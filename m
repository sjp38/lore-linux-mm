Received: From weill.orchestra.cse.unsw.EDU.AU ([129.94.242.49]) (ident-user root)
	(for <linux-mm@kvack.org>) By tone With Smtp ;
	Tue, 30 May 2006 17:18:29 +1000
From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Tue, 30 May 2006 17:18:28 +1000 (EST)
Subject: [Patch 5/17] PTI: Clean up page fault handler
Message-ID: <Pine.LNX.4.61.0605301716230.10816@weill.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This file calls the simple page table interface to allow the page fault
  handler to work independently of the default page table implementation.

  memory.c |  119 
++++++++++++++++++++++++++++++++++++---------------------------
  1 file changed, 68 insertions(+), 51 deletions(-)
Index: linux-rc5/mm/memory.c
===================================================================
--- linux-rc5.orig/mm/memory.c	2006-05-28 18:53:18.981556640 +1000
+++ linux-rc5/mm/memory.c	2006-05-28 18:53:20.053393696 +1000
@@ -57,6 +57,7 @@

  #include <linux/swapops.h>
  #include <linux/elf.h>
+#include <linux/default-pt.h>

  #ifndef CONFIG_NEED_MULTIPLE_NODES
  /* use the per-pgdat data instead for discontigmem - mbligh */
@@ -1145,6 +1146,18 @@
   * (but do_wp_page is only called after already making such a check;
   * and do_anonymous_page and do_no_page can safely check later on).
   */
+static inline int pte_unmap_same(struct mm_struct *mm, pt_path_t pt_path,
+				pte_t *page_table, pte_t orig_pte)
+{
+	int same = 1;
+#if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
+	if (sizeof(pte_t) > sizeof(unsigned long))
+		same = atomic_pte_same(mm, page_table, orig_pte, pt_path);
+#endif
+	pte_unmap(page_table);
+	return same;
+}
+
  static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
  				pte_t *page_table, pte_t orig_pte)
  {
@@ -1220,13 +1233,16 @@
   * We return with mmap_sem still held, but pte unmapped and unlocked.
   */
  static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		spinlock_t *ptl, pte_t orig_pte)
+		unsigned long address, pte_t *page_table, pt_path_t 
pt_path,
+		pte_t orig_pte)
  {
  	struct page *old_page, *new_page;
  	pte_t entry;
  	int ret = VM_FAULT_MINOR;

+	pmd_t *pmd;
+	pmd = pt_path.pmd;
+
  	old_page = vm_normal_page(vma, address, orig_pte);
  	if (!old_page)
  		goto gotten;
@@ -1251,7 +1267,8 @@
  	 */
  	page_cache_get(old_page);
  gotten:
-	pte_unmap_unlock(page_table, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(page_table);

  	if (unlikely(anon_vma_prepare(vma)))
  		goto oom;
@@ -1269,7 +1286,8 @@
  	/*
  	 * Re-check the pte - we dropped the lock
  	 */
-	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	page_table = lookup_page_table_fast(mm, pt_path, address);
+
  	if (likely(pte_same(*page_table, orig_pte))) {
  		if (old_page) {
  			page_remove_rmap(old_page);
@@ -1297,7 +1315,8 @@
  	if (old_page)
  		page_cache_release(old_page);
  unlock:
-	pte_unmap_unlock(page_table, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(page_table);
  	return ret;
  oom:
  	if (old_page)
@@ -1646,16 +1665,18 @@
   * We return with mmap_sem still held, but pte unmapped and unlocked.
   */
  static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
+		unsigned long address, pte_t *page_table, pt_path_t 
pt_path,
  		int write_access, pte_t orig_pte)
  {
-	spinlock_t *ptl;
  	struct page *page;
  	swp_entry_t entry;
  	pte_t pte;
  	int ret = VM_FAULT_MINOR;

-	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
+	pmd_t *pmd;
+	pmd = pt_path.pmd;
+
+	if (!pte_unmap_same(mm, pt_path, page_table, orig_pte))
  		goto out;

  	entry = pte_to_swp_entry(orig_pte);
@@ -1669,7 +1690,7 @@
  			 * Back out if somebody else faulted in this pte
  			 * while we released the pte lock.
  			 */
-			page_table = pte_offset_map_lock(mm, pmd, address, 
&ptl);
+			page_table = lookup_page_table_fast(mm, pt_path, 
address);
  			if (likely(pte_same(*page_table, orig_pte)))
  				ret = VM_FAULT_OOM;
  			goto unlock;
@@ -1693,7 +1714,7 @@
  	/*
  	 * Back out if somebody else already faulted in this pte.
  	 */
-	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	page_table = lookup_page_table_fast(mm, pt_path, address);
  	if (unlikely(!pte_same(*page_table, orig_pte)))
  		goto out_nomap;

@@ -1722,7 +1743,7 @@

  	if (write_access) {
  		if (do_wp_page(mm, vma, address,
-				page_table, pmd, ptl, pte) == 
VM_FAULT_OOM)
+				page_table, pt_path, pte) == VM_FAULT_OOM)
  			ret = VM_FAULT_OOM;
  		goto out;
  	}
@@ -1731,11 +1752,13 @@
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
@@ -1747,11 +1770,10 @@
   * We return with mmap_sem still held, but pte unmapped and unlocked.
   */
  static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct 
*vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
+		unsigned long address, pte_t *page_table, pt_path_t 
pt_path,
  		int write_access)
  {
  	struct page *page;
-	spinlock_t *ptl;
  	pte_t entry;

  	if (write_access) {
@@ -1767,7 +1789,7 @@
  		entry = mk_pte(page, vma->vm_page_prot);
  		entry = maybe_mkwrite(pte_mkdirty(entry), vma);

-		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+		lookup_page_table_fast(mm, pt_path, address);
  		if (!pte_none(*page_table))
  			goto release;
  		inc_mm_counter(mm, anon_rss);
@@ -1779,8 +1801,8 @@
  		page_cache_get(page);
  		entry = mk_pte(page, vma->vm_page_prot);

-		ptl = pte_lockptr(mm, pmd);
-		spin_lock(ptl);
+		lock_pte(mm, pt_path);
+
  		if (!pte_none(*page_table))
  			goto release;
  		inc_mm_counter(mm, file_rss);
@@ -1793,7 +1815,8 @@
  	update_mmu_cache(vma, address, entry);
  	lazy_mmu_prot_update(entry);
  unlock:
-	pte_unmap_unlock(page_table, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(page_table);
  	return VM_FAULT_MINOR;
  release:
  	page_cache_release(page);
@@ -1816,10 +1839,9 @@
   * We return with mmap_sem still held, but pte unmapped and unlocked.
   */
  static int do_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
+		unsigned long address, pte_t *page_table, pt_path_t 
pt_path,
  		int write_access)
  {
-	spinlock_t *ptl;
  	struct page *new_page;
  	struct address_space *mapping = NULL;
  	pte_t entry;
@@ -1827,6 +1849,9 @@
  	int ret = VM_FAULT_MINOR;
  	int anon = 0;

+	pmd_t *pmd;
+	pmd = pt_path.pmd;
+
  	pte_unmap(page_table);
  	BUG_ON(vma->vm_flags & VM_PFNMAP);

@@ -1868,14 +1893,17 @@
  		anon = 1;
  	}

-	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	page_table = lookup_page_table_fast(mm, pt_path, address);
+
  	/*
  	 * For a file-backed vma, someone could have truncated or 
otherwise
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
@@ -1918,7 +1946,8 @@
  	update_mmu_cache(vma, address, entry);
  	lazy_mmu_prot_update(entry);
  unlock:
-	pte_unmap_unlock(page_table, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(page_table);
  	return ret;
  oom:
  	page_cache_release(new_page);
@@ -1935,13 +1964,13 @@
   * We return with mmap_sem still held, but pte unmapped and unlocked.
   */
  static int do_file_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
+		unsigned long address, pte_t *page_table, pt_path_t 
pt_path,
  		int write_access, pte_t orig_pte)
  {
  	pgoff_t pgoff;
  	int err;

-	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
+	if (!pte_unmap_same(mm, pt_path, page_table, orig_pte))
  		return VM_FAULT_MINOR;

  	if (unlikely(!(vma->vm_flags & VM_NONLINEAR))) {
@@ -1978,36 +2007,35 @@
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
+					pte, pt_path, write_access, 
entry);
  		return do_swap_page(mm, vma, address,
-					pte, pmd, write_access, entry);
+					pte, pt_path, write_access, 
entry);
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
@@ -2026,7 +2054,8 @@
  			flush_tlb_page(vma, address);
  	}
  unlock:
-	pte_unmap_unlock(pte, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(pte);
  	return VM_FAULT_MINOR;
  }

@@ -2036,30 +2065,18 @@
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
+	return handle_pte_fault(mm, vma, address, pte, pt_path, 
write_access);
  }

  EXPORT_SYMBOL_GPL(__handle_mm_fault);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
