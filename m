From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:46:22 +1100
Message-Id: <20070113024622.29682.63596.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 8/29] Clean up page fault handers
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH 08
 * Goes through the page fault handler functions in memory.c and abstracts
 the implementation dependent page table lookups, replacing them with calls
 from the interface.   
 * This has been abstracted such that the fault handler functions remain 
 as undisturbed as possible for the default page table implementation.

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 memory.c |   44 ++++++++++++++++++++++++--------------------
 1 file changed, 24 insertions(+), 20 deletions(-)
Index: linux-2.6.20-rc1/mm/memory.c
===================================================================
--- linux-2.6.20-rc1.orig/mm/memory.c	2006-12-21 16:50:32.334023000 +1100
+++ linux-2.6.20-rc1/mm/memory.c	2006-12-21 16:54:57.202023000 +1100
@@ -2014,11 +2014,10 @@
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
@@ -2034,7 +2033,7 @@
 		entry = mk_pte(page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 
-		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+		page_table = lookup_page_table_lock(mm, pt_path, address);
 		if (!pte_none(*page_table))
 			goto release;
 		inc_mm_counter(mm, anon_rss);
@@ -2046,8 +2045,8 @@
 		page_cache_get(page);
 		entry = mk_pte(page, vma->vm_page_prot);
 
-		ptl = pte_lockptr(mm, pmd);
-		spin_lock(ptl);
+		lock_pte(mm, pt_path);
+
 		if (!pte_none(*page_table))
 			goto release;
 		inc_mm_counter(mm, file_rss);
@@ -2060,7 +2059,8 @@
 	update_mmu_cache(vma, address, entry);
 	lazy_mmu_prot_update(entry);
 unlock:
-	pte_unmap_unlock(page_table, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(page_table);
 	return VM_FAULT_MINOR;
 release:
 	page_cache_release(page);
@@ -2083,10 +2083,9 @@
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
@@ -2151,14 +2150,16 @@
 		}
 	}
 
-	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	page_table = lookup_page_table_lock(mm, pt_path, address);
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
 		page_cache_release(new_page);
 		cond_resched();
 		sequence = mapping->truncate_count;
@@ -2205,7 +2206,8 @@
 	update_mmu_cache(vma, address, entry);
 	lazy_mmu_prot_update(entry);
 unlock:
-	pte_unmap_unlock(page_table, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(page_table);
 	if (dirty_page) {
 		set_page_dirty_balance(dirty_page);
 		put_page(dirty_page);
@@ -2233,10 +2235,9 @@
  * Mark this `noinline' to prevent it from bloating the main pagefault code.
  */
 static noinline int do_no_pfn(struct mm_struct *mm, struct vm_area_struct *vma,
-		     unsigned long address, pte_t *page_table, pmd_t *pmd,
+		     unsigned long address, pte_t *page_table, pt_path_t pt_path,
 		     int write_access)
 {
-	spinlock_t *ptl;
 	pte_t entry;
 	unsigned long pfn;
 	int ret = VM_FAULT_MINOR;
@@ -2251,7 +2252,7 @@
 	if (pfn == NOPFN_SIGBUS)
 		return VM_FAULT_SIGBUS;
 
-	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	page_table = lookup_page_table_lock(mm, pt_path, address);
 
 	/* Only go through if we didn't race with anybody else... */
 	if (pte_none(*page_table)) {
@@ -2260,7 +2261,8 @@
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		set_pte_at(mm, address, page_table, entry);
 	}
-	pte_unmap_unlock(page_table, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(page_table);
 	return ret;
 }
 
@@ -2317,26 +2319,28 @@
  */
 static inline int handle_pte_fault(struct mm_struct *mm,
 		struct vm_area_struct *vma, unsigned long address,
-		pte_t *pte, pmd_t *pmd, int write_access)
+		pte_t *pte, pt_path_t pt_path, int write_access)
 {
 	pte_t entry;
 	pte_t old_entry;
 	spinlock_t *ptl;
 
+	pmd_t *pmd = pt_path.pmd;
+
 	old_entry = entry = *pte;
 	if (!pte_present(entry)) {
 		if (pte_none(entry)) {
 			if (vma->vm_ops) {
 				if (vma->vm_ops->nopage)
 					return do_no_page(mm, vma, address,
-							  pte, pmd,
+							  pte, pt_path,
 							  write_access);
 				if (unlikely(vma->vm_ops->nopfn))
 					return do_no_pfn(mm, vma, address, pte,
-							 pmd, write_access);
+							 pt_path, write_access);
 			}
 			return do_anonymous_page(mm, vma, address,
-						 pte, pmd, write_access);
+						 pte, pt_path, write_access);
 		}
 		if (pte_file(entry))
 			return do_file_page(mm, vma, address,
@@ -2396,7 +2400,7 @@
 	if (!pte)
 		return VM_FAULT_OOM;
 
-	return handle_pte_fault(mm, vma, address, pte, pt_path.pmd, write_access);
+	return handle_pte_fault(mm, vma, address, pte, pt_path, write_access);
 }
 EXPORT_SYMBOL_GPL(__handle_mm_fault);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
