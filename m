Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 072986B3F64
	for <linux-mm@kvack.org>; Sun, 25 Nov 2018 21:17:57 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id y83so17868822qka.7
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 18:17:57 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 46si6267702qtx.375.2018.11.25.18.17.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Nov 2018 18:17:55 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V12 01/20] btrfs: remove various bio_offset arguments
Date: Mon, 26 Nov 2018 10:17:01 +0800
Message-Id: <20181126021720.19471-2-ming.lei@redhat.com>
In-Reply-To: <20181126021720.19471-1-ming.lei@redhat.com>
References: <20181126021720.19471-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

From: Christoph Hellwig <hch@lst.de>

The btrfs write path passes a bio_offset argument through some deep
callchains including async offloading.  In the end this is easily
calculatable using page_offset plus the bvec offset for the first
page in the bio, and only actually used by by a single function.
Just move the calculation of the offset there.

Reviewed-by: David Sterba <dsterba@suse.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/btrfs/disk-io.c   | 21 +++++----------------
 fs/btrfs/disk-io.h   |  2 +-
 fs/btrfs/extent_io.c |  9 ++-------
 fs/btrfs/extent_io.h |  5 ++---
 fs/btrfs/inode.c     | 17 ++++++++---------
 5 files changed, 18 insertions(+), 36 deletions(-)

diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index 3f0b6d1936e8..169839487ac9 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -108,11 +108,6 @@ struct async_submit_bio {
 	struct bio *bio;
 	extent_submit_bio_start_t *submit_bio_start;
 	int mirror_num;
-	/*
-	 * bio_offset is optional, can be used if the pages in the bio
-	 * can't tell us where in the file the bio should go
-	 */
-	u64 bio_offset;
 	struct btrfs_work work;
 	blk_status_t status;
 };
@@ -754,8 +749,7 @@ static void run_one_async_start(struct btrfs_work *work)
 	blk_status_t ret;
 
 	async = container_of(work, struct  async_submit_bio, work);
-	ret = async->submit_bio_start(async->private_data, async->bio,
-				      async->bio_offset);
+	ret = async->submit_bio_start(async->private_data, async->bio);
 	if (ret)
 		async->status = ret;
 }
@@ -786,7 +780,7 @@ static void run_one_async_free(struct btrfs_work *work)
 
 blk_status_t btrfs_wq_submit_bio(struct btrfs_fs_info *fs_info, struct bio *bio,
 				 int mirror_num, unsigned long bio_flags,
-				 u64 bio_offset, void *private_data,
+				 void *private_data,
 				 extent_submit_bio_start_t *submit_bio_start)
 {
 	struct async_submit_bio *async;
@@ -803,8 +797,6 @@ blk_status_t btrfs_wq_submit_bio(struct btrfs_fs_info *fs_info, struct bio *bio,
 	btrfs_init_work(&async->work, btrfs_worker_helper, run_one_async_start,
 			run_one_async_done, run_one_async_free);
 
-	async->bio_offset = bio_offset;
-
 	async->status = 0;
 
 	if (op_is_sync(bio->bi_opf))
@@ -831,8 +823,7 @@ static blk_status_t btree_csum_one_bio(struct bio *bio)
 	return errno_to_blk_status(ret);
 }
 
-static blk_status_t btree_submit_bio_start(void *private_data, struct bio *bio,
-					     u64 bio_offset)
+static blk_status_t btree_submit_bio_start(void *private_data, struct bio *bio)
 {
 	/*
 	 * when we're called for a write, we're already in the async
@@ -853,8 +844,7 @@ static int check_async_write(struct btrfs_inode *bi)
 }
 
 static blk_status_t btree_submit_bio_hook(void *private_data, struct bio *bio,
-					  int mirror_num, unsigned long bio_flags,
-					  u64 bio_offset)
+					  int mirror_num, unsigned long bio_flags)
 {
 	struct inode *inode = private_data;
 	struct btrfs_fs_info *fs_info = btrfs_sb(inode->i_sb);
@@ -882,8 +872,7 @@ static blk_status_t btree_submit_bio_hook(void *private_data, struct bio *bio,
 		 * checksumming can happen in parallel across all CPUs
 		 */
 		ret = btrfs_wq_submit_bio(fs_info, bio, mirror_num, 0,
-					  bio_offset, private_data,
-					  btree_submit_bio_start);
+					  private_data, btree_submit_bio_start);
 	}
 
 	if (ret)
diff --git a/fs/btrfs/disk-io.h b/fs/btrfs/disk-io.h
index 4cccba22640f..b48b3ec353fc 100644
--- a/fs/btrfs/disk-io.h
+++ b/fs/btrfs/disk-io.h
@@ -119,7 +119,7 @@ blk_status_t btrfs_bio_wq_end_io(struct btrfs_fs_info *info, struct bio *bio,
 			enum btrfs_wq_endio_type metadata);
 blk_status_t btrfs_wq_submit_bio(struct btrfs_fs_info *fs_info, struct bio *bio,
 			int mirror_num, unsigned long bio_flags,
-			u64 bio_offset, void *private_data,
+			void *private_data,
 			extent_submit_bio_start_t *submit_bio_start);
 blk_status_t btrfs_submit_bio_done(void *private_data, struct bio *bio,
 			  int mirror_num);
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index d228f706ff3e..15fd46582bb2 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -2397,7 +2397,7 @@ static int bio_readpage_error(struct bio *failed_bio, u64 phy_offset,
 		read_mode, failrec->this_mirror, failrec->in_validation);
 
 	status = tree->ops->submit_bio_hook(tree->private_data, bio, failrec->this_mirror,
-					 failrec->bio_flags, 0);
+					 failrec->bio_flags);
 	if (status) {
 		free_io_failure(failure_tree, tree, failrec);
 		bio_put(bio);
@@ -2719,18 +2719,13 @@ static int __must_check submit_one_bio(struct bio *bio, int mirror_num,
 				       unsigned long bio_flags)
 {
 	blk_status_t ret = 0;
-	struct bio_vec *bvec = bio_last_bvec_all(bio);
-	struct page *page = bvec->bv_page;
 	struct extent_io_tree *tree = bio->bi_private;
-	u64 start;
-
-	start = page_offset(page) + bvec->bv_offset;
 
 	bio->bi_private = NULL;
 
 	if (tree->ops)
 		ret = tree->ops->submit_bio_hook(tree->private_data, bio,
-					   mirror_num, bio_flags, start);
+					   mirror_num, bio_flags);
 	else
 		btrfsic_submit_bio(bio);
 
diff --git a/fs/btrfs/extent_io.h b/fs/btrfs/extent_io.h
index 369daa5d4f73..ea3e1a2206dc 100644
--- a/fs/btrfs/extent_io.h
+++ b/fs/btrfs/extent_io.h
@@ -86,11 +86,10 @@ struct btrfs_io_bio;
 struct io_failure_record;
 
 typedef	blk_status_t (extent_submit_bio_hook_t)(void *private_data, struct bio *bio,
-				       int mirror_num, unsigned long bio_flags,
-				       u64 bio_offset);
+				       int mirror_num, unsigned long bio_flags);
 
 typedef blk_status_t (extent_submit_bio_start_t)(void *private_data,
-		struct bio *bio, u64 bio_offset);
+		struct bio *bio);
 
 struct extent_io_ops {
 	/*
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 9ea4c6f0352f..c576b3fcaea7 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -1920,8 +1920,7 @@ int btrfs_merge_bio_hook(struct page *page, unsigned long offset,
  * At IO completion time the cums attached on the ordered extent record
  * are inserted into the btree
  */
-static blk_status_t btrfs_submit_bio_start(void *private_data, struct bio *bio,
-				    u64 bio_offset)
+static blk_status_t btrfs_submit_bio_start(void *private_data, struct bio *bio)
 {
 	struct inode *inode = private_data;
 	blk_status_t ret = 0;
@@ -1973,8 +1972,7 @@ blk_status_t btrfs_submit_bio_done(void *private_data, struct bio *bio,
  *    c-3) otherwise:			async submit
  */
 static blk_status_t btrfs_submit_bio_hook(void *private_data, struct bio *bio,
-				 int mirror_num, unsigned long bio_flags,
-				 u64 bio_offset)
+				 int mirror_num, unsigned long bio_flags)
 {
 	struct inode *inode = private_data;
 	struct btrfs_fs_info *fs_info = btrfs_sb(inode->i_sb);
@@ -2011,8 +2009,7 @@ static blk_status_t btrfs_submit_bio_hook(void *private_data, struct bio *bio,
 			goto mapit;
 		/* we're doing a write, do the async checksumming */
 		ret = btrfs_wq_submit_bio(fs_info, bio, mirror_num, bio_flags,
-					  bio_offset, inode,
-					  btrfs_submit_bio_start);
+					  inode, btrfs_submit_bio_start);
 		goto out;
 	} else if (!skip_sum) {
 		ret = btrfs_csum_one_bio(inode, bio, 0, 0);
@@ -8123,10 +8120,13 @@ static void btrfs_endio_direct_write(struct bio *bio)
 }
 
 static blk_status_t btrfs_submit_bio_start_direct_io(void *private_data,
-				    struct bio *bio, u64 offset)
+				    struct bio *bio)
 {
 	struct inode *inode = private_data;
+	struct bio_vec *bvec = bio_first_bvec_all(bio);
+	u64 offset = page_offset(bvec->bv_page) + bvec->bv_offset;
 	blk_status_t ret;
+
 	ret = btrfs_csum_one_bio(inode, bio, offset, 1);
 	BUG_ON(ret); /* -ENOMEM */
 	return 0;
@@ -8225,8 +8225,7 @@ static inline blk_status_t btrfs_submit_dio_bio(struct bio *bio,
 		goto map;
 
 	if (write && async_submit) {
-		ret = btrfs_wq_submit_bio(fs_info, bio, 0, 0,
-					  file_offset, inode,
+		ret = btrfs_wq_submit_bio(fs_info, bio, 0, 0, inode,
 					  btrfs_submit_bio_start_direct_io);
 		goto err;
 	} else if (write) {
-- 
2.9.5
