Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 79A316B0044
	for <linux-mm@kvack.org>; Sat,  3 Nov 2012 04:37:01 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so3206600pbb.14
        for <linux-mm@kvack.org>; Sat, 03 Nov 2012 01:37:00 -0700 (PDT)
From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v4 5/6] PM / Runtime: force memory allocation with no I/O during Runtime PM callbcack
Date: Sat,  3 Nov 2012 16:35:13 +0800
Message-Id: <1351931714-11689-6-git-send-email-ming.lei@canonical.com>
In-Reply-To: <1351931714-11689-1-git-send-email-ming.lei@canonical.com>
References: <1351931714-11689-1-git-send-email-ming.lei@canonical.com>
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
v4:
	- runtime_suspend need this too because rpm_resume may wait for
	completion of concurrent runtime_suspend, so deadlock still may
	be triggered in runtime_suspend path.
---
 drivers/base/power/runtime.c |   32 ++++++++++++++++++++++++++++++--
 1 file changed, 30 insertions(+), 2 deletions(-)

diff --git a/drivers/base/power/runtime.c b/drivers/base/power/runtime.c
index d477924..7ed17a9 100644
--- a/drivers/base/power/runtime.c
+++ b/drivers/base/power/runtime.c
@@ -368,6 +368,7 @@ static int rpm_suspend(struct device *dev, int rpmflags)
 	int (*callback)(struct device *);
 	struct device *parent = NULL;
 	int retval;
+	unsigned int noio_flag;
 
 	trace_rpm_suspend(dev, rpmflags);
 
@@ -477,7 +478,20 @@ static int rpm_suspend(struct device *dev, int rpmflags)
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
+		memalloc_noio_save(noio_flag);
+		retval = rpm_callback(callback, dev);
+		memalloc_noio_restore(noio_flag);
+	} else {
+		retval = rpm_callback(callback, dev);
+	}
 	if (retval)
 		goto fail;
 
@@ -560,6 +574,7 @@ static int rpm_resume(struct device *dev, int rpmflags)
 	int (*callback)(struct device *);
 	struct device *parent = NULL;
 	int retval = 0;
+	unsigned int noio_flag;
 
 	trace_rpm_resume(dev, rpmflags);
 
@@ -709,7 +724,20 @@ static int rpm_resume(struct device *dev, int rpmflags)
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
+		memalloc_noio_save(noio_flag);
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
