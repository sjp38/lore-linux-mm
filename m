Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B5A9E6B004F
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 12:16:48 -0400 (EDT)
Date: Mon, 6 Jul 2009 18:54:38 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch 1/3] fs: new truncate sequence
Message-ID: <20090706165438.GQ2714@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Here is a next iteration of the truncate change. 1st patch introduces
all the mechanism. 2nd patch makes use of some new helper functions
but otherwise is uninteresting.  Last patch converts a couple of filesystems
just to see how it looks (more complete conversion may actually try to check
and handle errors when truncating blocks in the fs, but that's outside the
scope of this series).

I am also working on removing page lock requirement from extending i_size
during write(2) syscall as we discussed which could allow solution for
partial-page page_mkwrite problems. I've got some code here but it's got
some remaining fsx failure I'm tracking down... Anyway I think the truncate
reorganisation should be a good change regardless (I need it for fsblock
too).

--

Introduce a new truncate calling sequence into fs/mm subsystems.  Rather than
setattr > vmtruncate > truncate, add a new inode operation ->ftruncate, called
from inode_setattr when called with ATTR_SIZE.  The filesystem will be
responsible for updating i_size and truncating pagecache.

Generic code which previously called vmtruncate (in order to truncate blocks
that may have been instantiated past i_size) no longer calls vmtruncate in the
case that the inode has an ->ftruncate attribute. In that case it is the
responsibility of the caller to trim off blocks appropriately in case of
error.

New helper functions, inode_truncate_ok and truncate_pagecache are broken out
of vmtruncate, allowing the filesystem more flexibility in ordering of
operations. simple_ftruncate is implemented for filesystems which have no
need for a ->truncate operation under the old scheme.

Big problem with the previous calling sequence: the filesystem is not called
until i_size has already changed.  This means it is not allowed to fail the
call, and also it does not know what the previous i_size was. Also, generic
code calling vmtruncate to truncate allocated blocks in case of error had
no good way to return a meaningful error (or, for example, atomically handle
block deallocation).

---
 Documentation/filesystems/Locking |    7 +--
 Documentation/vm/locking          |    2 -
 fs/attr.c                         |   55 ++++++++++++++++++++++++---
 fs/buffer.c                       |    9 +++-
 fs/direct-io.c                    |    6 +--
 fs/libfs.c                        |   18 +++++++++
 include/linux/fs.h                |    4 ++
 include/linux/mm.h                |    2 +
 mm/filemap.c                      |    2 -
 mm/memory.c                       |   62 +------------------------------
 mm/mremap.c                       |    4 +-
 mm/nommu.c                        |   40 --------------------
 mm/truncate.c                     |   76 ++++++++++++++++++++++++++++++++++++++
 13 files changed, 168 insertions(+), 119 deletions(-)

Index: linux-2.6/fs/attr.c
===================================================================
--- linux-2.6.orig/fs/attr.c
+++ linux-2.6/fs/attr.c
@@ -60,18 +60,61 @@ fine:
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
+			if (inode->i_op->ftruncate) {
+				struct file *filp = NULL;
+				int open = 0;
+
+				if (ia_valid & ATTR_FILE)
+					filp = attr->ia_file;
+				if (ia_valid & ATTR_OPEN)
+					open = 1;
+				error = inode->i_op->ftruncate(filp, open,
+							inode, offset);
+			} else
+				error = vmtruncate(inode, offset);
+			if (error)
+				return error;
+		}
 	}
 
 	if (ia_valid & ATTR_UID)
Index: linux-2.6/fs/libfs.c
===================================================================
--- linux-2.6.orig/fs/libfs.c
+++ linux-2.6/fs/libfs.c
@@ -329,6 +329,23 @@ int simple_rename(struct inode *old_dir,
 	return 0;
 }
 
+int simple_ftruncate(struct file *file, int open,
+			struct inode *inode, loff_t offset)
+{
+	loff_t oldsize;
+	int error;
+
+	error = inode_truncate_ok(inode, offset);
+	if (error)
+		return error;
+
+	oldsize = inode->i_size;
+	i_size_write(inode, offset);
+	truncate_pagecache(inode, oldsize, offset);
+
+	return error;
+}
+
 int simple_readpage(struct file *file, struct page *page)
 {
 	clear_highpage(page);
@@ -840,6 +857,7 @@ EXPORT_SYMBOL(generic_read_dir);
 EXPORT_SYMBOL(get_sb_pseudo);
 EXPORT_SYMBOL(simple_write_begin);
 EXPORT_SYMBOL(simple_write_end);
+EXPORT_SYMBOL(simple_ftruncate);
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
+	int (*ftruncate) (struct file *, int, struct inode *, loff_t);
 	int (*permission) (struct inode *, int);
 	int (*setattr) (struct dentry *, struct iattr *);
 	int (*getattr) (struct vfsmount *mnt, struct dentry *, struct kstat *);
@@ -2332,6 +2333,8 @@ extern int simple_link(struct dentry *,
 extern int simple_unlink(struct inode *, struct dentry *);
 extern int simple_rmdir(struct inode *, struct dentry *);
 extern int simple_rename(struct inode *, struct dentry *, struct inode *, struct dentry *);
+extern int simple_ftruncate(struct file *file, int open,
+			struct inode *inode, loff_t offset);
 extern int simple_sync_file(struct file *, struct dentry *, int);
 extern int simple_empty(struct dentry *);
 extern int simple_readpage(struct file *file, struct page *page);
@@ -2367,6 +2370,7 @@ extern int buffer_migrate_page(struct ad
 #endif
 
 extern int inode_change_ok(struct inode *, struct iattr *);
+extern int inode_truncate_ok(struct inode *, loff_t offset);
 extern int __must_check inode_setattr(struct inode *, struct iattr *);
 
 extern void file_update_time(struct file *file);
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -805,7 +805,9 @@ static inline void unmap_shared_mapping_
 	unmap_mapping_range(mapping, holebegin, holelen, 0);
 }
 
+extern void truncate_pagecache(struct inode * inode, loff_t old, loff_t new);
 extern int vmtruncate(struct inode * inode, loff_t offset);
+extern int truncate_blocks(struct inode *inode, loff_t offset);
 extern int vmtruncate_range(struct inode * inode, loff_t offset, loff_t end);
 
 #ifdef CONFIG_MMU
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -282,7 +282,8 @@ void free_pgtables(struct mmu_gather *tl
 		unsigned long addr = vma->vm_start;
 
 		/*
-		 * Hide vma from rmap and vmtruncate before freeing pgtables
+		 * Hide vma from rmap and truncate_pagecache before freeing
+		 * pgtables
 		 */
 		anon_vma_unlink(vma);
 		unlink_file_vma(vma);
@@ -2358,7 +2359,7 @@ restart:
  * @mapping: the address space containing mmaps to be unmapped.
  * @holebegin: byte in first page to unmap, relative to the start of
  * the underlying file.  This will be rounded down to a PAGE_SIZE
- * boundary.  Note that this is different from vmtruncate(), which
+ * boundary.  Note that this is different from truncate_pagecache(), which
  * must keep the partial page.  In contrast, we must get rid of
  * partial pages.
  * @holelen: size of prospective hole in bytes.  This will be rounded
@@ -2409,63 +2410,6 @@ void unmap_mapping_range(struct address_
 }
 EXPORT_SYMBOL(unmap_mapping_range);
 
-/**
- * vmtruncate - unmap mappings "freed" by truncate() syscall
- * @inode: inode of the file used
- * @offset: file offset to start truncating
- *
- * NOTE! We have to be ready to update the memory sharing
- * between the file and the memory map for a potential last
- * incomplete page.  Ugly, but necessary.
- */
-int vmtruncate(struct inode * inode, loff_t offset)
-{
-	if (inode->i_size < offset) {
-		unsigned long limit;
-
-		limit = current->signal->rlim[RLIMIT_FSIZE].rlim_cur;
-		if (limit != RLIM_INFINITY && offset > limit)
-			goto out_sig;
-		if (offset > inode->i_sb->s_maxbytes)
-			goto out_big;
-		i_size_write(inode, offset);
-	} else {
-		struct address_space *mapping = inode->i_mapping;
-
-		/*
-		 * truncation of in-use swapfiles is disallowed - it would
-		 * cause subsequent swapout to scribble on the now-freed
-		 * blocks.
-		 */
-		if (IS_SWAPFILE(inode))
-			return -ETXTBSY;
-		i_size_write(inode, offset);
-
-		/*
-		 * unmap_mapping_range is called twice, first simply for
-		 * efficiency so that truncate_inode_pages does fewer
-		 * single-page unmaps.  However after this first call, and
-		 * before truncate_inode_pages finishes, it is possible for
-		 * private pages to be COWed, which remain after
-		 * truncate_inode_pages finishes, hence the second
-		 * unmap_mapping_range call must be made for correctness.
-		 */
-		unmap_mapping_range(mapping, offset + PAGE_SIZE - 1, 0, 1);
-		truncate_inode_pages(mapping, offset);
-		unmap_mapping_range(mapping, offset + PAGE_SIZE - 1, 0, 1);
-	}
-
-	if (inode->i_op->truncate)
-		inode->i_op->truncate(inode);
-	return 0;
-
-out_sig:
-	send_sig(SIGXFSZ, current, 0);
-out_big:
-	return -EFBIG;
-}
-EXPORT_SYMBOL(vmtruncate);
-
 int vmtruncate_range(struct inode *inode, loff_t offset, loff_t end)
 {
 	struct address_space *mapping = inode->i_mapping;
Index: linux-2.6/Documentation/filesystems/Locking
===================================================================
--- linux-2.6.orig/Documentation/filesystems/Locking
+++ linux-2.6/Documentation/filesystems/Locking
@@ -78,10 +78,9 @@ removexattr:	yes
 victim.
 	cross-directory ->rename() has (per-superblock) ->s_vfs_rename_sem.
 	->truncate() is never called directly - it's a callback, not a
-method. It's called by vmtruncate() - library function normally used by
-->setattr(). Locking information above applies to that call (i.e. is
-inherited from ->setattr() - vmtruncate() is used when ATTR_SIZE had been
-passed).
+method. It's called by the default inode_setattr() library function normally
+used by ->setattr() when ATTR_SIZE has been passed. Locking information above
+applies to that call (i.e. is inherited from ->setattr()).
 
 See Documentation/filesystems/directory-locking for more detailed discussion
 of the locking scheme for directory operations.
Index: linux-2.6/mm/nommu.c
===================================================================
--- linux-2.6.orig/mm/nommu.c
+++ linux-2.6/mm/nommu.c
@@ -86,46 +86,6 @@ struct vm_operations_struct generic_file
 };
 
 /*
- * Handle all mappings that got truncated by a "truncate()"
- * system call.
- *
- * NOTE! We have to be ready to update the memory sharing
- * between the file and the memory map for a potential last
- * incomplete page.  Ugly, but necessary.
- */
-int vmtruncate(struct inode *inode, loff_t offset)
-{
-	struct address_space *mapping = inode->i_mapping;
-	unsigned long limit;
-
-	if (inode->i_size < offset)
-		goto do_expand;
-	i_size_write(inode, offset);
-
-	truncate_inode_pages(mapping, offset);
-	goto out_truncate;
-
-do_expand:
-	limit = current->signal->rlim[RLIMIT_FSIZE].rlim_cur;
-	if (limit != RLIM_INFINITY && offset > limit)
-		goto out_sig;
-	if (offset > inode->i_sb->s_maxbytes)
-		goto out;
-	i_size_write(inode, offset);
-
-out_truncate:
-	if (inode->i_op->truncate)
-		inode->i_op->truncate(inode);
-	return 0;
-out_sig:
-	send_sig(SIGXFSZ, current, 0);
-out:
-	return -EFBIG;
-}
-
-EXPORT_SYMBOL(vmtruncate);
-
-/*
  * Return the total memory allocated for this pointer, not
  * just what the caller asked for.
  *
Index: linux-2.6/Documentation/vm/locking
===================================================================
--- linux-2.6.orig/Documentation/vm/locking
+++ linux-2.6/Documentation/vm/locking
@@ -80,7 +80,7 @@ Note: PTL can also be used to guarantee
 mm start up ... this is a loose form of stability on mm_users. For
 example, it is used in copy_mm to protect against a racing tlb_gather_mmu
 single address space optimization, so that the zap_page_range (from
-vmtruncate) does not lose sending ipi's to cloned threads that might 
+truncate) does not lose sending ipi's to cloned threads that might
 be spawned underneath it and go to user mode to drag in pte's into tlbs.
 
 swap_lock
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -59,7 +59,7 @@
 /*
  * Lock ordering:
  *
- *  ->i_mmap_lock		(vmtruncate)
+ *  ->i_mmap_lock		(truncate_pagecache)
  *    ->private_lock		(__free_pte->__set_page_dirty_buffers)
  *      ->swap_lock		(exclusive_swap_page, others)
  *        ->mapping->tree_lock
Index: linux-2.6/mm/mremap.c
===================================================================
--- linux-2.6.orig/mm/mremap.c
+++ linux-2.6/mm/mremap.c
@@ -85,8 +85,8 @@ static void move_ptes(struct vm_area_str
 	if (vma->vm_file) {
 		/*
 		 * Subtle point from Rajesh Venkatasubramanian: before
-		 * moving file-based ptes, we must lock vmtruncate out,
-		 * since it might clean the dst vma before the src vma,
+		 * moving file-based ptes, we must lock truncate_pagecache
+		 * out, since it might clean the dst vma before the src vma,
 		 * and we propagate stale pages into the dst afterward.
 		 */
 		mapping = vma->vm_file->f_mapping;
Index: linux-2.6/mm/truncate.c
===================================================================
--- linux-2.6.orig/mm/truncate.c
+++ linux-2.6/mm/truncate.c
@@ -465,3 +465,79 @@ int invalidate_inode_pages2(struct addre
 	return invalidate_inode_pages2_range(mapping, 0, -1);
 }
 EXPORT_SYMBOL_GPL(invalidate_inode_pages2);
+
+/**
+ * truncate_pagecache - unmap mappings "freed" by truncate() syscall
+ * @inode: inode
+ * @old: old file offset
+ * @new: new file offset
+ *
+ * inode's new i_size must already be written before truncate_pagecache
+ * is called.
+ */
+void truncate_pagecache(struct inode * inode, loff_t old, loff_t new)
+{
+	VM_BUG_ON(inode->i_size != new);
+
+	if (new < old) {
+		struct address_space *mapping = inode->i_mapping;
+
+#ifdef CONFIG_MMU
+		/*
+		 * unmap_mapping_range is called twice, first simply for
+		 * efficiency so that truncate_inode_pages does fewer
+		 * single-page unmaps.  However after this first call, and
+		 * before truncate_inode_pages finishes, it is possible for
+		 * private pages to be COWed, which remain after
+		 * truncate_inode_pages finishes, hence the second
+		 * unmap_mapping_range call must be made for correctness.
+		 */
+		unmap_mapping_range(mapping, new + PAGE_SIZE - 1, 0, 1);
+		truncate_inode_pages(mapping, new);
+		unmap_mapping_range(mapping, new + PAGE_SIZE - 1, 0, 1);
+#else
+		truncate_inode_pages(mapping, new);
+#endif
+	}
+}
+EXPORT_SYMBOL(truncate_pagecache);
+
+/**
+ * vmtruncate - unmap mappings "freed" by truncate() syscall
+ * @inode: inode of the file used
+ * @offset: file offset to start truncating
+ *
+ * NOTE! We have to be ready to update the memory sharing
+ * between the file and the memory map for a potential last
+ * incomplete page.  Ugly, but necessary.
+ *
+ * This function is deprecated and truncate_pagecache should be
+ * used instead.
+ */
+int vmtruncate(struct inode * inode, loff_t offset)
+{
+	loff_t oldsize;
+	int error;
+
+	error = inode_truncate_ok(inode, offset);
+	if (error)
+		return error;
+	oldsize = inode->i_size;
+	i_size_write(inode, offset);
+	truncate_pagecache(inode, oldsize, offset);
+
+	if (inode->i_op->truncate)
+		inode->i_op->truncate(inode);
+
+	return error;
+}
+EXPORT_SYMBOL(vmtruncate);
+
+int truncate_blocks(struct inode *inode, loff_t offset)
+{
+	if (inode->i_op->ftruncate) /* these guys handle it themselves */
+		return 0;
+
+	return vmtruncate(inode, offset);
+}
+EXPORT_SYMBOL(truncate_blocks);
Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -1992,9 +1992,12 @@ int block_write_begin(struct file *file,
 			 * prepare_write() may have instantiated a few blocks
 			 * outside i_size.  Trim these off again. Don't need
 			 * i_size_read because we hold i_mutex.
+			 *
+			 * Filesystems which define ->ftruncate must handle
+			 * this themselves.
 			 */
 			if (pos + len > inode->i_size)
-				vmtruncate(inode, inode->i_size);
+				truncate_blocks(inode, inode->i_size);
 		}
 	}
 
@@ -2377,7 +2380,7 @@ int block_commit_write(struct page *page
  *
  * We are not allowed to take the i_mutex here so we have to play games to
  * protect against truncate races as the page could now be beyond EOF.  Because
- * vmtruncate() writes the inode size before removing pages, once we have the
+ * truncate writes the inode size before removing pages, once we have the
  * page lock we can determine safely if the page is beyond EOF. If it is not
  * beyond EOF, then the page is guaranteed safe against truncation until we
  * unlock the page.
@@ -2601,7 +2604,7 @@ out_release:
 	*pagep = NULL;
 
 	if (pos + len > inode->i_size)
-		vmtruncate(inode, inode->i_size);
+		truncate_blocks(inode, inode->i_size);
 
 	return ret;
 }
Index: linux-2.6/fs/direct-io.c
===================================================================
--- linux-2.6.orig/fs/direct-io.c
+++ linux-2.6/fs/direct-io.c
@@ -1210,14 +1210,14 @@ __blockdev_direct_IO(int rw, struct kioc
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
+			truncate_blocks(inode, isize);
 	}
 
 	if (rw == READ && dio_lock_type == DIO_LOCKING)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
