Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9D0516B026C
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:23:35 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id f62so8828808otf.6
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:23:35 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z7si4336075otb.166.2017.12.18.04.23.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:23:34 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 02/45] block: conver to bio_first_bvec_all & bio_first_page_all
Date: Mon, 18 Dec 2017 20:22:04 +0800
Message-Id: <20171218122247.3488-3-ming.lei@redhat.com>
In-Reply-To: <20171218122247.3488-1-ming.lei@redhat.com>
References: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

This patch converts to bio_first_bvec_all() & bio_first_page_all() for
retrieving the 1st bvec/page, and prepares for supporting multipage bvec.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 drivers/block/drbd/drbd_bitmap.c | 2 +-
 drivers/block/zram/zram_drv.c    | 2 +-
 drivers/md/bcache/super.c        | 8 ++++----
 fs/btrfs/compression.c           | 2 +-
 fs/btrfs/inode.c                 | 4 ++--
 fs/f2fs/data.c                   | 2 +-
 kernel/power/swap.c              | 2 +-
 mm/page_io.c                     | 4 ++--
 8 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/block/drbd/drbd_bitmap.c b/drivers/block/drbd/drbd_bitmap.c
index bd97908c766f..9f4e6f502b84 100644
--- a/drivers/block/drbd/drbd_bitmap.c
+++ b/drivers/block/drbd/drbd_bitmap.c
@@ -953,7 +953,7 @@ static void drbd_bm_endio(struct bio *bio)
 	struct drbd_bm_aio_ctx *ctx = bio->bi_private;
 	struct drbd_device *device = ctx->device;
 	struct drbd_bitmap *b = device->bitmap;
-	unsigned int idx = bm_page_to_idx(bio->bi_io_vec[0].bv_page);
+	unsigned int idx = bm_page_to_idx(bio_first_page_all(bio));
 
 	if ((ctx->flags & BM_AIO_COPY_PAGES) == 0 &&
 	    !bm_test_page_unchanged(b->bm_pages[idx]))
diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index d70eba30003a..0afa6c8c3857 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -430,7 +430,7 @@ static void put_entry_bdev(struct zram *zram, unsigned long entry)
 
 static void zram_page_end_io(struct bio *bio)
 {
-	struct page *page = bio->bi_io_vec[0].bv_page;
+	struct page *page = bio_first_page_all(bio);
 
 	page_endio(page, op_is_write(bio_op(bio)),
 			blk_status_to_errno(bio->bi_status));
diff --git a/drivers/md/bcache/super.c b/drivers/md/bcache/super.c
index b4d28928dec5..8399fe0651f2 100644
--- a/drivers/md/bcache/super.c
+++ b/drivers/md/bcache/super.c
@@ -211,7 +211,7 @@ static void write_bdev_super_endio(struct bio *bio)
 
 static void __write_super(struct cache_sb *sb, struct bio *bio)
 {
-	struct cache_sb *out = page_address(bio->bi_io_vec[0].bv_page);
+	struct cache_sb *out = page_address(bio_first_page_all(bio));
 	unsigned i;
 
 	bio->bi_iter.bi_sector	= SB_SECTOR;
@@ -1166,7 +1166,7 @@ static void register_bdev(struct cache_sb *sb, struct page *sb_page,
 	dc->bdev->bd_holder = dc;
 
 	bio_init(&dc->sb_bio, dc->sb_bio.bi_inline_vecs, 1);
-	dc->sb_bio.bi_io_vec[0].bv_page = sb_page;
+	bio_first_bvec_all(&dc->sb_bio)->bv_page = sb_page;
 	get_page(sb_page);
 
 	if (cached_dev_init(dc, sb->block_size << 9))
@@ -1810,7 +1810,7 @@ void bch_cache_release(struct kobject *kobj)
 		free_fifo(&ca->free[i]);
 
 	if (ca->sb_bio.bi_inline_vecs[0].bv_page)
-		put_page(ca->sb_bio.bi_io_vec[0].bv_page);
+		put_page(bio_first_page_all(&ca->sb_bio));
 
 	if (!IS_ERR_OR_NULL(ca->bdev))
 		blkdev_put(ca->bdev, FMODE_READ|FMODE_WRITE|FMODE_EXCL);
@@ -1864,7 +1864,7 @@ static int register_cache(struct cache_sb *sb, struct page *sb_page,
 	ca->bdev->bd_holder = ca;
 
 	bio_init(&ca->sb_bio, ca->sb_bio.bi_inline_vecs, 1);
-	ca->sb_bio.bi_io_vec[0].bv_page = sb_page;
+	bio_first_bvec_all(&ca->sb_bio)->bv_page = sb_page;
 	get_page(sb_page);
 
 	if (blk_queue_discard(bdev_get_queue(ca->bdev)))
diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
index 5982c8a71f02..38a6b091bc25 100644
--- a/fs/btrfs/compression.c
+++ b/fs/btrfs/compression.c
@@ -563,7 +563,7 @@ blk_status_t btrfs_submit_compressed_read(struct inode *inode, struct bio *bio,
 	/* we need the actual starting offset of this extent in the file */
 	read_lock(&em_tree->lock);
 	em = lookup_extent_mapping(em_tree,
-				   page_offset(bio->bi_io_vec->bv_page),
+				   page_offset(bio_first_page_all(bio)),
 				   PAGE_SIZE);
 	read_unlock(&em_tree->lock);
 	if (!em)
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index e1a7f3cb5be9..4d5cb6e93c80 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -8074,7 +8074,7 @@ static void btrfs_retry_endio_nocsum(struct bio *bio)
 	ASSERT(bio->bi_vcnt == 1);
 	io_tree = &BTRFS_I(inode)->io_tree;
 	failure_tree = &BTRFS_I(inode)->io_failure_tree;
-	ASSERT(bio->bi_io_vec->bv_len == btrfs_inode_sectorsize(inode));
+	ASSERT(bio_first_bvec_all(bio)->bv_len == btrfs_inode_sectorsize(inode));
 
 	done->uptodate = 1;
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
@@ -8164,7 +8164,7 @@ static void btrfs_retry_endio(struct bio *bio)
 	uptodate = 1;
 
 	ASSERT(bio->bi_vcnt == 1);
-	ASSERT(bio->bi_io_vec->bv_len == btrfs_inode_sectorsize(done->inode));
+	ASSERT(bio_first_bvec_all(bio)->bv_len == btrfs_inode_sectorsize(done->inode));
 
 	io_tree = &BTRFS_I(inode)->io_tree;
 	failure_tree = &BTRFS_I(inode)->io_failure_tree;
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 516fa0d3ff9c..455f086cce3d 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -56,7 +56,7 @@ static void f2fs_read_end_io(struct bio *bio)
 	int i;
 
 #ifdef CONFIG_F2FS_FAULT_INJECTION
-	if (time_to_inject(F2FS_P_SB(bio->bi_io_vec->bv_page), FAULT_IO)) {
+	if (time_to_inject(F2FS_P_SB(bio_first_page_all(bio)), FAULT_IO)) {
 		f2fs_show_injection_info(FAULT_IO);
 		bio->bi_status = BLK_STS_IOERR;
 	}
diff --git a/kernel/power/swap.c b/kernel/power/swap.c
index 293ead59eccc..96c736313faa 100644
--- a/kernel/power/swap.c
+++ b/kernel/power/swap.c
@@ -240,7 +240,7 @@ static void hib_init_batch(struct hib_bio_batch *hb)
 static void hib_end_io(struct bio *bio)
 {
 	struct hib_bio_batch *hb = bio->bi_private;
-	struct page *page = bio->bi_io_vec[0].bv_page;
+	struct page *page = bio_first_page_all(bio);
 
 	if (bio->bi_status) {
 		pr_alert("Read-error on swap-device (%u:%u:%Lu)\n",
diff --git a/mm/page_io.c b/mm/page_io.c
index e93f1a4cacd7..b41cf9644585 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -50,7 +50,7 @@ static struct bio *get_swap_bio(gfp_t gfp_flags,
 
 void end_swap_bio_write(struct bio *bio)
 {
-	struct page *page = bio->bi_io_vec[0].bv_page;
+	struct page *page = bio_first_page_all(bio);
 
 	if (bio->bi_status) {
 		SetPageError(page);
@@ -122,7 +122,7 @@ static void swap_slot_free_notify(struct page *page)
 
 static void end_swap_bio_read(struct bio *bio)
 {
-	struct page *page = bio->bi_io_vec[0].bv_page;
+	struct page *page = bio_first_page_all(bio);
 	struct task_struct *waiter = bio->bi_private;
 
 	if (bio->bi_status) {
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
