Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C03756B005C
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 10:48:10 -0400 (EDT)
Date: Tue, 7 Jul 2009 16:49:18 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch 4/4] fs: tmpfs, ext2 use new truncate
Message-ID: <20090707144918.GF2714@wotan.suse.de>
References: <20090707144423.GC2714@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090707144423.GC2714@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Convert ext2 and tmpfs to use the new truncate convention (with setsize
inode operation).

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 fs/ext2/ext2.h  |    2 
 fs/ext2/file.c  |    2 
 fs/ext2/inode.c |  117 +++++++++++++++++++++++++++++++++++++++++++-------------
 mm/shmem.c      |   29 +++++++++----
 4 files changed, 112 insertions(+), 38 deletions(-)

Index: linux-2.6/fs/ext2/inode.c
===================================================================
--- linux-2.6.orig/fs/ext2/inode.c
+++ linux-2.6/fs/ext2/inode.c
@@ -53,6 +53,8 @@ static inline int ext2_inode_is_fast_sym
 		inode->i_blocks - ea_blocks == 0);
 }
 
+static void ext2_truncate_blocks(struct inode *inode, loff_t offset);
+
 /*
  * Called at the last iput() if i_nlink is zero.
  */
@@ -68,7 +70,7 @@ void ext2_delete_inode (struct inode * i
 
 	inode->i_size = 0;
 	if (inode->i_blocks)
-		ext2_truncate (inode);
+		ext2_truncate_blocks(inode, 0);
 	ext2_free_inode (inode);
 
 	return;
@@ -761,8 +763,33 @@ ext2_write_begin(struct file *file, stru
 		loff_t pos, unsigned len, unsigned flags,
 		struct page **pagep, void **fsdata)
 {
+	int ret;
+
 	*pagep = NULL;
-	return __ext2_write_begin(file, mapping, pos, len, flags, pagep,fsdata);
+	ret = __ext2_write_begin(file, mapping, pos, len, flags, pagep,fsdata);
+	if (ret < 0) {
+		struct inode *inode = mapping->host;
+		loff_t isize = inode->i_size;
+		if (pos + len > isize)
+			ext2_truncate_blocks(inode, isize);
+	}
+	return ret;
+}
+
+static int ext2_write_end(struct file *file, struct address_space *mapping,
+			loff_t pos, unsigned len, unsigned copied,
+			struct page *page, void *fsdata)
+{
+	int ret;
+
+	ret = generic_write_end(file, mapping, pos, len, copied, page, fsdata);
+	if (ret < len) {
+		struct inode *inode = mapping->host;
+		loff_t isize = inode->i_size;
+		if (pos + len > isize)
+			ext2_truncate_blocks(inode, isize);
+	}
+	return ret;
 }
 
 static int
@@ -770,13 +797,22 @@ ext2_nobh_write_begin(struct file *file,
 		loff_t pos, unsigned len, unsigned flags,
 		struct page **pagep, void **fsdata)
 {
+	int ret;
+
 	/*
 	 * Dir-in-pagecache still uses ext2_write_begin. Would have to rework
 	 * directory handling code to pass around offsets rather than struct
 	 * pages in order to make this work easily.
 	 */
-	return nobh_write_begin(file, mapping, pos, len, flags, pagep, fsdata,
+	ret = nobh_write_begin(file, mapping, pos, len, flags, pagep, fsdata,
 							ext2_get_block);
+	if (ret < 0) {
+		struct inode *inode = mapping->host;
+		loff_t isize = inode->i_size;
+		if (pos + len > isize)
+			ext2_truncate_blocks(inode, isize);
+	}
+	return ret;
 }
 
 static int ext2_nobh_writepage(struct page *page,
@@ -796,9 +832,15 @@ ext2_direct_IO(int rw, struct kiocb *ioc
 {
 	struct file *file = iocb->ki_filp;
 	struct inode *inode = file->f_mapping->host;
+	ssize_t ret;
 
-	return blockdev_direct_IO(rw, iocb, inode, inode->i_sb->s_bdev, iov,
+	ret = blockdev_direct_IO(rw, iocb, inode, inode->i_sb->s_bdev, iov,
 				offset, nr_segs, ext2_get_block, NULL);
+	if (ret < 0 && (rw & WRITE)) {
+		loff_t isize = inode->i_size;
+		ext2_truncate_blocks(inode, isize);
+	}
+	return ret;
 }
 
 static int
@@ -813,7 +855,7 @@ const struct address_space_operations ex
 	.writepage		= ext2_writepage,
 	.sync_page		= block_sync_page,
 	.write_begin		= ext2_write_begin,
-	.write_end		= generic_write_end,
+	.write_end		= ext2_write_end,
 	.bmap			= ext2_bmap,
 	.direct_IO		= ext2_direct_IO,
 	.writepages		= ext2_writepages,
@@ -1020,7 +1062,7 @@ static void ext2_free_branches(struct in
 		ext2_free_data(inode, p, q);
 }
 
-void ext2_truncate(struct inode *inode)
+static void ext2_truncate_blocks(struct inode *inode, loff_t offset)
 {
 	__le32 *i_data = EXT2_I(inode)->i_data;
 	struct ext2_inode_info *ei = EXT2_I(inode);
@@ -1032,27 +1074,8 @@ void ext2_truncate(struct inode *inode)
 	int n;
 	long iblock;
 	unsigned blocksize;
-
-	if (!(S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode) ||
-	    S_ISLNK(inode->i_mode)))
-		return;
-	if (ext2_inode_is_fast_symlink(inode))
-		return;
-	if (IS_APPEND(inode) || IS_IMMUTABLE(inode))
-		return;
-
 	blocksize = inode->i_sb->s_blocksize;
-	iblock = (inode->i_size + blocksize-1)
-					>> EXT2_BLOCK_SIZE_BITS(inode->i_sb);
-
-	if (mapping_is_xip(inode->i_mapping))
-		xip_truncate_page(inode->i_mapping, inode->i_size);
-	else if (test_opt(inode->i_sb, NOBH))
-		nobh_truncate_page(inode->i_mapping,
-				inode->i_size, ext2_get_block);
-	else
-		block_truncate_page(inode->i_mapping,
-				inode->i_size, ext2_get_block);
+	iblock = (offset + blocksize-1) >> EXT2_BLOCK_SIZE_BITS(inode->i_sb);
 
 	n = ext2_block_to_path(inode, iblock, offsets, NULL);
 	if (n == 0)
@@ -1120,6 +1143,46 @@ do_indirects:
 	ext2_discard_reservation(inode);
 
 	mutex_unlock(&ei->truncate_mutex);
+}
+
+int ext2_setsize(struct dentry *dentry, loff_t newsize,
+			unsigned int flags, struct file *file)
+{
+	struct inode *inode = dentry->d_inode;
+	loff_t oldsize;
+	int error;
+
+	error = inode_newsize_ok(inode, newsize);
+	if (error)
+		return error;
+
+	if (!(S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode) ||
+	    S_ISLNK(inode->i_mode)))
+		return -EINVAL;
+	if (ext2_inode_is_fast_symlink(inode))
+		return -EINVAL;
+	if (IS_APPEND(inode) || IS_IMMUTABLE(inode))
+		return -EPERM;
+
+	if (mapping_is_xip(inode->i_mapping))
+		error = xip_truncate_page(inode->i_mapping, newsize);
+	else if (test_opt(inode->i_sb, NOBH))
+		error = nobh_truncate_page(inode->i_mapping,
+				newsize, ext2_get_block);
+	else
+		error = block_truncate_page(inode->i_mapping,
+				newsize, ext2_get_block);
+	if (error)
+		return error;
+
+	oldsize = inode->i_size;
+	i_size_write(inode, newsize);
+	truncate_pagecache(inode, oldsize, newsize);
+
+	down_write(&inode->i_alloc_sem);
+	ext2_truncate_blocks(inode, newsize);
+	up_write(&inode->i_alloc_sem);
+
 	inode->i_mtime = inode->i_ctime = CURRENT_TIME_SEC;
 	if (inode_needs_sync(inode)) {
 		sync_mapping_buffers(inode->i_mapping);
@@ -1127,6 +1190,8 @@ do_indirects:
 	} else {
 		mark_inode_dirty(inode);
 	}
+
+	return 0;
 }
 
 static struct ext2_inode *ext2_get_inode(struct super_block *sb, ino_t ino,
Index: linux-2.6/mm/shmem.c
===================================================================
--- linux-2.6.orig/mm/shmem.c
+++ linux-2.6/mm/shmem.c
@@ -730,10 +730,11 @@ done2:
 	if (inode->i_mapping->nrpages && (info->flags & SHMEM_PAGEIN)) {
 		/*
 		 * Call truncate_inode_pages again: racing shmem_unuse_inode
-		 * may have swizzled a page in from swap since vmtruncate or
-		 * generic_delete_inode did it, before we lowered next_index.
-		 * Also, though shmem_getpage checks i_size before adding to
-		 * cache, no recheck after: so fix the narrow window there too.
+		 * may have swizzled a page in from swap since
+		 * truncate_pagecache or generic_delete_inode did it, before we
+		 * lowered next_index.  Also, though shmem_getpage checks
+		 * i_size before adding to cache, no recheck after: so fix the
+		 * narrow window there too.
 		 *
 		 * Recalling truncate_inode_pages_range and unmap_mapping_range
 		 * every time for punch_hole (which never got a chance to clear
@@ -763,9 +764,17 @@ done2:
 	}
 }
 
-static void shmem_truncate(struct inode *inode)
+static int shmem_setsize(struct dentry *dentry, loff_t newsize,
+			unsigned int flags, struct file *file)
 {
-	shmem_truncate_range(inode, inode->i_size, (loff_t)-1);
+	int error;
+
+	error = simple_setsize(dentry, newsize, flags, file);
+	if (error)
+		return error;
+	shmem_truncate_range(dentry->d_inode, newsize, (loff_t)-1);
+
+	return error;
 }
 
 static int shmem_notify_change(struct dentry *dentry, struct iattr *attr)
@@ -822,11 +831,11 @@ static void shmem_delete_inode(struct in
 {
 	struct shmem_inode_info *info = SHMEM_I(inode);
 
-	if (inode->i_op->truncate == shmem_truncate) {
+	if (inode->i_op->setsize == shmem_setsize) {
 		truncate_inode_pages(inode->i_mapping, 0);
 		shmem_unacct_size(info->flags, inode->i_size);
 		inode->i_size = 0;
-		shmem_truncate(inode);
+		shmem_truncate_range(inode, 0, (loff_t)-1);
 		if (!list_empty(&info->swaplist)) {
 			mutex_lock(&shmem_swaplist_mutex);
 			list_del_init(&info->swaplist);
@@ -2018,7 +2027,7 @@ static const struct inode_operations shm
 };
 
 static const struct inode_operations shmem_symlink_inode_operations = {
-	.truncate	= shmem_truncate,
+	.setsize	= shmem_setsize,
 	.readlink	= generic_readlink,
 	.follow_link	= shmem_follow_link,
 	.put_link	= shmem_put_link,
@@ -2438,7 +2447,7 @@ static const struct file_operations shme
 };
 
 static const struct inode_operations shmem_inode_operations = {
-	.truncate	= shmem_truncate,
+	.setsize	= shmem_setsize,
 	.setattr	= shmem_notify_change,
 	.truncate_range	= shmem_truncate_range,
 #ifdef CONFIG_TMPFS_POSIX_ACL
Index: linux-2.6/fs/ext2/ext2.h
===================================================================
--- linux-2.6.orig/fs/ext2/ext2.h
+++ linux-2.6/fs/ext2/ext2.h
@@ -122,7 +122,7 @@ extern int ext2_write_inode (struct inod
 extern void ext2_delete_inode (struct inode *);
 extern int ext2_sync_inode (struct inode *);
 extern int ext2_get_block(struct inode *, sector_t, struct buffer_head *, int);
-extern void ext2_truncate (struct inode *);
+extern int ext2_setsize(struct dentry *, loff_t, unsigned int, struct file *);
 extern int ext2_setattr (struct dentry *, struct iattr *);
 extern void ext2_set_inode_flags(struct inode *inode);
 extern void ext2_get_inode_flags(struct ext2_inode_info *);
Index: linux-2.6/fs/ext2/file.c
===================================================================
--- linux-2.6.orig/fs/ext2/file.c
+++ linux-2.6/fs/ext2/file.c
@@ -77,7 +77,7 @@ const struct file_operations ext2_xip_fi
 #endif
 
 const struct inode_operations ext2_file_inode_operations = {
-	.truncate	= ext2_truncate,
+	.setsize	= ext2_setsize,
 #ifdef CONFIG_EXT2_FS_XATTR
 	.setxattr	= generic_setxattr,
 	.getxattr	= generic_getxattr,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
