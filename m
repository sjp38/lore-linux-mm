Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D37DA6B004D
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 08:30:38 -0400 (EDT)
Date: Wed, 8 Jul 2009 14:39:04 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 4/4] fs: tmpfs, ext2 use new truncate
Message-ID: <20090708123904.GR2714@wotan.suse.de>
References: <20090707144423.GC2714@wotan.suse.de> <20090707144918.GF2714@wotan.suse.de> <20090707163829.GB14947@infradead.org> <20090708065327.GM2714@wotan.suse.de> <20090708111420.GB20924@duck.suse.cz> <20090708122250.GP2714@wotan.suse.de> <20090708123244.GA22722@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090708123244.GA22722@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 08, 2009 at 08:32:44AM -0400, Christoph Hellwig wrote:
> On Wed, Jul 08, 2009 at 02:22:50PM +0200, Nick Piggin wrote:
> > OK fair enough. But I don't know if all those checks are
> > realy appropriate. For example an IS_APPEND inode should
> > be able to have its blocks trimmed off if a write fails.
> 
> It should.  But I think that's a separate issue of what we're trying to
> fix right now.  So let's just do the method reshuffle now and then sort
> out the checks later.

Here is patch 4/4 after your parts folded in and other changes
I said in last mail. (yes I do agree to split it up, but I'll
just wait until we all agree on basics and then resend a new
patchset).

--
Convert ext2 and tmpfs to use the new truncate convention.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 fs/ext2/ext2.h  |    1 
 fs/ext2/file.c  |    2 
 fs/ext2/inode.c |  137 +++++++++++++++++++++++++++++++++++++++++++++-----------
 mm/shmem.c      |   35 +++++++-------
 4 files changed, 131 insertions(+), 44 deletions(-)

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
+static void __ext2_truncate_blocks(struct inode *inode, loff_t offset)
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
@@ -1120,6 +1143,59 @@ do_indirects:
 	ext2_discard_reservation(inode);
 
 	mutex_unlock(&ei->truncate_mutex);
+}
+
+static void ext2_truncate_blocks(struct inode *inode, loff_t offset)
+{
+	/*
+	 * XXX: it seems like a bug here that we don't allow
+	 * IS_APPEND inode to have blocks-past-i_size trimmed off.
+	 * review and fix this.
+	 */
+	if (!(S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode) ||
+	    S_ISLNK(inode->i_mode)))
+		return -EINVAL;
+	if (ext2_inode_is_fast_symlink(inode))
+		return -EINVAL;
+	if (IS_APPEND(inode) || IS_IMMUTABLE(inode))
+		return -EPERM;
+	__ext2_truncate_blocks(inode, offset);
+}
+
+int ext2_setsize(struct inode *inode, loff_t newsize)
+{
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
+	__ext2_truncate_blocks(inode, newsize);
+
 	inode->i_mtime = inode->i_ctime = CURRENT_TIME_SEC;
 	if (inode_needs_sync(inode)) {
 		sync_mapping_buffers(inode->i_mapping);
@@ -1127,6 +1203,8 @@ do_indirects:
 	} else {
 		mark_inode_dirty(inode);
 	}
+
+	return 0;
 }
 
 static struct ext2_inode *ext2_get_inode(struct super_block *sb, ino_t ino,
@@ -1459,6 +1537,13 @@ int ext2_setattr(struct dentry *dentry,
 		if (error)
 			return error;
 	}
+	if (iattr->ia_valid & ATTR_SIZE) {
+		error = ext2_setsize(inode, iattr->ia_size);
+		if (error)
+			return error;
+		iattr->ia_valid &= ~ATTR_SIZE;
+		/* strip ATTR_SIZE for inode_setattr */
+	}
 	error = inode_setattr(inode, iattr);
 	if (!error && (iattr->ia_valid & ATTR_MODE))
 		error = ext2_acl_chmod(inode);
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
@@ -763,11 +764,6 @@ done2:
 	}
 }
 
-static void shmem_truncate(struct inode *inode)
-{
-	shmem_truncate_range(inode, inode->i_size, (loff_t)-1);
-}
-
 static int shmem_notify_change(struct dentry *dentry, struct iattr *attr)
 {
 	struct inode *inode = dentry->d_inode;
@@ -775,6 +771,8 @@ static int shmem_notify_change(struct de
 	int error;
 
 	if (S_ISREG(inode->i_mode) && (attr->ia_valid & ATTR_SIZE)) {
+		loff_t newsize = attr->ia_size;
+
 		if (attr->ia_size < inode->i_size) {
 			/*
 			 * If truncating down to a partial page, then
@@ -783,9 +781,9 @@ static int shmem_notify_change(struct de
 			 * truncate_partial_page cannnot miss it were
 			 * it assigned to swap.
 			 */
-			if (attr->ia_size & (PAGE_CACHE_SIZE-1)) {
+			if (newsize & (PAGE_CACHE_SIZE-1)) {
 				(void) shmem_getpage(inode,
-					attr->ia_size>>PAGE_CACHE_SHIFT,
+					newsize >> PAGE_CACHE_SHIFT,
 						&page, SGP_READ, NULL);
 				if (page)
 					unlock_page(page);
@@ -797,13 +795,19 @@ static int shmem_notify_change(struct de
 			 * if it's being fully truncated to zero-length: the
 			 * nrpages check is efficient enough in that case.
 			 */
-			if (attr->ia_size) {
+			if (newsize) {
 				struct shmem_inode_info *info = SHMEM_I(inode);
 				spin_lock(&info->lock);
 				info->flags &= ~SHMEM_PAGEIN;
 				spin_unlock(&info->lock);
 			}
 		}
+
+		error = simple_setsize(inode, newsize);
+		if (error)
+			return error;
+		shmem_truncate_range(inode, newsize, (loff_t)-1);
+		attr->ia_valid &= ~ATTR_SIZE;
 	}
 
 	error = inode_change_ok(inode, attr);
@@ -822,11 +826,11 @@ static void shmem_delete_inode(struct in
 {
 	struct shmem_inode_info *info = SHMEM_I(inode);
 
-	if (inode->i_op->truncate == shmem_truncate) {
+	if (inode->i_mapping->a_ops == &shmem_aops) {
 		truncate_inode_pages(inode->i_mapping, 0);
 		shmem_unacct_size(info->flags, inode->i_size);
 		inode->i_size = 0;
-		shmem_truncate(inode);
+		shmem_truncate_range(inode, 0, (loff_t)-1);
 		if (!list_empty(&info->swaplist)) {
 			mutex_lock(&shmem_swaplist_mutex);
 			list_del_init(&info->swaplist);
@@ -2018,7 +2022,6 @@ static const struct inode_operations shm
 };
 
 static const struct inode_operations shmem_symlink_inode_operations = {
-	.truncate	= shmem_truncate,
 	.readlink	= generic_readlink,
 	.follow_link	= shmem_follow_link,
 	.put_link	= shmem_put_link,
@@ -2438,7 +2441,7 @@ static const struct file_operations shme
 };
 
 static const struct inode_operations shmem_inode_operations = {
-	.truncate	= shmem_truncate,
+	.new_truncate	= 1,
 	.setattr	= shmem_notify_change,
 	.truncate_range	= shmem_truncate_range,
 #ifdef CONFIG_TMPFS_POSIX_ACL
Index: linux-2.6/fs/ext2/ext2.h
===================================================================
--- linux-2.6.orig/fs/ext2/ext2.h
+++ linux-2.6/fs/ext2/ext2.h
@@ -122,7 +122,6 @@ extern int ext2_write_inode (struct inod
 extern void ext2_delete_inode (struct inode *);
 extern int ext2_sync_inode (struct inode *);
 extern int ext2_get_block(struct inode *, sector_t, struct buffer_head *, int);
-extern void ext2_truncate (struct inode *);
 extern int ext2_setattr (struct dentry *, struct iattr *);
 extern void ext2_set_inode_flags(struct inode *inode);
 extern void ext2_get_inode_flags(struct ext2_inode_info *);
Index: linux-2.6/fs/ext2/file.c
===================================================================
--- linux-2.6.orig/fs/ext2/file.c
+++ linux-2.6/fs/ext2/file.c
@@ -77,13 +77,13 @@ const struct file_operations ext2_xip_fi
 #endif
 
 const struct inode_operations ext2_file_inode_operations = {
-	.truncate	= ext2_truncate,
 #ifdef CONFIG_EXT2_FS_XATTR
 	.setxattr	= generic_setxattr,
 	.getxattr	= generic_getxattr,
 	.listxattr	= ext2_listxattr,
 	.removexattr	= generic_removexattr,
 #endif
+	.new_truncate	= 1,
 	.setattr	= ext2_setattr,
 	.permission	= ext2_permission,
 	.fiemap		= ext2_fiemap,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
