Message-Id: <20080304225227.915245373@redhat.com>
References: <20080304225157.573336066@redhat.com>
Date: Tue, 04 Mar 2008 17:52:15 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [patch 18/20] handle mlocked pages during map/unmap and truncate
Content-Disposition: inline; filename=noreclaim-04.2-move-mlocked-pages-off-the-LRU.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

V2 -> V3:
+ rebase to 23-mm1 atop RvR's split lru series [no changes]

V1 -> V2:
+  modified mmap.c:mmap_region() to return error if mlock_vma_pages_range()
   does.  This can only occur if the vma gets removed/changed while
   we're switching mmap_sem lock modes.   Most callers don't care, but
   sys_remap_file_pages() appears to.

Rework of Nick Piggins's "mm: move mlocked pages off the LRU" patch
-- part 2 0f 2.

Remove mlocked pages from the LRU using "NoReclaim infrastructure"
during mmap()/mremap().  Try to move back to normal LRU lists on
munmap() when last locked mapping removed.  Removed PageMlocked()
status when page truncated from file.


Originally Signed-off-by: Nick Piggin <npiggin@suse.de>
Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by:  Rik van Riel <riel@redhat.com>

Index: linux-2.6.25-rc3-mm1/mm/mmap.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/mmap.c	2008-03-04 17:38:18.000000000 -0500
+++ linux-2.6.25-rc3-mm1/mm/mmap.c	2008-03-04 17:38:20.000000000 -0500
@@ -32,6 +32,8 @@
 #include <asm/tlb.h>
 #include <asm/mmu_context.h>
 
+#include "internal.h"
+
 #ifndef arch_mmap_check
 #define arch_mmap_check(addr, len, flags)	(0)
 #endif
@@ -1208,9 +1210,13 @@ out:
 	vm_stat_account(mm, vm_flags, file, len >> PAGE_SHIFT);
 	if (vm_flags & VM_LOCKED) {
 		mm->locked_vm += len >> PAGE_SHIFT;
-		make_pages_present(addr, addr + len);
-	}
-	if ((flags & MAP_POPULATE) && !(flags & MAP_NONBLOCK))
+		/*
+		 * makes pages present; downgrades, drops, requires mmap_sem
+		 */
+		error = mlock_vma_pages_range(vma, addr, addr + len);
+		if (error)
+			return error;	/* vma gone! */
+	} else if ((flags & MAP_POPULATE) && !(flags & MAP_NONBLOCK))
 		make_pages_present(addr, addr + len);
 	return addr;
 
@@ -1896,6 +1902,18 @@ int do_munmap(struct mm_struct *mm, unsi
 	vma = prev? prev->vm_next: mm->mmap;
 
 	/*
+	 * unlock any mlock()ed ranges before detaching vmas
+	 */
+	if (mm->locked_vm) {
+		struct vm_area_struct *tmp = vma;
+		while (tmp && tmp->vm_start < end) {
+			if (tmp->vm_flags & VM_LOCKED)
+				munlock_vma_pages_all(tmp);
+			tmp = tmp->vm_next;
+		}
+	}
+
+	/*
 	 * Remove the vma's, and unmap the actual pages
 	 */
 	detach_vmas_to_be_unmapped(mm, vma, prev, end);
@@ -2032,7 +2050,7 @@ out:
 	mm->total_vm += len >> PAGE_SHIFT;
 	if (flags & VM_LOCKED) {
 		mm->locked_vm += len >> PAGE_SHIFT;
-		make_pages_present(addr, addr + len);
+		mlock_vma_pages_range(vma, addr, addr + len);
 	}
 	return addr;
 }
@@ -2043,13 +2061,25 @@ EXPORT_SYMBOL(do_brk);
 void exit_mmap(struct mm_struct *mm)
 {
 	struct mmu_gather *tlb;
-	struct vm_area_struct *vma = mm->mmap;
+	struct vm_area_struct *vma;
 	unsigned long nr_accounted = 0;
 	unsigned long end;
 
 	/* mm's last user has gone, and its about to be pulled down */
 	arch_exit_mmap(mm);
 
+	if (mm->locked_vm) {
+		vma = mm->mmap;
+		while (vma) {
+			if (vma->vm_flags & VM_LOCKED)
+				munlock_vma_pages_all(vma);
+			vma = vma->vm_next;
+		}
+	}
+
+	vma = mm->mmap;
+
+
 	lru_add_drain();
 	flush_cache_mm(mm);
 	tlb = tlb_gather_mmu(mm, 1);
Index: linux-2.6.25-rc3-mm1/mm/mremap.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/mremap.c	2008-03-04 17:37:24.000000000 -0500
+++ linux-2.6.25-rc3-mm1/mm/mremap.c	2008-03-04 17:38:20.000000000 -0500
@@ -23,6 +23,8 @@
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 
+#include "internal.h"
+
 static pmd_t *get_old_pmd(struct mm_struct *mm, unsigned long addr)
 {
 	pgd_t *pgd;
@@ -232,8 +234,8 @@ static unsigned long move_vma(struct vm_
 	if (vm_flags & VM_LOCKED) {
 		mm->locked_vm += new_len >> PAGE_SHIFT;
 		if (new_len > old_len)
-			make_pages_present(new_addr + old_len,
-					   new_addr + new_len);
+			mlock_vma_pages_range(vma, new_addr + old_len,
+						   new_addr + new_len);
 	}
 
 	return new_addr;
@@ -373,7 +375,7 @@ unsigned long do_mremap(unsigned long ad
 			vm_stat_account(mm, vma->vm_flags, vma->vm_file, pages);
 			if (vma->vm_flags & VM_LOCKED) {
 				mm->locked_vm += pages;
-				make_pages_present(addr + old_len,
+				mlock_vma_pages_range(vma, addr + old_len,
 						   addr + new_len);
 			}
 			ret = addr;
Index: linux-2.6.25-rc3-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/vmscan.c	2008-03-04 17:37:24.000000000 -0500
+++ linux-2.6.25-rc3-mm1/mm/vmscan.c	2008-03-04 17:38:20.000000000 -0500
@@ -540,6 +540,10 @@ static unsigned long shrink_page_list(st
 				goto activate_locked;
 			case SWAP_AGAIN:
 				goto keep_locked;
+			case SWAP_MLOCK:
+				ClearPageActive(page);
+				SetPageNoreclaim(page);
+				goto keep_locked;	/* to noreclaim list */
 			case SWAP_SUCCESS:
 				; /* try to free the page below */
 			}
Index: linux-2.6.25-rc3-mm1/mm/truncate.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/truncate.c	2008-03-04 17:37:24.000000000 -0500
+++ linux-2.6.25-rc3-mm1/mm/truncate.c	2008-03-04 17:38:20.000000000 -0500
@@ -18,6 +18,7 @@
 #include <linux/task_io_accounting_ops.h>
 #include <linux/buffer_head.h>	/* grr. try_to_release_page,
 				   do_invalidatepage */
+#include "internal.h"
 
 
 /**
@@ -105,6 +106,7 @@ truncate_complete_page(struct address_sp
 	cancel_dirty_page(page, page_cache_size(mapping));
 
 	remove_from_page_cache(page);
+	clear_page_mlock(page);
 	ClearPageUptodate(page);
 	ClearPageMappedToDisk(page);
 	page_cache_release(page);	/* pagecache ref */
@@ -129,6 +131,7 @@ invalidate_complete_page(struct address_
 	if (PagePrivate(page) && !try_to_release_page(page, 0))
 		return 0;
 
+	clear_page_mlock(page);
 	ret = remove_mapping(mapping, page);
 
 	return ret;
@@ -355,6 +358,7 @@ invalidate_complete_page2(struct address
 	if (PageDirty(page))
 		goto failed;
 
+	clear_page_mlock(page);
 	BUG_ON(PagePrivate(page));
 	__remove_from_page_cache(page);
 	write_unlock_irq(&mapping->tree_lock);
Index: linux-2.6.25-rc3-mm1/mm/internal.h
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/internal.h	2008-03-04 17:38:18.000000000 -0500
+++ linux-2.6.25-rc3-mm1/mm/internal.h	2008-03-04 17:38:20.000000000 -0500
@@ -65,17 +65,13 @@ extern int mlock_vma_pages_range(struct 
 			unsigned long start, unsigned long end);
 
 /*
- * munlock range of pages.   For munmap() and exit().
+ * munlock range of pages mapped by the vma.   For munmap() and exit().
  * Always called to operate on a full vma that is being unmapped.
  */
-static inline int munlock_vma_pages_range(struct vm_area_struct *vma,
-			unsigned long start, unsigned long end)
+static inline int munlock_vma_pages_all(struct vm_area_struct *vma)
 {
-// TODO:  verify my assumption.  Should we just drop the start/end args?
-	VM_BUG_ON(start != vma->vm_start || end != vma->vm_end);
-
 	vma->vm_flags &= ~VM_LOCKED;
-	return __mlock_vma_pages_range(vma, start, end);
+	return __mlock_vma_pages_range(vma, vma->vm_start, vma->vm_end);
 }
 
 extern void clear_page_mlock(struct page *page);
@@ -89,8 +85,10 @@ static inline void clear_page_mlock(stru
 static inline void mlock_vma_page(struct page *page) { }
 static inline int mlock_vma_pages_range(struct vm_area_struct *vma,
 			unsigned long start, unsigned long end) { return 0; }
-static inline int munlock_vma_pages_range(struct vm_area_struct *vma,
-			unsigned long start, unsigned long end) { return 0; }
+static inline int munlock_vma_pages_all(struct vm_area_struct *vma)
+{
+	return 0;
+}
 
 #endif /* CONFIG_NORECLAIM_MLOCK */
 

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
