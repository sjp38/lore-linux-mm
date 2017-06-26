Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 98DD36B03DB
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:21:42 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id z22so47589865qka.4
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:21:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e18si11521026qtg.64.2017.06.26.05.21.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 05:21:41 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v2 48/51] fs/btrfs: convert to bio_for_each_segment_all_sp()
Date: Mon, 26 Jun 2017 20:10:31 +0800
Message-Id: <20170626121034.3051-49-ming.lei@redhat.com>
In-Reply-To: <20170626121034.3051-1-ming.lei@redhat.com>
References: <20170626121034.3051-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org

Cc: Chris Mason <clm@fb.com>
Cc: Josef Bacik <jbacik@fb.com>
Cc: David Sterba <dsterba@suse.com>
Cc: linux-btrfs@vger.kernel.org
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 fs/btrfs/compression.c |  3 ++-
 fs/btrfs/disk-io.c     |  3 ++-
 fs/btrfs/extent_io.c   | 12 ++++++++----
 fs/btrfs/inode.c       |  6 ++++--
 fs/btrfs/raid56.c      |  6 ++++--
 5 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
index fdab5b821aa8..9d1693ecf468 100644
--- a/fs/btrfs/compression.c
+++ b/fs/btrfs/compression.c
@@ -147,12 +147,13 @@ static void end_compressed_bio_read(struct bio *bio)
 	} else {
 		int i;
 		struct bio_vec *bvec;
+		struct bvec_iter_all bia;
 
 		/*
 		 * we have verified the checksum already, set page
 		 * checked so the end_io handlers know about it
 		 */
-		bio_for_each_segment_all(bvec, cb->orig_bio, i)
+		bio_for_each_segment_all_sp(bvec, cb->orig_bio, i, bia)
 			SetPageChecked(bvec->bv_page);
 
 		bio_endio(cb->orig_bio);
diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index f4f54d13db6d..e7efbaa3566c 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -963,8 +963,9 @@ static blk_status_t btree_csum_one_bio(struct bio *bio)
 	struct bio_vec *bvec;
 	struct btrfs_root *root;
 	int i, ret = 0;
+	struct bvec_iter_all bia;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all_sp(bvec, bio, i, bia) {
 		root = BTRFS_I(bvec->bv_page->mapping->host)->root;
 		ret = csum_dirty_buffer(root->fs_info, bvec->bv_page);
 		if (ret)
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index 7cc6c8a52e49..8e51452894ba 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -2359,8 +2359,9 @@ static unsigned int get_bio_pages(struct bio *bio)
 {
 	unsigned i;
 	struct bio_vec *bv;
+	struct bvec_iter_all bia;
 
-	bio_for_each_segment_all(bv, bio, i)
+	bio_for_each_segment_all_sp(bv, bio, i, bia)
 		;
 
 	return i;
@@ -2468,8 +2469,9 @@ static void end_bio_extent_writepage(struct bio *bio)
 	u64 start;
 	u64 end;
 	int i;
+	struct bvec_iter_all bia;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all_sp(bvec, bio, i, bia) {
 		struct page *page = bvec->bv_page;
 		struct inode *inode = page->mapping->host;
 		struct btrfs_fs_info *fs_info = btrfs_sb(inode->i_sb);
@@ -2538,8 +2540,9 @@ static void end_bio_extent_readpage(struct bio *bio)
 	int mirror;
 	int ret;
 	int i;
+	struct bvec_iter_all bia;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all_sp(bvec, bio, i, bia) {
 		struct page *page = bvec->bv_page;
 		struct inode *inode = page->mapping->host;
 		struct btrfs_fs_info *fs_info = btrfs_sb(inode->i_sb);
@@ -3695,8 +3698,9 @@ static void end_bio_extent_buffer_writepage(struct bio *bio)
 	struct bio_vec *bvec;
 	struct extent_buffer *eb;
 	int i, done;
+	struct bvec_iter_all bia;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all_sp(bvec, bio, i, bia) {
 		struct page *page = bvec->bv_page;
 
 		eb = (struct extent_buffer *)page->private;
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 7e725d84917b..61cc6d899ae5 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -8051,6 +8051,7 @@ static void btrfs_retry_endio_nocsum(struct bio *bio)
 	struct bio_vec *bvec;
 	struct extent_io_tree *io_tree, *failure_tree;
 	int i;
+	struct bvec_iter_all bia;
 
 	if (bio->bi_status)
 		goto end;
@@ -8067,7 +8068,7 @@ static void btrfs_retry_endio_nocsum(struct bio *bio)
 	ASSERT(bio->bi_io_vec->bv_len == btrfs_inode_sectorsize(inode));
 
 	done->uptodate = 1;
-	bio_for_each_segment_all(bvec, bio, i)
+	bio_for_each_segment_all_sp(bvec, bio, i, bia)
 		clean_io_failure(BTRFS_I(inode)->root->fs_info, failure_tree,
 				 io_tree, done->start, bvec->bv_page,
 				 btrfs_ino(BTRFS_I(inode)), 0);
@@ -8146,6 +8147,7 @@ static void btrfs_retry_endio(struct bio *bio)
 	int uptodate;
 	int ret;
 	int i;
+	struct bvec_iter_all bia;
 
 	if (bio->bi_status)
 		goto end;
@@ -8164,7 +8166,7 @@ static void btrfs_retry_endio(struct bio *bio)
 	io_tree = &BTRFS_I(inode)->io_tree;
 	failure_tree = &BTRFS_I(inode)->io_failure_tree;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all_sp(bvec, bio, i, bia) {
 		ret = __readpage_endio_check(inode, io_bio, i, bvec->bv_page,
 					     bvec->bv_offset, done->start,
 					     bvec->bv_len);
diff --git a/fs/btrfs/raid56.c b/fs/btrfs/raid56.c
index 6f845d219cd6..9c68f1c88b40 100644
--- a/fs/btrfs/raid56.c
+++ b/fs/btrfs/raid56.c
@@ -1141,6 +1141,7 @@ static void index_rbio_pages(struct btrfs_raid_bio *rbio)
 	unsigned long stripe_offset;
 	unsigned long page_index;
 	int i;
+	struct bvec_iter_all bia;
 
 	spin_lock_irq(&rbio->bio_list_lock);
 	bio_list_for_each(bio, &rbio->bio_list) {
@@ -1148,7 +1149,7 @@ static void index_rbio_pages(struct btrfs_raid_bio *rbio)
 		stripe_offset = start - rbio->bbio->raid_map[0];
 		page_index = stripe_offset >> PAGE_SHIFT;
 
-		bio_for_each_segment_all(bvec, bio, i)
+		bio_for_each_segment_all_sp(bvec, bio, i, bia)
 			rbio->bio_pages[page_index + i] = bvec->bv_page;
 	}
 	spin_unlock_irq(&rbio->bio_list_lock);
@@ -1425,8 +1426,9 @@ static void set_bio_pages_uptodate(struct bio *bio)
 {
 	struct bio_vec *bvec;
 	int i;
+	struct bvec_iter_all bia;
 
-	bio_for_each_segment_all(bvec, bio, i)
+	bio_for_each_segment_all_sp(bvec, bio, i, bia)
 		SetPageUptodate(bvec->bv_page);
 }
 
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
