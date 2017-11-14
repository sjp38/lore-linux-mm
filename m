Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6DD4E280246
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 16:57:12 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id p44so11179666qtj.17
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 13:57:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x49sor12677872qth.46.2017.11.14.13.57.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 Nov 2017 13:57:11 -0800 (PST)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 10/10] btrfs: rework end io for extent buffer reads
Date: Tue, 14 Nov 2017 16:56:56 -0500
Message-Id: <1510696616-8489-10-git-send-email-josef@toxicpanda.com>
In-Reply-To: <1510696616-8489-1-git-send-email-josef@toxicpanda.com>
References: <1510696616-8489-1-git-send-email-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org
Cc: Josef Bacik <jbacik@fb.com>

From: Josef Bacik <jbacik@fb.com>

Now that the only thing that keeps eb's alive is io_pages and it's
refcount we need to hold the eb ref for the entire end io call so we
don't get it removed out from underneath us.  Also the hooks make no
sense for us now, so rework this to be cleaner.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 fs/btrfs/disk-io.c   | 63 ++++--------------------------------------------
 fs/btrfs/disk-io.h   |  1 +
 fs/btrfs/extent_io.c | 67 +++++++++++++++++++++++++++-------------------------
 3 files changed, 41 insertions(+), 90 deletions(-)

diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index 7ccb6d839126..459491d662a0 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -755,33 +755,13 @@ static int check_node(struct btrfs_root *root, struct extent_buffer *node)
 	return ret;
 }
 
-static int btree_readpage_end_io_hook(struct btrfs_io_bio *io_bio,
-				      u64 phy_offset, struct page *page,
-				      u64 start, u64 end, int mirror)
+int btrfs_extent_buffer_end_read(struct extent_buffer *eb, int mirror)
 {
+	struct btrfs_fs_info *fs_info = eb->eb_info->fs_info;
+	struct btrfs_root *root = fs_info->tree_root;
 	u64 found_start;
 	int found_level;
-	struct extent_buffer *eb;
-	struct btrfs_root *root;
-	struct btrfs_fs_info *fs_info;
 	int ret = 0;
-	int reads_done;
-
-	if (!page->private)
-		goto out;
-
-	eb = (struct extent_buffer *)page->private;
-
-	/* the pending IO might have been the only thing that kept this buffer
-	 * in memory.  Make sure we have a ref for all this other checks
-	 */
-	extent_buffer_get(eb);
-	fs_info = eb->eb_info->fs_info;
-	root = fs_info->tree_root;
-
-	reads_done = atomic_dec_and_test(&eb->io_pages);
-	if (!reads_done)
-		goto err;
 
 	eb->read_mirror = mirror;
 	if (test_bit(EXTENT_BUFFER_READ_ERR, &eb->bflags)) {
@@ -833,45 +813,14 @@ static int btree_readpage_end_io_hook(struct btrfs_io_bio *io_bio,
 	if (!ret)
 		set_extent_buffer_uptodate(eb);
 err:
-	if (reads_done &&
-	    test_and_clear_bit(EXTENT_BUFFER_READAHEAD, &eb->bflags))
+	if (test_and_clear_bit(EXTENT_BUFFER_READAHEAD, &eb->bflags))
 		btree_readahead_hook(eb, ret);
 
-	if (ret) {
-		/*
-		 * our io error hook is going to dec the io pages
-		 * again, we have to make sure it has something
-		 * to decrement.
-		 *
-		 * TODO: Kill this, we've re-arranged how this works now so we
-		 * don't need to do this io_pages dance.
-		 */
-		atomic_inc(&eb->io_pages);
+	if (ret)
 		clear_extent_buffer_uptodate(eb);
-	}
-	if (reads_done) {
-		clear_bit(EXTENT_BUFFER_READING, &eb->bflags);
-		smp_mb__after_atomic();
-		wake_up_bit(&eb->bflags, EXTENT_BUFFER_READING);
-	}
-	free_extent_buffer(eb);
-out:
 	return ret;
 }
 
-static int btree_io_failed_hook(struct page *page, int failed_mirror)
-{
-	struct extent_buffer *eb;
-
-	eb = (struct extent_buffer *)page->private;
-	set_bit(EXTENT_BUFFER_READ_ERR, &eb->bflags);
-	eb->read_mirror = failed_mirror;
-	atomic_dec(&eb->io_pages);
-	if (test_and_clear_bit(EXTENT_BUFFER_READAHEAD, &eb->bflags))
-		btree_readahead_hook(eb, -EIO);
-	return -EIO;	/* we fixed nothing */
-}
-
 static void end_workqueue_bio(struct bio *bio)
 {
 	struct btrfs_end_io_wq *end_io_wq = bio->bi_private;
@@ -4553,9 +4502,7 @@ static int btree_merge_bio_hook(struct page *page, unsigned long offset,
 static const struct extent_io_ops btree_extent_io_ops = {
 	/* mandatory callbacks */
 	.submit_bio_hook = btree_submit_bio_hook,
-	.readpage_end_io_hook = btree_readpage_end_io_hook,
 	.merge_bio_hook = btree_merge_bio_hook,
-	.readpage_io_failed_hook = btree_io_failed_hook,
 	.set_range_writeback = btrfs_set_range_writeback,
 	.tree_fs_info = btree_fs_info,
 
diff --git a/fs/btrfs/disk-io.h b/fs/btrfs/disk-io.h
index 7f7c35d6347a..e1f4fef91547 100644
--- a/fs/btrfs/disk-io.h
+++ b/fs/btrfs/disk-io.h
@@ -152,6 +152,7 @@ int btree_lock_page_hook(struct page *page, void *data,
 int btrfs_get_num_tolerated_disk_barrier_failures(u64 flags);
 int __init btrfs_end_io_wq_init(void);
 void btrfs_end_io_wq_exit(void);
+int btrfs_extent_buffer_end_read(struct extent_buffer *eb, int mirror);
 
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
 void btrfs_init_lockdep(void);
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index 2077bd6ad1b3..1e5affee0f7e 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -20,6 +20,7 @@
 #include "locking.h"
 #include "rcu-string.h"
 #include "backref.h"
+#include "disk-io.h"
 
 static struct kmem_cache *extent_state_cache;
 static struct kmem_cache *extent_buffer_cache;
@@ -5375,6 +5376,15 @@ int extent_buffer_uptodate(struct extent_buffer *eb)
 	return test_bit(EXTENT_BUFFER_UPTODATE, &eb->bflags);
 }
 
+static void mark_eb_failed(struct extent_buffer *eb, int failed_mirror)
+{
+	set_bit(EXTENT_BUFFER_READ_ERR, &eb->bflags);
+	eb->read_mirror = failed_mirror;
+	atomic_dec(&eb->io_pages);
+	if (test_and_clear_bit(EXTENT_BUFFER_READAHEAD, &eb->bflags))
+		btree_readahead_hook(eb, -EIO);
+}
+
 static void end_bio_extent_buffer_readpage(struct bio *bio)
 {
 	struct btrfs_io_bio *io_bio = btrfs_io_bio(bio);
@@ -5383,12 +5393,13 @@ static void end_bio_extent_buffer_readpage(struct bio *bio)
 	u64 unlock_start = 0, unlock_len = 0;
 	int mirror_num = io_bio->mirror_num;
 	int uptodate = !bio->bi_status;
-	int i, ret;
+	int i;
 
 	bio_for_each_segment_all(bvec, bio, i) {
 		struct page *page = bvec->bv_page;
 		struct btrfs_eb_info *eb_info;
 		struct extent_buffer *eb;
+		int reads_done;
 
 		eb = (struct extent_buffer *)page->private;
 		if (WARN_ON(!eb))
@@ -5397,41 +5408,33 @@ static void end_bio_extent_buffer_readpage(struct bio *bio)
 		eb_info = eb->eb_info;
 		if (!tree)
 			tree = &eb_info->io_tree;
+		extent_buffer_get(eb);
+		reads_done = atomic_dec_and_test(&eb->io_pages);
 		if (uptodate) {
-			/*
-			 * btree_readpage_end_io_hook doesn't care about
-			 * start/end so just pass 0.  We'll kill this later.
-			 */
-			ret = tree->ops->readpage_end_io_hook(io_bio, 0,
-							      page, 0, 0,
-							      mirror_num);
-			if (ret) {
-				uptodate = 0;
-			} else {
-				u64 start = eb->start;
-				int c, num_pages;
-
-				num_pages = num_extent_pages(eb->start,
-							     eb->len);
-				for (c = 0; c < num_pages; c++) {
-					if (eb->pages[c] == page)
-						break;
-					start += PAGE_SIZE;
-				}
-				clean_io_failure(eb_info->fs_info,
-						 &eb_info->io_failure_tree,
-						 tree, start, page, 0, 0);
+			u64 start = eb->start;
+			int c, num_pages;
+
+			num_pages = num_extent_pages(eb->start,
+						     eb->len);
+			for (c = 0; c < num_pages; c++) {
+				if (eb->pages[c] == page)
+					break;
+				start += PAGE_SIZE;
 			}
+			clean_io_failure(eb_info->fs_info,
+					 &eb_info->io_failure_tree,
+					 tree, start, page, 0, 0);
 		}
-		/*
-		 * We never fix anything in btree_io_failed_hook.
-		 *
-		 * TODO: rework the io failed hook to not assume we can fix
-		 * anything.
-		 */
+		if (reads_done && btrfs_extent_buffer_end_read(eb, mirror_num))
+			uptodate = 0;
 		if (!uptodate)
-			tree->ops->readpage_io_failed_hook(page, mirror_num);
-
+			mark_eb_failed(eb, mirror_num);
+		if (reads_done) {
+			clear_bit(EXTENT_BUFFER_READING, &eb->bflags);
+			smp_mb__after_atomic();
+			wake_up_bit(&eb->bflags, EXTENT_BUFFER_READING);
+		}
+		free_extent_buffer(eb);
 		if (unlock_start == 0) {
 			unlock_start = eb->start;
 			unlock_len = PAGE_SIZE;
-- 
2.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
