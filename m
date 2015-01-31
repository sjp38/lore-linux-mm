Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4CC736B0032
	for <linux-mm@kvack.org>; Sat, 31 Jan 2015 03:27:18 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id eu11so61617542pac.2
        for <linux-mm@kvack.org>; Sat, 31 Jan 2015 00:27:18 -0800 (PST)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id h10si16439265pat.194.2015.01.31.00.27.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Sat, 31 Jan 2015 00:27:17 -0800 (PST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJ10005Z8TES320@mailout1.samsung.com> for
 linux-mm@kvack.org; Sat, 31 Jan 2015 17:27:15 +0900 (KST)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH] zram: fix race between reset and mount/mkswap
Date: Sat, 31 Jan 2015 16:25:20 +0800
Message-id: <1422692720-19756-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ganesh Mahendran <opensource.ganesh@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Currently there is a racy between reset and mount/mkswap, so that it could
make oops when umount a corropted filesystem.

This issue can be reproduced by adding delay between bdput() and zram_reset_device
    reset_store(...) {
        bdput(bdev);

        msleep(2000); // test code

        zram_reset_device(zram, true);
    }

Steps:

$ echo 1 > /sys/block/zram0/reset &
$ mount /dev/zram0 /mnt/
$ umount /mnt
BUG: failure at fs/buffer.c:3006/_submit_bh()!
Kernel panic - not syncing: BUG!
CPU: 0 PID: 726 Comm: umount Not tainted 3.19.0-rc6+ #32
Hardware name: linux,dummy-virt (DT)
Call trace:
[<ffffffc00008a020>] dump_backtrace+0x0/0x124
[<ffffffc00008a154>] show_stack+0x10/0x1c
[<ffffffc000559514>] dump_stack+0x80/0xc4
[<ffffffc0005587d8>] panic+0xe0/0x220
[<ffffffc0001c7fd8>] _submit_bh+0x18c/0x1e0
[<ffffffc0001c9c8c>] __sync_dirty_buffer+0x6c/0xfc
[<ffffffc0001c9d28>] sync_dirty_buffer+0xc/0x18
[<ffffffc0002205bc>] ext2_sync_super+0xa8/0xbc
[<ffffffc000220628>] ext2_sync_fs+0x58/0x70
[<ffffffc0001c3ab0>] sync_filesystem+0x80/0xb0
[<ffffffc00019a294>] generic_shutdown_super+0x2c/0xd8
[<ffffffc00019a64c>] kill_block_super+0x1c/0x70
[<ffffffc00019a95c>] deactivate_locked_super+0x54/0x84
[<ffffffc00019ae5c>] deactivate_super+0x8c/0x9c
[<ffffffc0001b5fd0>] cleanup_mnt+0x38/0x84
[<ffffffc0001b6074>] __cleanup_mnt+0xc/0x18
[<ffffffc0000cc5bc>] task_work_run+0x94/0xec
[<ffffffc000089d54>] do_notify_resume+0x54/0x68
---[ end Kernel panic - not syncing: BUG!

The problem is caused by:

      CPU0                    CPU1
 t1:  bdput
 t2:                          mount /dev/zram0 /mnt
 t3:  zram_reset_device

At time 3: the mounted filesystem will be corrputed by CPU0, oops will happen
when admin umounts /mnt or reset linux system.

This patch uses bdev->bd_mutex to prevent concurrent visit of /dev/zram0.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 drivers/block/zram/zram_drv.c |   79 ++++++++++++++++++++++-------------------
 1 file changed, 42 insertions(+), 37 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index aa5a4c5..2b6b0dc 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -717,17 +717,35 @@ static void zram_bio_discard(struct zram *zram, u32 index,
 	}
 }
 
-static void zram_reset_device(struct zram *zram, bool reset_capacity)
+static int zram_reset_device(struct zram *zram, bool reset_capacity)
 {
-	down_write(&zram->init_lock);
+	int ret;
+	struct block_device *bdev;
 
-	zram->limit_pages = 0;
+	bdev = bdget_disk(zram->disk, 0);
+	if (!bdev)
+		return -ENOMEM;
+
+	mutex_lock(&bdev->bd_mutex);
+
+	/* Do not reset an active device! */
+	if (bdev->bd_holders) {
+		ret = -EBUSY;
+		goto err;
+	}
+
+	/* Make sure all pending I/O is finished */
+	fsync_bdev(bdev);
+
+	down_write(&zram->init_lock);
 
 	if (!init_done(zram)) {
-		up_write(&zram->init_lock);
-		return;
+		ret = -EIO;
+		goto err_init_done;
 	}
 
+	zram->limit_pages = 0;
+
 	zcomp_destroy(zram->comp);
 	zram->max_comp_streams = 1;
 	zram_meta_free(zram->meta, zram->disksize);
@@ -740,6 +758,8 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
 		set_capacity(zram->disk, 0);
 
 	up_write(&zram->init_lock);
+	mutex_unlock(&bdev->bd_mutex);
+	bdput(bdev);
 
 	/*
 	 * Revalidate disk out of the init_lock to avoid lockdep splat.
@@ -748,6 +768,16 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
 	 */
 	if (reset_capacity)
 		revalidate_disk(zram->disk);
+
+	return 0;
+
+err_init_done:
+	up_write(&zram->init_lock);
+err:
+	mutex_unlock(&bdev->bd_mutex);
+	bdput(bdev);
+
+	return ret;
 }
 
 static ssize_t disksize_store(struct device *dev,
@@ -811,40 +841,19 @@ static ssize_t reset_store(struct device *dev,
 {
 	int ret;
 	unsigned short do_reset;
-	struct zram *zram;
-	struct block_device *bdev;
-
-	zram = dev_to_zram(dev);
-	bdev = bdget_disk(zram->disk, 0);
-
-	if (!bdev)
-		return -ENOMEM;
-
-	/* Do not reset an active device! */
-	if (bdev->bd_holders) {
-		ret = -EBUSY;
-		goto out;
-	}
 
 	ret = kstrtou16(buf, 10, &do_reset);
 	if (ret)
-		goto out;
+		return ret;
 
-	if (!do_reset) {
-		ret = -EINVAL;
-		goto out;
-	}
+	if (!do_reset)
+		return -EINVAL;
 
-	/* Make sure all pending I/O is finished */
-	fsync_bdev(bdev);
-	bdput(bdev);
+	ret = zram_reset_device(dev_to_zram(dev), true);
+	if (ret)
+		return ret;
 
-	zram_reset_device(zram, true);
 	return len;
-
-out:
-	bdput(bdev);
-	return ret;
 }
 
 static void __zram_make_request(struct zram *zram, struct bio *bio)
@@ -1183,12 +1192,8 @@ static void __exit zram_exit(void)
 	for (i = 0; i < num_devices; i++) {
 		zram = &zram_devices[i];
 
-		destroy_device(zram);
-		/*
-		 * Shouldn't access zram->disk after destroy_device
-		 * because destroy_device already released zram->disk.
-		 */
 		zram_reset_device(zram, false);
+		destroy_device(zram);
 	}
 
 	unregister_blkdev(zram_major, "zram");
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
