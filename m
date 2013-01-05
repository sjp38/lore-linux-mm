Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 959BB6B006E
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 21:28:10 -0500 (EST)
Received: by mail-da0-f43.google.com with SMTP id u36so7777658dak.16
        for <linux-mm@kvack.org>; Fri, 04 Jan 2013 18:28:09 -0800 (PST)
From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v7 5/6] PM / Runtime: force memory allocation with no I/O during Runtime PM callbcack
Date: Sat,  5 Jan 2013 10:25:43 +0800
Message-Id: <1357352744-8138-6-git-send-email-ming.lei@canonical.com>
In-Reply-To: <1357352744-8138-1-git-send-email-ming.lei@canonical.com>
References: <1357352744-8138-1-git-send-email-ming.lei@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Ming Lei <ming.lei@canonical.com>

This patch applies the introduced memalloc_noio_save() and
memalloc_noio_restore() to force memory allocation with no I/O
during runtime_resume/runtime_suspend callback on device with
the flag of 'memalloc_noio' set.

Cc: Alan Stern <stern@rowland.harvard.edu>
Cc: Oliver Neukum <oneukum@suse.de>
Cc: Rafael J. Wysocki <rjw@sisk.pl>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
--
v7:
	- move memalloc_noio_save/memalloc_noio_restore into
	rpm_callback to avoid code duplication, as suggested
	by Rafael
v5:
	- use inline memalloc_noio_save()
v4:
	- runtime_suspend need this too because rpm_resume may wait for
	completion of concurrent runtime_suspend, so deadlock still may
	be triggered in runtime_suspend path.
---
 drivers/base/power/runtime.c |   19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

diff --git a/drivers/base/power/runtime.c b/drivers/base/power/runtime.c
index cd92e1c..1244930 100644
--- a/drivers/base/power/runtime.c
+++ b/drivers/base/power/runtime.c
@@ -348,7 +348,24 @@ static int rpm_callback(int (*cb)(struct device *), struct device *dev)
 	if (!cb)
 		return -ENOSYS;
 
-	retval = __rpm_callback(cb, dev);
+	if (dev->power.memalloc_noio) {
+		unsigned int noio_flag;
+
+		/*
+		 * Deadlock might be caused if memory allocation with
+		 * GFP_KERNEL happens inside runtime_suspend and
+		 * runtime_resume callbacks of one block device's
+		 * ancestor or the block device itself. Network
+		 * device might be thought as part of iSCSI block
+		 * device, so network device and its ancestor should
+		 * be marked as memalloc_noio too.
+		 */
+		noio_flag = memalloc_noio_save();
+		retval = __rpm_callback(cb, dev);
+		memalloc_noio_restore(noio_flag);
+	} else {
+		retval = __rpm_callback(cb, dev);
+	}
 
 	dev->power.runtime_error = retval;
 	return retval != -EACCES ? retval : -EIO;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
