Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 707546B0072
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 21:28:23 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id un1so9471805pbc.20
        for <linux-mm@kvack.org>; Fri, 04 Jan 2013 18:28:22 -0800 (PST)
From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v7 6/6] USB: forbid memory allocation with I/O during bus reset
Date: Sat,  5 Jan 2013 10:25:44 +0800
Message-Id: <1357352744-8138-7-git-send-email-ming.lei@canonical.com>
In-Reply-To: <1357352744-8138-1-git-send-email-ming.lei@canonical.com>
References: <1357352744-8138-1-git-send-email-ming.lei@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Ming Lei <ming.lei@canonical.com>

If one storage interface or usb network interface(iSCSI case)
exists in current configuration, memory allocation with
GFP_KERNEL during usb_device_reset() might trigger I/O transfer
on the storage interface itself and cause deadlock because
the 'us->dev_mutex' is held in .pre_reset() and the storage
interface can't do I/O transfer when the reset is triggered
by other interface, or the error handling can't be completed
if the reset is triggered by the storage itself(error handling path).

Cc: Alan Stern <stern@rowland.harvard.edu>
Cc: Oliver Neukum <oneukum@suse.de>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
--
v5:
	- use inline memalloc_noio_save()
v4:
	- mark current memalloc_noio for every usb device reset
---
 drivers/usb/core/hub.c |   13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/usb/core/hub.c b/drivers/usb/core/hub.c
index a815fd2..698922e 100644
--- a/drivers/usb/core/hub.c
+++ b/drivers/usb/core/hub.c
@@ -5040,6 +5040,7 @@ int usb_reset_device(struct usb_device *udev)
 {
 	int ret;
 	int i;
+	unsigned int noio_flag;
 	struct usb_host_config *config = udev->actconfig;
 
 	if (udev->state == USB_STATE_NOTATTACHED ||
@@ -5049,6 +5050,17 @@ int usb_reset_device(struct usb_device *udev)
 		return -EINVAL;
 	}
 
+	/*
+	 * Don't allocate memory with GFP_KERNEL in current
+	 * context to avoid possible deadlock if usb mass
+	 * storage interface or usbnet interface(iSCSI case)
+	 * is included in current configuration. The easist
+	 * approach is to do it for every device reset,
+	 * because the device 'memalloc_noio' flag may have
+	 * not been set before reseting the usb device.
+	 */
+	noio_flag = memalloc_noio_save();
+
 	/* Prevent autosuspend during the reset */
 	usb_autoresume_device(udev);
 
@@ -5093,6 +5105,7 @@ int usb_reset_device(struct usb_device *udev)
 	}
 
 	usb_autosuspend_device(udev);
+	memalloc_noio_restore(noio_flag);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(usb_reset_device);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
