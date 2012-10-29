Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 529FD6B006C
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 08:26:46 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so2606285dad.14
        for <linux-mm@kvack.org>; Mon, 29 Oct 2012 05:26:45 -0700 (PDT)
From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v3 6/6] USB: forbid memory allocation with I/O during bus reset
Date: Mon, 29 Oct 2012 20:24:00 +0800
Message-Id: <1351513440-9286-7-git-send-email-ming.lei@canonical.com>
In-Reply-To: <1351513440-9286-1-git-send-email-ming.lei@canonical.com>
References: <1351513440-9286-1-git-send-email-ming.lei@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@canonical.com>

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
---
v3:
	- check usbnet device or usb mass storage device by
	'dev->power.memalloc_noio_resume' as suggested by Alan Stern
---
 drivers/usb/core/hub.c |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/drivers/usb/core/hub.c b/drivers/usb/core/hub.c
index 5b131b6..5aea807 100644
--- a/drivers/usb/core/hub.c
+++ b/drivers/usb/core/hub.c
@@ -5044,6 +5044,8 @@ int usb_reset_device(struct usb_device *udev)
 {
 	int ret;
 	int i;
+	unsigned int uninitialized_var(noio_flag);
+	bool noio_set = false;
 	struct usb_host_config *config = udev->actconfig;
 
 	if (udev->state == USB_STATE_NOTATTACHED ||
@@ -5053,6 +5055,17 @@ int usb_reset_device(struct usb_device *udev)
 		return -EINVAL;
 	}
 
+	/*
+	 * Don't allocate memory with GFP_KERNEL in current
+	 * context to avoid possible deadlock if usb mass
+	 * storage interface or usbnet interface(iSCSI case)
+	 * is included in current configuration.
+	 */
+	if (pm_runtime_get_memalloc_noio(&udev->dev)) {
+		memalloc_noio_save(noio_flag);
+		noio_set = true;
+	}
+
 	/* Prevent autosuspend during the reset */
 	usb_autoresume_device(udev);
 
@@ -5097,6 +5110,8 @@ int usb_reset_device(struct usb_device *udev)
 	}
 
 	usb_autosuspend_device(udev);
+	if (noio_set)
+		memalloc_noio_restore(noio_flag);
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
