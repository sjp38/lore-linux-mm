Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1D6546B0055
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 11:21:45 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 7/7] ext2: Convert ext2 to new mkwrite code
Date: Thu, 17 Sep 2009 17:21:47 +0200
Message-Id: <1253200907-31392-8-git-send-email-jack@suse.cz>
In-Reply-To: <1253200907-31392-1-git-send-email-jack@suse.cz>
References: <1253200907-31392-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/ext2/file.c  |   28 +++++++++++++++++++++++++++-
 fs/ext2/inode.c |   54 ++++++++++++++++++++++++++++++++++++++++--------------
 2 files changed, 67 insertions(+), 15 deletions(-)

diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index 806def9..317cfa0 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -19,6 +19,8 @@
  */
 
 #include <linux/time.h>
+#include <linux/mm.h>
+#include <linux/buffer_head.h>
 #include "ext2.h"
 #include "xattr.h"
 #include "acl.h"
@@ -38,6 +40,30 @@ static int ext2_release_file (struct inode * inode, struct file * filp)
 	return 0;
 }
 
+static struct vm_operations_struct ext2_file_vm_ops = {
+	.fault		= filemap_fault,
+	.page_mkwrite	= noalloc_page_mkwrite,
+};
+
+static struct vm_operations_struct ext2_nobh_file_vm_ops = {
+	.fault		= filemap_fault,
+};
+
+static int ext2_file_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	struct address_space *mapping = file->f_mapping;
+
+	if (!mapping->a_ops->readpage)
+		return -ENOEXEC;
+	file_accessed(file);
+	if (!test_opt(mapping->host->i_sb, NOBH))
+		vma->vm_ops = &ext2_file_vm_ops;
+	else
+		vma->vm_ops = &ext2_nobh_file_vm_ops;
+	vma->vm_flags |= VM_CAN_NONLINEAR;
+	return 0;
+}
+
 /*
  * We have mostly NULL's here: the current defaults are ok for
  * the ext2 filesystem.
@@ -52,7 +78,7 @@ const struct file_operations ext2_file_operations = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl	= ext2_compat_ioctl,
 #endif
-	.mmap		= generic_file_mmap,
+	.mmap		= ext2_file_mmap,
 	.open		= generic_file_open,
 	.release	= ext2_release_file,
 	.fsync		= simple_fsync,
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 8ff0f44..75881dd 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -815,10 +815,35 @@ ext2_nobh_write_begin(struct file *file, struct address_space *mapping,
 	return ret;
 }
 
+/*
+ * This is mostly used as a fallback function for __mpage_writepage(). We have
+ * to prepare buffers for block_write_full_page() so that all the buffers that
+ * should be written are either mapped or delay.
+ */
 static int ext2_nobh_writepage(struct page *page,
-			struct writeback_control *wbc)
+			       struct writeback_control *wbc)
 {
-	return nobh_writepage(page, ext2_get_block, wbc);
+	struct inode *inode = page->mapping->host;
+	int blocksize = 1 << inode->i_blkbits;
+	loff_t i_size = i_size_read(inode), start;
+	struct buffer_head *head, *bh;
+
+	if (!page_has_buffers(page)) {
+		create_empty_buffers(page, blocksize,
+				     (1 << BH_Dirty)|(1 << BH_Uptodate));
+	}
+	head = bh = page_buffers(page);
+	start = page_offset(page);
+	do {
+		if (start >= i_size)
+			break;
+		if (!buffer_mapped(bh) && buffer_dirty(bh))
+			set_buffer_delay(bh);
+		start += blocksize;
+		bh = bh->b_this_page;
+	} while (bh != head);
+
+	return block_write_full_page(page, ext2_get_block, wbc);
 }
 
 static sector_t ext2_bmap(struct address_space *mapping, sector_t block)
@@ -850,6 +875,7 @@ ext2_writepages(struct address_space *mapping, struct writeback_control *wbc)
 }
 
 const struct address_space_operations ext2_aops = {
+	.new_writepage		= 1,
 	.readpage		= ext2_readpage,
 	.readpages		= ext2_readpages,
 	.writepage		= ext2_writepage,
@@ -864,11 +890,13 @@ const struct address_space_operations ext2_aops = {
 };
 
 const struct address_space_operations ext2_aops_xip = {
+	.new_writepage		= 1,
 	.bmap			= ext2_bmap,
 	.get_xip_mem		= ext2_get_xip_mem,
 };
 
 const struct address_space_operations ext2_nobh_aops = {
+	.new_writepage		= 1,
 	.readpage		= ext2_readpage,
 	.readpages		= ext2_readpages,
 	.writepage		= ext2_nobh_writepage,
@@ -1167,7 +1195,7 @@ static void ext2_truncate_blocks(struct inode *inode, loff_t offset)
 
 int ext2_setsize(struct inode *inode, loff_t newsize)
 {
-	loff_t oldsize;
+	loff_t oldsize = inode->i_size;
 	int error;
 
 	error = inode_newsize_ok(inode, newsize);
@@ -1182,21 +1210,19 @@ int ext2_setsize(struct inode *inode, loff_t newsize)
 	if (IS_APPEND(inode) || IS_IMMUTABLE(inode))
 		return -EPERM;
 
-	if (mapping_is_xip(inode->i_mapping))
-		error = xip_truncate_page(inode->i_mapping, newsize);
-	else if (test_opt(inode->i_sb, NOBH))
-		error = nobh_truncate_page(inode->i_mapping,
-				newsize, ext2_get_block);
-	else
-		error = block_truncate_page(inode->i_mapping,
-				newsize, ext2_get_block);
-	if (error)
-		return error;
+	if (newsize > oldsize) {
+		error = block_prepare_hole(inode, oldsize, newsize, 0,
+					   ext2_get_block);
+		if (error)
+			return error;
+	}
 
-	oldsize = inode->i_size;
 	i_size_write(inode, newsize);
 	truncate_pagecache(inode, oldsize, newsize);
 
+	if (newsize > oldsize)
+		block_finish_hole(inode, oldsize, newsize);
+
 	__ext2_truncate_blocks(inode, newsize);
 
 	inode->i_mtime = inode->i_ctime = CURRENT_TIME_SEC;
-- 
1.6.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
