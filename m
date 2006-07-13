From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Thu, 13 Jul 2006 14:27:55 +1000
Message-Id: <20060713042755.9978.16103.sendpatchset@localhost.localdomain>
In-Reply-To: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
References: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
Subject: [PATCH 8/18] PTI - Page fault handler
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

1) Continues calling the PTI interface to abstract page table dependent 
calls from the page fault handler functions.

2) Remove get_locked_pte from memory.c to be replaced by build_page_table.

3) Call lookup_page_table in filemap_xip.c


Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 include/linux/mm.h |    2 -
 mm/filemap_xip.c   |   26 +++++++++++++++++++---
 mm/memory.c        |   62 +++++++++++++++++++++--------------------------------
 3 files changed, 48 insertions(+), 42 deletions(-)
Index: linux-2.6.17.2/mm/memory.c
===================================================================
--- linux-2.6.17.2.orig/mm/memory.c	2006-07-08 20:35:44.823860064 +1000
+++ linux-2.6.17.2/mm/memory.c	2006-07-08 20:38:43.631677144 +1000
@@ -934,18 +934,6 @@
 	return err;
 }
 
-pte_t * fastcall get_locked_pte(struct mm_struct *mm, unsigned long addr, spinlock_t **ptl)
-{
-	pgd_t * pgd = pgd_offset(mm, addr);
-	pud_t * pud = pud_alloc(mm, pgd, addr);
-	if (pud) {
-		pmd_t * pmd = pmd_alloc(mm, pud, addr);
-		if (pmd)
-			return pte_alloc_map_lock(mm, pmd, addr, ptl);
-	}
-	return NULL;
-}
-
 /*
  * This is the old fallback for page remapping.
  *
@@ -957,14 +945,14 @@
 {
 	int retval;
 	pte_t *pte;
-	spinlock_t *ptl;  
+	pt_path_t pt_path;
 
 	retval = -EINVAL;
 	if (PageAnon(page))
 		goto out;
 	retval = -ENOMEM;
 	flush_dcache_page(page);
-	pte = get_locked_pte(mm, addr, &ptl);
+	pte = build_page_table(mm, addr, &pt_path);
 	if (!pte)
 		goto out;
 	retval = -EBUSY;
@@ -979,7 +967,8 @@
 
 	retval = 0;
 out_unlock:
-	pte_unmap_unlock(pte, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(pte);
 out:
 	return retval;
 }
@@ -1136,17 +1125,13 @@
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
@@ -1210,10 +1195,9 @@
  * but allow concurrent faults), with pte both mapped and locked.
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
-
 static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		spinlock_t *ptl, pte_t orig_pte)
+		unsigned long address, pte_t *page_table, pt_path_t pt_path,
+		pte_t orig_pte)
 {
 	struct page *old_page, *new_page;
 	pte_t entry;
@@ -1243,7 +1227,8 @@
 	 */
 	page_cache_get(old_page);
 gotten:
-	pte_unmap_unlock(page_table, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(page_table);
 
 	if (unlikely(anon_vma_prepare(vma)))
 		goto oom;
@@ -1261,7 +1246,7 @@
 	/*
 	 * Re-check the pte - we dropped the lock
 	 */
-	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	page_table = lookup_page_table_fast(mm, pt_path, address);
 	if (likely(pte_same(*page_table, orig_pte))) {
 		if (old_page) {
 			page_remove_rmap(old_page);
@@ -1289,7 +1274,8 @@
 	if (old_page)
 		page_cache_release(old_page);
 unlock:
-	pte_unmap_unlock(page_table, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(page_table);
 	return ret;
 oom:
 	if (old_page)
@@ -1638,16 +1624,15 @@
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
@@ -1661,7 +1646,7 @@
 			 * Back out if somebody else faulted in this pte
 			 * while we released the pte lock.
 			 */
-			page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+			page_table = lookup_page_table_fast(mm, pt_path, address);
 			if (likely(pte_same(*page_table, orig_pte)))
 				ret = VM_FAULT_OOM;
 			goto unlock;
@@ -1685,7 +1670,7 @@
 	/*
 	 * Back out if somebody else already faulted in this pte.
 	 */
-	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	page_table = lookup_page_table_fast(mm, pt_path, address);
 	if (unlikely(!pte_same(*page_table, orig_pte)))
 		goto out_nomap;
 
@@ -1713,8 +1698,8 @@
 	unlock_page(page);
 
 	if (write_access) {
-		if (do_wp_page(mm, vma, address,
-				page_table, pmd, ptl, pte) == VM_FAULT_OOM)
+			if (do_wp_page(mm, vma, address,
+				page_table, pt_path, pte) == VM_FAULT_OOM)
 			ret = VM_FAULT_OOM;
 		goto out;
 	}
@@ -1723,11 +1708,14 @@
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
+
 	unlock_page(page);
 	page_cache_release(page);
 	return ret;
Index: linux-2.6.17.2/mm/filemap_xip.c
===================================================================
--- linux-2.6.17.2.orig/mm/filemap_xip.c	2006-07-08 20:35:44.823860064 +1000
+++ linux-2.6.17.2/mm/filemap_xip.c	2006-07-08 20:35:46.151658208 +1000
@@ -16,6 +16,8 @@
 #include <asm/tlbflush.h>
 #include "filemap.h"
 
+#include <linux/pt.h>
+
 /*
  * This is a file read routine for execute in place files, and uses
  * the mapping->a_ops->get_xip_page() function for the actual low-level
@@ -174,7 +176,7 @@
 	unsigned long address;
 	pte_t *pte;
 	pte_t pteval;
-	spinlock_t *ptl;
+	pt_path_t pt_path;
 	struct page *page;
 
 	spin_lock(&mapping->i_mmap_lock);
@@ -184,7 +186,23 @@
 			((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
 		BUG_ON(address < vma->vm_start || address >= vma->vm_end);
 		page = ZERO_PAGE(address);
-		pte = page_check_address(page, mm, address, &ptl);
+		pte = lookup_page_table(mm, address, &pt_path);
+		if(!pte)
+			goto out;
+
+		/* Make a quick check before getting the lock */
+		if (!pte_present(*pte)) {
+			pte_unmap(pte);
+			goto out;
+		}
+
+		lock_pte(mm, pt_path);
+		if (!(pte_present(*pte) && page_to_pfn(page) == pte_pfn(*pte))) {
+			unlock_pte(mm, pt_path);
+			pte_unmap(pte);
+			goto out;
+		}
+
 		if (pte) {
 			/* Nuke the page table entry. */
 			flush_cache_page(vma, address, pte_pfn(*pte));
@@ -192,10 +210,12 @@
 			page_remove_rmap(page);
 			dec_mm_counter(mm, file_rss);
 			BUG_ON(pte_dirty(pteval));
-			pte_unmap_unlock(pte, ptl);
+			unlock_pte(mm, pt_path);
+			pte_unmap(pte);
 			page_cache_release(page);
 		}
 	}
+out:
 	spin_unlock(&mapping->i_mmap_lock);
 }
 
Index: linux-2.6.17.2/include/linux/mm.h
===================================================================
--- linux-2.6.17.2.orig/include/linux/mm.h	2006-07-08 20:35:44.899848512 +1000
+++ linux-2.6.17.2/include/linux/mm.h	2006-07-08 20:35:46.153657904 +1000
@@ -796,8 +796,6 @@
 	unsigned long private_dirty;
 };
 
-extern pte_t *FASTCALL(get_locked_pte(struct mm_struct *mm, unsigned long addr, spinlock_t **ptl));
-
 #include <linux/pt-mm.h>
 
 extern void free_area_init(unsigned long * zones_size);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
