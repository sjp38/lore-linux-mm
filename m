From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Thu, 13 Jul 2006 14:27:45 +1000
Message-Id: <20060713042745.9978.53008.sendpatchset@localhost.localdomain>
In-Reply-To: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
References: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
Subject: [PATCH 7/18] PTI - Page fault handler
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

1) Calls the PTI interface to abstract page table dependent calls
from the page fault handler functions.

2) Abstracts page table dependent generic asm-generic/tlb.h #defines 
to asm-generic/pt-tlb.h 

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 include/asm-generic/pt-tlb.h |   24 +++++++++++++++
 include/asm-generic/tlb.h    |   22 +------------
 mm/memory.c                  |   68 ++++++++++++++++++-------------------------
 3 files changed, 56 insertions(+), 58 deletions(-)
Index: linux-2.6.17.2/include/asm-generic/pt-tlb.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.17.2/include/asm-generic/pt-tlb.h	2006-07-08 00:46:42.890847200 +1000
@@ -0,0 +1,24 @@
+#ifndef _ASM_GENERIC_PT_TLB_H
+#define _ASM_GENERIC_PT_TLB_H 1
+
+#define pte_free_tlb(tlb, ptep)					\
+	do {							\
+		tlb->need_flush = 1;				\
+		__pte_free_tlb(tlb, ptep);			\
+	} while (0)
+
+#ifndef __ARCH_HAS_4LEVEL_HACK
+#define pud_free_tlb(tlb, pudp)					\
+	do {							\
+		tlb->need_flush = 1;				\
+		__pud_free_tlb(tlb, pudp);			\
+	} while (0)
+#endif
+
+#define pmd_free_tlb(tlb, pmdp)					\
+	do {							\
+		tlb->need_flush = 1;				\
+		__pmd_free_tlb(tlb, pmdp);			\
+	} while (0)
+
+#endif
Index: linux-2.6.17.2/include/asm-generic/tlb.h
===================================================================
--- linux-2.6.17.2.orig/include/asm-generic/tlb.h	2006-07-08 00:46:34.233163368 +1000
+++ linux-2.6.17.2/include/asm-generic/tlb.h	2006-07-08 00:46:42.890847200 +1000
@@ -124,26 +124,8 @@
 		__tlb_remove_tlb_entry(tlb, ptep, address);	\
 	} while (0)
 
-#define pte_free_tlb(tlb, ptep)					\
-	do {							\
-		tlb->need_flush = 1;				\
-		__pte_free_tlb(tlb, ptep);			\
-	} while (0)
-
-#ifndef __ARCH_HAS_4LEVEL_HACK
-#define pud_free_tlb(tlb, pudp)					\
-	do {							\
-		tlb->need_flush = 1;				\
-		__pud_free_tlb(tlb, pudp);			\
-	} while (0)
-#endif
-
-#define pmd_free_tlb(tlb, pmdp)					\
-	do {							\
-		tlb->need_flush = 1;				\
-		__pmd_free_tlb(tlb, pmdp);			\
-	} while (0)
-
 #define tlb_migrate_finish(mm) do {} while (0)
 
+#include <asm-generic/pt-tlb.h>
+
 #endif /* _ASM_GENERIC__TLB_H */
Index: linux-2.6.17.2/mm/memory.c
===================================================================
--- linux-2.6.17.2.orig/mm/memory.c	2006-07-08 00:46:42.857852216 +1000
+++ linux-2.6.17.2/mm/memory.c	2006-07-08 01:04:37.485483984 +1000
@@ -1210,6 +1210,7 @@
  * but allow concurrent faults), with pte both mapped and locked.
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
+
 static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
 		spinlock_t *ptl, pte_t orig_pte)
@@ -1738,11 +1739,10 @@
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
 static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
+		unsigned long address, pte_t *page_table, pt_path_t pt_path,
 		int write_access)
 {
 	struct page *page;
-	spinlock_t *ptl;
 	pte_t entry;
 
 	if (write_access) {
@@ -1758,7 +1758,7 @@
 		entry = mk_pte(page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 
-		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+		page_table = lookup_page_table_fast(mm, pt_path, address);
 		if (!pte_none(*page_table))
 			goto release;
 		inc_mm_counter(mm, anon_rss);
@@ -1770,8 +1770,8 @@
 		page_cache_get(page);
 		entry = mk_pte(page, vma->vm_page_prot);
 
-		ptl = pte_lockptr(mm, pmd);
-		spin_lock(ptl);
+		lock_pte(mm, pt_path);
+
 		if (!pte_none(*page_table))
 			goto release;
 		inc_mm_counter(mm, file_rss);
@@ -1784,7 +1784,8 @@
 	update_mmu_cache(vma, address, entry);
 	lazy_mmu_prot_update(entry);
 unlock:
-	pte_unmap_unlock(page_table, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(page_table);
 	return VM_FAULT_MINOR;
 release:
 	page_cache_release(page);
@@ -1807,10 +1808,9 @@
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
 static int do_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
+		unsigned long address, pte_t *page_table, pt_path_t pt_path,
 		int write_access)
 {
-	spinlock_t *ptl;
 	struct page *new_page;
 	struct address_space *mapping = NULL;
 	pte_t entry;
@@ -1859,14 +1859,17 @@
 		anon = 1;
 	}
 
-	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	page_table = lookup_page_table_fast(mm, pt_path, address);
+	
 	/*
 	 * For a file-backed vma, someone could have truncated or otherwise
 	 * invalidated this page.  If unmap_mapping_range got called,
 	 * retry getting the page.
 	 */
 	if (mapping && unlikely(sequence != mapping->truncate_count)) {
-		pte_unmap_unlock(page_table, ptl);
+		unlock_pte(mm, pt_path);
+		pte_unmap(page_table);
+
 		page_cache_release(new_page);
 		cond_resched();
 		sequence = mapping->truncate_count;
@@ -1909,7 +1912,8 @@
 	update_mmu_cache(vma, address, entry);
 	lazy_mmu_prot_update(entry);
 unlock:
-	pte_unmap_unlock(page_table, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(page_table);
 	return ret;
 oom:
 	page_cache_release(new_page);
@@ -1926,13 +1930,13 @@
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
@@ -1969,36 +1973,35 @@
  */
 static inline int handle_pte_fault(struct mm_struct *mm,
 		struct vm_area_struct *vma, unsigned long address,
-		pte_t *pte, pmd_t *pmd, int write_access)
+		pte_t *pte, pt_path_t pt_path, int write_access)
 {
 	pte_t entry;
 	pte_t old_entry;
-	spinlock_t *ptl;
 
 	old_entry = entry = *pte;
 	if (!pte_present(entry)) {
 		if (pte_none(entry)) {
 			if (!vma->vm_ops || !vma->vm_ops->nopage)
 				return do_anonymous_page(mm, vma, address,
-					pte, pmd, write_access);
+					pte, pt_path, write_access);
 			return do_no_page(mm, vma, address,
-					pte, pmd, write_access);
+					pte, pt_path, write_access);
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
@@ -2017,7 +2020,8 @@
 			flush_tlb_page(vma, address);
 	}
 unlock:
-	pte_unmap_unlock(pte, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(pte);
 	return VM_FAULT_MINOR;
 }
 
@@ -2027,30 +2031,18 @@
 int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, int write_access)
 {
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
 	pte_t *pte;
+	pt_path_t pt_path;
 
 	__set_current_state(TASK_RUNNING);
 
 	inc_page_state(pgfault);
 
-	if (unlikely(is_vm_hugetlb_page(vma)))
-		return hugetlb_fault(mm, vma, address, write_access);
-
-	pgd = pgd_offset(mm, address);
-	pud = pud_alloc(mm, pgd, address);
-	if (!pud)
-		return VM_FAULT_OOM;
-	pmd = pmd_alloc(mm, pud, address);
-	if (!pmd)
-		return VM_FAULT_OOM;
-	pte = pte_alloc_map(mm, pmd, address);
+	pte = build_page_table(mm, address, &pt_path);
 	if (!pte)
 		return VM_FAULT_OOM;
 
-	return handle_pte_fault(mm, vma, address, pte, pmd, write_access);
+	return handle_pte_fault(mm, vma, address, pte, pt_path, write_access);
 }
 
 EXPORT_SYMBOL_GPL(__handle_mm_fault);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
