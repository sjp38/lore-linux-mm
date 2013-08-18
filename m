Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 6C98D6B0037
	for <linux-mm@kvack.org>; Sun, 18 Aug 2013 04:42:17 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id bg4so3513959pad.4
        for <linux-mm@kvack.org>; Sun, 18 Aug 2013 01:42:16 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH 4/4] mm: zswap: create a pseudo device /dev/zram0
Date: Sun, 18 Aug 2013 16:40:49 +0800
Message-Id: <1376815249-6611-5-git-send-email-bob.liu@oracle.com>
In-Reply-To: <1376815249-6611-1-git-send-email-bob.liu@oracle.com>
References: <1376815249-6611-1-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, eternaleye@gmail.com, minchan@kernel.org, mgorman@suse.de, gregkh@linuxfoundation.org, akpm@linux-foundation.org, axboe@kernel.dk, sjenning@linux.vnet.ibm.com, ngupta@vflare.org, semenzato@google.com, penberg@iki.fi, sonnyrao@google.com, smbarber@google.com, konrad.wilk@oracle.com, riel@redhat.com, kmpark@infradead.org, Bob Liu <bob.liu@oracle.com>

This is used to replace previous zram.
zram users can enable this feature, then a pseudo device will be created
automaticlly after kernel boot.
Just using "mkswp /dev/zram0; swapon /dev/zram0" to use it as a swap disk.

The size of this pseudeo is controlled by zswap boot parameter
zswap.max_pool_percent.
disksize = (totalram_pages * zswap.max_pool_percent/100)*PAGE_SIZE.

Signed-off-by: Bob Liu <bob.liu@oracle.com>
---
 mm/Kconfig |   12 ++++
 mm/zswap.c |  196 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 208 insertions(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index d80a575..3778026 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -525,6 +525,18 @@ choice
 	  be refused unless frontswap_get happened and freed some space.
 endchoice
 
+config ZSWAP_PSEUDO_BLKDEV
+	bool "Emulate a pseudo blk-dev based on zswap(previous zram)"
+	depends on ZSWAP && ZSMALLOC
+	default n
+
+	help
+	  Enable this option will emulate a pseudo block swapdev /dev/zram0
+	  with size zswap.max_pool_percent of total ram size. All writes to this
+	  block device will be compressed and cached by zswap as a result no
+	  real IO disk operations will happen.
+	  This feature can be used to replace drivers/staging/zram.
+
 config MEM_SOFT_DIRTY
 	bool "Track memory changes"
 	depends on CHECKPOINT_RESTORE && HAVE_ARCH_SOFT_DIRTY
diff --git a/mm/zswap.c b/mm/zswap.c
index 8e8dc99..ae73c9d 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -38,6 +38,11 @@
 #include <linux/zbud.h>
 #else
 #include <linux/zsmalloc.h>
+#ifdef CONFIG_ZSWAP_PSEUDO_BLKDEV
+#include <linux/bio.h>
+#include <linux/blkdev.h>
+#include <linux/genhd.h>
+#endif
 #endif
 #include <linux/mm_types.h>
 #include <linux/page-flags.h>
@@ -968,6 +973,189 @@ static int __init zswap_debugfs_init(void)
 static void __exit zswap_debugfs_exit(void) { }
 #endif
 
+#ifdef CONFIG_ZSWAP_PSEUDO_BLKDEV
+#define SECTOR_SHIFT		9
+#define SECTOR_SIZE		(1 << SECTOR_SHIFT)
+#define SECTORS_PER_PAGE_SHIFT	(PAGE_SHIFT - SECTOR_SHIFT)
+#define SECTORS_PER_PAGE	(1 << SECTORS_PER_PAGE_SHIFT)
+
+struct zram {
+	struct rw_semaphore lock; /* protect concurent reads and writes */
+	struct request_queue *queue;
+	struct gendisk *disk;
+
+	/*
+	 * This is the disk size for userland. The size is controlled by
+	 * boot parameter zswap.max_pool_percent.
+	 * disksize = (totalram_pages * zswap.max_pool_percent/100)*PAGE_SIZE
+	 */
+	u64 disksize;	/* bytes */
+
+	/*
+	 * This page is used to store real data for /dev/zram.
+	 * Meanful operation to /dev/zramx is only mkswp and swapon/swapoff.
+	 * So use one page to store the real data(written by mkswp).
+	 */
+	struct page *metapage;
+};
+
+/*
+ * Only create /dev/zram0, can be extened in future if there is real uercases
+ * need multiple zram devices.
+ */
+static struct zram zram_device;
+static const struct block_device_operations zram_devops = {
+	.owner = THIS_MODULE
+};
+
+static void update_position(u32 *index, int *offset, struct bio_vec *bvec)
+{
+	if (*offset + bvec->bv_len >= PAGE_SIZE)
+		(*index)++;
+	*offset = (*offset + bvec->bv_len) % PAGE_SIZE;
+}
+
+static void zram_make_request(struct request_queue *queue, struct bio *bio)
+{
+	u32 index;
+	struct bio_vec *bvec;
+	unsigned char *src, *dst;
+	int offset, i, rw = bio_data_dir(bio);
+	struct zram *zram = queue->queuedata;
+
+	index = bio->bi_sector >> SECTORS_PER_PAGE_SHIFT;
+	offset = (bio->bi_sector & (SECTORS_PER_PAGE - 1)) << SECTOR_SHIFT;
+
+	bio_for_each_segment(bvec, bio, i) {
+		/*
+		 * The only operation to pseudo /dev/zramx is mkswp and
+		 * swapon/swapoff, so we only need one extra page to store the
+		 * real meta data!
+		 */
+		BUG_ON(bvec->bv_len != PAGE_SIZE);
+		BUG_ON(offset);
+
+		if (!index) {
+			if (rw == READ) {
+				down_read(&zram->lock);
+				dst = kmap_atomic(bvec->bv_page);
+				src = kmap_atomic(zram->metapage);
+				memcpy(dst, src, bvec->bv_len);
+				kunmap_atomic(dst);
+				kunmap_atomic(src);
+				flush_dcache_page(bvec->bv_page);
+				up_read(&zram->lock);
+			} else {
+				down_write(&zram->lock);
+				src = kmap_atomic(bvec->bv_page);
+				dst = kmap_atomic(zram->metapage);
+				memcpy(dst, src, bvec->bv_len);
+				kunmap_atomic(dst);
+				kunmap_atomic(src);
+				up_write(&zram->lock);
+			}
+		}
+		update_position(&index, &offset, bvec);
+	}
+	set_bit(BIO_UPTODATE, &bio->bi_flags);
+	bio_endio(bio, 0);
+	return;
+}
+
+static int create_zram_device(struct zram *zram, int major, int device_id)
+{
+	int ret = -ENOMEM;
+	u64 disksize;
+
+	zram->queue = blk_alloc_queue(GFP_KERNEL);
+	if (!zram->queue) {
+		pr_err("Error allocating disk queue for device%d\n", device_id);
+		goto out;
+	}
+
+	blk_queue_make_request(zram->queue, zram_make_request);
+	zram->queue->queuedata = zram;
+
+	/* gendisk structure */
+	zram->disk = alloc_disk(1);
+	if (!zram->disk) {
+		pr_warn("Error allocating disk structure for device %d\n",
+			device_id);
+		goto out_free_queue;
+	}
+
+	zram->disk->major = major;
+	zram->disk->first_minor = device_id;
+	zram->disk->fops = &zram_devops;
+	zram->disk->queue = zram->queue;
+	snprintf(zram->disk->disk_name, 16, "zram%d", device_id);
+
+	/*
+	 * To ensure that we always get PAGE_SIZE aligned
+	 * and n*PAGE_SIZED sized I/O requests.
+	 */
+	blk_queue_physical_block_size(zram->disk->queue, PAGE_SIZE);
+	blk_queue_logical_block_size(zram->disk->queue, 1<<12);
+	blk_queue_io_min(zram->disk->queue, PAGE_SIZE);
+	blk_queue_io_opt(zram->disk->queue, PAGE_SIZE);
+
+	add_disk(zram->disk);
+
+	/* Init blk-dev */
+	disksize = totalram_pages * zswap_max_pool_percent / 100;
+	disksize *= PAGE_SIZE;
+	disksize = PAGE_ALIGN(disksize);
+	zram->disksize = disksize;
+	set_capacity(zram->disk, zram->disksize >> SECTOR_SHIFT);
+
+	/* zram devices sort of resembles non-rotational disks */
+	queue_flag_set_unlocked(QUEUE_FLAG_NONROT, zram->disk->queue);
+
+	zram->metapage = alloc_page(GFP_KERNEL);
+	if (!zram->metapage)
+		goto out_free_disk;
+
+	pr_debug("Initialization done!\n");
+	return 0;
+
+out_free_disk:
+	pr_debug("Init zram meta pages fail!\n");
+	del_gendisk(zram->disk);
+	put_disk(zram->disk);
+out_free_queue:
+	blk_cleanup_queue(zram->queue);
+out:
+	return ret;
+}
+
+static int zswap_blkdev_init(void)
+{
+	int major, ret = 0;
+
+	major = register_blkdev(0, "zram");
+	if (major <= 0) {
+		pr_warn("Unable to get major number\n");
+		ret = -EBUSY;
+		goto out;
+	}
+
+	ret = create_zram_device(&zram_device, major, 0);
+	if (ret) {
+		unregister_blkdev(major, "zram");
+		goto out;
+	}
+
+	pr_info("Created zram device(%d, %d).\n", major, 0);
+out:
+	return ret;
+}
+#else
+static int zswap_blkdev_init(void)
+{
+	return 0;
+}
+#endif
+
 /*********************************
 * module init and exit
 **********************************/
@@ -989,9 +1177,17 @@ static int __init init_zswap(void)
 		pr_err("per-cpu initialization failed\n");
 		goto pcpufail;
 	}
+
+	if (IS_ENABLED(CONFIG_ZSWAP_PSEUDO_BLKDEV))
+		if (zswap_blkdev_init()) {
+			pr_err("emulate blk device failed\n");
+			goto pcpufail;
+		}
+
 	frontswap_register_ops(&zswap_frontswap_ops);
 	if (zswap_debugfs_init())
 		pr_warn("debugfs initialization failed\n");
+
 	return 0;
 pcpufail:
 	zswap_comp_exit();
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
