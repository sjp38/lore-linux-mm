Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0A2A26B0160
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 09:35:08 -0400 (EDT)
Received: by pxi3 with SMTP id 3so2496923pxi.31
        for <linux-mm@kvack.org>; Mon, 21 Sep 2009 06:35:09 -0700 (PDT)
From: Nitin Gupta <ngupta@vflare.org>
Subject: [PATCH RFC 2/2] example usage of swap notifiers in ramzswap
Date: Mon, 21 Sep 2009 19:04:00 +0530
Message-Id: <1253540040-24860-2-git-send-email-ngupta@vflare.org>
In-Reply-To: <1253540040-24860-1-git-send-email-ngupta@vflare.org>
References: <1253540040-24860-1-git-send-email-ngupta@vflare.org>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This patch is against a version of ramzswap which uses module sepcific hacks
to register a callback for swap slot free event and does not use any notifier.

It shows improvments in the ramzswap module (in terms of code flow) that
resulted from swap notifier support added in patch 1/2.

Signed-off-by: Nitin Gupta <ngupta@vflare.org>

---

diff --git a/drivers/staging/ramzswap/ramzswap_drv.c b/drivers/staging/ramzswap/ramzswap_drv.c
index 1a7167f..1c5326e 100644
--- a/drivers/staging/ramzswap/ramzswap_drv.c
+++ b/drivers/staging/ramzswap/ramzswap_drv.c
@@ -647,19 +647,6 @@ out:
 	rzs->table[index].offset = 0;
 }
 
-/*
- * callback function called when swap_map[offset] == 0
- * i.e page at this swap offset is no longer used
- */
-static void ramzswap_free_notify(struct block_device *bdev,
-				unsigned long index)
-{
-	struct ramzswap *rzs = bdev->bd_disk->private_data;
-
-	ramzswap_free_page(rzs, index);
-	stat_inc(rzs->stats.notify_free);
-}
-
 static int handle_zero_page(struct bio *bio)
 {
 	void *user_mem;
@@ -760,11 +747,6 @@ static int ramzswap_read(struct ramzswap *rzs, struct bio *bio)
 	page = bio->bi_io_vec[0].bv_page;
 	index = bio->bi_sector >> SECTORS_PER_PAGE_SHIFT;
 
-	if (unlikely(!rzs->init_notify_callback) && PageSwapCache(page)) {
-		set_ramzswap_free_notify(bio->bi_bdev, ramzswap_free_notify);
-		rzs->init_notify_callback = 1;
-	}
-
 	if (rzs_test_flag(rzs, index, RZS_ZERO))
 		return handle_zero_page(bio);
 
@@ -1318,13 +1300,6 @@ static int ramzswap_ioctl(struct block_device *bdev, fmode_t mode,
 			goto out;
 		}
 		ret = ramzswap_ioctl_reset_device(rzs);
-		/*
-		 * Racy! Device has already been swapoff'ed.  Bad things
-		 * can happen if another swapon is done before this reset.
-		 * TODO: A callback from swapoff() will solve this problem.
-		 */
-		set_ramzswap_free_notify(bdev, NULL);
-		rzs->init_notify_callback = 0;
 		break;
 
 	default:
@@ -1395,13 +1370,62 @@ static void destroy_device(struct ramzswap *rzs)
 		blk_cleanup_queue(rzs->queue);
 }
 
+static int ramzswap_slot_free_notify(struct notifier_block *self,
+			unsigned long index, void *swap_file)
+{
+	struct block_device *bdev;
+	struct inode *inode;
+	struct ramzswap *rzs;
+
+	inode = ((struct file *)swap_file)->f_mapping->host;
+	bdev = I_BDEV(inode);
+	rzs = bdev->bd_disk->private_data;
+
+	ramzswap_free_page(rzs, index);
+	stat_inc(rzs->stats.notify_free);
+	return 0;
+}
+
+static struct notifier_block ramzswap_slot_free_nb = {
+	.notifier_call = ramzswap_slot_free_notify
+};
+
+static int ramzswap_swapon_notify(struct notifier_block *self,
+			unsigned long swap_id, void *swap_file)
+{
+	int ret = 0;
+
+	ret = register_swap_event_notifier(&ramzswap_slot_free_nb,
+				SWAP_EVENT_SLOT_FREE, swap_id);
+	if (ret)
+		pr_err("Error registering swap free notifier\n");
+	return ret;
+}
+
+static int ramzswap_swapoff_notify(struct notifier_block *self,
+			unsigned long swap_id, void *swap_file)
+{
+	unregister_swap_event_notifier(&ramzswap_slot_free_nb,
+				SWAP_EVENT_SLOT_FREE, swap_id);
+	return 0;
+}
+
+
+static struct notifier_block ramzswap_swapon_nb = {
+	.notifier_call = ramzswap_swapon_notify
+};
+
+static struct notifier_block ramzswap_swapoff_nb = {
+	.notifier_call = ramzswap_swapoff_notify
+};
+
 static int __init ramzswap_init(void)
 {
-	int i;
+	int i, ret;
 
 	if (num_devices > max_num_devices) {
 		pr_warning("Invalid value for num_devices: %u\n",
-							num_devices);
+				num_devices);
 		return -EINVAL;
 	}
 
@@ -1419,17 +1443,32 @@ static int __init ramzswap_init(void)
 	/* Allocate the device array and initialize each one */
 	pr_info("Creating %u devices ...\n", num_devices);
 	devices = kzalloc(num_devices * sizeof(struct ramzswap), GFP_KERNEL);
-	if (!devices)
+	if (!devices) {
+		ret = -ENOMEM;
 		goto out;
+	}
 
 	for (i = 0; i < num_devices; i++)
 		create_device(&devices[i], i);
 
+	ret = register_swap_event_notifier(&ramzswap_swapon_nb,
+				SWAP_EVENT_SWAPON, 0);
+	if (ret) {
+		pr_err("Error registering swapon notifier\n");
+		goto out;
+	}
+
+	ret = register_swap_event_notifier(&ramzswap_swapoff_nb,
+				SWAP_EVENT_SWAPOFF, 0);
+	if (ret) {
+		pr_err("Error registering swapoff notifier\n");
+		goto out;
+	}
 	return 0;
 
 out:
 	unregister_blkdev(ramzswap_major, "ramzswap");
-	return -ENOMEM;
+	return ret;
 }
 
 static void __exit ramzswap_exit(void)
@@ -1437,6 +1476,11 @@ static void __exit ramzswap_exit(void)
 	int i;
 	struct ramzswap *rzs;
 
+	unregister_swap_event_notifier(&ramzswap_swapon_nb,
+				SWAP_EVENT_SWAPON, 0);
+	unregister_swap_event_notifier(&ramzswap_swapoff_nb,
+				SWAP_EVENT_SWAPOFF, 0);
+
 	for (i = 0; i < num_devices; i++) {
 		rzs = &devices[i];
 
diff --git a/drivers/staging/ramzswap/ramzswap_drv.h b/drivers/staging/ramzswap/ramzswap_drv.h
index f7f273f..350db81 100644
--- a/drivers/staging/ramzswap/ramzswap_drv.h
+++ b/drivers/staging/ramzswap/ramzswap_drv.h
@@ -143,7 +143,6 @@ struct ramzswap {
 	struct request_queue *queue;
 	struct gendisk *disk;
 	int init_done;
-	int init_notify_callback;
 	/*
 	 * This is limit on compressed data size (stats.compr_size)
 	 * Its applicable only when backing swap device is present.
@@ -162,6 +161,7 @@ struct ramzswap {
 	struct ramzswap_backing_extent *curr_extent;
 	struct list_head backing_swap_extent_list;
 	unsigned long num_extents;
+	struct notifier_block *slot_free_nb;
 	char backing_swap_name[MAX_SWAP_NAME_LEN];
 	struct block_device *backing_swap;
 	struct file *swap_file;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
