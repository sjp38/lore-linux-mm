Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 54D226B004F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 12:29:01 -0400 (EDT)
Date: Tue, 7 Jul 2009 12:30:42 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [rfc][patch 3/4] fs: new truncate sequence
Message-ID: <20090707163042.GA14947@infradead.org>
References: <20090707144423.GC2714@wotan.suse.de> <20090707144823.GE2714@wotan.suse.de> <20090707145820.GA9976@infradead.org> <20090707150257.GG2714@wotan.suse.de> <20090707150758.GA18075@infradead.org> <20090707154809.GH2714@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090707154809.GH2714@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 07, 2009 at 05:48:09PM +0200, Nick Piggin wrote:
> OK, so what do you suggest? If the filesystem defines
> ->setsize then do not pass ATTR_SIZE changes into setattr?
> But then do you also not pass in ATTR_TIME cchanges to setattr
> iff they  are together with ATTR_SIZE change? It sees also like
> quite a difficult calling convention.

Ok, I played around with these ideas and your patches a bit.  I think
we're actually best of to return to one of the early ideas and just
get rid of ->truncate without any replacement, e.g. let ->setattr
handle all of it.

Below is a patch ontop of you four patches that implements exactly that
and it looks surprisingly nice.  The only gotcha I can see is that we
need to audit for existing filesystems not implementing ->truncate
getting a behaviour change due to the checks to decide if we want
to call vmtruncate.  But most likely any existing filesystems without
->truncate using the buffer.c helper or direct I/O is buggy anyway.

Note that it doesn't touch i_alloc_mutex locking for now - if we go
down this route I would do the lock shift in one patch at the end of
the series.

This patch passes xfsqa for ext2 and doing some randoms ops for shmem
(it's mounted on /tmp on my test VM)

Index: linux-2.6/fs/ext2/ext2.h
===================================================================
--- linux-2.6.orig/fs/ext2/ext2.h	2009-07-07 17:15:22.591389224 +0200
+++ linux-2.6/fs/ext2/ext2.h	2009-07-07 17:15:26.185252886 +0200
@@ -122,7 +122,6 @@ extern int ext2_write_inode (struct inod
 extern void ext2_delete_inode (struct inode *);
 extern int ext2_sync_inode (struct inode *);
 extern int ext2_get_block(struct inode *, sector_t, struct buffer_head *, int);
-extern int ext2_setsize(struct dentry *, loff_t, unsigned int, struct file *);
 extern int ext2_setattr (struct dentry *, struct iattr *);
 extern void ext2_set_inode_flags(struct inode *inode);
 extern void ext2_get_inode_flags(struct ext2_inode_info *);
Index: linux-2.6/fs/ext2/file.c
===================================================================
--- linux-2.6.orig/fs/ext2/file.c	2009-07-07 17:15:10.028363845 +0200
+++ linux-2.6/fs/ext2/file.c	2009-07-07 17:15:19.283479548 +0200
@@ -77,7 +77,6 @@ const struct file_operations ext2_xip_fi
 #endif
 
 const struct inode_operations ext2_file_inode_operations = {
-	.setsize	= ext2_setsize,
 #ifdef CONFIG_EXT2_FS_XATTR
 	.setxattr	= generic_setxattr,
 	.getxattr	= generic_getxattr,
Index: linux-2.6/fs/ext2/inode.c
===================================================================
--- linux-2.6.orig/fs/ext2/inode.c	2009-07-07 17:15:10.045364476 +0200
+++ linux-2.6/fs/ext2/inode.c	2009-07-07 17:53:01.633240795 +0200
@@ -1145,55 +1145,6 @@ do_indirects:
 	mutex_unlock(&ei->truncate_mutex);
 }
 
-int ext2_setsize(struct dentry *dentry, loff_t newsize,
-			unsigned int flags, struct file *file)
-{
-	struct inode *inode = dentry->d_inode;
-	loff_t oldsize;
-	int error;
-
-	error = inode_newsize_ok(inode, newsize);
-	if (error)
-		return error;
-
-	if (!(S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode) ||
-	    S_ISLNK(inode->i_mode)))
-		return -EINVAL;
-	if (ext2_inode_is_fast_symlink(inode))
-		return -EINVAL;
-	if (IS_APPEND(inode) || IS_IMMUTABLE(inode))
-		return -EPERM;
-
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
-
-	oldsize = inode->i_size;
-	i_size_write(inode, newsize);
-	truncate_pagecache(inode, oldsize, newsize);
-
-	down_write(&inode->i_alloc_sem);
-	ext2_truncate_blocks(inode, newsize);
-	up_write(&inode->i_alloc_sem);
-
-	inode->i_mtime = inode->i_ctime = CURRENT_TIME_SEC;
-	if (inode_needs_sync(inode)) {
-		sync_mapping_buffers(inode->i_mapping);
-		ext2_sync_inode (inode);
-	} else {
-		mark_inode_dirty(inode);
-	}
-
-	return 0;
-}
-
 static struct ext2_inode *ext2_get_inode(struct super_block *sb, ino_t ino,
 					struct buffer_head **p)
 {
@@ -1510,11 +1461,62 @@ int ext2_sync_inode(struct inode *inode)
 	return sync_inode(inode, &wbc);
 }
 
+static int ext2_setsize(struct inode *inode, loff_t newsize)
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
+	ext2_truncate_blocks(inode, newsize);
+
+	inode->i_mtime = inode->i_ctime = CURRENT_TIME_SEC;
+	if (inode_needs_sync(inode)) {
+		sync_mapping_buffers(inode->i_mapping);
+		ext2_sync_inode (inode);
+	} else {
+		mark_inode_dirty(inode);
+	}
+
+	return 0;
+}
+
 int ext2_setattr(struct dentry *dentry, struct iattr *iattr)
 {
 	struct inode *inode = dentry->d_inode;
 	int error;
 
+	if (iattr->ia_valid & ATTR_SIZE) {
+		error = ext2_setsize(inode, iattr->ia_size);
+		if (error)
+			return error;
+	}
+
 	error = inode_change_ok(inode, iattr);
 	if (error)
 		return error;
Index: linux-2.6/fs/attr.c
===================================================================
--- linux-2.6.orig/fs/attr.c	2009-07-07 17:14:41.017394460 +0200
+++ linux-2.6/fs/attr.c	2009-07-07 17:23:06.618241423 +0200
@@ -206,24 +206,8 @@ int notify_change(struct dentry * dentry
 	if (error)
 		return error;
 
-	if (ia_valid & ATTR_SIZE) {
-		if (inode->i_op && inode->i_op->setsize) {
-			unsigned int flags = 0;
-			struct file *file = NULL;
-
-			if (ia_valid & ATTR_FILE) {
-				flags |= SETSIZE_FILE;
-				file = attr->ia_file;
-			}
-			if (ia_valid & ATTR_OPEN)
-				flags |= SETSIZE_OPEN;
-			error = inode->i_op->setsize(dentry, attr->ia_size,
-							flags, file);
-			if (error)
-				return error;
-		} else
-			down_write(&dentry->d_inode->i_alloc_sem);
-	}
+	if (ia_valid & ATTR_SIZE)
+		down_write(&dentry->d_inode->i_alloc_sem);
 
 	if (inode->i_op && inode->i_op->setattr) {
 		error = inode->i_op->setattr(dentry, attr);
@@ -239,7 +223,7 @@ int notify_change(struct dentry * dentry
 		}
 	}
 
-	if (ia_valid & ATTR_SIZE && !(inode->i_op && inode->i_op->setsize))
+	if (ia_valid & ATTR_SIZE)
 		up_write(&dentry->d_inode->i_alloc_sem);
 
 	if (!error)
Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c	2009-07-07 17:22:16.770364959 +0200
+++ linux-2.6/fs/buffer.c	2009-07-07 17:23:33.825268267 +0200
@@ -1993,11 +1993,11 @@ int block_write_begin(struct file *file,
 			 * outside i_size.  Trim these off again. Don't need
 			 * i_size_read because we hold i_mutex.
 			 *
-			 * Filesystems which define ->setsize must handle
+			 * Filesystems which do not define ->setsize must handle
 			 * this themselves.
 			 */
 			if (pos + len > inode->i_size)
-				if (!inode->i_op->setsize)
+				if (inode->i_op->truncate)
 					vmtruncate(inode, inode->i_size);
 		}
 	}
@@ -2599,7 +2599,7 @@ out_release:
 	*pagep = NULL;
 
 	if (pos + len > inode->i_size)
-		if (!inode->i_op->setsize)
+		if (inode->i_op->truncate)
 			vmtruncate(inode, inode->i_size);
 
 	return ret;
Index: linux-2.6/fs/direct-io.c
===================================================================
--- linux-2.6.orig/fs/direct-io.c	2009-07-07 17:22:16.710364362 +0200
+++ linux-2.6/fs/direct-io.c	2009-07-07 17:22:26.601241382 +0200
@@ -1217,7 +1217,7 @@ __blockdev_direct_IO(int rw, struct kioc
 		loff_t isize = i_size_read(inode);
 
 		if (end > isize && dio_lock_type == DIO_LOCKING)
-			if (!inode->i_op->setsize)
+			if (inode->i_op->truncate)
 				vmtruncate(inode, isize);
 	}
 
Index: linux-2.6/fs/libfs.c
===================================================================
--- linux-2.6.orig/fs/libfs.c	2009-07-07 17:21:07.357268403 +0200
+++ linux-2.6/fs/libfs.c	2009-07-07 17:21:32.413241823 +0200
@@ -329,10 +329,8 @@ int simple_rename(struct inode *old_dir,
 	return 0;
 }
 
-int simple_setsize(struct dentry *dentry, loff_t newsize,
-			unsigned flags, struct file *file)
+int simple_setsize(struct inode *inode, loff_t newsize)
 {
-	struct inode *inode = dentry->d_inode;
 	loff_t oldsize;
 	int error;
 
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h	2009-07-07 17:21:35.255363657 +0200
+++ linux-2.6/include/linux/fs.h	2009-07-07 17:23:14.795241323 +0200
@@ -431,12 +431,6 @@ typedef void (dio_iodone_t)(struct kiocb
 #define ATTR_TIMES_SET	(1 << 16)
 
 /*
- * Setsize flags.
- */
-#define SETSIZE_FILE	(1 << 0) /* Trucating via an open file (eg ftruncate) */
-#define SETSIZE_OPEN	(1 << 1) /* Truncating from open(O_TRUNC) */
-
-/*
  * This is the Inode Attributes structure, used for notify_change().  It
  * uses the above definitions as flags, to know which values have changed.
  * Also, in this manner, a Filesystem can look at only the values it cares
@@ -1533,7 +1527,6 @@ struct inode_operations {
 	void * (*follow_link) (struct dentry *, struct nameidata *);
 	void (*put_link) (struct dentry *, struct nameidata *, void *);
 	void (*truncate) (struct inode *);
-	int (*setsize) (struct dentry *, loff_t, unsigned, struct file *);
 	int (*permission) (struct inode *, int);
 	int (*setattr) (struct dentry *, struct iattr *);
 	int (*getattr) (struct vfsmount *mnt, struct dentry *, struct kstat *);
@@ -2339,8 +2332,7 @@ extern int simple_link(struct dentry *, 
 extern int simple_unlink(struct inode *, struct dentry *);
 extern int simple_rmdir(struct inode *, struct dentry *);
 extern int simple_rename(struct inode *, struct dentry *, struct inode *, struct dentry *);
-extern int simple_setsize(struct dentry *dentry, loff_t newsize,
-			unsigned flags, struct file *file);
+extern int simple_setsize(struct inode *inode, loff_t newsize);
 extern int simple_sync_file(struct file *, struct dentry *, int);
 extern int simple_empty(struct dentry *);
 extern int simple_readpage(struct file *file, struct page *page);
Index: linux-2.6/mm/shmem.c
===================================================================
--- linux-2.6.orig/mm/shmem.c	2009-07-07 17:19:51.972394381 +0200
+++ linux-2.6/mm/shmem.c	2009-07-07 17:53:20.961241413 +0200
@@ -764,25 +764,19 @@ done2:
 	}
 }
 
-static int shmem_setsize(struct dentry *dentry, loff_t newsize,
-			unsigned int flags, struct file *file)
-{
-	int error;
-
-	error = simple_setsize(dentry, newsize, flags, file);
-	if (error)
-		return error;
-	shmem_truncate_range(dentry->d_inode, newsize, (loff_t)-1);
-
-	return error;
-}
-
 static int shmem_notify_change(struct dentry *dentry, struct iattr *attr)
 {
 	struct inode *inode = dentry->d_inode;
 	struct page *page = NULL;
 	int error;
 
+	if (attr->ia_valid & ATTR_SIZE) {
+		error = simple_setsize(dentry->d_inode, attr->ia_size);
+		if (error)
+			return error;
+		shmem_truncate_range(dentry->d_inode, attr->ia_size, -1);
+	}
+
 	if (S_ISREG(inode->i_mode) && (attr->ia_valid & ATTR_SIZE)) {
 		if (attr->ia_size < inode->i_size) {
 			/*
@@ -831,7 +825,7 @@ static void shmem_delete_inode(struct in
 {
 	struct shmem_inode_info *info = SHMEM_I(inode);
 
-	if (inode->i_op->setsize == shmem_setsize) {
+	if (inode->i_mapping->a_ops == &shmem_aops) {
 		truncate_inode_pages(inode->i_mapping, 0);
 		shmem_unacct_size(info->flags, inode->i_size);
 		inode->i_size = 0;
@@ -2027,7 +2021,6 @@ static const struct inode_operations shm
 };
 
 static const struct inode_operations shmem_symlink_inode_operations = {
-	.setsize	= shmem_setsize,
 	.readlink	= generic_readlink,
 	.follow_link	= shmem_follow_link,
 	.put_link	= shmem_put_link,
@@ -2447,7 +2440,6 @@ static const struct file_operations shme
 };
 
 static const struct inode_operations shmem_inode_operations = {
-	.setsize	= shmem_setsize,
 	.setattr	= shmem_notify_change,
 	.truncate_range	= shmem_truncate_range,
 #ifdef CONFIG_TMPFS_POSIX_ACL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
