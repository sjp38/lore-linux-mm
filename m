Subject: [patch resend v4] update ctime and mtime for mmaped write
Message-Id: <E1HVZyn-0008T8-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Sun, 25 Mar 2007 23:10:21 +0200
Sender: owner-linux-mm@kvack.org
From: Miklos Szeredi <mszeredi@suse.cz>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Changes:
v4:
 o rename test_clear_page_modified to page_mkclean_noprot
 o clean up page_mkclean_noprot
 o don't set AS_CMTIME from fault handler, since that also sets the PTE dirty
 o only update c/mtime in munmap, if file is not mapped any more
 o cleanups
v3:
 o rename is_page_modified to test_clear_page_modified
v2:
 o set AS_CMTIME flag in clear_page_dirty_for_io() too
 o don't clear AS_CMTIME in file_update_time()
 o check the dirty bit in the page tables
v1:
 o moved check from __fput() to remove_vma(), which is more logical
 o changed set_page_dirty() to set_page_dirty_mapping in hugetlb.c
 o cleaned up #ifdef CONFIG_BLOCK mess

This patch makes writing to shared memory mappings update st_ctime and
st_mtime as defined by SUSv3:

   The st_ctime and st_mtime fields of a file that is mapped with
   MAP_SHARED and PROT_WRITE shall be marked for update at some point
   in the interval between a write reference to the mapped region and
   the next call to msync() with MS_ASYNC or MS_SYNC for that portion
   of the file by any process. If there is no such call and if the
   underlying file is modified as a result of a write reference, then
   these fields shall be marked for update at some time after the
   write reference.

A new address_space flag is introduced: AS_CMTIME.  This is set each
time dirtyness from the page table is transferred to the page or if
the page is dirtied without the page table being set dirty.

Note, the flag is set unconditionally, even if the page is already
dirty.  This is important, because the page might have been dirtied
earlier by a non-mmap write.

Msync checks this flag and also dirty bit in the page tables, because
the data might change again after an msync(MS_ASYNC), while the page
is already dirty and read-write.  This also makes the time updating
work for memory backed filesystems such as tmpfs.

This implementation walks the pages in the synced range, and uses rmap
to find all the ptes for each page.  Non-linear vmas are ignored,
since the ptes can only be found by scanning the whole vma, which is
very inefficient.

As an optimization, if dirty pages are accounted, then only walk the
dirty pages, since the clean pages necessarily have clean ptes.  This
doesn't work for memory backed filesystems, where no dirty accounting
is done.

An alternative implementation could check for all intersecting vmas in
the mapping and walk the page tables for each.  This would probably be
more efficient for memory backed filesystems and if the number of
dirty pages is near the total number of pages in the range.

In munmap if there are no more memory mappings of this file, and the
AS_CMTIME flag has been set, the file times are updated.

Fixes Novell Bugzilla #206431.

Inspired by Peter Staubach's patch and the resulting comments.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---

Index: linux-2.6.21-rc4-mm1/include/linux/pagemap.h
===================================================================
--- linux-2.6.21-rc4-mm1.orig/include/linux/pagemap.h	2007-03-25 19:00:06.000000000 +0200
+++ linux-2.6.21-rc4-mm1/include/linux/pagemap.h	2007-03-25 19:00:35.000000000 +0200
@@ -19,6 +19,7 @@
  */
 #define	AS_EIO		(__GFP_BITS_SHIFT + 0)	/* IO error on async write */
 #define AS_ENOSPC	(__GFP_BITS_SHIFT + 1)	/* ENOSPC on async write */
+#define AS_CMTIME	(__GFP_BITS_SHIFT + 2)	/* ctime/mtime update needed */
 
 static inline void mapping_set_error(struct address_space *mapping, int error)
 {
Index: linux-2.6.21-rc4-mm1/include/linux/mm.h
===================================================================
--- linux-2.6.21-rc4-mm1.orig/include/linux/mm.h	2007-03-25 19:00:06.000000000 +0200
+++ linux-2.6.21-rc4-mm1/include/linux/mm.h	2007-03-25 19:00:36.000000000 +0200
@@ -808,6 +808,7 @@ int redirty_page_for_writepage(struct wr
 				struct page *page);
 int FASTCALL(set_page_dirty(struct page *page));
 int set_page_dirty_lock(struct page *page);
+int set_page_dirty_mapping(struct page *page);
 int clear_page_dirty_for_io(struct page *page);
 
 extern unsigned long do_mremap(unsigned long addr,
Index: linux-2.6.21-rc4-mm1/mm/memory.c
===================================================================
--- linux-2.6.21-rc4-mm1.orig/mm/memory.c	2007-03-25 19:00:06.000000000 +0200
+++ linux-2.6.21-rc4-mm1/mm/memory.c	2007-03-25 19:00:36.000000000 +0200
@@ -676,7 +676,7 @@ static unsigned long zap_pte_range(struc
 				anon_rss--;
 			else {
 				if (pte_dirty(ptent))
-					set_page_dirty(page);
+					set_page_dirty_mapping(page);
 				if (pte_young(ptent))
 					SetPageReferenced(page);
 				file_rss--;
@@ -954,7 +954,7 @@ struct page *follow_page(struct vm_area_
 	if (flags & FOLL_TOUCH) {
 		if ((flags & FOLL_WRITE) &&
 		    !pte_dirty(pte) && !PageDirty(page))
-			set_page_dirty(page);
+			set_page_dirty_mapping(page);
 		mark_page_accessed(page);
 	}
 unlock:
Index: linux-2.6.21-rc4-mm1/mm/page-writeback.c
===================================================================
--- linux-2.6.21-rc4-mm1.orig/mm/page-writeback.c	2007-03-25 19:00:06.000000000 +0200
+++ linux-2.6.21-rc4-mm1/mm/page-writeback.c	2007-03-25 19:00:36.000000000 +0200
@@ -848,17 +848,42 @@ EXPORT_SYMBOL(redirty_page_for_writepage
  * If the mapping doesn't provide a set_page_dirty a_op, then
  * just fall through and assume that it wants buffer_heads.
  */
+static inline int __set_page_dirty(struct address_space *mapping,
+				   struct page *page)
+{
+	int (*spd)(struct page *) = mapping->a_ops->set_page_dirty;
+#ifdef CONFIG_BLOCK
+	if (!spd)
+		spd = __set_page_dirty_buffers;
+#endif
+	return (*spd)(page);
+}
+
 int fastcall set_page_dirty(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
 
+	if (likely(mapping))
+		return __set_page_dirty(mapping, page);
+	if (!PageDirty(page)) {
+		if (!TestSetPageDirty(page))
+			return 1;
+	}
+	return 0;
+}
+EXPORT_SYMBOL(set_page_dirty);
+
+/*
+ * Special set_page_dirty() variant for dirtiness coming from a memory
+ * mapping.  In this case the ctime/mtime update flag needs to be set.
+ */
+int set_page_dirty_mapping(struct page *page)
+{
+	struct address_space *mapping = page_mapping(page);
+
 	if (likely(mapping)) {
-		int (*spd)(struct page *) = mapping->a_ops->set_page_dirty;
-#ifdef CONFIG_BLOCK
-		if (!spd)
-			spd = __set_page_dirty_buffers;
-#endif
-		return (*spd)(page);
+		set_bit(AS_CMTIME, &mapping->flags);
+		return __set_page_dirty(mapping, page);
 	}
 	if (!PageDirty(page)) {
 		if (!TestSetPageDirty(page))
@@ -866,7 +891,6 @@ int fastcall set_page_dirty(struct page 
 	}
 	return 0;
 }
-EXPORT_SYMBOL(set_page_dirty);
 
 /*
  * set_page_dirty() is racy if the caller has no reference against
@@ -936,7 +960,7 @@ int clear_page_dirty_for_io(struct page 
 		 * threads doing their things.
 		 */
 		if (page_mkclean(page))
-			set_page_dirty(page);
+			set_page_dirty_mapping(page);
 		/*
 		 * We carefully synchronise fault handlers against
 		 * installing a dirty pte and marking the page dirty
Index: linux-2.6.21-rc4-mm1/mm/rmap.c
===================================================================
--- linux-2.6.21-rc4-mm1.orig/mm/rmap.c	2007-03-25 19:00:06.000000000 +0200
+++ linux-2.6.21-rc4-mm1/mm/rmap.c	2007-03-25 21:38:18.000000000 +0200
@@ -506,6 +506,49 @@ int page_mkclean(struct page *page)
 }
 EXPORT_SYMBOL_GPL(page_mkclean);
 
+static int page_mkclean_one_noprot(struct page *page,
+				   struct vm_area_struct *vma)
+{
+	int modified = 0;
+	unsigned long address = vma_address(page, vma);
+	if (address != -EFAULT) {
+		struct mm_struct *mm = vma->vm_mm;
+		spinlock_t *ptl;
+		pte_t *pte = page_check_address(page, mm, address, &ptl);
+		if (pte) {
+			if (ptep_clear_flush_dirty(vma, address, pte))
+				modified = 1;
+			pte_unmap_unlock(pte, ptl);
+		}
+	}
+	return modified;
+}
+
+/**
+ * page_mkclean_noprot - check and clear the dirty bit for all mappings of a page
+ * @page:	the page to check
+ */
+int page_mkclean_noprot(struct page *page)
+{
+	struct address_space *mapping = page->mapping;
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	struct vm_area_struct *vma;
+	struct prio_tree_iter iter;
+	int modified = 0;
+
+	BUG_ON(!page_mapped(page));
+
+	spin_lock(&mapping->i_mmap_lock);
+	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+		if (vma->vm_flags & VM_SHARED)
+			modified |= page_mkclean_one_noprot(page, vma);
+	}
+	spin_unlock(&mapping->i_mmap_lock);
+	if (page_test_and_clear_dirty(page))
+		modified = 1;
+	return modified;
+}
+
 /**
  * page_set_anon_rmap - setup new anonymous rmap
  * @page:	the page to add the mapping to
@@ -657,7 +700,7 @@ void page_remove_rmap(struct page *page,
 		 * faster for those pages still in swapcache.
 		 */
 		if (page_test_and_clear_dirty(page))
-			set_page_dirty(page);
+			set_page_dirty_mapping(page);
 		__dec_zone_page_state(page,
 				PageAnon(page) ? NR_ANON_PAGES : NR_FILE_MAPPED);
 	}
@@ -702,7 +745,7 @@ static int try_to_unmap_one(struct page 
 
 	/* Move the dirty bit to the physical page now the pte is gone. */
 	if (pte_dirty(pteval))
-		set_page_dirty(page);
+		set_page_dirty_mapping(page);
 
 	/* Update high watermark before we lower rss */
 	update_hiwater_rss(mm);
@@ -836,7 +879,7 @@ static void try_to_unmap_cluster(unsigne
 
 		/* Move the dirty bit to the physical page now the pte is gone. */
 		if (pte_dirty(pteval))
-			set_page_dirty(page);
+			set_page_dirty_mapping(page);
 
 		page_remove_rmap(page, vma);
 		page_cache_release(page);
Index: linux-2.6.21-rc4-mm1/mm/mmap.c
===================================================================
--- linux-2.6.21-rc4-mm1.orig/mm/mmap.c	2007-03-25 19:00:06.000000000 +0200
+++ linux-2.6.21-rc4-mm1/mm/mmap.c	2007-03-25 19:00:36.000000000 +0200
@@ -222,12 +222,30 @@ void unlink_file_vma(struct vm_area_stru
 static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
 {
 	struct vm_area_struct *next = vma->vm_next;
+	struct file *file = vma->vm_file;
 
 	might_sleep();
 	if (vma->vm_ops && vma->vm_ops->close)
 		vma->vm_ops->close(vma);
-	if (vma->vm_file)
-		fput(vma->vm_file);
+	if (file) {
+		struct address_space *mapping = file->f_mapping;
+		int update_cmtime = 0;
+		/*
+		 * Only update c/mtime if there are no more memory maps
+		 * referring to this inode.  Otherwise it would be possible,
+		 * that some modification info remains in page tables of
+		 * other mappings, and the times would be updated again,
+		 * even though the file wasn't modified after this
+		 */
+		spin_lock(&mapping->i_mmap_lock);
+		if (prio_tree_empty(&mapping->i_mmap) &&
+		    test_and_clear_bit(AS_CMTIME, &file->f_mapping->flags))
+			update_cmtime = 1;
+		spin_unlock(&mapping->i_mmap_lock);
+		if (update_cmtime)
+			file_update_time(file);
+		fput(file);
+	}
 	mpol_free(vma_policy(vma));
 	kmem_cache_free(vm_area_cachep, vma);
 	return next;
Index: linux-2.6.21-rc4-mm1/mm/hugetlb.c
===================================================================
--- linux-2.6.21-rc4-mm1.orig/mm/hugetlb.c	2007-03-25 19:00:06.000000000 +0200
+++ linux-2.6.21-rc4-mm1/mm/hugetlb.c	2007-03-25 19:00:36.000000000 +0200
@@ -407,7 +407,7 @@ void __unmap_hugepage_range(struct vm_ar
 
 		page = pte_page(pte);
 		if (pte_dirty(pte))
-			set_page_dirty(page);
+			set_page_dirty_mapping(page);
 		list_add(&page->lru, &page_list);
 	}
 	spin_unlock(&mm->page_table_lock);
Index: linux-2.6.21-rc4-mm1/mm/msync.c
===================================================================
--- linux-2.6.21-rc4-mm1.orig/mm/msync.c	2007-03-25 19:00:06.000000000 +0200
+++ linux-2.6.21-rc4-mm1/mm/msync.c	2007-03-25 19:00:36.000000000 +0200
@@ -12,6 +12,81 @@
 #include <linux/mman.h>
 #include <linux/file.h>
 #include <linux/syscalls.h>
+#include <linux/pagemap.h>
+#include <linux/rmap.h>
+#include <linux/pagevec.h>
+
+/*
+ * Update ctime/mtime on msync().
+ *
+ * POSIX requires, that the times are updated between a modification
+ * of the file through a memory mapping and the next msync for a
+ * region containing the modification.  The wording implies that this
+ * must be done even if the modification was through a different
+ * address space.  Ugh.
+ *
+ * Non-linear vmas are too hard to handle and they are non-standard
+ * anyway, so they are ignored for now.
+ *
+ * The "file modified" info is collected from two places:
+ *
+ *  - AS_CMTIME flag of the mapping
+ *  - the dirty bit of the ptes
+ *
+ * For memory backed filesystems all the pages in the range need to be
+ * examined.  In other cases, since dirty pages are accurately
+ * tracked, it is enough to look at the pages with the dirty tag.
+ */
+static void msync_update_file_time(struct vm_area_struct *vma,
+				   unsigned long start, unsigned long end)
+{
+	struct address_space *mapping;
+	struct pagevec pvec;
+	pgoff_t index;
+	pgoff_t end_index;
+
+	if (!vma->vm_file || !(vma->vm_flags & VM_SHARED) ||
+	    (vma->vm_flags & VM_NONLINEAR))
+		return;
+
+	mapping = vma->vm_file->f_mapping;
+	pagevec_init(&pvec, 0);
+	index = linear_page_index(vma, start);
+	end_index = linear_page_index(vma, end);
+	while (index < end_index) {
+		int i;
+		int nr_pages = min(end_index - index, (pgoff_t) PAGEVEC_SIZE);
+
+		if (mapping_cap_account_dirty(mapping))
+			nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
+					PAGECACHE_TAG_DIRTY, nr_pages);
+		else
+			nr_pages = pagevec_lookup(&pvec, mapping, index,
+						  nr_pages);
+		if (!nr_pages)
+			break;
+
+		for (i = 0; i < nr_pages; i++) {
+			struct page *page = pvec.pages[i];
+
+			/* Skip pages which are just being read */
+			if (!PageUptodate(page))
+				continue;
+
+			lock_page(page);
+			index = page->index + 1;
+			if (page->mapping == mapping &&
+			    page_mkclean_noprot(page))
+				set_page_dirty_mapping(page);
+
+			unlock_page(page);
+		}
+		pagevec_release(&pvec);
+	}
+
+	if (test_and_clear_bit(AS_CMTIME, &mapping->flags))
+		file_update_time(vma->vm_file);
+}
 
 /*
  * MS_SYNC syncs the entire file - including mappings.
@@ -75,6 +150,9 @@ asmlinkage long sys_msync(unsigned long 
 			error = -EBUSY;
 			goto out_unlock;
 		}
+		if (flags & (MS_SYNC | MS_ASYNC))
+			msync_update_file_time(vma, start,
+					       min(end, vma->vm_end));
 		file = vma->vm_file;
 		start = vma->vm_end;
 		if ((flags & MS_SYNC) && file &&
Index: linux-2.6.21-rc4-mm1/include/linux/rmap.h
===================================================================
--- linux-2.6.21-rc4-mm1.orig/include/linux/rmap.h	2007-03-25 19:00:06.000000000 +0200
+++ linux-2.6.21-rc4-mm1/include/linux/rmap.h	2007-03-25 19:00:36.000000000 +0200
@@ -100,6 +100,11 @@ unsigned long page_address_in_vma(struct
  */
 int page_mkclean(struct page *);
 
+/*
+ * Similar to the above, but doesn't write protect the PTEs
+ */
+int page_mkclean_noprot(struct page *page);
+
 #else	/* !CONFIG_MMU */
 
 #define anon_vma_init()		do {} while (0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
