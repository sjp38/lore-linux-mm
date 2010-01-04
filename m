Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6B41E6005A4
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 15:49:50 -0500 (EST)
Message-Id: <20100104182813.599032632@chello.nl>
References: <20100104182429.833180340@chello.nl>
Date: Mon, 04 Jan 2010 19:24:34 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 5/8] mm: Speculative pte_map_lock()
Content-Disposition: inline; filename=mm-foo-7.patch
Sender: owner-linux-mm@kvack.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Implement pte_map_lock(.flags & FAULT_FLAG_SPECULATIVE), in which case
we're not holding mmap_sem, so we can race against umap() and similar
routines.

Since we cannot rely on pagetable stability in the face of unmap, we
use the technique fast_gup() also uses for a lockless pagetable
lookup. For this we introduce the {un,}pin_page_tables() functions.

The only problem is that we do TLB flushes while holding the PTL,
which in turn means that we cannot acquire the PTL while having IRQs
disabled.

Fudge around this by open-coding a spinner which drops the page-table
pin, which on x86 will be IRQ-disable (that holds of the TLB flush,
which is done before freeing the pagetables).

Once we hold the PTL, we can validate the VMA, if that is still valid
we know we're good to go and holding the PTL will hold off unmap.

We need to propagate the VMA sequence count through the fault code.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/mm.h |    2 
 mm/memory.c        |  111 ++++++++++++++++++++++++++++++++++++++---------------
 mm/util.c          |   12 ++++-
 3 files changed, 93 insertions(+), 32 deletions(-)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -848,6 +848,8 @@ int get_user_pages(struct task_struct *t
 			struct page **pages, struct vm_area_struct **vmas);
 int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			struct page **pages);
+void pin_page_tables(void);
+void unpin_page_tables(void);
 struct page *get_dump_page(unsigned long addr);
 
 extern int try_to_release_page(struct page * page, gfp_t gfp_mask);
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -1959,10 +1959,56 @@ static inline void cow_user_page(struct 
 
 static int pte_map_lock(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pmd_t *pmd, unsigned int flags,
-		pte_t **ptep, spinlock_t **ptl)
+		unsigned int seq, pte_t **ptep, spinlock_t **ptlp)
 {
-	*ptep = pte_offset_map_lock(mm, pmd, address, ptl);
+	pgd_t *pgd;
+	pud_t *pud;
+
+	if (!(flags & FAULT_FLAG_SPECULATIVE)) {
+		*ptep = pte_offset_map_lock(mm, pmd, address, ptlp);
+		return 1;
+	}
+
+again:
+	pin_page_tables();
+
+	pgd = pgd_offset(mm, address);
+	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
+		goto out;
+
+	pud = pud_offset(pgd, address);
+	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
+		goto out;
+
+	pmd = pmd_offset(pud, address);
+	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
+		goto out;
+
+	if (pmd_huge(*pmd))
+		goto out;
+
+	*ptlp = pte_lockptr(mm, pmd);
+	*ptep = pte_offset_map(pmd, address);
+	if (!spin_trylock(*ptlp)) {
+		pte_unmap(*ptep);
+		unpin_page_tables();
+		goto again;
+	}
+
+	if (!*ptep)
+		goto out;
+
+	if (vma_is_dead(vma, seq))
+		goto unlock;
+
+	unpin_page_tables();
 	return 1;
+
+unlock:
+	pte_unmap_unlock(*ptep, *ptlp);
+out:
+	unpin_page_tables();
+	return 0;
 }
 
 /*
@@ -1985,7 +2031,8 @@ static int pte_map_lock(struct mm_struct
  */
 static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		spinlock_t *ptl, unsigned int flags, pte_t orig_pte)
+		spinlock_t *ptl, unsigned int flags, pte_t orig_pte,
+		unsigned int seq)
 {
 	struct page *old_page, *new_page;
 	pte_t entry;
@@ -2018,7 +2065,7 @@ static int do_wp_page(struct mm_struct *
 			pte_unmap_unlock(page_table, ptl);
 			lock_page(old_page);
 
-			if (!pte_map_lock(mm, vma, address, pmd, flags,
+			if (!pte_map_lock(mm, vma, address, pmd, flags, seq,
 						&page_table, &ptl)) {
 				unlock_page(old_page);
 				ret = VM_FAULT_RETRY;
@@ -2084,7 +2131,7 @@ static int do_wp_page(struct mm_struct *
 			 * they did, we just return, as we can count on the
 			 * MMU to tell us if they didn't also make it writable.
 			 */
-			if (!pte_map_lock(mm, vma, address, pmd, flags,
+			if (!pte_map_lock(mm, vma, address, pmd, flags, seq,
 						&page_table, &ptl)) {
 				unlock_page(old_page);
 				ret = VM_FAULT_RETRY;
@@ -2161,7 +2208,7 @@ gotten:
 	/*
 	 * Re-check the pte - we dropped the lock
 	 */
-	if (!pte_map_lock(mm, vma, address, pmd, flags, &page_table, &ptl)) {
+	if (!pte_map_lock(mm, vma, address, pmd, flags, seq, &page_table, &ptl)) {
 		mem_cgroup_uncharge_page(new_page);
 		ret = VM_FAULT_RETRY;
 		goto err_free_new;
@@ -2511,8 +2558,8 @@ int vmtruncate_range(struct inode *inode
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
 static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pmd_t *pmd,
-		unsigned int flags, pte_t orig_pte)
+		unsigned long address, pmd_t *pmd, unsigned int flags,
+		pte_t orig_pte, unsigned int seq)
 {
 	spinlock_t *ptl;
 	struct page *page;
@@ -2548,7 +2595,7 @@ static int do_swap_page(struct mm_struct
 			 * Back out if somebody else faulted in this pte
 			 * while we released the pte lock.
 			 */
-			if (!pte_map_lock(mm, vma, address, pmd, flags,
+			if (!pte_map_lock(mm, vma, address, pmd, flags, seq,
 						&page_table, &ptl)) {
 				ret = VM_FAULT_RETRY;
 				goto out;
@@ -2589,7 +2636,7 @@ static int do_swap_page(struct mm_struct
 	/*
 	 * Back out if somebody else already faulted in this pte.
 	 */
-	if (!pte_map_lock(mm, vma, address, pmd, flags, &page_table, &ptl)) {
+	if (!pte_map_lock(mm, vma, address, pmd, flags, seq, &page_table, &ptl)) {
 		ret = VM_FAULT_RETRY;
 		goto out_nolock;
 	}
@@ -2634,7 +2681,8 @@ static int do_swap_page(struct mm_struct
 	unlock_page(page);
 
 	if (flags & FAULT_FLAG_WRITE) {
-		ret |= do_wp_page(mm, vma, address, page_table, pmd, ptl, flags, pte);
+		ret |= do_wp_page(mm, vma, address, page_table, pmd,
+				ptl, flags, pte, seq);
 		if (ret & VM_FAULT_ERROR)
 			ret &= VM_FAULT_ERROR;
 		goto out;
@@ -2663,7 +2711,8 @@ out_release:
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
 static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pmd_t *pmd, unsigned int flags)
+		unsigned long address, pmd_t *pmd, unsigned int flags,
+		unsigned int seq)
 {
 	struct page *page;
 	spinlock_t *ptl;
@@ -2672,7 +2721,7 @@ static int do_anonymous_page(struct mm_s
 	if (!(flags & FAULT_FLAG_WRITE)) {
 		entry = pte_mkspecial(pfn_pte(my_zero_pfn(address),
 						vma->vm_page_prot));
-		if (!pte_map_lock(mm, vma, address, pmd, flags,
+		if (!pte_map_lock(mm, vma, address, pmd, flags, seq,
 					&page_table, &ptl))
 			return VM_FAULT_RETRY;
 		if (!pte_none(*page_table))
@@ -2697,7 +2746,7 @@ static int do_anonymous_page(struct mm_s
 	if (vma->vm_flags & VM_WRITE)
 		entry = pte_mkwrite(pte_mkdirty(entry));
 
-	if (!pte_map_lock(mm, vma, address, pmd, flags, &page_table, &ptl)) {
+	if (!pte_map_lock(mm, vma, address, pmd, flags, seq, &page_table, &ptl)) {
 		mem_cgroup_uncharge_page(page);
 		page_cache_release(page);
 		return VM_FAULT_RETRY;
@@ -2740,8 +2789,8 @@ oom:
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
 static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pmd_t *pmd,
-		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
+		unsigned long address, pmd_t *pmd, pgoff_t pgoff,
+		unsigned int flags, pte_t orig_pte, unsigned int seq)
 {
 	pte_t *page_table;
 	spinlock_t *ptl;
@@ -2841,7 +2890,7 @@ static int __do_fault(struct mm_struct *
 
 	}
 
-	if (!pte_map_lock(mm, vma, address, pmd, flags, &page_table, &ptl)) {
+	if (!pte_map_lock(mm, vma, address, pmd, flags, seq, &page_table, &ptl)) {
 		ret = VM_FAULT_RETRY;
 		goto out_uncharge;
 	}
@@ -2923,12 +2972,12 @@ unwritable_page:
 
 static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pmd_t *pmd,
-		unsigned int flags, pte_t orig_pte)
+		unsigned int flags, pte_t orig_pte, unsigned int seq)
 {
 	pgoff_t pgoff = (((address & PAGE_MASK)
 			- vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
 
-	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
+	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte, seq);
 }
 
 /*
@@ -2942,7 +2991,7 @@ static int do_linear_fault(struct mm_str
  */
 static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pmd_t *pmd,
-		unsigned int flags, pte_t orig_pte)
+		unsigned int flags, pte_t orig_pte, unsigned int seq)
 {
 	pgoff_t pgoff;
 
@@ -2957,7 +3006,7 @@ static int do_nonlinear_fault(struct mm_
 	}
 
 	pgoff = pte_to_pgoff(orig_pte);
-	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
+	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte, seq);
 }
 
 /*
@@ -2975,7 +3024,8 @@ static int do_nonlinear_fault(struct mm_
  */
 static inline int handle_pte_fault(struct mm_struct *mm,
 		struct vm_area_struct *vma, unsigned long address,
-		pte_t entry, pmd_t *pmd, unsigned int flags)
+		pte_t entry, pmd_t *pmd, unsigned int flags,
+		unsigned int seq)
 {
 	spinlock_t *ptl;
 	pte_t *pte;
@@ -2985,26 +3035,27 @@ static inline int handle_pte_fault(struc
 			if (vma->vm_ops) {
 				if (likely(vma->vm_ops->fault))
 					return do_linear_fault(mm, vma, address,
-						pmd, flags, entry);
+						pmd, flags, entry, seq);
 			}
 			return do_anonymous_page(mm, vma, address,
-						 pmd, flags);
+						 pmd, flags, seq);
 		}
 		if (pte_file(entry))
 			return do_nonlinear_fault(mm, vma, address,
-					pmd, flags, entry);
+					pmd, flags, entry, seq);
 		return do_swap_page(mm, vma, address,
-					pmd, flags, entry);
+					pmd, flags, entry, seq);
 	}
 
-	if (!pte_map_lock(mm, vma, address, pmd, flags, &pte, &ptl))
+	if (!pte_map_lock(mm, vma, address, pmd, flags, seq, &pte, &ptl))
 		return VM_FAULT_RETRY;
 	if (unlikely(!pte_same(*pte, entry)))
 		goto unlock;
 	if (flags & FAULT_FLAG_WRITE) {
-		if (!pte_write(entry))
+		if (!pte_write(entry)) {
 			return do_wp_page(mm, vma, address,
-					pte, pmd, ptl, flags, entry);
+					pte, pmd, ptl, flags, entry, seq);
+		}
 		entry = pte_mkdirty(entry);
 	}
 	entry = pte_mkyoung(entry);
@@ -3058,7 +3109,7 @@ int handle_mm_fault(struct mm_struct *mm
 
 	pte_unmap(pte);
 
-	return handle_pte_fault(mm, vma, address, entry, pmd, flags);
+	return handle_pte_fault(mm, vma, address, entry, pmd, flags, 0);
 }
 
 #ifndef __PAGETABLE_PUD_FOLDED
Index: linux-2.6/mm/util.c
===================================================================
--- linux-2.6.orig/mm/util.c
+++ linux-2.6/mm/util.c
@@ -253,8 +253,8 @@ void arch_pick_mmap_layout(struct mm_str
  * callers need to carefully consider what to use. On many architectures,
  * get_user_pages_fast simply falls back to get_user_pages.
  */
-int __attribute__((weak)) get_user_pages_fast(unsigned long start,
-				int nr_pages, int write, struct page **pages)
+int __weak get_user_pages_fast(unsigned long start,
+			       int nr_pages, int write, struct page **pages)
 {
 	struct mm_struct *mm = current->mm;
 	int ret;
@@ -268,6 +268,14 @@ int __attribute__((weak)) get_user_pages
 }
 EXPORT_SYMBOL_GPL(get_user_pages_fast);
 
+void __weak pin_page_tables(void)
+{
+}
+
+void __weak unpin_page_tables(void)
+{
+}
+
 /* Tracepoints definitions. */
 EXPORT_TRACEPOINT_SYMBOL(kmalloc);
 EXPORT_TRACEPOINT_SYMBOL(kmem_cache_alloc);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
