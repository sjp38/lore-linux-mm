Date: Tue, 24 Jul 2007 16:04:26 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: [PATCH RFC] ext2 extentmap support
Message-ID: <20070724200426.GB16557@think.oraclecorp.com>
References: <20070710210326.GA29963@think.oraclecorp.com> <20070724160032.7a7097db@think.oraclecorp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070724160032.7a7097db@think.oraclecorp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

mount -o extentmap to use the new stuff

diff -r 126111346f94 -r 53cabea328f7 fs/ext2/ext2.h
--- a/fs/ext2/ext2.h	Mon Jul 09 10:53:57 2007 -0400
+++ b/fs/ext2/ext2.h	Tue Jul 24 15:40:27 2007 -0400
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
diff -r 126111346f94 -r 53cabea328f7 fs/ext2/inode.c
--- a/fs/ext2/inode.c	Mon Jul 09 10:53:57 2007 -0400
+++ b/fs/ext2/inode.c	Tue Jul 24 15:40:27 2007 -0400
@@ -625,6 +625,84 @@ changed:
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
+	u64 bh_start;
+	u64 bh_end;
+
+	bh.b_size = inode->i_sb->s_blocksize;
+	bh.b_state = 0;
+again:
+	em = lookup_extent_mapping(extent_tree, start, end);
+	if (em) {
+		return em;
+	}
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
+	bh_start = start;
+	bh_end = start + found_len - 1;
+	em->start = start;
+	em->end = bh_end;
+	em->bdev = inode->i_sb->s_bdev;
+
+	if (!buffer_mapped(&bh)) {
+		em->block_start = 0;
+		em->block_end = 0;
+	} else {
+		em->block_start = bh.b_blocknr << inode->i_blkbits;
+		em->block_end = em->block_start + found_len - 1;
+	}
+	ret = add_extent_mapping(extent_tree, em);
+	if (ret == -EEXIST) {
+		free_extent_map(em);
+		em = NULL;
+		max_end = end;
+		goto again;
+	}
+out:
+	if (ret) {
+		if (em)
+			free_extent_map(em);
+		return ERR_PTR(ret);
+	} else if (em && buffer_new(&bh)) {
+		set_extent_new(extent_tree, bh_start, bh_end, GFP_NOFS);
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
@@ -633,6 +711,42 @@ static int ext2_readpage(struct file *fi
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
+	int ret;
+
+	if (page->private != 1)
+		return try_to_free_buffers(page);
+	tree = &EXT2_I(page->mapping->host)->extent_tree;
+	ret = try_release_extent_mapping(tree, page);
+	if (ret == 1) {
+		ClearPagePrivate(page);
+		set_page_private(page, 0);
+		page_cache_release(page);
+	}
+	return ret;
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
@@ -643,10 +757,30 @@ ext2_readpages(struct file *file, struct
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
@@ -713,6 +847,21 @@ const struct address_space_operations ex
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
+	.set_page_dirty		= __set_page_dirty_nobuffers,
+	// .bmap			= ext2_bmap,
+	// .direct_IO		= ext2_direct_IO,
+	// .writepages		= ext2_writepages,
+	// .migratepage		= buffer_migrate_page,
 };
 
 /*
@@ -924,7 +1073,8 @@ void ext2_truncate (struct inode * inode
 
 	if (mapping_is_xip(inode->i_mapping))
 		xip_truncate_page(inode->i_mapping, inode->i_size);
-	else if (test_opt(inode->i_sb, NOBH))
+	else if (test_opt(inode->i_sb, NOBH) ||
+		 test_opt(inode->i_sb, EXTENTMAP))
 		nobh_truncate_page(inode->i_mapping, inode->i_size);
 	else
 		block_truncate_page(inode->i_mapping,
@@ -1142,11 +1292,16 @@ void ext2_read_inode (struct inode * ino
 
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
diff -r 126111346f94 -r 53cabea328f7 fs/ext2/namei.c
--- a/fs/ext2/namei.c	Mon Jul 09 10:53:57 2007 -0400
+++ b/fs/ext2/namei.c	Tue Jul 24 15:40:27 2007 -0400
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
diff -r 126111346f94 -r 53cabea328f7 fs/ext2/super.c
--- a/fs/ext2/super.c	Mon Jul 09 10:53:57 2007 -0400
+++ b/fs/ext2/super.c	Tue Jul 24 15:40:27 2007 -0400
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
diff -r 126111346f94 -r 53cabea328f7 include/linux/ext2_fs.h
--- a/include/linux/ext2_fs.h	Mon Jul 09 10:53:57 2007 -0400
+++ b/include/linux/ext2_fs.h	Tue Jul 24 15:40:27 2007 -0400
@@ -319,6 +319,7 @@ struct ext2_inode {
 #define EXT2_MOUNT_XIP			0x010000  /* Execute in place */
 #define EXT2_MOUNT_USRQUOTA		0x020000 /* user quota */
 #define EXT2_MOUNT_GRPQUOTA		0x040000 /* group quota */
+#define EXT2_MOUNT_EXTENTMAP		0x080000  /* use extent maps */
 
 
 #define clear_opt(o, opt)		o &= ~EXT2_MOUNT_##opt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
