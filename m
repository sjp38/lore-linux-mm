Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 118CD6B0283
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 03:56:39 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id l7-v6so43804811qkd.5
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 00:56:39 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c19si2396932qkb.99.2018.11.15.00.56.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 00:56:37 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V10 12/19] block: allow bio_for_each_segment_all() to iterate over multi-page bvec
Date: Thu, 15 Nov 2018 16:52:59 +0800
Message-Id: <20181115085306.9910-13-ming.lei@redhat.com>
In-Reply-To: <20181115085306.9910-1-ming.lei@redhat.com>
References: <20181115085306.9910-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, linux-fsdevel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

This patch introduces one extra iterator variable to bio_for_each_segment_all(),
then we can allow bio_for_each_segment_all() to iterate over multi-page bvec.

Given it is just one mechannical & simple change on all bio_for_each_segment_all()
users, this patch does tree-wide change in one single patch, so that we can
avoid to use a temporary helper for this conversion.

Cc: Dave Chinner <dchinner@redhat.com>
Cc: Kent Overstreet <kent.overstreet@gmail.com>
Cc: linux-fsdevel@vger.kernel.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Shaohua Li <shli@kernel.org>
Cc: linux-raid@vger.kernel.org
Cc: linux-erofs@lists.ozlabs.org
Cc: linux-btrfs@vger.kernel.org
Cc: David Sterba <dsterba@suse.com>
Cc: Darrick J. Wong <darrick.wong@oracle.com>
Cc: Gao Xiang <gaoxiang25@huawei.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Theodore Ts'o <tytso@mit.edu>
Cc: linux-ext4@vger.kernel.org
Cc: Coly Li <colyli@suse.de>
Cc: linux-bcache@vger.kernel.org
Cc: Boaz Harrosh <ooo@electrozaur.com>
Cc: Bob Peterson <rpeterso@redhat.com>
Cc: cluster-devel@redhat.com
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/bio.c                       | 27 ++++++++++++++++++---------
 block/blk-zoned.c                 |  1 +
 block/bounce.c                    |  6 ++++--
 drivers/md/bcache/btree.c         |  3 ++-
 drivers/md/dm-crypt.c             |  3 ++-
 drivers/md/raid1.c                |  3 ++-
 drivers/staging/erofs/data.c      |  3 ++-
 drivers/staging/erofs/unzip_vle.c |  3 ++-
 fs/block_dev.c                    |  6 ++++--
 fs/btrfs/compression.c            |  3 ++-
 fs/btrfs/disk-io.c                |  3 ++-
 fs/btrfs/extent_io.c              | 12 ++++++++----
 fs/btrfs/inode.c                  |  6 ++++--
 fs/btrfs/raid56.c                 |  3 ++-
 fs/crypto/bio.c                   |  3 ++-
 fs/direct-io.c                    |  4 +++-
 fs/exofs/ore.c                    |  3 ++-
 fs/exofs/ore_raid.c               |  3 ++-
 fs/ext4/page-io.c                 |  3 ++-
 fs/ext4/readpage.c                |  3 ++-
 fs/f2fs/data.c                    |  9 ++++++---
 fs/gfs2/lops.c                    |  6 ++++--
 fs/gfs2/meta_io.c                 |  3 ++-
 fs/iomap.c                        |  6 ++++--
 fs/mpage.c                        |  3 ++-
 fs/xfs/xfs_aops.c                 |  5 +++--
 include/linux/bio.h               | 11 +++++++++--
 include/linux/bvec.h              | 31 +++++++++++++++++++++++++++++++
 28 files changed, 129 insertions(+), 46 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index d5368a445561..6486722d4d4b 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -1072,8 +1072,9 @@ static int bio_copy_from_iter(struct bio *bio, struct iov_iter *iter)
 {
 	int i;
 	struct bio_vec *bvec;
+	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		ssize_t ret;
 
 		ret = copy_page_from_iter(bvec->bv_page,
@@ -1103,8 +1104,9 @@ static int bio_copy_to_iter(struct bio *bio, struct iov_iter iter)
 {
 	int i;
 	struct bio_vec *bvec;
+	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		ssize_t ret;
 
 		ret = copy_page_to_iter(bvec->bv_page,
@@ -1126,8 +1128,9 @@ void bio_free_pages(struct bio *bio)
 {
 	struct bio_vec *bvec;
 	int i;
+	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bvec, bio, i)
+	bio_for_each_segment_all(bvec, bio, i, iter_all)
 		__free_page(bvec->bv_page);
 }
 EXPORT_SYMBOL(bio_free_pages);
@@ -1293,6 +1296,7 @@ struct bio *bio_map_user_iov(struct request_queue *q,
 	struct bio *bio;
 	int ret;
 	struct bio_vec *bvec;
+	struct bvec_iter_all iter_all;
 
 	if (!iov_iter_count(iter))
 		return ERR_PTR(-EINVAL);
@@ -1366,7 +1370,7 @@ struct bio *bio_map_user_iov(struct request_queue *q,
 	return bio;
 
  out_unmap:
-	bio_for_each_segment_all(bvec, bio, j) {
+	bio_for_each_segment_all(bvec, bio, j, iter_all) {
 		put_page(bvec->bv_page);
 	}
 	bio_put(bio);
@@ -1377,11 +1381,12 @@ static void __bio_unmap_user(struct bio *bio)
 {
 	struct bio_vec *bvec;
 	int i;
+	struct bvec_iter_all iter_all;
 
 	/*
 	 * make sure we dirty pages we wrote to
 	 */
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		if (bio_data_dir(bio) == READ)
 			set_page_dirty_lock(bvec->bv_page);
 
@@ -1473,8 +1478,9 @@ static void bio_copy_kern_endio_read(struct bio *bio)
 	char *p = bio->bi_private;
 	struct bio_vec *bvec;
 	int i;
+	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		memcpy(p, page_address(bvec->bv_page), bvec->bv_len);
 		p += bvec->bv_len;
 	}
@@ -1583,8 +1589,9 @@ void bio_set_pages_dirty(struct bio *bio)
 {
 	struct bio_vec *bvec;
 	int i;
+	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		if (!PageCompound(bvec->bv_page))
 			set_page_dirty_lock(bvec->bv_page);
 	}
@@ -1595,8 +1602,9 @@ static void bio_release_pages(struct bio *bio)
 {
 	struct bio_vec *bvec;
 	int i;
+	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bvec, bio, i)
+	bio_for_each_segment_all(bvec, bio, i, iter_all)
 		put_page(bvec->bv_page);
 }
 
@@ -1643,8 +1651,9 @@ void bio_check_pages_dirty(struct bio *bio)
 	struct bio_vec *bvec;
 	unsigned long flags;
 	int i;
+	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		if (!PageDirty(bvec->bv_page) && !PageCompound(bvec->bv_page))
 			goto defer;
 	}
diff --git a/block/blk-zoned.c b/block/blk-zoned.c
index 13ba2011a306..789b09ae402a 100644
--- a/block/blk-zoned.c
+++ b/block/blk-zoned.c
@@ -123,6 +123,7 @@ static int blk_report_zones(struct gendisk *disk, sector_t sector,
 	unsigned int z = 0, n, nrz = *nr_zones;
 	sector_t capacity = get_capacity(disk);
 	int ret;
+	struct bvec_iter_all iter_all;
 
 	while (z < nrz && sector < capacity) {
 		n = nrz - z;
diff --git a/block/bounce.c b/block/bounce.c
index 36869afc258c..aee79b3e4777 100644
--- a/block/bounce.c
+++ b/block/bounce.c
@@ -165,11 +165,12 @@ static void bounce_end_io(struct bio *bio, mempool_t *pool)
 	struct bio_vec *bvec, orig_vec;
 	int i;
 	struct bvec_iter orig_iter = bio_orig->bi_iter;
+	struct bvec_iter_all iter_all;
 
 	/*
 	 * free up bounce indirect pages used
 	 */
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		orig_vec = bio_iter_iovec(bio_orig, orig_iter);
 		if (bvec->bv_page != orig_vec.bv_page) {
 			dec_zone_page_state(bvec->bv_page, NR_BOUNCE);
@@ -292,6 +293,7 @@ static void __blk_queue_bounce(struct request_queue *q, struct bio **bio_orig,
 	bool bounce = false;
 	int sectors = 0;
 	bool passthrough = bio_is_passthrough(*bio_orig);
+	struct bvec_iter_all iter_all;
 
 	bio_for_each_segment(from, *bio_orig, iter) {
 		if (i++ < BIO_MAX_PAGES)
@@ -311,7 +313,7 @@ static void __blk_queue_bounce(struct request_queue *q, struct bio **bio_orig,
 	bio = bounce_clone_bio(*bio_orig, GFP_NOIO, passthrough ? NULL :
 			&bounce_bio_set);
 
-	bio_for_each_segment_all(to, bio, i) {
+	bio_for_each_segment_all(to, bio, i, iter_all) {
 		struct page *page = to->bv_page;
 
 		if (page_to_pfn(page) <= q->limits.bounce_pfn)
diff --git a/drivers/md/bcache/btree.c b/drivers/md/bcache/btree.c
index 3f4211b5cd33..6242ae4e2127 100644
--- a/drivers/md/bcache/btree.c
+++ b/drivers/md/bcache/btree.c
@@ -427,8 +427,9 @@ static void do_btree_node_write(struct btree *b)
 		int j;
 		struct bio_vec *bv;
 		void *base = (void *) ((unsigned long) i & ~(PAGE_SIZE - 1));
+		struct bvec_iter_all iter_all;
 
-		bio_for_each_segment_all(bv, b->bio, j)
+		bio_for_each_segment_all(bv, b->bio, j, iter_all)
 			memcpy(page_address(bv->bv_page),
 			       base + j * PAGE_SIZE, PAGE_SIZE);
 
diff --git a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
index b8eec515a003..a0dcf28c01b5 100644
--- a/drivers/md/dm-crypt.c
+++ b/drivers/md/dm-crypt.c
@@ -1447,8 +1447,9 @@ static void crypt_free_buffer_pages(struct crypt_config *cc, struct bio *clone)
 {
 	unsigned int i;
 	struct bio_vec *bv;
+	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bv, clone, i) {
+	bio_for_each_segment_all(bv, clone, i, iter_all) {
 		BUG_ON(!bv->bv_page);
 		mempool_free(bv->bv_page, &cc->page_pool);
 	}
diff --git a/drivers/md/raid1.c b/drivers/md/raid1.c
index 1d54109071cc..6f74a3b06c7e 100644
--- a/drivers/md/raid1.c
+++ b/drivers/md/raid1.c
@@ -2114,13 +2114,14 @@ static void process_checks(struct r1bio *r1_bio)
 		struct page **spages = get_resync_pages(sbio)->pages;
 		struct bio_vec *bi;
 		int page_len[RESYNC_PAGES] = { 0 };
+		struct bvec_iter_all iter_all;
 
 		if (sbio->bi_end_io != end_sync_read)
 			continue;
 		/* Now we can 'fixup' the error value */
 		sbio->bi_status = 0;
 
-		bio_for_each_segment_all(bi, sbio, j)
+		bio_for_each_segment_all(bi, sbio, j, iter_all)
 			page_len[j] = bi->bv_len;
 
 		if (!status) {
diff --git a/drivers/staging/erofs/data.c b/drivers/staging/erofs/data.c
index 6384f73e5418..96240ceca02a 100644
--- a/drivers/staging/erofs/data.c
+++ b/drivers/staging/erofs/data.c
@@ -20,8 +20,9 @@ static inline void read_endio(struct bio *bio)
 	int i;
 	struct bio_vec *bvec;
 	const blk_status_t err = bio->bi_status;
+	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		struct page *page = bvec->bv_page;
 
 		/* page is already locked */
diff --git a/drivers/staging/erofs/unzip_vle.c b/drivers/staging/erofs/unzip_vle.c
index 79d3ba62b298..41a8a9399863 100644
--- a/drivers/staging/erofs/unzip_vle.c
+++ b/drivers/staging/erofs/unzip_vle.c
@@ -731,11 +731,12 @@ static inline void z_erofs_vle_read_endio(struct bio *bio)
 	const blk_status_t err = bio->bi_status;
 	unsigned int i;
 	struct bio_vec *bvec;
+	struct bvec_iter_all iter_all;
 #ifdef EROFS_FS_HAS_MANAGED_CACHE
 	struct address_space *mngda = NULL;
 #endif
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		struct page *page = bvec->bv_page;
 		bool cachemngd = false;
 
diff --git a/fs/block_dev.c b/fs/block_dev.c
index c039abfb2052..0fcb5515dca7 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -197,6 +197,7 @@ __blkdev_direct_IO_simple(struct kiocb *iocb, struct iov_iter *iter,
 	ssize_t ret;
 	blk_qc_t qc;
 	int i;
+	struct bvec_iter_all iter_all;
 
 	if ((pos | iov_iter_alignment(iter)) &
 	    (bdev_logical_block_size(bdev) - 1))
@@ -246,7 +247,7 @@ __blkdev_direct_IO_simple(struct kiocb *iocb, struct iov_iter *iter,
 	}
 	__set_current_state(TASK_RUNNING);
 
-	bio_for_each_segment_all(bvec, &bio, i) {
+	bio_for_each_segment_all(bvec, &bio, i, iter_all) {
 		if (should_dirty && !PageCompound(bvec->bv_page))
 			set_page_dirty_lock(bvec->bv_page);
 		put_page(bvec->bv_page);
@@ -314,8 +315,9 @@ static void blkdev_bio_end_io(struct bio *bio)
 	} else {
 		struct bio_vec *bvec;
 		int i;
+		struct bvec_iter_all iter_all;
 
-		bio_for_each_segment_all(bvec, bio, i)
+		bio_for_each_segment_all(bvec, bio, i, iter_all)
 			put_page(bvec->bv_page);
 		bio_put(bio);
 	}
diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
index 161e14b8b180..ac3c201377e1 100644
--- a/fs/btrfs/compression.c
+++ b/fs/btrfs/compression.c
@@ -162,13 +162,14 @@ static void end_compressed_bio_read(struct bio *bio)
 	} else {
 		int i;
 		struct bio_vec *bvec;
+		struct bvec_iter_all iter_all;
 
 		/*
 		 * we have verified the checksum already, set page
 		 * checked so the end_io handlers know about it
 		 */
 		ASSERT(!bio_flagged(bio, BIO_CLONED));
-		bio_for_each_segment_all(bvec, cb->orig_bio, i)
+		bio_for_each_segment_all(bvec, cb->orig_bio, i, iter_all)
 			SetPageChecked(bvec->bv_page);
 
 		bio_endio(cb->orig_bio);
diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index b0ab41da91d1..834efe6e3137 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -819,9 +819,10 @@ static blk_status_t btree_csum_one_bio(struct bio *bio)
 	struct bio_vec *bvec;
 	struct btrfs_root *root;
 	int i, ret = 0;
+	struct bvec_iter_all iter_all;
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		root = BTRFS_I(bvec->bv_page->mapping->host)->root;
 		ret = csum_dirty_buffer(root->fs_info, bvec->bv_page);
 		if (ret)
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index 874bb9aeebdc..9373eb8ade06 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -2352,10 +2352,11 @@ static unsigned btrfs_bio_pages_all(struct bio *bio)
 {
 	unsigned i;
 	struct bio_vec *bv;
+	struct bvec_iter_all iter_all;
 
 	WARN_ON_ONCE(bio_flagged(bio, BIO_CLONED));
 
-	bio_for_each_segment_all(bv, bio, i)
+	bio_for_each_segment_all(bv, bio, i, iter_all)
 		;
 	return i;
 }
@@ -2457,9 +2458,10 @@ static void end_bio_extent_writepage(struct bio *bio)
 	u64 start;
 	u64 end;
 	int i;
+	struct bvec_iter_all iter_all;
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		struct page *page = bvec->bv_page;
 		struct inode *inode = page->mapping->host;
 		struct btrfs_fs_info *fs_info = btrfs_sb(inode->i_sb);
@@ -2528,9 +2530,10 @@ static void end_bio_extent_readpage(struct bio *bio)
 	int mirror;
 	int ret;
 	int i;
+	struct bvec_iter_all iter_all;
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		struct page *page = bvec->bv_page;
 		struct inode *inode = page->mapping->host;
 		struct btrfs_fs_info *fs_info = btrfs_sb(inode->i_sb);
@@ -3682,9 +3685,10 @@ static void end_bio_extent_buffer_writepage(struct bio *bio)
 	struct bio_vec *bvec;
 	struct extent_buffer *eb;
 	int i, done;
+	struct bvec_iter_all iter_all;
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		struct page *page = bvec->bv_page;
 
 		eb = (struct extent_buffer *)page->private;
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index d3df5b52278c..0ec8c1dd328f 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -7811,6 +7811,7 @@ static void btrfs_retry_endio_nocsum(struct bio *bio)
 	struct bio_vec *bvec;
 	struct extent_io_tree *io_tree, *failure_tree;
 	int i;
+	struct bvec_iter_all iter_all;
 
 	if (bio->bi_status)
 		goto end;
@@ -7822,7 +7823,7 @@ static void btrfs_retry_endio_nocsum(struct bio *bio)
 
 	done->uptodate = 1;
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_segment_all(bvec, bio, i)
+	bio_for_each_segment_all(bvec, bio, i, iter_all)
 		clean_io_failure(BTRFS_I(inode)->root->fs_info, failure_tree,
 				 io_tree, done->start, bvec->bv_page,
 				 btrfs_ino(BTRFS_I(inode)), 0);
@@ -7901,6 +7902,7 @@ static void btrfs_retry_endio(struct bio *bio)
 	int uptodate;
 	int ret;
 	int i;
+	struct bvec_iter_all iter_all;
 
 	if (bio->bi_status)
 		goto end;
@@ -7914,7 +7916,7 @@ static void btrfs_retry_endio(struct bio *bio)
 	failure_tree = &BTRFS_I(inode)->io_failure_tree;
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		ret = __readpage_endio_check(inode, io_bio, i, bvec->bv_page,
 					     bvec->bv_offset, done->start,
 					     bvec->bv_len);
diff --git a/fs/btrfs/raid56.c b/fs/btrfs/raid56.c
index df41d7049936..e33a99871d60 100644
--- a/fs/btrfs/raid56.c
+++ b/fs/btrfs/raid56.c
@@ -1443,10 +1443,11 @@ static void set_bio_pages_uptodate(struct bio *bio)
 {
 	struct bio_vec *bvec;
 	int i;
+	struct bvec_iter_all iter_all;
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
 
-	bio_for_each_segment_all(bvec, bio, i)
+	bio_for_each_segment_all(bvec, bio, i, iter_all)
 		SetPageUptodate(bvec->bv_page);
 }
 
diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
index 0959044c5cee..5759bcd018cd 100644
--- a/fs/crypto/bio.c
+++ b/fs/crypto/bio.c
@@ -30,8 +30,9 @@ static void __fscrypt_decrypt_bio(struct bio *bio, bool done)
 {
 	struct bio_vec *bv;
 	int i;
+	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bv, bio, i) {
+	bio_for_each_segment_all(bv, bio, i, iter_all) {
 		struct page *page = bv->bv_page;
 		int ret = fscrypt_decrypt_page(page->mapping->host, page,
 				PAGE_SIZE, 0, page->index);
diff --git a/fs/direct-io.c b/fs/direct-io.c
index ea07d5a34317..5904fc2e180c 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -551,7 +551,9 @@ static blk_status_t dio_bio_complete(struct dio *dio, struct bio *bio)
 	if (dio->is_async && dio->op == REQ_OP_READ && dio->should_dirty) {
 		bio_check_pages_dirty(bio);	/* transfers ownership */
 	} else {
-		bio_for_each_segment_all(bvec, bio, i) {
+		struct bvec_iter_all iter_all;
+
+		bio_for_each_segment_all(bvec, bio, i, iter_all) {
 			struct page *page = bvec->bv_page;
 
 			if (dio->op == REQ_OP_READ && !PageCompound(page) &&
diff --git a/fs/exofs/ore.c b/fs/exofs/ore.c
index 5331a15a61f1..24a8e34882e9 100644
--- a/fs/exofs/ore.c
+++ b/fs/exofs/ore.c
@@ -420,8 +420,9 @@ static void _clear_bio(struct bio *bio)
 {
 	struct bio_vec *bv;
 	unsigned i;
+	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bv, bio, i) {
+	bio_for_each_segment_all(bv, bio, i, iter_all) {
 		unsigned this_count = bv->bv_len;
 
 		if (likely(PAGE_SIZE == this_count))
diff --git a/fs/exofs/ore_raid.c b/fs/exofs/ore_raid.c
index 199590f36203..e83bab54b03e 100644
--- a/fs/exofs/ore_raid.c
+++ b/fs/exofs/ore_raid.c
@@ -468,11 +468,12 @@ static void _mark_read4write_pages_uptodate(struct ore_io_state *ios, int ret)
 	/* loop on all devices all pages */
 	for (d = 0; d < ios->numdevs; d++) {
 		struct bio *bio = ios->per_dev[d].bio;
+		struct bvec_iter_all iter_all;
 
 		if (!bio)
 			continue;
 
-		bio_for_each_segment_all(bv, bio, i) {
+		bio_for_each_segment_all(bv, bio, i, iter_all) {
 			struct page *page = bv->bv_page;
 
 			SetPageUptodate(page);
diff --git a/fs/ext4/page-io.c b/fs/ext4/page-io.c
index db7590178dfc..0644b4e7d6d4 100644
--- a/fs/ext4/page-io.c
+++ b/fs/ext4/page-io.c
@@ -63,8 +63,9 @@ static void ext4_finish_bio(struct bio *bio)
 {
 	int i;
 	struct bio_vec *bvec;
+	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		struct page *page = bvec->bv_page;
 #ifdef CONFIG_EXT4_FS_ENCRYPTION
 		struct page *data_page = NULL;
diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
index f461d75ac049..b0d9537bc797 100644
--- a/fs/ext4/readpage.c
+++ b/fs/ext4/readpage.c
@@ -72,6 +72,7 @@ static void mpage_end_io(struct bio *bio)
 {
 	struct bio_vec *bv;
 	int i;
+	struct bvec_iter_all iter_all;
 
 	if (ext4_bio_encrypted(bio)) {
 		if (bio->bi_status) {
@@ -81,7 +82,7 @@ static void mpage_end_io(struct bio *bio)
 			return;
 		}
 	}
-	bio_for_each_segment_all(bv, bio, i) {
+	bio_for_each_segment_all(bv, bio, i, iter_all) {
 		struct page *page = bv->bv_page;
 
 		if (!bio->bi_status) {
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index b293cb3e27a2..d28f482a0d52 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -87,8 +87,9 @@ static void __read_end_io(struct bio *bio)
 	struct page *page;
 	struct bio_vec *bv;
 	int i;
+	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bv, bio, i) {
+	bio_for_each_segment_all(bv, bio, i, iter_all) {
 		page = bv->bv_page;
 
 		/* PG_error was set if any post_read step failed */
@@ -164,13 +165,14 @@ static void f2fs_write_end_io(struct bio *bio)
 	struct f2fs_sb_info *sbi = bio->bi_private;
 	struct bio_vec *bvec;
 	int i;
+	struct bvec_iter_all iter_all;
 
 	if (time_to_inject(sbi, FAULT_WRITE_IO)) {
 		f2fs_show_injection_info(FAULT_WRITE_IO);
 		bio->bi_status = BLK_STS_IOERR;
 	}
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		struct page *page = bvec->bv_page;
 		enum count_type type = WB_DATA_TYPE(page);
 
@@ -347,6 +349,7 @@ static bool __has_merged_page(struct f2fs_bio_info *io, struct inode *inode,
 	struct bio_vec *bvec;
 	struct page *target;
 	int i;
+	struct bvec_iter_all iter_all;
 
 	if (!io->bio)
 		return false;
@@ -354,7 +357,7 @@ static bool __has_merged_page(struct f2fs_bio_info *io, struct inode *inode,
 	if (!inode && !page && !ino)
 		return true;
 
-	bio_for_each_segment_all(bvec, io->bio, i) {
+	bio_for_each_segment_all(bvec, io->bio, i, iter_all) {
 
 		if (bvec->bv_page->mapping)
 			target = bvec->bv_page;
diff --git a/fs/gfs2/lops.c b/fs/gfs2/lops.c
index 4c7069b8f3c1..f2f165620161 100644
--- a/fs/gfs2/lops.c
+++ b/fs/gfs2/lops.c
@@ -168,7 +168,8 @@ u64 gfs2_log_bmap(struct gfs2_sbd *sdp)
  * that is pinned in the pagecache.
  */
 
-static void gfs2_end_log_write_bh(struct gfs2_sbd *sdp, struct bio_vec *bvec,
+static void gfs2_end_log_write_bh(struct gfs2_sbd *sdp,
+				  struct bio_vec *bvec,
 				  blk_status_t error)
 {
 	struct buffer_head *bh, *next;
@@ -207,6 +208,7 @@ static void gfs2_end_log_write(struct bio *bio)
 	struct bio_vec *bvec;
 	struct page *page;
 	int i;
+	struct bvec_iter_all iter_all;
 
 	if (bio->bi_status) {
 		fs_err(sdp, "Error %d writing to journal, jid=%u\n",
@@ -214,7 +216,7 @@ static void gfs2_end_log_write(struct bio *bio)
 		wake_up(&sdp->sd_logd_waitq);
 	}
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		page = bvec->bv_page;
 		if (page_has_buffers(page))
 			gfs2_end_log_write_bh(sdp, bvec, bio->bi_status);
diff --git a/fs/gfs2/meta_io.c b/fs/gfs2/meta_io.c
index be9c0bf697fe..3201342404a7 100644
--- a/fs/gfs2/meta_io.c
+++ b/fs/gfs2/meta_io.c
@@ -190,8 +190,9 @@ static void gfs2_meta_read_endio(struct bio *bio)
 {
 	struct bio_vec *bvec;
 	int i;
+	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		struct page *page = bvec->bv_page;
 		struct buffer_head *bh = page_buffers(page);
 		unsigned int len = bvec->bv_len;
diff --git a/fs/iomap.c b/fs/iomap.c
index f61d13dfdf09..df0212560b36 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -262,8 +262,9 @@ iomap_read_end_io(struct bio *bio)
 	int error = blk_status_to_errno(bio->bi_status);
 	struct bio_vec *bvec;
 	int i;
+	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bvec, bio, i)
+	bio_for_each_segment_all(bvec, bio, i, iter_all)
 		iomap_read_page_end_io(bvec, error);
 	bio_put(bio);
 }
@@ -1541,8 +1542,9 @@ static void iomap_dio_bio_end_io(struct bio *bio)
 	} else {
 		struct bio_vec *bvec;
 		int i;
+		struct bvec_iter_all iter_all;
 
-		bio_for_each_segment_all(bvec, bio, i)
+		bio_for_each_segment_all(bvec, bio, i, iter_all)
 			put_page(bvec->bv_page);
 		bio_put(bio);
 	}
diff --git a/fs/mpage.c b/fs/mpage.c
index c820dc9bebab..3f19da75178b 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -48,8 +48,9 @@ static void mpage_end_io(struct bio *bio)
 {
 	struct bio_vec *bv;
 	int i;
+	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bv, bio, i) {
+	bio_for_each_segment_all(bv, bio, i, iter_all) {
 		struct page *page = bv->bv_page;
 		page_endio(page, bio_op(bio),
 			   blk_status_to_errno(bio->bi_status));
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 338b9d9984e0..1f1829e506e8 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -62,7 +62,7 @@ xfs_find_daxdev_for_inode(
 static void
 xfs_finish_page_writeback(
 	struct inode		*inode,
-	struct bio_vec		*bvec,
+	struct bio_vec	*bvec,
 	int			error)
 {
 	struct iomap_page	*iop = to_iomap_page(bvec->bv_page);
@@ -98,6 +98,7 @@ xfs_destroy_ioend(
 	for (bio = &ioend->io_inline_bio; bio; bio = next) {
 		struct bio_vec	*bvec;
 		int		i;
+		struct bvec_iter_all iter_all;
 
 		/*
 		 * For the last bio, bi_private points to the ioend, so we
@@ -109,7 +110,7 @@ xfs_destroy_ioend(
 			next = bio->bi_private;
 
 		/* walk each page on bio, ending page IO on them */
-		bio_for_each_segment_all(bvec, bio, i)
+		bio_for_each_segment_all(bvec, bio, i, iter_all)
 			xfs_finish_page_writeback(inode, bvec, error);
 		bio_put(bio);
 	}
diff --git a/include/linux/bio.h b/include/linux/bio.h
index 3496c816946e..1a2430a8b89d 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -131,12 +131,19 @@ static inline bool bio_full(struct bio *bio)
 	return bio->bi_vcnt >= bio->bi_max_vecs;
 }
 
+#define bvec_for_each_segment(bv, bvl, i, iter_all)			\
+	for (bv = bvec_init_iter_all(&iter_all);			\
+		(iter_all.done < (bvl)->bv_len) &&			\
+		((bvec_next_segment((bvl), &iter_all)), 1);		\
+		iter_all.done += bv->bv_len, i += 1)
+
 /*
  * drivers should _never_ use the all version - the bio may have been split
  * before it got to the driver and the driver won't own all of it
  */
-#define bio_for_each_segment_all(bvl, bio, i)				\
-	for (i = 0, bvl = (bio)->bi_io_vec; i < (bio)->bi_vcnt; i++, bvl++)
+#define bio_for_each_segment_all(bvl, bio, i, iter_all)		\
+	for (i = 0, iter_all.idx = 0; iter_all.idx < (bio)->bi_vcnt; iter_all.idx++)	\
+		bvec_for_each_segment(bvl, &((bio)->bi_io_vec[iter_all.idx]), i, iter_all)
 
 static inline void __bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
 				      unsigned bytes, bool mp)
diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index 01616a0b6220..02f26d2b59ad 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -82,6 +82,12 @@ struct bvec_iter {
 						   current bvec */
 };
 
+struct bvec_iter_all {
+	struct bio_vec	bv;
+	int		idx;
+	unsigned	done;
+};
+
 /*
  * various member access, note that bio_data should of course not be used
  * on highmem page vectors
@@ -216,6 +222,31 @@ static inline bool mp_bvec_iter_advance(const struct bio_vec *bv,
 	.bi_bvec_done	= 0,						\
 }
 
+static inline struct bio_vec *bvec_init_iter_all(struct bvec_iter_all *iter_all)
+{
+	iter_all->bv.bv_page = NULL;
+	iter_all->done = 0;
+
+	return &iter_all->bv;
+}
+
+/* used for chunk_for_each_segment */
+static inline void bvec_next_segment(const struct bio_vec *bvec,
+		struct bvec_iter_all *iter_all)
+{
+	struct bio_vec *bv = &iter_all->bv;
+
+	if (bv->bv_page) {
+		bv->bv_page += 1;
+		bv->bv_offset = 0;
+	} else {
+		bv->bv_page = bvec->bv_page;
+		bv->bv_offset = bvec->bv_offset;
+	}
+	bv->bv_len = min_t(unsigned int, PAGE_SIZE - bv->bv_offset,
+			bvec->bv_len - iter_all->done);
+}
+
 /*
  * Get the last singlepage segment from the multipage bvec and store it
  * in @seg
-- 
2.9.5
