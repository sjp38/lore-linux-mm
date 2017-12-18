Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 194D36B02B5
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:32:58 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id z81so6972767oig.16
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:32:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s65si3668213oib.515.2017.12.18.04.32.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:32:56 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 41/45] block: rename bio_for_each_page_all2 as bio_for_each_page_all
Date: Mon, 18 Dec 2017 20:22:43 +0800
Message-Id: <20171218122247.3488-42-ming.lei@redhat.com>
In-Reply-To: <20171218122247.3488-1-ming.lei@redhat.com>
References: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

Now bio_for_each_page_all() is gone, we can reuse the name to iterate
bio page by page, which is done via bio_for_each_page_all2() now.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/bio.c               | 14 +++++++-------
 block/blk-zoned.c         |  4 ++--
 block/bounce.c            |  4 ++--
 drivers/md/bcache/btree.c |  2 +-
 drivers/md/dm-crypt.c     |  2 +-
 drivers/md/raid1.c        |  2 +-
 fs/block_dev.c            |  4 ++--
 fs/btrfs/compression.c    |  2 +-
 fs/btrfs/disk-io.c        |  2 +-
 fs/btrfs/extent_io.c      |  6 +++---
 fs/btrfs/inode.c          |  4 ++--
 fs/crypto/bio.c           |  2 +-
 fs/direct-io.c            |  2 +-
 fs/exofs/ore.c            |  2 +-
 fs/exofs/ore_raid.c       |  2 +-
 fs/ext4/page-io.c         |  2 +-
 fs/ext4/readpage.c        |  2 +-
 fs/f2fs/data.c            |  6 +++---
 fs/gfs2/lops.c            |  2 +-
 fs/gfs2/meta_io.c         |  2 +-
 fs/iomap.c                |  2 +-
 fs/mpage.c                |  2 +-
 fs/xfs/xfs_aops.c         |  2 +-
 include/linux/bio.h       |  4 ++--
 include/linux/bvec.h      |  2 +-
 25 files changed, 40 insertions(+), 40 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index 21d621e07ac9..e82e4c815dbb 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -1065,7 +1065,7 @@ static int bio_copy_from_iter(struct bio *bio, struct iov_iter *iter)
 	struct bio_vec *bvec;
 	struct bvec_iter_all bia;
 
-	bio_for_each_page_all2(bvec, bio, i, bia) {
+	bio_for_each_page_all(bvec, bio, i, bia) {
 		ssize_t ret;
 
 		ret = copy_page_from_iter(bvec->bv_page,
@@ -1097,7 +1097,7 @@ static int bio_copy_to_iter(struct bio *bio, struct iov_iter iter)
 	struct bio_vec *bvec;
 	struct bvec_iter_all bia;
 
-	bio_for_each_page_all2(bvec, bio, i, bia) {
+	bio_for_each_page_all(bvec, bio, i, bia) {
 		ssize_t ret;
 
 		ret = copy_page_to_iter(bvec->bv_page,
@@ -1121,7 +1121,7 @@ void bio_free_pages(struct bio *bio)
 	int i;
 	struct bvec_iter_all bia;
 
-	bio_for_each_page_all2(bvec, bio, i, bia)
+	bio_for_each_page_all(bvec, bio, i, bia)
 		__free_page(bvec->bv_page);
 }
 EXPORT_SYMBOL(bio_free_pages);
@@ -1361,7 +1361,7 @@ struct bio *bio_map_user_iov(struct request_queue *q,
 	return bio;
 
  out_unmap:
-	bio_for_each_page_all2(bvec, bio, j, bia) {
+	bio_for_each_page_all(bvec, bio, j, bia) {
 		put_page(bvec->bv_page);
 	}
 	bio_put(bio);
@@ -1377,7 +1377,7 @@ static void __bio_unmap_user(struct bio *bio)
 	/*
 	 * make sure we dirty pages we wrote to
 	 */
-	bio_for_each_page_all2(bvec, bio, i, bia) {
+	bio_for_each_page_all(bvec, bio, i, bia) {
 		if (bio_data_dir(bio) == READ)
 			set_page_dirty_lock(bvec->bv_page);
 
@@ -1471,7 +1471,7 @@ static void bio_copy_kern_endio_read(struct bio *bio)
 	int i;
 	struct bvec_iter_all bia;
 
-	bio_for_each_page_all2(bvec, bio, i, bia) {
+	bio_for_each_page_all(bvec, bio, i, bia) {
 		memcpy(p, page_address(bvec->bv_page), bvec->bv_len);
 		p += bvec->bv_len;
 	}
@@ -1582,7 +1582,7 @@ void bio_set_pages_dirty(struct bio *bio)
 	int i;
 	struct bvec_iter_all bia;
 
-	bio_for_each_page_all2(bvec, bio, i, bia) {
+	bio_for_each_page_all(bvec, bio, i, bia) {
 		struct page *page = bvec->bv_page;
 
 		if (page && !PageCompound(page))
diff --git a/block/blk-zoned.c b/block/blk-zoned.c
index 2899adfa23f4..360f99317fa2 100644
--- a/block/blk-zoned.c
+++ b/block/blk-zoned.c
@@ -149,7 +149,7 @@ int blkdev_report_zones(struct block_device *bdev,
 	n = 0;
 	nz = 0;
 	nr_rep = 0;
-	bio_for_each_page_all2(bv, bio, i, bia) {
+	bio_for_each_page_all(bv, bio, i, bia) {
 
 		if (!bv->bv_page)
 			break;
@@ -182,7 +182,7 @@ int blkdev_report_zones(struct block_device *bdev,
 
 	*nr_zones = nz;
 out:
-	bio_for_each_page_all2(bv, bio, i, bia)
+	bio_for_each_page_all(bv, bio, i, bia)
 		__free_page(bv->bv_page);
 	bio_put(bio);
 
diff --git a/block/bounce.c b/block/bounce.c
index 6436c07179f0..fdabaed443fb 100644
--- a/block/bounce.c
+++ b/block/bounce.c
@@ -151,7 +151,7 @@ static void bounce_end_io(struct bio *bio, mempool_t *pool)
 	/*
 	 * free up bounce indirect pages used
 	 */
-	bio_for_each_page_all2(bvec, bio, i, bia) {
+	bio_for_each_page_all(bvec, bio, i, bia) {
 		orig_vec = bio_iter_iovec(bio_orig, orig_iter);
 		if (bvec->bv_page != orig_vec.bv_page) {
 			dec_zone_page_state(bvec->bv_page, NR_BOUNCE);
@@ -225,7 +225,7 @@ static void __blk_queue_bounce(struct request_queue *q, struct bio **bio_orig,
 	}
 	bio = bio_clone_bioset(*bio_orig, GFP_NOIO, bounce_bio_set);
 
-	bio_for_each_page_all2(to, bio, i, bia) {
+	bio_for_each_page_all(to, bio, i, bia) {
 		struct page *page = to->bv_page;
 
 		if (page_to_pfn(page) <= q->limits.bounce_pfn)
diff --git a/drivers/md/bcache/btree.c b/drivers/md/bcache/btree.c
index ac7bac6e6a29..10e48336ccbf 100644
--- a/drivers/md/bcache/btree.c
+++ b/drivers/md/bcache/btree.c
@@ -425,7 +425,7 @@ static void do_btree_node_write(struct btree *b)
 		void *base = (void *) ((unsigned long) i & ~(PAGE_SIZE - 1));
 		struct bvec_iter_all bia;
 
-		bio_for_each_page_all2(bv, b->bio, j, bia)
+		bio_for_each_page_all(bv, b->bio, j, bia)
 			memcpy(page_address(bv->bv_page),
 			       base + j * PAGE_SIZE, PAGE_SIZE);
 
diff --git a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
index 19dc1f6b523a..9960b4e1747e 100644
--- a/drivers/md/dm-crypt.c
+++ b/drivers/md/dm-crypt.c
@@ -1444,7 +1444,7 @@ static void crypt_free_buffer_pages(struct crypt_config *cc, struct bio *clone)
 	struct bio_vec *bv;
 	struct bvec_iter_all bia;
 
-	bio_for_each_page_all2(bv, clone, i, bia) {
+	bio_for_each_page_all(bv, clone, i, bia) {
 		BUG_ON(!bv->bv_page);
 		mempool_free(bv->bv_page, cc->page_pool);
 	}
diff --git a/drivers/md/raid1.c b/drivers/md/raid1.c
index da5d7ea5504b..c7b059c87fe1 100644
--- a/drivers/md/raid1.c
+++ b/drivers/md/raid1.c
@@ -2090,7 +2090,7 @@ static void process_checks(struct r1bio *r1_bio)
 		/* Now we can 'fixup' the error value */
 		sbio->bi_status = 0;
 
-		bio_for_each_page_all2(bi, sbio, j, bia)
+		bio_for_each_page_all(bi, sbio, j, bia)
 			page_len[j] = bi->bv_len;
 
 		if (!status) {
diff --git a/fs/block_dev.c b/fs/block_dev.c
index 41e1fc90f048..54f625a11c6e 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -243,7 +243,7 @@ __blkdev_direct_IO_simple(struct kiocb *iocb, struct iov_iter *iter,
 	}
 	__set_current_state(TASK_RUNNING);
 
-	bio_for_each_page_all2(bvec, &bio, i, bia) {
+	bio_for_each_page_all(bvec, &bio, i, bia) {
 		if (should_dirty && !PageCompound(bvec->bv_page))
 			set_page_dirty_lock(bvec->bv_page);
 		put_page(bvec->bv_page);
@@ -312,7 +312,7 @@ static void blkdev_bio_end_io(struct bio *bio)
 		int i;
 		struct bvec_iter_all bia;
 
-		bio_for_each_page_all2(bvec, bio, i, bia)
+		bio_for_each_page_all(bvec, bio, i, bia)
 			put_page(bvec->bv_page);
 		bio_put(bio);
 	}
diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
index f399f298b446..176c49050390 100644
--- a/fs/btrfs/compression.c
+++ b/fs/btrfs/compression.c
@@ -172,7 +172,7 @@ static void end_compressed_bio_read(struct bio *bio)
 		 * checked so the end_io handlers know about it
 		 */
 		ASSERT(!bio_flagged(bio, BIO_CLONED));
-		bio_for_each_page_all2(bvec, cb->orig_bio, i, bia)
+		bio_for_each_page_all(bvec, cb->orig_bio, i, bia)
 			SetPageChecked(bvec->bv_page);
 
 		bio_endio(cb->orig_bio);
diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index 8f2afdbd0a27..a7f27f4810ef 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -806,7 +806,7 @@ static blk_status_t btree_csum_one_bio(struct bio *bio)
 	struct bvec_iter_all bia;
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_page_all2(bvec, bio, i, bia) {
+	bio_for_each_page_all(bvec, bio, i, bia) {
 		root = BTRFS_I(bvec->bv_page->mapping->host)->root;
 		ret = csum_dirty_buffer(root->fs_info, bvec->bv_page);
 		if (ret)
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index 9df1b70cfa9b..61d147b708bc 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -2454,7 +2454,7 @@ static void end_bio_extent_writepage(struct bio *bio)
 	struct bvec_iter_all bia;
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_page_all2(bvec, bio, i, bia) {
+	bio_for_each_page_all(bvec, bio, i, bia) {
 		struct page *page = bvec->bv_page;
 		struct inode *inode = page->mapping->host;
 		struct btrfs_fs_info *fs_info = btrfs_sb(inode->i_sb);
@@ -2526,7 +2526,7 @@ static void end_bio_extent_readpage(struct bio *bio)
 	struct bvec_iter_all bia;
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_page_all2(bvec, bio, i, bia) {
+	bio_for_each_page_all(bvec, bio, i, bia) {
 		struct page *page = bvec->bv_page;
 		struct inode *inode = page->mapping->host;
 		struct btrfs_fs_info *fs_info = btrfs_sb(inode->i_sb);
@@ -3687,7 +3687,7 @@ static void end_bio_extent_buffer_writepage(struct bio *bio)
 	struct bvec_iter_all bia;
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_page_all2(bvec, bio, i, bia) {
+	bio_for_each_page_all(bvec, bio, i, bia) {
 		struct page *page = bvec->bv_page;
 
 		eb = (struct extent_buffer *)page->private;
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 1da401c60b9c..ccf91c724bc1 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -8081,7 +8081,7 @@ static void btrfs_retry_endio_nocsum(struct bio *bio)
 
 	done->uptodate = 1;
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_page_all2(bvec, bio, i, bia)
+	bio_for_each_page_all(bvec, bio, i, bia)
 		clean_io_failure(BTRFS_I(inode)->root->fs_info, failure_tree,
 				 io_tree, done->start, bvec->bv_page,
 				 btrfs_ino(BTRFS_I(inode)), 0);
@@ -8174,7 +8174,7 @@ static void btrfs_retry_endio(struct bio *bio)
 	failure_tree = &BTRFS_I(inode)->io_failure_tree;
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_page_all2(bvec, bio, i, bia) {
+	bio_for_each_page_all(bvec, bio, i, bia) {
 		ret = __readpage_endio_check(inode, io_bio, i, bvec->bv_page,
 					     bvec->bv_offset, done->start,
 					     bvec->bv_len);
diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
index 743c3ecb7f97..b1bf8913945b 100644
--- a/fs/crypto/bio.c
+++ b/fs/crypto/bio.c
@@ -39,7 +39,7 @@ static void completion_pages(struct work_struct *work)
 	int i;
 	struct bvec_iter_all bia;
 
-	bio_for_each_page_all2(bv, bio, i, bia) {
+	bio_for_each_page_all(bv, bio, i, bia) {
 		struct page *page = bv->bv_page;
 		int ret = fscrypt_decrypt_page(page->mapping->host, page,
 				PAGE_SIZE, 0, page->index);
diff --git a/fs/direct-io.c b/fs/direct-io.c
index 578a3a854115..6ae379f7327d 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -532,7 +532,7 @@ static blk_status_t dio_bio_complete(struct dio *dio, struct bio *bio)
 	} else {
 		struct bvec_iter_all bia;
 
-		bio_for_each_page_all2(bvec, bio, i, bia) {
+		bio_for_each_page_all(bvec, bio, i, bia) {
 			struct page *page = bvec->bv_page;
 
 			if (dio->op == REQ_OP_READ && !PageCompound(page) &&
diff --git a/fs/exofs/ore.c b/fs/exofs/ore.c
index 5a1d3cd14b44..d28c643e62b4 100644
--- a/fs/exofs/ore.c
+++ b/fs/exofs/ore.c
@@ -408,7 +408,7 @@ static void _clear_bio(struct bio *bio)
 	unsigned i;
 	struct bvec_iter_all bia;
 
-	bio_for_each_page_all2(bv, bio, i, bia) {
+	bio_for_each_page_all(bv, bio, i, bia) {
 		unsigned this_count = bv->bv_len;
 
 		if (likely(PAGE_SIZE == this_count))
diff --git a/fs/exofs/ore_raid.c b/fs/exofs/ore_raid.c
index bb0cc314a987..d14e070bfab1 100644
--- a/fs/exofs/ore_raid.c
+++ b/fs/exofs/ore_raid.c
@@ -438,7 +438,7 @@ static void _mark_read4write_pages_uptodate(struct ore_io_state *ios, int ret)
 		if (!bio)
 			continue;
 
-		bio_for_each_page_all2(bv, bio, i, bia) {
+		bio_for_each_page_all(bv, bio, i, bia) {
 			struct page *page = bv->bv_page;
 
 			SetPageUptodate(page);
diff --git a/fs/ext4/page-io.c b/fs/ext4/page-io.c
index b56a733f33c0..a960ac073818 100644
--- a/fs/ext4/page-io.c
+++ b/fs/ext4/page-io.c
@@ -65,7 +65,7 @@ static void ext4_finish_bio(struct bio *bio)
 	struct bio_vec *bvec;
 	struct bvec_iter_all bia;
 
-	bio_for_each_page_all2(bvec, bio, i, bia) {
+	bio_for_each_page_all(bvec, bio, i, bia) {
 		struct page *page = bvec->bv_page;
 #ifdef CONFIG_EXT4_FS_ENCRYPTION
 		struct page *data_page = NULL;
diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
index c46b5ff68fa8..0bb78365417b 100644
--- a/fs/ext4/readpage.c
+++ b/fs/ext4/readpage.c
@@ -82,7 +82,7 @@ static void mpage_end_io(struct bio *bio)
 			return;
 		}
 	}
-	bio_for_each_page_all2(bv, bio, i, bia) {
+	bio_for_each_page_all(bv, bio, i, bia) {
 		struct page *page = bv->bv_page;
 
 		if (!bio->bi_status) {
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index dc76e0b38ebb..6902cdb87a6e 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -72,7 +72,7 @@ static void f2fs_read_end_io(struct bio *bio)
 		}
 	}
 
-	bio_for_each_page_all2(bvec, bio, i, bia) {
+	bio_for_each_page_all(bvec, bio, i, bia) {
 		struct page *page = bvec->bv_page;
 
 		if (!bio->bi_status) {
@@ -94,7 +94,7 @@ static void f2fs_write_end_io(struct bio *bio)
 	int i;
 	struct bvec_iter_all bia;
 
-	bio_for_each_page_all2(bvec, bio, i, bia) {
+	bio_for_each_page_all(bvec, bio, i, bia) {
 		struct page *page = bvec->bv_page;
 		enum count_type type = WB_DATA_TYPE(page);
 
@@ -263,7 +263,7 @@ static bool __has_merged_page(struct f2fs_bio_info *io,
 	if (!inode && !ino)
 		return true;
 
-	bio_for_each_page_all2(bvec, io->bio, i, bia) {
+	bio_for_each_page_all(bvec, io->bio, i, bia) {
 
 		if (bvec->bv_page->mapping)
 			target = bvec->bv_page;
diff --git a/fs/gfs2/lops.c b/fs/gfs2/lops.c
index 29c8751f9672..5305b192a177 100644
--- a/fs/gfs2/lops.c
+++ b/fs/gfs2/lops.c
@@ -215,7 +215,7 @@ static void gfs2_end_log_write(struct bio *bio)
 		wake_up(&sdp->sd_logd_waitq);
 	}
 
-	bio_for_each_page_all2(bvec, bio, i, bia) {
+	bio_for_each_page_all(bvec, bio, i, bia) {
 		page = bvec->bv_page;
 		if (page_has_buffers(page))
 			gfs2_end_log_write_bh(sdp, bvec, bio->bi_status);
diff --git a/fs/gfs2/meta_io.c b/fs/gfs2/meta_io.c
index a945c9fa1dc6..829affd24efa 100644
--- a/fs/gfs2/meta_io.c
+++ b/fs/gfs2/meta_io.c
@@ -192,7 +192,7 @@ static void gfs2_meta_read_endio(struct bio *bio)
 	int i;
 	struct bvec_iter_all bia;
 
-	bio_for_each_page_all2(bvec, bio, i, bia) {
+	bio_for_each_page_all(bvec, bio, i, bia) {
 		struct page *page = bvec->bv_page;
 		struct buffer_head *bh = page_buffers(page);
 		unsigned int len = bvec->bv_len;
diff --git a/fs/iomap.c b/fs/iomap.c
index fa4b6e15d29c..dde0c60e3a87 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -816,7 +816,7 @@ static void iomap_dio_bio_end_io(struct bio *bio)
 		int i;
 		struct bvec_iter_all bia;
 
-		bio_for_each_page_all2(bvec, bio, i, bia)
+		bio_for_each_page_all(bvec, bio, i, bia)
 			put_page(bvec->bv_page);
 		bio_put(bio);
 	}
diff --git a/fs/mpage.c b/fs/mpage.c
index f2da0f9ec0f2..6360217f4f97 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -50,7 +50,7 @@ static void mpage_end_io(struct bio *bio)
 	int i;
 	struct bvec_iter_all bia;
 
-	bio_for_each_page_all2(bv, bio, i, bia) {
+	bio_for_each_page_all(bv, bio, i, bia) {
 		struct page *page = bv->bv_page;
 		page_endio(page, op_is_write(bio_op(bio)),
 				blk_status_to_errno(bio->bi_status));
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index c0d970817cdc..24c925c4e2a2 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -181,7 +181,7 @@ xfs_destroy_ioend(
 			next = bio->bi_private;
 
 		/* walk each page on bio, ending page IO on them */
-		bio_for_each_page_all2(bvec, bio, i, bia)
+		bio_for_each_page_all(bvec, bio, i, bia)
 			xfs_finish_page_writeback(inode, bvec, error);
 
 		bio_put(bio);
diff --git a/include/linux/bio.h b/include/linux/bio.h
index 05027f0df83f..5c5cd34c9fa3 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -232,7 +232,7 @@ static inline bool bio_rewind_iter(struct bio *bio, struct bvec_iter *iter,
  * bio_for_each_segment_all() and make sure it is correctly used since
  * bvec may points to one multipage bvec.
  */
-#define bio_for_each_page_all2(bvl, bio, i, bi)			\
+#define bio_for_each_page_all(bvl, bio, i, bi)			\
 	for ((bi).iter = BVEC_ITER_ALL_INIT, i = 0, bvl = &(bi).bv;	\
 	     (bi).iter.bi_idx < (bio)->bi_vcnt &&			\
 		(((bi).bv = bio_iter_iovec((bio), (bi).iter)), 1);	\
@@ -368,7 +368,7 @@ static inline unsigned bio_pages_all(struct bio *bio)
 
 	WARN_ON_ONCE(bio_flagged(bio, BIO_CLONED));
 
-	bio_for_each_page_all2(bv, bio, i, bia)
+	bio_for_each_page_all(bv, bio, i, bia)
 		;
 	return i;
 }
diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index 893e8fef0dd0..2811a4cd0706 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -84,7 +84,7 @@ struct bvec_iter {
 						   current bvec */
 };
 
-/* this iter is only for implementing bio_for_each_page_all2() */
+/* this iter is only for implementing bio_for_each_page_all() */
 struct bvec_iter_all {
 	struct bvec_iter	iter;
 	struct bio_vec		bv;      /* in-flight singlepage bvec */
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
