Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4C46B00FB
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 12:59:31 -0500 (EST)
Message-Id: <20110125174907.277206243@chello.nl>
Date: Tue, 25 Jan 2011 18:31:13 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 02/25] mm: Preemptible mmu_gather
References: <20110125173111.720927511@chello.nl>
Content-Disposition: inline; filename=peter_zijlstra-mm-preemptible_mmu_gather.patch
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Tony Luck <tony.luck@intel.com>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

Make mmu_gather preemptible by using a small on stack list and use
an option allocation to speed things up.

Preemptible mmu_gather is desired in general and usable once
i_mmap_lock becomes a mutex. Doing it before the mutex conversion
saves us from having to rework the code by moving the mmu_gather
bits inside the pte_lock.

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: David Miller <davem@davemloft.net>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Russell King <rmk@arm.linux.org.uk>
Cc: Paul Mundt <lethal@linux-sh.org>
Cc: Jeff Dike <jdike@addtoit.com>
Cc: Tony Luck <tony.luck@intel.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/exec.c                 |   10 ++++-----
 include/asm-generic/tlb.h |   51 +++++++++++++++++++++++++++++-----------------
 include/linux/mm.h        |    2 -
 mm/memory.c               |   27 +++++-------------------
 mm/mmap.c                 |   18 ++++++++--------
 5 files changed, 54 insertions(+), 54 deletions(-)

Index: linux-2.6/fs/exec.c
===================================================================
--- linux-2.6.orig/fs/exec.c
+++ linux-2.6/fs/exec.c
@@ -550,7 +550,7 @@ static int shift_arg_pages(struct vm_are
 	unsigned long length = old_end - old_start;
 	unsigned long new_start = old_start - shift;
 	unsigned long new_end = old_end - shift;
-	struct mmu_gather *tlb;
+	struct mmu_gather tlb;
 
 	BUG_ON(new_start > new_end);
 
@@ -576,12 +576,12 @@ static int shift_arg_pages(struct vm_are
 		return -ENOMEM;
 
 	lru_add_drain();
-	tlb = tlb_gather_mmu(mm, 0);
+	tlb_gather_mmu(&tlb, mm, 0);
 	if (new_end > old_start) {
 		/*
 		 * when the old and new regions overlap clear from new_end.
 		 */
-		free_pgd_range(tlb, new_end, old_end, new_end,
+		free_pgd_range(&tlb, new_end, old_end, new_end,
 			vma->vm_next ? vma->vm_next->vm_start : 0);
 	} else {
 		/*
@@ -590,10 +590,10 @@ static int shift_arg_pages(struct vm_are
 		 * have constraints on va-space that make this illegal (IA64) -
 		 * for the others its just a little faster.
 		 */
-		free_pgd_range(tlb, old_start, old_end, new_end,
+		free_pgd_range(&tlb, old_start, old_end, new_end,
 			vma->vm_next ? vma->vm_next->vm_start : 0);
 	}
-	tlb_finish_mmu(tlb, new_end, old_end);
+	tlb_finish_mmu(&tlb, new_end, old_end);
 
 	/*
 	 * Shrink the vma to just the new range.  Always succeeds.
Index: linux-2.6/include/asm-generic/tlb.h
===================================================================
--- linux-2.6.orig/include/asm-generic/tlb.h
+++ linux-2.6/include/asm-generic/tlb.h
@@ -22,14 +22,8 @@
  * and page free order so much..
  */
 #ifdef CONFIG_SMP
-  #ifdef ARCH_FREE_PTR_NR
-    #define FREE_PTR_NR   ARCH_FREE_PTR_NR
-  #else
-    #define FREE_PTE_NR	506
-  #endif
   #define tlb_fast_mode(tlb) ((tlb)->nr == ~0U)
 #else
-  #define FREE_PTE_NR	1
   #define tlb_fast_mode(tlb) 1
 #endif
 
@@ -39,30 +33,48 @@
 struct mmu_gather {
 	struct mm_struct	*mm;
 	unsigned int		nr;	/* set to ~0U means fast mode */
+	unsigned int		max;	/* nr < max */
 	unsigned int		need_flush;/* Really unmapped some ptes? */
 	unsigned int		fullmm; /* non-zero means full mm flush */
-	struct page *		pages[FREE_PTE_NR];
+#ifdef HAVE_ARCH_MMU_GATHER
+	struct arch_mmu_gather	arch;
+#endif
+	struct page		**pages;
+	struct page		*local[8];
 };
 
-/* Users of the generic TLB shootdown code must declare this storage space. */
-DECLARE_PER_CPU(struct mmu_gather, mmu_gathers);
+static inline void __tlb_alloc_page(struct mmu_gather *tlb)
+{
+	unsigned long addr = __get_free_pages(GFP_NOWAIT | __GFP_NOWARN, 0);
+
+	if (addr) {
+		tlb->pages = (void *)addr;
+		tlb->max = PAGE_SIZE / sizeof(struct page *);
+	}
+}
 
 /* tlb_gather_mmu
  *	Return a pointer to an initialized struct mmu_gather.
  */
-static inline struct mmu_gather *
-tlb_gather_mmu(struct mm_struct *mm, unsigned int full_mm_flush)
+static inline void
+tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned int full_mm_flush)
 {
-	struct mmu_gather *tlb = &get_cpu_var(mmu_gathers);
-
 	tlb->mm = mm;
 
-	/* Use fast mode if only one CPU is online */
-	tlb->nr = num_online_cpus() > 1 ? 0U : ~0U;
+	tlb->max = ARRAY_SIZE(tlb->local);
+	tlb->pages = tlb->local;
+
+	if (num_online_cpus() > 1) {
+		tlb->nr = 0;
+		__tlb_alloc_page(tlb);
+	} else /* Use fast mode if only one CPU is online */
+		tlb->nr = ~0U;
 
 	tlb->fullmm = full_mm_flush;
 
-	return tlb;
+#ifdef HAVE_ARCH_MMU_GATHER
+	tlb->arch = ARCH_MMU_GATHER_INIT;
+#endif
 }
 
 static inline void
@@ -75,6 +87,8 @@ tlb_flush_mmu(struct mmu_gather *tlb, un
 	if (!tlb_fast_mode(tlb)) {
 		free_pages_and_swap_cache(tlb->pages, tlb->nr);
 		tlb->nr = 0;
+		if (tlb->pages == tlb->local)
+			__tlb_alloc_page(tlb);
 	}
 }
 
@@ -90,7 +104,8 @@ tlb_finish_mmu(struct mmu_gather *tlb, u
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
 
-	put_cpu_var(mmu_gathers);
+	if (tlb->pages != tlb->local)
+		free_pages((unsigned long)tlb->pages, 0);
 }
 
 /* tlb_remove_page
@@ -106,7 +121,7 @@ static inline void tlb_remove_page(struc
 		return;
 	}
 	tlb->pages[tlb->nr++] = page;
-	if (tlb->nr >= FREE_PTE_NR)
+	if (tlb->nr >= tlb->max)
 		tlb_flush_mmu(tlb, 0, 0);
 }
 
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -887,7 +887,7 @@ int zap_vma_ptes(struct vm_area_struct *
 		unsigned long size);
 unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size, struct zap_details *);
-unsigned long unmap_vmas(struct mmu_gather **tlb,
+unsigned long unmap_vmas(struct mmu_gather *tlb,
 		struct vm_area_struct *start_vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *);
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -1121,17 +1121,14 @@ static unsigned long unmap_page_range(st
  * ensure that any thus-far unmapped pages are flushed before unmap_vmas()
  * drops the lock and schedules.
  */
-unsigned long unmap_vmas(struct mmu_gather **tlbp,
+unsigned long unmap_vmas(struct mmu_gather *tlb,
 		struct vm_area_struct *vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *details)
 {
 	long zap_work = ZAP_BLOCK_SIZE;
-	unsigned long tlb_start = 0;	/* For tlb_finish_mmu */
-	int tlb_start_valid = 0;
 	unsigned long start = start_addr;
 	spinlock_t *i_mmap_lock = details? details->i_mmap_lock: NULL;
-	int fullmm = (*tlbp)->fullmm;
 	struct mm_struct *mm = vma->vm_mm;
 
 	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
@@ -1152,11 +1149,6 @@ unsigned long unmap_vmas(struct mmu_gath
 			untrack_pfn_vma(vma, 0, 0);
 
 		while (start != end) {
-			if (!tlb_start_valid) {
-				tlb_start = start;
-				tlb_start_valid = 1;
-			}
-
 			if (unlikely(is_vm_hugetlb_page(vma))) {
 				/*
 				 * It is undesirable to test vma->vm_file as it
@@ -1177,7 +1169,7 @@ unsigned long unmap_vmas(struct mmu_gath
 
 				start = end;
 			} else
-				start = unmap_page_range(*tlbp, vma,
+				start = unmap_page_range(tlb, vma,
 						start, end, &zap_work, details);
 
 			if (zap_work > 0) {
@@ -1185,19 +1177,13 @@ unsigned long unmap_vmas(struct mmu_gath
 				break;
 			}
 
-			tlb_finish_mmu(*tlbp, tlb_start, start);
-
 			if (need_resched() ||
 				(i_mmap_lock && spin_needbreak(i_mmap_lock))) {
-				if (i_mmap_lock) {
-					*tlbp = NULL;
+				if (i_mmap_lock)
 					goto out;
-				}
 				cond_resched();
 			}
 
-			*tlbp = tlb_gather_mmu(vma->vm_mm, fullmm);
-			tlb_start_valid = 0;
 			zap_work = ZAP_BLOCK_SIZE;
 		}
 	}
@@ -1217,16 +1203,15 @@ unsigned long zap_page_range(struct vm_a
 		unsigned long size, struct zap_details *details)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	struct mmu_gather *tlb;
+	struct mmu_gather tlb;
 	unsigned long end = address + size;
 	unsigned long nr_accounted = 0;
 
 	lru_add_drain();
-	tlb = tlb_gather_mmu(mm, 0);
+	tlb_gather_mmu(&tlb, mm, 0);
 	update_hiwater_rss(mm);
 	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
-	if (tlb)
-		tlb_finish_mmu(tlb, address, end);
+	tlb_finish_mmu(&tlb, address, end);
 	return end;
 }
 
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c
+++ linux-2.6/mm/mmap.c
@@ -1913,17 +1913,17 @@ static void unmap_region(struct mm_struc
 		unsigned long start, unsigned long end)
 {
 	struct vm_area_struct *next = prev? prev->vm_next: mm->mmap;
-	struct mmu_gather *tlb;
+	struct mmu_gather tlb;
 	unsigned long nr_accounted = 0;
 
 	lru_add_drain();
-	tlb = tlb_gather_mmu(mm, 0);
+	tlb_gather_mmu(&tlb, mm, 0);
 	update_hiwater_rss(mm);
 	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
-	free_pgtables(tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
-				 next? next->vm_start: 0);
-	tlb_finish_mmu(tlb, start, end);
+	free_pgtables(&tlb, vma, prev ? prev->vm_end : FIRST_USER_ADDRESS,
+				 next ? next->vm_start : 0);
+	tlb_finish_mmu(&tlb, start, end);
 }
 
 /*
@@ -2265,7 +2265,7 @@ EXPORT_SYMBOL(do_brk);
 /* Release all mmaps. */
 void exit_mmap(struct mm_struct *mm)
 {
-	struct mmu_gather *tlb;
+	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
 	unsigned long nr_accounted = 0;
 	unsigned long end;
@@ -2290,14 +2290,14 @@ void exit_mmap(struct mm_struct *mm)
 
 	lru_add_drain();
 	flush_cache_mm(mm);
-	tlb = tlb_gather_mmu(mm, 1);
+	tlb_gather_mmu(&tlb, mm, 1);
 	/* update_hiwater_rss(mm) here? but nobody should be looking */
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
 
-	free_pgtables(tlb, vma, FIRST_USER_ADDRESS, 0);
-	tlb_finish_mmu(tlb, 0, end);
+	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, 0);
+	tlb_finish_mmu(&tlb, 0, end);
 
 	/*
 	 * Walk the list again, actually closing and freeing it,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
