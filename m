Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 413AE6B3F83
	for <linux-mm@kvack.org>; Sun, 25 Nov 2018 21:20:49 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id c7so18001436qkg.16
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 18:20:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y36si416961qtd.218.2018.11.25.18.20.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Nov 2018 18:20:47 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V12 15/20] block: allow bio_for_each_segment_all() to iterate over multi-page bvec
Date: Mon, 26 Nov 2018 10:17:15 +0800
Message-Id: <20181126021720.19471-16-ming.lei@redhat.com>
In-Reply-To: <20181126021720.19471-1-ming.lei@redhat.com>
References: <20181126021720.19471-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Ming Lei <ming.lei@redhat.com>

This patch introduces one extra iterator variable to bio_for_each_segment_all(),
then we can allow bio_for_each_segment_all() to iterate over multi-page bvec.

Given it is just one mechannical & simple change on all bio_for_each_segment_all()
users, this patch does tree-wide change in one single patch, so that we can
avoid to use a temporary helper for this conversion.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/bio.c                       | 27 ++++++++++++++++++---------
 block/bounce.c                    |  6 ++++--
 drivers/md/bcache/btree.c         |  3 ++-
 drivers/md/dm-crypt.c             |  3 ++-
 drivers/md/raid1.c                |  3 ++-
 drivers/staging/erofs/data.c      |  3 ++-
 drivers/staging/erofs/unzip_vle.c |  3 ++-
 fs/block_dev.c                    |  6 ++++--
 fs/btrfs/compression.c            |  3 ++-
 fs/btrfs/disk-io.c                |  3 ++-
 fs/btrfs/extent_io.c              |  9 ++++++---
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
 include/linux/bvec.h              | 30 ++++++++++++++++++++++++++++++
 27 files changed, 125 insertions(+), 45 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index 03895cc0d74a..75fde30af51f 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -1073,8 +1073,9 @@ static int bio_copy_from_iter(struct bio *bio, struct iov_iter *iter)
 {
 	int i;
 	struct bio_vec *bvec;
+	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		ssize_t ret;
 
 		ret = copy_page_from_iter(bvec->bv_page,
@@ -1104,8 +1105,9 @@ static int bio_copy_to_iter(struct bio *bio, struct iov_iter iter)
 {
 	int i;
 	struct bio_vec *bvec;
+	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		ssize_t ret;
 
 		ret = copy_page_to_iter(bvec->bv_page,
@@ -1127,8 +1129,9 @@ void bio_free_pages(struct bio *bio)
 {
 	struct bio_vec *bvec;
 	int i;
+	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bvec, bio, i)
+	bio_for_each_segment_all(bvec, bio, i, iter_all)
 		__free_page(bvec->bv_page);
 }
 EXPORT_SYMBOL(bio_free_pages);
@@ -1295,6 +1298,7 @@ struct bio *bio_map_user_iov(struct request_queue *q,
 	struct bio *bio;
 	int ret;
 	struct bio_vec *bvec;
+	struct bvec_iter_all iter_all;
 
 	if (!iov_iter_count(iter))
 		return ERR_PTR(-EINVAL);
@@ -1368,7 +1372,7 @@ struct bio *bio_map_user_iov(struct request_queue *q,
 	return bio;
 
  out_unmap:
-	bio_for_each_segment_all(bvec, bio, j) {
+	bio_for_each_segment_all(bvec, bio, j, iter_all) {
 		put_page(bvec->bv_page);
 	}
 	bio_put(bio);
@@ -1379,11 +1383,12 @@ static void __bio_unmap_user(struct bio *bio)
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
 
@@ -1475,8 +1480,9 @@ static void bio_copy_kern_endio_read(struct bio *bio)
 	char *p = bio->bi_private;
 	struct bio_vec *bvec;
 	int i;
+	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		memcpy(p, page_address(bvec->bv_page), bvec->bv_len);
 		p += bvec->bv_len;
 	}
@@ -1585,8 +1591,9 @@ void bio_set_pages_dirty(struct bio *bio)
 {
 	struct bio_vec *bvec;
 	int i;
+	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		if (!PageCompound(bvec->bv_page))
 			set_page_dirty_lock(bvec->bv_page);
 	}
@@ -1597,8 +1604,9 @@ static void bio_release_pages(struct bio *bio)
 {
 	struct bio_vec *bvec;
 	int i;
+	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bvec, bio, i)
+	bio_for_each_segment_all(bvec, bio, i, iter_all)
 		put_page(bvec->bv_page);
 }
 
@@ -1645,8 +1653,9 @@ void bio_check_pages_dirty(struct bio *bio)
 	struct bio_vec *bvec;
 	unsigned long flags;
 	int i;
+	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		if (!PageDirty(bvec->bv_page) && !PageCompound(bvec->bv_page))
 			goto defer;
 	}
diff --git a/block/bounce.c b/block/bounce.c
index 559c55bda040..7338041e3042 100644
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
@@ -293,6 +294,7 @@ static void __blk_queue_bounce(struct request_queue *q, struct bio **bio_orig,
 	bool bounce = false;
 	int sectors = 0;
 	bool passthrough = bio_is_passthrough(*bio_orig);
+	struct bvec_iter_all iter_all;
 
 	bio_for_each_segment(from, *bio_orig, iter) {
 		if (i++ < BIO_MAX_PAGES)
@@ -312,7 +314,7 @@ static void __blk_queue_bounce(struct request_queue *q, struct bio **bio_orig,
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
index 64ba27b8b754..f8dbfa0b4225 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -197,6 +197,7 @@ __blkdev_direct_IO_simple(struct kiocb *iocb, struct iov_iter *iter,
 	ssize_t ret;
 	blk_qc_t qc;
 	int i;
+	struct bvec_iter_all iter_all;
 
 	if ((pos | iov_iter_alignment(iter)) &
 	    (bdev_logical_block_size(bdev) - 1))
@@ -248,7 +249,7 @@ __blkdev_direct_IO_simple(struct kiocb *iocb, struct iov_iter *iter,
 	}
 	__set_current_state(TASK_RUNNING);
 
-	bio_for_each_segment_all(bvec, &bio, i) {
+	bio_for_each_segment_all(bvec, &bio, i, iter_all) {
 		if (should_dirty && !PageCompound(bvec->bv_page))
 			set_page_dirty_lock(bvec->bv_page);
 		put_page(bvec->bv_page);
@@ -316,8 +317,9 @@ static void blkdev_bio_end_io(struct bio *bio)
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
index 2955a4ea2fa8..602a74c645c3 100644
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
index 169839487ac9..559ab016a33c 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -811,9 +811,10 @@ static blk_status_t btree_csum_one_bio(struct bio *bio)
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
index 40751e86a2a9..87907aba2a25 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -2445,9 +2445,10 @@ static void end_bio_extent_writepage(struct bio *bio)
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
@@ -2516,9 +2517,10 @@ static void end_bio_extent_readpage(struct bio *bio)
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
@@ -3664,9 +3666,10 @@ static void end_bio_extent_buffer_writepage(struct bio *bio)
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
index c576b3fcaea7..47c4013f4d06 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -7819,6 +7819,7 @@ static void btrfs_retry_endio_nocsum(struct bio *bio)
 	struct bio_vec *bvec;
 	struct extent_io_tree *io_tree, *failure_tree;
 	int i;
+	struct bvec_iter_all iter_all;
 
 	if (bio->bi_status)
 		goto end;
@@ -7830,7 +7831,7 @@ static void btrfs_retry_endio_nocsum(struct bio *bio)
 
 	done->uptodate = 1;
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_segment_all(bvec, bio, i)
+	bio_for_each_segment_all(bvec, bio, i, iter_all)
 		clean_io_failure(BTRFS_I(inode)->root->fs_info, failure_tree,
 				 io_tree, done->start, bvec->bv_page,
 				 btrfs_ino(BTRFS_I(inode)), 0);
@@ -7909,6 +7910,7 @@ static void btrfs_retry_endio(struct bio *bio)
 	int uptodate;
 	int ret;
 	int i;
+	struct bvec_iter_all iter_all;
 
 	if (bio->bi_status)
 		goto end;
@@ -7922,7 +7924,7 @@ static void btrfs_retry_endio(struct bio *bio)
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
index c5df035ace6f..1f648d098a3b 100644
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
index 46fd0e03233b..c35997dd02c2 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -128,12 +128,19 @@ static inline bool bio_full(struct bio *bio)
 	return bio->bi_vcnt >= bio->bi_max_vecs;
 }
 
+#define bvec_for_each_segment(bv, bvl, i, iter_all)			\
+	for (bv = bvec_init_iter_all(&iter_all);			\
+		(iter_all.done < (bvl)->bv_len) &&			\
+		(bvec_next_segment((bvl), &iter_all), 1);		\
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
 
 static inline void bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
 				    unsigned bytes)
diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index ca6e630f88ab..94620cf01762 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -45,6 +45,12 @@ struct bvec_iter {
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
@@ -131,6 +137,30 @@ static inline bool bvec_iter_advance(const struct bio_vec *bv,
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
+static inline void bvec_next_segment(const struct bio_vec *bvec,
+				     struct bvec_iter_all *iter_all)
+{
+	struct bio_vec *bv = &iter_all->bv;
+
+	if (bv->bv_page) {
+		bv->bv_page = nth_page(bv->bv_page, 1);
+		bv->bv_offset = 0;
+	} else {
+		bv->bv_page = bvec->bv_page;
+		bv->bv_offset = bvec->bv_offset;
+	}
+	bv->bv_len = min_t(unsigned int, PAGE_SIZE - bv->bv_offset,
+			   bvec->bv_len - iter_all->done);
+}
+
 /*
  * Get the last single-page segment from the multi-page bvec and store it
  * in @seg
-- 
2.9.5
