Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E19226B004F
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 12:42:10 -0400 (EDT)
Date: Thu, 25 Jun 2009 18:43:21 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 02/11] vfs: Add better VFS support for page_mkwrite when blocksize < pagesize
Message-ID: <20090625164321.GC30755@wotan.suse.de>
References: <1245088797-29533-1-git-send-email-jack@suse.cz> <1245088797-29533-3-git-send-email-jack@suse.cz> <20090625161753.GB30755@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090625161753.GB30755@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 25, 2009 at 06:17:53PM +0200, Nick Piggin wrote:
> On Mon, Jun 15, 2009 at 07:59:49PM +0200, Jan Kara wrote:
> My patch is basically moving ->truncate call into setattr, and have
> the filesystem call vmtruncate. I've jt to clean up loose ends.
> 
> Now I may be speaking too soon. It might trun out that my fix is
> complex as well, but let me just give you an RFC and we can discuss.

Well this is the basics of the truncate rearrangement, obviously
not finished but it should give the fs enough flexiblity to DTRT
to fix the mapped partial page problem I think.

I'll followup with a patch for that if I can make it work.

---
 fs/attr.c          |   47 +++++++++++++++++++++++++++++++++++++++++------
 fs/buffer.c        |    6 ++++++
 fs/ext2/ext2.h     |    2 +-
 fs/ext2/inode.c    |   38 +++++++++++++++++++++++---------------
 fs/libfs.c         |   13 +++++++++++++
 include/linux/fs.h |    4 +++-
 include/linux/mm.h |    2 +-
 mm/filemap_xip.c   |    9 ++++++---
 mm/memory.c        |   25 +------------------------
 mm/shmem.c         |   12 +++++++++---
 10 files changed, 104 insertions(+), 54 deletions(-)

Index: linux-2.6/fs/attr.c
===================================================================
--- linux-2.6.orig/fs/attr.c
+++ linux-2.6/fs/attr.c
@@ -60,18 +60,53 @@ fine:
 error:
 	return retval;
 }
-
 EXPORT_SYMBOL(inode_change_ok);
 
+int inode_truncate_ok(struct inode *inode, loff_t offset)
+{
+	if (inode->i_size < offset) {
+		unsigned long limit;
+
+		limit = current->signal->rlim[RLIMIT_FSIZE].rlim_cur;
+		if (limit != RLIM_INFINITY && offset > limit)
+			goto out_sig;
+		if (offset > inode->i_sb->s_maxbytes)
+			goto out_big;
+	} else {
+		/*
+		 * truncation of in-use swapfiles is disallowed - it would
+		 * cause subsequent swapout to scribble on the now-freed
+		 * blocks.
+		 */
+		if (IS_SWAPFILE(inode))
+			return -ETXTBSY;
+	}
+
+	return 0;
+out_sig:
+	send_sig(SIGXFSZ, current, 0);
+out_big:
+	return -EFBIG;
+}
+EXPORT_SYMBOL(inode_truncate_ok);
+
 int inode_setattr(struct inode * inode, struct iattr * attr)
 {
 	unsigned int ia_valid = attr->ia_valid;
 
-	if (ia_valid & ATTR_SIZE &&
-	    attr->ia_size != i_size_read(inode)) {
-		int error = vmtruncate(inode, attr->ia_size);
-		if (error)
-			return error;
+	if (ia_valid & ATTR_SIZE) {
+		loff_t offset = attr->ia_size;
+
+		if (offset != inode->i_size) {
+			int error;
+
+			if (inode->i_op->truncate)
+				error = inode->i_op->truncate(inode, offset);
+			else
+				error = simple_truncate(inode, offset);
+			if (error)
+				return error;
+		}
 	}
 
 	if (ia_valid & ATTR_UID)
Index: linux-2.6/fs/ext2/inode.c
===================================================================
--- linux-2.6.orig/fs/ext2/inode.c
+++ linux-2.6/fs/ext2/inode.c
@@ -68,7 +68,7 @@ void ext2_delete_inode (struct inode * i
 
 	inode->i_size = 0;
 	if (inode->i_blocks)
-		ext2_truncate (inode);
+		ext2_truncate(inode, 0);
 	ext2_free_inode (inode);
 
 	return;
@@ -1020,7 +1020,7 @@ static void ext2_free_branches(struct in
 		ext2_free_data(inode, p, q);
 }
 
-void ext2_truncate(struct inode *inode)
+int ext2_truncate(struct inode *inode, loff_t offset)
 {
 	__le32 *i_data = EXT2_I(inode)->i_data;
 	struct ext2_inode_info *ei = EXT2_I(inode);
@@ -1032,31 +1032,37 @@ void ext2_truncate(struct inode *inode)
 	int n;
 	long iblock;
 	unsigned blocksize;
+	int error;
+
+	error = inode_truncate_ok(inode, offset);
+	if (error)
+		return error;
 
 	if (!(S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode) ||
 	    S_ISLNK(inode->i_mode)))
-		return;
+		return -EINVAL;
 	if (ext2_inode_is_fast_symlink(inode))
-		return;
+		return -EINVAL;
 	if (IS_APPEND(inode) || IS_IMMUTABLE(inode))
-		return;
-
-	blocksize = inode->i_sb->s_blocksize;
-	iblock = (inode->i_size + blocksize-1)
-					>> EXT2_BLOCK_SIZE_BITS(inode->i_sb);
+		return -EPERM;
 
 	if (mapping_is_xip(inode->i_mapping))
-		xip_truncate_page(inode->i_mapping, inode->i_size);
+		error = xip_truncate_page(inode->i_mapping, offset);
 	else if (test_opt(inode->i_sb, NOBH))
-		nobh_truncate_page(inode->i_mapping,
-				inode->i_size, ext2_get_block);
+		error = nobh_truncate_page(inode->i_mapping,
+				offset, ext2_get_block);
 	else
-		block_truncate_page(inode->i_mapping,
-				inode->i_size, ext2_get_block);
+		error = block_truncate_page(inode->i_mapping,
+				offset, ext2_get_block);
+	if (error)
+		return error;
+
+	blocksize = inode->i_sb->s_blocksize;
+	iblock = (offset + blocksize-1) >> EXT2_BLOCK_SIZE_BITS(inode->i_sb);
 
 	n = ext2_block_to_path(inode, iblock, offsets, NULL);
 	if (n == 0)
-		return;
+		return 0;
 
 	/*
 	 * From here we block out all ext2_get_block() callers who want to
@@ -1127,6 +1133,8 @@ do_indirects:
 	} else {
 		mark_inode_dirty(inode);
 	}
+
+	return 0;
 }
 
 static struct ext2_inode *ext2_get_inode(struct super_block *sb, ino_t ino,
Index: linux-2.6/fs/libfs.c
===================================================================
--- linux-2.6.orig/fs/libfs.c
+++ linux-2.6/fs/libfs.c
@@ -329,6 +329,18 @@ int simple_rename(struct inode *old_dir,
 	return 0;
 }
 
+int simple_truncate(struct inode * inode, loff_t offset)
+{
+	int error;
+
+	error = inode_truncate_ok(inode, offset);
+	if (error)
+		return error;
+	vmtruncate(inode, offset);
+
+	return error;
+}
+
 int simple_readpage(struct file *file, struct page *page)
 {
 	clear_highpage(page);
@@ -840,6 +852,7 @@ EXPORT_SYMBOL(generic_read_dir);
 EXPORT_SYMBOL(get_sb_pseudo);
 EXPORT_SYMBOL(simple_write_begin);
 EXPORT_SYMBOL(simple_write_end);
+EXPORT_SYMBOL(simple_truncate);
 EXPORT_SYMBOL(simple_dir_inode_operations);
 EXPORT_SYMBOL(simple_dir_operations);
 EXPORT_SYMBOL(simple_empty);
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h
+++ linux-2.6/include/linux/fs.h
@@ -1526,7 +1526,7 @@ struct inode_operations {
 	int (*readlink) (struct dentry *, char __user *,int);
 	void * (*follow_link) (struct dentry *, struct nameidata *);
 	void (*put_link) (struct dentry *, struct nameidata *, void *);
-	void (*truncate) (struct inode *);
+	int (*truncate) (struct inode *, loff_t);
 	int (*permission) (struct inode *, int);
 	int (*setattr) (struct dentry *, struct iattr *);
 	int (*getattr) (struct vfsmount *mnt, struct dentry *, struct kstat *);
@@ -2332,6 +2332,7 @@ extern int simple_link(struct dentry *,
 extern int simple_unlink(struct inode *, struct dentry *);
 extern int simple_rmdir(struct inode *, struct dentry *);
 extern int simple_rename(struct inode *, struct dentry *, struct inode *, struct dentry *);
+extern int simple_truncate(struct inode *inode, loff_t offset);
 extern int simple_sync_file(struct file *, struct dentry *, int);
 extern int simple_empty(struct dentry *);
 extern int simple_readpage(struct file *file, struct page *page);
@@ -2367,6 +2368,7 @@ extern int buffer_migrate_page(struct ad
 #endif
 
 extern int inode_change_ok(struct inode *, struct iattr *);
+extern int inode_truncate_ok(struct inode *, loff_t offset);
 extern int __must_check inode_setattr(struct inode *, struct iattr *);
 
 extern void file_update_time(struct file *file);
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -805,7 +805,7 @@ static inline void unmap_shared_mapping_
 	unmap_mapping_range(mapping, holebegin, holelen, 0);
 }
 
-extern int vmtruncate(struct inode * inode, loff_t offset);
+extern void vmtruncate(struct inode * inode, loff_t offset);
 extern int vmtruncate_range(struct inode * inode, loff_t offset, loff_t end);
 
 #ifdef CONFIG_MMU
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -2420,27 +2420,13 @@ EXPORT_SYMBOL(unmap_mapping_range);
  * between the file and the memory map for a potential last
  * incomplete page.  Ugly, but necessary.
  */
-int vmtruncate(struct inode * inode, loff_t offset)
+void vmtruncate(struct inode * inode, loff_t offset)
 {
 	if (inode->i_size < offset) {
-		unsigned long limit;
-
-		limit = current->signal->rlim[RLIMIT_FSIZE].rlim_cur;
-		if (limit != RLIM_INFINITY && offset > limit)
-			goto out_sig;
-		if (offset > inode->i_sb->s_maxbytes)
-			goto out_big;
 		i_size_write(inode, offset);
 	} else {
 		struct address_space *mapping = inode->i_mapping;
 
-		/*
-		 * truncation of in-use swapfiles is disallowed - it would
-		 * cause subsequent swapout to scribble on the now-freed
-		 * blocks.
-		 */
-		if (IS_SWAPFILE(inode))
-			return -ETXTBSY;
 		i_size_write(inode, offset);
 
 		/*
@@ -2456,15 +2442,6 @@ int vmtruncate(struct inode * inode, lof
 		truncate_inode_pages(mapping, offset);
 		unmap_mapping_range(mapping, offset + PAGE_SIZE - 1, 0, 1);
 	}
-
-	if (inode->i_op->truncate)
-		inode->i_op->truncate(inode);
-	return 0;
-
-out_sig:
-	send_sig(SIGXFSZ, current, 0);
-out_big:
-	return -EFBIG;
 }
 EXPORT_SYMBOL(vmtruncate);
 
Index: linux-2.6/mm/shmem.c
===================================================================
--- linux-2.6.orig/mm/shmem.c
+++ linux-2.6/mm/shmem.c
@@ -763,9 +763,15 @@ done2:
 	}
 }
 
-static void shmem_truncate(struct inode *inode)
+static int shmem_truncate(struct inode *inode, loff_t offset)
 {
-	shmem_truncate_range(inode, inode->i_size, (loff_t)-1);
+	int error;
+	error = inode_truncate_ok(inode, offset);
+	if (error)
+		return error;
+	vmtruncate(inode, offset);
+	shmem_truncate_range(inode, offset, (loff_t)-1);
+	return error;
 }
 
 static int shmem_notify_change(struct dentry *dentry, struct iattr *attr)
@@ -826,7 +832,7 @@ static void shmem_delete_inode(struct in
 		truncate_inode_pages(inode->i_mapping, 0);
 		shmem_unacct_size(info->flags, inode->i_size);
 		inode->i_size = 0;
-		shmem_truncate(inode);
+		shmem_truncate(inode, 0);
 		if (!list_empty(&info->swaplist)) {
 			mutex_lock(&shmem_swaplist_mutex);
 			list_del_init(&info->swaplist);
Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -2768,6 +2768,9 @@ unlock:
 	unlock_page(page);
 	page_cache_release(page);
 out:
+	if (!err)
+		vmtruncate(inode, from);
+
 	return err;
 }
 EXPORT_SYMBOL(nobh_truncate_page);
@@ -2844,6 +2847,9 @@ unlock:
 	unlock_page(page);
 	page_cache_release(page);
 out:
+	if (!err)
+		vmtruncate(inode, from);
+
 	return err;
 }
 
Index: linux-2.6/fs/ext2/ext2.h
===================================================================
--- linux-2.6.orig/fs/ext2/ext2.h
+++ linux-2.6/fs/ext2/ext2.h
@@ -122,7 +122,7 @@ extern int ext2_write_inode (struct inod
 extern void ext2_delete_inode (struct inode *);
 extern int ext2_sync_inode (struct inode *);
 extern int ext2_get_block(struct inode *, sector_t, struct buffer_head *, int);
-extern void ext2_truncate (struct inode *);
+extern int ext2_truncate (struct inode *, loff_t);
 extern int ext2_setattr (struct dentry *, struct iattr *);
 extern void ext2_set_inode_flags(struct inode *inode);
 extern void ext2_get_inode_flags(struct ext2_inode_info *);
Index: linux-2.6/mm/filemap_xip.c
===================================================================
--- linux-2.6.orig/mm/filemap_xip.c
+++ linux-2.6/mm/filemap_xip.c
@@ -440,6 +440,7 @@ EXPORT_SYMBOL_GPL(xip_file_write);
 int
 xip_truncate_page(struct address_space *mapping, loff_t from)
 {
+	struct inode *inode = mapping->host;
 	pgoff_t index = from >> PAGE_CACHE_SHIFT;
 	unsigned offset = from & (PAGE_CACHE_SIZE-1);
 	unsigned blocksize;
@@ -450,12 +451,12 @@ xip_truncate_page(struct address_space *
 
 	BUG_ON(!mapping->a_ops->get_xip_mem);
 
-	blocksize = 1 << mapping->host->i_blkbits;
+	blocksize = 1 << inode->i_blkbits;
 	length = offset & (blocksize - 1);
 
 	/* Block boundary? Nothing to do */
 	if (!length)
-		return 0;
+		goto out;
 
 	length = blocksize - length;
 
@@ -464,11 +465,13 @@ xip_truncate_page(struct address_space *
 	if (unlikely(err)) {
 		if (err == -ENODATA)
 			/* Hole? No need to truncate */
-			return 0;
+			goto out;
 		else
 			return err;
 	}
 	memset(xip_mem + offset, 0, length);
+out:
+	vmtruncate(host, from);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(xip_truncate_page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
