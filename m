Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id E79EE6B0073
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 18:41:57 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id fp1so22296pdb.7
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 15:41:57 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id dd15si9161809pac.61.2014.10.20.15.41.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Oct 2014 15:41:54 -0700 (PDT)
Message-Id: <20141020222841.244195829@infradead.org>
Date: Mon, 20 Oct 2014 23:56:34 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [RFC][PATCH 1/6] mm: Dont assume page-table invariance during faults
References: <20141020215633.717315139@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=peterz-mm-kill-pte-pointer.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, laijs@cn.fujitsu.com, dave@stgolabs.net
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>

One of the side effects of speculating on faults (without holding
mmap_sem) is that we can race with free_pgtables() and therefore we
cannot assume the page-tables will stick around.

Remove the relyance on the pte pointer.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 mm/memory.c |   76 ++++++++++++++++--------------------------------------------
 1 file changed, 21 insertions(+), 55 deletions(-)

--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1933,31 +1933,6 @@ int apply_to_page_range(struct mm_struct
 }
 EXPORT_SYMBOL_GPL(apply_to_page_range);
 
-/*
- * handle_pte_fault chooses page fault handler according to an entry
- * which was read non-atomically.  Before making any commitment, on
- * those architectures or configurations (e.g. i386 with PAE) which
- * might give a mix of unmatched parts, do_swap_page and do_nonlinear_fault
- * must check under lock before unmapping the pte and proceeding
- * (but do_wp_page is only called after already making such a check;
- * and do_anonymous_page can safely check later on).
- */
-static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
-				pte_t *page_table, pte_t orig_pte)
-{
-	int same = 1;
-#if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
-	if (sizeof(pte_t) > sizeof(unsigned long)) {
-		spinlock_t *ptl = pte_lockptr(mm, pmd);
-		spin_lock(ptl);
-		same = pte_same(*page_table, orig_pte);
-		spin_unlock(ptl);
-	}
-#endif
-	pte_unmap(page_table);
-	return same;
-}
-
 static inline void cow_user_page(struct page *dst, struct page *src, unsigned long va, struct vm_area_struct *vma)
 {
 	debug_dma_assert_idle(src);
@@ -2407,21 +2382,18 @@ EXPORT_SYMBOL(unmap_mapping_range);
  * as does filemap_fault().
  */
 static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
+		unsigned long address, pmd_t *pmd,
 		unsigned int flags, pte_t orig_pte)
 {
 	spinlock_t *ptl;
 	struct page *page, *swapcache;
 	struct mem_cgroup *memcg;
 	swp_entry_t entry;
-	pte_t pte;
+	pte_t *page_table, pte;
 	int locked;
 	int exclusive = 0;
 	int ret = 0;
 
-	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
-		goto out;
-
 	entry = pte_to_swp_entry(orig_pte);
 	if (unlikely(non_swap_entry(entry))) {
 		if (is_migration_entry(entry)) {
@@ -2624,15 +2596,13 @@ static inline int check_stack_guard_page
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
 static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
+		unsigned long address, pmd_t *pmd,
 		unsigned int flags)
 {
 	struct mem_cgroup *memcg;
 	struct page *page;
 	spinlock_t *ptl;
-	pte_t entry;
-
-	pte_unmap(page_table);
+	pte_t entry, *page_table;
 
 	/* Check if we need to add a guard page to the stack */
 	if (check_stack_guard_page(vma, address) < 0)
@@ -3031,13 +3001,12 @@ static int do_shared_fault(struct mm_str
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
 static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
+		unsigned long address, pmd_t *pmd,
 		unsigned int flags, pte_t orig_pte)
 {
 	pgoff_t pgoff = (((address & PAGE_MASK)
 			- vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
 
-	pte_unmap(page_table);
 	if (!(flags & FAULT_FLAG_WRITE))
 		return do_read_fault(mm, vma, address, pmd, pgoff, flags,
 				orig_pte);
@@ -3059,16 +3028,13 @@ static int do_linear_fault(struct mm_str
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
 static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
+		unsigned long address, pmd_t *pmd,
 		unsigned int flags, pte_t orig_pte)
 {
 	pgoff_t pgoff;
 
 	flags |= FAULT_FLAG_NONLINEAR;
 
-	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
-		return 0;
-
 	if (unlikely(!(vma->vm_flags & VM_NONLINEAR))) {
 		/*
 		 * Page table corrupted: show pte and kill process.
@@ -3103,7 +3069,7 @@ static int numa_migrate_prep(struct page
 }
 
 static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		   unsigned long addr, pte_t pte, pte_t *ptep, pmd_t *pmd)
+		   unsigned long addr, pte_t pte, pmd_t *pmd)
 {
 	struct page *page = NULL;
 	spinlock_t *ptl;
@@ -3112,6 +3078,7 @@ static int do_numa_page(struct mm_struct
 	int target_nid;
 	bool migrated = false;
 	int flags = 0;
+	pte_t *ptep;
 
 	/*
 	* The "pte" at this point cannot be used safely without
@@ -3122,8 +3089,7 @@ static int do_numa_page(struct mm_struct
 	* the _PAGE_NUMA bit and it is not really expected that there
 	* would be concurrent hardware modifications to the PTE.
 	*/
-	ptl = pte_lockptr(mm, pmd);
-	spin_lock(ptl);
+	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	if (unlikely(!pte_same(*ptep, pte))) {
 		pte_unmap_unlock(ptep, ptl);
 		goto out;
@@ -3195,34 +3161,32 @@ static int do_numa_page(struct mm_struct
  */
 static int handle_pte_fault(struct mm_struct *mm,
 		     struct vm_area_struct *vma, unsigned long address,
-		     pte_t *pte, pmd_t *pmd, unsigned int flags)
+		     pte_t entry, pmd_t *pmd, unsigned int flags)
 {
-	pte_t entry;
 	spinlock_t *ptl;
+	pte_t *pte;
 
-	entry = ACCESS_ONCE(*pte);
 	if (!pte_present(entry)) {
 		if (pte_none(entry)) {
 			if (vma->vm_ops) {
 				if (likely(vma->vm_ops->fault))
 					return do_linear_fault(mm, vma, address,
-						pte, pmd, flags, entry);
+						pmd, flags, entry);
 			}
 			return do_anonymous_page(mm, vma, address,
-						 pte, pmd, flags);
+						 pmd, flags);
 		}
 		if (pte_file(entry))
 			return do_nonlinear_fault(mm, vma, address,
-					pte, pmd, flags, entry);
+					pmd, flags, entry);
 		return do_swap_page(mm, vma, address,
-					pte, pmd, flags, entry);
+					pmd, flags, entry);
 	}
 
 	if (pte_numa(entry))
-		return do_numa_page(mm, vma, address, entry, pte, pmd);
+		return do_numa_page(mm, vma, address, entry, pmd);
 
-	ptl = pte_lockptr(mm, pmd);
-	spin_lock(ptl);
+	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
 	if (unlikely(!pte_same(*pte, entry)))
 		goto unlock;
 	if (flags & FAULT_FLAG_WRITE) {
@@ -3261,7 +3225,7 @@ static int __handle_mm_fault(struct mm_s
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
-	pte_t *pte;
+	pte_t *pte, entry;
 
 	if (unlikely(is_vm_hugetlb_page(vma)))
 		return hugetlb_fault(mm, vma, address, flags);
@@ -3331,8 +3295,10 @@ static int __handle_mm_fault(struct mm_s
 	 * safe to run pte_offset_map().
 	 */
 	pte = pte_offset_map(pmd, address);
+	entry = ACCESS_ONCE(*pte);
+	pte_unmap(pte);
 
-	return handle_pte_fault(mm, vma, address, pte, pmd, flags);
+	return handle_pte_fault(mm, vma, address, entry, pmd, flags);
 }
 
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
