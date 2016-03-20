Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id ED72D828DF
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:42:00 -0400 (EDT)
Received: by mail-pf0-f172.google.com with SMTP id 4so106542146pfd.0
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:42:00 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id 24si2318154pfq.155.2016.03.20.11.41.43
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:43 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 06/71] block: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:13 +0300
Message-Id: <1458499278-1516-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Philipp Reisner <philipp.reisner@linbit.com>, Lars Ellenberg <lars.ellenberg@linbit.com>, "Ed L. Cashin" <ed.cashin@acm.org>

PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
with promise that one day it will be possible to implement page cache with
bigger chunks than PAGE_SIZE.

This promise never materialized. And unlikely will.

We have many places where PAGE_CACHE_SIZE assumed to be equal to
PAGE_SIZE. And it's constant source of confusion on whether PAGE_CACHE_*
or PAGE_* constant should be used in a particular case, especially on the
border between fs and mm.

Global switching to PAGE_CACHE_SIZE != PAGE_SIZE would cause to much
breakage to be doable.

Let's stop pretending that pages in page cache are special. They are not.

The changes are pretty straight-forward:

 - <foo> << (PAGE_CACHE_SHIFT - PAGE_SHIFT) -> <foo>;

 - PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} -> PAGE_{SIZE,SHIFT,MASK,ALIGN};

 - page_cache_get() -> get_page();

 - page_cache_release() -> put_page();

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Philipp Reisner <philipp.reisner@linbit.com>
Cc: Lars Ellenberg <lars.ellenberg@linbit.com>
Cc: "Ed L. Cashin" <ed.cashin@acm.org>
---
 block/bio.c                      | 12 ++++++------
 block/blk-core.c                 |  2 +-
 block/blk-settings.c             | 12 ++++++------
 block/blk-sysfs.c                |  8 ++++----
 block/cfq-iosched.c              |  2 +-
 block/compat_ioctl.c             |  4 ++--
 block/ioctl.c                    |  4 ++--
 block/partition-generic.c        |  8 ++++----
 drivers/block/aoe/aoeblk.c       |  2 +-
 drivers/block/brd.c              |  2 +-
 drivers/block/drbd/drbd_int.h    |  4 ++--
 drivers/block/drbd/drbd_nl.c     |  2 +-
 include/linux/backing-dev-defs.h |  2 +-
 include/linux/bio.h              |  2 +-
 include/linux/blkdev.h           |  2 +-
 15 files changed, 34 insertions(+), 34 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index f124a0a624fc..807d25e466ec 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -1339,7 +1339,7 @@ struct bio *bio_map_user_iov(struct request_queue *q,
 		 * release the pages we didn't map into the bio, if any
 		 */
 		while (j < page_limit)
-			page_cache_release(pages[j++]);
+			put_page(pages[j++]);
 	}
 
 	kfree(pages);
@@ -1365,7 +1365,7 @@ struct bio *bio_map_user_iov(struct request_queue *q,
 	for (j = 0; j < nr_pages; j++) {
 		if (!pages[j])
 			break;
-		page_cache_release(pages[j]);
+		put_page(pages[j]);
 	}
  out:
 	kfree(pages);
@@ -1385,7 +1385,7 @@ static void __bio_unmap_user(struct bio *bio)
 		if (bio_data_dir(bio) == READ)
 			set_page_dirty_lock(bvec->bv_page);
 
-		page_cache_release(bvec->bv_page);
+		put_page(bvec->bv_page);
 	}
 
 	bio_put(bio);
@@ -1615,8 +1615,8 @@ static void bio_release_pages(struct bio *bio)
  * the BIO and the offending pages and re-dirty the pages in process context.
  *
  * It is expected that bio_check_pages_dirty() will wholly own the BIO from
- * here on.  It will run one page_cache_release() against each page and will
- * run one bio_put() against the BIO.
+ * here on.  It will run one put_page() against each page and will run one
+ * bio_put() against the BIO.
  */
 
 static void bio_dirty_fn(struct work_struct *work);
@@ -1658,7 +1658,7 @@ void bio_check_pages_dirty(struct bio *bio)
 		struct page *page = bvec->bv_page;
 
 		if (PageDirty(page) || PageCompound(page)) {
-			page_cache_release(page);
+			put_page(page);
 			bvec->bv_page = NULL;
 		} else {
 			nr_clean_pages++;
diff --git a/block/blk-core.c b/block/blk-core.c
index 827f8badd143..b60537b2c35b 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -706,7 +706,7 @@ struct request_queue *blk_alloc_queue_node(gfp_t gfp_mask, int node_id)
 		goto fail_id;
 
 	q->backing_dev_info.ra_pages =
-			(VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
+			(VM_MAX_READAHEAD * 1024) / PAGE_SIZE;
 	q->backing_dev_info.capabilities = BDI_CAP_CGROUP_WRITEBACK;
 	q->backing_dev_info.name = "block";
 	q->node = node_id;
diff --git a/block/blk-settings.c b/block/blk-settings.c
index c7bb666aafd1..331e4eee0dda 100644
--- a/block/blk-settings.c
+++ b/block/blk-settings.c
@@ -239,8 +239,8 @@ void blk_queue_max_hw_sectors(struct request_queue *q, unsigned int max_hw_secto
 	struct queue_limits *limits = &q->limits;
 	unsigned int max_sectors;
 
-	if ((max_hw_sectors << 9) < PAGE_CACHE_SIZE) {
-		max_hw_sectors = 1 << (PAGE_CACHE_SHIFT - 9);
+	if ((max_hw_sectors << 9) < PAGE_SIZE) {
+		max_hw_sectors = 1 << (PAGE_SHIFT - 9);
 		printk(KERN_INFO "%s: set to minimum %d\n",
 		       __func__, max_hw_sectors);
 	}
@@ -329,8 +329,8 @@ EXPORT_SYMBOL(blk_queue_max_segments);
  **/
 void blk_queue_max_segment_size(struct request_queue *q, unsigned int max_size)
 {
-	if (max_size < PAGE_CACHE_SIZE) {
-		max_size = PAGE_CACHE_SIZE;
+	if (max_size < PAGE_SIZE) {
+		max_size = PAGE_SIZE;
 		printk(KERN_INFO "%s: set to minimum %d\n",
 		       __func__, max_size);
 	}
@@ -760,8 +760,8 @@ EXPORT_SYMBOL_GPL(blk_queue_dma_drain);
  **/
 void blk_queue_segment_boundary(struct request_queue *q, unsigned long mask)
 {
-	if (mask < PAGE_CACHE_SIZE - 1) {
-		mask = PAGE_CACHE_SIZE - 1;
+	if (mask < PAGE_SIZE - 1) {
+		mask = PAGE_SIZE - 1;
 		printk(KERN_INFO "%s: set to minimum %lx\n",
 		       __func__, mask);
 	}
diff --git a/block/blk-sysfs.c b/block/blk-sysfs.c
index dd93763057ce..995b58d46ed1 100644
--- a/block/blk-sysfs.c
+++ b/block/blk-sysfs.c
@@ -76,7 +76,7 @@ queue_requests_store(struct request_queue *q, const char *page, size_t count)
 static ssize_t queue_ra_show(struct request_queue *q, char *page)
 {
 	unsigned long ra_kb = q->backing_dev_info.ra_pages <<
-					(PAGE_CACHE_SHIFT - 10);
+					(PAGE_SHIFT - 10);
 
 	return queue_var_show(ra_kb, (page));
 }
@@ -90,7 +90,7 @@ queue_ra_store(struct request_queue *q, const char *page, size_t count)
 	if (ret < 0)
 		return ret;
 
-	q->backing_dev_info.ra_pages = ra_kb >> (PAGE_CACHE_SHIFT - 10);
+	q->backing_dev_info.ra_pages = ra_kb >> (PAGE_SHIFT - 10);
 
 	return ret;
 }
@@ -117,7 +117,7 @@ static ssize_t queue_max_segment_size_show(struct request_queue *q, char *page)
 	if (blk_queue_cluster(q))
 		return queue_var_show(queue_max_segment_size(q), (page));
 
-	return queue_var_show(PAGE_CACHE_SIZE, (page));
+	return queue_var_show(PAGE_SIZE, (page));
 }
 
 static ssize_t queue_logical_block_size_show(struct request_queue *q, char *page)
@@ -198,7 +198,7 @@ queue_max_sectors_store(struct request_queue *q, const char *page, size_t count)
 {
 	unsigned long max_sectors_kb,
 		max_hw_sectors_kb = queue_max_hw_sectors(q) >> 1,
-			page_kb = 1 << (PAGE_CACHE_SHIFT - 10);
+			page_kb = 1 << (PAGE_SHIFT - 10);
 	ssize_t ret = queue_var_store(&max_sectors_kb, page, count);
 
 	if (ret < 0)
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index e3c591dd8f19..4a349787bc62 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -4075,7 +4075,7 @@ cfq_rq_enqueued(struct cfq_data *cfqd, struct cfq_queue *cfqq,
 		 * idle timer unplug to continue working.
 		 */
 		if (cfq_cfqq_wait_request(cfqq)) {
-			if (blk_rq_bytes(rq) > PAGE_CACHE_SIZE ||
+			if (blk_rq_bytes(rq) > PAGE_SIZE ||
 			    cfqd->busy_queues > 1) {
 				cfq_del_timer(cfqd, cfqq);
 				cfq_clear_cfqq_wait_request(cfqq);
diff --git a/block/compat_ioctl.c b/block/compat_ioctl.c
index f678c733df40..556826ac7cb4 100644
--- a/block/compat_ioctl.c
+++ b/block/compat_ioctl.c
@@ -710,7 +710,7 @@ long compat_blkdev_ioctl(struct file *file, unsigned cmd, unsigned long arg)
 			return -EINVAL;
 		bdi = blk_get_backing_dev_info(bdev);
 		return compat_put_long(arg,
-				       (bdi->ra_pages * PAGE_CACHE_SIZE) / 512);
+				       (bdi->ra_pages * PAGE_SIZE) / 512);
 	case BLKROGET: /* compatible */
 		return compat_put_int(arg, bdev_read_only(bdev) != 0);
 	case BLKBSZGET_32: /* get the logical block size (cf. BLKSSZGET) */
@@ -729,7 +729,7 @@ long compat_blkdev_ioctl(struct file *file, unsigned cmd, unsigned long arg)
 		if (!capable(CAP_SYS_ADMIN))
 			return -EACCES;
 		bdi = blk_get_backing_dev_info(bdev);
-		bdi->ra_pages = (arg * 512) / PAGE_CACHE_SIZE;
+		bdi->ra_pages = (arg * 512) / PAGE_SIZE;
 		return 0;
 	case BLKGETSIZE:
 		size = i_size_read(bdev->bd_inode);
diff --git a/block/ioctl.c b/block/ioctl.c
index d8996bbd7f12..4ff1f92f89ca 100644
--- a/block/ioctl.c
+++ b/block/ioctl.c
@@ -550,7 +550,7 @@ int blkdev_ioctl(struct block_device *bdev, fmode_t mode, unsigned cmd,
 		if (!arg)
 			return -EINVAL;
 		bdi = blk_get_backing_dev_info(bdev);
-		return put_long(arg, (bdi->ra_pages * PAGE_CACHE_SIZE) / 512);
+		return put_long(arg, (bdi->ra_pages * PAGE_SIZE) / 512);
 	case BLKROGET:
 		return put_int(arg, bdev_read_only(bdev) != 0);
 	case BLKBSZGET: /* get block device soft block size (cf. BLKSSZGET) */
@@ -578,7 +578,7 @@ int blkdev_ioctl(struct block_device *bdev, fmode_t mode, unsigned cmd,
 		if(!capable(CAP_SYS_ADMIN))
 			return -EACCES;
 		bdi = blk_get_backing_dev_info(bdev);
-		bdi->ra_pages = (arg * 512) / PAGE_CACHE_SIZE;
+		bdi->ra_pages = (arg * 512) / PAGE_SIZE;
 		return 0;
 	case BLKBSZSET:
 		return blkdev_bszset(bdev, mode, argp);
diff --git a/block/partition-generic.c b/block/partition-generic.c
index 5d8701941054..2c6ae2aed2c4 100644
--- a/block/partition-generic.c
+++ b/block/partition-generic.c
@@ -566,8 +566,8 @@ static struct page *read_pagecache_sector(struct block_device *bdev, sector_t n)
 {
 	struct address_space *mapping = bdev->bd_inode->i_mapping;
 
-	return read_mapping_page(mapping, (pgoff_t)(n >> (PAGE_CACHE_SHIFT-9)),
-			NULL);
+	return read_mapping_page(mapping, (pgoff_t)(n >> (PAGE_SHIFT-9)),
+				 NULL);
 }
 
 unsigned char *read_dev_sector(struct block_device *bdev, sector_t n, Sector *p)
@@ -584,9 +584,9 @@ unsigned char *read_dev_sector(struct block_device *bdev, sector_t n, Sector *p)
 		if (PageError(page))
 			goto fail;
 		p->v = page;
-		return (unsigned char *)page_address(page) +  ((n & ((1 << (PAGE_CACHE_SHIFT - 9)) - 1)) << 9);
+		return (unsigned char *)page_address(page) +  ((n & ((1 << (PAGE_SHIFT - 9)) - 1)) << 9);
 fail:
-		page_cache_release(page);
+		put_page(page);
 	}
 	p->v = NULL;
 	return NULL;
diff --git a/drivers/block/aoe/aoeblk.c b/drivers/block/aoe/aoeblk.c
index dd73e1ff1759..ec9d8610b25f 100644
--- a/drivers/block/aoe/aoeblk.c
+++ b/drivers/block/aoe/aoeblk.c
@@ -397,7 +397,7 @@ aoeblk_gdalloc(void *vp)
 	WARN_ON(d->flags & DEVFL_UP);
 	blk_queue_max_hw_sectors(q, BLK_DEF_MAX_SECTORS);
 	q->backing_dev_info.name = "aoe";
-	q->backing_dev_info.ra_pages = READ_AHEAD / PAGE_CACHE_SIZE;
+	q->backing_dev_info.ra_pages = READ_AHEAD / PAGE_SIZE;
 	d->bufpool = mp;
 	d->blkq = gd->queue = q;
 	q->queuedata = d;
diff --git a/drivers/block/brd.c b/drivers/block/brd.c
index f7ecc287d733..51a071e32221 100644
--- a/drivers/block/brd.c
+++ b/drivers/block/brd.c
@@ -374,7 +374,7 @@ static int brd_rw_page(struct block_device *bdev, sector_t sector,
 		       struct page *page, int rw)
 {
 	struct brd_device *brd = bdev->bd_disk->private_data;
-	int err = brd_do_bvec(brd, page, PAGE_CACHE_SIZE, 0, rw, sector);
+	int err = brd_do_bvec(brd, page, PAGE_SIZE, 0, rw, sector);
 	page_endio(page, rw & WRITE, err);
 	return err;
 }
diff --git a/drivers/block/drbd/drbd_int.h b/drivers/block/drbd/drbd_int.h
index c227fd4cad75..7a1cf7eaa71d 100644
--- a/drivers/block/drbd/drbd_int.h
+++ b/drivers/block/drbd/drbd_int.h
@@ -1327,8 +1327,8 @@ struct bm_extent {
 #endif
 #endif
 
-/* BIO_MAX_SIZE is 256 * PAGE_CACHE_SIZE,
- * so for typical PAGE_CACHE_SIZE of 4k, that is (1<<20) Byte.
+/* BIO_MAX_SIZE is 256 * PAGE_SIZE,
+ * so for typical PAGE_SIZE of 4k, that is (1<<20) Byte.
  * Since we may live in a mixed-platform cluster,
  * we limit us to a platform agnostic constant here for now.
  * A followup commit may allow even bigger BIO sizes,
diff --git a/drivers/block/drbd/drbd_nl.c b/drivers/block/drbd/drbd_nl.c
index 226eb0c9f0fb..1fd1dccebb6b 100644
--- a/drivers/block/drbd/drbd_nl.c
+++ b/drivers/block/drbd/drbd_nl.c
@@ -1178,7 +1178,7 @@ static void drbd_setup_queue_param(struct drbd_device *device, struct drbd_backi
 	blk_queue_max_hw_sectors(q, max_hw_sectors);
 	/* This is the workaround for "bio would need to, but cannot, be split" */
 	blk_queue_max_segments(q, max_segments ? max_segments : BLK_MAX_SEGMENTS);
-	blk_queue_segment_boundary(q, PAGE_CACHE_SIZE-1);
+	blk_queue_segment_boundary(q, PAGE_SIZE-1);
 
 	if (b) {
 		struct drbd_connection *connection = first_peer_device(device)->connection;
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 1b4d69f68c33..3f103076d0bf 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -135,7 +135,7 @@ struct bdi_writeback {
 
 struct backing_dev_info {
 	struct list_head bdi_list;
-	unsigned long ra_pages;	/* max readahead in PAGE_CACHE_SIZE units */
+	unsigned long ra_pages;	/* max readahead in PAGE_SIZE units */
 	unsigned int capabilities; /* Device capabilities */
 	congested_fn *congested_fn; /* Function pointer if device is md/dm */
 	void *congested_data;	/* Pointer to aux data for congested func */
diff --git a/include/linux/bio.h b/include/linux/bio.h
index 88bc64f00bb5..6b7481f62218 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -41,7 +41,7 @@
 #endif
 
 #define BIO_MAX_PAGES		256
-#define BIO_MAX_SIZE		(BIO_MAX_PAGES << PAGE_CACHE_SHIFT)
+#define BIO_MAX_SIZE		(BIO_MAX_PAGES << PAGE_SHIFT)
 #define BIO_MAX_SECTORS		(BIO_MAX_SIZE >> 9)
 
 /*
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 7e5d7e018bea..669e419d6234 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -1372,7 +1372,7 @@ unsigned char *read_dev_sector(struct block_device *, sector_t, Sector *);
 
 static inline void put_dev_sector(Sector p)
 {
-	page_cache_release(p.v);
+	put_page(p.v);
 }
 
 static inline bool __bvec_gap_to_prev(struct request_queue *q,
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
