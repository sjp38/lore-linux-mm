Message-Id: <20080606202859.647025648@redhat.com>
References: <20080606202838.390050172@redhat.com>
Date: Fri, 06 Jun 2008 16:28:57 -0400
From: Rik van Riel <riel@redhat.com>
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm 19/25] Handle mlocked pages during map, remap, unmap
Content-Disposition: inline; filename=rvr-19-lts-noreclaim-cull-non-reclaimable-anon-pages-in-fault-path.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

Originally
From: Nick Piggin <npiggin@suse.de>

Against:  2.6.26-rc2-mm1

Remove mlocked pages from the LRU using "NoReclaim infrastructure"
during mmap(), munmap(), mremap() and truncate().  Try to move back
to normal LRU lists on munmap() when last mlocked mapping removed.
Removed PageMlocked() status when page truncated from file.

Originally Signed-off-by: Nick Piggin <npiggin@suse.de>
Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---

V6:
+ munlock page in range of VM_LOCKED vma being covered by
  remap_file_pages(), as this is an implied unmap of the
  range.
+ in support of special vma filtering, don't account for
  non-mlockable vmas as locked_vm. 

V2 -> V3:
+ rebase to 23-mm1 atop RvR's split lru series [no changes]

V1 -> V2:
+  modified mmap.c:mmap_region() to return error if mlock_vma_pages_range()
   does.  This can only occur if the vma gets removed/changed while
   we're switching mmap_sem lock modes.   Most callers don't care, but
   sys_remap_file_pages() appears to.

Rework of Nick Piggins's "mm: move mlocked pages off the LRU" patch
-- part 2 0f 2.

 mm/fremap.c   |   26 +++++++++++++++++---
 mm/internal.h |   13 ++++++++--
 mm/mlock.c    |   10 ++++---
 mm/mmap.c     |   75 ++++++++++++++++++++++++++++++++++++++++++++--------------
 mm/mremap.c   |    8 +++---
 mm/truncate.c |    4 +++
 6 files changed, 106 insertions(+), 30 deletions(-)

Index: linux-2.6.26-rc2-mm1/mm/mmap.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/mmap.c	2008-06-06 16:06:28.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/mmap.c	2008-06-06 16:06:35.000000000 -0400
@@ -32,6 +32,8 @@
 #include <asm/tlb.h>
 #include <asm/mmu_context.h>
 
+#include "internal.h"
+
 #ifndef arch_mmap_check
 #define arch_mmap_check(addr, len, flags)	(0)
 #endif
@@ -961,6 +963,7 @@ unsigned long do_mmap_pgoff(struct file 
 			return -EPERM;
 		vm_flags |= VM_LOCKED;
 	}
+
 	/* mlock MCL_FUTURE? */
 	if (vm_flags & VM_LOCKED) {
 		unsigned long locked, lock_limit;
@@ -1121,10 +1124,12 @@ munmap_back:
 	 * The VM_SHARED test is necessary because shmem_zero_setup
 	 * will create the file object for a shared anonymous map below.
 	 */
-	if (!file && !(vm_flags & VM_SHARED) &&
-	    vma_merge(mm, prev, addr, addr + len, vm_flags,
-					NULL, NULL, pgoff, NULL))
-		goto out;
+	if (!file && !(vm_flags & VM_SHARED)) {
+		vma = vma_merge(mm, prev, addr, addr + len, vm_flags,
+					NULL, NULL, pgoff, NULL);
+		if (vma)
+			goto out;
+	}
 
 	/*
 	 * Determine the object being mapped and call the appropriate
@@ -1206,10 +1211,14 @@ out:
 	mm->total_vm += len >> PAGE_SHIFT;
 	vm_stat_account(mm, vm_flags, file, len >> PAGE_SHIFT);
 	if (vm_flags & VM_LOCKED) {
-		mm->locked_vm += len >> PAGE_SHIFT;
-		make_pages_present(addr, addr + len);
-	}
-	if ((flags & MAP_POPULATE) && !(flags & MAP_NONBLOCK))
+		/*
+		 * makes pages present; downgrades, drops, reacquires mmap_sem
+		 */
+		int nr_pages = mlock_vma_pages_range(vma, addr, addr + len);
+		if (nr_pages < 0)
+			return nr_pages;	/* vma gone! */
+		mm->locked_vm += (len >> PAGE_SHIFT) - nr_pages;
+	} else if ((flags & MAP_POPULATE) && !(flags & MAP_NONBLOCK))
 		make_pages_present(addr, addr + len);
 	return addr;
 
@@ -1682,8 +1691,11 @@ find_extend_vma(struct mm_struct *mm, un
 		return vma;
 	if (!prev || expand_stack(prev, addr))
 		return NULL;
-	if (prev->vm_flags & VM_LOCKED)
-		make_pages_present(addr, prev->vm_end);
+	if (prev->vm_flags & VM_LOCKED) {
+		int nr_pages = mlock_vma_pages_range(prev, addr, prev->vm_end);
+		if (nr_pages < 0)
+			return NULL;	/* vma gone! */
+	}
 	return prev;
 }
 #else
@@ -1709,8 +1721,11 @@ find_extend_vma(struct mm_struct * mm, u
 	start = vma->vm_start;
 	if (expand_stack(vma, addr))
 		return NULL;
-	if (vma->vm_flags & VM_LOCKED)
-		make_pages_present(addr, start);
+	if (vma->vm_flags & VM_LOCKED) {
+		int nr_pages = mlock_vma_pages_range(vma, addr, start);
+		if (nr_pages < 0)
+			return NULL;	/* vma gone! */
+	}
 	return vma;
 }
 #endif
@@ -1895,6 +1910,18 @@ int do_munmap(struct mm_struct *mm, unsi
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
@@ -2006,8 +2033,9 @@ unsigned long do_brk(unsigned long addr,
 		return -ENOMEM;
 
 	/* Can we just expand an old private anonymous mapping? */
-	if (vma_merge(mm, prev, addr, addr + len, flags,
-					NULL, NULL, pgoff, NULL))
+	vma = vma_merge(mm, prev, addr, addr + len, flags,
+					NULL, NULL, pgoff, NULL);
+	if (vma)
 		goto out;
 
 	/*
@@ -2029,8 +2057,9 @@ unsigned long do_brk(unsigned long addr,
 out:
 	mm->total_vm += len >> PAGE_SHIFT;
 	if (flags & VM_LOCKED) {
-		mm->locked_vm += len >> PAGE_SHIFT;
-		make_pages_present(addr, addr + len);
+		int nr_pages = mlock_vma_pages_range(vma, addr, addr + len);
+		if (nr_pages >= 0)
+			mm->locked_vm += (len >> PAGE_SHIFT) - nr_pages;
 	}
 	return addr;
 }
@@ -2041,13 +2070,25 @@ EXPORT_SYMBOL(do_brk);
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
Index: linux-2.6.26-rc2-mm1/mm/mremap.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/mremap.c	2008-05-15 11:20:24.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/mremap.c	2008-06-06 16:06:35.000000000 -0400
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
+			mlock_vma_pages_range(new_vma, new_addr + old_len,
+						       new_addr + new_len);
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
Index: linux-2.6.26-rc2-mm1/mm/truncate.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/truncate.c	2008-05-15 11:20:57.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/truncate.c	2008-06-06 16:06:35.000000000 -0400
@@ -18,6 +18,7 @@
 #include <linux/task_io_accounting_ops.h>
 #include <linux/buffer_head.h>	/* grr. try_to_release_page,
 				   do_invalidatepage */
+#include "internal.h"
 
 
 /**
@@ -104,6 +105,7 @@ truncate_complete_page(struct address_sp
 	cancel_dirty_page(page, PAGE_CACHE_SIZE);
 
 	remove_from_page_cache(page);
+	clear_page_mlock(page);
 	ClearPageUptodate(page);
 	ClearPageMappedToDisk(page);
 	page_cache_release(page);	/* pagecache ref */
@@ -128,6 +130,7 @@ invalidate_complete_page(struct address_
 	if (PagePrivate(page) && !try_to_release_page(page, 0))
 		return 0;
 
+	clear_page_mlock(page);
 	ret = remove_mapping(mapping, page);
 
 	return ret;
@@ -353,6 +356,7 @@ invalidate_complete_page2(struct address
 	if (PageDirty(page))
 		goto failed;
 
+	clear_page_mlock(page);
 	BUG_ON(PagePrivate(page));
 	__remove_from_page_cache(page);
 	write_unlock_irq(&mapping->tree_lock);
Index: linux-2.6.26-rc2-mm1/mm/mlock.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/mlock.c	2008-06-06 16:06:32.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/mlock.c	2008-06-06 16:06:35.000000000 -0400
@@ -270,7 +270,8 @@ static void __munlock_vma_pages_range(st
 	struct munlock_page_walk mpw;
 
 	VM_BUG_ON(start & ~PAGE_MASK || end & ~PAGE_MASK);
-	VM_BUG_ON(!rwsem_is_locked(&vma->vm_mm->mmap_sem));
+	VM_BUG_ON((!rwsem_is_locked(&vma->vm_mm->mmap_sem)) &&
+		  (atomic_read(&mm->mm_users) != 0));
 	VM_BUG_ON(start < vma->vm_start);
 	VM_BUG_ON(end > vma->vm_end);
 
@@ -354,12 +355,13 @@ no_mlock:
 
 
 /*
- * munlock all pages in vma.   For munmap() and exit().
+ * munlock all pages in the vma range.   For mremap(), munmap() and exit().
  */
-void munlock_vma_pages_all(struct vm_area_struct *vma)
+void munlock_vma_pages_range(struct vm_area_struct *vma,
+			   unsigned long start, unsigned long end)
 {
 	vma->vm_flags &= ~VM_LOCKED;
-	__munlock_vma_pages_range(vma, vma->vm_start, vma->vm_end);
+	__munlock_vma_pages_range(vma, start, end);
 }
 
 /*
Index: linux-2.6.26-rc2-mm1/mm/fremap.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/fremap.c	2008-05-15 11:20:43.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/fremap.c	2008-06-06 16:06:35.000000000 -0400
@@ -20,6 +20,8 @@
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 
+#include "internal.h"
+
 static void zap_pte(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long addr, pte_t *ptep)
 {
@@ -214,13 +216,29 @@ asmlinkage long sys_remap_file_pages(uns
 		spin_unlock(&mapping->i_mmap_lock);
 	}
 
+	if (vma->vm_flags & VM_LOCKED) {
+		/*
+		 * drop PG_Mlocked flag for over-mapped range
+		 */
+		unsigned int saved_flags = vma->vm_flags;
+		munlock_vma_pages_range(vma, start, start + size);
+		vma->vm_flags = saved_flags;
+	}
+
 	err = populate_range(mm, vma, start, size, pgoff);
 	if (!err && !(flags & MAP_NONBLOCK)) {
-		if (unlikely(has_write_lock)) {
-			downgrade_write(&mm->mmap_sem);
-			has_write_lock = 0;
+		if (vma->vm_flags & VM_LOCKED) {
+			/*
+			 * might be mapping previously unmapped range of file
+			 */
+			mlock_vma_pages_range(vma, start, start + size);
+		} else {
+			if (unlikely(has_write_lock)) {
+				downgrade_write(&mm->mmap_sem);
+				has_write_lock = 0;
+			}
+			make_pages_present(start, start+size);
 		}
-		make_pages_present(start, start+size);
 	}
 
 	/*
Index: linux-2.6.26-rc2-mm1/mm/internal.h
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/internal.h	2008-06-06 16:06:28.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/internal.h	2008-06-06 16:06:35.000000000 -0400
@@ -63,9 +63,18 @@ extern int mlock_vma_pages_range(struct 
 			unsigned long start, unsigned long end);
 
 /*
- * munlock all pages in vma.   For munmap() and exit().
+ * munlock all pages in vma range.   For mremap().
  */
-extern void munlock_vma_pages_all(struct vm_area_struct *vma);
+extern void munlock_vma_pages_range(struct vm_area_struct *vma,
+			       unsigned long start, unsigned long end);
+
+/*
+ * munlock all pages in vma.   For munmap and exit().
+ */
+static inline void munlock_vma_pages_all(struct vm_area_struct *vma)
+{
+	munlock_vma_pages_range(vma, vma->vm_start, vma->vm_end);
+}
 
 #ifdef CONFIG_NORECLAIM_LRU
 /*

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
