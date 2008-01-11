Message-ID: <4787BC89.2010106@redhat.com>
Date: Fri, 11 Jan 2008 13:59:21 -0500
From: Peter Staubach <staubach@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2][RFC][BUG] msync: updating ctime and mtime at syncing
References: <1200006638.19293.42.camel@codedot> <1200012249.20379.2.camel@codedot>
In-Reply-To: <1200012249.20379.2.camel@codedot>
Content-Type: multipart/mixed;
 boundary="------------060409040608030601020204"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Salikhmetov <salikhmetov@gmail.com>
Cc: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, Valdis.Kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, jesper.juhl@gmail.com
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------060409040608030601020204
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Anton Salikhmetov wrote:
> From: Anton Salikhmetov <salikhmetov@gmail.com>
>
> The patch contains changes for updating the ctime and mtime fields for memory mapped files:
>
> 1) adding a new flag triggering update of the inode data;
> 2) implementing a helper function for checking that flag and updating ctime and mtime;
> 3) updating time stamps for mapped files in sys_msync() and do_fsync().

Sorry, one other issue to throw out too -- an mmap'd block device
should also have its inode time fields updated.  This is a little
tricky because the inode referenced via mapping->host isn't the
one that needs to have the time fields updated on.

I have attached the patch that I submitted last.  It is quite out
of date, but does show my attempt to resolve some of these issues.

    Thanx...

       ps

--------------060409040608030601020204
Content-Type: text/plain;
 name="mmap_mctime.devel.v2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mmap_mctime.devel.v2"

--- linux-2.6.20.i686/fs/buffer.c.org
+++ linux-2.6.20.i686/fs/buffer.c
@@ -710,6 +710,7 @@ EXPORT_SYMBOL(mark_buffer_dirty_inode);
 int __set_page_dirty_buffers(struct page *page)
 {
 	struct address_space * const mapping = page_mapping(page);
+	int ret = 0;
 
 	if (unlikely(!mapping))
 		return !TestSetPageDirty(page);
@@ -727,7 +728,7 @@ int __set_page_dirty_buffers(struct page
 	spin_unlock(&mapping->private_lock);
 
 	if (TestSetPageDirty(page))
-		return 0;
+		goto out;
 
 	write_lock_irq(&mapping->tree_lock);
 	if (page->mapping) {	/* Race with truncate? */
@@ -740,7 +741,11 @@ int __set_page_dirty_buffers(struct page
 	}
 	write_unlock_irq(&mapping->tree_lock);
 	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
-	return 1;
+	ret = 1;
+out:
+	if (page_mapped(page))
+		set_bit(AS_MCTIME, &mapping->flags);
+	return ret;
 }
 EXPORT_SYMBOL(__set_page_dirty_buffers);
 
--- linux-2.6.20.i686/fs/fs-writeback.c.org
+++ linux-2.6.20.i686/fs/fs-writeback.c
@@ -167,6 +167,13 @@ __sync_single_inode(struct inode *inode,
 
 	spin_unlock(&inode_lock);
 
+	if (test_and_clear_bit(AS_MCTIME, &mapping->flags)) {
+		if (S_ISBLK(inode->i_mode))
+			bd_inode_update_time(inode);
+		else
+			inode_update_time(inode);
+	}
+
 	ret = do_writepages(mapping, wbc);
 
 	/* Don't write the inode if only I_DIRTY_PAGES was set */
--- linux-2.6.20.i686/fs/inode.c.org
+++ linux-2.6.20.i686/fs/inode.c
@@ -1201,8 +1201,8 @@ void touch_atime(struct vfsmount *mnt, s
 EXPORT_SYMBOL(touch_atime);
 
 /**
- *	file_update_time	-	update mtime and ctime time
- *	@file: file accessed
+ *	inode_update_time	-	update mtime and ctime time
+ *	@inode: file accessed
  *
  *	Update the mtime and ctime members of an inode and mark the inode
  *	for writeback.  Note that this function is meant exclusively for
@@ -1212,9 +1212,8 @@ EXPORT_SYMBOL(touch_atime);
  *	timestamps are handled by the server.
  */
 
-void file_update_time(struct file *file)
+void inode_update_time(struct inode *inode)
 {
-	struct inode *inode = file->f_path.dentry->d_inode;
 	struct timespec now;
 	int sync_it = 0;
 
@@ -1238,7 +1237,7 @@ void file_update_time(struct file *file)
 		mark_inode_dirty_sync(inode);
 }
 
-EXPORT_SYMBOL(file_update_time);
+EXPORT_SYMBOL(inode_update_time);
 
 int inode_needs_sync(struct inode *inode)
 {
--- linux-2.6.20.i686/fs/block_dev.c.org
+++ linux-2.6.20.i686/fs/block_dev.c
@@ -608,6 +608,22 @@ void bdput(struct block_device *bdev)
 
 EXPORT_SYMBOL(bdput);
  
+void bd_inode_update_time(struct inode *inode)
+{
+	struct block_device *bdev = inode->i_bdev;
+	struct list_head *p;
+
+	if (bdev == NULL)
+		return;
+
+	spin_lock(&bdev_lock);
+	list_for_each(p, &bdev->bd_inodes) {
+		inode = list_entry(p, struct inode, i_devices);
+		inode_update_time(inode);
+	}
+	spin_unlock(&bdev_lock);
+}
+
 static struct block_device *bd_acquire(struct inode *inode)
 {
 	struct block_device *bdev;
--- linux-2.6.20.i686/include/linux/fs.h.org
+++ linux-2.6.20.i686/include/linux/fs.h
@@ -1488,6 +1488,7 @@ extern struct block_device *bdget(dev_t)
 extern void bd_set_size(struct block_device *, loff_t size);
 extern void bd_forget(struct inode *inode);
 extern void bdput(struct block_device *);
+extern void bd_inode_update_time(struct inode *);
 extern struct block_device *open_by_devnum(dev_t, unsigned);
 extern const struct address_space_operations def_blk_aops;
 #else
@@ -1892,7 +1893,11 @@ extern int buffer_migrate_page(struct ad
 extern int inode_change_ok(struct inode *, struct iattr *);
 extern int __must_check inode_setattr(struct inode *, struct iattr *);
 
-extern void file_update_time(struct file *file);
+extern void inode_update_time(struct inode *inode);
+static inline void file_update_time(struct file *file)
+{
+	inode_update_time(file->f_path.dentry->d_inode);
+}
 
 static inline ino_t parent_ino(struct dentry *dentry)
 {
--- linux-2.6.20.i686/include/linux/pagemap.h.org
+++ linux-2.6.20.i686/include/linux/pagemap.h
@@ -16,8 +16,9 @@
  * Bits in mapping->flags.  The lower __GFP_BITS_SHIFT bits are the page
  * allocation mode flags.
  */
-#define	AS_EIO		(__GFP_BITS_SHIFT + 0)	/* IO error on async write */
+#define AS_EIO		(__GFP_BITS_SHIFT + 0)	/* IO error on async write */
 #define AS_ENOSPC	(__GFP_BITS_SHIFT + 1)	/* ENOSPC on async write */
+#define AS_MCTIME	(__GFP_BITS_SHIFT + 2)	/* need m/ctime change */
 
 static inline gfp_t mapping_gfp_mask(struct address_space * mapping)
 {
--- linux-2.6.20.i686/mm/page-writeback.c.org
+++ linux-2.6.20.i686/mm/page-writeback.c
@@ -760,8 +760,10 @@ int __set_page_dirty_no_writeback(struct
  */
 int __set_page_dirty_nobuffers(struct page *page)
 {
+	struct address_space *mapping = page_mapping(page);
+	int ret = 0;
+
 	if (!TestSetPageDirty(page)) {
-		struct address_space *mapping = page_mapping(page);
 		struct address_space *mapping2;
 
 		if (!mapping)
@@ -783,9 +785,11 @@ int __set_page_dirty_nobuffers(struct pa
 			/* !PageAnon && !swapper_space */
 			__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 		}
-		return 1;
+		ret = 1;
 	}
-	return 0;
+	if (page_mapped(page))
+		set_bit(AS_MCTIME, &mapping->flags);
+	return ret;
 }
 EXPORT_SYMBOL(__set_page_dirty_nobuffers);
 
--- linux-2.6.20.i686/mm/msync.c.org
+++ linux-2.6.20.i686/mm/msync.c
@@ -12,6 +12,7 @@
 #include <linux/mman.h>
 #include <linux/file.h>
 #include <linux/syscalls.h>
+#include <linux/pagemap.h>
 
 /*
  * MS_SYNC syncs the entire file - including mappings.
@@ -77,11 +78,16 @@ asmlinkage long sys_msync(unsigned long 
 		}
 		file = vma->vm_file;
 		start = vma->vm_end;
-		if ((flags & MS_SYNC) && file &&
-				(vma->vm_flags & VM_SHARED)) {
+		if ((flags & (MS_SYNC|MS_ASYNC)) &&
+		    file && (vma->vm_flags & VM_SHARED)) {
 			get_file(file);
 			up_read(&mm->mmap_sem);
-			error = do_fsync(file, 0);
+			error = 0;
+			if (flags & MS_SYNC)
+				error = do_fsync(file, 0);
+			else if (test_and_clear_bit(AS_MCTIME,
+					       &file->f_mapping->flags))
+				file_update_time(file);
 			fput(file);
 			if (error || start >= end)
 				goto out;

--------------060409040608030601020204--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
