//
//  ViewController.swift
//  LayerX
//
//  Created by Michael Chen on 2015/10/26.
//  Copyright © 2015年 Michael Chen. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var imageView: MCDragAndDropImageView!
    @IBOutlet weak var sizeTextField: NSTextField!
    @IBOutlet weak var placeholderTextField: NSTextField!
    @IBOutlet weak var lockIconImageView: NSImageView!

    override var acceptsFirstResponder: Bool {
        return true
    }

    lazy var trackingArea: NSTrackingArea = {
        let options: NSTrackingArea.Options = [.activeAlways, .mouseEnteredAndExited]
        return NSTrackingArea(rect: self.view.bounds, options: options, owner: self, userInfo: nil)
    }()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        appDelegate().viewController = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.delegate = self

        sizeTextField.layer?.cornerRadius = 3
        sizeTextField.layer?.masksToBounds = true

        lockIconImageView.wantsLayer = true
        lockIconImageView.layer?.backgroundColor = NSColor(white: 0.0, alpha: 0.5).cgColor
        lockIconImageView.layer?.cornerRadius = 5
        lockIconImageView.layer?.masksToBounds = true

        NotificationCenter.default.addObserver(self, selector: #selector(windowDidResize(_:)), name: NSWindow.didResizeNotification, object: appDelegate().window)

        view.addTrackingArea(trackingArea)

        placeholderTextField.isHidden = true
        appDelegate().imageOne(nil)
        imageView.alphaValue = 0.7
    }

    override func viewDidAppear() {
        super.viewDidAppear()
    }

    @objc func fadeOutSizeTextField() {
        let transition = CATransition()
        sizeTextField.layer?.add(transition, forKey: "fadeOut")
        sizeTextField.layer?.opacity = 0
    }

    @objc func windowDidResize(_ notification: Notification) {
        let window = notification.object as! NSWindow
        let size = window.frame.size
        sizeTextField.stringValue = "\(Int(size.width))x\(Int(size.height))"
        sizeTextField.layer?.opacity = 1

        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(ViewController.fadeOutSizeTextField), object: nil)
        perform(#selector(ViewController.fadeOutSizeTextField), with: nil, afterDelay: 2)
    }

    // MARK: Mouse events

    override func scrollWheel(with theEvent: NSEvent) {
        guard let _ = imageView.image else { return }

        let delta = theEvent.deltaY * 0.005;
        var alpha = imageView.alphaValue - delta
        alpha = min(alpha, 1)
        alpha = max(alpha, 0.05)
        imageView.alphaValue = alpha
    }

    override func mouseEntered(with theEvent: NSEvent) {
        sizeTextField.layer?.opacity = 1
    }

    override func mouseExited(with theEvent: NSEvent) {
        fadeOutSizeTextField()
    }
}

// MARK: - MCDragAndDropImageViewDelegate

extension ViewController: MCDragAndDropImageViewDelegate {
    func dragAndDropImageViewDidDrop(_ imageView: MCDragAndDropImageView) {

        sizeTextField.isHidden = false
        placeholderTextField.isHidden = true

        appDelegate().actualSize(nil)
    }
}

// MARK: - Movable NSView

class MCMovableView: NSView {
    override var mouseDownCanMoveWindow: Bool {
        return true
    }
}
