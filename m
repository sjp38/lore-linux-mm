Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 275B16B0069
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 04:35:39 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so1880654pad.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 01:35:38 -0700 (PDT)
From: Ming Lei <ming.lei@canonical.com>
Subject: [RFC PATCH v2 3/6] block/genhd.c: apply pm_runtime_set_memalloc_noio on block devices
Date: Mon, 22 Oct 2012 16:33:11 +0800
Message-Id: <1350894794-1494-4-git-send-email-ming.lei@canonical.com>
In-Reply-To: <1350894794-1494-1-git-send-email-ming.lei@canonical.com>
References: <1350894794-1494-1-git-send-email-ming.lei@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@canonical.com>

This patch applyes the introduced pm_runtime_set_memalloc_noio on
block device so that PM core will teach mm to not allocate memory with
GFP_IOFS when calling the runtime_resume callback for block devices.

Cc: Jens Axboe <axboe@kernel.dk>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 block/genhd.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/block/genhd.c b/block/genhd.c
index 9e02cd6..c5f10ea 100644
--- a/block/genhd.c
+++ b/block/genhd.c
@@ -18,6 +18,7 @@
 #include <linux/mutex.h>
 #include <linux/idr.h>
 #include <linux/log2.h>
+#include <linux/pm_runtime.h>
 
 #include "blk.h"
 
@@ -519,6 +520,12 @@ static void register_disk(struct gendisk *disk)
 
 	dev_set_name(ddev, disk->disk_name);
 
+	/* avoid probable deadlock caused by allocate memory with
+	 * GFP_KERNEL in runtime_resume callback of its all ancestor
+	 * deivces
+	 */
+	pm_runtime_set_memalloc_noio(ddev, true);
+
 	/* delay uevents, until we scanned partition table */
 	dev_set_uevent_suppress(ddev, 1);
 
@@ -661,6 +668,7 @@ void del_gendisk(struct gendisk *disk)
 	disk->driverfs_dev = NULL;
 	if (!sysfs_deprecated)
 		sysfs_remove_link(block_depr, dev_name(disk_to_dev(disk)));
+	pm_runtime_set_memalloc_noio(disk_to_dev(disk), false);
 	device_del(disk_to_dev(disk));
 }
 EXPORT_SYMBOL(del_gendisk);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
