From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:46:27 +1100
Message-Id: <20070113024627.29682.59430.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 9/29] Clean up page fault handlers
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH 09
 * Finish abstracting implementation dependendent code from
 page fault handler functions
 * Abstract page migration function to call lookup page table
 from the page table interface.
 * Align migration_entry_wait prototype in swapops.h with
 page table interface. 

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 include/linux/swapops.h |    6 ++--
 mm/memory.c             |   70 +++++++++++++++++++++++-------------------------
 mm/migrate.c            |   12 ++++----
 3 files changed, 44 insertions(+), 44 deletions(-)
Index: linux-2.6.20-rc3/mm/memory.c
===================================================================
--- linux-2.6.20-rc3.orig/mm/memory.c	2007-01-04 20:49:40.550922000 +1100
+++ linux-2.6.20-rc3/mm/memory.c	2007-01-04 20:49:46.340026000 +1100
@@ -1345,22 +1345,17 @@
  * (but do_wp_page is only called after already making such a check;
  * and do_anonymous_page and do_no_page can safely check later on).
  */
-static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
+static inline int pte_unmap_same(struct mm_struct *mm, pt_path_t pt_path,
 				pte_t *page_table, pte_t orig_pte)
 {
 	int same = 1;
 #if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
-	if (sizeof(pte_t) > sizeof(unsigned long)) {
-		spinlock_t *ptl = pte_lockptr(mm, pmd);
-		spin_lock(ptl);
-		same = pte_same(*page_table, orig_pte);
-		spin_unlock(ptl);
-	}
+	if (sizeof(pte_t) > sizeof(unsigned long))
+		same = atomic_pte_same(mm, page_table, orig_pte, pt_path);
 #endif
 	pte_unmap(page_table);
 	return same;
 }
-
 /*
  * Do pte_mkwrite, but only if the vma says VM_WRITE.  We do this when
  * servicing faults for write access.  In the normal case, do always want
@@ -1421,8 +1416,8 @@
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
 static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		spinlock_t *ptl, pte_t orig_pte)
+		unsigned long address, pte_t *page_table, pt_path_t pt_path,
+		pte_t orig_pte)
 {
 	struct page *old_page, *new_page;
 	pte_t entry;
@@ -1459,7 +1454,8 @@
 			 * sleep if it needs to.
 			 */
 			page_cache_get(old_page);
-			pte_unmap_unlock(page_table, ptl);
+			unlock_pte(mm, pt_path);
+			pte_unmap(page_table);
 
 			if (vma->vm_ops->page_mkwrite(vma, old_page) < 0)
 				goto unwritable_page;
@@ -1472,8 +1468,7 @@
 			 * they did, we just return, as we can count on the
 			 * MMU to tell us if they didn't also make it writable.
 			 */
-			page_table = pte_offset_map_lock(mm, pmd, address,
-							 &ptl);
+			page_table = lookup_page_table_lock(mm, pt_path, address);
 			if (!pte_same(*page_table, orig_pte))
 				goto unlock;
 		}
@@ -1498,7 +1493,8 @@
 	 */
 	page_cache_get(old_page);
 gotten:
-	pte_unmap_unlock(page_table, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(page_table);
 
 	if (unlikely(anon_vma_prepare(vma)))
 		goto oom;
@@ -1516,7 +1512,8 @@
 	/*
 	 * Re-check the pte - we dropped the lock
 	 */
-	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	page_table = lookup_page_table_lock(mm, pt_path, address);
+
 	if (likely(pte_same(*page_table, orig_pte))) {
 		if (old_page) {
 			page_remove_rmap(old_page, vma);
@@ -1551,7 +1548,8 @@
 	if (old_page)
 		page_cache_release(old_page);
 unlock:
-	pte_unmap_unlock(page_table, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(page_table);
 	if (dirty_page) {
 		set_page_dirty_balance(dirty_page);
 		put_page(dirty_page);
@@ -1913,21 +1911,20 @@
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
 static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
+		unsigned long address, pte_t *page_table, pt_path_t pt_path,
 		int write_access, pte_t orig_pte)
 {
-	spinlock_t *ptl;
 	struct page *page;
 	swp_entry_t entry;
 	pte_t pte;
 	int ret = VM_FAULT_MINOR;
 
-	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
+	if (!pte_unmap_same(mm, pt_path, page_table, orig_pte))
 		goto out;
 
 	entry = pte_to_swp_entry(orig_pte);
 	if (is_migration_entry(entry)) {
-		migration_entry_wait(mm, pmd, address);
+		migration_entry_wait(mm, pt_path, address);
 		goto out;
 	}
 	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
@@ -1941,7 +1938,7 @@
 			 * Back out if somebody else faulted in this pte
 			 * while we released the pte lock.
 			 */
-			page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+			page_table = lookup_page_table_lock(mm, pt_path, address);
 			if (likely(pte_same(*page_table, orig_pte)))
 				ret = VM_FAULT_OOM;
 			delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
@@ -1960,7 +1957,8 @@
 	/*
 	 * Back out if somebody else already faulted in this pte.
 	 */
-	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	page_table = lookup_page_table_lock(mm, pt_path, address);
+
 	if (unlikely(!pte_same(*page_table, orig_pte)))
 		goto out_nomap;
 
@@ -1989,7 +1987,7 @@
 
 	if (write_access) {
 		if (do_wp_page(mm, vma, address,
-				page_table, pmd, ptl, pte) == VM_FAULT_OOM)
+				page_table, pt_path, pte) == VM_FAULT_OOM)
 			ret = VM_FAULT_OOM;
 		goto out;
 	}
@@ -1998,11 +1996,13 @@
 	update_mmu_cache(vma, address, pte);
 	lazy_mmu_prot_update(pte);
 unlock:
-	pte_unmap_unlock(page_table, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(page_table);
 out:
 	return ret;
 out_nomap:
-	pte_unmap_unlock(page_table, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(page_table);
 	unlock_page(page);
 	page_cache_release(page);
 	return ret;
@@ -2276,13 +2276,13 @@
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
 static int do_file_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
+		unsigned long address, pte_t *page_table, pt_path_t pt_path,
 		int write_access, pte_t orig_pte)
 {
 	pgoff_t pgoff;
 	int err;
 
-	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
+	if (!pte_unmap_same(mm, pt_path, page_table, orig_pte))
 		return VM_FAULT_MINOR;
 
 	if (unlikely(!(vma->vm_flags & VM_NONLINEAR))) {
@@ -2323,9 +2323,6 @@
 {
 	pte_t entry;
 	pte_t old_entry;
-	spinlock_t *ptl;
-
-	pmd_t *pmd = pt_path.pmd;
 
 	old_entry = entry = *pte;
 	if (!pte_present(entry)) {
@@ -2344,19 +2341,19 @@
 		}
 		if (pte_file(entry))
 			return do_file_page(mm, vma, address,
-					pte, pmd, write_access, entry);
+					pte, pt_path, write_access, entry);
 		return do_swap_page(mm, vma, address,
-					pte, pmd, write_access, entry);
+					pte, pt_path, write_access, entry);
 	}
 
-	ptl = pte_lockptr(mm, pmd);
-	spin_lock(ptl);
+	lock_pte(mm, pt_path);
+
 	if (unlikely(!pte_same(*pte, entry)))
 		goto unlock;
 	if (write_access) {
 		if (!pte_write(entry))
 			return do_wp_page(mm, vma, address,
-					pte, pmd, ptl, entry);
+					pte, pt_path, entry);
 		entry = pte_mkdirty(entry);
 	}
 	entry = pte_mkyoung(entry);
@@ -2375,7 +2372,8 @@
 			flush_tlb_page(vma, address);
 	}
 unlock:
-	pte_unmap_unlock(pte, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(pte);
 	return VM_FAULT_MINOR;
 }
 
Index: linux-2.6.20-rc3/include/linux/swapops.h
===================================================================
--- linux-2.6.20-rc3.orig/include/linux/swapops.h	2007-01-01 11:53:20.000000000 +1100
+++ linux-2.6.20-rc3/include/linux/swapops.h	2007-01-04 20:49:46.344024000 +1100
@@ -68,6 +68,8 @@
 	return __swp_entry_to_pte(arch_entry);
 }
 
+#include <linux/pt.h>
+
 #ifdef CONFIG_MIGRATION
 static inline swp_entry_t make_migration_entry(struct page *page, int write)
 {
@@ -103,7 +105,7 @@
 	*entry = swp_entry(SWP_MIGRATION_READ, swp_offset(*entry));
 }
 
-extern void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
+extern void migration_entry_wait(struct mm_struct *mm, pt_path_t pt_path,
 					unsigned long address);
 #else
 
@@ -111,7 +113,7 @@
 #define is_migration_entry(swp) 0
 #define migration_entry_to_page(swp) NULL
 static inline void make_migration_entry_read(swp_entry_t *entryp) { }
-static inline void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
+static inline void migration_entry_wait(struct mm_struct *mm, pt_path_t pt_path,
 					 unsigned long address) { }
 static inline int is_write_migration_entry(swp_entry_t entry)
 {
Index: linux-2.6.20-rc3/mm/migrate.c
===================================================================
--- linux-2.6.20-rc3.orig/mm/migrate.c	2007-01-01 11:53:20.000000000 +1100
+++ linux-2.6.20-rc3/mm/migrate.c	2007-01-04 20:49:46.344024000 +1100
@@ -255,15 +255,14 @@
  *
  * This function is called from do_swap_page().
  */
-void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
+void migration_entry_wait(struct mm_struct *mm, pt_path_t pt_path,
 				unsigned long address)
 {
 	pte_t *ptep, pte;
-	spinlock_t *ptl;
 	swp_entry_t entry;
 	struct page *page;
 
-	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
+	ptep = lookup_page_table_lock(mm, pt_path, address);
 	pte = *ptep;
 	if (!is_swap_pte(pte))
 		goto out;
@@ -275,14 +274,15 @@
 	page = migration_entry_to_page(entry);
 
 	get_page(page);
-	pte_unmap_unlock(ptep, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(page_table);
 	wait_on_page_locked(page);
 	put_page(page);
 	return;
 out:
-	pte_unmap_unlock(ptep, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(page_table);
 }
-
 /*
  * Replace the page in the mapping.
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
