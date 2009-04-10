Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 655A95F0001
	for <linux-mm@kvack.org>; Fri, 10 Apr 2009 12:12:39 -0400 (EDT)
Date: Fri, 10 Apr 2009 09:04:16 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: [PATCH 1/2] Remove internal use of 'write_access' in mm/memory.c
In-Reply-To: <alpine.LFD.2.00.0904100835150.4583@localhost.localdomain>
Message-ID: <alpine.LFD.2.00.0904100903470.4583@localhost.localdomain>
References: <604427e00904081302m7b29c538u7781cd8f4dd576f2@mail.gmail.com> <20090409230205.310c68a7.akpm@linux-foundation.org> <20090410073042.GB21149@localhost> <alpine.LFD.2.00.0904100835150.4583@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>, =?ISO-8859-15?Q?T=F6r=F6k_Edwin?= <edwintorok@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>


From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 10 Apr 2009 08:43:11 -0700

The fault handling routines really want more fine-grained flags than a
single "was it a write fault" boolean - the callers will want to set
flags like "you can return a retry error" etc.

And that's actually how the VM works internally, but right now the
top-level fault handling functions in mm/memory.c all pass just the
'write_access' boolean around.

This switches them over to pass around the FAULT_FLAG_xyzzy 'flags'
variable instead.  The 'write_access' calling convention still exists
for the exported 'handle_mm_fault()' function, but that is next.

Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
---
 mm/memory.c |   42 +++++++++++++++++++++---------------------
 1 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index cf6873e..9050bae 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2413,7 +2413,7 @@ int vmtruncate_range(struct inode *inode, loff_t offset, loff_t end)
  */
 static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		int write_access, pte_t orig_pte)
+		unsigned int flags, pte_t orig_pte)
 {
 	spinlock_t *ptl;
 	struct page *page;
@@ -2490,9 +2490,9 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	inc_mm_counter(mm, anon_rss);
 	pte = mk_pte(page, vma->vm_page_prot);
-	if (write_access && reuse_swap_page(page)) {
+	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
-		write_access = 0;
+		flags &= ~FAULT_FLAG_WRITE;
 	}
 	flush_icache_page(vma, page);
 	set_pte_at(mm, address, page_table, pte);
@@ -2505,7 +2505,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		try_to_free_swap(page);
 	unlock_page(page);
 
-	if (write_access) {
+	if (flags & FAULT_FLAG_WRITE) {
 		ret |= do_wp_page(mm, vma, address, page_table, pmd, ptl, pte);
 		if (ret & VM_FAULT_ERROR)
 			ret &= VM_FAULT_ERROR;
@@ -2533,7 +2533,7 @@ out_nomap:
  */
 static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		int write_access)
+		unsigned int flags)
 {
 	struct page *page;
 	spinlock_t *ptl;
@@ -2698,7 +2698,7 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * due to the bad i386 page protection. But it's valid
 	 * for other architectures too.
 	 *
-	 * Note that if write_access is true, we either now have
+	 * Note that if FAULT_FLAG_WRITE is set, we either now have
 	 * an exclusive copy of the page, or this is a shared mapping,
 	 * so we can make it writable and dirty to avoid having to
 	 * handle that later.
@@ -2753,11 +2753,10 @@ out_unlocked:
 
 static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		int write_access, pte_t orig_pte)
+		unsigned int flags, pte_t orig_pte)
 {
 	pgoff_t pgoff = (((address & PAGE_MASK)
 			- vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
-	unsigned int flags = (write_access ? FAULT_FLAG_WRITE : 0);
 
 	pte_unmap(page_table);
 	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
@@ -2774,12 +2773,12 @@ static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
  */
 static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		int write_access, pte_t orig_pte)
+		unsigned int flags, pte_t orig_pte)
 {
-	unsigned int flags = FAULT_FLAG_NONLINEAR |
-				(write_access ? FAULT_FLAG_WRITE : 0);
 	pgoff_t pgoff;
 
+	flags |= FAULT_FLAG_NONLINEAR;
+
 	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
 		return 0;
 
@@ -2810,7 +2809,7 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
  */
 static inline int handle_pte_fault(struct mm_struct *mm,
 		struct vm_area_struct *vma, unsigned long address,
-		pte_t *pte, pmd_t *pmd, int write_access)
+		pte_t *pte, pmd_t *pmd, unsigned int flags)
 {
 	pte_t entry;
 	spinlock_t *ptl;
@@ -2821,30 +2820,30 @@ static inline int handle_pte_fault(struct mm_struct *mm,
 			if (vma->vm_ops) {
 				if (likely(vma->vm_ops->fault))
 					return do_linear_fault(mm, vma, address,
-						pte, pmd, write_access, entry);
+						pte, pmd, flags, entry);
 			}
 			return do_anonymous_page(mm, vma, address,
-						 pte, pmd, write_access);
+						 pte, pmd, flags);
 		}
 		if (pte_file(entry))
 			return do_nonlinear_fault(mm, vma, address,
-					pte, pmd, write_access, entry);
+					pte, pmd, flags, entry);
 		return do_swap_page(mm, vma, address,
-					pte, pmd, write_access, entry);
+					pte, pmd, flags, entry);
 	}
 
 	ptl = pte_lockptr(mm, pmd);
 	spin_lock(ptl);
 	if (unlikely(!pte_same(*pte, entry)))
 		goto unlock;
-	if (write_access) {
+	if (flags & FAULT_FLAG_WRITE) {
 		if (!pte_write(entry))
 			return do_wp_page(mm, vma, address,
 					pte, pmd, ptl, entry);
 		entry = pte_mkdirty(entry);
 	}
 	entry = pte_mkyoung(entry);
-	if (ptep_set_access_flags(vma, address, pte, entry, write_access)) {
+	if (ptep_set_access_flags(vma, address, pte, entry, flags & FAULT_FLAG_WRITE)) {
 		update_mmu_cache(vma, address, entry);
 	} else {
 		/*
@@ -2853,7 +2852,7 @@ static inline int handle_pte_fault(struct mm_struct *mm,
 		 * This still avoids useless tlb flushes for .text page faults
 		 * with threads.
 		 */
-		if (write_access)
+		if (flags & FAULT_FLAG_WRITE)
 			flush_tlb_page(vma, address);
 	}
 unlock:
@@ -2871,13 +2870,14 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
+	unsigned int flags = write_access ? FAULT_FLAG_WRITE : 0;
 
 	__set_current_state(TASK_RUNNING);
 
 	count_vm_event(PGFAULT);
 
 	if (unlikely(is_vm_hugetlb_page(vma)))
-		return hugetlb_fault(mm, vma, address, write_access);
+		return hugetlb_fault(mm, vma, address, flags);
 
 	pgd = pgd_offset(mm, address);
 	pud = pud_alloc(mm, pgd, address);
@@ -2890,7 +2890,7 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (!pte)
 		return VM_FAULT_OOM;
 
-	return handle_pte_fault(mm, vma, address, pte, pmd, write_access);
+	return handle_pte_fault(mm, vma, address, pte, pmd, flags);
 }
 
 #ifndef __PAGETABLE_PUD_FOLDED
-- 
1.6.2.2.471.g6da14.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
