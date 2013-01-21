Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id C562C6B0005
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 00:21:34 -0500 (EST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3 1/4] zram: force disksize setting before using zram
Date: Mon, 21 Jan 2013 14:21:28 +0900
Message-Id: <1358745691-4556-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Pekka Enberg <penberg@cs.helsinki.fi>, jmarchan@redhat.com, Minchan Kim <minchan@kernel.org>

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

Cc: Nitin Gupta <ngupta@vflare.org>
Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/staging/zram/zram.txt     |   27 +++++++++----------
 drivers/staging/zram/zram_drv.c   |   52 ++++++++++++++-----------------------
 drivers/staging/zram/zram_drv.h   |    5 +---
 drivers/staging/zram/zram_sysfs.c |    6 +----
 4 files changed, 35 insertions(+), 55 deletions(-)

diff --git a/drivers/staging/zram/zram.txt b/drivers/staging/zram/zram.txt
index 5f75d29..765d790 100644
--- a/drivers/staging/zram/zram.txt
+++ b/drivers/staging/zram/zram.txt
@@ -23,17 +23,17 @@ Following shows a typical sequence of steps for using zram.
 	This creates 4 devices: /dev/zram{0,1,2,3}
 	(num_devices parameter is optional. Default: 1)
 
-2) Set Disksize (Optional):
-	Set disk size by writing the value to sysfs node 'disksize'
-	(in bytes). If disksize is not given, default value of 25%
-	of RAM is used.
-
-	# Initialize /dev/zram0 with 50MB disksize
-	echo $((50*1024*1024)) > /sys/block/zram0/disksize
-
-	NOTE: disksize cannot be changed if the disk contains any
-	data. So, for such a disk, you need to issue 'reset' (see below)
-	before you can change its disksize.
+2) Set Disksize
+        Set disk size by writing the value to sysfs node 'disksize'.
+        The value can be either in bytes or you can use mem suffixes.
+        Examples:
+            # Initialize /dev/zram0 with 50MB disksize
+            echo $((50*1024*1024)) > /sys/block/zram0/disksize
+
+            # Using mem suffixes
+            echo 256K > /sys/block/zram0/disksize
+            echo 512M > /sys/block/zram0/disksize
+            echo 1G > /sys/block/zram0/disksize
 
 3) Activate:
 	mkswap /dev/zram0
@@ -65,8 +65,9 @@ Following shows a typical sequence of steps for using zram.
 	echo 1 > /sys/block/zram0/reset
 	echo 1 > /sys/block/zram1/reset
 
-	(This frees all the memory allocated for the given device).
-
+	This frees all the memory allocated for the given device and
+	resets the disksize to zero. You must set the disksize again
+	before reusing the device.
 
 Please report any problems at:
  - Mailing list: linux-mm-cc at laptop dot org
diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
index 61fb8f1..1d45401 100644
--- a/drivers/staging/zram/zram_drv.c
+++ b/drivers/staging/zram/zram_drv.c
@@ -94,34 +94,6 @@ static int page_zero_filled(void *ptr)
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
-		totalram_bytes >> 10, zram->disksize >> 10);
-	}
-
-	zram->disksize &= PAGE_MASK;
-}
-
 static void zram_free_page(struct zram *zram, size_t index)
 {
 	unsigned long handle = zram->table[index].handle;
@@ -495,6 +467,9 @@ void __zram_reset_device(struct zram *zram)
 {
 	size_t index;
 
+	if (!zram->init_done)
+		goto out;
+
 	zram->init_done = 0;
 
 	/* Free various per-device buffers */
@@ -522,7 +497,9 @@ void __zram_reset_device(struct zram *zram)
 	/* Reset stats */
 	memset(&zram->stats, 0, sizeof(zram->stats));
 
+out:
 	zram->disksize = 0;
+	set_capacity(zram->disk, 0);
 }
 
 void zram_reset_device(struct zram *zram)
@@ -544,7 +521,19 @@ int zram_init_device(struct zram *zram)
 		return 0;
 	}
 
-	zram_set_disksize(zram, totalram_pages << PAGE_SHIFT);
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
+		(totalram_pages << PAGE_SHIFT) >> 10, zram->disksize >> 10
+		);
+	}
 
 	zram->compress_workmem = kzalloc(LZO1X_MEM_COMPRESS, GFP_KERNEL);
 	if (!zram->compress_workmem) {
@@ -569,8 +558,6 @@ int zram_init_device(struct zram *zram)
 		goto fail_no_table;
 	}
 
-	set_capacity(zram->disk, zram->disksize >> SECTOR_SHIFT);
-
 	/* zram devices sort of resembles non-rotational disks */
 	queue_flag_set_unlocked(QUEUE_FLAG_NONROT, zram->disk->queue);
 
@@ -749,8 +736,7 @@ static void __exit zram_exit(void)
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
