Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D0E6D6B0055
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 10:47:15 -0400 (EDT)
Date: Tue, 7 Jul 2009 16:48:23 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch 3/4] fs: new truncate sequence
Message-ID: <20090707144823.GE2714@wotan.suse.de>
References: <20090707144423.GC2714@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090707144423.GC2714@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Don't know whether it is a good idea to move i_alloc_sem into implementation.
Maybe it is better to leave it in the caller in this patchset?
--

Introduce a new truncate calling sequence into fs/mm subsystems. Rather than
setattr > vmtruncate > truncate, add a new inode operation ->setsize, called
from notify_change when called with ATTR_SIZE. The filesystem will be
responsible for updating i_size and truncating pagecache. ->setattr will
still be called with ATTR_SIZE.

Generic code which previously called vmtruncate (in order to truncate blocks
that may have been instantiated past i_size) no longer calls vmtruncate in the
case that the inode has an ->setsize attribute. In that case it is the
responsibility of the caller to trim off blocks appropriately in case of
error.

Big problem with the previous calling sequence: the filesystem is not called
until i_size has already changed.  This means it is not allowed to fail the
call, and also it does not know what the previous i_size was. Also, generic
code calling vmtruncate to truncate allocated blocks in case of error had
no good way to return a meaningful error (or, for example, atomically handle
block deallocation).

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 Documentation/filesystems/Locking |    2 ++
 Documentation/filesystems/vfs.txt |    9 ++++++++-
 fs/attr.c                         |   22 +++++++++++++++++++---
 fs/buffer.c                       |   11 ++++++++---
 fs/configfs/inode.c               |    1 +
 fs/direct-io.c                    |    7 ++++---
 fs/libfs.c                        |   19 +++++++++++++++++++
 fs/ramfs/file-mmu.c               |    1 +
 include/linux/fs.h                |    9 +++++++++
 9 files changed, 71 insertions(+), 10 deletions(-)

Index: linux-2.6/fs/libfs.c
===================================================================
--- linux-2.6.orig/fs/libfs.c
+++ linux-2.6/fs/libfs.c
@@ -329,6 +329,24 @@ int simple_rename(struct inode *old_dir,
 	return 0;
 }
 
+int simple_setsize(struct dentry *dentry, loff_t newsize,
+			unsigned flags, struct file *file)
+{
+	struct inode *inode = dentry->d_inode;
+	loff_t oldsize;
+	int error;
+
+	error = inode_newsize_ok(inode, newsize);
+	if (error)
+		return error;
+
+	oldsize = inode->i_size;
+	i_size_write(inode, newsize);
+	truncate_pagecache(inode, oldsize, newsize);
+
+	return error;
+}
+
 int simple_readpage(struct file *file, struct page *page)
 {
 	clear_highpage(page);
@@ -840,6 +858,7 @@ EXPORT_SYMBOL(generic_read_dir);
 EXPORT_SYMBOL(get_sb_pseudo);
 EXPORT_SYMBOL(simple_write_begin);
 EXPORT_SYMBOL(simple_write_end);
+EXPORT_SYMBOL(simple_setsize);
 EXPORT_SYMBOL(simple_dir_inode_operations);
 EXPORT_SYMBOL(simple_dir_operations);
 EXPORT_SYMBOL(simple_empty);
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h
+++ linux-2.6/include/linux/fs.h
@@ -431,6 +431,12 @@ typedef void (dio_iodone_t)(struct kiocb
 #define ATTR_TIMES_SET	(1 << 16)
 
 /*
+ * Setsize flags.
+ */
+#define SETSIZE_FILE	(1 << 0) /* Trucating via an open file (eg ftruncate) */
+#define SETSIZE_OPEN	(1 << 1) /* Truncating from open(O_TRUNC) */
+
+/*
  * This is the Inode Attributes structure, used for notify_change().  It
  * uses the above definitions as flags, to know which values have changed.
  * Also, in this manner, a Filesystem can look at only the values it cares
@@ -1527,6 +1533,7 @@ struct inode_operations {
 	void * (*follow_link) (struct dentry *, struct nameidata *);
 	void (*put_link) (struct dentry *, struct nameidata *, void *);
 	void (*truncate) (struct inode *);
+	int (*setsize) (struct dentry *, loff_t, unsigned, struct file *);
 	int (*permission) (struct inode *, int);
 	int (*setattr) (struct dentry *, struct iattr *);
 	int (*getattr) (struct vfsmount *mnt, struct dentry *, struct kstat *);
@@ -2332,6 +2339,8 @@ extern int simple_link(struct dentry *,
 extern int simple_unlink(struct inode *, struct dentry *);
 extern int simple_rmdir(struct inode *, struct dentry *);
 extern int simple_rename(struct inode *, struct dentry *, struct inode *, struct dentry *);
+extern int simple_setsize(struct dentry *dentry, loff_t newsize,
+			unsigned flags, struct file *file);
 extern int simple_sync_file(struct file *, struct dentry *, int);
 extern int simple_empty(struct dentry *);
 extern int simple_readpage(struct file *file, struct page *page);
Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -1992,9 +1992,13 @@ int block_write_begin(struct file *file,
 			 * prepare_write() may have instantiated a few blocks
 			 * outside i_size.  Trim these off again. Don't need
 			 * i_size_read because we hold i_mutex.
+			 *
+			 * Filesystems which define ->setsize must handle
+			 * this themselves.
 			 */
 			if (pos + len > inode->i_size)
-				vmtruncate(inode, inode->i_size);
+				if (!inode->i_op->setsize)
+					vmtruncate(inode, inode->i_size);
 		}
 	}
 
@@ -2371,7 +2375,7 @@ int block_commit_write(struct page *page
  *
  * We are not allowed to take the i_mutex here so we have to play games to
  * protect against truncate races as the page could now be beyond EOF.  Because
- * vmtruncate() writes the inode size before removing pages, once we have the
+ * truncate writes the inode size before removing pages, once we have the
  * page lock we can determine safely if the page is beyond EOF. If it is not
  * beyond EOF, then the page is guaranteed safe against truncation until we
  * unlock the page.
@@ -2595,7 +2599,8 @@ out_release:
 	*pagep = NULL;
 
 	if (pos + len > inode->i_size)
-		vmtruncate(inode, inode->i_size);
+		if (!inode->i_op->setsize)
+			vmtruncate(inode, inode->i_size);
 
 	return ret;
 }
Index: linux-2.6/fs/direct-io.c
===================================================================
--- linux-2.6.orig/fs/direct-io.c
+++ linux-2.6/fs/direct-io.c
@@ -1210,14 +1210,15 @@ __blockdev_direct_IO(int rw, struct kioc
 	/*
 	 * In case of error extending write may have instantiated a few
 	 * blocks outside i_size. Trim these off again for DIO_LOCKING.
-	 * NOTE: DIO_NO_LOCK/DIO_OWN_LOCK callers have to handle this by
-	 * it's own meaner.
+	 * NOTE: DIO_NO_LOCK/DIO_OWN_LOCK callers have to handle this in
+	 * their own manner.
 	 */
 	if (unlikely(retval < 0 && (rw & WRITE))) {
 		loff_t isize = i_size_read(inode);
 
 		if (end > isize && dio_lock_type == DIO_LOCKING)
-			vmtruncate(inode, isize);
+			if (!inode->i_op->setsize)
+				vmtruncate(inode, isize);
 	}
 
 	if (rw == READ && dio_lock_type == DIO_LOCKING)
Index: linux-2.6/Documentation/filesystems/Locking
===================================================================
--- linux-2.6.orig/Documentation/filesystems/Locking
+++ linux-2.6/Documentation/filesystems/Locking
@@ -45,6 +45,7 @@ ata *);
 	int (*follow_link) (struct dentry *, struct nameidata *);
 	void (*truncate) (struct inode *);
 	int (*permission) (struct inode *, int, struct nameidata *);
+	int (*setsize) (struct dentry *, loff_t, unsigned, struct file *);
 	int (*setattr) (struct dentry *, struct iattr *);
 	int (*getattr) (struct vfsmount *, struct dentry *, struct kstat *);
 	int (*setxattr) (struct dentry *, const char *,const void *,size_t,int);
@@ -67,6 +68,7 @@ rename:		yes (all)	(see below)
 readlink:	no
 follow_link:	no
 truncate:	yes		(see below)
+setsize:	yes
 setattr:	yes
 permission:	no
 getattr:	no
Index: linux-2.6/fs/attr.c
===================================================================
--- linux-2.6.orig/fs/attr.c
+++ linux-2.6/fs/attr.c
@@ -206,8 +206,24 @@ int notify_change(struct dentry * dentry
 	if (error)
 		return error;
 
-	if (ia_valid & ATTR_SIZE)
-		down_write(&dentry->d_inode->i_alloc_sem);
+	if (ia_valid & ATTR_SIZE) {
+		if (inode->i_op && inode->i_op->setsize) {
+			unsigned int flags = 0;
+			struct file *file = NULL;
+
+			if (ia_valid & ATTR_FILE) {
+				flags |= SETSIZE_FILE;
+				file = attr->ia_file;
+			}
+			if (ia_valid & ATTR_OPEN)
+				flags |= SETSIZE_OPEN;
+			error = inode->i_op->setsize(dentry, attr->ia_size,
+							flags, file);
+			if (error)
+				return error;
+		} else
+			down_write(&dentry->d_inode->i_alloc_sem);
+	}
 
 	if (inode->i_op && inode->i_op->setattr) {
 		error = inode->i_op->setattr(dentry, attr);
@@ -223,7 +239,7 @@ int notify_change(struct dentry * dentry
 		}
 	}
 
-	if (ia_valid & ATTR_SIZE)
+	if (ia_valid & ATTR_SIZE && !(inode->i_op && inode->i_op->setsize))
 		up_write(&dentry->d_inode->i_alloc_sem);
 
 	if (!error)
Index: linux-2.6/Documentation/filesystems/vfs.txt
===================================================================
--- linux-2.6.orig/Documentation/filesystems/vfs.txt
+++ linux-2.6/Documentation/filesystems/vfs.txt
@@ -326,6 +326,7 @@ struct inode_operations {
         void (*put_link) (struct dentry *, struct nameidata *, void *);
 	void (*truncate) (struct inode *);
 	int (*permission) (struct inode *, int, struct nameidata *);
+	int (*setsize) (struct dentry *, loff_t, unsigned, struct file *);
 	int (*setattr) (struct dentry *, struct iattr *);
 	int (*getattr) (struct vfsmount *mnt, struct dentry *, struct kstat *);
 	int (*setxattr) (struct dentry *, const char *,const void *,size_t,int);
@@ -401,7 +402,8 @@ otherwise noted.
   	started might not be in the page cache at the end of the
   	walk).
 
-  truncate: called by the VFS to change the size of a file.  The
+  truncate: Deprecated. This will not be called if ->setsize is defined.
+	Called by the VFS to change the size of a file.  The
  	i_size field of the inode is set to the desired size by the
  	VFS before this method is called.  This method is called by
  	the truncate(2) system call and related functionality.
@@ -409,6 +411,11 @@ otherwise noted.
   permission: called by the VFS to check for access rights on a POSIX-like
   	filesystem.
 
+  setsize: Supersedes truncate. Called by the VFS to change the size of a file.
+	It is the responsibility of the implementation to check size is OK
+	(eg. using inode_newsize_ok()), update i_size, and trim pagecache
+	(eg. using truncate_pagecache()).
+
   setattr: called by the VFS to set attributes for a file. This method
   	is called by chmod(2) and related system calls.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
