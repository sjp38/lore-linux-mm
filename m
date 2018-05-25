Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 67EAC6B02C4
	for <linux-mm@kvack.org>; Thu, 24 May 2018 23:52:13 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id m7-v6so2929879qtg.1
        for <linux-mm@kvack.org>; Thu, 24 May 2018 20:52:13 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id y18-v6si4213116qva.200.2018.05.24.20.52.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 20:52:11 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [RESEND PATCH V5 29/33] block: rename bio_for_each_page_all2 as bio_for_each_page_all
Date: Fri, 25 May 2018 11:46:17 +0800
Message-Id: <20180525034621.31147-30-ming.lei@redhat.com>
In-Reply-To: <20180525034621.31147-1-ming.lei@redhat.com>
References: <20180525034621.31147-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

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
 fs/btrfs/raid56.c         |  2 +-
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
 26 files changed, 41 insertions(+), 41 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index a14c854b9111..c160c143cc1b 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -1121,7 +1121,7 @@ static int bio_copy_from_iter(struct bio *bio, struct iov_iter *iter)
 	struct bio_vec *bvec;
 	struct bvec_iter_all bia;
 
-	bio_for_each_page_all2(bvec, bio, i, bia) {
+	bio_for_each_page_all(bvec, bio, i, bia) {
 		ssize_t ret;
 
 		ret = copy_page_from_iter(bvec->bv_page,
@@ -1153,7 +1153,7 @@ static int bio_copy_to_iter(struct bio *bio, struct iov_iter iter)
 	struct bio_vec *bvec;
 	struct bvec_iter_all bia;
 
-	bio_for_each_page_all2(bvec, bio, i, bia) {
+	bio_for_each_page_all(bvec, bio, i, bia) {
 		ssize_t ret;
 
 		ret = copy_page_to_iter(bvec->bv_page,
@@ -1177,7 +1177,7 @@ void bio_free_pages(struct bio *bio)
 	int i;
 	struct bvec_iter_all bia;
 
-	bio_for_each_page_all2(bvec, bio, i, bia)
+	bio_for_each_page_all(bvec, bio, i, bia)
 		__free_page(bvec->bv_page);
 }
 EXPORT_SYMBOL(bio_free_pages);
@@ -1417,7 +1417,7 @@ struct bio *bio_map_user_iov(struct request_queue *q,
 	return bio;
 
  out_unmap:
-	bio_for_each_page_all2(bvec, bio, j, bia) {
+	bio_for_each_page_all(bvec, bio, j, bia) {
 		put_page(bvec->bv_page);
 	}
 	bio_put(bio);
@@ -1433,7 +1433,7 @@ static void __bio_unmap_user(struct bio *bio)
 	/*
 	 * make sure we dirty pages we wrote to
 	 */
-	bio_for_each_page_all2(bvec, bio, i, bia) {
+	bio_for_each_page_all(bvec, bio, i, bia) {
 		if (bio_data_dir(bio) == READ)
 			set_page_dirty_lock(bvec->bv_page);
 
@@ -1527,7 +1527,7 @@ static void bio_copy_kern_endio_read(struct bio *bio)
 	int i;
 	struct bvec_iter_all bia;
 
-	bio_for_each_page_all2(bvec, bio, i, bia) {
+	bio_for_each_page_all(bvec, bio, i, bia) {
 		memcpy(p, page_address(bvec->bv_page), bvec->bv_len);
 		p += bvec->bv_len;
 	}
@@ -1638,7 +1638,7 @@ void bio_set_pages_dirty(struct bio *bio)
 	int i;
 	struct bvec_iter_all bia;
 
-	bio_for_each_page_all2(bvec, bio, i, bia) {
+	bio_for_each_page_all(bvec, bio, i, bia) {
 		struct page *page = bvec->bv_page;
 
 		if (page && !PageCompound(page))
diff --git a/block/blk-zoned.c b/block/blk-zoned.c
index a76053d6fd6c..b7c182b0d805 100644
--- a/block/blk-zoned.c
+++ b/block/blk-zoned.c
@@ -191,7 +191,7 @@ int blkdev_report_zones(struct block_device *bdev,
 	n = 0;
 	nz = 0;
 	nr_rep = 0;
-	bio_for_each_page_all2(bv, bio, i, bia) {
+	bio_for_each_page_all(bv, bio, i, bia) {
 
 		if (!bv->bv_page)
 			break;
@@ -224,7 +224,7 @@ int blkdev_report_zones(struct block_device *bdev,
 
 	*nr_zones = nz;
 out:
-	bio_for_each_page_all2(bv, bio, i, bia)
+	bio_for_each_page_all(bv, bio, i, bia)
 		__free_page(bv->bv_page);
 	bio_put(bio);
 
diff --git a/block/bounce.c b/block/bounce.c
index 8b14683f4061..da9fcf1a07d7 100644
--- a/block/bounce.c
+++ b/block/bounce.c
@@ -148,7 +148,7 @@ static void bounce_end_io(struct bio *bio, mempool_t *pool)
 	/*
 	 * free up bounce indirect pages used
 	 */
-	bio_for_each_page_all2(bvec, bio, i, bia) {
+	bio_for_each_page_all(bvec, bio, i, bia) {
 		orig_vec = bio_iter_iovec(bio_orig, orig_iter);
 		if (bvec->bv_page != orig_vec.bv_page) {
 			dec_zone_page_state(bvec->bv_page, NR_BOUNCE);
@@ -224,7 +224,7 @@ static void __blk_queue_bounce(struct request_queue *q, struct bio **bio_orig,
 	bio = bio_clone_bioset(*bio_orig, GFP_NOIO, passthrough ? NULL :
 			bounce_bio_set);
 
-	bio_for_each_page_all2(to, bio, i, bia) {
+	bio_for_each_page_all(to, bio, i, bia) {
 		struct page *page = to->bv_page;
 
 		if (page_to_pfn(page) <= q->limits.bounce_pfn)
diff --git a/drivers/md/bcache/btree.c b/drivers/md/bcache/btree.c
index 498f6b032b4c..da8a434dc3a0 100644
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
index 8fdc8349fd72..016b8c5fcaf6 100644
--- a/drivers/md/dm-crypt.c
+++ b/drivers/md/dm-crypt.c
@@ -1452,7 +1452,7 @@ static void crypt_free_buffer_pages(struct crypt_config *cc, struct bio *clone)
 	struct bio_vec *bv;
 	struct bvec_iter_all bia;
 
-	bio_for_each_page_all2(bv, clone, i, bia) {
+	bio_for_each_page_all(bv, clone, i, bia) {
 		BUG_ON(!bv->bv_page);
 		mempool_free(bv->bv_page, cc->page_pool);
 	}
diff --git a/drivers/md/raid1.c b/drivers/md/raid1.c
index 8b2b071619a2..74737cf08cab 100644
--- a/drivers/md/raid1.c
+++ b/drivers/md/raid1.c
@@ -2124,7 +2124,7 @@ static void process_checks(struct r1bio *r1_bio)
 		/* Now we can 'fixup' the error value */
 		sbio->bi_status = 0;
 
-		bio_for_each_page_all2(bi, sbio, j, bia)
+		bio_for_each_page_all(bi, sbio, j, bia)
 			page_len[j] = bi->bv_len;
 
 		if (!status) {
diff --git a/fs/block_dev.c b/fs/block_dev.c
index f581fc0a6142..03422da6bfff 100644
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
index 4cfe38feae3b..3a7a14db80b8 100644
--- a/fs/btrfs/compression.c
+++ b/fs/btrfs/compression.c
@@ -173,7 +173,7 @@ static void end_compressed_bio_read(struct bio *bio)
 		 * checked so the end_io handlers know about it
 		 */
 		ASSERT(!bio_flagged(bio, BIO_CLONED));
-		bio_for_each_page_all2(bvec, cb->orig_bio, i, bia)
+		bio_for_each_page_all(bvec, cb->orig_bio, i, bia)
 			SetPageChecked(bvec->bv_page);
 
 		bio_endio(cb->orig_bio);
diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index ef78fd71c2f7..e3dbdbf4ea6b 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -832,7 +832,7 @@ static blk_status_t btree_csum_one_bio(struct bio *bio)
 	struct bvec_iter_all bia;
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_page_all2(bvec, bio, i, bia) {
+	bio_for_each_page_all(bvec, bio, i, bia) {
 		root = BTRFS_I(bvec->bv_page->mapping->host)->root;
 		ret = csum_dirty_buffer(root->fs_info, bvec->bv_page);
 		if (ret)
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index 383db7a7e5a4..3a1a1b4a4c55 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -2459,7 +2459,7 @@ static void end_bio_extent_writepage(struct bio *bio)
 	struct bvec_iter_all bia;
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_page_all2(bvec, bio, i, bia) {
+	bio_for_each_page_all(bvec, bio, i, bia) {
 		struct page *page = bvec->bv_page;
 		struct inode *inode = page->mapping->host;
 		struct btrfs_fs_info *fs_info = btrfs_sb(inode->i_sb);
@@ -2531,7 +2531,7 @@ static void end_bio_extent_readpage(struct bio *bio)
 	struct bvec_iter_all bia;
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_page_all2(bvec, bio, i, bia) {
+	bio_for_each_page_all(bvec, bio, i, bia) {
 		struct page *page = bvec->bv_page;
 		struct inode *inode = page->mapping->host;
 		struct btrfs_fs_info *fs_info = btrfs_sb(inode->i_sb);
@@ -3686,7 +3686,7 @@ static void end_bio_extent_buffer_writepage(struct bio *bio)
 	struct bvec_iter_all bia;
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_page_all2(bvec, bio, i, bia) {
+	bio_for_each_page_all(bvec, bio, i, bia) {
 		struct page *page = bvec->bv_page;
 
 		eb = (struct extent_buffer *)page->private;
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 8a73b26915bc..812ca7ac5108 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -7895,7 +7895,7 @@ static void btrfs_retry_endio_nocsum(struct bio *bio)
 
 	done->uptodate = 1;
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_page_all2(bvec, bio, i, bia)
+	bio_for_each_page_all(bvec, bio, i, bia)
 		clean_io_failure(BTRFS_I(inode)->root->fs_info, failure_tree,
 				 io_tree, done->start, bvec->bv_page,
 				 btrfs_ino(BTRFS_I(inode)), 0);
@@ -7988,7 +7988,7 @@ static void btrfs_retry_endio(struct bio *bio)
 	failure_tree = &BTRFS_I(inode)->io_failure_tree;
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_page_all2(bvec, bio, i, bia) {
+	bio_for_each_page_all(bvec, bio, i, bia) {
 		ret = __readpage_endio_check(inode, io_bio, i, bvec->bv_page,
 					     bvec->bv_offset, done->start,
 					     bvec->bv_len);
diff --git a/fs/btrfs/raid56.c b/fs/btrfs/raid56.c
index 955fa4dbecee..90f16fbfc378 100644
--- a/fs/btrfs/raid56.c
+++ b/fs/btrfs/raid56.c
@@ -1449,7 +1449,7 @@ static void set_bio_pages_uptodate(struct bio *bio)
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
 
-	bio_for_each_page_all2(bvec, bio, i, bia)
+	bio_for_each_page_all(bvec, bio, i, bia)
 		SetPageUptodate(bvec->bv_page);
 }
 
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
index e6a6dd560da2..b57c3aa26cab 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -553,7 +553,7 @@ static blk_status_t dio_bio_complete(struct dio *dio, struct bio *bio)
 	} else {
 		struct bvec_iter_all bia;
 
-		bio_for_each_page_all2(bvec, bio, i, bia) {
+		bio_for_each_page_all(bvec, bio, i, bia) {
 			struct page *page = bvec->bv_page;
 
 			if (dio->op == REQ_OP_READ && !PageCompound(page) &&
diff --git a/fs/exofs/ore.c b/fs/exofs/ore.c
index 2a7e93f21695..e4b51885cf49 100644
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
index 924284e2f358..a3200dee15a4 100644
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
 
@@ -277,7 +277,7 @@ static bool __has_merged_page(struct f2fs_bio_info *io,
 	if (!inode && !ino)
 		return true;
 
-	bio_for_each_page_all2(bvec, io->bio, i, bia) {
+	bio_for_each_page_all(bvec, io->bio, i, bia) {
 
 		if (bvec->bv_page->mapping)
 			target = bvec->bv_page;
diff --git a/fs/gfs2/lops.c b/fs/gfs2/lops.c
index 0284cd66089c..036475303fed 100644
--- a/fs/gfs2/lops.c
+++ b/fs/gfs2/lops.c
@@ -216,7 +216,7 @@ static void gfs2_end_log_write(struct bio *bio)
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
index 31d19f8f0aac..39a49a1cd8d8 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -819,7 +819,7 @@ static void iomap_dio_bio_end_io(struct bio *bio)
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
index b5077eb4df51..f3ae373d3092 100644
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
index c5e692d43f23..fc8a8238805e 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -236,7 +236,7 @@ static inline bool bio_rewind_iter(struct bio *bio, struct bvec_iter *iter,
  * bio_for_each_segment_all() and make sure it is correctly used since
  * bvec may points to one multipage bvec.
  */
-#define bio_for_each_page_all2(bvl, bio, i, bi)			\
+#define bio_for_each_page_all(bvl, bio, i, bi)			\
 	for ((bi).iter = BVEC_ITER_ALL_INIT, i = 0, bvl = &(bi).bv;	\
 	     (bi).iter.bi_idx < (bio)->bi_vcnt &&			\
 		(((bi).bv = bio_iter_iovec((bio), (bi).iter)), 1);	\
@@ -372,7 +372,7 @@ static inline unsigned bio_pages_all(struct bio *bio)
 
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
