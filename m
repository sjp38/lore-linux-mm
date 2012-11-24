Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id C44576B004D
	for <linux-mm@kvack.org>; Sat, 24 Nov 2012 08:00:55 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so7475434pbc.14
        for <linux-mm@kvack.org>; Sat, 24 Nov 2012 05:00:55 -0800 (PST)
From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v6 5/6] PM / Runtime: force memory allocation with no I/O during Runtime PM callbcack
Date: Sat, 24 Nov 2012 20:59:17 +0800
Message-Id: <1353761958-12810-6-git-send-email-ming.lei@canonical.com>
In-Reply-To: <1353761958-12810-1-git-send-email-ming.lei@canonical.com>
References: <1353761958-12810-1-git-send-email-ming.lei@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@canonical.com>

This patch applies the introduced memalloc_noio_save() and
memalloc_noio_restore() to force memory allocation with no I/O
during runtime_resume/runtime_suspend callback on device with
the flag of 'memalloc_noio' set.

Cc: Alan Stern <stern@rowland.harvard.edu>
Cc: Oliver Neukum <oneukum@suse.de>
Cc: Rafael J. Wysocki <rjw@sisk.pl>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
v5:
	- use inline memalloc_noio_save()
v4:
	- runtime_suspend need this too because rpm_resume may wait for
	completion of concurrent runtime_suspend, so deadlock still may
	be triggered in runtime_suspend path.
---
 drivers/base/power/runtime.c |   32 ++++++++++++++++++++++++++++++--
 1 file changed, 30 insertions(+), 2 deletions(-)

diff --git a/drivers/base/power/runtime.c b/drivers/base/power/runtime.c
index 3e198a0..96d99ea 100644
--- a/drivers/base/power/runtime.c
+++ b/drivers/base/power/runtime.c
@@ -371,6 +371,7 @@ static int rpm_suspend(struct device *dev, int rpmflags)
 	int (*callback)(struct device *);
 	struct device *parent = NULL;
 	int retval;
+	unsigned int noio_flag;
 
 	trace_rpm_suspend(dev, rpmflags);
 
@@ -480,7 +481,20 @@ static int rpm_suspend(struct device *dev, int rpmflags)
 	if (!callback && dev->driver && dev->driver->pm)
 		callback = dev->driver->pm->runtime_suspend;
 
-	retval = rpm_callback(callback, dev);
+	/*
+	 * Deadlock might be caused if memory allocation with GFP_KERNEL
+	 * happens inside runtime_suspend callback of one block device's
+	 * ancestor or the block device itself. Network device might be
+	 * thought as part of iSCSI block device, so network device and
+	 * its ancestor should be marked as memalloc_noio.
+	 */
+	if (dev->power.memalloc_noio) {
+		noio_flag = memalloc_noio_save();
+		retval = rpm_callback(callback, dev);
+		memalloc_noio_restore(noio_flag);
+	} else {
+		retval = rpm_callback(callback, dev);
+	}
 	if (retval)
 		goto fail;
 
@@ -563,6 +577,7 @@ static int rpm_resume(struct device *dev, int rpmflags)
 	int (*callback)(struct device *);
 	struct device *parent = NULL;
 	int retval = 0;
+	unsigned int noio_flag;
 
 	trace_rpm_resume(dev, rpmflags);
 
@@ -712,7 +727,20 @@ static int rpm_resume(struct device *dev, int rpmflags)
 	if (!callback && dev->driver && dev->driver->pm)
 		callback = dev->driver->pm->runtime_resume;
 
-	retval = rpm_callback(callback, dev);
+	/*
+	 * Deadlock might be caused if memory allocation with GFP_KERNEL
+	 * happens inside runtime_resume callback of one block device's
+	 * ancestor or the block device itself. Network device might be
+	 * thought as part of iSCSI block device, so network device and
+	 * its ancestor should be marked as memalloc_noio.
+	 */
+	if (dev->power.memalloc_noio) {
+		noio_flag = memalloc_noio_save();
+		retval = rpm_callback(callback, dev);
+		memalloc_noio_restore(noio_flag);
+	} else {
+		retval = rpm_callback(callback, dev);
+	}
 	if (retval) {
 		__update_runtime_status(dev, RPM_SUSPENDED);
 		pm_runtime_cancel_pending(dev);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
