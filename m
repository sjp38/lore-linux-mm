Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2C3D5440D03
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 14:31:15 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id y186so4875382qky.20
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 11:31:15 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i25sor5289530qte.30.2017.11.09.11.31.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 Nov 2017 11:31:10 -0800 (PST)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 5/6] Btrfs: kill the btree_inode
Date: Thu,  9 Nov 2017 14:31:00 -0500
Message-Id: <1510255861-8020-5-git-send-email-josef@toxicpanda.com>
In-Reply-To: <1510255861-8020-1-git-send-email-josef@toxicpanda.com>
References: <1510255861-8020-1-git-send-email-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org
Cc: Josef Bacik <jbacik@fb.com>

From: Josef Bacik <jbacik@fb.com>

In order to more efficiently support sub-page blocksizes we need to stop
allocating pages from pagecache for our metadata.  Instead switch to using the
account_metadata* counters for making sure we are keeping the system aware of
how much dirty metadata we have, and use the ->free_cached_objects super
operation in order to handle freeing up extent buffers.  This greatly simplifies
how we deal with extent buffers as now we no longer have to tie the page cache
reclaimation stuff to the extent buffer stuff.  This will also allow us to
simply kmalloc() our data for sub-page blocksizes.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 fs/btrfs/btrfs_inode.h                 |   1 -
 fs/btrfs/ctree.c                       |  18 +-
 fs/btrfs/ctree.h                       |  17 +-
 fs/btrfs/dir-item.c                    |   2 +-
 fs/btrfs/disk-io.c                     | 385 ++++----------
 fs/btrfs/extent-tree.c                 |  14 +-
 fs/btrfs/extent_io.c                   | 919 ++++++++++++++++++---------------
 fs/btrfs/extent_io.h                   |  51 +-
 fs/btrfs/inode.c                       |   6 +-
 fs/btrfs/print-tree.c                  |  13 +-
 fs/btrfs/reada.c                       |   2 +-
 fs/btrfs/root-tree.c                   |   2 +-
 fs/btrfs/super.c                       |  31 +-
 fs/btrfs/tests/btrfs-tests.c           |  36 +-
 fs/btrfs/tests/extent-buffer-tests.c   |   3 +-
 fs/btrfs/tests/extent-io-tests.c       |   4 +-
 fs/btrfs/tests/free-space-tree-tests.c |   3 +-
 fs/btrfs/tests/inode-tests.c           |   4 +-
 fs/btrfs/tests/qgroup-tests.c          |   3 +-
 fs/btrfs/transaction.c                 |  13 +-
 20 files changed, 759 insertions(+), 768 deletions(-)

diff --git a/fs/btrfs/btrfs_inode.h b/fs/btrfs/btrfs_inode.h
index f9c6887a8b6c..24582650622d 100644
--- a/fs/btrfs/btrfs_inode.h
+++ b/fs/btrfs/btrfs_inode.h
@@ -241,7 +241,6 @@ static inline u64 btrfs_ino(const struct btrfs_inode *inode)
 	u64 ino = inode->location.objectid;
 
 	/*
-	 * !ino: btree_inode
 	 * type == BTRFS_ROOT_ITEM_KEY: subvol dir
 	 */
 	if (!ino || inode->location.type == BTRFS_ROOT_ITEM_KEY)
diff --git a/fs/btrfs/ctree.c b/fs/btrfs/ctree.c
index 531e0a8645b0..3c6610b5d0d3 100644
--- a/fs/btrfs/ctree.c
+++ b/fs/btrfs/ctree.c
@@ -1361,7 +1361,8 @@ tree_mod_log_rewind(struct btrfs_fs_info *fs_info, struct btrfs_path *path,
 
 	if (tm->op == MOD_LOG_KEY_REMOVE_WHILE_FREEING) {
 		BUG_ON(tm->slot != 0);
-		eb_rewin = alloc_dummy_extent_buffer(fs_info, eb->start);
+		eb_rewin = alloc_dummy_extent_buffer(fs_info->eb_info,
+						     eb->start, eb->len);
 		if (!eb_rewin) {
 			btrfs_tree_read_unlock_blocking(eb);
 			free_extent_buffer(eb);
@@ -1444,7 +1445,8 @@ get_old_root(struct btrfs_root *root, u64 time_seq)
 	} else if (old_root) {
 		btrfs_tree_read_unlock(eb_root);
 		free_extent_buffer(eb_root);
-		eb = alloc_dummy_extent_buffer(fs_info, logical);
+		eb = alloc_dummy_extent_buffer(root->fs_info->eb_info, logical,
+					       root->fs_info->nodesize);
 	} else {
 		btrfs_set_lock_blocking_rw(eb_root, BTRFS_READ_LOCK);
 		eb = btrfs_clone_extent_buffer(eb_root);
@@ -1675,7 +1677,7 @@ int btrfs_realloc_node(struct btrfs_trans_handle *trans,
 			continue;
 		}
 
-		cur = find_extent_buffer(fs_info, blocknr);
+		cur = find_extent_buffer(fs_info->eb_info, blocknr);
 		if (cur)
 			uptodate = btrfs_buffer_uptodate(cur, gen, 0);
 		else
@@ -1748,7 +1750,7 @@ static noinline int generic_bin_search(struct extent_buffer *eb,
 	int err;
 
 	if (low > high) {
-		btrfs_err(eb->fs_info,
+		btrfs_err(eb->eb_info->fs_info,
 		 "%s: low (%d) > high (%d) eb %llu owner %llu level %d",
 			  __func__, low, high, eb->start,
 			  btrfs_header_owner(eb), btrfs_header_level(eb));
@@ -2260,7 +2262,7 @@ static void reada_for_search(struct btrfs_fs_info *fs_info,
 
 	search = btrfs_node_blockptr(node, slot);
 	blocksize = fs_info->nodesize;
-	eb = find_extent_buffer(fs_info, search);
+	eb = find_extent_buffer(fs_info->eb_info, search);
 	if (eb) {
 		free_extent_buffer(eb);
 		return;
@@ -2319,7 +2321,7 @@ static noinline void reada_for_balance(struct btrfs_fs_info *fs_info,
 	if (slot > 0) {
 		block1 = btrfs_node_blockptr(parent, slot - 1);
 		gen = btrfs_node_ptr_generation(parent, slot - 1);
-		eb = find_extent_buffer(fs_info, block1);
+		eb = find_extent_buffer(fs_info->eb_info, block1);
 		/*
 		 * if we get -eagain from btrfs_buffer_uptodate, we
 		 * don't want to return eagain here.  That will loop
@@ -2332,7 +2334,7 @@ static noinline void reada_for_balance(struct btrfs_fs_info *fs_info,
 	if (slot + 1 < nritems) {
 		block2 = btrfs_node_blockptr(parent, slot + 1);
 		gen = btrfs_node_ptr_generation(parent, slot + 1);
-		eb = find_extent_buffer(fs_info, block2);
+		eb = find_extent_buffer(fs_info->eb_info, block2);
 		if (eb && btrfs_buffer_uptodate(eb, gen, 1) != 0)
 			block2 = 0;
 		free_extent_buffer(eb);
@@ -2450,7 +2452,7 @@ read_block_for_search(struct btrfs_root *root, struct btrfs_path *p,
 	blocknr = btrfs_node_blockptr(b, slot);
 	gen = btrfs_node_ptr_generation(b, slot);
 
-	tmp = find_extent_buffer(fs_info, blocknr);
+	tmp = find_extent_buffer(fs_info->eb_info, blocknr);
 	if (tmp) {
 		/* first we do an atomic uptodate check */
 		if (btrfs_buffer_uptodate(tmp, gen, 1) > 0) {
diff --git a/fs/btrfs/ctree.h b/fs/btrfs/ctree.h
index 4ffbe9f07cf7..a7c764a1ee48 100644
--- a/fs/btrfs/ctree.h
+++ b/fs/btrfs/ctree.h
@@ -40,6 +40,7 @@
 #include <linux/sizes.h>
 #include <linux/dynamic_debug.h>
 #include <linux/refcount.h>
+#include <linux/list_lru.h>
 #include "extent_io.h"
 #include "extent_map.h"
 #include "async-thread.h"
@@ -701,6 +702,7 @@ struct btrfs_device;
 struct btrfs_fs_devices;
 struct btrfs_balance_control;
 struct btrfs_delayed_root;
+struct btrfs_eb_info;
 
 #define BTRFS_FS_BARRIER			1
 #define BTRFS_FS_CLOSING_START			2
@@ -818,7 +820,7 @@ struct btrfs_fs_info {
 	struct btrfs_super_block *super_copy;
 	struct btrfs_super_block *super_for_commit;
 	struct super_block *sb;
-	struct inode *btree_inode;
+	struct btrfs_eb_info *eb_info;
 	struct mutex tree_log_mutex;
 	struct mutex transaction_kthread_mutex;
 	struct mutex cleaner_mutex;
@@ -1060,10 +1062,6 @@ struct btrfs_fs_info {
 	/* readahead works cnt */
 	atomic_t reada_works_cnt;
 
-	/* Extent buffer radix tree */
-	spinlock_t buffer_lock;
-	struct radix_tree_root buffer_radix;
-
 	/* next backup root to be overwritten */
 	int backup_root_index;
 
@@ -1563,7 +1561,7 @@ static inline void btrfs_set_device_total_bytes(struct extent_buffer *eb,
 {
 	BUILD_BUG_ON(sizeof(u64) !=
 		     sizeof(((struct btrfs_dev_item *)0))->total_bytes);
-	WARN_ON(!IS_ALIGNED(val, eb->fs_info->sectorsize));
+	WARN_ON(!IS_ALIGNED(val, eb->eb_info->fs_info->sectorsize));
 	btrfs_set_64(eb, s, offsetof(struct btrfs_dev_item, total_bytes), val);
 }
 
@@ -2962,6 +2960,10 @@ static inline int btrfs_need_cleaner_sleep(struct btrfs_fs_info *fs_info)
 
 static inline void free_fs_info(struct btrfs_fs_info *fs_info)
 {
+	if (fs_info->eb_info) {
+		list_lru_destroy(&fs_info->eb_info->lru_list);
+		kfree(fs_info->eb_info);
+	}
 	kfree(fs_info->balance_ctl);
 	kfree(fs_info->delayed_root);
 	kfree(fs_info->extent_root);
@@ -3185,9 +3187,6 @@ int btrfs_create_subvol_root(struct btrfs_trans_handle *trans,
 			     struct btrfs_root *new_root,
 			     struct btrfs_root *parent_root,
 			     u64 new_dirid);
-int btrfs_merge_bio_hook(struct page *page, unsigned long offset,
-			 size_t size, struct bio *bio,
-			 unsigned long bio_flags);
 void btrfs_set_range_writeback(void *private_data, u64 start, u64 end);
 int btrfs_page_mkwrite(struct vm_fault *vmf);
 int btrfs_readpage(struct file *file, struct page *page);
diff --git a/fs/btrfs/dir-item.c b/fs/btrfs/dir-item.c
index 41cb9196eaa8..f5782523e723 100644
--- a/fs/btrfs/dir-item.c
+++ b/fs/btrfs/dir-item.c
@@ -496,7 +496,7 @@ int verify_dir_item(struct btrfs_fs_info *fs_info,
 bool btrfs_is_name_len_valid(struct extent_buffer *leaf, int slot,
 			     unsigned long start, u16 name_len)
 {
-	struct btrfs_fs_info *fs_info = leaf->fs_info;
+	struct btrfs_fs_info *fs_info = leaf->eb_info->fs_info;
 	struct btrfs_key key;
 	u32 read_start;
 	u32 read_end;
diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index 8b6df7688d52..f53127777783 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -215,56 +215,6 @@ void btrfs_set_buffer_lockdep_class(u64 objectid, struct extent_buffer *eb,
 
 #endif
 
-/*
- * extents on the btree inode are pretty simple, there's one extent
- * that covers the entire device
- */
-static struct extent_map *btree_get_extent(struct btrfs_inode *inode,
-		struct page *page, size_t pg_offset, u64 start, u64 len,
-		int create)
-{
-	struct btrfs_fs_info *fs_info = btrfs_sb(inode->vfs_inode.i_sb);
-	struct extent_map_tree *em_tree = &inode->extent_tree;
-	struct extent_map *em;
-	int ret;
-
-	read_lock(&em_tree->lock);
-	em = lookup_extent_mapping(em_tree, start, len);
-	if (em) {
-		em->bdev = fs_info->fs_devices->latest_bdev;
-		read_unlock(&em_tree->lock);
-		goto out;
-	}
-	read_unlock(&em_tree->lock);
-
-	em = alloc_extent_map();
-	if (!em) {
-		em = ERR_PTR(-ENOMEM);
-		goto out;
-	}
-	em->start = 0;
-	em->len = (u64)-1;
-	em->block_len = (u64)-1;
-	em->block_start = 0;
-	em->bdev = fs_info->fs_devices->latest_bdev;
-
-	write_lock(&em_tree->lock);
-	ret = add_extent_mapping(em_tree, em, 0);
-	if (ret == -EEXIST) {
-		free_extent_map(em);
-		em = lookup_extent_mapping(em_tree, start, len);
-		if (!em)
-			em = ERR_PTR(-EIO);
-	} else if (ret) {
-		free_extent_map(em);
-		em = ERR_PTR(ret);
-	}
-	write_unlock(&em_tree->lock);
-
-out:
-	return em;
-}
-
 u32 btrfs_csum_data(const char *data, u32 seed, size_t len)
 {
 	return btrfs_crc32c(seed, data, len);
@@ -346,11 +296,11 @@ static int csum_tree_block(struct btrfs_fs_info *fs_info,
  * detect blocks that either didn't get written at all or got written
  * in the wrong place.
  */
-static int verify_parent_transid(struct extent_io_tree *io_tree,
-				 struct extent_buffer *eb, u64 parent_transid,
+static int verify_parent_transid(struct extent_buffer *eb, u64 parent_transid,
 				 int atomic)
 {
 	struct extent_state *cached_state = NULL;
+	struct extent_io_tree *io_tree = &eb->eb_info->io_tree;
 	int ret;
 	bool need_lock = (current->journal_info == BTRFS_SEND_TRANS_STUB);
 
@@ -372,7 +322,7 @@ static int verify_parent_transid(struct extent_io_tree *io_tree,
 		ret = 0;
 		goto out;
 	}
-	btrfs_err_rl(eb->fs_info,
+	btrfs_err_rl(eb->eb_info->fs_info,
 		"parent transid verify failed on %llu wanted %llu found %llu",
 			eb->start,
 			parent_transid, btrfs_header_generation(eb));
@@ -443,7 +393,6 @@ static int btree_read_extent_buffer_pages(struct btrfs_fs_info *fs_info,
 					  struct extent_buffer *eb,
 					  u64 parent_transid)
 {
-	struct extent_io_tree *io_tree;
 	int failed = 0;
 	int ret;
 	int num_copies = 0;
@@ -451,13 +400,10 @@ static int btree_read_extent_buffer_pages(struct btrfs_fs_info *fs_info,
 	int failed_mirror = 0;
 
 	clear_bit(EXTENT_BUFFER_CORRUPT, &eb->bflags);
-	io_tree = &BTRFS_I(fs_info->btree_inode)->io_tree;
 	while (1) {
-		ret = read_extent_buffer_pages(io_tree, eb, WAIT_COMPLETE,
-					       btree_get_extent, mirror_num);
+		ret = read_extent_buffer_pages(eb, WAIT_COMPLETE, mirror_num);
 		if (!ret) {
-			if (!verify_parent_transid(io_tree, eb,
-						   parent_transid, 0))
+			if (!verify_parent_transid(eb, parent_transid, 0))
 				break;
 			else
 				ret = -EIO;
@@ -502,24 +448,11 @@ static int btree_read_extent_buffer_pages(struct btrfs_fs_info *fs_info,
 
 static int csum_dirty_buffer(struct btrfs_fs_info *fs_info, struct page *page)
 {
-	u64 start = page_offset(page);
-	u64 found_start;
 	struct extent_buffer *eb;
 
 	eb = (struct extent_buffer *)page->private;
 	if (page != eb->pages[0])
 		return 0;
-
-	found_start = btrfs_header_bytenr(eb);
-	/*
-	 * Please do not consolidate these warnings into a single if.
-	 * It is useful to know what went wrong.
-	 */
-	if (WARN_ON(found_start != start))
-		return -EUCLEAN;
-	if (WARN_ON(!PageUptodate(page)))
-		return -EUCLEAN;
-
 	ASSERT(memcmp_extent_buffer(eb, fs_info->fsid,
 			btrfs_header_fsid(), BTRFS_FSID_SIZE) == 0);
 
@@ -829,8 +762,8 @@ static int btree_readpage_end_io_hook(struct btrfs_io_bio *io_bio,
 	u64 found_start;
 	int found_level;
 	struct extent_buffer *eb;
-	struct btrfs_root *root = BTRFS_I(page->mapping->host)->root;
-	struct btrfs_fs_info *fs_info = root->fs_info;
+	struct btrfs_root *root;
+	struct btrfs_fs_info *fs_info;
 	int ret = 0;
 	int reads_done;
 
@@ -843,6 +776,8 @@ static int btree_readpage_end_io_hook(struct btrfs_io_bio *io_bio,
 	 * in memory.  Make sure we have a ref for all this other checks
 	 */
 	extent_buffer_get(eb);
+	fs_info = eb->eb_info->fs_info;
+	root = fs_info->tree_root;
 
 	reads_done = atomic_dec_and_test(&eb->io_pages);
 	if (!reads_done)
@@ -906,11 +841,19 @@ static int btree_readpage_end_io_hook(struct btrfs_io_bio *io_bio,
 		/*
 		 * our io error hook is going to dec the io pages
 		 * again, we have to make sure it has something
-		 * to decrement
+		 * to decrement.
+		 *
+		 * TODO: Kill this, we've re-arranged how this works now so we
+		 * don't need to do this io_pages dance.
 		 */
 		atomic_inc(&eb->io_pages);
 		clear_extent_buffer_uptodate(eb);
 	}
+	if (reads_done) {
+		clear_bit(EXTENT_BUFFER_READING, &eb->bflags);
+		smp_mb__after_atomic();
+		wake_up_bit(&eb->bflags, EXTENT_BUFFER_READING);
+	}
 	free_extent_buffer(eb);
 out:
 	return ret;
@@ -1075,16 +1018,14 @@ blk_status_t btrfs_wq_submit_bio(struct btrfs_fs_info *fs_info, struct bio *bio,
 	return 0;
 }
 
-static blk_status_t btree_csum_one_bio(struct bio *bio)
+static blk_status_t btree_csum_one_bio(struct btrfs_fs_info *fs_info, struct bio *bio)
 {
 	struct bio_vec *bvec;
-	struct btrfs_root *root;
 	int i, ret = 0;
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
 	bio_for_each_segment_all(bvec, bio, i) {
-		root = BTRFS_I(bvec->bv_page->mapping->host)->root;
-		ret = csum_dirty_buffer(root->fs_info, bvec->bv_page);
+		ret = csum_dirty_buffer(fs_info, bvec->bv_page);
 		if (ret)
 			break;
 	}
@@ -1096,25 +1037,26 @@ static blk_status_t __btree_submit_bio_start(void *private_data, struct bio *bio
 					     int mirror_num, unsigned long bio_flags,
 					     u64 bio_offset)
 {
+	struct btrfs_eb_info *eb_info = private_data;
 	/*
 	 * when we're called for a write, we're already in the async
 	 * submission context.  Just jump into btrfs_map_bio
 	 */
-	return btree_csum_one_bio(bio);
+	return btree_csum_one_bio(eb_info->fs_info, bio);
 }
 
 static blk_status_t __btree_submit_bio_done(void *private_data, struct bio *bio,
 					    int mirror_num, unsigned long bio_flags,
 					    u64 bio_offset)
 {
-	struct inode *inode = private_data;
-	blk_status_t ret;
+	struct btrfs_eb_info *eb_info = private_data;
+	int ret;
 
 	/*
 	 * when we're called for a write, we're already in the async
 	 * submission context.  Just jump into btrfs_map_bio
 	 */
-	ret = btrfs_map_bio(btrfs_sb(inode->i_sb), bio, mirror_num, 1);
+	ret = btrfs_map_bio(eb_info->fs_info, bio, mirror_num, 1);
 	if (ret) {
 		bio->bi_status = ret;
 		bio_endio(bio);
@@ -1122,9 +1064,9 @@ static blk_status_t __btree_submit_bio_done(void *private_data, struct bio *bio,
 	return ret;
 }
 
-static int check_async_write(struct btrfs_inode *bi)
+static int check_async_write(void)
 {
-	if (atomic_read(&bi->sync_writers))
+	if (current->journal_info)
 		return 0;
 #ifdef CONFIG_X86
 	if (static_cpu_has(X86_FEATURE_XMM4_2))
@@ -1137,9 +1079,9 @@ static blk_status_t btree_submit_bio_hook(void *private_data, struct bio *bio,
 					  int mirror_num, unsigned long bio_flags,
 					  u64 bio_offset)
 {
-	struct inode *inode = private_data;
-	struct btrfs_fs_info *fs_info = btrfs_sb(inode->i_sb);
-	int async = check_async_write(BTRFS_I(inode));
+	struct btrfs_eb_info *eb_info = private_data;
+	struct btrfs_fs_info *fs_info = eb_info->fs_info;
+	int async = check_async_write();
 	blk_status_t ret;
 
 	if (bio_op(bio) != REQ_OP_WRITE) {
@@ -1153,7 +1095,7 @@ static blk_status_t btree_submit_bio_hook(void *private_data, struct bio *bio,
 			goto out_w_error;
 		ret = btrfs_map_bio(fs_info, bio, mirror_num, 0);
 	} else if (!async) {
-		ret = btree_csum_one_bio(bio);
+		ret = btree_csum_one_bio(eb_info->fs_info, bio);
 		if (ret)
 			goto out_w_error;
 		ret = btrfs_map_bio(fs_info, bio, mirror_num, 0);
@@ -1178,118 +1120,14 @@ static blk_status_t btree_submit_bio_hook(void *private_data, struct bio *bio,
 	return ret;
 }
 
-#ifdef CONFIG_MIGRATION
-static int btree_migratepage(struct address_space *mapping,
-			struct page *newpage, struct page *page,
-			enum migrate_mode mode)
-{
-	/*
-	 * we can't safely write a btree page from here,
-	 * we haven't done the locking hook
-	 */
-	if (PageDirty(page))
-		return -EAGAIN;
-	/*
-	 * Buffers may be managed in a filesystem specific way.
-	 * We must have no buffers or drop them.
-	 */
-	if (page_has_private(page) &&
-	    !try_to_release_page(page, GFP_KERNEL))
-		return -EAGAIN;
-	return migrate_page(mapping, newpage, page, mode);
-}
-#endif
-
-
-static int btree_writepages(struct address_space *mapping,
-			    struct writeback_control *wbc)
-{
-	struct btrfs_fs_info *fs_info;
-	int ret;
-
-	if (wbc->sync_mode == WB_SYNC_NONE) {
-
-		if (wbc->for_kupdate)
-			return 0;
-
-		fs_info = BTRFS_I(mapping->host)->root->fs_info;
-		/* this is a bit racy, but that's ok */
-		ret = percpu_counter_compare(&fs_info->dirty_metadata_bytes,
-					     BTRFS_DIRTY_METADATA_THRESH);
-		if (ret < 0)
-			return 0;
-	}
-	return btree_write_cache_pages(mapping, wbc);
-}
-
-static int btree_readpage(struct file *file, struct page *page)
-{
-	struct extent_io_tree *tree;
-	tree = &BTRFS_I(page->mapping->host)->io_tree;
-	return extent_read_full_page(tree, page, btree_get_extent, 0);
-}
-
-static int btree_releasepage(struct page *page, gfp_t gfp_flags)
-{
-	if (PageWriteback(page) || PageDirty(page))
-		return 0;
-
-	return try_release_extent_buffer(page);
-}
-
-static void btree_invalidatepage(struct page *page, unsigned int offset,
-				 unsigned int length)
-{
-	struct extent_io_tree *tree;
-	tree = &BTRFS_I(page->mapping->host)->io_tree;
-	extent_invalidatepage(tree, page, offset);
-	btree_releasepage(page, GFP_NOFS);
-	if (PagePrivate(page)) {
-		btrfs_warn(BTRFS_I(page->mapping->host)->root->fs_info,
-			   "page private not zero on page %llu",
-			   (unsigned long long)page_offset(page));
-		ClearPagePrivate(page);
-		set_page_private(page, 0);
-		put_page(page);
-	}
-}
-
-static int btree_set_page_dirty(struct page *page)
-{
-#ifdef DEBUG
-	struct extent_buffer *eb;
-
-	BUG_ON(!PagePrivate(page));
-	eb = (struct extent_buffer *)page->private;
-	BUG_ON(!eb);
-	BUG_ON(!test_bit(EXTENT_BUFFER_DIRTY, &eb->bflags));
-	BUG_ON(!atomic_read(&eb->refs));
-	btrfs_assert_tree_locked(eb);
-#endif
-	return __set_page_dirty_nobuffers(page);
-}
-
-static const struct address_space_operations btree_aops = {
-	.readpage	= btree_readpage,
-	.writepages	= btree_writepages,
-	.releasepage	= btree_releasepage,
-	.invalidatepage = btree_invalidatepage,
-#ifdef CONFIG_MIGRATION
-	.migratepage	= btree_migratepage,
-#endif
-	.set_page_dirty = btree_set_page_dirty,
-};
-
 void readahead_tree_block(struct btrfs_fs_info *fs_info, u64 bytenr)
 {
 	struct extent_buffer *buf = NULL;
-	struct inode *btree_inode = fs_info->btree_inode;
 
 	buf = btrfs_find_create_tree_block(fs_info, bytenr);
 	if (IS_ERR(buf))
 		return;
-	read_extent_buffer_pages(&BTRFS_I(btree_inode)->io_tree,
-				 buf, WAIT_NONE, btree_get_extent, 0);
+	read_extent_buffer_pages(buf, WAIT_NONE, 0);
 	free_extent_buffer(buf);
 }
 
@@ -1297,8 +1135,6 @@ int reada_tree_block_flagged(struct btrfs_fs_info *fs_info, u64 bytenr,
 			 int mirror_num, struct extent_buffer **eb)
 {
 	struct extent_buffer *buf = NULL;
-	struct inode *btree_inode = fs_info->btree_inode;
-	struct extent_io_tree *io_tree = &BTRFS_I(btree_inode)->io_tree;
 	int ret;
 
 	buf = btrfs_find_create_tree_block(fs_info, bytenr);
@@ -1307,8 +1143,7 @@ int reada_tree_block_flagged(struct btrfs_fs_info *fs_info, u64 bytenr,
 
 	set_bit(EXTENT_BUFFER_READAHEAD, &buf->bflags);
 
-	ret = read_extent_buffer_pages(io_tree, buf, WAIT_PAGE_LOCK,
-				       btree_get_extent, mirror_num);
+	ret = read_extent_buffer_pages(buf, WAIT_PAGE_LOCK, mirror_num);
 	if (ret) {
 		free_extent_buffer(buf);
 		return ret;
@@ -1330,21 +1165,22 @@ struct extent_buffer *btrfs_find_create_tree_block(
 						u64 bytenr)
 {
 	if (btrfs_is_testing(fs_info))
-		return alloc_test_extent_buffer(fs_info, bytenr);
+		return alloc_test_extent_buffer(fs_info->eb_info, bytenr,
+						fs_info->nodesize);
 	return alloc_extent_buffer(fs_info, bytenr);
 }
 
 
 int btrfs_write_tree_block(struct extent_buffer *buf)
 {
-	return filemap_fdatawrite_range(buf->pages[0]->mapping, buf->start,
-					buf->start + buf->len - 1);
+	return btree_write_range(buf->eb_info->fs_info, buf->start,
+				 buf->start + buf->len - 1);
 }
 
 void btrfs_wait_tree_block_writeback(struct extent_buffer *buf)
 {
-	filemap_fdatawait_range(buf->pages[0]->mapping,
-			        buf->start, buf->start + buf->len - 1);
+	btree_wait_range(buf->eb_info->fs_info, buf->start,
+			 buf->start + buf->len - 1);
 }
 
 struct extent_buffer *read_tree_block(struct btrfs_fs_info *fs_info, u64 bytenr,
@@ -1372,15 +1208,10 @@ void clean_tree_block(struct btrfs_fs_info *fs_info,
 	if (btrfs_header_generation(buf) ==
 	    fs_info->running_transaction->transid) {
 		btrfs_assert_tree_locked(buf);
-
-		if (test_and_clear_bit(EXTENT_BUFFER_DIRTY, &buf->bflags)) {
+		if (clear_extent_buffer_dirty(buf))
 			percpu_counter_add_batch(&fs_info->dirty_metadata_bytes,
 						 -buf->len,
 						 fs_info->dirty_metadata_batch);
-			/* ugh, clear_extent_buffer_dirty needs to lock the page */
-			btrfs_set_lock_blocking(buf);
-			clear_extent_buffer_dirty(buf);
-		}
 	}
 }
 
@@ -2412,31 +2243,20 @@ static void btrfs_init_balance(struct btrfs_fs_info *fs_info)
 	init_waitqueue_head(&fs_info->balance_wait_q);
 }
 
-static void btrfs_init_btree_inode(struct btrfs_fs_info *fs_info)
+int btrfs_init_eb_info(struct btrfs_fs_info *fs_info)
 {
-	struct inode *inode = fs_info->btree_inode;
-
-	inode->i_ino = BTRFS_BTREE_INODE_OBJECTID;
-	set_nlink(inode, 1);
-	/*
-	 * we set the i_size on the btree inode to the max possible int.
-	 * the real end of the address space is determined by all of
-	 * the devices in the system
-	 */
-	inode->i_size = OFFSET_MAX;
-	inode->i_mapping->a_ops = &btree_aops;
-
-	RB_CLEAR_NODE(&BTRFS_I(inode)->rb_node);
-	extent_io_tree_init(&BTRFS_I(inode)->io_tree, inode);
-	BTRFS_I(inode)->io_tree.track_uptodate = 0;
-	extent_map_tree_init(&BTRFS_I(inode)->extent_tree);
-
-	BTRFS_I(inode)->io_tree.ops = &btree_extent_io_ops;
-
-	BTRFS_I(inode)->root = fs_info->tree_root;
-	memset(&BTRFS_I(inode)->location, 0, sizeof(struct btrfs_key));
-	set_bit(BTRFS_INODE_DUMMY, &BTRFS_I(inode)->runtime_flags);
-	btrfs_insert_inode_hash(inode);
+	struct btrfs_eb_info *eb_info = fs_info->eb_info;
+
+	eb_info->fs_info = fs_info;
+	extent_io_tree_init(&eb_info->io_tree, eb_info);
+	eb_info->io_tree.track_uptodate = 0;
+	eb_info->io_tree.ops = &btree_extent_io_ops;
+	extent_io_tree_init(&eb_info->io_failure_tree, eb_info);
+	INIT_RADIX_TREE(&eb_info->buffer_radix, GFP_ATOMIC);
+	spin_lock_init(&eb_info->buffer_lock);
+	if (list_lru_init(&eb_info->lru_list))
+		return -ENOMEM;
+	return 0;
 }
 
 static void btrfs_init_dev_replace_locks(struct btrfs_fs_info *fs_info)
@@ -2725,7 +2545,6 @@ int open_ctree(struct super_block *sb,
 	}
 
 	INIT_RADIX_TREE(&fs_info->fs_roots_radix, GFP_ATOMIC);
-	INIT_RADIX_TREE(&fs_info->buffer_radix, GFP_ATOMIC);
 	INIT_LIST_HEAD(&fs_info->trans_list);
 	INIT_LIST_HEAD(&fs_info->dead_roots);
 	INIT_LIST_HEAD(&fs_info->delayed_iputs);
@@ -2739,7 +2558,6 @@ int open_ctree(struct super_block *sb,
 	spin_lock_init(&fs_info->tree_mod_seq_lock);
 	spin_lock_init(&fs_info->super_lock);
 	spin_lock_init(&fs_info->qgroup_op_lock);
-	spin_lock_init(&fs_info->buffer_lock);
 	spin_lock_init(&fs_info->unused_bgs_lock);
 	rwlock_init(&fs_info->tree_mod_log_lock);
 	mutex_init(&fs_info->unused_bg_unpin_mutex);
@@ -2785,18 +2603,11 @@ int open_ctree(struct super_block *sb,
 	INIT_LIST_HEAD(&fs_info->ordered_roots);
 	spin_lock_init(&fs_info->ordered_root_lock);
 
-	fs_info->btree_inode = new_inode(sb);
-	if (!fs_info->btree_inode) {
-		err = -ENOMEM;
-		goto fail_bio_counter;
-	}
-	mapping_set_gfp_mask(fs_info->btree_inode->i_mapping, GFP_NOFS);
-
 	fs_info->delayed_root = kmalloc(sizeof(struct btrfs_delayed_root),
 					GFP_KERNEL);
 	if (!fs_info->delayed_root) {
 		err = -ENOMEM;
-		goto fail_iput;
+		goto fail_alloc;
 	}
 	btrfs_init_delayed_root(fs_info->delayed_root);
 
@@ -2810,7 +2621,15 @@ int open_ctree(struct super_block *sb,
 	sb->s_blocksize = BTRFS_BDEV_BLOCKSIZE;
 	sb->s_blocksize_bits = blksize_bits(BTRFS_BDEV_BLOCKSIZE);
 
-	btrfs_init_btree_inode(fs_info);
+	fs_info->eb_info = kzalloc(sizeof(struct btrfs_eb_info), GFP_KERNEL);
+	if (!fs_info->eb_info) {
+		err = -ENOMEM;
+		goto fail_alloc;
+	}
+	if (btrfs_init_eb_info(fs_info)) {
+		err = -ENOMEM;
+		goto fail_alloc;
+	}
 
 	spin_lock_init(&fs_info->block_group_cache_lock);
 	fs_info->block_group_cache_tree = RB_ROOT;
@@ -3243,6 +3062,14 @@ int open_ctree(struct super_block *sb,
 	if (sb_rdonly(sb))
 		return 0;
 
+	/*
+	 * We need to make sure we are on the bdi's dirty list so we get
+	 * writeback requests for our fs properly.
+	 */
+	spin_lock(&sb->s_bdi->sb_list_lock);
+	list_add_tail(&sb->s_bdi->dirty_sb_list, &sb->s_bdi_list);
+	spin_unlock(&sb->s_bdi->sb_list_lock);
+
 	if (btrfs_test_opt(fs_info, CLEAR_CACHE) &&
 	    btrfs_fs_compat_ro(fs_info, FREE_SPACE_TREE)) {
 		clear_free_space_tree = 1;
@@ -3346,7 +3173,8 @@ int open_ctree(struct super_block *sb,
 	 * make sure we're done with the btree inode before we stop our
 	 * kthreads
 	 */
-	filemap_write_and_wait(fs_info->btree_inode->i_mapping);
+	btree_write_range(fs_info, 0, (u64)-1);
+	btree_wait_range(fs_info, 0, (u64)-1);
 
 fail_sysfs:
 	btrfs_sysfs_remove_mounted(fs_info);
@@ -3359,17 +3187,12 @@ int open_ctree(struct super_block *sb,
 
 fail_tree_roots:
 	free_root_pointers(fs_info, 1);
-	invalidate_inode_pages2(fs_info->btree_inode->i_mapping);
-
+	btrfs_invalidate_eb_info(fs_info->eb_info);
 fail_sb_buffer:
 	btrfs_stop_all_workers(fs_info);
 	btrfs_free_block_groups(fs_info);
 fail_alloc:
-fail_iput:
 	btrfs_mapping_tree_free(&fs_info->mapping_tree);
-
-	iput(fs_info->btree_inode);
-fail_bio_counter:
 	percpu_counter_destroy(&fs_info->bio_counter);
 fail_delalloc_bytes:
 	percpu_counter_destroy(&fs_info->delalloc_bytes);
@@ -4041,7 +3864,6 @@ void close_ctree(struct btrfs_fs_info *fs_info)
 	 * we must make sure there is not any read request to
 	 * submit after we stopping all workers.
 	 */
-	invalidate_inode_pages2(fs_info->btree_inode->i_mapping);
 	btrfs_stop_all_workers(fs_info);
 
 	btrfs_free_block_groups(fs_info);
@@ -4049,8 +3871,6 @@ void close_ctree(struct btrfs_fs_info *fs_info)
 	clear_bit(BTRFS_FS_OPEN, &fs_info->flags);
 	free_root_pointers(fs_info, 1);
 
-	iput(fs_info->btree_inode);
-
 #ifdef CONFIG_BTRFS_FS_CHECK_INTEGRITY
 	if (btrfs_test_opt(fs_info, CHECK_INTEGRITY))
 		btrfsic_unmount(fs_info->fs_devices);
@@ -4059,6 +3879,8 @@ void close_ctree(struct btrfs_fs_info *fs_info)
 	btrfs_close_devices(fs_info->fs_devices);
 	btrfs_mapping_tree_free(&fs_info->mapping_tree);
 
+	btrfs_invalidate_eb_info(fs_info->eb_info);
+
 	percpu_counter_destroy(&fs_info->dirty_metadata_bytes);
 	percpu_counter_destroy(&fs_info->delalloc_bytes);
 	percpu_counter_destroy(&fs_info->bio_counter);
@@ -4084,14 +3906,12 @@ int btrfs_buffer_uptodate(struct extent_buffer *buf, u64 parent_transid,
 			  int atomic)
 {
 	int ret;
-	struct inode *btree_inode = buf->pages[0]->mapping->host;
 
 	ret = extent_buffer_uptodate(buf);
 	if (!ret)
 		return ret;
 
-	ret = verify_parent_transid(&BTRFS_I(btree_inode)->io_tree, buf,
-				    parent_transid, atomic);
+	ret = verify_parent_transid(buf, parent_transid, atomic);
 	if (ret == -EAGAIN)
 		return ret;
 	return !ret;
@@ -4113,8 +3933,8 @@ void btrfs_mark_buffer_dirty(struct extent_buffer *buf)
 	if (unlikely(test_bit(EXTENT_BUFFER_DUMMY, &buf->bflags)))
 		return;
 #endif
-	root = BTRFS_I(buf->pages[0]->mapping->host)->root;
-	fs_info = root->fs_info;
+	fs_info = buf->eb_info->fs_info;
+	root = fs_info->tree_root;
 	btrfs_assert_tree_locked(buf);
 	if (transid != fs_info->generation)
 		WARN(1, KERN_CRIT "btrfs transid mismatch buffer %llu, found %llu running %llu\n",
@@ -4140,6 +3960,7 @@ static void __btrfs_btree_balance_dirty(struct btrfs_fs_info *fs_info,
 	 * this code, they end up stuck in balance_dirty_pages forever
 	 */
 	int ret;
+	struct super_block *sb = fs_info->sb;
 
 	if (current->flags & PF_MEMALLOC)
 		return;
@@ -4149,10 +3970,8 @@ static void __btrfs_btree_balance_dirty(struct btrfs_fs_info *fs_info,
 
 	ret = percpu_counter_compare(&fs_info->dirty_metadata_bytes,
 				     BTRFS_DIRTY_METADATA_THRESH);
-	if (ret > 0) {
-		balance_dirty_pages_ratelimited(fs_info->sb->s_bdi,
-						fs_info->sb);
-	}
+	if (ret > 0)
+		balance_dirty_pages_ratelimited(sb->s_bdi, sb);
 }
 
 void btrfs_btree_balance_dirty(struct btrfs_fs_info *fs_info)
@@ -4167,9 +3986,7 @@ void btrfs_btree_balance_dirty_nodelay(struct btrfs_fs_info *fs_info)
 
 int btrfs_read_buffer(struct extent_buffer *buf, u64 parent_transid)
 {
-	struct btrfs_root *root = BTRFS_I(buf->pages[0]->mapping->host)->root;
-	struct btrfs_fs_info *fs_info = root->fs_info;
-
+	struct btrfs_fs_info *fs_info = buf->eb_info->fs_info;
 	return btree_read_extent_buffer_pages(fs_info, buf, parent_transid);
 }
 
@@ -4513,15 +4330,12 @@ static int btrfs_destroy_marked_extents(struct btrfs_fs_info *fs_info,
 
 		clear_extent_bits(dirty_pages, start, end, mark);
 		while (start <= end) {
-			eb = find_extent_buffer(fs_info, start);
+			eb = find_extent_buffer(fs_info->eb_info, start);
 			start += fs_info->nodesize;
 			if (!eb)
 				continue;
 			wait_on_extent_buffer_writeback(eb);
-
-			if (test_and_clear_bit(EXTENT_BUFFER_DIRTY,
-					       &eb->bflags))
-				clear_extent_buffer_dirty(eb);
+			clear_extent_buffer_dirty(eb);
 			free_extent_buffer_stale(eb);
 		}
 	}
@@ -4710,16 +4524,37 @@ static int btrfs_cleanup_transaction(struct btrfs_fs_info *fs_info)
 
 static struct btrfs_fs_info *btree_fs_info(void *private_data)
 {
-	struct inode *inode = private_data;
-	return btrfs_sb(inode->i_sb);
+	struct btrfs_eb_info *eb_info = private_data;
+	return eb_info->fs_info;
+}
+
+static int btree_merge_bio_hook(struct page *page, unsigned long offset,
+				size_t size, struct bio *bio,
+				unsigned long bio_flags)
+{
+	struct extent_buffer *eb = (struct extent_buffer *)page->private;
+	struct btrfs_fs_info *fs_info = eb->eb_info->fs_info;
+	u64 logical = (u64)bio->bi_iter.bi_sector << 9;
+	u64 length = 0;
+	u64 map_length;
+	int ret;
+
+	length = bio->bi_iter.bi_size;
+	map_length = length;
+	ret = btrfs_map_block(fs_info, bio_op(bio), logical, &map_length,
+			      NULL, 0);
+	if (ret < 0)
+		return ret;
+	if (map_length < length + size)
+		return 1;
+	return 0;
 }
 
 static const struct extent_io_ops btree_extent_io_ops = {
 	/* mandatory callbacks */
 	.submit_bio_hook = btree_submit_bio_hook,
 	.readpage_end_io_hook = btree_readpage_end_io_hook,
-	/* note we're sharing with inode.c for the merge bio hook */
-	.merge_bio_hook = btrfs_merge_bio_hook,
+	.merge_bio_hook = btree_merge_bio_hook,
 	.readpage_io_failed_hook = btree_io_failed_hook,
 	.set_range_writeback = btrfs_set_range_writeback,
 	.tree_fs_info = btree_fs_info,
diff --git a/fs/btrfs/extent-tree.c b/fs/btrfs/extent-tree.c
index 0bdc10b453b9..a48fb3abed0c 100644
--- a/fs/btrfs/extent-tree.c
+++ b/fs/btrfs/extent-tree.c
@@ -1158,28 +1158,30 @@ int btrfs_get_extent_inline_ref_type(const struct extent_buffer *eb,
 			if (type == BTRFS_TREE_BLOCK_REF_KEY)
 				return type;
 			if (type == BTRFS_SHARED_BLOCK_REF_KEY) {
-				ASSERT(eb->fs_info);
+				ASSERT(eb->eb_info);
 				/*
 				 * Every shared one has parent tree
 				 * block, which must be aligned to
 				 * nodesize.
 				 */
 				if (offset &&
-				    IS_ALIGNED(offset, eb->fs_info->nodesize))
+				    IS_ALIGNED(offset,
+					       eb->eb_info->fs_info->nodesize))
 					return type;
 			}
 		} else if (is_data == BTRFS_REF_TYPE_DATA) {
 			if (type == BTRFS_EXTENT_DATA_REF_KEY)
 				return type;
 			if (type == BTRFS_SHARED_DATA_REF_KEY) {
-				ASSERT(eb->fs_info);
+				ASSERT(eb->eb_info->fs_info);
 				/*
 				 * Every shared one has parent tree
 				 * block, which must be aligned to
 				 * nodesize.
 				 */
 				if (offset &&
-				    IS_ALIGNED(offset, eb->fs_info->nodesize))
+				    IS_ALIGNED(offset,
+					       eb->eb_info->fs_info->nodesize))
 					return type;
 			}
 		} else {
@@ -1189,7 +1191,7 @@ int btrfs_get_extent_inline_ref_type(const struct extent_buffer *eb,
 	}
 
 	btrfs_print_leaf((struct extent_buffer *)eb);
-	btrfs_err(eb->fs_info, "eb %llu invalid extent inline ref type %d",
+	btrfs_err(eb->eb_info->fs_info, "eb %llu invalid extent inline ref type %d",
 		  eb->start, type);
 	WARN_ON(1);
 
@@ -8731,7 +8733,7 @@ static noinline int do_walk_down(struct btrfs_trans_handle *trans,
 	bytenr = btrfs_node_blockptr(path->nodes[level], path->slots[level]);
 	blocksize = fs_info->nodesize;
 
-	next = find_extent_buffer(fs_info, bytenr);
+	next = find_extent_buffer(fs_info->eb_info, bytenr);
 	if (!next) {
 		next = btrfs_find_create_tree_block(fs_info, bytenr);
 		if (IS_ERR(next))
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index 0538bf85adc3..c7e8b6d678bd 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -2768,6 +2768,7 @@ static int submit_extent_page(unsigned int opf, struct extent_io_tree *tree,
 			      int mirror_num,
 			      unsigned long prev_bio_flags,
 			      unsigned long bio_flags,
+			      enum rw_hint io_hint,
 			      bool force_bio_submit)
 {
 	int ret = 0;
@@ -2804,7 +2805,7 @@ static int submit_extent_page(unsigned int opf, struct extent_io_tree *tree,
 	bio_add_page(bio, page, page_size, offset);
 	bio->bi_end_io = end_io_func;
 	bio->bi_private = tree;
-	bio->bi_write_hint = page->mapping->host->i_write_hint;
+	bio->bi_write_hint = io_hint;
 	bio->bi_opf = opf;
 	if (wbc) {
 		wbc_init_bio(wbc, bio);
@@ -3065,7 +3066,7 @@ static int __do_readpage(struct extent_io_tree *tree,
 					 bdev, bio,
 					 end_bio_extent_readpage, mirror_num,
 					 *bio_flags,
-					 this_bio_flag,
+					 this_bio_flag, inode->i_write_hint,
 					 force_bio_submit);
 		if (!ret) {
 			nr++;
@@ -3433,7 +3434,7 @@ static noinline_for_stack int __extent_writepage_io(struct inode *inode,
 					 page, sector, iosize, pg_offset,
 					 bdev, &epd->bio,
 					 end_bio_extent_writepage,
-					 0, 0, 0, false);
+					 0, 0, 0, inode->i_write_hint, false);
 		if (ret) {
 			SetPageError(page);
 			if (PageWriteback(page))
@@ -3539,7 +3540,7 @@ lock_extent_buffer_for_io(struct extent_buffer *eb,
 			  struct btrfs_fs_info *fs_info,
 			  struct extent_page_data *epd)
 {
-	unsigned long i, num_pages;
+	struct btrfs_eb_info *eb_info = fs_info->eb_info;
 	int flush = 0;
 	int ret = 0;
 
@@ -3586,37 +3587,42 @@ lock_extent_buffer_for_io(struct extent_buffer *eb,
 
 	btrfs_tree_unlock(eb);
 
-	if (!ret)
-		return ret;
-
-	num_pages = num_extent_pages(eb->start, eb->len);
-	for (i = 0; i < num_pages; i++) {
-		struct page *p = eb->pages[i];
-
-		if (!trylock_page(p)) {
-			if (!flush) {
-				flush_write_bio(epd);
-				flush = 1;
-			}
-			lock_page(p);
-		}
+	/*
+	 * We cleared dirty on this buffer, we need to adjust the radix tags.
+	 * We do the actual page accounting in write_one_eb.
+	 */
+	if (ret) {
+		spin_lock_irq(&eb_info->buffer_lock);
+		radix_tree_tag_set(&eb_info->buffer_radix, eb_index(eb),
+				   PAGECACHE_TAG_WRITEBACK);
+		radix_tree_tag_clear(&eb_info->buffer_radix, eb_index(eb),
+				     PAGECACHE_TAG_DIRTY);
+		radix_tree_tag_clear(&eb_info->buffer_radix, eb_index(eb),
+				     PAGECACHE_TAG_TOWRITE);
+		spin_unlock_irq(&eb_info->buffer_lock);
 	}
-
 	return ret;
 }
 
 static void end_extent_buffer_writeback(struct extent_buffer *eb)
 {
-	clear_bit(EXTENT_BUFFER_WRITEBACK, &eb->bflags);
-	smp_mb__after_atomic();
-	wake_up_bit(&eb->bflags, EXTENT_BUFFER_WRITEBACK);
+	if (test_and_clear_bit(EXTENT_BUFFER_WRITEBACK, &eb->bflags)) {
+		struct btrfs_eb_info *eb_info = eb->eb_info;
+		unsigned long flags;
+
+		spin_lock_irqsave(&eb_info->buffer_lock, flags);
+		radix_tree_tag_clear(&eb_info->buffer_radix, eb_index(eb),
+				     PAGECACHE_TAG_WRITEBACK);
+		spin_unlock_irqrestore(&eb_info->buffer_lock, flags);
+		wake_up_bit(&eb->bflags, EXTENT_BUFFER_WRITEBACK);
+	}
 }
 
 static void set_btree_ioerr(struct page *page)
 {
 	struct extent_buffer *eb = (struct extent_buffer *)page->private;
+	struct btrfs_fs_info *fs_info = eb->eb_info->fs_info;
 
-	SetPageError(page);
 	if (test_and_set_bit(EXTENT_BUFFER_WRITE_ERR, &eb->bflags))
 		return;
 
@@ -3625,8 +3631,7 @@ static void set_btree_ioerr(struct page *page)
 	 * failed, increment the counter transaction->eb_write_errors.
 	 * We do this because while the transaction is running and before it's
 	 * committing (when we call filemap_fdata[write|wait]_range against
-	 * the btree inode), we might have
-	 * btree_inode->i_mapping->a_ops->writepages() called by the VM - if it
+	 * the btree inode), we might have write_metadata() called - if it
 	 * returns an error or an error happens during writeback, when we're
 	 * committing the transaction we wouldn't know about it, since the pages
 	 * can be no longer dirty nor marked anymore for writeback (if a
@@ -3660,13 +3665,13 @@ static void set_btree_ioerr(struct page *page)
 	 */
 	switch (eb->log_index) {
 	case -1:
-		set_bit(BTRFS_FS_BTREE_ERR, &eb->fs_info->flags);
+		set_bit(BTRFS_FS_BTREE_ERR, &fs_info->flags);
 		break;
 	case 0:
-		set_bit(BTRFS_FS_LOG1_ERR, &eb->fs_info->flags);
+		set_bit(BTRFS_FS_LOG1_ERR, &fs_info->flags);
 		break;
 	case 1:
-		set_bit(BTRFS_FS_LOG2_ERR, &eb->fs_info->flags);
+		set_bit(BTRFS_FS_LOG2_ERR, &fs_info->flags);
 		break;
 	default:
 		BUG(); /* unexpected, logic error */
@@ -3682,22 +3687,20 @@ static void end_bio_extent_buffer_writepage(struct bio *bio)
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
 	bio_for_each_segment_all(bvec, bio, i) {
 		struct page *page = bvec->bv_page;
+		struct super_block *sb;
 
 		eb = (struct extent_buffer *)page->private;
 		BUG_ON(!eb);
 		done = atomic_dec_and_test(&eb->io_pages);
 
 		if (bio->bi_status ||
-		    test_bit(EXTENT_BUFFER_WRITE_ERR, &eb->bflags)) {
-			ClearPageUptodate(page);
+		    test_bit(EXTENT_BUFFER_WRITE_ERR, &eb->bflags))
 			set_btree_ioerr(page);
-		}
-
-		end_page_writeback(page);
 
+		sb = eb->eb_info->fs_info->sb;
+		account_metadata_end_writeback(page, sb->s_bdi);
 		if (!done)
 			continue;
-
 		end_extent_buffer_writeback(eb);
 	}
 
@@ -3710,7 +3713,7 @@ static noinline_for_stack int write_one_eb(struct extent_buffer *eb,
 			struct extent_page_data *epd)
 {
 	struct block_device *bdev = fs_info->fs_devices->latest_bdev;
-	struct extent_io_tree *tree = &BTRFS_I(fs_info->btree_inode)->io_tree;
+	struct extent_io_tree *tree = &fs_info->eb_info->io_tree;
 	u64 offset = eb->start;
 	u32 nritems;
 	unsigned long i, num_pages;
@@ -3741,44 +3744,105 @@ static noinline_for_stack int write_one_eb(struct extent_buffer *eb,
 	for (i = 0; i < num_pages; i++) {
 		struct page *p = eb->pages[i];
 
-		clear_page_dirty_for_io(p);
-		set_page_writeback(p);
 		ret = submit_extent_page(REQ_OP_WRITE | write_flags, tree, wbc,
 					 p, offset >> 9, PAGE_SIZE, 0, bdev,
 					 &epd->bio,
 					 end_bio_extent_buffer_writepage,
-					 0, 0, 0, false);
+					 0, 0, 0, 0, false);
 		if (ret) {
 			set_btree_ioerr(p);
-			if (PageWriteback(p))
-				end_page_writeback(p);
 			if (atomic_sub_and_test(num_pages - i, &eb->io_pages))
 				end_extent_buffer_writeback(eb);
 			ret = -EIO;
 			break;
 		}
+		account_metadata_writeback(p, fs_info->sb->s_bdi);
 		offset += PAGE_SIZE;
 		update_nr_written(wbc, 1);
-		unlock_page(p);
 	}
 
-	if (unlikely(ret)) {
-		for (; i < num_pages; i++) {
-			struct page *p = eb->pages[i];
-			clear_page_dirty_for_io(p);
-			unlock_page(p);
-		}
+	return ret;
+}
+
+static void tag_ebs_for_writeback(struct btrfs_eb_info *eb_info, pgoff_t start,
+				  pgoff_t end)
+{
+#define EB_TAG_BATCH 4096
+	unsigned long tagged = 0;
+	struct radix_tree_iter iter;
+	void **slot;
+
+	spin_lock_irq(&eb_info->buffer_lock);
+	radix_tree_for_each_tagged(slot, &eb_info->buffer_radix, &iter, start,
+				   PAGECACHE_TAG_DIRTY) {
+		if (iter.index > end)
+			break;
+		radix_tree_iter_tag_set(&eb_info->buffer_radix, &iter,
+					PAGECACHE_TAG_TOWRITE);
+		tagged++;
+		if ((tagged % EB_TAG_BATCH) != 0)
+			continue;
+		slot = radix_tree_iter_resume(slot, &iter);
+		spin_unlock_irq(&eb_info->buffer_lock);
+		cond_resched();
+		spin_lock_irq(&eb_info->buffer_lock);
 	}
+	spin_unlock_irq(&eb_info->buffer_lock);
+}
+
+static unsigned eb_lookup_tag(struct btrfs_eb_info *eb_info,
+			      struct extent_buffer **ebs, pgoff_t *index,
+			      int tag, unsigned nr)
+{
+	struct radix_tree_iter iter;
+	void **slot;
+	unsigned ret = 0;
 
+	if (unlikely(!nr))
+		return 0;
+
+	rcu_read_lock();
+	radix_tree_for_each_tagged(slot, &eb_info->buffer_radix, &iter, *index,
+				   tag) {
+		struct extent_buffer *eb;
+repeat:
+		eb = radix_tree_deref_slot(slot);
+		if (unlikely(!eb))
+			continue;
+
+		if (radix_tree_exception(eb)) {
+			if (radix_tree_deref_retry(eb)) {
+				slot = radix_tree_iter_retry(&iter);
+				continue;
+			}
+			continue;
+		}
+
+		if (unlikely(!atomic_inc_not_zero(&eb->refs)))
+			continue;
+
+		if (unlikely(eb != *slot)) {
+			free_extent_buffer(eb);
+			goto repeat;
+		}
+
+		ebs[ret] = eb;
+		if (++ret == nr)
+			break;
+	}
+	rcu_read_unlock();
+	if (ret)
+		*index = (ebs[ret - 1]->start >> PAGE_SHIFT) + 1;
 	return ret;
 }
 
-int btree_write_cache_pages(struct address_space *mapping,
+#define EBVEC_SIZE 16
+static int btree_write_cache_pages(struct btrfs_fs_info *fs_info,
 				   struct writeback_control *wbc)
 {
-	struct extent_io_tree *tree = &BTRFS_I(mapping->host)->io_tree;
-	struct btrfs_fs_info *fs_info = BTRFS_I(mapping->host)->root->fs_info;
-	struct extent_buffer *eb, *prev_eb = NULL;
+	struct btrfs_eb_info *eb_info = fs_info->eb_info;
+	struct extent_io_tree *tree = &eb_info->io_tree;
+	struct extent_buffer *eb;
 	struct extent_page_data epd = {
 		.bio = NULL,
 		.tree = tree,
@@ -3788,16 +3852,16 @@ int btree_write_cache_pages(struct address_space *mapping,
 	int ret = 0;
 	int done = 0;
 	int nr_to_write_done = 0;
-	struct pagevec pvec;
-	int nr_pages;
+	struct extent_buffer *ebs[EBVEC_SIZE];
+	int nr_ebs;
 	pgoff_t index;
 	pgoff_t end;		/* Inclusive */
+	pgoff_t done_index = 0;
 	int scanned = 0;
 	int tag;
 
-	pagevec_init(&pvec, 0);
 	if (wbc->range_cyclic) {
-		index = mapping->writeback_index; /* Start from prev offset */
+		index = eb_info->writeback_index; /* Start from prev offset */
 		end = -1;
 	} else {
 		index = wbc->range_start >> PAGE_SHIFT;
@@ -3810,53 +3874,27 @@ int btree_write_cache_pages(struct address_space *mapping,
 		tag = PAGECACHE_TAG_DIRTY;
 retry:
 	if (wbc->sync_mode == WB_SYNC_ALL)
-		tag_pages_for_writeback(mapping, index, end);
+		tag_ebs_for_writeback(fs_info->eb_info, index, end);
 	while (!done && !nr_to_write_done && (index <= end) &&
-	       (nr_pages = pagevec_lookup_tag(&pvec, mapping, &index, tag,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1))) {
+	       (nr_ebs = eb_lookup_tag(eb_info, ebs, &index, tag,
+			min(end - index, (pgoff_t)EBVEC_SIZE-1) + 1))) {
 		unsigned i;
 
 		scanned = 1;
-		for (i = 0; i < nr_pages; i++) {
-			struct page *page = pvec.pages[i];
-
-			if (!PagePrivate(page))
-				continue;
-
-			if (!wbc->range_cyclic && page->index > end) {
-				done = 1;
-				break;
-			}
-
-			spin_lock(&mapping->private_lock);
-			if (!PagePrivate(page)) {
-				spin_unlock(&mapping->private_lock);
-				continue;
-			}
-
-			eb = (struct extent_buffer *)page->private;
-
-			/*
-			 * Shouldn't happen and normally this would be a BUG_ON
-			 * but no sense in crashing the users box for something
-			 * we can survive anyway.
-			 */
-			if (WARN_ON(!eb)) {
-				spin_unlock(&mapping->private_lock);
+		for (i = 0; i < nr_ebs; i++) {
+			eb = ebs[i];
+			if (done) {
+				free_extent_buffer(eb);
 				continue;
 			}
 
-			if (eb == prev_eb) {
-				spin_unlock(&mapping->private_lock);
+			if (!wbc->range_cyclic && eb->start > wbc->range_end) {
+				done = 1;
+				free_extent_buffer(eb);
 				continue;
 			}
 
-			ret = atomic_inc_not_zero(&eb->refs);
-			spin_unlock(&mapping->private_lock);
-			if (!ret)
-				continue;
-
-			prev_eb = eb;
+			done_index = eb_index(eb);
 			ret = lock_extent_buffer_for_io(eb, fs_info, &epd);
 			if (!ret) {
 				free_extent_buffer(eb);
@@ -3864,12 +3902,11 @@ int btree_write_cache_pages(struct address_space *mapping,
 			}
 
 			ret = write_one_eb(eb, fs_info, wbc, &epd);
+			free_extent_buffer(eb);
 			if (ret) {
 				done = 1;
-				free_extent_buffer(eb);
-				break;
+				continue;
 			}
-			free_extent_buffer(eb);
 
 			/*
 			 * the filesystem may choose to bump up nr_to_write.
@@ -3878,7 +3915,6 @@ int btree_write_cache_pages(struct address_space *mapping,
 			 */
 			nr_to_write_done = wbc->nr_to_write <= 0;
 		}
-		pagevec_release(&pvec);
 		cond_resched();
 	}
 	if (!scanned && !done) {
@@ -3890,10 +3926,77 @@ int btree_write_cache_pages(struct address_space *mapping,
 		index = 0;
 		goto retry;
 	}
+	if (wbc->range_cyclic)
+		fs_info->eb_info->writeback_index = done_index;
 	flush_write_bio(&epd);
 	return ret;
 }
 
+void btrfs_write_ebs(struct super_block *sb, struct writeback_control *wbc)
+{
+	struct btrfs_fs_info *fs_info = btrfs_sb(sb);
+	btree_write_cache_pages(fs_info, wbc);
+}
+
+static int __btree_write_range(struct btrfs_fs_info *fs_info, u64 start,
+			       u64 end, int sync_mode)
+{
+	struct writeback_control wbc = {
+		.sync_mode = sync_mode,
+		.nr_to_write = LONG_MAX,
+		.range_start = start,
+		.range_end = end,
+	};
+
+	return btree_write_cache_pages(fs_info, &wbc);
+}
+
+void btree_flush(struct btrfs_fs_info *fs_info)
+{
+	__btree_write_range(fs_info, 0, (u64)-1, WB_SYNC_NONE);
+}
+
+int btree_write_range(struct btrfs_fs_info *fs_info, u64 start, u64 end)
+{
+	return __btree_write_range(fs_info, start, end, WB_SYNC_ALL);
+}
+
+int btree_wait_range(struct btrfs_fs_info *fs_info, u64 start, u64 end)
+{
+	struct extent_buffer *ebs[EBVEC_SIZE];
+	pgoff_t index = start >> PAGE_SHIFT;
+	pgoff_t end_index = end >> PAGE_SHIFT;
+	unsigned nr_ebs;
+	int ret = 0;
+
+	if (end < start)
+		return ret;
+
+	while ((index <= end) &&
+	       (nr_ebs = eb_lookup_tag(fs_info->eb_info, ebs, &index,
+				       PAGECACHE_TAG_WRITEBACK,
+				       min(end_index - index,
+					   (pgoff_t)EBVEC_SIZE-1) + 1)) != 0) {
+		unsigned i;
+
+		for (i = 0; i < nr_ebs; i++) {
+			struct extent_buffer *eb = ebs[i];
+
+			if (eb->start > end) {
+				free_extent_buffer(eb);
+				continue;
+			}
+
+			wait_on_extent_buffer_writeback(eb);
+			if (test_bit(EXTENT_BUFFER_WRITE_ERR, &eb->bflags))
+				ret = -EIO;
+			free_extent_buffer(eb);
+		}
+		cond_resched();
+	}
+	return ret;
+}
+
 /**
  * write_cache_pages - walk the list of dirty pages of the given address space and write all of them.
  * @mapping: address space structure to write
@@ -4680,7 +4783,6 @@ static void btrfs_release_extent_buffer_page(struct extent_buffer *eb)
 {
 	unsigned long index;
 	struct page *page;
-	int mapped = !test_bit(EXTENT_BUFFER_DUMMY, &eb->bflags);
 
 	BUG_ON(extent_buffer_under_io(eb));
 
@@ -4688,39 +4790,21 @@ static void btrfs_release_extent_buffer_page(struct extent_buffer *eb)
 	if (index == 0)
 		return;
 
+	ASSERT(!test_bit(EXTENT_BUFFER_DIRTY, &eb->bflags));
 	do {
 		index--;
 		page = eb->pages[index];
 		if (!page)
 			continue;
-		if (mapped)
-			spin_lock(&page->mapping->private_lock);
-		/*
-		 * We do this since we'll remove the pages after we've
-		 * removed the eb from the radix tree, so we could race
-		 * and have this page now attached to the new eb.  So
-		 * only clear page_private if it's still connected to
-		 * this eb.
-		 */
-		if (PagePrivate(page) &&
-		    page->private == (unsigned long)eb) {
-			BUG_ON(test_bit(EXTENT_BUFFER_DIRTY, &eb->bflags));
-			BUG_ON(PageDirty(page));
-			BUG_ON(PageWriteback(page));
-			/*
-			 * We need to make sure we haven't be attached
-			 * to a new eb.
-			 */
-			ClearPagePrivate(page);
-			set_page_private(page, 0);
-			/* One for the page private */
-			put_page(page);
-		}
+		ASSERT(PagePrivate(page));
+		ASSERT(page->private == (unsigned long)eb);
+		ClearPagePrivate(page);
+		set_page_private(page, 0);
 
-		if (mapped)
-			spin_unlock(&page->mapping->private_lock);
+		/* Once for the page private. */
+		put_page(page);
 
-		/* One for when we allocated the page */
+		/* Once for the alloc_page. */
 		put_page(page);
 	} while (index != 0);
 }
@@ -4735,7 +4819,7 @@ static inline void btrfs_release_extent_buffer(struct extent_buffer *eb)
 }
 
 static struct extent_buffer *
-__alloc_extent_buffer(struct btrfs_fs_info *fs_info, u64 start,
+__alloc_extent_buffer(struct btrfs_eb_info *eb_info, u64 start,
 		      unsigned long len)
 {
 	struct extent_buffer *eb = NULL;
@@ -4743,7 +4827,7 @@ __alloc_extent_buffer(struct btrfs_fs_info *fs_info, u64 start,
 	eb = kmem_cache_zalloc(extent_buffer_cache, GFP_NOFS|__GFP_NOFAIL);
 	eb->start = start;
 	eb->len = len;
-	eb->fs_info = fs_info;
+	eb->eb_info = eb_info;
 	eb->bflags = 0;
 	rwlock_init(&eb->lock);
 	atomic_set(&eb->write_locks, 0);
@@ -4755,6 +4839,7 @@ __alloc_extent_buffer(struct btrfs_fs_info *fs_info, u64 start,
 	eb->lock_nested = 0;
 	init_waitqueue_head(&eb->write_lock_wq);
 	init_waitqueue_head(&eb->read_lock_wq);
+	INIT_LIST_HEAD(&eb->lru);
 
 	btrfs_leak_debug_add(&eb->leak_list, &buffers);
 
@@ -4779,7 +4864,7 @@ struct extent_buffer *btrfs_clone_extent_buffer(struct extent_buffer *src)
 	struct extent_buffer *new;
 	unsigned long num_pages = num_extent_pages(src->start, src->len);
 
-	new = __alloc_extent_buffer(src->fs_info, src->start, src->len);
+	new = __alloc_extent_buffer(src->eb_info, src->start, src->len);
 	if (new == NULL)
 		return NULL;
 
@@ -4790,8 +4875,6 @@ struct extent_buffer *btrfs_clone_extent_buffer(struct extent_buffer *src)
 			return NULL;
 		}
 		attach_extent_buffer_page(new, p);
-		WARN_ON(PageDirty(p));
-		SetPageUptodate(p);
 		new->pages[i] = p;
 		copy_page(page_address(p), page_address(src->pages[i]));
 	}
@@ -4802,8 +4885,8 @@ struct extent_buffer *btrfs_clone_extent_buffer(struct extent_buffer *src)
 	return new;
 }
 
-struct extent_buffer *__alloc_dummy_extent_buffer(struct btrfs_fs_info *fs_info,
-						  u64 start, unsigned long len)
+struct extent_buffer *alloc_dummy_extent_buffer(struct btrfs_eb_info *eb_info,
+						u64 start, unsigned long len)
 {
 	struct extent_buffer *eb;
 	unsigned long num_pages;
@@ -4811,7 +4894,7 @@ struct extent_buffer *__alloc_dummy_extent_buffer(struct btrfs_fs_info *fs_info,
 
 	num_pages = num_extent_pages(start, len);
 
-	eb = __alloc_extent_buffer(fs_info, start, len);
+	eb = __alloc_extent_buffer(eb_info, start, len);
 	if (!eb)
 		return NULL;
 
@@ -4819,6 +4902,7 @@ struct extent_buffer *__alloc_dummy_extent_buffer(struct btrfs_fs_info *fs_info,
 		eb->pages[i] = alloc_page(GFP_NOFS);
 		if (!eb->pages[i])
 			goto err;
+		attach_extent_buffer_page(eb, eb->pages[i]);
 	}
 	set_extent_buffer_uptodate(eb);
 	btrfs_set_header_nritems(eb, 0);
@@ -4826,18 +4910,10 @@ struct extent_buffer *__alloc_dummy_extent_buffer(struct btrfs_fs_info *fs_info,
 
 	return eb;
 err:
-	for (; i > 0; i--)
-		__free_page(eb->pages[i - 1]);
-	__free_extent_buffer(eb);
+	btrfs_release_extent_buffer(eb);
 	return NULL;
 }
 
-struct extent_buffer *alloc_dummy_extent_buffer(struct btrfs_fs_info *fs_info,
-						u64 start)
-{
-	return __alloc_dummy_extent_buffer(fs_info, start, fs_info->nodesize);
-}
-
 static void check_buffer_tree_ref(struct extent_buffer *eb)
 {
 	int refs;
@@ -4887,13 +4963,13 @@ static void mark_extent_buffer_accessed(struct extent_buffer *eb,
 	}
 }
 
-struct extent_buffer *find_extent_buffer(struct btrfs_fs_info *fs_info,
+struct extent_buffer *find_extent_buffer(struct btrfs_eb_info *eb_info,
 					 u64 start)
 {
 	struct extent_buffer *eb;
 
 	rcu_read_lock();
-	eb = radix_tree_lookup(&fs_info->buffer_radix,
+	eb = radix_tree_lookup(&eb_info->buffer_radix,
 			       start >> PAGE_SHIFT);
 	if (eb && atomic_inc_not_zero(&eb->refs)) {
 		rcu_read_unlock();
@@ -4925,30 +5001,30 @@ struct extent_buffer *find_extent_buffer(struct btrfs_fs_info *fs_info,
 }
 
 #ifdef CONFIG_BTRFS_FS_RUN_SANITY_TESTS
-struct extent_buffer *alloc_test_extent_buffer(struct btrfs_fs_info *fs_info,
-					u64 start)
+struct extent_buffer *alloc_test_extent_buffer(struct btrfs_eb_info *eb_info,
+					       u64 start, u32 nodesize)
 {
 	struct extent_buffer *eb, *exists = NULL;
 	int ret;
 
-	eb = find_extent_buffer(fs_info, start);
+	eb = find_extent_buffer(eb_info, start);
 	if (eb)
 		return eb;
-	eb = alloc_dummy_extent_buffer(fs_info, start);
+	eb = alloc_dummy_extent_buffer(eb_info, start, nodesize);
 	if (!eb)
 		return NULL;
-	eb->fs_info = fs_info;
+	eb->eb_info = eb_info;
 again:
 	ret = radix_tree_preload(GFP_NOFS);
 	if (ret)
 		goto free_eb;
-	spin_lock(&fs_info->buffer_lock);
-	ret = radix_tree_insert(&fs_info->buffer_radix,
+	spin_lock_irq(&eb_info->buffer_lock);
+	ret = radix_tree_insert(&eb_info->buffer_radix,
 				start >> PAGE_SHIFT, eb);
-	spin_unlock(&fs_info->buffer_lock);
+	spin_unlock_irq(&eb_info->buffer_lock);
 	radix_tree_preload_end();
 	if (ret == -EEXIST) {
-		exists = find_extent_buffer(fs_info, start);
+		exists = find_extent_buffer(eb_info, start);
 		if (exists)
 			goto free_eb;
 		else
@@ -4964,6 +5040,7 @@ struct extent_buffer *alloc_test_extent_buffer(struct btrfs_fs_info *fs_info,
 	 * bump the ref count again.
 	 */
 	atomic_inc(&eb->refs);
+	set_extent_buffer_uptodate(eb);
 	return eb;
 free_eb:
 	btrfs_release_extent_buffer(eb);
@@ -4977,12 +5054,12 @@ struct extent_buffer *alloc_extent_buffer(struct btrfs_fs_info *fs_info,
 	unsigned long len = fs_info->nodesize;
 	unsigned long num_pages = num_extent_pages(start, len);
 	unsigned long i;
-	unsigned long index = start >> PAGE_SHIFT;
 	struct extent_buffer *eb;
 	struct extent_buffer *exists = NULL;
 	struct page *p;
-	struct address_space *mapping = fs_info->btree_inode->i_mapping;
-	int uptodate = 1;
+	struct btrfs_eb_info *eb_info = fs_info->eb_info;
+//	struct zone *last_zone = NULL;
+//	struct pg_data_t *last_pgdata = NULL;
 	int ret;
 
 	if (!IS_ALIGNED(start, fs_info->sectorsize)) {
@@ -4990,62 +5067,36 @@ struct extent_buffer *alloc_extent_buffer(struct btrfs_fs_info *fs_info,
 		return ERR_PTR(-EINVAL);
 	}
 
-	eb = find_extent_buffer(fs_info, start);
+	eb = find_extent_buffer(eb_info, start);
 	if (eb)
 		return eb;
 
-	eb = __alloc_extent_buffer(fs_info, start, len);
+	eb = __alloc_extent_buffer(eb_info, start, len);
 	if (!eb)
 		return ERR_PTR(-ENOMEM);
 
-	for (i = 0; i < num_pages; i++, index++) {
-		p = find_or_create_page(mapping, index, GFP_NOFS|__GFP_NOFAIL);
+	for (i = 0; i < num_pages; i++) {
+		p = alloc_page(GFP_NOFS|__GFP_NOFAIL);
 		if (!p) {
 			exists = ERR_PTR(-ENOMEM);
 			goto free_eb;
 		}
 
-		spin_lock(&mapping->private_lock);
-		if (PagePrivate(p)) {
-			/*
-			 * We could have already allocated an eb for this page
-			 * and attached one so lets see if we can get a ref on
-			 * the existing eb, and if we can we know it's good and
-			 * we can just return that one, else we know we can just
-			 * overwrite page->private.
-			 */
-			exists = (struct extent_buffer *)p->private;
-			if (atomic_inc_not_zero(&exists->refs)) {
-				spin_unlock(&mapping->private_lock);
-				unlock_page(p);
-				put_page(p);
-				mark_extent_buffer_accessed(exists, p);
-				goto free_eb;
-			}
-			exists = NULL;
-
-			/*
-			 * Do this so attach doesn't complain and we need to
-			 * drop the ref the old guy had.
-			 */
-			ClearPagePrivate(p);
-			WARN_ON(PageDirty(p));
-			put_page(p);
-		}
+		/*
+		 * If our pages span zones or numa nodes we have to do
+		 * dirty/writeback accounting per page, otherwise we can do it
+		 * in bulk and save us some looping.
+		 *
+		if (!last_zone)
+			last_zone = page_zone(p);
+		if (!last_pgdata)
+			last_pgdata = page_pgdata(p);
+		if (last_zone != page_zone(p) || last_pgdata != page_pgdata(p))
+			set_bit(EXTENT_BUFFER_MIXED_PAGES, &eb->bflags);
+		*/
 		attach_extent_buffer_page(eb, p);
-		spin_unlock(&mapping->private_lock);
-		WARN_ON(PageDirty(p));
 		eb->pages[i] = p;
-		if (!PageUptodate(p))
-			uptodate = 0;
-
-		/*
-		 * see below about how we avoid a nasty race with release page
-		 * and why we unlock later
-		 */
 	}
-	if (uptodate)
-		set_bit(EXTENT_BUFFER_UPTODATE, &eb->bflags);
 again:
 	ret = radix_tree_preload(GFP_NOFS);
 	if (ret) {
@@ -5053,13 +5104,13 @@ struct extent_buffer *alloc_extent_buffer(struct btrfs_fs_info *fs_info,
 		goto free_eb;
 	}
 
-	spin_lock(&fs_info->buffer_lock);
-	ret = radix_tree_insert(&fs_info->buffer_radix,
+	spin_lock_irq(&eb_info->buffer_lock);
+	ret = radix_tree_insert(&eb_info->buffer_radix,
 				start >> PAGE_SHIFT, eb);
-	spin_unlock(&fs_info->buffer_lock);
+	spin_unlock_irq(&eb_info->buffer_lock);
 	radix_tree_preload_end();
 	if (ret == -EEXIST) {
-		exists = find_extent_buffer(fs_info, start);
+		exists = find_extent_buffer(eb_info, start);
 		if (exists)
 			goto free_eb;
 		else
@@ -5069,31 +5120,10 @@ struct extent_buffer *alloc_extent_buffer(struct btrfs_fs_info *fs_info,
 	check_buffer_tree_ref(eb);
 	set_bit(EXTENT_BUFFER_IN_TREE, &eb->bflags);
 
-	/*
-	 * there is a race where release page may have
-	 * tried to find this extent buffer in the radix
-	 * but failed.  It will tell the VM it is safe to
-	 * reclaim the, and it will clear the page private bit.
-	 * We must make sure to set the page private bit properly
-	 * after the extent buffer is in the radix tree so
-	 * it doesn't get lost
-	 */
-	SetPageChecked(eb->pages[0]);
-	for (i = 1; i < num_pages; i++) {
-		p = eb->pages[i];
-		ClearPageChecked(p);
-		unlock_page(p);
-	}
-	unlock_page(eb->pages[0]);
 	return eb;
 
 free_eb:
 	WARN_ON(!atomic_dec_and_test(&eb->refs));
-	for (i = 0; i < num_pages; i++) {
-		if (eb->pages[i])
-			unlock_page(eb->pages[i]);
-	}
-
 	btrfs_release_extent_buffer(eb);
 	return exists;
 }
@@ -5109,17 +5139,19 @@ static inline void btrfs_release_extent_buffer_rcu(struct rcu_head *head)
 /* Expects to have eb->eb_lock already held */
 static int release_extent_buffer(struct extent_buffer *eb)
 {
+	struct btrfs_eb_info *eb_info = eb->eb_info;
+
 	WARN_ON(atomic_read(&eb->refs) == 0);
 	if (atomic_dec_and_test(&eb->refs)) {
+		if (eb_info)
+			list_lru_del(&eb_info->lru_list, &eb->lru);
 		if (test_and_clear_bit(EXTENT_BUFFER_IN_TREE, &eb->bflags)) {
-			struct btrfs_fs_info *fs_info = eb->fs_info;
-
 			spin_unlock(&eb->refs_lock);
 
-			spin_lock(&fs_info->buffer_lock);
-			radix_tree_delete(&fs_info->buffer_radix,
-					  eb->start >> PAGE_SHIFT);
-			spin_unlock(&fs_info->buffer_lock);
+			spin_lock_irq(&eb_info->buffer_lock);
+			radix_tree_delete(&eb_info->buffer_radix,
+					  eb_index(eb));
+			spin_unlock_irq(&eb_info->buffer_lock);
 		} else {
 			spin_unlock(&eb->refs_lock);
 		}
@@ -5134,6 +5166,8 @@ static int release_extent_buffer(struct extent_buffer *eb)
 #endif
 		call_rcu(&eb->rcu_head, btrfs_release_extent_buffer_rcu);
 		return 1;
+	} else if (eb_info && atomic_read(&eb->refs) == 1) {
+		list_lru_add(&eb_info->lru_list, &eb->lru);
 	}
 	spin_unlock(&eb->refs_lock);
 
@@ -5167,10 +5201,6 @@ void free_extent_buffer(struct extent_buffer *eb)
 	    test_and_clear_bit(EXTENT_BUFFER_TREE_REF, &eb->bflags))
 		atomic_dec(&eb->refs);
 
-	/*
-	 * I know this is terrible, but it's temporary until we stop tracking
-	 * the uptodate bits and such for the extent buffers.
-	 */
 	release_extent_buffer(eb);
 }
 
@@ -5188,82 +5218,160 @@ void free_extent_buffer_stale(struct extent_buffer *eb)
 	release_extent_buffer(eb);
 }
 
-void clear_extent_buffer_dirty(struct extent_buffer *eb)
+long btrfs_nr_ebs(struct super_block *sb, struct shrink_control *sc)
 {
-	unsigned long i;
-	unsigned long num_pages;
-	struct page *page;
+	struct btrfs_fs_info *fs_info = btrfs_sb(sb);
+	struct btrfs_eb_info *eb_info = fs_info->eb_info;
 
-	num_pages = num_extent_pages(eb->start, eb->len);
+	return list_lru_shrink_count(&eb_info->lru_list, sc);
+}
 
-	for (i = 0; i < num_pages; i++) {
-		page = eb->pages[i];
-		if (!PageDirty(page))
-			continue;
+static enum lru_status eb_lru_isolate(struct list_head *item,
+				      struct list_lru_one *lru,
+				      spinlock_t *lru_lock, void *arg)
+{
+	struct list_head *freeable = (struct list_head *)arg;
+	struct extent_buffer *eb = container_of(item, struct extent_buffer,
+						lru);
+	enum lru_status ret;
+	int refs;
 
-		lock_page(page);
-		WARN_ON(!PagePrivate(page));
+	if (!spin_trylock(&eb->refs_lock))
+		return LRU_SKIP;
 
-		clear_page_dirty_for_io(page);
-		spin_lock_irq(&page->mapping->tree_lock);
-		if (!PageDirty(page)) {
-			radix_tree_tag_clear(&page->mapping->page_tree,
-						page_index(page),
-						PAGECACHE_TAG_DIRTY);
-		}
-		spin_unlock_irq(&page->mapping->tree_lock);
-		ClearPageError(page);
-		unlock_page(page);
+	if (extent_buffer_under_io(eb)) {
+		ret = LRU_ROTATE;
+		goto out;
 	}
+
+	refs = atomic_read(&eb->refs);
+	/* We can race with somebody freeing us, just skip if this happens. */
+	if (refs == 0) {
+		ret = LRU_SKIP;
+		goto out;
+	}
+
+	/* Eb is in use, don't kill it. */
+	if (refs > 1) {
+		ret = LRU_ROTATE;
+		goto out;
+	}
+
+	/*
+	 * If we don't clear the TREE_REF flag then this eb is going to
+	 * disappear soon anyway.  Otherwise we become responsible for dropping
+	 * the last ref on this eb and we know it'll survive until we call
+	 * dispose_list.
+	 */
+	if (!test_and_clear_bit(EXTENT_BUFFER_TREE_REF, &eb->bflags)) {
+		ret = LRU_SKIP;
+		goto out;
+	}
+	list_lru_isolate_move(lru, &eb->lru, freeable);
+	ret = LRU_REMOVED;
+out:
+	spin_unlock(&eb->refs_lock);
+	return ret;
+}
+
+static void dispose_list(struct list_head *list)
+{
+	struct extent_buffer *eb;
+
+	while (!list_empty(list)) {
+		eb = list_first_entry(list, struct extent_buffer, lru);
+
+		spin_lock(&eb->refs_lock);
+		list_del_init(&eb->lru);
+		spin_unlock(&eb->refs_lock);
+		free_extent_buffer(eb);
+		cond_resched();
+	}
+}
+
+long btrfs_free_ebs(struct super_block *sb, struct shrink_control *sc)
+{
+	struct btrfs_fs_info *fs_info = btrfs_sb(sb);
+	struct btrfs_eb_info *eb_info = fs_info->eb_info;
+	LIST_HEAD(freeable);
+	long freed;
+
+	freed = list_lru_shrink_walk(&eb_info->lru_list, sc, eb_lru_isolate,
+				     &freeable);
+	dispose_list(&freeable);
+	return freed;
+}
+
+void btrfs_invalidate_eb_info(struct btrfs_eb_info *eb_info)
+{
+	LIST_HEAD(freeable);
+
+	/*
+	 * We should be able to free all the extent buffers at this point, if we
+	 * can't there's a problem and we should complain loudly about it.
+	 */
+	do {
+		list_lru_walk(&eb_info->lru_list, eb_lru_isolate, &freeable, LONG_MAX);
+	} while (WARN_ON(list_lru_count(&eb_info->lru_list)));
+	dispose_list(&freeable);
+	synchronize_rcu();
+}
+
+int clear_extent_buffer_dirty(struct extent_buffer *eb)
+{
+	struct btrfs_eb_info *eb_info = eb->eb_info;
+	struct super_block *sb = eb_info->fs_info->sb;
+	unsigned long i;
+	unsigned long num_pages;
+
+	if (!test_and_clear_bit(EXTENT_BUFFER_DIRTY, &eb->bflags))
+		return 0;
+
+	spin_lock_irq(&eb_info->buffer_lock);
+	radix_tree_tag_clear(&eb_info->buffer_radix, eb_index(eb),
+			     PAGECACHE_TAG_DIRTY);
+	spin_unlock_irq(&eb_info->buffer_lock);
+
+	num_pages = num_extent_pages(eb->start, eb->len);
+	for (i = 0; i < num_pages; i++)
+		account_metadata_cleaned(eb->pages[i], sb->s_bdi);
 	WARN_ON(atomic_read(&eb->refs) == 0);
+	return 1;
 }
 
 int set_extent_buffer_dirty(struct extent_buffer *eb)
 {
+	struct btrfs_eb_info *eb_info = eb->eb_info;
+	struct super_block *sb = eb_info->fs_info->sb;
 	unsigned long i;
 	unsigned long num_pages;
 	int was_dirty = 0;
 
 	check_buffer_tree_ref(eb);
 
-	was_dirty = test_and_set_bit(EXTENT_BUFFER_DIRTY, &eb->bflags);
-
-	num_pages = num_extent_pages(eb->start, eb->len);
 	WARN_ON(atomic_read(&eb->refs) == 0);
 	WARN_ON(!test_bit(EXTENT_BUFFER_TREE_REF, &eb->bflags));
+	if (test_and_set_bit(EXTENT_BUFFER_DIRTY, &eb->bflags))
+		return 1;
 
+	num_pages = num_extent_pages(eb->start, eb->len);
 	for (i = 0; i < num_pages; i++)
-		set_page_dirty(eb->pages[i]);
+		account_metadata_dirtied(eb->pages[i], sb->s_bdi);
+	spin_lock_irq(&eb_info->buffer_lock);
+	radix_tree_tag_set(&eb_info->buffer_radix, eb_index(eb),
+			   PAGECACHE_TAG_DIRTY);
+	spin_unlock_irq(&eb_info->buffer_lock);
 	return was_dirty;
 }
 
 void clear_extent_buffer_uptodate(struct extent_buffer *eb)
 {
-	unsigned long i;
-	struct page *page;
-	unsigned long num_pages;
-
 	clear_bit(EXTENT_BUFFER_UPTODATE, &eb->bflags);
-	num_pages = num_extent_pages(eb->start, eb->len);
-	for (i = 0; i < num_pages; i++) {
-		page = eb->pages[i];
-		if (page)
-			ClearPageUptodate(page);
-	}
 }
 
 void set_extent_buffer_uptodate(struct extent_buffer *eb)
 {
-	unsigned long i;
-	struct page *page;
-	unsigned long num_pages;
-
 	set_bit(EXTENT_BUFFER_UPTODATE, &eb->bflags);
-	num_pages = num_extent_pages(eb->start, eb->len);
-	for (i = 0; i < num_pages; i++) {
-		page = eb->pages[i];
-		SetPageUptodate(page);
-	}
 }
 
 int extent_buffer_uptodate(struct extent_buffer *eb)
@@ -5271,112 +5379,165 @@ int extent_buffer_uptodate(struct extent_buffer *eb)
 	return test_bit(EXTENT_BUFFER_UPTODATE, &eb->bflags);
 }
 
-int read_extent_buffer_pages(struct extent_io_tree *tree,
-			     struct extent_buffer *eb, int wait,
-			     get_extent_t *get_extent, int mirror_num)
+static void end_bio_extent_buffer_readpage(struct bio *bio)
 {
+	struct btrfs_io_bio *io_bio = btrfs_io_bio(bio);
+	struct extent_io_tree *tree = NULL;
+	struct bio_vec *bvec;
+	u64 unlock_start = 0, unlock_len = 0;
+	int mirror_num = io_bio->mirror_num;
+	int uptodate = !bio->bi_status;
+	int i, ret;
+
+	bio_for_each_segment_all(bvec, bio, i) {
+		struct page *page = bvec->bv_page;
+		struct btrfs_eb_info *eb_info;
+		struct extent_buffer *eb;
+
+		eb = (struct extent_buffer *)page->private;
+		if (WARN_ON(!eb))
+			continue;
+
+		eb_info = eb->eb_info;
+		if (!tree)
+			tree = &eb_info->io_tree;
+		if (uptodate) {
+			/*
+			 * btree_readpage_end_io_hook doesn't care about
+			 * start/end so just pass 0.  We'll kill this later.
+			 */
+			ret = tree->ops->readpage_end_io_hook(io_bio, 0,
+							      page, 0, 0,
+							      mirror_num);
+			if (ret) {
+				uptodate = 0;
+			} else {
+				u64 start = eb->start;
+				int c, num_pages;
+
+				num_pages = num_extent_pages(eb->start,
+							     eb->len);
+				for (c = 0; c < num_pages; c++) {
+					if (eb->pages[c] == page)
+						break;
+					start += PAGE_SIZE;
+				}
+				clean_io_failure(eb_info->fs_info,
+						 &eb_info->io_failure_tree,
+						 tree, start, page, 0, 0);
+			}
+		}
+		/*
+		 * We never fix anything in btree_io_failed_hook.
+		 *
+		 * TODO: rework the io failed hook to not assume we can fix
+		 * anything.
+		 */
+		if (!uptodate)
+			tree->ops->readpage_io_failed_hook(page, mirror_num);
+
+		if (unlock_start == 0) {
+			unlock_start = eb->start;
+			unlock_len = PAGE_SIZE;
+		} else {
+			unlock_len += PAGE_SIZE;
+		}
+	}
+
+	if (unlock_start)
+		unlock_extent(tree, unlock_start,
+			      unlock_start + unlock_len - 1);
+	if (io_bio->end_io)
+		io_bio->end_io(io_bio, blk_status_to_errno(bio->bi_status));
+	bio_put(bio);
+}
+
+int read_extent_buffer_pages(struct extent_buffer *eb, int wait,
+			     int mirror_num)
+{
+	struct btrfs_eb_info *eb_info = eb->eb_info;
+	struct extent_io_tree *io_tree = &eb_info->io_tree;
+	struct block_device *bdev = eb_info->fs_info->fs_devices->latest_bdev;
+	struct bio *bio = NULL;
+	u64 offset = eb->start;
+	u64 unlock_start = 0, unlock_len = 0;
 	unsigned long i;
 	struct page *page;
 	int err;
 	int ret = 0;
-	int locked_pages = 0;
-	int all_uptodate = 1;
 	unsigned long num_pages;
-	unsigned long num_reads = 0;
-	struct bio *bio = NULL;
-	unsigned long bio_flags = 0;
 
 	if (test_bit(EXTENT_BUFFER_UPTODATE, &eb->bflags))
 		return 0;
 
-	num_pages = num_extent_pages(eb->start, eb->len);
-	for (i = 0; i < num_pages; i++) {
-		page = eb->pages[i];
-		if (wait == WAIT_NONE) {
-			if (!trylock_page(page))
-				goto unlock_exit;
-		} else {
-			lock_page(page);
-		}
-		locked_pages++;
-	}
-	/*
-	 * We need to firstly lock all pages to make sure that
-	 * the uptodate bit of our pages won't be affected by
-	 * clear_extent_buffer_uptodate().
-	 */
-	for (i = 0; i < num_pages; i++) {
-		page = eb->pages[i];
-		if (!PageUptodate(page)) {
-			num_reads++;
-			all_uptodate = 0;
-		}
-	}
-
-	if (all_uptodate) {
-		set_bit(EXTENT_BUFFER_UPTODATE, &eb->bflags);
-		goto unlock_exit;
+	if (test_and_set_bit(EXTENT_BUFFER_READING, &eb->bflags)) {
+		if (wait != WAIT_COMPLETE)
+			return 0;
+		wait_on_bit_io(&eb->bflags, EXTENT_BUFFER_READING,
+			       TASK_UNINTERRUPTIBLE);
+		if (!test_bit(EXTENT_BUFFER_UPTODATE, &eb->bflags))
+			ret = -EIO;
+		return ret;
 	}
 
+	lock_extent(io_tree, eb->start, eb->start + eb->len - 1);
+	num_pages = num_extent_pages(eb->start, eb->len);
 	clear_bit(EXTENT_BUFFER_READ_ERR, &eb->bflags);
 	eb->read_mirror = 0;
-	atomic_set(&eb->io_pages, num_reads);
+	atomic_set(&eb->io_pages, num_pages);
 	for (i = 0; i < num_pages; i++) {
 		page = eb->pages[i];
-
-		if (!PageUptodate(page)) {
-			if (ret) {
-				atomic_dec(&eb->io_pages);
-				unlock_page(page);
-				continue;
+		if (ret) {
+			unlock_len += PAGE_SIZE;
+			if (atomic_dec_and_test(&eb->io_pages)) {
+				clear_bit(EXTENT_BUFFER_READING, &eb->bflags);
+				smp_mb__after_atomic();
+				wake_up_bit(&eb->bflags, EXTENT_BUFFER_READING);
 			}
+			continue;
+		}
 
-			ClearPageError(page);
-			err = __extent_read_full_page(tree, page,
-						      get_extent, &bio,
-						      mirror_num, &bio_flags,
-						      REQ_META);
-			if (err) {
-				ret = err;
-				/*
-				 * We use &bio in above __extent_read_full_page,
-				 * so we ensure that if it returns error, the
-				 * current page fails to add itself to bio and
-				 * it's been unlocked.
-				 *
-				 * We must dec io_pages by ourselves.
-				 */
-				atomic_dec(&eb->io_pages);
+		err = submit_extent_page(REQ_OP_READ | REQ_META, io_tree, NULL,
+					 page, offset >> 9, PAGE_SIZE, 0, bdev,
+					 &bio, end_bio_extent_buffer_readpage,
+					 mirror_num, 0, 0, 0, false);
+		if (err) {
+			ret = err;
+			/*
+			 * We use &bio in above submit_extent_page
+			 * so we ensure that if it returns error, the
+			 * current page fails to add itself to bio and
+			 * it's been unlocked.
+			 *
+			 * We must dec io_pages by ourselves.
+			 */
+			if (atomic_dec_and_test(&eb->io_pages)) {
+				clear_bit(EXTENT_BUFFER_READING, &eb->bflags);
+				smp_mb__after_atomic();
+				wake_up_bit(&eb->bflags, EXTENT_BUFFER_READING);
 			}
-		} else {
-			unlock_page(page);
+			unlock_start = eb->start;
+			unlock_len = PAGE_SIZE;
 		}
+		offset += PAGE_SIZE;
 	}
 
 	if (bio) {
-		err = submit_one_bio(bio, mirror_num, bio_flags);
+		err = submit_one_bio(bio, mirror_num, 0);
 		if (err)
 			return err;
 	}
 
+	if (ret && unlock_start)
+		unlock_extent(io_tree, unlock_start,
+			      unlock_start + unlock_len - 1);
 	if (ret || wait != WAIT_COMPLETE)
 		return ret;
 
-	for (i = 0; i < num_pages; i++) {
-		page = eb->pages[i];
-		wait_on_page_locked(page);
-		if (!PageUptodate(page))
-			ret = -EIO;
-	}
-
-	return ret;
-
-unlock_exit:
-	while (locked_pages > 0) {
-		locked_pages--;
-		page = eb->pages[locked_pages];
-		unlock_page(page);
-	}
+	wait_on_bit_io(&eb->bflags, EXTENT_BUFFER_READING,
+		       TASK_UNINTERRUPTIBLE);
+	if (!test_bit(EXTENT_BUFFER_UPTODATE, &eb->bflags))
+		ret = -EIO;
 	return ret;
 }
 
@@ -5533,7 +5694,6 @@ void write_extent_buffer_chunk_tree_uuid(struct extent_buffer *eb,
 {
 	char *kaddr;
 
-	WARN_ON(!PageUptodate(eb->pages[0]));
 	kaddr = page_address(eb->pages[0]);
 	memcpy(kaddr + offsetof(struct btrfs_header, chunk_tree_uuid), srcv,
 			BTRFS_FSID_SIZE);
@@ -5543,7 +5703,6 @@ void write_extent_buffer_fsid(struct extent_buffer *eb, const void *srcv)
 {
 	char *kaddr;
 
-	WARN_ON(!PageUptodate(eb->pages[0]));
 	kaddr = page_address(eb->pages[0]);
 	memcpy(kaddr + offsetof(struct btrfs_header, fsid), srcv,
 			BTRFS_FSID_SIZE);
@@ -5567,7 +5726,6 @@ void write_extent_buffer(struct extent_buffer *eb, const void *srcv,
 
 	while (len > 0) {
 		page = eb->pages[i];
-		WARN_ON(!PageUptodate(page));
 
 		cur = min(len, PAGE_SIZE - offset);
 		kaddr = page_address(page);
@@ -5597,7 +5755,6 @@ void memzero_extent_buffer(struct extent_buffer *eb, unsigned long start,
 
 	while (len > 0) {
 		page = eb->pages[i];
-		WARN_ON(!PageUptodate(page));
 
 		cur = min(len, PAGE_SIZE - offset);
 		kaddr = page_address(page);
@@ -5642,7 +5799,6 @@ void copy_extent_buffer(struct extent_buffer *dst, struct extent_buffer *src,
 
 	while (len > 0) {
 		page = dst->pages[i];
-		WARN_ON(!PageUptodate(page));
 
 		cur = min(len, (unsigned long)(PAGE_SIZE - offset));
 
@@ -5745,7 +5901,6 @@ int extent_buffer_test_bit(struct extent_buffer *eb, unsigned long start,
 
 	eb_bitmap_offset(eb, start, nr, &i, &offset);
 	page = eb->pages[i];
-	WARN_ON(!PageUptodate(page));
 	kaddr = page_address(page);
 	return 1U & (kaddr[offset] >> (nr & (BITS_PER_BYTE - 1)));
 }
@@ -5770,7 +5925,6 @@ void extent_buffer_bitmap_set(struct extent_buffer *eb, unsigned long start,
 
 	eb_bitmap_offset(eb, start, pos, &i, &offset);
 	page = eb->pages[i];
-	WARN_ON(!PageUptodate(page));
 	kaddr = page_address(page);
 
 	while (len >= bits_to_set) {
@@ -5781,7 +5935,6 @@ void extent_buffer_bitmap_set(struct extent_buffer *eb, unsigned long start,
 		if (++offset >= PAGE_SIZE && len > 0) {
 			offset = 0;
 			page = eb->pages[++i];
-			WARN_ON(!PageUptodate(page));
 			kaddr = page_address(page);
 		}
 	}
@@ -5812,7 +5965,6 @@ void extent_buffer_bitmap_clear(struct extent_buffer *eb, unsigned long start,
 
 	eb_bitmap_offset(eb, start, pos, &i, &offset);
 	page = eb->pages[i];
-	WARN_ON(!PageUptodate(page));
 	kaddr = page_address(page);
 
 	while (len >= bits_to_clear) {
@@ -5823,7 +5975,6 @@ void extent_buffer_bitmap_clear(struct extent_buffer *eb, unsigned long start,
 		if (++offset >= PAGE_SIZE && len > 0) {
 			offset = 0;
 			page = eb->pages[++i];
-			WARN_ON(!PageUptodate(page));
 			kaddr = page_address(page);
 		}
 	}
@@ -5864,7 +6015,7 @@ static void copy_pages(struct page *dst_page, struct page *src_page,
 void memcpy_extent_buffer(struct extent_buffer *dst, unsigned long dst_offset,
 			   unsigned long src_offset, unsigned long len)
 {
-	struct btrfs_fs_info *fs_info = dst->fs_info;
+	struct btrfs_fs_info *fs_info = dst->eb_info->fs_info;
 	size_t cur;
 	size_t dst_off_in_page;
 	size_t src_off_in_page;
@@ -5911,7 +6062,7 @@ void memcpy_extent_buffer(struct extent_buffer *dst, unsigned long dst_offset,
 void memmove_extent_buffer(struct extent_buffer *dst, unsigned long dst_offset,
 			   unsigned long src_offset, unsigned long len)
 {
-	struct btrfs_fs_info *fs_info = dst->fs_info;
+	struct btrfs_fs_info *fs_info = dst->eb_info->fs_info;
 	size_t cur;
 	size_t dst_off_in_page;
 	size_t src_off_in_page;
@@ -5957,45 +6108,3 @@ void memmove_extent_buffer(struct extent_buffer *dst, unsigned long dst_offset,
 		len -= cur;
 	}
 }
-
-int try_release_extent_buffer(struct page *page)
-{
-	struct extent_buffer *eb;
-
-	/*
-	 * We need to make sure nobody is attaching this page to an eb right
-	 * now.
-	 */
-	spin_lock(&page->mapping->private_lock);
-	if (!PagePrivate(page)) {
-		spin_unlock(&page->mapping->private_lock);
-		return 1;
-	}
-
-	eb = (struct extent_buffer *)page->private;
-	BUG_ON(!eb);
-
-	/*
-	 * This is a little awful but should be ok, we need to make sure that
-	 * the eb doesn't disappear out from under us while we're looking at
-	 * this page.
-	 */
-	spin_lock(&eb->refs_lock);
-	if (atomic_read(&eb->refs) != 1 || extent_buffer_under_io(eb)) {
-		spin_unlock(&eb->refs_lock);
-		spin_unlock(&page->mapping->private_lock);
-		return 0;
-	}
-	spin_unlock(&page->mapping->private_lock);
-
-	/*
-	 * If tree ref isn't set then we know the ref on this eb is a real ref,
-	 * so just return, this page will likely be freed soon anyway.
-	 */
-	if (!test_and_clear_bit(EXTENT_BUFFER_TREE_REF, &eb->bflags)) {
-		spin_unlock(&eb->refs_lock);
-		return 0;
-	}
-
-	return release_extent_buffer(eb);
-}
diff --git a/fs/btrfs/extent_io.h b/fs/btrfs/extent_io.h
index 861dacb371c7..f18cbce1f2f1 100644
--- a/fs/btrfs/extent_io.h
+++ b/fs/btrfs/extent_io.h
@@ -47,6 +47,8 @@
 #define EXTENT_BUFFER_DUMMY 9
 #define EXTENT_BUFFER_IN_TREE 10
 #define EXTENT_BUFFER_WRITE_ERR 11    /* write IO error */
+#define EXTENT_BUFFER_MIXED_PAGES 12	/* the pages span multiple zones or numa nodes. */
+#define EXTENT_BUFFER_READING 13 /* currently reading this eb. */
 
 /* these are flags for __process_pages_contig */
 #define PAGE_UNLOCK		(1 << 0)
@@ -160,13 +162,25 @@ struct extent_state {
 #endif
 };
 
+struct btrfs_eb_info {
+	struct btrfs_fs_info *fs_info;
+	struct extent_io_tree io_tree;
+	struct extent_io_tree io_failure_tree;
+
+	/* Extent buffer radix tree */
+	spinlock_t buffer_lock;
+	struct radix_tree_root buffer_radix;
+	struct list_lru lru_list;
+	pgoff_t writeback_index;
+};
+
 #define INLINE_EXTENT_BUFFER_PAGES 16
 #define MAX_INLINE_EXTENT_BUFFER_SIZE (INLINE_EXTENT_BUFFER_PAGES * PAGE_SIZE)
 struct extent_buffer {
 	u64 start;
 	unsigned long len;
 	unsigned long bflags;
-	struct btrfs_fs_info *fs_info;
+	struct btrfs_eb_info *eb_info;
 	spinlock_t refs_lock;
 	atomic_t refs;
 	atomic_t io_pages;
@@ -201,6 +215,7 @@ struct extent_buffer {
 #ifdef CONFIG_BTRFS_DEBUG
 	struct list_head leak_list;
 #endif
+	struct list_head lru;
 };
 
 /*
@@ -408,8 +423,6 @@ int extent_writepages(struct extent_io_tree *tree,
 		      struct address_space *mapping,
 		      get_extent_t *get_extent,
 		      struct writeback_control *wbc);
-int btree_write_cache_pages(struct address_space *mapping,
-			    struct writeback_control *wbc);
 int extent_readpages(struct extent_io_tree *tree,
 		     struct address_space *mapping,
 		     struct list_head *pages, unsigned nr_pages,
@@ -420,21 +433,18 @@ void set_page_extent_mapped(struct page *page);
 
 struct extent_buffer *alloc_extent_buffer(struct btrfs_fs_info *fs_info,
 					  u64 start);
-struct extent_buffer *__alloc_dummy_extent_buffer(struct btrfs_fs_info *fs_info,
-						  u64 start, unsigned long len);
-struct extent_buffer *alloc_dummy_extent_buffer(struct btrfs_fs_info *fs_info,
-						u64 start);
+struct extent_buffer *alloc_dummy_extent_buffer(struct btrfs_eb_info *eb_info,
+						u64 start, unsigned long len);
 struct extent_buffer *btrfs_clone_extent_buffer(struct extent_buffer *src);
-struct extent_buffer *find_extent_buffer(struct btrfs_fs_info *fs_info,
+struct extent_buffer *find_extent_buffer(struct btrfs_eb_info *eb_info,
 					 u64 start);
 void free_extent_buffer(struct extent_buffer *eb);
 void free_extent_buffer_stale(struct extent_buffer *eb);
 #define WAIT_NONE	0
 #define WAIT_COMPLETE	1
 #define WAIT_PAGE_LOCK	2
-int read_extent_buffer_pages(struct extent_io_tree *tree,
-			     struct extent_buffer *eb, int wait,
-			     get_extent_t *get_extent, int mirror_num);
+int read_extent_buffer_pages(struct extent_buffer *eb, int wait,
+			     int mirror_num);
 void wait_on_extent_buffer_writeback(struct extent_buffer *eb);
 
 static inline unsigned long num_extent_pages(u64 start, u64 len)
@@ -448,6 +458,11 @@ static inline void extent_buffer_get(struct extent_buffer *eb)
 	atomic_inc(&eb->refs);
 }
 
+static inline unsigned long eb_index(struct extent_buffer *eb)
+{
+	return eb->start >> PAGE_SHIFT;
+}
+
 int memcmp_extent_buffer(const struct extent_buffer *eb, const void *ptrv,
 			 unsigned long start, unsigned long len);
 void read_extent_buffer(const struct extent_buffer *eb, void *dst,
@@ -478,7 +493,7 @@ void extent_buffer_bitmap_set(struct extent_buffer *eb, unsigned long start,
 			      unsigned long pos, unsigned long len);
 void extent_buffer_bitmap_clear(struct extent_buffer *eb, unsigned long start,
 				unsigned long pos, unsigned long len);
-void clear_extent_buffer_dirty(struct extent_buffer *eb);
+int clear_extent_buffer_dirty(struct extent_buffer *eb);
 int set_extent_buffer_dirty(struct extent_buffer *eb);
 void set_extent_buffer_uptodate(struct extent_buffer *eb);
 void clear_extent_buffer_uptodate(struct extent_buffer *eb);
@@ -512,6 +527,14 @@ int clean_io_failure(struct btrfs_fs_info *fs_info,
 void end_extent_writepage(struct page *page, int err, u64 start, u64 end);
 int repair_eb_io_failure(struct btrfs_fs_info *fs_info,
 			 struct extent_buffer *eb, int mirror_num);
+void btree_flush(struct btrfs_fs_info *fs_info);
+int btree_write_range(struct btrfs_fs_info *fs_info, u64 start, u64 end);
+int btree_wait_range(struct btrfs_fs_info *fs_info, u64 start, u64 end);
+long btrfs_free_ebs(struct super_block *sb, struct shrink_control *sc);
+long btrfs_nr_ebs(struct super_block *sb, struct shrink_control *sc);
+void btrfs_write_ebs(struct super_block *sb, struct writeback_control *wbc);
+void btrfs_invalidate_eb_info(struct btrfs_eb_info *eb_info);
+int btrfs_init_eb_info(struct btrfs_fs_info *fs_info);
 
 /*
  * When IO fails, either with EIO or csum verification fails, we
@@ -552,6 +575,6 @@ noinline u64 find_lock_delalloc_range(struct inode *inode,
 				      struct page *locked_page, u64 *start,
 				      u64 *end, u64 max_bytes);
 #endif
-struct extent_buffer *alloc_test_extent_buffer(struct btrfs_fs_info *fs_info,
-					       u64 start);
+struct extent_buffer *alloc_test_extent_buffer(struct btrfs_eb_info *eb_info,
+					       u64 start, u32 nodesize);
 #endif
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 46b5632a7c6d..27bc64fb6d3e 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -1877,9 +1877,9 @@ static void btrfs_clear_bit_hook(void *private_data,
  * return 0 if page can be merged to bio
  * return error otherwise
  */
-int btrfs_merge_bio_hook(struct page *page, unsigned long offset,
-			 size_t size, struct bio *bio,
-			 unsigned long bio_flags)
+static int btrfs_merge_bio_hook(struct page *page, unsigned long offset,
+				size_t size, struct bio *bio,
+				unsigned long bio_flags)
 {
 	struct inode *inode = page->mapping->host;
 	struct btrfs_fs_info *fs_info = btrfs_sb(inode->i_sb);
diff --git a/fs/btrfs/print-tree.c b/fs/btrfs/print-tree.c
index 569205e651c7..f912c8166d94 100644
--- a/fs/btrfs/print-tree.c
+++ b/fs/btrfs/print-tree.c
@@ -102,6 +102,7 @@ static void print_extent_item(struct extent_buffer *eb, int slot, int type)
 	ptr = (unsigned long)iref;
 	end = (unsigned long)ei + item_size;
 	while (ptr < end) {
+		struct btrfs_fs_info *fs_info = eb->eb_info->fs_info;
 		iref = (struct btrfs_extent_inline_ref *)ptr;
 		type = btrfs_extent_inline_ref_type(eb, iref);
 		offset = btrfs_extent_inline_ref_offset(eb, iref);
@@ -116,9 +117,9 @@ static void print_extent_item(struct extent_buffer *eb, int slot, int type)
 			 * offset is supposed to be a tree block which
 			 * must be aligned to nodesize.
 			 */
-			if (!IS_ALIGNED(offset, eb->fs_info->nodesize))
+			if (!IS_ALIGNED(offset, fs_info->nodesize))
 				pr_info("\t\t\t(parent %llu is NOT ALIGNED to nodesize %llu)\n",
-					offset, (unsigned long long)eb->fs_info->nodesize);
+					offset, (unsigned long long)fs_info->nodesize);
 			break;
 		case BTRFS_EXTENT_DATA_REF_KEY:
 			dref = (struct btrfs_extent_data_ref *)(&iref->offset);
@@ -132,9 +133,9 @@ static void print_extent_item(struct extent_buffer *eb, int slot, int type)
 			 * offset is supposed to be a tree block which
 			 * must be aligned to nodesize.
 			 */
-			if (!IS_ALIGNED(offset, eb->fs_info->nodesize))
+			if (!IS_ALIGNED(offset, fs_info->nodesize))
 				pr_info("\t\t\t(parent %llu is NOT ALIGNED to nodesize %llu)\n",
-				     offset, (unsigned long long)eb->fs_info->nodesize);
+				     offset, (unsigned long long)fs_info->nodesize);
 			break;
 		default:
 			pr_cont("(extent %llu has INVALID ref type %d)\n",
@@ -199,7 +200,7 @@ void btrfs_print_leaf(struct extent_buffer *l)
 	if (!l)
 		return;
 
-	fs_info = l->fs_info;
+	fs_info = l->eb_info->fs_info;
 	nr = btrfs_header_nritems(l);
 
 	btrfs_info(fs_info, "leaf %llu total ptrs %d free space %d",
@@ -347,7 +348,7 @@ void btrfs_print_tree(struct extent_buffer *c)
 
 	if (!c)
 		return;
-	fs_info = c->fs_info;
+	fs_info = c->eb_info->fs_info;
 	nr = btrfs_header_nritems(c);
 	level = btrfs_header_level(c);
 	if (level == 0) {
diff --git a/fs/btrfs/reada.c b/fs/btrfs/reada.c
index ab852b8e3e37..c6244890085f 100644
--- a/fs/btrfs/reada.c
+++ b/fs/btrfs/reada.c
@@ -210,7 +210,7 @@ static void __readahead_hook(struct btrfs_fs_info *fs_info,
 
 int btree_readahead_hook(struct extent_buffer *eb, int err)
 {
-	struct btrfs_fs_info *fs_info = eb->fs_info;
+	struct btrfs_fs_info *fs_info = eb->eb_info->fs_info;
 	int ret = 0;
 	struct reada_extent *re;
 
diff --git a/fs/btrfs/root-tree.c b/fs/btrfs/root-tree.c
index 3338407ef0f0..e40bd9a910dd 100644
--- a/fs/btrfs/root-tree.c
+++ b/fs/btrfs/root-tree.c
@@ -45,7 +45,7 @@ static void btrfs_read_root_item(struct extent_buffer *eb, int slot,
 	if (!need_reset && btrfs_root_generation(item)
 		!= btrfs_root_generation_v2(item)) {
 		if (btrfs_root_generation_v2(item) != 0) {
-			btrfs_warn(eb->fs_info,
+			btrfs_warn(eb->eb_info->fs_info,
 					"mismatching generation and generation_v2 found in root item. This root was probably mounted with an older kernel. Resetting all new fields.");
 		}
 		need_reset = 1;
diff --git a/fs/btrfs/super.c b/fs/btrfs/super.c
index 8e74f7029e12..3b5fe791639d 100644
--- a/fs/btrfs/super.c
+++ b/fs/btrfs/super.c
@@ -1198,7 +1198,7 @@ int btrfs_sync_fs(struct super_block *sb, int wait)
 	trace_btrfs_sync_fs(fs_info, wait);
 
 	if (!wait) {
-		filemap_flush(fs_info->btree_inode->i_mapping);
+		btree_flush(fs_info);
 		return 0;
 	}
 
@@ -2284,19 +2284,22 @@ static int btrfs_show_devname(struct seq_file *m, struct dentry *root)
 }
 
 static const struct super_operations btrfs_super_ops = {
-	.drop_inode	= btrfs_drop_inode,
-	.evict_inode	= btrfs_evict_inode,
-	.put_super	= btrfs_put_super,
-	.sync_fs	= btrfs_sync_fs,
-	.show_options	= btrfs_show_options,
-	.show_devname	= btrfs_show_devname,
-	.write_inode	= btrfs_write_inode,
-	.alloc_inode	= btrfs_alloc_inode,
-	.destroy_inode	= btrfs_destroy_inode,
-	.statfs		= btrfs_statfs,
-	.remount_fs	= btrfs_remount,
-	.freeze_fs	= btrfs_freeze,
-	.unfreeze_fs	= btrfs_unfreeze,
+	.drop_inode		= btrfs_drop_inode,
+	.evict_inode		= btrfs_evict_inode,
+	.put_super		= btrfs_put_super,
+	.sync_fs		= btrfs_sync_fs,
+	.show_options		= btrfs_show_options,
+	.show_devname		= btrfs_show_devname,
+	.write_inode		= btrfs_write_inode,
+	.alloc_inode		= btrfs_alloc_inode,
+	.destroy_inode		= btrfs_destroy_inode,
+	.statfs			= btrfs_statfs,
+	.remount_fs		= btrfs_remount,
+	.freeze_fs		= btrfs_freeze,
+	.unfreeze_fs		= btrfs_unfreeze,
+	.nr_cached_objects	= btrfs_nr_ebs,
+	.free_cached_objects	= btrfs_free_ebs,
+	.write_metadata		= btrfs_write_ebs,
 };
 
 static const struct file_operations btrfs_ctl_fops = {
diff --git a/fs/btrfs/tests/btrfs-tests.c b/fs/btrfs/tests/btrfs-tests.c
index d3f25376a0f8..dbf05b2ab9ee 100644
--- a/fs/btrfs/tests/btrfs-tests.c
+++ b/fs/btrfs/tests/btrfs-tests.c
@@ -102,15 +102,32 @@ struct btrfs_fs_info *btrfs_alloc_dummy_fs_info(u32 nodesize, u32 sectorsize)
 
 	fs_info->nodesize = nodesize;
 	fs_info->sectorsize = sectorsize;
+	fs_info->eb_info = kzalloc(sizeof(struct btrfs_eb_info),
+				   GFP_KERNEL);
+	if (!fs_info->eb_info) {
+		kfree(fs_info->fs_devices);
+		kfree(fs_info->super_copy);
+		kfree(fs_info);
+		return NULL;
+	}
+
+	if (btrfs_init_eb_info(fs_info)) {
+		kfree(fs_info->eb_info);
+		kfree(fs_info->fs_devices);
+		kfree(fs_info->super_copy);
+		kfree(fs_info);
+		return NULL;
+	}
 
 	if (init_srcu_struct(&fs_info->subvol_srcu)) {
+		list_lru_destroy(&fs_info->eb_info->lru_list);
+		kfree(fs_info->eb_info);
 		kfree(fs_info->fs_devices);
 		kfree(fs_info->super_copy);
 		kfree(fs_info);
 		return NULL;
 	}
 
-	spin_lock_init(&fs_info->buffer_lock);
 	spin_lock_init(&fs_info->qgroup_lock);
 	spin_lock_init(&fs_info->qgroup_op_lock);
 	spin_lock_init(&fs_info->super_lock);
@@ -126,7 +143,6 @@ struct btrfs_fs_info *btrfs_alloc_dummy_fs_info(u32 nodesize, u32 sectorsize)
 	INIT_LIST_HEAD(&fs_info->dirty_qgroups);
 	INIT_LIST_HEAD(&fs_info->dead_roots);
 	INIT_LIST_HEAD(&fs_info->tree_mod_seq_list);
-	INIT_RADIX_TREE(&fs_info->buffer_radix, GFP_ATOMIC);
 	INIT_RADIX_TREE(&fs_info->fs_roots_radix, GFP_ATOMIC);
 	extent_io_tree_init(&fs_info->freed_extents[0], NULL);
 	extent_io_tree_init(&fs_info->freed_extents[1], NULL);
@@ -140,6 +156,7 @@ struct btrfs_fs_info *btrfs_alloc_dummy_fs_info(u32 nodesize, u32 sectorsize)
 
 void btrfs_free_dummy_fs_info(struct btrfs_fs_info *fs_info)
 {
+	struct btrfs_eb_info *eb_info;
 	struct radix_tree_iter iter;
 	void **slot;
 
@@ -150,13 +167,14 @@ void btrfs_free_dummy_fs_info(struct btrfs_fs_info *fs_info)
 			      &fs_info->fs_state)))
 		return;
 
+	eb_info = fs_info->eb_info;
 	test_mnt->mnt_sb->s_fs_info = NULL;
 
-	spin_lock(&fs_info->buffer_lock);
-	radix_tree_for_each_slot(slot, &fs_info->buffer_radix, &iter, 0) {
+	spin_lock_irq(&eb_info->buffer_lock);
+	radix_tree_for_each_slot(slot, &eb_info->buffer_radix, &iter, 0) {
 		struct extent_buffer *eb;
 
-		eb = radix_tree_deref_slot_protected(slot, &fs_info->buffer_lock);
+		eb = radix_tree_deref_slot_protected(slot, &eb_info->buffer_lock);
 		if (!eb)
 			continue;
 		/* Shouldn't happen but that kind of thinking creates CVE's */
@@ -166,15 +184,17 @@ void btrfs_free_dummy_fs_info(struct btrfs_fs_info *fs_info)
 			continue;
 		}
 		slot = radix_tree_iter_resume(slot, &iter);
-		spin_unlock(&fs_info->buffer_lock);
+		spin_unlock_irq(&eb_info->buffer_lock);
 		free_extent_buffer_stale(eb);
-		spin_lock(&fs_info->buffer_lock);
+		spin_lock_irq(&eb_info->buffer_lock);
 	}
-	spin_unlock(&fs_info->buffer_lock);
+	spin_unlock_irq(&eb_info->buffer_lock);
 
 	btrfs_free_qgroup_config(fs_info);
 	btrfs_free_fs_roots(fs_info);
 	cleanup_srcu_struct(&fs_info->subvol_srcu);
+	list_lru_destroy(&eb_info->lru_list);
+	kfree(fs_info->eb_info);
 	kfree(fs_info->super_copy);
 	kfree(fs_info->fs_devices);
 	kfree(fs_info);
diff --git a/fs/btrfs/tests/extent-buffer-tests.c b/fs/btrfs/tests/extent-buffer-tests.c
index b9142c614114..9a264b81a7b4 100644
--- a/fs/btrfs/tests/extent-buffer-tests.c
+++ b/fs/btrfs/tests/extent-buffer-tests.c
@@ -61,7 +61,8 @@ static int test_btrfs_split_item(u32 sectorsize, u32 nodesize)
 		goto out;
 	}
 
-	path->nodes[0] = eb = alloc_dummy_extent_buffer(fs_info, nodesize);
+	path->nodes[0] = eb = alloc_dummy_extent_buffer(fs_info->eb_info, 0,
+							nodesize);
 	if (!eb) {
 		test_msg("Could not allocate dummy buffer\n");
 		ret = -ENOMEM;
diff --git a/fs/btrfs/tests/extent-io-tests.c b/fs/btrfs/tests/extent-io-tests.c
index d06b1c931d05..600c01ddf0d0 100644
--- a/fs/btrfs/tests/extent-io-tests.c
+++ b/fs/btrfs/tests/extent-io-tests.c
@@ -406,7 +406,7 @@ static int test_eb_bitmaps(u32 sectorsize, u32 nodesize)
 		return -ENOMEM;
 	}
 
-	eb = __alloc_dummy_extent_buffer(fs_info, 0, len);
+	eb = alloc_dummy_extent_buffer(NULL, 0, len);
 	if (!eb) {
 		test_msg("Couldn't allocate test extent buffer\n");
 		kfree(bitmap);
@@ -419,7 +419,7 @@ static int test_eb_bitmaps(u32 sectorsize, u32 nodesize)
 
 	/* Do it over again with an extent buffer which isn't page-aligned. */
 	free_extent_buffer(eb);
-	eb = __alloc_dummy_extent_buffer(NULL, nodesize / 2, len);
+	eb = alloc_dummy_extent_buffer(NULL, nodesize / 2, len);
 	if (!eb) {
 		test_msg("Couldn't allocate test extent buffer\n");
 		kfree(bitmap);
diff --git a/fs/btrfs/tests/free-space-tree-tests.c b/fs/btrfs/tests/free-space-tree-tests.c
index 8444a018cca2..afba937f4365 100644
--- a/fs/btrfs/tests/free-space-tree-tests.c
+++ b/fs/btrfs/tests/free-space-tree-tests.c
@@ -474,7 +474,8 @@ static int run_test(test_func_t test_func, int bitmaps, u32 sectorsize,
 	root->fs_info->free_space_root = root;
 	root->fs_info->tree_root = root;
 
-	root->node = alloc_test_extent_buffer(root->fs_info, nodesize);
+	root->node = alloc_test_extent_buffer(fs_info->eb_info, nodesize,
+					      nodesize);
 	if (!root->node) {
 		test_msg("Couldn't allocate dummy buffer\n");
 		ret = -ENOMEM;
diff --git a/fs/btrfs/tests/inode-tests.c b/fs/btrfs/tests/inode-tests.c
index 11c77eafde00..486aa7fbfce2 100644
--- a/fs/btrfs/tests/inode-tests.c
+++ b/fs/btrfs/tests/inode-tests.c
@@ -261,7 +261,7 @@ static noinline int test_btrfs_get_extent(u32 sectorsize, u32 nodesize)
 		goto out;
 	}
 
-	root->node = alloc_dummy_extent_buffer(fs_info, nodesize);
+	root->node = alloc_dummy_extent_buffer(fs_info->eb_info, 0, nodesize);
 	if (!root->node) {
 		test_msg("Couldn't allocate dummy buffer\n");
 		goto out;
@@ -867,7 +867,7 @@ static int test_hole_first(u32 sectorsize, u32 nodesize)
 		goto out;
 	}
 
-	root->node = alloc_dummy_extent_buffer(fs_info, nodesize);
+	root->node = alloc_dummy_extent_buffer(fs_info->eb_info, 0, nodesize);
 	if (!root->node) {
 		test_msg("Couldn't allocate dummy buffer\n");
 		goto out;
diff --git a/fs/btrfs/tests/qgroup-tests.c b/fs/btrfs/tests/qgroup-tests.c
index 0f4ce970d195..0ba27cd9ae4c 100644
--- a/fs/btrfs/tests/qgroup-tests.c
+++ b/fs/btrfs/tests/qgroup-tests.c
@@ -486,7 +486,8 @@ int btrfs_test_qgroups(u32 sectorsize, u32 nodesize)
 	 * Can't use bytenr 0, some things freak out
 	 * *cough*backref walking code*cough*
 	 */
-	root->node = alloc_test_extent_buffer(root->fs_info, nodesize);
+	root->node = alloc_test_extent_buffer(fs_info->eb_info, nodesize,
+					      nodesize);
 	if (!root->node) {
 		test_msg("Couldn't allocate dummy buffer\n");
 		ret = -ENOMEM;
diff --git a/fs/btrfs/transaction.c b/fs/btrfs/transaction.c
index 9fed8c67b6e8..5df3963c413e 100644
--- a/fs/btrfs/transaction.c
+++ b/fs/btrfs/transaction.c
@@ -293,8 +293,7 @@ static noinline int join_transaction(struct btrfs_fs_info *fs_info,
 	INIT_LIST_HEAD(&cur_trans->deleted_bgs);
 	spin_lock_init(&cur_trans->dropped_roots_lock);
 	list_add_tail(&cur_trans->list, &fs_info->trans_list);
-	extent_io_tree_init(&cur_trans->dirty_pages,
-			     fs_info->btree_inode);
+	extent_io_tree_init(&cur_trans->dirty_pages, NULL);
 	fs_info->generation++;
 	cur_trans->transid = fs_info->generation;
 	fs_info->running_transaction = cur_trans;
@@ -944,12 +943,10 @@ int btrfs_write_marked_extents(struct btrfs_fs_info *fs_info,
 {
 	int err = 0;
 	int werr = 0;
-	struct address_space *mapping = fs_info->btree_inode->i_mapping;
 	struct extent_state *cached_state = NULL;
 	u64 start = 0;
 	u64 end;
 
-	atomic_inc(&BTRFS_I(fs_info->btree_inode)->sync_writers);
 	while (!find_first_extent_bit(dirty_pages, start, &start, &end,
 				      mark, &cached_state)) {
 		bool wait_writeback = false;
@@ -975,17 +972,16 @@ int btrfs_write_marked_extents(struct btrfs_fs_info *fs_info,
 			wait_writeback = true;
 		}
 		if (!err)
-			err = filemap_fdatawrite_range(mapping, start, end);
+			err = btree_write_range(fs_info, start, end);
 		if (err)
 			werr = err;
 		else if (wait_writeback)
-			werr = filemap_fdatawait_range(mapping, start, end);
+			werr = btree_wait_range(fs_info, start, end);
 		free_extent_state(cached_state);
 		cached_state = NULL;
 		cond_resched();
 		start = end + 1;
 	}
-	atomic_dec(&BTRFS_I(fs_info->btree_inode)->sync_writers);
 	return werr;
 }
 
@@ -1000,7 +996,6 @@ static int __btrfs_wait_marked_extents(struct btrfs_fs_info *fs_info,
 {
 	int err = 0;
 	int werr = 0;
-	struct address_space *mapping = fs_info->btree_inode->i_mapping;
 	struct extent_state *cached_state = NULL;
 	u64 start = 0;
 	u64 end;
@@ -1021,7 +1016,7 @@ static int __btrfs_wait_marked_extents(struct btrfs_fs_info *fs_info,
 		if (err == -ENOMEM)
 			err = 0;
 		if (!err)
-			err = filemap_fdatawait_range(mapping, start, end);
+			err = btree_wait_range(fs_info, start, end);
 		if (err)
 			werr = err;
 		free_extent_state(cached_state);
-- 
2.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
