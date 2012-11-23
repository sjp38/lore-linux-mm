Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id C04EF6B0044
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 21:42:32 -0500 (EST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 1/2] zram: force disksize setting before using zram
Date: Fri, 23 Nov 2012 11:42:46 +0900
Message-Id: <1353638567-3981-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Jerome Marchand <jmarchan@redhat.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan@kernel.org>

Now zram document syas "set disksize is optional"
but partly it's wrong. When you try to use zram firstly after
booting, you must set disksize, otherwise zram can't work because
zram gendisk's size is 0. But once you do it, you can use zram freely
after reset because reset doesn't reset to zero paradoxically.
So in this time, disksize setting is optional.:(
It's inconsitent for user behavior and not straightforward.

This patch forces always setting disksize firstly before using zram.
Yes. It changes current behavior so someone could complain when
he upgrades zram. Apparently it could be a problem if zram is mainline
but it still lives in staging so behavior could be changed for right
way to go. Let them excuse.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/staging/zram/zram.txt     |    7 +++--
 drivers/staging/zram/zram_drv.c   |   57 ++++++++++++++-----------------------
 drivers/staging/zram/zram_drv.h   |    5 +---
 drivers/staging/zram/zram_sysfs.c |    6 +---
 4 files changed, 27 insertions(+), 48 deletions(-)

diff --git a/drivers/staging/zram/zram.txt b/drivers/staging/zram/zram.txt
index 5f75d29..00ae66b 100644
--- a/drivers/staging/zram/zram.txt
+++ b/drivers/staging/zram/zram.txt
@@ -23,10 +23,9 @@ Following shows a typical sequence of steps for using zram.
 	This creates 4 devices: /dev/zram{0,1,2,3}
 	(num_devices parameter is optional. Default: 1)
 
-2) Set Disksize (Optional):
+2) Set Disksize
 	Set disk size by writing the value to sysfs node 'disksize'
-	(in bytes). If disksize is not given, default value of 25%
-	of RAM is used.
+	(in bytes).
 
 	# Initialize /dev/zram0 with 50MB disksize
 	echo $((50*1024*1024)) > /sys/block/zram0/disksize
@@ -67,6 +66,8 @@ Following shows a typical sequence of steps for using zram.
 
 	(This frees all the memory allocated for the given device).
 
+	If you want to use zram again, you should set disksize first
+	due to reset zram.
 
 Please report any problems at:
  - Mailing list: linux-mm-cc at laptop dot org
diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
index fb4a7c9..9ef1eca 100644
--- a/drivers/staging/zram/zram_drv.c
+++ b/drivers/staging/zram/zram_drv.c
@@ -104,35 +104,6 @@ static int page_zero_filled(void *ptr)
 	return 1;
 }
 
-static void zram_set_disksize(struct zram *zram, size_t totalram_bytes)
-{
-	if (!zram->disksize) {
-		pr_info(
-		"disk size not provided. You can use disksize_kb module "
-		"param to specify size.\nUsing default: (%u%% of RAM).\n",
-		default_disksize_perc_ram
-		);
-		zram->disksize = default_disksize_perc_ram *
-					(totalram_bytes / 100);
-	}
-
-	if (zram->disksize > 2 * (totalram_bytes)) {
-		pr_info(
-		"There is little point creating a zram of greater than "
-		"twice the size of memory since we expect a 2:1 compression "
-		"ratio. Note that zram uses about 0.1%% of the size of "
-		"the disk when not in use so a huge zram is "
-		"wasteful.\n"
-		"\tMemory Size: %zu kB\n"
-		"\tSize you selected: %llu kB\n"
-		"Continuing anyway ...\n",
-		totalram_bytes >> 10, zram->disksize
-		);
-	}
-
-	zram->disksize &= PAGE_MASK;
-}
-
 static void zram_free_page(struct zram *zram, size_t index)
 {
 	unsigned long handle = zram->table[index].handle;
@@ -497,6 +468,9 @@ void __zram_reset_device(struct zram *zram)
 {
 	size_t index;
 
+	if (!zram->init_done)
+		goto out;
+
 	zram->init_done = 0;
 
 	/* Free various per-device buffers */
@@ -523,8 +497,9 @@ void __zram_reset_device(struct zram *zram)
 
 	/* Reset stats */
 	memset(&zram->stats, 0, sizeof(zram->stats));
-
+out:
 	zram->disksize = 0;
+	set_capacity(zram->disk, 0);
 }
 
 void zram_reset_device(struct zram *zram)
@@ -540,13 +515,26 @@ int zram_init_device(struct zram *zram)
 	size_t num_pages;
 
 	down_write(&zram->init_lock);
-
 	if (zram->init_done) {
 		up_write(&zram->init_lock);
 		return 0;
 	}
 
-	zram_set_disksize(zram, totalram_pages << PAGE_SHIFT);
+	BUG_ON(!zram->disksize);
+
+	if (zram->disksize > 2 * (totalram_pages << PAGE_SHIFT)) {
+		pr_info(
+		"There is little point creating a zram of greater than "
+		"twice the size of memory since we expect a 2:1 compression "
+		"ratio. Note that zram uses about 0.1%% of the size of "
+		"the disk when not in use so a huge zram is "
+		"wasteful.\n"
+		"\tMemory Size: %zu kB\n"
+		"\tSize you selected: %llu kB\n"
+		"Continuing anyway ...\n",
+		(totalram_pages << PAGE_SHIFT) >> 10, zram->disksize
+		);
+	}
 
 	zram->compress_workmem = kzalloc(LZO1X_MEM_COMPRESS, GFP_KERNEL);
 	if (!zram->compress_workmem) {
@@ -571,8 +559,6 @@ int zram_init_device(struct zram *zram)
 		goto fail_no_table;
 	}
 
-	set_capacity(zram->disk, zram->disksize >> SECTOR_SHIFT);
-
 	/* zram devices sort of resembles non-rotational disks */
 	queue_flag_set_unlocked(QUEUE_FLAG_NONROT, zram->disk->queue);
 
@@ -755,8 +741,7 @@ static void __exit zram_exit(void)
 		zram = &zram_devices[i];
 
 		destroy_device(zram);
-		if (zram->init_done)
-			zram_reset_device(zram);
+		zram_reset_device(zram);
 	}
 
 	unregister_blkdev(zram_major, "zram");
diff --git a/drivers/staging/zram/zram_drv.h b/drivers/staging/zram/zram_drv.h
index df2eec4..5b671d1 100644
--- a/drivers/staging/zram/zram_drv.h
+++ b/drivers/staging/zram/zram_drv.h
@@ -28,9 +28,6 @@ static const unsigned max_num_devices = 32;
 
 /*-- Configurable parameters */
 
-/* Default zram disk size: 25% of total RAM */
-static const unsigned default_disksize_perc_ram = 25;
-
 /*
  * Pages that compress to size greater than this are stored
  * uncompressed in memory.
@@ -115,6 +112,6 @@ extern struct attribute_group zram_disk_attr_group;
 #endif
 
 extern int zram_init_device(struct zram *zram);
-extern void __zram_reset_device(struct zram *zram);
+extern void zram_reset_device(struct zram *zram);
 
 #endif
diff --git a/drivers/staging/zram/zram_sysfs.c b/drivers/staging/zram/zram_sysfs.c
index de1eacf..4143af9 100644
--- a/drivers/staging/zram/zram_sysfs.c
+++ b/drivers/staging/zram/zram_sysfs.c
@@ -110,11 +110,7 @@ static ssize_t reset_store(struct device *dev,
 	if (bdev)
 		fsync_bdev(bdev);
 
-	down_write(&zram->init_lock);
-	if (zram->init_done)
-		__zram_reset_device(zram);
-	up_write(&zram->init_lock);
-
+	zram_reset_device(zram);
 	return len;
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
