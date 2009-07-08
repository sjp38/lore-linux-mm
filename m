Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2B0836B004F
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 08:25:48 -0400 (EDT)
Date: Wed, 8 Jul 2009 14:34:12 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 3/4] fs: new truncate sequence
Message-ID: <20090708123412.GQ2714@wotan.suse.de>
References: <20090707144423.GC2714@wotan.suse.de> <20090707144823.GE2714@wotan.suse.de> <20090707145820.GA9976@infradead.org> <20090707150257.GG2714@wotan.suse.de> <20090707150758.GA18075@infradead.org> <20090707154809.GH2714@wotan.suse.de> <20090707163042.GA14947@infradead.org> <20090708063225.GL2714@wotan.suse.de> <20090708104701.GA31419@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090708104701.GA31419@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 08, 2009 at 06:47:01AM -0400, Christoph Hellwig wrote:
> On Wed, Jul 08, 2009 at 08:32:25AM +0200, Nick Piggin wrote:
> > Thanks for the patch, I think I will fold it in to the series. I
> > think we probably do need to call simple_setsize in inode_setattr
> > though (unless you propose to eventually convert every filesystem
> > to define a .setattr). This would also require eg. your ext2
> > conversion to strip ATTR_SIZE before passing through to inode_setattr.
> 
> Yes, we should eventually make .setattr mandatory.  Doing a default
> action when a method lacks tends to cause more issues than it solves.
> 
> I'm happy to help in doing that part of the conversion (and also other
> bits)

OK well here is what I have now for 3/4 and 4/4. Basically just
folded your patch on top, changed ordering of some checks, have
fs clear ATTR_SIZE before calling inode_setattr, add a .new_truncate
field to check against rather than .truncate, and provide a default
ATTR_SIZE handler in inode_setattr (simple_setsize).

---
Introduce a new truncate calling sequence into fs/mm subsystems. Rather than
setattr > vmtruncate > truncate, have filesystems call their truncate sequence
from ->setattr if filesystem specific operations are required. vmtruncate is
deprecated, and truncate_pagecache and inode_newsize_ok helpers introduced
previously should be used.

simple_setsize is also introduced to perform the equivalent of vmtruncate.
simple_setsize gets called by inode_setattr when ATTR_SIZE is passed. So
filesystems implementing their own truncate code in setattr then calling
through to inode_setattr should clear ATTR_SIZE.

A new attribute is introduced into inode_operations structure; .new_truncate
is a temporary hack to distinguish filesystems that implement the new
truncate system. These guys cannot trim off block past i_size via vmtruncate,
so instead they must handle it in fs code. This gives better opportunity to
catch errors etc anyway. .new_truncate and .truncate will go away once all
filesystems are converted.

Big problem with the previous calling sequence: the filesystem is not called
until i_size has already changed.  This means it is not allowed to fail the
call, and also it does not know what the previous i_size was. Also, generic
code calling vmtruncate to truncate allocated blocks in case of error had
no good way to return a meaningful error (or, for example, atomically handle
block deallocation).

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 Documentation/filesystems/vfs.txt |    7 ++++++-
 fs/attr.c                         |    7 ++++++-
 fs/buffer.c                       |   12 +++++++++---
 fs/direct-io.c                    |    7 ++++---
 fs/libfs.c                        |   17 +++++++++++++++++
 include/linux/fs.h                |    2 ++
 mm/truncate.c                     |    6 ++----
 7 files changed, 46 insertions(+), 12 deletions(-)

Index: linux-2.6/fs/libfs.c
===================================================================
--- linux-2.6.orig/fs/libfs.c
+++ linux-2.6/fs/libfs.c
@@ -329,6 +329,22 @@ int simple_rename(struct inode *old_dir,
 	return 0;
 }
 
+int simple_setsize(struct inode *inode, loff_t newsize)
+{
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
@@ -840,6 +856,7 @@ EXPORT_SYMBOL(generic_read_dir);
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
@@ -1527,6 +1527,7 @@ struct inode_operations {
 	void * (*follow_link) (struct dentry *, struct nameidata *);
 	void (*put_link) (struct dentry *, struct nameidata *, void *);
 	void (*truncate) (struct inode *);
+	int new_truncate; /* nasty hack to transition to new truncate code */
 	int (*permission) (struct inode *, int);
 	int (*setattr) (struct dentry *, struct iattr *);
 	int (*getattr) (struct vfsmount *mnt, struct dentry *, struct kstat *);
@@ -2332,6 +2333,7 @@ extern int simple_link(struct dentry *,
 extern int simple_unlink(struct inode *, struct dentry *);
 extern int simple_rmdir(struct inode *, struct dentry *);
 extern int simple_rename(struct inode *, struct dentry *, struct inode *, struct dentry *);
+extern int simple_setsize(struct inode *inode, loff_t newsize);
 extern int simple_sync_file(struct file *, struct dentry *, int);
 extern int simple_empty(struct dentry *);
 extern int simple_readpage(struct file *file, struct page *page);
Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -1992,9 +1992,14 @@ int block_write_begin(struct file *file,
 			 * prepare_write() may have instantiated a few blocks
 			 * outside i_size.  Trim these off again. Don't need
 			 * i_size_read because we hold i_mutex.
+			 *
+			 * Filesystems which define i_op->new_truncate must
+			 * handle this themselves. Eventually this will go
+			 * away because everyone will be converted.
 			 */
 			if (pos + len > inode->i_size)
-				vmtruncate(inode, inode->i_size);
+				if (!inode->i_op->new_truncate)
+					vmtruncate(inode, inode->i_size);
 		}
 	}
 
@@ -2371,7 +2376,7 @@ int block_commit_write(struct page *page
  *
  * We are not allowed to take the i_mutex here so we have to play games to
  * protect against truncate races as the page could now be beyond EOF.  Because
- * vmtruncate() writes the inode size before removing pages, once we have the
+ * truncate writes the inode size before removing pages, once we have the
  * page lock we can determine safely if the page is beyond EOF. If it is not
  * beyond EOF, then the page is guaranteed safe against truncation until we
  * unlock the page.
@@ -2595,7 +2600,8 @@ out_release:
 	*pagep = NULL;
 
 	if (pos + len > inode->i_size)
-		vmtruncate(inode, inode->i_size);
+		if (!inode->i_op->new_truncate)
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
+			if (!inode->i_op->new_truncate)
+				vmtruncate(inode, isize);
 	}
 
 	if (rw == READ && dio_lock_type == DIO_LOCKING)
Index: linux-2.6/fs/attr.c
===================================================================
--- linux-2.6.orig/fs/attr.c
+++ linux-2.6/fs/attr.c
@@ -112,7 +112,12 @@ int inode_setattr(struct inode * inode,
 
 	if (ia_valid & ATTR_SIZE &&
 	    attr->ia_size != i_size_read(inode)) {
-		int error = vmtruncate(inode, attr->ia_size);
+		int error;
+
+		if (inode->i_op->new_truncate)
+			error = simple_setsize(inode, attr->ia_size);
+		else
+			error = vmtruncate(inode, attr->ia_size);
 		if (error)
 			return error;
 	}
Index: linux-2.6/Documentation/filesystems/vfs.txt
===================================================================
--- linux-2.6.orig/Documentation/filesystems/vfs.txt
+++ linux-2.6/Documentation/filesystems/vfs.txt
@@ -401,11 +401,16 @@ otherwise noted.
   	started might not be in the page cache at the end of the
   	walk).
 
-  truncate: called by the VFS to change the size of a file.  The
+  truncate: Deprecated. This will not be called if ->setsize is defined.
+	Called by the VFS to change the size of a file.  The
  	i_size field of the inode is set to the desired size by the
  	VFS before this method is called.  This method is called by
  	the truncate(2) system call and related functionality.
 
+	Note: ->truncate and vmtruncate are deprecated. Do not add new
+	instances/calls of these. Filesystems shoud be converted to do their
+	truncate sequence via ->setattr().
+
   permission: called by the VFS to check for access rights on a POSIX-like
   	filesystem.
 
Index: linux-2.6/mm/truncate.c
===================================================================
--- linux-2.6.orig/mm/truncate.c
+++ linux-2.6/mm/truncate.c
@@ -513,12 +513,10 @@ int vmtruncate(struct inode * inode, lof
 	loff_t oldsize;
 	int error;
 
-	error = inode_newsize_ok(inode, offset);
+	error = simple_setsize(inode, offset);
 	if (error)
 		return error;
-	oldsize = inode->i_size;
-	i_size_write(inode, offset);
-	truncate_pagecache(inode, oldsize, offset);
+
 	if (inode->i_op->truncate)
 		inode->i_op->truncate(inode);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
