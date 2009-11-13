Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0BD266B0062
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 02:44:15 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAD7iD7u007437
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 13 Nov 2009 16:44:13 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E531945DE55
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 16:44:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BADCB45DE4F
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 16:44:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 935E21DB803C
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 16:44:12 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 38A911DB8038
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 16:44:12 +0900 (JST)
Date: Fri, 13 Nov 2009 16:41:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC MM 4/4]  speculative page fault
Message-Id: <20091113164134.79805c13.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091113163544.d92561c7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091113163544.d92561c7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: cl@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Speculative page fault.

 This patch tries to implement speculative page fault.
 Do page fault without taking mm->semaphore and check tag mm->generation
 after taking page table lock. If generation is modified, someone took
 write lock on mm->semaphore and we need to take read lock.

 Now, hugepage is not handled. And stack page is not handled because
 it can change [vm_start, vm_end).

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 arch/x86/mm/fault.c |   54 ++++++++++++++++++++++++++--------------
 include/linux/mm.h  |    2 -
 mm/memory.c         |   70 ++++++++++++++++++++++++++++++++--------------------
 3 files changed, 81 insertions(+), 45 deletions(-)

Index: mmotm-2.6.32-Nov2/arch/x86/mm/fault.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/arch/x86/mm/fault.c
+++ mmotm-2.6.32-Nov2/arch/x86/mm/fault.c
@@ -11,6 +11,7 @@
 #include <linux/kprobes.h>		/* __kprobes, ...		*/
 #include <linux/mmiotrace.h>		/* kmmio_handler, ...		*/
 #include <linux/perf_event.h>		/* perf_sw_event		*/
+#include <linux/hugetlb.h>		/* is_vm_hugetlbe_page()...     */
 
 #include <asm/traps.h>			/* dotraplinkage, ...		*/
 #include <asm/pgalloc.h>		/* pgd_*(), ...			*/
@@ -952,7 +953,8 @@ do_page_fault(struct pt_regs *regs, unsi
 	struct mm_struct *mm;
 	int write;
 	int fault;
-	int cachehit = 0;
+	int cachehit;
+	unsigned int key;
 
 	tsk = current;
 	mm = tsk->mm;
@@ -1057,6 +1059,18 @@ do_page_fault(struct pt_regs *regs, unsi
 	 * validate the source. If this is invalid we can skip the address
 	 * space check, thus avoiding the deadlock:
 	 */
+	 if ((error_code & PF_USER) &&
+	     (mm->generation == current->mm_generation) && current->vma_cache) {
+		vma = current->vma_cache;
+		if ((vma->vm_start <= address) && (address < vma->vm_end)) {
+			key = mm->generation;
+			cachehit = 1;
+			goto got_vma;
+		}
+	}
+speculative_fault_retry:
+	cachehit = 0;
+	vma = NULL;
 	if (unlikely(!mm_reader_trylock(mm))) {
 		if ((error_code & PF_USER) == 0 &&
 		    !search_exception_tables(regs->ip)) {
@@ -1072,13 +1086,9 @@ do_page_fault(struct pt_regs *regs, unsi
 		 */
 		might_sleep();
 	}
-	if ((mm->generation == current->mm_generation) && current->vma_cache) {
-		vma = current->vma_cache;
-		if ((vma->vm_start <= address) && (address < vma->vm_end))
-			cachehit = 1;
-	}
-	if (!cachehit)
-		vma = find_vma(mm, address);
+	key = mm->generation;
+	vma = find_vma(mm, address);
+got_vma:
 	if (unlikely(!vma)) {
 		bad_area(regs, error_code, address);
 		return;
@@ -1123,13 +1133,17 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault:
 	 */
-	fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
+	fault = handle_mm_fault(mm, vma, address,
+		write ? FAULT_FLAG_WRITE : 0, key);
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		mm_fault_error(regs, error_code, address, fault);
 		return;
 	}
 
+	if (mm->generation != key)
+		goto speculative_fault_retry;
+
 	if (fault & VM_FAULT_MAJOR) {
 		tsk->maj_flt++;
 		perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MAJ, 1, 0,
@@ -1139,16 +1153,20 @@ good_area:
 		perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MIN, 1, 0,
 				     regs, address);
 	}
-	/* cache information */
+	check_v8086_mode(regs, address, tsk);
+
 	if (!cachehit) {
-		if (current->vma_cache)
+		/* cache information if not hit. */
+		if (current->vma_cache) {
 			vma_put(current->vma_cache);
-		current->vma_cache = vma;
-		current->mm_generation = mm->generation;
-		vma_get(vma);
+			current->vma_cache = NULL;
+		}
+		if (!is_vm_hugetlb_page(vma) &&
+		    !((vma->vm_flags & VM_STACK_FLAGS) == VM_STACK_FLAGS)){
+			current->vma_cache = vma;
+			current->mm_generation = mm->generation;
+			vma_get(vma);
+		}
+		mm_reader_unlock(mm);
 	}
-
-	check_v8086_mode(regs, address, tsk);
-
-	mm_reader_unlock(mm);
 }
Index: mmotm-2.6.32-Nov2/include/linux/mm.h
===================================================================
--- mmotm-2.6.32-Nov2.orig/include/linux/mm.h
+++ mmotm-2.6.32-Nov2/include/linux/mm.h
@@ -803,7 +803,7 @@ int invalidate_inode_page(struct page *p
 
 #ifdef CONFIG_MMU
 extern int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long address, unsigned int flags);
+	unsigned long address, unsigned int flags, unsigned int key);
 #else
 static inline int handle_mm_fault(struct mm_struct *mm,
 			struct vm_area_struct *vma, unsigned long address,
Index: mmotm-2.6.32-Nov2/mm/memory.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/memory.c
+++ mmotm-2.6.32-Nov2/mm/memory.c
@@ -145,6 +145,13 @@ void pmd_clear_bad(pmd_t *pmd)
 	pmd_clear(pmd);
 }
 
+static int match_key(struct mm_struct *mm, unsigned int key)
+{
+	if (likely(key == mm->generation))
+		return 1;
+	return 0;
+}
+
 /*
  * Note: this doesn't free the actual pages themselves. That
  * has been handled earlier when unmapping all the memory regions.
@@ -1339,7 +1346,7 @@ int __get_user_pages(struct task_struct 
 
 				ret = handle_mm_fault(mm, vma, start,
 					(foll_flags & FOLL_WRITE) ?
-					FAULT_FLAG_WRITE : 0);
+					FAULT_FLAG_WRITE : 0, mm->generation);
 
 				if (ret & VM_FAULT_ERROR) {
 					if (ret & VM_FAULT_OOM)
@@ -2002,7 +2009,7 @@ static inline void cow_user_page(struct 
  */
 static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		spinlock_t *ptl, pte_t orig_pte)
+		spinlock_t *ptl, pte_t orig_pte, unsigned int key)
 {
 	struct page *old_page, *new_page;
 	pte_t entry;
@@ -2036,7 +2043,8 @@ static int do_wp_page(struct mm_struct *
 			lock_page(old_page);
 			page_table = pte_offset_map_lock(mm, pmd, address,
 							 &ptl);
-			if (!pte_same(*page_table, orig_pte)) {
+			if (!match_key(mm, key) ||
+				!pte_same(*page_table, orig_pte)) {
 				unlock_page(old_page);
 				page_cache_release(old_page);
 				goto unlock;
@@ -2097,7 +2105,8 @@ static int do_wp_page(struct mm_struct *
 			 */
 			page_table = pte_offset_map_lock(mm, pmd, address,
 							 &ptl);
-			if (!pte_same(*page_table, orig_pte)) {
+			if (!match_key(mm, key) ||
+				!pte_same(*page_table, orig_pte)) {
 				unlock_page(old_page);
 				page_cache_release(old_page);
 				goto unlock;
@@ -2160,7 +2169,8 @@ gotten:
 	 * Re-check the pte - we dropped the lock
 	 */
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (likely(pte_same(*page_table, orig_pte))) {
+	if (likely(match_key(mm, key) &&
+		   pte_same(*page_table, orig_pte))) {
 		if (old_page) {
 			if (!PageAnon(old_page)) {
 				dec_mm_counter(mm, file_rss);
@@ -2509,7 +2519,7 @@ int vmtruncate_range(struct inode *inode
  */
 static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		unsigned int flags, pte_t orig_pte)
+		unsigned int flags, pte_t orig_pte, unsigned int key)
 {
 	spinlock_t *ptl;
 	struct page *page;
@@ -2572,6 +2582,8 @@ static int do_swap_page(struct mm_struct
 	 * Back out if somebody else already faulted in this pte.
 	 */
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	if (!match_key(mm, key))
+		goto out_nomap;
 	if (unlikely(!pte_same(*page_table, orig_pte)))
 		goto out_nomap;
 
@@ -2612,7 +2624,8 @@ static int do_swap_page(struct mm_struct
 	unlock_page(page);
 
 	if (flags & FAULT_FLAG_WRITE) {
-		ret |= do_wp_page(mm, vma, address, page_table, pmd, ptl, pte);
+		ret |= do_wp_page(mm, vma, address, page_table,
+				pmd, ptl, pte, key);
 		if (ret & VM_FAULT_ERROR)
 			ret &= VM_FAULT_ERROR;
 		goto out;
@@ -2641,7 +2654,7 @@ out_release:
  */
 static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		unsigned int flags)
+		unsigned int flags, unsigned int key)
 {
 	struct page *page;
 	spinlock_t *ptl;
@@ -2652,7 +2665,7 @@ static int do_anonymous_page(struct mm_s
 						vma->vm_page_prot));
 		ptl = pte_lockptr(mm, pmd);
 		spin_lock(ptl);
-		if (!pte_none(*page_table))
+		if (!match_key(mm, key) || !pte_none(*page_table))
 			goto unlock;
 		goto setpte;
 	}
@@ -2675,7 +2688,7 @@ static int do_anonymous_page(struct mm_s
 		entry = pte_mkwrite(pte_mkdirty(entry));
 
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (!pte_none(*page_table))
+	if (!match_key(mm, key) || !pte_none(*page_table))
 		goto release;
 
 	inc_mm_counter(mm, anon_rss);
@@ -2712,8 +2725,8 @@ oom:
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
 static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pmd_t *pmd,
-		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
+		unsigned long address, pmd_t *pmd, pgoff_t pgoff,
+		unsigned int flags, pte_t orig_pte, unsigned int key)
 {
 	pte_t *page_table;
 	spinlock_t *ptl;
@@ -2826,7 +2839,8 @@ static int __do_fault(struct mm_struct *
 	 * handle that later.
 	 */
 	/* Only go through if we didn't race with anybody else... */
-	if (likely(pte_same(*page_table, orig_pte))) {
+	if (likely(match_key(mm, key) &&
+		pte_same(*page_table, orig_pte))) {
 		flush_icache_page(vma, page);
 		entry = mk_pte(page, vma->vm_page_prot);
 		if (flags & FAULT_FLAG_WRITE)
@@ -2891,13 +2905,14 @@ unwritable_page:
 
 static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		unsigned int flags, pte_t orig_pte)
+		unsigned int flags, pte_t orig_pte, unsigned int key)
 {
 	pgoff_t pgoff = (((address & PAGE_MASK)
 			- vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
 
 	pte_unmap(page_table);
-	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
+	return __do_fault(mm, vma, address, pmd, pgoff, flags,
+			orig_pte, key);
 }
 
 /*
@@ -2911,7 +2926,7 @@ static int do_linear_fault(struct mm_str
  */
 static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		unsigned int flags, pte_t orig_pte)
+		unsigned int flags, pte_t orig_pte, unsigned int key)
 {
 	pgoff_t pgoff;
 
@@ -2929,7 +2944,8 @@ static int do_nonlinear_fault(struct mm_
 	}
 
 	pgoff = pte_to_pgoff(orig_pte);
-	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
+	return __do_fault(mm, vma, address, pmd, pgoff,
+				flags, orig_pte, key);
 }
 
 /*
@@ -2946,8 +2962,8 @@ static int do_nonlinear_fault(struct mm_
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
 static inline int handle_pte_fault(struct mm_struct *mm,
-		struct vm_area_struct *vma, unsigned long address,
-		pte_t *pte, pmd_t *pmd, unsigned int flags)
+	struct vm_area_struct *vma, unsigned long address,
+	pte_t *pte, pmd_t *pmd, unsigned int flags, unsigned int key)
 {
 	pte_t entry;
 	spinlock_t *ptl;
@@ -2958,26 +2974,28 @@ static inline int handle_pte_fault(struc
 			if (vma->vm_ops) {
 				if (likely(vma->vm_ops->fault))
 					return do_linear_fault(mm, vma, address,
-						pte, pmd, flags, entry);
+					pte, pmd, flags, entry, key);
 			}
 			return do_anonymous_page(mm, vma, address,
-						 pte, pmd, flags);
+					 pte, pmd, flags, key);
 		}
 		if (pte_file(entry))
 			return do_nonlinear_fault(mm, vma, address,
-					pte, pmd, flags, entry);
+					pte, pmd, flags, entry, key);
 		return do_swap_page(mm, vma, address,
-					pte, pmd, flags, entry);
+				pte, pmd, flags, entry, key);
 	}
 
 	ptl = pte_lockptr(mm, pmd);
 	spin_lock(ptl);
+	if (!match_key(mm, key))
+		goto unlock;
 	if (unlikely(!pte_same(*pte, entry)))
 		goto unlock;
 	if (flags & FAULT_FLAG_WRITE) {
 		if (!pte_write(entry))
 			return do_wp_page(mm, vma, address,
-					pte, pmd, ptl, entry);
+					pte, pmd, ptl, entry, key);
 		entry = pte_mkdirty(entry);
 	}
 	entry = pte_mkyoung(entry);
@@ -3002,7 +3020,7 @@ unlock:
  * By the time we get here, we already hold the mm semaphore
  */
 int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, unsigned int flags)
+	unsigned long address, unsigned int flags, unsigned int key)
 {
 	pgd_t *pgd;
 	pud_t *pud;
@@ -3027,7 +3045,7 @@ int handle_mm_fault(struct mm_struct *mm
 	if (!pte)
 		return VM_FAULT_OOM;
 
-	return handle_pte_fault(mm, vma, address, pte, pmd, flags);
+	return handle_pte_fault(mm, vma, address, pte, pmd, flags, key);
 }
 
 #ifndef __PAGETABLE_PUD_FOLDED

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
