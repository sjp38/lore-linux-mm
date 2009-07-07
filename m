Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D45136B004F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 10:43:16 -0400 (EDT)
Date: Tue, 7 Jul 2009 16:44:23 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch 1/4] fs: new truncate helpers
Message-ID: <20090707144423.GC2714@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Introduce new truncate helpers truncate_pagecache and inode_newsize_ok.
vmtruncate is also consolidated from mm/memory.c and mm/nommu.c and
into mm/truncate.c.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 Documentation/vm/locking |    2 -
 fs/attr.c                |   45 +++++++++++++++++++++++++++++++++-
 include/linux/fs.h       |    1 
 include/linux/mm.h       |    1 
 mm/filemap.c             |    2 -
 mm/memory.c              |   62 ++---------------------------------------------
 mm/mremap.c              |    4 +--
 mm/nommu.c               |   40 ------------------------------
 mm/truncate.c            |   61 ++++++++++++++++++++++++++++++++++++++++++++++
 9 files changed, 114 insertions(+), 104 deletions(-)

Index: linux-2.6/fs/attr.c
===================================================================
--- linux-2.6.orig/fs/attr.c
+++ linux-2.6/fs/attr.c
@@ -60,9 +60,52 @@ fine:
 error:
 	return retval;
 }
-
 EXPORT_SYMBOL(inode_change_ok);
 
+/**
+ * inode_newsize_ok - may this inode be truncated to a given size
+ * @inode:	the inode to be truncated
+ * @offset:	the new size to assign to the inode
+ * @Returns:	0 on success, -ve errno on failure
+ *
+ * Description:
+ *    inode_newsize_ok will check filesystem limits and ulimits to
+ *    check that the new inode size is within limits. inode_newsize_ok
+ *    will also send SIGXFSZ when necessary. Caller must not proceed
+ *    with inode size change if failure is returned. @inode must be
+ *    a file (not directory), with appropriate permissions to allow
+ *    truncate (inode_newsize_ok does NOT check these conditions).
+ *
+ *    inode_newsize_ok must be called with i_mutex held.
+ */
+int inode_newsize_ok(struct inode *inode, loff_t offset)
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
+EXPORT_SYMBOL(inode_newsize_ok);
+
 int inode_setattr(struct inode * inode, struct iattr * attr)
 {
 	unsigned int ia_valid = attr->ia_valid;
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h
+++ linux-2.6/include/linux/fs.h
@@ -2367,6 +2367,7 @@ extern int buffer_migrate_page(struct ad
 #endif
 
 extern int inode_change_ok(struct inode *, struct iattr *);
+extern int inode_newsize_ok(struct inode *, loff_t offset);
 extern int __must_check inode_setattr(struct inode *, struct iattr *);
 
 extern void file_update_time(struct file *file);
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -805,6 +805,7 @@ static inline void unmap_shared_mapping_
 	unmap_mapping_range(mapping, holebegin, holelen, 0);
 }
 
+extern void truncate_pagecache(struct inode * inode, loff_t old, loff_t new);
 extern int vmtruncate(struct inode * inode, loff_t offset);
 extern int vmtruncate_range(struct inode * inode, loff_t offset, loff_t end);
 
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
@@ -465,3 +465,64 @@ int invalidate_inode_pages2(struct addre
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
+	if (new < old) {
+		struct address_space *mapping = inode->i_mapping;
+
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
+	error = inode_newsize_ok(inode, offset);
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
