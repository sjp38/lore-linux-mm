Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 477B46B0071
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 02:18:17 -0500 (EST)
Received: by gxk24 with SMTP id 24so21214026gxk.6
        for <linux-mm@kvack.org>; Sun, 10 Jan 2010 23:18:15 -0800 (PST)
Date: Mon, 11 Jan 2010 16:15:53 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH] Free memory when create_device is failed
Message-Id: <20100111161553.3acebae9.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Kroah-Hartman <greg@kroah.com>
Cc: Nitin Gupta <ngupta@vflare.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

	
Hi, Greg.

I don't know where I send this patch.
Do I send this patch to akpm or only you and LKML?

== CUT HERE ==

If create_device is failed, it can't free gendisk and request_queue 
of preceding devices. It cause memory leak.

This patch fixes it.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
CC: Nitin Gupta <ngupta@vflare.org>
---
 drivers/staging/ramzswap/ramzswap_drv.c |   21 +++++++++++++--------
 1 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/ramzswap/ramzswap_drv.c b/drivers/staging/ramzswap/ramzswap_drv.c
index 18196f3..faa412d 100644
--- a/drivers/staging/ramzswap/ramzswap_drv.c
+++ b/drivers/staging/ramzswap/ramzswap_drv.c
@@ -1292,7 +1292,7 @@ static struct block_device_operations ramzswap_devops = {
 	.owner = THIS_MODULE,
 };
 
-static void create_device(struct ramzswap *rzs, int device_id)
+static int create_device(struct ramzswap *rzs, int device_id)
 {
 	mutex_init(&rzs->lock);
 	INIT_LIST_HEAD(&rzs->backing_swap_extent_list);
@@ -1301,7 +1301,7 @@ static void create_device(struct ramzswap *rzs, int device_id)
 	if (!rzs->queue) {
 		pr_err("Error allocating disk queue for device %d\n",
 			device_id);
-		return;
+		return 0;
 	}
 
 	blk_queue_make_request(rzs->queue, ramzswap_make_request);
@@ -1313,7 +1313,7 @@ static void create_device(struct ramzswap *rzs, int device_id)
 		blk_cleanup_queue(rzs->queue);
 		pr_warning("Error allocating disk structure for device %d\n",
 			device_id);
-		return;
+		return 0;
 	}
 
 	rzs->disk->major = ramzswap_major;
@@ -1331,6 +1331,7 @@ static void create_device(struct ramzswap *rzs, int device_id)
 	add_disk(rzs->disk);
 
 	rzs->init_done = 0;
+	return 1;
 }
 
 static void destroy_device(struct ramzswap *rzs)
@@ -1368,16 +1369,20 @@ static int __init ramzswap_init(void)
 	/* Allocate the device array and initialize each one */
 	pr_info("Creating %u devices ...\n", num_devices);
 	devices = kzalloc(num_devices * sizeof(struct ramzswap), GFP_KERNEL);
-	if (!devices) {
-		ret = -ENOMEM;
+	if (!devices)
 		goto out;
-	}
 
 	for (i = 0; i < num_devices; i++)
-		create_device(&devices[i], i);
-
+		if (!create_device(&devices[i], i)) {
+			ret = i;
+			goto free_devices;
+		}
 	return 0;
+free_devices:
+	for (i = 0; i < ret; i++)
+		destroy_device(&devices[i]);
 out:
+	ret = -ENOMEM;
 	unregister_blkdev(ramzswap_major, "ramzswap");
 	return ret;
 }
-- 
1.5.6.3



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
