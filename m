Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 315B15F0001
	for <linux-mm@kvack.org>; Mon, 13 Apr 2009 15:45:21 -0400 (EDT)
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id n3DJk1Ru008534
	for <linux-mm@kvack.org>; Mon, 13 Apr 2009 12:46:02 -0700
Received: from wf-out-1314.google.com (wfd27.prod.google.com [10.142.4.27])
	by spaceape9.eur.corp.google.com with ESMTP id n3DJjgn8012911
	for <linux-mm@kvack.org>; Mon, 13 Apr 2009 12:46:00 -0700
Received: by wf-out-1314.google.com with SMTP id 27so2054086wfd.1
        for <linux-mm@kvack.org>; Mon, 13 Apr 2009 12:45:59 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 13 Apr 2009 12:45:59 -0700
Message-ID: <604427e00904131245r1125eadapc4f526ac42cf68a@mail.gmail.com>
Subject: [V4][PATCH 1/4]Remove internal use of 'write_access' in mm/memory.c
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, akpm <akpm@linux-foundation.org>, torvalds@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>, =?ISO-8859-1?Q?T=F6r=F6k_Edwin?= <edwintorok@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

Remove internal use of 'write_access' in mm/memory.c

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
Signed-off-by: Ying Han <yinghan@google.com>
---

 include/linux/hugetlb.h |    2 +-
 mm/hugetlb.c            |   12 +++++++-----
 mm/memory.c             |   43 ++++++++++++++++++++++---------------------
 3 files changed, 30 insertions(+), 27 deletions(-)


diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 03be7f2..ef873ef 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -31,7 +31,7 @@ void hugetlb_report_meminfo(struct seq_file *);
 int hugetlb_report_node_meminfo(int, char *);
 unsigned long hugetlb_total_pages(void);
 int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long address, int write_access);
+			unsigned long address, unsigned int flags);
 int hugetlb_reserve_pages(struct inode *inode, long from, long to,
 						struct vm_area_struct *vma,
 						int acctflags);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 107da3d..12f6ca4 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2063,7 +2063,7 @@ backout_unlocked:
 }

 int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long address, int write_access)
+			unsigned long address, unsigned int flags)
 {
 	pte_t *ptep;
 	pte_t entry;
@@ -2084,7 +2084,8 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_str
 	mutex_lock(&hugetlb_instantiation_mutex);
 	entry = huge_ptep_get(ptep);
 	if (huge_pte_none(entry)) {
-		ret = hugetlb_no_page(mm, vma, address, ptep, write_access);
+		ret = hugetlb_no_page(mm, vma, address, ptep,
+				flags & FAULT_FLAG_WRITE);
 		goto out_mutex;
 	}

@@ -2098,7 +2099,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_str
 	 * page now as it is used to determine if a reservation has been
 	 * consumed.
 	 */
-	if (write_access && !pte_write(entry)) {
+	if ((flags & FAULT_FLAG_WRITE) && !pte_write(entry)) {
 		if (vma_needs_reservation(h, vma, address) < 0) {
 			ret = VM_FAULT_OOM;
 			goto out_mutex;
@@ -2115,7 +2116,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_str
 		goto out_page_table_lock;


-	if (write_access) {
+	if (flags & FAULT_FLAG_WRITE) {
 		if (!pte_write(entry)) {
 			ret = hugetlb_cow(mm, vma, address, ptep, entry,
 							pagecache_page);
@@ -2124,7 +2125,8 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_str
 		entry = pte_mkdirty(entry);
 	}
 	entry = pte_mkyoung(entry);
-	if (huge_ptep_set_access_flags(vma, address, ptep, entry, write_access))
+	if (huge_ptep_set_access_flags(vma, address, ptep, entry,
+				flags & FAULT_FLAG_WRITE))
 		update_mmu_cache(vma, address, entry);

 out_page_table_lock:
diff --git a/mm/memory.c b/mm/memory.c
index baa999e..bfecdfb 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2393,7 +2393,7 @@ int vmtruncate_range(struct inode *inode, loff_t offset, l
  */
 static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		int write_access, pte_t orig_pte)
+		unsigned int flags, pte_t orig_pte)
 {
 	spinlock_t *ptl;
 	struct page *page;
@@ -2472,9 +2472,9 @@ static int do_swap_page(struct mm_struct *mm, struct vm_ar

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
@@ -2487,7 +2487,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_ar
 		try_to_free_swap(page);
 	unlock_page(page);

-	if (write_access) {
+	if (flags & FAULT_FLAG_WRITE) {
 		ret |= do_wp_page(mm, vma, address, page_table, pmd, ptl, pte);
 		if (ret & VM_FAULT_ERROR)
 			ret &= VM_FAULT_ERROR;
@@ -2515,7 +2515,7 @@ out_nomap:
  */
 static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		int write_access)
+		unsigned int flags)
 {
 	struct page *page;
 	spinlock_t *ptl;
@@ -2675,7 +2675,7 @@ static int __do_fault(struct mm_struct *mm, struct vm_area
 	 * due to the bad i386 page protection. But it's valid
 	 * for other architectures too.
 	 *
-	 * Note that if write_access is true, we either now have
+	 * Note that if FAULT_FLAG_WRITE is set, we either now have
 	 * an exclusive copy of the page, or this is a shared mapping,
 	 * so we can make it writable and dirty to avoid having to
 	 * handle that later.
@@ -2730,11 +2730,10 @@ out_unlocked:

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
@@ -2751,12 +2750,12 @@ static int do_linear_fault(struct mm_struct *mm, struct
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

@@ -2787,7 +2786,7 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct
  */
 static inline int handle_pte_fault(struct mm_struct *mm,
 		struct vm_area_struct *vma, unsigned long address,
-		pte_t *pte, pmd_t *pmd, int write_access)
+		pte_t *pte, pmd_t *pmd, unsigned int flags)
 {
 	pte_t entry;
 	spinlock_t *ptl;
@@ -2798,30 +2797,31 @@ static inline int handle_pte_fault(struct mm_struct *mm,
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
+	if (ptep_set_access_flags(vma, address, pte, entry,
+				flags & FAULT_FLAG_WRITE)) {
 		update_mmu_cache(vma, address, entry);
 	} else {
 		/*
@@ -2830,7 +2830,7 @@ static inline int handle_pte_fault(struct mm_struct *mm,
 		 * This still avoids useless tlb flushes for .text page faults
 		 * with threads.
 		 */
-		if (write_access)
+		if (flags & FAULT_FLAG_WRITE)
 			flush_tlb_page(vma, address);
 	}
 unlock:
@@ -2848,13 +2848,14 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area
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
@@ -2867,7 +2868,7 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_s
 	if (!pte)
 		return VM_FAULT_OOM;

-	return handle_pte_fault(mm, vma, address, pte, pmd, write_access);
+	return handle_pte_fault(mm, vma, address, pte, pmd, flags);
 }

 #ifndef __PAGETABLE_PUD_FOLDED

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
