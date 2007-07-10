Date: Tue, 10 Jul 2007 17:03:26 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: [PATCH RFC] extent mapped page cache
Message-ID: <20070710210326.GA29963@think.oraclecorp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patch aims to demonstrate one way to replace buffer heads with a few
extent trees.  Buffer heads provide a few different features:

1) Mapping of logical file offset to blocks on disk
2) Recording state (dirty, locked etc)
3) Providing a mechanism to access sub-page sized blocks.

This patch covers #1 and #2, I'll start on #3 a little later next week.

The file offset to disk block mapping is done in one radix tree, and the
state is done in a second radix tree.  Extent ranges are stored in the
radix trees by inserting into the slot corresponding to the end of the range,
and always using gang lookups for searching.

The basic implementation mirrors the page and buffer bits already used, but
allows state bits to be set on regions smaller or larger than a single page.
Eventually I would like to use this mechanism to replace my DIO
locking/placeholder patch.

Ext2 is changed to use the extent mapping code when mounted with -o extentmap.
DIO is not supported and readpages/writepages are not yet implemented, but
this should be enough to get the basic idea across.  Testing has been
very very light, I'm mostly sending this out for comments and to continue
the discussion started by Nick's patch set.

diff -r 126111346f94 fs/Makefile
--- a/fs/Makefile	Mon Jul 09 10:53:57 2007 -0400
+++ b/fs/Makefile	Tue Jul 10 16:49:26 2007 -0400
@@ -11,7 +11,7 @@ obj-y :=	open.o read_write.o file_table.
 		attr.o bad_inode.o file.o filesystems.o namespace.o aio.o \
 		seq_file.o xattr.o libfs.o fs-writeback.o \
 		pnode.o drop_caches.o splice.o sync.o utimes.o \
-		stack.o
+		stack.o extent_map.o
 
 ifeq ($(CONFIG_BLOCK),y)
 obj-y +=	buffer.o bio.o block_dev.o direct-io.o mpage.o ioprio.o
diff -r 126111346f94 fs/ext2/ext2.h
--- a/fs/ext2/ext2.h	Mon Jul 09 10:53:57 2007 -0400
+++ b/fs/ext2/ext2.h	Tue Jul 10 16:49:26 2007 -0400
@@ -1,5 +1,6 @@
 #include <linux/fs.h>
 #include <linux/ext2_fs.h>
+#include <linux/extent_map.h>
 
 /*
  * ext2 mount options
@@ -65,6 +66,7 @@ struct ext2_inode_info {
 	struct posix_acl	*i_default_acl;
 #endif
 	rwlock_t i_meta_lock;
+	struct extent_map_tree extent_tree;
 	struct inode	vfs_inode;
 };
 
@@ -167,6 +169,7 @@ extern const struct address_space_operat
 extern const struct address_space_operations ext2_aops;
 extern const struct address_space_operations ext2_aops_xip;
 extern const struct address_space_operations ext2_nobh_aops;
+extern const struct address_space_operations ext2_extent_map_aops;
 
 /* namei.c */
 extern const struct inode_operations ext2_dir_inode_operations;
diff -r 126111346f94 fs/ext2/inode.c
--- a/fs/ext2/inode.c	Mon Jul 09 10:53:57 2007 -0400
+++ b/fs/ext2/inode.c	Tue Jul 10 16:49:26 2007 -0400
@@ -625,6 +625,78 @@ changed:
 	goto reread;
 }
 
+/*
+ * simple get_extent implementation using get_block.  This assumes
+ * the get_block function can return something larger than a single block,
+ * but the ext2 implementation doesn't do so.  Just change b_size to
+ * something larger if get_block can return larger extents.
+ */
+struct extent_map *ext2_get_extent(struct inode *inode, struct page *page,
+				   size_t page_offset, u64 start, u64 end,
+				   int create)
+{
+	struct buffer_head bh;
+	sector_t iblock;
+	struct extent_map *em = NULL;
+	struct extent_map_tree *extent_tree = &EXT2_I(inode)->extent_tree;
+	int ret = 0;
+	u64 max_end = (u64)-1;
+	u64 found_len;
+
+	bh.b_size = inode->i_sb->s_blocksize;
+	bh.b_state = 0;
+again:
+	em = lookup_extent_mapping(extent_tree, start, end);
+	if (em)
+		return em;
+
+	iblock = start >> inode->i_blkbits;
+	if (!buffer_mapped(&bh)) {
+		ret = ext2_get_block(inode, iblock, &bh, create);
+		if (ret)
+			goto out;
+	}
+
+	found_len = min((u64)(bh.b_size), max_end - start);
+	if (!em)
+		em = alloc_extent_map(GFP_NOFS);
+
+	em->start = start;
+	em->end = start + found_len - 1;
+	em->bdev = inode->i_sb->s_bdev;
+
+	if (!buffer_mapped(&bh)) {
+		em->block_start = 0;
+		em->block_end = 0;
+	} else {
+		em->block_start = bh.b_blocknr << inode->i_blkbits;
+		em->block_end = em->block_start + found_len - 1;
+	}
+
+	ret = add_extent_mapping(extent_tree, em);
+	if (ret == -EEXIST) {
+		max_end = end;
+		goto again;
+	}
+out:
+	if (ret) {
+		if (em)
+			free_extent_map(em);
+		return ERR_PTR(ret);
+	} else if (em && buffer_new(&bh)) {
+		set_extent_new(extent_tree, start, end, GFP_NOFS);
+	}
+	return em;
+}
+
+static int ext2_extent_map_writepage(struct page *page,
+				     struct writeback_control *wbc)
+{
+	struct extent_map_tree *tree;
+	tree = &EXT2_I(page->mapping->host)->extent_tree;
+	return extent_write_full_page(tree, page, ext2_get_extent, wbc);
+}
+
 static int ext2_writepage(struct page *page, struct writeback_control *wbc)
 {
 	return block_write_full_page(page, ext2_get_block, wbc);
@@ -633,6 +705,39 @@ static int ext2_readpage(struct file *fi
 static int ext2_readpage(struct file *file, struct page *page)
 {
 	return mpage_readpage(page, ext2_get_block);
+}
+
+static int ext2_extent_map_readpage(struct file *file, struct page *page)
+{
+	struct extent_map_tree *tree;
+	tree = &EXT2_I(page->mapping->host)->extent_tree;
+	return extent_read_full_page(tree, page, ext2_get_extent);
+}
+
+static int ext2_extent_map_releasepage(struct page *page,
+				       gfp_t unused_gfp_flags)
+{
+	struct extent_map_tree *tree;
+
+	if (page->private != 1)
+		return try_to_free_buffers(page);
+	tree = &EXT2_I(page->mapping->host)->extent_tree;
+	try_release_extent_mapping(tree, page);
+	ClearPagePrivate(page);
+	set_page_private(page, 0);
+	page_cache_release(page);
+	return 1;
+}
+
+
+static void ext2_extent_map_invalidatepage(struct page *page,
+					   unsigned long offset)
+{
+	struct extent_map_tree *tree;
+
+	tree = &EXT2_I(page->mapping->host)->extent_tree;
+	extent_invalidatepage(tree, page, offset);
+	ext2_extent_map_releasepage(page, GFP_NOFS);
 }
 
 static int
@@ -643,10 +748,30 @@ ext2_readpages(struct file *file, struct
 }
 
 static int
+ext2_extent_map_prepare_write(struct file *file, struct page *page,
+			unsigned from, unsigned to)
+{
+	struct extent_map_tree *tree;
+
+	tree = &EXT2_I(page->mapping->host)->extent_tree;
+	return extent_prepare_write(tree, page->mapping->host,
+				    page, from, to, ext2_get_extent);
+}
+
+static int
 ext2_prepare_write(struct file *file, struct page *page,
-			unsigned from, unsigned to)
+		   unsigned from, unsigned to)
 {
 	return block_prepare_write(page,from,to,ext2_get_block);
+}
+
+int ext2_extent_map_commit_write(struct file *file, struct page *page,
+				 unsigned from, unsigned to)
+{
+	struct extent_map_tree *tree;
+
+	tree = &EXT2_I(page->mapping->host)->extent_tree;
+	return extent_commit_write(tree, page->mapping->host, page, from, to);
 }
 
 static int
@@ -713,6 +838,20 @@ const struct address_space_operations ex
 	.direct_IO		= ext2_direct_IO,
 	.writepages		= ext2_writepages,
 	.migratepage		= buffer_migrate_page,
+};
+
+const struct address_space_operations ext2_extent_map_aops = {
+	.readpage		= ext2_extent_map_readpage,
+	.sync_page		= block_sync_page,
+	.invalidatepage		= ext2_extent_map_invalidatepage,
+	.releasepage		= ext2_extent_map_releasepage,
+	.prepare_write		= ext2_extent_map_prepare_write,
+	.commit_write		= ext2_extent_map_commit_write,
+	.writepage		= ext2_extent_map_writepage,
+	// .bmap			= ext2_bmap,
+	// .direct_IO		= ext2_direct_IO,
+	// .writepages		= ext2_writepages,
+	// .migratepage		= buffer_migrate_page,
 };
 
 /*
@@ -1142,11 +1281,16 @@ void ext2_read_inode (struct inode * ino
 
 	if (S_ISREG(inode->i_mode)) {
 		inode->i_op = &ext2_file_inode_operations;
+		extent_map_tree_init(&EXT2_I(inode)->extent_tree,
+				     inode->i_mapping, GFP_NOFS);
 		if (ext2_use_xip(inode->i_sb)) {
 			inode->i_mapping->a_ops = &ext2_aops_xip;
 			inode->i_fop = &ext2_xip_file_operations;
 		} else if (test_opt(inode->i_sb, NOBH)) {
 			inode->i_mapping->a_ops = &ext2_nobh_aops;
+			inode->i_fop = &ext2_file_operations;
+		} else if (test_opt(inode->i_sb, EXTENTMAP)) {
+			inode->i_mapping->a_ops = &ext2_extent_map_aops;
 			inode->i_fop = &ext2_file_operations;
 		} else {
 			inode->i_mapping->a_ops = &ext2_aops;
diff -r 126111346f94 fs/ext2/namei.c
--- a/fs/ext2/namei.c	Mon Jul 09 10:53:57 2007 -0400
+++ b/fs/ext2/namei.c	Tue Jul 10 16:49:26 2007 -0400
@@ -112,6 +112,11 @@ static int ext2_create (struct inode * d
 		if (ext2_use_xip(inode->i_sb)) {
 			inode->i_mapping->a_ops = &ext2_aops_xip;
 			inode->i_fop = &ext2_xip_file_operations;
+		} else if (test_opt(inode->i_sb, EXTENTMAP)) {
+			extent_map_tree_init(&EXT2_I(inode)->extent_tree,
+					     inode->i_mapping, GFP_NOFS);
+			inode->i_mapping->a_ops = &ext2_extent_map_aops;
+			inode->i_fop = &ext2_file_operations;
 		} else if (test_opt(inode->i_sb, NOBH)) {
 			inode->i_mapping->a_ops = &ext2_nobh_aops;
 			inode->i_fop = &ext2_file_operations;
diff -r 126111346f94 fs/ext2/super.c
--- a/fs/ext2/super.c	Mon Jul 09 10:53:57 2007 -0400
+++ b/fs/ext2/super.c	Tue Jul 10 16:49:26 2007 -0400
@@ -319,7 +319,8 @@ enum {
 	Opt_bsd_df, Opt_minix_df, Opt_grpid, Opt_nogrpid,
 	Opt_resgid, Opt_resuid, Opt_sb, Opt_err_cont, Opt_err_panic,
 	Opt_err_ro, Opt_nouid32, Opt_nocheck, Opt_debug,
-	Opt_oldalloc, Opt_orlov, Opt_nobh, Opt_user_xattr, Opt_nouser_xattr,
+	Opt_oldalloc, Opt_orlov, Opt_nobh, Opt_extent_map,
+	Opt_user_xattr, Opt_nouser_xattr,
 	Opt_acl, Opt_noacl, Opt_xip, Opt_ignore, Opt_err, Opt_quota,
 	Opt_usrquota, Opt_grpquota
 };
@@ -344,6 +345,7 @@ static match_table_t tokens = {
 	{Opt_oldalloc, "oldalloc"},
 	{Opt_orlov, "orlov"},
 	{Opt_nobh, "nobh"},
+	{Opt_extent_map, "extentmap"},
 	{Opt_user_xattr, "user_xattr"},
 	{Opt_nouser_xattr, "nouser_xattr"},
 	{Opt_acl, "acl"},
@@ -431,6 +433,9 @@ static int parse_options (char * options
 			break;
 		case Opt_nobh:
 			set_opt (sbi->s_mount_opt, NOBH);
+			break;
+		case Opt_extent_map:
+			set_opt (sbi->s_mount_opt, EXTENTMAP);
 			break;
 #ifdef CONFIG_EXT2_FS_XATTR
 		case Opt_user_xattr:
diff -r 126111346f94 fs/extent_map.c
--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/fs/extent_map.c	Tue Jul 10 16:49:26 2007 -0400
@@ -0,0 +1,1563 @@
+#include <linux/bitops.h>
+#include <linux/slab.h>
+#include <linux/bio.h>
+#include <linux/mm.h>
+#include <linux/gfp.h>
+#include <linux/pagemap.h>
+#include <linux/page-flags.h>
+#include <linux/module.h>
+#include <linux/spinlock.h>
+#include <linux/blkdev.h>
+#include <linux/extent_map.h>
+
+static struct kmem_cache *extent_map_cache;
+static struct kmem_cache *extent_state_cache;
+
+/* bits for the extent state */
+#define EXTENT_DIRTY 1
+#define EXTENT_WRITEBACK (1 << 1)
+#define EXTENT_UPTODATE (1 << 2)
+#define EXTENT_LOCKED (1 << 3)
+#define EXTENT_NEW (1 << 4)
+
+#define EXTENT_IOBITS (EXTENT_LOCKED | EXTENT_WRITEBACK)
+
+void __init extent_map_init(void)
+{
+	extent_map_cache = kmem_cache_create("extent_map",
+					    sizeof(struct extent_map), 0,
+					    SLAB_RECLAIM_ACCOUNT |
+					    SLAB_DESTROY_BY_RCU,
+					    NULL, NULL);
+	extent_state_cache = kmem_cache_create("extent_state",
+					    sizeof(struct extent_state), 0,
+					    SLAB_RECLAIM_ACCOUNT |
+					    SLAB_DESTROY_BY_RCU,
+					    NULL, NULL);
+}
+
+void extent_map_tree_init(struct extent_map_tree *tree,
+			  struct address_space *mapping, gfp_t mask)
+{
+	INIT_RADIX_TREE(&tree->map, GFP_ATOMIC);
+	INIT_RADIX_TREE(&tree->state, GFP_ATOMIC);
+	rwlock_init(&tree->lock);
+	tree->mapping = mapping;
+}
+EXPORT_SYMBOL(extent_map_tree_init);
+
+struct extent_map *alloc_extent_map(gfp_t mask)
+{
+	struct extent_map *em;
+	em = kmem_cache_alloc(extent_map_cache, mask);
+	if (!em || IS_ERR(em))
+		return em;
+	atomic_set(&em->refs, 1);
+	return em;
+}
+EXPORT_SYMBOL(alloc_extent_map);
+
+void free_extent_map(struct extent_map *em)
+{
+	if (atomic_dec_and_test(&em->refs))
+		kmem_cache_free(extent_map_cache, em);
+}
+EXPORT_SYMBOL(free_extent_map);
+
+struct extent_state *alloc_extent_state(gfp_t mask)
+{
+	struct extent_state *state;
+	state = kmem_cache_alloc(extent_state_cache, mask);
+	if (!state || IS_ERR(state))
+		return state;
+	state->state = 0;
+	atomic_set(&state->refs, 1);
+	init_waitqueue_head(&state->wq);
+	return state;
+}
+EXPORT_SYMBOL(alloc_extent_state);
+
+void free_extent_state(struct extent_state *state)
+{
+	if (atomic_dec_and_test(&state->refs))
+		kmem_cache_free(extent_state_cache, state);
+}
+EXPORT_SYMBOL(free_extent_state);
+
+/*
+ * add_extent_mapping tries a simple backward merge with existing
+ * mappings.  The extent_map struct passed in will be inserted into
+ * the tree directly (no copies made, just a reference taken).
+ */
+int add_extent_mapping(struct extent_map_tree *tree,
+		       struct extent_map *em)
+{
+	int ret;
+	struct extent_map *prev;
+
+	atomic_inc(&em->refs);
+	radix_tree_preload(GFP_NOFS);
+	write_lock_irq(&tree->lock);
+	ret = radix_tree_insert(&tree->map, em->end, em);
+	if (em->start != 0) {
+		prev = radix_tree_lookup(&tree->map, em->start - 1);
+		if (prev && ((em->block_start == 0 && prev->block_start == 0) ||
+			     (em->block_start == prev->block_end + 1))) {
+			em->start = prev->start;
+			em->block_start = prev->block_start;
+			radix_tree_delete(&tree->map, prev->end);
+			free_extent_map(prev);
+		}
+	 }
+	radix_tree_preload_end();
+	write_unlock_irq(&tree->lock);
+	return ret;
+}
+EXPORT_SYMBOL(add_extent_mapping);
+
+/*
+ * lookup_extent_mapping returns the first extent_map struct in the
+ * tree that intersects the [start, end] (inclusive) range.  There may
+ * be additional objects in the tree that intersect, so check the object
+ * returned carefully to make sure you don't need additional lookups.
+ */
+struct extent_map *lookup_extent_mapping(struct extent_map_tree *tree,
+					 u64 start, u64 end)
+{
+	struct extent_map *gang[1];
+	struct extent_map *em;
+	int ret;
+
+	read_lock_irq(&tree->lock);
+	ret = radix_tree_gang_lookup(&tree->map, (void **)gang,
+				     start, ARRAY_SIZE(gang));
+	if (ret < 0) {
+		em = ERR_PTR(ret);
+		goto out;
+	}
+	if (ret == 0) {
+		em = NULL;
+		goto out;
+	}
+	em = gang[0];
+	if (em->end < start || em->start > end) {
+		em = NULL;
+		goto out;
+	}
+	atomic_inc(&em->refs);
+out:
+	read_unlock_irq(&tree->lock);
+	return em;
+}
+EXPORT_SYMBOL(lookup_extent_mapping);
+
+/*
+ * removes an extent_map struct from the tree.  No reference counts are
+ * dropped, and no checks are done to  see if the range is in use
+ */
+int remove_extent_mapping(struct extent_map_tree *tree, struct extent_map *em)
+{
+	void *p;
+
+	write_lock_irq(&tree->lock);
+	p = radix_tree_delete(&tree->map, em->end);
+	write_unlock_irq(&tree->lock);
+	if (p)
+		return 0;
+	return -ENOENT;
+}
+EXPORT_SYMBOL(remove_extent_mapping);
+
+/*
+ * insert an extent_state struct into the tree.  'bits' are set on the
+ * struct before it is inserted.
+ *
+ * This may return -EEXIST if the extent is already there, in which case the
+ * state struct is freed.
+ *
+ * The tree lock is not taken internally.  This is a utility function and
+ * probably isn't what you want to call (see set/clear_extent_bit).
+ */
+static int insert_state(struct extent_map_tree *tree,
+			struct extent_state *state, u64 start, u64 end,
+			int bits)
+{
+	int ret;
+
+	state->state |= bits;
+	state->start = start;
+	state->end = end;
+	ret = radix_tree_insert(&tree->state, end, state);
+	if (ret)
+		free_extent_state(state);
+	return ret;
+}
+
+/*
+ * split a given extent state struct in two, inserting the preallocated
+ * struct 'prealloc' as the newly created second half.  'split' indicates an
+ * offset inside 'orig' where it should be split.
+ *
+ * Before calling,
+ * the tree has 'orig' at [orig->start, orig->end].  After calling, there
+ * are two extent state structs in the tree:
+ * prealloc: [orig->start, split - 1]
+ * orig: [ split, orig->end ]
+ *
+ * The tree locks are not taken by this function. They need to be held
+ * by the caller.
+ */
+static int split_state(struct extent_map_tree *tree, struct extent_state *orig,
+		       struct extent_state *prealloc, u64 split)
+{
+	int ret;
+	prealloc->start = orig->start;
+	prealloc->end = split - 1;
+	prealloc->state = orig->state;
+	ret = radix_tree_insert(&tree->state, prealloc->end, prealloc);
+	if (ret) {
+		free_extent_state(prealloc);
+		return ret;
+	}
+	orig->start = split;
+	return 0;
+}
+
+/*
+ * utility function to look for merge candidates inside a given range.
+ * Any extents with matching state are merged together into a single
+ * extent in the tree.  Extents with EXTENT_IO in their state field
+ * are not merged because the end_io handlers need to be able to do
+ * operations on them without sleeping (or doing allocations/splits).
+ *
+ * This should be called with the tree lock held.
+ */
+static int merge_state(struct extent_map_tree *tree, u64 start, u64 end)
+{
+	struct extent_state *gang[2];
+	struct extent_state *state;
+	struct extent_state *next;
+	int i;
+	int ret;
+
+	write_lock_irq(&tree->lock);
+
+	while(start < end) {
+		ret = radix_tree_gang_lookup(&tree->state, (void **)gang,
+					     start - 1, ARRAY_SIZE(gang));
+		if (ret < 2)
+			goto out;
+		for (i = 0; i < ret - 1; i++) {
+			state = gang[i];
+			next = gang[i + 1];
+			if (state->start > end)
+				goto out;
+			if (state->end == next->start - 1 &&
+			    state->state == next->state &&
+			    !(state->state & EXTENT_IOBITS)) {
+				next->start = state->start;
+				radix_tree_delete(&tree->state, state->end);
+				free_extent_state(state);
+			}
+			start = next->end + 1;
+		}
+	}
+out:
+	write_unlock_irq(&tree->lock);
+	return 0;
+}
+
+
+/*
+ * utility function to clear some bits in an extent state struct.
+ * it will optionally wake up any one waiting on this state (wake == 1), or
+ * forcibly remove the state from the tree (delete == 1).
+ *
+ * If no bits are set on the state struct after clearing things, the
+ * struct is freed and removed from the tree
+ */
+static int clear_state_bit(struct extent_map_tree *tree,
+			    struct extent_state *state, int bits, int wake,
+			    int delete)
+{
+	int ret = state->state & bits;
+	state->state &= ~bits;
+
+	if (wake)
+		wake_up(&state->wq);
+	if (delete || state->state == 0) {
+		radix_tree_delete(&tree->state, state->end);
+		free_extent_state(state);
+	}
+	return ret;
+}
+
+/*
+ * clear some bits on a range in the tree.  This may require splitting
+ * or inserting elements in the tree, so the gfp mask is used to
+ * indicate which allocations or sleeping are allowed.
+ *
+ * pass 'wake' == 1 to kick any sleepers, and 'delete' == 1 to remove
+ * the given range from the tree regardless of state (ie for truncate).
+ *
+ * the range [start, end] is inclusive.
+ *
+ * This takes the tree lock, and returns < 0 on error, > 0 if any of the
+ * bits were already set, or zero if none of the bits were already set.
+ */
+int clear_extent_bit(struct extent_map_tree *tree, u64 start, u64 end,
+		     int bits, int wake, int delete, gfp_t mask)
+{
+	struct extent_state *gang[2];
+	struct extent_state *state;
+	struct extent_state *prealloc = NULL;
+	u64 orig_start = start;
+	int ret;
+	int i;
+	int err;
+	int set = 0;
+
+	write_lock_irq(&tree->lock);
+	state = radix_tree_lookup(&tree->state, end);
+	if (state && state->start == start && state->end == end) {
+		set = clear_state_bit(tree, state, bits, wake, delete);
+		goto out;
+	}
+	write_unlock_irq(&tree->lock);
+again:
+	if (mask & __GFP_WAIT) {
+		if (!prealloc) {
+			prealloc = alloc_extent_state(mask);
+			if (!prealloc)
+				return -ENOMEM;
+		}
+		radix_tree_preload(GFP_NOFS);
+	}
+
+	write_lock_irq(&tree->lock);
+	/*
+	 * this radix search will find all the extents that end after
+	 * our range starts
+	 */
+	ret = radix_tree_gang_lookup(&tree->state, (void **)gang,
+				     start, ARRAY_SIZE(gang));
+	if (!ret)
+		goto out;
+	for (i = 0; i < ret; i++) {
+		state = gang[i];
+
+		if (state->start > end)
+			goto out;
+
+		/*
+		 *     | ---- desired range ---- |
+		 *  | state | or
+		 *  | ------------- state -------------- |
+		 *
+		 * We need to split the extent we found, and may flip
+		 * bits on second half.
+		 *
+		 * If the extent we found extends past our range, we
+		 * just split and search again.  It'll get split again
+		 * the next time though.
+		 *
+		 * If the extent we found is inside our range, we clear
+		 * the desired bit on it.
+		 */
+
+		if (state->start < start) {
+			err = split_state(tree, state, prealloc, start);
+			BUG_ON(err == -EEXIST);
+			prealloc = NULL;
+			if (err)
+				goto out;
+			if (state->end <= end) {
+				start = state->end + 1;
+				set |= clear_state_bit(tree, state, bits,
+						wake, delete);
+			} else {
+				start = state->start;
+			}
+			goto search_again;
+		}
+		/*
+		 * | ---- desired range ---- |
+		 *                        | state |
+		 * We need to split the extent, and clear the bit
+		 * on the first half
+		 */
+		if (state->start <= end && state->end > end) {
+			err = split_state(tree, state, prealloc, end + 1);
+			BUG_ON(err == -EEXIST);
+
+			if (wake)
+				wake_up(&state->wq);
+			set |= clear_state_bit(tree, prealloc, bits,
+					       wake, delete);
+			prealloc = NULL;
+			goto out;
+		}
+
+		start = state->end + 1;
+		set |= clear_state_bit(tree, state, bits, wake, delete);
+	}
+	goto search_again;
+
+out:
+	write_unlock_irq(&tree->lock);
+	if (prealloc)
+		free_extent_state(prealloc);
+
+	if (bits & EXTENT_IOBITS)
+		merge_state(tree, orig_start, end);
+	return set;
+
+search_again:
+	if (start >= end)
+		goto out;
+	write_unlock_irq(&tree->lock);
+	radix_tree_preload_end();
+	cond_resched();
+	goto again;
+}
+EXPORT_SYMBOL(clear_extent_bit);
+
+static int wait_on_state(struct extent_map_tree *tree,
+			 struct extent_state *state)
+{
+	DEFINE_WAIT(wait);
+	prepare_to_wait(&state->wq, &wait, TASK_UNINTERRUPTIBLE);
+	write_unlock_irq(&tree->lock);
+	schedule();
+	write_lock_irq(&tree->lock);
+	return 0;
+}
+
+/*
+ * waits for one or more bits to clear on a range in the state tree.
+ * The range [start, end] is inclusive.
+ * The tree lock is taken by this function
+ */
+int wait_extent_bit(struct extent_map_tree *tree, u64 start, u64 end, int bits)
+{
+	struct extent_state *gang[1];
+	struct extent_state *state;
+	int ret;
+	int i;
+
+	write_lock_irq(&tree->lock);
+again:
+	while (1) {
+		/*
+		 * this radix search will find all the extents that end after
+		 * our range starts
+		 */
+		ret = radix_tree_gang_lookup(&tree->state, (void **)gang,
+					     start, ARRAY_SIZE(gang));
+		if (!ret)
+			break;
+
+		for (i = 0; i < ret; i++) {
+			state = gang[i];
+
+			if (state->start > end)
+				goto out;
+
+			if (state->state & bits) {
+				start = state->start;
+				atomic_inc(&state->refs);
+				wait_on_state(tree, state);
+				free_extent_state(state);
+				goto again;
+			}
+			start = state->end + 1;
+		}
+
+		if (start > end)
+			break;
+
+		if (need_resched()) {
+			write_unlock_irq(&tree->lock);
+			cond_resched();
+			write_lock_irq(&tree->lock);
+		}
+	}
+out:
+	write_unlock_irq(&tree->lock);
+	return 0;
+}
+EXPORT_SYMBOL(wait_extent_bit);
+
+/*
+ * set some bits on a range in the tree.  This may require allocations
+ * or sleeping, so the gfp mask is used to indicate what is allowed.
+ *
+ * If 'exclusive' == 1, this will fail with -EEXIST if some part of the
+ * range already has the desired bits set.  The start of the existing
+ * range is returned in failed_start in this case.
+ *
+ * [start, end] is inclusive
+ * This takes the tree lock.
+ */
+int set_extent_bit(struct extent_map_tree *tree, u64 start, u64 end, int bits,
+		   int exclusive, u64 *failed_start, gfp_t mask)
+{
+	struct extent_state *gang[1];
+	struct extent_state *state;
+	struct extent_state *prealloc = NULL;
+	int ret;
+	int err = 0;
+	int i;
+	int set;
+	int ioset = 0;
+	u64 last_start;
+	u64 last_end;
+	u64 orig_start = start;
+
+	/*
+	 * try an optimistic search for an exact match.  FIXME, is this
+	 * actually faster?
+	 */
+	write_lock_irq(&tree->lock);
+	state = radix_tree_lookup(&tree->state, end);
+	if (state && state->start == start && state->end == end) {
+		set = state->state & bits;
+		if (set && exclusive) {
+			*failed_start = state->start;
+			err = -EEXIST;
+		}
+		state->state |= bits;
+		goto out;
+	}
+	write_unlock_irq(&tree->lock);
+
+again:
+	if (mask & __GFP_WAIT) {
+		prealloc = alloc_extent_state(mask);
+		if (!prealloc)
+			return -ENOMEM;
+		err = radix_tree_preload(mask);
+		if (err) {
+			free_extent_state(prealloc);
+			return err;
+		}
+	}
+
+	write_lock_irq(&tree->lock);
+	/*
+	 * this radix search will find all the extents that end after
+	 * our range starts.
+	 */
+	ret = radix_tree_gang_lookup(&tree->state, (void **)gang,
+				     start, ARRAY_SIZE(gang));
+	if (!ret) {
+		err = insert_state(tree, prealloc, start, end, bits);
+		prealloc = NULL;
+		BUG_ON(err == -EEXIST);
+		goto out;
+	}
+
+	for (i = 0; i < ret; i++) {
+		state = gang[i];
+		last_start = state->start;
+		last_end = state->end;
+
+		/*
+		 * | ---- desired range ---- |
+		 * | state |
+		 *
+		 * Just lock what we found and keep going
+		 */
+		if (state->start == start && state->end <= end) {
+			ioset = state->state & EXTENT_IOBITS;
+			set = state->state & bits;
+			if (set && exclusive) {
+				*failed_start = state->start;
+				err = -EEXIST;
+				goto out;
+			}
+			state->state |= bits;
+			start = state->end + 1;
+			if (start > end)
+				goto out;
+			continue;
+		}
+
+		/*
+		 *     | ---- desired range ---- |
+		 * | state |
+		 *   or
+		 * | ------------- state -------------- |
+		 *
+		 * We need to split the extent we found, and may flip bits on
+		 * second half.
+		 *
+		 * If the extent we found extends past our
+		 * range, we just split and search again.  It'll get split
+		 * again the next time though.
+		 *
+		 * If the extent we found is inside our range, we set the
+		 * desired bit on it.
+		 */
+		if (state->start < start) {
+			ioset = state->state & EXTENT_IOBITS;
+			set = state->state & bits;
+			if (exclusive && set) {
+				*failed_start = start;
+				err = -EEXIST;
+				goto out;
+			}
+			err = split_state(tree, state, prealloc, start);
+			BUG_ON(err == -EEXIST);
+			prealloc = NULL;
+			if (err)
+				goto out;
+			if (state->end <= end) {
+				state->state |= bits;
+				start = state->end + 1;
+			} else {
+				start = state->start;
+			}
+			goto search_again;
+		}
+		/*
+		 * | ---- desired range ---- |
+		 *                        | state |
+		 * We need to split the extent, and set the bit
+		 * on the first half
+		 */
+		if (state->start <= end && state->end > end) {
+			ioset = state->state & EXTENT_IOBITS;
+			set = state->state & bits;
+			if (exclusive && set) {
+				*failed_start = start;
+				err = -EEXIST;
+				goto out;
+			}
+			err = split_state(tree, state, prealloc, end + 1);
+			BUG_ON(err == -EEXIST);
+
+			prealloc->state |= bits;
+			prealloc = NULL;
+			goto out;
+		}
+
+		/*
+		 * | ---- desired range ---- |
+		 *     | state | or               | state |
+		 *
+		 * There's a hole, we need to insert something in it and
+		 * ignore the extent we found.
+		 */
+		if (state->start > start) {
+			u64 this_end = min(end, last_start);
+			err = insert_state(tree, prealloc, start, this_end,
+					   bits);
+			prealloc = NULL;
+			BUG_ON(err == -EEXIST);
+			if (err)
+				goto out;
+			start = this_end + 1;
+			goto search_again;
+		}
+		WARN_ON(1);
+	}
+	goto search_again;
+
+out:
+	write_unlock_irq(&tree->lock);
+	radix_tree_preload_end();
+	if (prealloc)
+		free_extent_state(prealloc);
+
+	if (!err && !(bits & EXTENT_IOBITS) && !ioset)
+		merge_state(tree, orig_start, end);
+	return err;
+
+search_again:
+	if (start > end)
+		goto out;
+	write_unlock_irq(&tree->lock);
+	radix_tree_preload_end();
+	cond_resched();
+	goto again;
+}
+EXPORT_SYMBOL(set_extent_bit);
+
+/* wrappers around set/clear extent bit */
+int set_extent_dirty(struct extent_map_tree *tree, u64 start, u64 end,
+		     gfp_t mask)
+{
+	return set_extent_bit(tree, start, end, EXTENT_DIRTY, 0, NULL,
+			      mask);
+}
+EXPORT_SYMBOL(set_extent_dirty);
+
+int clear_extent_dirty(struct extent_map_tree *tree, u64 start, u64 end,
+		       gfp_t mask)
+{
+	return clear_extent_bit(tree, start, end, EXTENT_DIRTY, 0, 0, mask);
+}
+EXPORT_SYMBOL(clear_extent_dirty);
+
+int set_extent_new(struct extent_map_tree *tree, u64 start, u64 end,
+		     gfp_t mask)
+{
+	return set_extent_bit(tree, start, end, EXTENT_NEW, 0, NULL,
+			      mask);
+}
+EXPORT_SYMBOL(set_extent_new);
+
+int clear_extent_new(struct extent_map_tree *tree, u64 start, u64 end,
+		       gfp_t mask)
+{
+	return clear_extent_bit(tree, start, end, EXTENT_NEW, 0, 0, mask);
+}
+EXPORT_SYMBOL(clear_extent_new);
+
+int set_extent_uptodate(struct extent_map_tree *tree, u64 start, u64 end,
+			gfp_t mask)
+{
+	return set_extent_bit(tree, start, end, EXTENT_UPTODATE, 0, NULL,
+			      mask);
+}
+EXPORT_SYMBOL(set_extent_uptodate);
+
+int clear_extent_uptodate(struct extent_map_tree *tree, u64 start, u64 end,
+			  gfp_t mask)
+{
+	return clear_extent_bit(tree, start, end, EXTENT_UPTODATE, 0, 0, mask);
+}
+EXPORT_SYMBOL(clear_extent_uptodate);
+
+int set_extent_writeback(struct extent_map_tree *tree, u64 start, u64 end,
+			 gfp_t mask)
+{
+	return set_extent_bit(tree, start, end, EXTENT_WRITEBACK,
+			      0, NULL, mask);
+}
+EXPORT_SYMBOL(set_extent_writeback);
+
+int clear_extent_writeback(struct extent_map_tree *tree, u64 start, u64 end,
+			   gfp_t mask)
+{
+	return clear_extent_bit(tree, start, end, EXTENT_WRITEBACK, 1, 0, mask);
+}
+EXPORT_SYMBOL(clear_extent_writeback);
+
+int wait_on_extent_writeback(struct extent_map_tree *tree, u64 start, u64 end)
+{
+	return wait_extent_bit(tree, start, end, EXTENT_WRITEBACK);
+}
+EXPORT_SYMBOL(wait_on_extent_writeback);
+
+/*
+ * locks a range in ascending order, waiting for any locked regions
+ * it hits on the way.  [start,end] are inclusive, and this will sleep.
+ */
+int lock_extent(struct extent_map_tree *tree, u64 start, u64 end, gfp_t mask)
+{
+	int err;
+	u64 failed_start;
+	while (1) {
+		err = set_extent_bit(tree, start, end, EXTENT_LOCKED, 1,
+				     &failed_start, mask);
+		if (err == -EEXIST && (mask & __GFP_WAIT)) {
+			wait_extent_bit(tree, failed_start, end, EXTENT_LOCKED);
+			start = failed_start;
+		} else {
+			break;
+		}
+		WARN_ON(start > end);
+	}
+	return err;
+}
+EXPORT_SYMBOL(lock_extent);
+
+int unlock_extent(struct extent_map_tree *tree, u64 start, u64 end,
+		  gfp_t mask)
+{
+	return clear_extent_bit(tree, start, end, EXTENT_LOCKED, 1, 0, mask);
+}
+EXPORT_SYMBOL(unlock_extent);
+
+/*
+ * helper function to set pages and extents in the tree dirty
+ */
+int set_range_dirty(struct extent_map_tree *tree, u64 start, u64 end)
+{
+	unsigned long index = start >> PAGE_CACHE_SHIFT;
+	unsigned long end_index = end >> PAGE_CACHE_SHIFT;
+	struct page *page;
+
+	while (index <= end_index) {
+		page = find_get_page(tree->mapping, index);
+		BUG_ON(!page);
+		__set_page_dirty_nobuffers(page);
+		page_cache_release(page);
+		index++;
+	}
+	set_extent_dirty(tree, start, end, GFP_NOFS);
+	return 0;
+}
+EXPORT_SYMBOL(set_range_dirty);
+
+/*
+ * helper function to set both pages and extents in the tree writeback
+ */
+int set_range_writeback(struct extent_map_tree *tree, u64 start, u64 end)
+{
+	unsigned long index = start >> PAGE_CACHE_SHIFT;
+	unsigned long end_index = end >> PAGE_CACHE_SHIFT;
+	struct page *page;
+
+	while (index <= end_index) {
+		page = find_get_page(tree->mapping, index);
+		BUG_ON(!page);
+		set_page_writeback(page);
+		page_cache_release(page);
+		index++;
+	}
+	set_extent_writeback(tree, start, end, GFP_NOFS);
+	return 0;
+}
+EXPORT_SYMBOL(set_range_writeback);
+
+/*
+ * helper function to lock both pages and extents in the tree.
+ * pages must be locked first.
+ */
+int lock_range(struct extent_map_tree *tree, u64 start, u64 end)
+{
+	unsigned long index = start >> PAGE_CACHE_SHIFT;
+	unsigned long end_index = end >> PAGE_CACHE_SHIFT;
+	struct page *page;
+	int err;
+
+	while (index <= end_index) {
+		page = grab_cache_page(tree->mapping, index);
+		if (!page) {
+			err = -ENOMEM;
+			goto failed;
+		}
+		if (IS_ERR(page)) {
+			err = PTR_ERR(page);
+			goto failed;
+		}
+		index++;
+	}
+	lock_extent(tree, start, end, GFP_NOFS);
+	return 0;
+
+failed:
+	/*
+	 * we failed above in getting the page at 'index', so we undo here
+	 * up to but not including the page at 'index'
+	 */
+	end_index = index;
+	index = start >> PAGE_CACHE_SHIFT;
+	while (index < end_index) {
+		page = find_get_page(tree->mapping, index);
+		unlock_page(page);
+		page_cache_release(page);
+		index++;
+	}
+	return err;
+}
+EXPORT_SYMBOL(lock_range);
+
+/*
+ * helper function to unlock both pages and extents in the tree.
+ */
+int unlock_range(struct extent_map_tree *tree, u64 start, u64 end)
+{
+	unsigned long index = start >> PAGE_CACHE_SHIFT;
+	unsigned long end_index = end >> PAGE_CACHE_SHIFT;
+	struct page *page;
+
+	while (index <= end_index) {
+		page = find_get_page(tree->mapping, index);
+		unlock_page(page);
+		page_cache_release(page);
+		index++;
+	}
+	unlock_extent(tree, start, end, GFP_NOFS);
+	return 0;
+}
+EXPORT_SYMBOL(unlock_range);
+
+/*
+ * searches a range in the state tree for a given mask.
+ * If 'filled' == 1, this returns 1 only if ever extent in the tree
+ * has the bits set.  Otherwise, 1 is returned if any bit in the
+ * range is found set.
+ */
+static int test_range_bit(struct extent_map_tree *tree, u64 start, u64 end,
+			  int bits, int filled)
+{
+	struct extent_state *state;
+	struct extent_state *gang[1];
+	int bitset = 0;
+	int ret;
+	int i;
+
+	read_lock_irq(&tree->lock);
+	state = radix_tree_lookup(&tree->state, end);
+
+	if (state && state->start == start && state->end == end) {
+		bitset = state->state & bits;
+		goto out;
+	}
+
+	while (start <= end) {
+		ret = radix_tree_gang_lookup(&tree->state, (void **)gang,
+					     start, ARRAY_SIZE(gang));
+		if (!ret)
+			goto out;
+		for (i = 0; i < ret; i++) {
+			state = gang[i];
+
+			if (state->start > end)
+				goto out;
+
+			if (filled && state->start > start) {
+				bitset = 0;
+				goto out;
+			}
+			if (state->state & bits) {
+				bitset = 1;
+				if (!filled)
+					goto out;
+			} else if (filled) {
+				bitset = 0;
+				goto out;
+			}
+			start = state->end + 1;
+			if (start > end)
+				goto out;
+		}
+	}
+out:
+	read_unlock_irq(&tree->lock);
+	return bitset;
+}
+
+/*
+ * helper function to set a given page up to date if all the
+ * extents in the tree for that page are up to date
+ */
+static int check_page_uptodate(struct extent_map_tree *tree,
+			       struct page *page)
+{
+	u64 start = page->index << PAGE_CACHE_SHIFT;
+	u64 end = start + PAGE_CACHE_SIZE - 1;
+	if (test_range_bit(tree, start, end, EXTENT_UPTODATE, 1))
+		SetPageUptodate(page);
+	return 0;
+}
+
+/*
+ * helper function to unlock a page if all the extents in the tree
+ * for that page are unlocked
+ */
+static int check_page_locked(struct extent_map_tree *tree,
+			     struct page *page)
+{
+	u64 start = page->index << PAGE_CACHE_SHIFT;
+	u64 end = start + PAGE_CACHE_SIZE - 1;
+	if (!test_range_bit(tree, start, end, EXTENT_LOCKED, 0))
+		unlock_page(page);
+	return 0;
+}
+
+/*
+ * helper function to end page writeback if all the extents
+ * in the tree for that page are done with writeback
+ */
+static int check_page_writeback(struct extent_map_tree *tree,
+			     struct page *page)
+{
+	u64 start = page->index << PAGE_CACHE_SHIFT;
+	u64 end = start + PAGE_CACHE_SIZE - 1;
+	if (!test_range_bit(tree, start, end, EXTENT_WRITEBACK, 0))
+		end_page_writeback(page);
+	return 0;
+}
+
+/* lots and lots of room for performance fixes in the end_bio funcs */
+
+/*
+ * after a writepage IO is done, we need to:
+ * clear the uptodate bits on error
+ * clear the writeback bits in the extent tree for this IO
+ * end_page_writeback if the page has no more pending IO
+ *
+ * Scheduling is not allowed, so the extent state tree is expected
+ * to have one and only one object corresponding to this IO.
+ */
+static int end_bio_extent_writepage(struct bio *bio,
+				   unsigned int bytes_done, int err)
+{
+	const int uptodate = test_bit(BIO_UPTODATE, &bio->bi_flags);
+	struct bio_vec *bvec = bio->bi_io_vec + bio->bi_vcnt - 1;
+	struct extent_map_tree *tree = bio->bi_private;
+	u64 start;
+	u64 end;
+	int whole_page;
+
+	if (bio->bi_size)
+		return 1;
+
+	do {
+		struct page *page = bvec->bv_page;
+		start = (page->index << PAGE_CACHE_SHIFT) + bvec->bv_offset;
+		end = start + bvec->bv_len - 1;
+
+		if (bvec->bv_offset == 0 && bvec->bv_len == PAGE_CACHE_SIZE)
+			whole_page = 1;
+		else
+			whole_page = 0;
+
+		if (--bvec >= bio->bi_io_vec)
+			prefetchw(&bvec->bv_page->flags);
+
+		if (!uptodate) {
+			clear_extent_uptodate(tree, start, end, GFP_ATOMIC);
+			ClearPageUptodate(page);
+			SetPageError(page);
+		}
+		clear_extent_writeback(tree, start, end, GFP_ATOMIC);
+
+		if (whole_page)
+			end_page_writeback(page);
+		else
+			check_page_writeback(tree, page);
+	} while (bvec >= bio->bi_io_vec);
+
+	bio_put(bio);
+	return 0;
+}
+
+/*
+ * after a readpage IO is done, we need to:
+ * clear the uptodate bits on error
+ * set the uptodate bits if things worked
+ * set the page up to date if all extents in the tree are uptodate
+ * clear the lock bit in the extent tree
+ * unlock the page if there are no other extents locked for it
+ *
+ * Scheduling is not allowed, so the extent state tree is expected
+ * to have one and only one object corresponding to this IO.
+ */
+static int end_bio_extent_readpage(struct bio *bio,
+				   unsigned int bytes_done, int err)
+{
+	const int uptodate = test_bit(BIO_UPTODATE, &bio->bi_flags);
+	struct bio_vec *bvec = bio->bi_io_vec + bio->bi_vcnt - 1;
+	struct extent_map_tree *tree = bio->bi_private;
+	u64 start;
+	u64 end;
+	int whole_page;
+
+	if (bio->bi_size)
+		return 1;
+
+	do {
+		struct page *page = bvec->bv_page;
+		start = (page->index << PAGE_CACHE_SHIFT) + bvec->bv_offset;
+		end = start + bvec->bv_len - 1;
+
+		if (bvec->bv_offset == 0 && bvec->bv_len == PAGE_CACHE_SIZE)
+			whole_page = 1;
+		else
+			whole_page = 0;
+
+		if (--bvec >= bio->bi_io_vec)
+			prefetchw(&bvec->bv_page->flags);
+
+		if (uptodate) {
+			set_extent_uptodate(tree, start, end, GFP_ATOMIC);
+			if (whole_page)
+				SetPageUptodate(page);
+			else
+				check_page_uptodate(tree, page);
+		} else {
+			ClearPageUptodate(page);
+			SetPageError(page);
+		}
+
+		unlock_extent(tree, start, end, GFP_ATOMIC);
+
+		if (whole_page)
+			unlock_page(page);
+		else
+			check_page_locked(tree, page);
+	} while (bvec >= bio->bi_io_vec);
+
+	bio_put(bio);
+	return 0;
+}
+
+/*
+ * IO done from prepare_write is pretty simple, we just unlock
+ * the structs in the extent tree when done, and set the uptodate bits
+ * as appropriate.
+ */
+static int end_bio_extent_preparewrite(struct bio *bio,
+				       unsigned int bytes_done, int err)
+{
+	const int uptodate = test_bit(BIO_UPTODATE, &bio->bi_flags);
+	struct bio_vec *bvec = bio->bi_io_vec + bio->bi_vcnt - 1;
+	struct extent_map_tree *tree = bio->bi_private;
+	u64 start;
+	u64 end;
+
+	if (bio->bi_size)
+		return 1;
+
+	do {
+		struct page *page = bvec->bv_page;
+		start = (page->index << PAGE_CACHE_SHIFT) + bvec->bv_offset;
+		end = start + bvec->bv_len - 1;
+
+		if (--bvec >= bio->bi_io_vec)
+			prefetchw(&bvec->bv_page->flags);
+
+		if (uptodate) {
+			set_extent_uptodate(tree, start, end, GFP_ATOMIC);
+		} else {
+			ClearPageUptodate(page);
+			SetPageError(page);
+		}
+
+		unlock_extent(tree, start, end, GFP_ATOMIC);
+
+	} while (bvec >= bio->bi_io_vec);
+
+	bio_put(bio);
+	return 0;
+}
+
+static int submit_extent_page(int rw, struct extent_map_tree *tree,
+			      struct page *page, sector_t sector,
+			      size_t size, unsigned long offset,
+			      struct block_device *bdev,
+			      bio_end_io_t end_io_func)
+{
+	struct bio *bio;
+	int ret = 0;
+
+	bio = bio_alloc(GFP_NOIO, 1);
+
+	bio->bi_sector = sector;
+	bio->bi_bdev = bdev;
+	bio->bi_io_vec[0].bv_page = page;
+	bio->bi_io_vec[0].bv_len = size;
+	bio->bi_io_vec[0].bv_offset = offset;
+
+	bio->bi_vcnt = 1;
+	bio->bi_idx = 0;
+	bio->bi_size = size;
+
+	bio->bi_end_io = end_io_func;
+	bio->bi_private = tree;
+
+	bio_get(bio);
+	submit_bio(rw, bio);
+
+	if (bio_flagged(bio, BIO_EOPNOTSUPP))
+		ret = -EOPNOTSUPP;
+
+	bio_put(bio);
+	return ret;
+}
+
+/*
+ * basic readpage implementation.  Locked extent state structs are inserted
+ * into the tree that are removed when the IO is done (by the end_io
+ * handlers)
+ */
+int extent_read_full_page(struct extent_map_tree *tree, struct page *page,
+			  get_extent_t *get_extent)
+{
+	struct inode *inode = page->mapping->host;
+	u64 start = page->index << PAGE_CACHE_SHIFT;
+	u64 page_end = start + PAGE_CACHE_SIZE - 1;
+	u64 end;
+	u64 cur = start;
+	u64 extent_offset;
+	u64 last_byte = i_size_read(inode);
+	u64 block_start;
+	sector_t sector;
+	struct extent_map *em;
+	struct block_device *bdev;
+	int ret;
+	int nr = 0;
+	size_t page_offset = 0;
+	size_t iosize;
+	size_t blocksize = inode->i_sb->s_blocksize;
+
+	if (!PagePrivate(page)) {
+		SetPagePrivate(page);
+		set_page_private(page, 1);
+		page_cache_get(page);
+	}
+
+	end = min(page_end, last_byte - 1);
+	end = end | (blocksize - 1);
+	lock_extent(tree, start, end, GFP_NOFS);
+
+	if (last_byte <= start)
+		goto done;
+
+	while (cur <= end) {
+		em = get_extent(inode, page, page_offset, cur, end, 0);
+		if (IS_ERR(em) || !em) {
+			SetPageError(page);
+			break;
+		}
+
+		extent_offset = cur - em->start;
+		BUG_ON(em->end < cur);
+		BUG_ON(end < cur);
+
+		iosize = min(em->end - cur, end - cur) + 1;
+		iosize = (iosize + blocksize - 1) & ~((u64)blocksize - 1);
+		sector = (em->block_start + extent_offset) >> 9;
+		bdev = em->bdev;
+		block_start = em->block_start;
+		free_extent_map(em);
+		em = NULL;
+
+		/* we've found a hole, just zero and go on */
+		if (block_start == 0) {
+			zero_user_page(page, page_offset, iosize, KM_USER0);
+			set_extent_uptodate(tree, cur, cur + iosize - 1,
+					    GFP_NOFS);
+			unlock_extent(tree, cur, cur + iosize - 1, GFP_NOFS);
+			cur = cur + iosize;
+			page_offset += iosize;
+			continue;
+		}
+
+		/* the get_extent function already copied into the page */
+		if (test_range_bit(tree, cur, cur + iosize - 1,
+				   EXTENT_UPTODATE, 1)) {
+			unlock_extent(tree, cur, cur + iosize - 1, GFP_NOFS);
+			cur = cur + iosize;
+			page_offset += iosize;
+			continue;
+		}
+		ret = submit_extent_page(READ, tree, page,
+					 sector, iosize, page_offset, bdev,
+					 end_bio_extent_readpage);
+		if (ret)
+			SetPageError(page);
+		cur = cur + iosize;
+		page_offset += iosize;
+		nr++;
+	}
+done:
+	if (last_byte - 1 < page_end) {
+		size_t last_off = last_byte & (PAGE_CACHE_SIZE - 1);
+		zero_user_page(page, last_off, PAGE_CACHE_SIZE - last_off,
+			       KM_USER0);
+       }
+	if (!nr) {
+		if (!PageError(page))
+			SetPageUptodate(page);
+		unlock_extent(tree, start, end, GFP_NOFS);
+		unlock_page(page);
+	}
+	return 0;
+}
+EXPORT_SYMBOL(extent_read_full_page);
+
+/*
+ * the writepage semantics are similar to regular writepage.  extent
+ * records are inserted to lock ranges in the tree, and as dirty areas
+ * are found, they are marked writeback.  Then the lock bits are removed
+ * and the end_io handler clears the writeback ranges
+ */
+int extent_write_full_page(struct extent_map_tree *tree, struct page *page,
+			  get_extent_t *get_extent,
+			  struct writeback_control *wbc)
+{
+	struct inode *inode = page->mapping->host;
+	u64 start = page->index << PAGE_CACHE_SHIFT;
+	u64 page_end = start + PAGE_CACHE_SIZE - 1;
+	u64 end;
+	u64 cur = start;
+	u64 extent_offset;
+	u64 last_byte = i_size_read(inode);
+	u64 block_start;
+	sector_t sector;
+	struct extent_map *em;
+	struct block_device *bdev;
+	int ret;
+	int nr = 0;
+	size_t page_offset = 0;
+	size_t iosize;
+	size_t blocksize;
+	loff_t i_size = i_size_read(inode);
+	unsigned long end_index = i_size >> PAGE_CACHE_SHIFT;
+
+	if (page->index > end_index) {
+		unlock_page(page);
+		return 0;
+	}
+
+	if (page->index == end_index) {
+		size_t offset = i_size & (PAGE_CACHE_SIZE - 1);
+		zero_user_page(page, offset,
+			       PAGE_CACHE_SIZE - offset, KM_USER0);
+	}
+
+	if (!PagePrivate(page)) {
+		SetPagePrivate(page);
+		set_page_private(page, 1);
+		page_cache_get(page);
+	}
+
+	end = min(page_end, last_byte - 1);
+	lock_extent(tree, start, end, GFP_NOFS);
+
+	if (last_byte <= start)
+		goto done;
+
+	set_extent_uptodate(tree, start, end, GFP_NOFS);
+	blocksize = inode->i_sb->s_blocksize;
+
+	while (cur <= end) {
+		em = get_extent(inode, page, page_offset, cur, end, 0);
+		if (IS_ERR(em) || !em) {
+			SetPageError(page);
+			break;
+		}
+
+		extent_offset = cur - em->start;
+		BUG_ON(em->end < cur);
+		BUG_ON(end < cur);
+		iosize = min(em->end - cur, end - cur) + 1;
+		iosize = (iosize + blocksize - 1) & ~((u64)blocksize - 1);
+		sector = (em->block_start + extent_offset) >> 9;
+		bdev = em->bdev;
+		block_start = em->block_start;
+		free_extent_map(em);
+		em = NULL;
+
+		if (block_start == 0) {
+			unlock_extent(tree, cur, cur + iosize - 1, GFP_NOFS);
+			cur = cur + iosize;
+			page_offset += iosize;
+			continue;
+		}
+
+		if (!test_range_bit(tree, cur, cur + iosize - 1,
+				   EXTENT_DIRTY, 0)) {
+			unlock_extent(tree, cur, cur + iosize - 1, GFP_NOFS);
+			cur = cur + iosize;
+			page_offset += iosize;
+			continue;
+		}
+		clear_extent_dirty(tree, cur, cur + iosize - 1, GFP_NOFS);
+		ret = submit_extent_page(WRITE, tree, page,
+					 sector, iosize, page_offset, bdev,
+					 end_bio_extent_writepage);
+		if (ret)
+			SetPageError(page);
+		cur = cur + iosize;
+		page_offset += iosize;
+		nr++;
+	}
+done:
+	set_range_writeback(tree, start, end);
+	unlock_extent(tree, start, end, GFP_NOFS);
+	unlock_page(page);
+	if (!nr) {
+		clear_extent_writeback(tree, start, end, GFP_NOFS);
+		end_page_writeback(page);
+	}
+	return 0;
+}
+EXPORT_SYMBOL(extent_write_full_page);
+
+/*
+ * basic invalidatepage code, this waits on any locked or writeback
+ * ranges corresponding to the page, and then deletes any extent state
+ * records from the tree
+ */
+int extent_invalidatepage(struct extent_map_tree *tree,
+			  struct page *page, unsigned long offset)
+{
+	u64 start = (page->index << PAGE_CACHE_SHIFT) + offset;
+	u64 end = start + PAGE_CACHE_SIZE - 1 - offset;
+	lock_extent(tree, start, end, GFP_NOFS);
+	wait_on_extent_writeback(tree, start, end);
+	clear_extent_bit(tree, start, end, EXTENT_LOCKED, 1, 1, GFP_NOFS);
+	return 0;
+}
+EXPORT_SYMBOL(extent_invalidatepage);
+
+/*
+ * simple commit_write call, set_range_dirty is used to mark both
+ * the pages and the extent records as dirty
+ */
+int extent_commit_write(struct extent_map_tree *tree,
+			struct inode *inode, struct page *page,
+			unsigned from, unsigned to)
+{
+	u64 start = page->index << PAGE_CACHE_SHIFT;
+	u64 end = start + to - 1;
+	unsigned blocksize = 1 << inode->i_blkbits;
+	loff_t pos = ((loff_t)page->index << PAGE_CACHE_SHIFT) + to;
+
+	if (!PagePrivate(page)) {
+		SetPagePrivate(page);
+		set_page_private(page, 1);
+		page_cache_get(page);
+	}
+
+	start = (start + from) & ~((u64)blocksize - 1);
+	end = end | (blocksize - 1);
+	set_range_dirty(tree, start, end);
+
+	if (pos > inode->i_size) {
+		i_size_write(inode, pos);
+		mark_inode_dirty(inode);
+	}
+	return 0;
+}
+EXPORT_SYMBOL(extent_commit_write);
+
+int extent_prepare_write(struct extent_map_tree *tree,
+			 struct inode *inode, struct page *page,
+			 unsigned from, unsigned to, get_extent_t *get_extent)
+{
+	u64 start = page->index << PAGE_CACHE_SHIFT;
+	u64 end = start + to - 1;
+	u64 block_start;
+	u64 orig_block_start;
+	u64 block_end;
+	u64 cur_end;
+	struct extent_map *em;
+	unsigned blocksize = 1 << inode->i_blkbits;
+	size_t page_offset = 0;
+	size_t block_off_start;
+	size_t block_off_end;
+	int err = 0;
+	int iocount = 0;
+	int ret = 0;
+	int isnew;
+
+	if (!PagePrivate(page)) {
+		SetPagePrivate(page);
+		set_page_private(page, 1);
+		page_cache_get(page);
+	}
+
+	block_start = (start + from) & ~((u64)blocksize - 1);
+	block_end = end | (blocksize - 1);
+	orig_block_start = block_start;
+
+	lock_extent(tree, block_start, block_end, GFP_NOFS);
+	while(block_start <= block_end) {
+		em = get_extent(inode, page, page_offset, block_start,
+				block_end, 1);
+		if (IS_ERR(em) || !em) {
+			goto err;
+		}
+
+		cur_end = min(block_end, em->end);
+		block_off_start = block_start & (PAGE_CACHE_SIZE - 1);
+		block_off_end = (cur_end  + 1) & (PAGE_CACHE_SIZE - 1);
+
+		isnew = clear_extent_new(tree, block_start, cur_end, GFP_NOFS);
+
+		if (!PageUptodate(page) && isnew &&
+		    (block_off_end > to || block_off_start < from)) {
+			void *kaddr;
+
+			kaddr = kmap_atomic(page, KM_USER0);
+			if (block_off_end > to)
+				memset(kaddr + to, 0, block_off_end - to);
+			if (block_off_start < from)
+				memset(kaddr + block_off_start, 0,
+				       from - block_off_start);
+			flush_dcache_page(page);
+			kunmap_atomic(kaddr, KM_USER0);
+
+		}
+		if (!isnew && !PageUptodate(page) &&
+		    (block_off_end > to || block_off_start < from) &&
+		    !test_range_bit(tree, block_start, cur_end,
+				    EXTENT_UPTODATE, 1)) {
+			u64 sector;
+			u64 extent_offset = block_start - em->start;
+			size_t iosize;
+			sector = (em->block_start + extent_offset) >> 9;
+			iosize = (cur_end - block_start + blocksize - 1) &
+				~((u64)blocksize - 1);
+
+			/*
+			 * we've already got the extent locked, but we
+			 * need to split the state such that our end_bio
+			 * handler can clear the lock.
+			 */
+			set_extent_bit(tree, block_start, cur_end,
+				       EXTENT_LOCKED, 0, NULL, GFP_NOFS);
+			ret = submit_extent_page(READ, tree, page,
+					 sector, iosize, page_offset, em->bdev,
+					 end_bio_extent_preparewrite);
+			iocount++;
+		} else {
+			set_extent_uptodate(tree, block_start, cur_end,
+					    GFP_NOFS);
+			unlock_extent(tree, block_start, cur_end, GFP_NOFS);
+		}
+		page_offset += cur_end + block_start - 1;
+		block_start = cur_end + 1;
+		free_extent_map(em);
+	}
+	if (iocount) {
+		wait_extent_bit(tree, orig_block_start,
+				block_end, EXTENT_LOCKED);
+	}
+	check_page_uptodate(tree, page);
+err:
+	/* FIXME, zero out newly allocated blocks on error */
+	return err;
+}
+EXPORT_SYMBOL(extent_prepare_write);
+
+/*
+ * a helper for releasepage.  As long as there are no locked extents
+ * in the range corresponding to the page, both state records and extent
+ * map records are removed
+ */
+int try_release_extent_mapping(struct extent_map_tree *tree, struct page *page)
+{
+	struct extent_map *em;
+	u64 start = page->index << PAGE_CACHE_SHIFT;
+	u64 end = start + PAGE_CACHE_SIZE - 1;
+	u64 orig_start = start;
+
+	while (start <= end) {
+		em = lookup_extent_mapping(tree, start, end);
+		if (!em || IS_ERR(em))
+			break;
+		if (test_range_bit(tree, em->start, em->end,
+				   EXTENT_LOCKED, 0))
+			continue;
+		remove_extent_mapping(tree, em);
+		start = em->end + 1;
+		/* once for the radix */
+		free_extent_map(em);
+		/* once for us */
+		free_extent_map(em);
+	}
+	clear_extent_bit(tree, orig_start, end, EXTENT_UPTODATE,
+			 1, 1, GFP_NOFS);
+	return 0;
+}
+EXPORT_SYMBOL(try_release_extent_mapping);
diff -r 126111346f94 include/linux/ext2_fs.h
--- a/include/linux/ext2_fs.h	Mon Jul 09 10:53:57 2007 -0400
+++ b/include/linux/ext2_fs.h	Tue Jul 10 16:49:26 2007 -0400
@@ -319,6 +319,7 @@ struct ext2_inode {
 #define EXT2_MOUNT_XIP			0x010000  /* Execute in place */
 #define EXT2_MOUNT_USRQUOTA		0x020000 /* user quota */
 #define EXT2_MOUNT_GRPQUOTA		0x040000 /* group quota */
+#define EXT2_MOUNT_EXTENTMAP		0x080000  /* use extent maps */
 
 
 #define clear_opt(o, opt)		o &= ~EXT2_MOUNT_##opt
diff -r 126111346f94 include/linux/extent_map.h
--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/include/linux/extent_map.h	Tue Jul 10 16:49:26 2007 -0400
@@ -0,0 +1,74 @@
+#ifndef __EXTENTMAP__
+#define __EXTENTMAP__
+
+struct extent_map_tree {
+	struct radix_tree_root map;
+	struct radix_tree_root state;
+	struct address_space *mapping;
+	rwlock_t lock;
+};
+
+struct extent_map {
+	__u64 start;
+	__u64 end; /* inclusive */
+	/* block_start and block_end are in bytes */
+	__u64 block_start;
+	__u64 block_end; /* inclusive */
+	struct block_device *bdev;
+	atomic_t refs;
+};
+
+/* possible optimiziation, move the wq into a hash waitqueue setup somewhere */
+struct extent_state {
+	__u64 start;
+	__u64 end; /* inclusive */
+	wait_queue_head_t wq;
+	atomic_t refs;
+	unsigned long state;
+};
+
+struct extent_buffer {
+	__u64 start;
+	__u64 end; /* inclusive */
+	char *addr;
+	struct page *pages[];
+};
+
+typedef struct extent_map *(get_extent_t)(struct inode *inode,
+					  struct page *page,
+					  size_t page_offset,
+					  u64 start, u64 end,
+					  int create);
+
+void extent_map_tree_init(struct extent_map_tree *tree,
+			  struct address_space *mapping, gfp_t mask);
+struct extent_map *lookup_extent_mapping(struct extent_map_tree *tree,
+					 u64 start, u64 end);
+int add_extent_mapping(struct extent_map_tree *tree,
+		       struct extent_map *em);
+int try_release_extent_mapping(struct extent_map_tree *tree, struct page *page);
+int lock_extent(struct extent_map_tree *tree, u64 start, u64 end, gfp_t mask);
+int unlock_extent(struct extent_map_tree *tree, u64 start, u64 end, gfp_t mask);
+struct extent_map *alloc_extent_map(gfp_t mask);
+void free_extent_map(struct extent_map *em);
+int extent_read_full_page(struct extent_map_tree *tree, struct page *page,
+			  get_extent_t *get_extent);
+void __init extent_map_init(void);
+void __exit extent_map_exit(void);
+int extent_clean_all_trees(struct extent_map_tree *tree);
+int set_extent_uptodate(struct extent_map_tree *tree, u64 start, u64 end,
+			gfp_t mask);
+int set_extent_new(struct extent_map_tree *tree, u64 start, u64 end,
+		   gfp_t mask);
+int extent_invalidatepage(struct extent_map_tree *tree,
+			  struct page *page, unsigned long offset);
+int extent_write_full_page(struct extent_map_tree *tree, struct page *page,
+			  get_extent_t *get_extent,
+			  struct writeback_control *wbc);
+int extent_prepare_write(struct extent_map_tree *tree,
+			 struct inode *inode, struct page *page,
+			 unsigned from, unsigned to, get_extent_t *get_extent);
+int extent_commit_write(struct extent_map_tree *tree,
+			struct inode *inode, struct page *page,
+			unsigned from, unsigned to);
+#endif
diff -r 126111346f94 init/main.c
--- a/init/main.c	Mon Jul 09 10:53:57 2007 -0400
+++ b/init/main.c	Tue Jul 10 16:49:26 2007 -0400
@@ -94,6 +94,7 @@ extern void pidmap_init(void);
 extern void pidmap_init(void);
 extern void prio_tree_init(void);
 extern void radix_tree_init(void);
+extern void extent_map_init(void);
 extern void free_initmem(void);
 #ifdef	CONFIG_ACPI
 extern void acpi_early_init(void);
@@ -618,6 +619,7 @@ asmlinkage void __init start_kernel(void
 	security_init();
 	vfs_caches_init(num_physpages);
 	radix_tree_init();
+	extent_map_init();
 	signals_init();
 	/* rootfs populating might need page-writeback */
 	page_writeback_init();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
