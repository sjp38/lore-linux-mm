Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 673F76B02A7
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:31:19 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id q67so7035569oig.14
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:31:19 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d6si3740232oib.37.2017.12.18.04.31.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:31:18 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 34/45] btrfs: conver to bio_for_each_page_all2
Date: Mon, 18 Dec 2017 20:22:36 +0800
Message-Id: <20171218122247.3488-35-ming.lei@redhat.com>
In-Reply-To: <20171218122247.3488-1-ming.lei@redhat.com>
References: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

bio_for_each_page_all() can't be used any more after multipage bvec is
enabled, so we have to convert to bio_for_each_page_all2().

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 fs/btrfs/compression.c | 3 ++-
 fs/btrfs/disk-io.c     | 3 ++-
 fs/btrfs/extent_io.c   | 9 ++++++---
 fs/btrfs/inode.c       | 6 ++++--
 4 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
index 1a62725a5f08..f399f298b446 100644
--- a/fs/btrfs/compression.c
+++ b/fs/btrfs/compression.c
@@ -165,13 +165,14 @@ static void end_compressed_bio_read(struct bio *bio)
 	} else {
 		int i;
 		struct bio_vec *bvec;
+		struct bvec_iter_all bia;
 
 		/*
 		 * we have verified the checksum already, set page
 		 * checked so the end_io handlers know about it
 		 */
 		ASSERT(!bio_flagged(bio, BIO_CLONED));
-		bio_for_each_page_all(bvec, cb->orig_bio, i)
+		bio_for_each_page_all2(bvec, cb->orig_bio, i, bia)
 			SetPageChecked(bvec->bv_page);
 
 		bio_endio(cb->orig_bio);
diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index 4f80361fbea9..8f2afdbd0a27 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -803,9 +803,10 @@ static blk_status_t btree_csum_one_bio(struct bio *bio)
 	struct bio_vec *bvec;
 	struct btrfs_root *root;
 	int i, ret = 0;
+	struct bvec_iter_all bia;
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_page_all(bvec, bio, i) {
+	bio_for_each_page_all2(bvec, bio, i, bia) {
 		root = BTRFS_I(bvec->bv_page->mapping->host)->root;
 		ret = csum_dirty_buffer(root->fs_info, bvec->bv_page);
 		if (ret)
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index f466289b66a3..9df1b70cfa9b 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -2451,9 +2451,10 @@ static void end_bio_extent_writepage(struct bio *bio)
 	u64 start;
 	u64 end;
 	int i;
+	struct bvec_iter_all bia;
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_page_all(bvec, bio, i) {
+	bio_for_each_page_all2(bvec, bio, i, bia) {
 		struct page *page = bvec->bv_page;
 		struct inode *inode = page->mapping->host;
 		struct btrfs_fs_info *fs_info = btrfs_sb(inode->i_sb);
@@ -2522,9 +2523,10 @@ static void end_bio_extent_readpage(struct bio *bio)
 	int mirror;
 	int ret;
 	int i;
+	struct bvec_iter_all bia;
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_page_all(bvec, bio, i) {
+	bio_for_each_page_all2(bvec, bio, i, bia) {
 		struct page *page = bvec->bv_page;
 		struct inode *inode = page->mapping->host;
 		struct btrfs_fs_info *fs_info = btrfs_sb(inode->i_sb);
@@ -3682,9 +3684,10 @@ static void end_bio_extent_buffer_writepage(struct bio *bio)
 	struct bio_vec *bvec;
 	struct extent_buffer *eb;
 	int i, done;
+	struct bvec_iter_all bia;
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_page_all(bvec, bio, i) {
+	bio_for_each_page_all2(bvec, bio, i, bia) {
 		struct page *page = bvec->bv_page;
 
 		eb = (struct extent_buffer *)page->private;
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index fda9f2a92f7a..1da401c60b9c 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -8069,6 +8069,7 @@ static void btrfs_retry_endio_nocsum(struct bio *bio)
 	struct bio_vec *bvec;
 	struct extent_io_tree *io_tree, *failure_tree;
 	int i;
+	struct bvec_iter_all bia;
 
 	if (bio->bi_status)
 		goto end;
@@ -8080,7 +8081,7 @@ static void btrfs_retry_endio_nocsum(struct bio *bio)
 
 	done->uptodate = 1;
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_page_all(bvec, bio, i)
+	bio_for_each_page_all2(bvec, bio, i, bia)
 		clean_io_failure(BTRFS_I(inode)->root->fs_info, failure_tree,
 				 io_tree, done->start, bvec->bv_page,
 				 btrfs_ino(BTRFS_I(inode)), 0);
@@ -8159,6 +8160,7 @@ static void btrfs_retry_endio(struct bio *bio)
 	int uptodate;
 	int ret;
 	int i;
+	struct bvec_iter_all bia;
 
 	if (bio->bi_status)
 		goto end;
@@ -8172,7 +8174,7 @@ static void btrfs_retry_endio(struct bio *bio)
 	failure_tree = &BTRFS_I(inode)->io_failure_tree;
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
-	bio_for_each_page_all(bvec, bio, i) {
+	bio_for_each_page_all2(bvec, bio, i, bia) {
 		ret = __readpage_endio_check(inode, io_bio, i, bvec->bv_page,
 					     bvec->bv_offset, done->start,
 					     bvec->bv_len);
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
