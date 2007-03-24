In-reply-to: <E1HVEOB-0006fX-00@dorka.pomaz.szeredi.hu> (message from Miklos
	Szeredi on Sat, 24 Mar 2007 23:07:07 +0100)
Subject: [patch 3/3] update ctime and mtime for mmaped write
References: <E1HVEOB-0006fX-00@dorka.pomaz.szeredi.hu>
Message-Id: <E1HVERx-0006gx-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Sat, 24 Mar 2007 23:11:01 +0100
Sender: owner-linux-mm@kvack.org
From: Miklos Szeredi <mszeredi@suse.cz>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Changes:
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
time a page is dirtied through a userspace memory mapping.  This
includes write accesses via get_user_pages().

Note, the flag is set unconditionally, even if the page is already
dirty.  This is important, because the page might have been dirtied
earlier by a non-mmap write.

This flag is checked in msync() and munmap()/mremap(), and if set, the
file times are updated and the flag is cleared.

Msync also needs to check the dirty bit in the page tables, because
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

Fixes Novell Bugzilla #206431.

Inspired by Peter Staubach's patch and the resulting comments.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---

Index: linux-2.6.21-rc4-mm1/include/linux/pagemap.h
===================================================================
--- linux-2.6.21-rc4-mm1.orig/include/linux/pagemap.h	2007-03-24 19:03:11.000000000 +0100
+++ linux-2.6.21-rc4-mm1/include/linux/pagemap.h	2007-03-24 19:34:30.000000000 +0100
@@ -19,6 +19,7 @@
  */
 #define	AS_EIO		(__GFP_BITS_SHIFT + 0)	/* IO error on async write */
 #define AS_ENOSPC	(__GFP_BITS_SHIFT + 1)	/* ENOSPC on async write */
+#define AS_CMTIME	(__GFP_BITS_SHIFT + 2)	/* ctime/mtime update needed */
 
 static inline void mapping_set_error(struct address_space *mapping, int error)
 {
Index: linux-2.6.21-rc4-mm1/include/linux/mm.h
===================================================================
--- linux-2.6.21-rc4-mm1.orig/include/linux/mm.h	2007-03-24 19:04:15.000000000 +0100
+++ linux-2.6.21-rc4-mm1/include/linux/mm.h	2007-03-24 19:34:30.000000000 +0100
@@ -808,6 +808,7 @@ int redirty_page_for_writepage(struct wr
 				struct page *page);
 int FASTCALL(set_page_dirty(struct page *page));
 int set_page_dirty_lock(struct page *page);
+int set_page_dirty_mapping(struct page *page);
 int clear_page_dirty_for_io(struct page *page);
 
 extern unsigned long do_mremap(unsigned long addr,
Index: linux-2.6.21-rc4-mm1/mm/memory.c
===================================================================
--- linux-2.6.21-rc4-mm1.orig/mm/memory.c	2007-03-24 19:03:11.000000000 +0100
+++ linux-2.6.21-rc4-mm1/mm/memory.c	2007-03-24 19:34:30.000000000 +0100
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
@@ -1519,6 +1519,15 @@ static inline void cow_user_page(struct 
 	copy_user_highpage(dst, src, va, vma);
 }
 
+static void set_page_dirty_mapping_balance(struct page *page)
+{
+	if (set_page_dirty_mapping(page)) {
+		struct address_space *mapping = page_mapping(page);
+		if (mapping)
+			balance_dirty_pages_ratelimited(mapping);
+	}
+}
+
 /*
  * This routine handles present pages, when users try to write
  * to a shared page. It is done by copying the page to a new address
@@ -1678,7 +1687,7 @@ unlock:
 		 * do_no_page is protected similarly.
 		 */
 		wait_on_page_locked(dirty_page);
-		set_page_dirty_balance(dirty_page);
+		set_page_dirty_mapping_balance(dirty_page);
 		put_page(dirty_page);
 	}
 	return ret;
@@ -2328,7 +2337,7 @@ out:
 	if (anon)
 		page_cache_release(faulted_page);
 	else if (dirty_page) {
-		set_page_dirty_balance(dirty_page);
+		set_page_dirty_mapping_balance(dirty_page);
 		put_page(dirty_page);
 	}
 
Index: linux-2.6.21-rc4-mm1/mm/page-writeback.c
===================================================================
--- linux-2.6.21-rc4-mm1.orig/mm/page-writeback.c	2007-03-24 19:27:26.000000000 +0100
+++ linux-2.6.21-rc4-mm1/mm/page-writeback.c	2007-03-24 19:34:30.000000000 +0100
@@ -290,16 +290,6 @@ static void balance_dirty_pages(struct a
 		pdflush_operation(background_writeout, 0);
 }
 
-void set_page_dirty_balance(struct page *page)
-{
-	if (set_page_dirty(page)) {
-		struct address_space *mapping = page_mapping(page);
-
-		if (mapping)
-			balance_dirty_pages_ratelimited(mapping);
-	}
-}
-
 /**
  * balance_dirty_pages_ratelimited_nr - balance dirty memory state
  * @mapping: address_space which was dirtied
@@ -848,17 +838,42 @@ EXPORT_SYMBOL(redirty_page_for_writepage
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
@@ -866,7 +881,6 @@ int fastcall set_page_dirty(struct page 
 	}
 	return 0;
 }
-EXPORT_SYMBOL(set_page_dirty);
 
 /*
  * set_page_dirty() is racy if the caller has no reference against
@@ -936,7 +950,7 @@ int clear_page_dirty_for_io(struct page 
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
--- linux-2.6.21-rc4-mm1.orig/mm/rmap.c	2007-03-24 19:03:11.000000000 +0100
+++ linux-2.6.21-rc4-mm1/mm/rmap.c	2007-03-24 19:34:30.000000000 +0100
@@ -507,6 +507,43 @@ int page_mkclean(struct page *page)
 EXPORT_SYMBOL_GPL(page_mkclean);
 
 /**
+ * test_clear_page_modified - check and clear the dirty bit for all mappings of a page
+ * @page:	the page to check
+ */
+bool test_clear_page_modified(struct page *page)
+{
+	struct address_space *mapping = page->mapping;
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	struct vm_area_struct *vma;
+	struct prio_tree_iter iter;
+	bool modified = false;
+
+	BUG_ON(!mapping);
+	BUG_ON(!page_mapped(page));
+
+	spin_lock(&mapping->i_mmap_lock);
+	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+		if (vma->vm_flags & VM_SHARED) {
+			struct mm_struct *mm = vma->vm_mm;
+			unsigned long addr = vma_address(page, vma);
+			pte_t *pte;
+			spinlock_t *ptl;
+
+			if (addr != -EFAULT &&
+			    (pte = page_check_address(page, mm, addr, &ptl))) {
+				if (ptep_clear_flush_dirty(vma, addr, pte))
+					modified = true;
+				pte_unmap_unlock(pte, ptl);
+			}
+		}
+	}
+	spin_unlock(&mapping->i_mmap_lock);
+	if (page_test_and_clear_dirty(page))
+		modified = true;
+	return modified;
+}
+
+/**
  * page_set_anon_rmap - setup new anonymous rmap
  * @page:	the page to add the mapping to
  * @vma:	the vm area in which the mapping is added
@@ -657,7 +694,7 @@ void page_remove_rmap(struct page *page,
 		 * faster for those pages still in swapcache.
 		 */
 		if (page_test_and_clear_dirty(page))
-			set_page_dirty(page);
+			set_page_dirty_mapping(page);
 		__dec_zone_page_state(page,
 				PageAnon(page) ? NR_ANON_PAGES : NR_FILE_MAPPED);
 	}
@@ -702,7 +739,7 @@ static int try_to_unmap_one(struct page 
 
 	/* Move the dirty bit to the physical page now the pte is gone. */
 	if (pte_dirty(pteval))
-		set_page_dirty(page);
+		set_page_dirty_mapping(page);
 
 	/* Update high watermark before we lower rss */
 	update_hiwater_rss(mm);
@@ -836,7 +873,7 @@ static void try_to_unmap_cluster(unsigne
 
 		/* Move the dirty bit to the physical page now the pte is gone. */
 		if (pte_dirty(pteval))
-			set_page_dirty(page);
+			set_page_dirty_mapping(page);
 
 		page_remove_rmap(page, vma);
 		page_cache_release(page);
Index: linux-2.6.21-rc4-mm1/include/linux/writeback.h
===================================================================
--- linux-2.6.21-rc4-mm1.orig/include/linux/writeback.h	2007-03-24 19:27:26.000000000 +0100
+++ linux-2.6.21-rc4-mm1/include/linux/writeback.h	2007-03-24 19:34:30.000000000 +0100
@@ -129,7 +129,6 @@ int sync_page_range(struct inode *inode,
 			loff_t pos, loff_t count);
 int sync_page_range_nolock(struct inode *inode, struct address_space *mapping,
 			   loff_t pos, loff_t count);
-void set_page_dirty_balance(struct page *page);
 void writeback_set_ratelimit(void);
 
 /* pdflush.c */
Index: linux-2.6.21-rc4-mm1/mm/mmap.c
===================================================================
--- linux-2.6.21-rc4-mm1.orig/mm/mmap.c	2007-03-24 19:04:15.000000000 +0100
+++ linux-2.6.21-rc4-mm1/mm/mmap.c	2007-03-24 19:34:30.000000000 +0100
@@ -222,12 +222,16 @@ void unlink_file_vma(struct vm_area_stru
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
+		if (test_and_clear_bit(AS_CMTIME, &file->f_mapping->flags))
+			file_update_time(file);
+		fput(file);
+	}
 	mpol_free(vma_policy(vma));
 	kmem_cache_free(vm_area_cachep, vma);
 	return next;
Index: linux-2.6.21-rc4-mm1/mm/hugetlb.c
===================================================================
--- linux-2.6.21-rc4-mm1.orig/mm/hugetlb.c	2007-03-24 19:03:11.000000000 +0100
+++ linux-2.6.21-rc4-mm1/mm/hugetlb.c	2007-03-24 19:34:30.000000000 +0100
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
--- linux-2.6.21-rc4-mm1.orig/mm/msync.c	2007-02-04 19:44:54.000000000 +0100
+++ linux-2.6.21-rc4-mm1/mm/msync.c	2007-03-24 19:34:30.000000000 +0100
@@ -12,6 +12,85 @@
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
+	bool modified;
+
+	if (!vma->vm_file || !(vma->vm_flags & VM_SHARED) ||
+	    (vma->vm_flags & VM_NONLINEAR))
+		return;
+
+	mapping = vma->vm_file->f_mapping;
+	modified = test_and_clear_bit(AS_CMTIME, &mapping->flags);
+
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
+			    test_clear_page_modified(page)) {
+				set_page_dirty(page);
+				modified = true;
+			}
+			unlock_page(page);
+		}
+		pagevec_release(&pvec);
+	}
+
+	if (modified)
+		file_update_time(vma->vm_file);
+}
 
 /*
  * MS_SYNC syncs the entire file - including mappings.
@@ -75,6 +154,9 @@ asmlinkage long sys_msync(unsigned long 
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
--- linux-2.6.21-rc4-mm1.orig/include/linux/rmap.h	2007-03-24 19:03:11.000000000 +0100
+++ linux-2.6.21-rc4-mm1/include/linux/rmap.h	2007-03-24 19:34:30.000000000 +0100
@@ -100,6 +100,8 @@ unsigned long page_address_in_vma(struct
  */
 int page_mkclean(struct page *);
 
+bool test_clear_page_modified(struct page *page);
+
 #else	/* !CONFIG_MMU */
 
 #define anon_vma_init()		do {} while (0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
