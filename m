Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A2F18E0025
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 03:21:39 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id d31so20385479qtc.4
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 00:21:39 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p68si380512qkc.74.2019.01.21.00.21.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 00:21:37 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V14 13/18] block: allow bio_for_each_segment_all() to iterate over multi-page bvec
Date: Mon, 21 Jan 2019 16:18:00 +0800
Message-Id: <20190121081805.32727-14-ming.lei@redhat.com>
In-Reply-To: <20190121081805.32727-1-ming.lei@redhat.com>
References: <20190121081805.32727-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Ming Lei <ming.lei@redhat.com>

This patch introduces one extra iterator variable to bio_for_each_segment_all(),
then we can allow bio_for_each_segment_all() to iterate over multi-page bvec.

Given it is just one mechannical & simple change on all bio_for_each_segment_all()
users, this patch does tree-wide change in one single patch, so that we can
avoid to use a temporary helper for this conversion.

Reviewed-by: Omar Sandoval <osandov@fb.com>
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
 fs/gfs2/lops.c                    |  9 ++++++---
 fs/gfs2/meta_io.c                 |  3 ++-
 fs/iomap.c                        |  6 ++++--
 fs/mpage.c                        |  3 ++-
 fs/xfs/xfs_aops.c                 |  5 +++--
 include/linux/bio.h               | 11 +++++++++--
 include/linux/bvec.h              | 30 ++++++++++++++++++++++++++++++
 27 files changed, 127 insertions(+), 46 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index 4db1008309ed..968b12fea564 100644
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
@@ -1596,8 +1603,9 @@ static void bio_release_pages(struct bio *bio)
 {
 	struct bio_vec *bvec;
 	int i;
+	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bvec, bio, i)
+	bio_for_each_segment_all(bvec, bio, i, iter_all)
 		put_page(bvec->bv_page);
 }
 
@@ -1644,8 +1652,9 @@ void bio_check_pages_dirty(struct bio *bio)
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
index ffb9e9ecfa7e..add085e28b1d 100644
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
@@ -294,6 +295,7 @@ static void __blk_queue_bounce(struct request_queue *q, struct bio **bio_orig,
 	bool bounce = false;
 	int sectors = 0;
 	bool passthrough = bio_is_passthrough(*bio_orig);
+	struct bvec_iter_all iter_all;
 
 	bio_for_each_segment(from, *bio_orig, iter) {
 		if (i++ < BIO_MAX_PAGES)
@@ -313,7 +315,7 @@ static void __blk_queue_bounce(struct request_queue *q, struct bio **bio_orig,
 	bio = bounce_clone_bio(*bio_orig, GFP_NOIO, passthrough ? NULL :
 			&bounce_bio_set);
 
-	bio_for_each_segment_all(to, bio, i) {
+	bio_for_each_segment_all(to, bio, i, iter_all) {
 		struct page *page = to->bv_page;
 
 		if (page_to_pfn(page) <= q->limits.bounce_pfn)
diff --git a/drivers/md/bcache/btree.c b/drivers/md/bcache/btree.c
index 23cb1dc7296b..64def336f053 100644
--- a/drivers/md/bcache/btree.c
+++ b/drivers/md/bcache/btree.c
@@ -432,8 +432,9 @@ static void do_btree_node_write(struct btree *b)
 		int j;
 		struct bio_vec *bv;
 		void *base = (void *) ((unsigned long) i & ~(PAGE_SIZE - 1));
+		struct bvec_iter_all iter_all;
 
-		bio_for_each_segment_all(bv, b->bio, j)
+		bio_for_each_segment_all(bv, b->bio, j, iter_all)
 			memcpy(page_address(bv->bv_page),
 			       base + j * PAGE_SIZE, PAGE_SIZE);
 
diff --git a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
index 0ff22159a0ca..856df7b959c9 100644
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
index 5a55f0bfdfbb..4871ba7b7d9a 100644
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
index 4ac1099a39c6..c057c5616b1d 100644
--- a/drivers/staging/erofs/unzip_vle.c
+++ b/drivers/staging/erofs/unzip_vle.c
@@ -830,8 +830,9 @@ static inline void z_erofs_vle_read_endio(struct bio *bio)
 #ifdef EROFS_FS_HAS_MANAGED_CACHE
 	struct address_space *mc = NULL;
 #endif
+	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		struct page *page = bvec->bv_page;
 		bool cachemngd = false;
 
diff --git a/fs/block_dev.c b/fs/block_dev.c
index c546cdce77e6..33b6a2f03468 100644
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
@@ -315,8 +316,9 @@ static void blkdev_bio_end_io(struct bio *bio)
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
index 548057630b69..6896ea60c843 100644
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
index 8da2f380d3c0..5cc391fc6a57 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -832,9 +832,10 @@ static blk_status_t btree_csum_one_bio(struct bio *bio)
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
index 986ef49b0269..4ed58c9a94a9 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -2422,9 +2422,10 @@ static void end_bio_extent_writepage(struct bio *bio)
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
@@ -2493,9 +2494,10 @@ static void end_bio_extent_readpage(struct bio *bio)
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
@@ -3635,9 +3637,10 @@ static void end_bio_extent_buffer_writepage(struct bio *bio)
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
index 43eb4535319d..861593ab1cbb 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -7778,6 +7778,7 @@ static void btrfs_retry_endio_nocsum(struct bio *bio)
 	struct bio_vec *bvec;
 	struct extent_io_tree *io_tree, *failure_tree;
 	int i;
+	struct bvec_iter_all iter_all;
 
 	if (bio->bi_status)
 		goto end;
@@ -7789,7 +7790,7 @@ static void btrfs_retry_endio_nocsum(struct bio *bio)
 
 	done->uptodate = 1;
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_segment_all(bvec, bio, i)
+	bio_for_each_segment_all(bvec, bio, i, iter_all)
 		clean_io_failure(BTRFS_I(inode)->root->fs_info, failure_tree,
 				 io_tree, done->start, bvec->bv_page,
 				 btrfs_ino(BTRFS_I(inode)), 0);
@@ -7868,6 +7869,7 @@ static void btrfs_retry_endio(struct bio *bio)
 	int uptodate;
 	int ret;
 	int i;
+	struct bvec_iter_all iter_all;
 
 	if (bio->bi_status)
 		goto end;
@@ -7881,7 +7883,7 @@ static void btrfs_retry_endio(struct bio *bio)
 	failure_tree = &BTRFS_I(inode)->io_failure_tree;
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		ret = __readpage_endio_check(inode, io_bio, i, bvec->bv_page,
 					     bvec->bv_offset, done->start,
 					     bvec->bv_len);
diff --git a/fs/btrfs/raid56.c b/fs/btrfs/raid56.c
index e74455eb42f9..1869ba8e5981 100644
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
index dbc1a1f080ce..47fb973b92e2 100644
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
index 2aa62d58d8dd..cff4c4aa7a9c 100644
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
index 6aa282ee455a..e53639784892 100644
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
index f91d8630c9a2..da060b77f64d 100644
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
index 94dcab655bc0..15deefeaafd0 100644
--- a/fs/gfs2/lops.c
+++ b/fs/gfs2/lops.c
@@ -170,7 +170,8 @@ u64 gfs2_log_bmap(struct gfs2_sbd *sdp)
  * that is pinned in the pagecache.
  */
 
-static void gfs2_end_log_write_bh(struct gfs2_sbd *sdp, struct bio_vec *bvec,
+static void gfs2_end_log_write_bh(struct gfs2_sbd *sdp,
+				  struct bio_vec *bvec,
 				  blk_status_t error)
 {
 	struct buffer_head *bh, *next;
@@ -208,6 +209,7 @@ static void gfs2_end_log_write(struct bio *bio)
 	struct bio_vec *bvec;
 	struct page *page;
 	int i;
+	struct bvec_iter_all iter_all;
 
 	if (bio->bi_status) {
 		fs_err(sdp, "Error %d writing to journal, jid=%u\n",
@@ -215,7 +217,7 @@ static void gfs2_end_log_write(struct bio *bio)
 		wake_up(&sdp->sd_logd_waitq);
 	}
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		page = bvec->bv_page;
 		if (page_has_buffers(page))
 			gfs2_end_log_write_bh(sdp, bvec, bio->bi_status);
@@ -388,8 +390,9 @@ static void gfs2_end_log_read(struct bio *bio)
 	struct page *page;
 	struct bio_vec *bvec;
 	int i;
+	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		page = bvec->bv_page;
 		if (bio->bi_status) {
 			int err = blk_status_to_errno(bio->bi_status);
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
index a3088fae567b..af736acd9006 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -267,8 +267,9 @@ iomap_read_end_io(struct bio *bio)
 	int error = blk_status_to_errno(bio->bi_status);
 	struct bio_vec *bvec;
 	int i;
+	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bvec, bio, i)
+	bio_for_each_segment_all(bvec, bio, i, iter_all)
 		iomap_read_page_end_io(bvec, error);
 	bio_put(bio);
 }
@@ -1559,8 +1560,9 @@ static void iomap_dio_bio_end_io(struct bio *bio)
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
index 730288145568..e6a6f3d78afd 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -128,12 +128,19 @@ static inline bool bio_full(struct bio *bio)
 	return bio->bi_vcnt >= bio->bi_max_vecs;
 }
 
+#define mp_bvec_for_each_segment(bv, bvl, i, iter_all)			\
+	for (bv = bvec_init_iter_all(&iter_all);			\
+		(iter_all.done < (bvl)->bv_len) &&			\
+		(mp_bvec_next_segment((bvl), &iter_all), 1);		\
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
+		mp_bvec_for_each_segment(bvl, &((bio)->bi_io_vec[iter_all.idx]), i, iter_all)
 
 static inline void bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
 				    unsigned bytes)
diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index 21f76bad7be2..30a57b68d017 100644
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
+static inline void mp_bvec_next_segment(const struct bio_vec *bvec,
+					struct bvec_iter_all *iter_all)
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
