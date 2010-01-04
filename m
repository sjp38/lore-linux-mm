Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AC17A600068
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 15:49:23 -0500 (EST)
Message-Id: <20100104182813.180396813@chello.nl>
References: <20100104182429.833180340@chello.nl>
Date: Mon, 04 Jan 2010 19:24:30 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 1/8] mm: Remove pte reference from fault path
Content-Disposition: inline; filename=mm-foo-1.patch
Sender: owner-linux-mm@kvack.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Since we want to do speculative faults, where we can race against
unmap() and similar, we cannot trust pte pointers to remain valid.

Hence remove the relyance on those from the fault path.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/memory.c |   72 ++++++++++++++++--------------------------------------------
 1 file changed, 20 insertions(+), 52 deletions(-)

Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -1919,31 +1919,6 @@ int apply_to_page_range(struct mm_struct
 EXPORT_SYMBOL_GPL(apply_to_page_range);
 
 /*
- * handle_pte_fault chooses page fault handler according to an entry
- * which was read non-atomically.  Before making any commitment, on
- * those architectures or configurations (e.g. i386 with PAE) which
- * might give a mix of unmatched parts, do_swap_page and do_file_page
- * must check under lock before unmapping the pte and proceeding
- * (but do_wp_page is only called after already making such a check;
- * and do_anonymous_page and do_no_page can safely check later on).
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
-/*
  * Do pte_mkwrite, but only if the vma says VM_WRITE.  We do this when
  * servicing faults for write access.  In the normal case, do always want
  * pte_mkwrite.  But get_user_pages can cause write faults for mappings
@@ -2508,19 +2483,16 @@ int vmtruncate_range(struct inode *inode
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
 static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
+		unsigned long address, pmd_t *pmd,
 		unsigned int flags, pte_t orig_pte)
 {
 	spinlock_t *ptl;
 	struct page *page;
 	swp_entry_t entry;
-	pte_t pte;
+	pte_t *page_table, pte;
 	struct mem_cgroup *ptr = NULL;
 	int ret = 0;
 
-	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
-		goto out;
-
 	entry = pte_to_swp_entry(orig_pte);
 	if (unlikely(non_swap_entry(entry))) {
 		if (is_migration_entry(entry)) {
@@ -2650,18 +2622,16 @@ out_release:
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
 static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		unsigned int flags)
+		unsigned long address, pmd_t *pmd, unsigned int flags)
 {
 	struct page *page;
 	spinlock_t *ptl;
-	pte_t entry;
+	pte_t entry, *page_table;
 
 	if (!(flags & FAULT_FLAG_WRITE)) {
 		entry = pte_mkspecial(pfn_pte(my_zero_pfn(address),
 						vma->vm_page_prot));
-		ptl = pte_lockptr(mm, pmd);
-		spin_lock(ptl);
+		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
 		if (!pte_none(*page_table))
 			goto unlock;
 		goto setpte;
@@ -2900,13 +2870,12 @@ unwritable_page:
 }
 
 static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
+		unsigned long address, pmd_t *pmd,
 		unsigned int flags, pte_t orig_pte)
 {
 	pgoff_t pgoff = (((address & PAGE_MASK)
 			- vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
 
-	pte_unmap(page_table);
 	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
@@ -2920,16 +2889,13 @@ static int do_linear_fault(struct mm_str
  * We return with mmap_sem still held, but pte unmapped and unlocked.
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
@@ -2957,31 +2923,29 @@ static int do_nonlinear_fault(struct mm_
  */
 static inline int handle_pte_fault(struct mm_struct *mm,
 		struct vm_area_struct *vma, unsigned long address,
-		pte_t *pte, pmd_t *pmd, unsigned int flags)
+		pte_t entry, pmd_t *pmd, unsigned int flags)
 {
-	pte_t entry;
 	spinlock_t *ptl;
+	pte_t *pte;
 
-	entry = *pte;
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
 
-	ptl = pte_lockptr(mm, pmd);
-	spin_lock(ptl);
+	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
 	if (unlikely(!pte_same(*pte, entry)))
 		goto unlock;
 	if (flags & FAULT_FLAG_WRITE) {
@@ -3017,7 +2981,7 @@ int handle_mm_fault(struct mm_struct *mm
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
-	pte_t *pte;
+	pte_t *pte, entry;
 
 	__set_current_state(TASK_RUNNING);
 
@@ -3037,7 +3001,11 @@ int handle_mm_fault(struct mm_struct *mm
 	if (!pte)
 		return VM_FAULT_OOM;
 
-	return handle_pte_fault(mm, vma, address, pte, pmd, flags);
+	entry = *pte;
+
+	pte_unmap(pte);
+
+	return handle_pte_fault(mm, vma, address, entry, pmd, flags);
 }
 
 #ifndef __PAGETABLE_PUD_FOLDED

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
