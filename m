Received: from [127.0.0.1] (localhost.localdomain [127.0.0.1])
	by gate.crashing.org (8.13.8/8.13.8) with ESMTP id l6Q8HtWs011273
	for <linux-mm@kvack.org>; Thu, 26 Jul 2007 03:17:56 -0500
Subject: WIP: mmu_gather work
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Type: text/plain
Date: Thu, 26 Jul 2007 18:17:54 +1000
Message-Id: <1185437874.5495.66.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Still a lot to do, it's a fairly trivial and incomplete patch right now,
you people can start flaming me for the direction I'm going to
already :-)

Here's a simple first cut at what I call "step 1" on the mmu_gather
rework. Before you look at the patch, here are some random notes about
it and where it's going

 - I kept the page list per-cpu for now. There are non trivial issues
with doing differently, the "smart" idea of trying to steal one of the
pages being freed for example doesn't work well in practice with
HIGHMEM, etc... so let's break one thing at a time and keep it that way

 - The page list is only 'attached' to the batch (and thus, preempt
diabled by a get_cpu_var()) when you start adding freed pages to it and
is detached as soon as you flush. That removes the need to
finish/restart the batch when doing lock breaking, it's enough to just
flush it to be able to schedule. That simplifies the code path all over
mm/memory.c and avoids passing double indirections around. That also
means that on arch that don't the page free batching for PTE pages,
preemption will no longer be disabled in free_pgtables(). I added a
need_resched() test there too while at it.

 - I've only touched powerpc, i386 and x86_64 (and minor bits of other
archs but unfinished yet) and only tested ppc64 (and not yet re-adapted
it's own batching system to use the generic code yet) and compile tested
i386. This is all very rough at the moment and there are known issues
with other archs. Also, you'll notice that hackish macro I added for
archs to add things to the batch structure. It's a bit ugly, I will try
to do something nicer when I get to the real users of this, which are
sparc64 and ia64.

 - sparc64. This one relies on the per-cpuness of the batch heavily for
TLB invalidations a bit like ppc64 used to do. ppc64 does things a bit
differently now but I may change it again in the future, so it's all a
bit in flux, depending on where I end up with this rework of the
mmu_gather. At this point, I started hacking together something for
sparc64 but figured I was missing some data about how things work in
there and that I was on a wrong track anyway. I'll have another look
tomorrow hopefully.

 - ia64. That one isn't done yet neither. My main issue here is that I
really really really want to get rid of the start/end arguments of
tlb_finish_mmu() but ia64 seems to want it for reasons I haven't totally
figured out just yet. I suspect it has to do with the flushing of the
virtual page tables but I'll need some input there too. The ia64 batch
structure attempts to keep track of the start/end by itself, but doesn't
actually use those values in ia64_tlb_flush_mmu() with a a comment that
I don't fully grok about "nr" being 0. I wonder if the issue is related
to the virtual page tables flushing and whether we could solve it by
keeping track via pte_free_tlb() instead. It would be easy to add addr
arguments to it.

 - I still think we can do more cleanup of unmap_vmas (possibly around
the lines of Hugh's earlier patch). To be looked at. In any case, that's
matter for a separate patch. We may want to rethink the zap work thingy.
Especially if we move over to a non-per-cpu page list.

 - I haven't hooked up fork, mprotect etc... to it yet, same thing:
separate patch

Hrm... nothign else comes up right now, but heh. I'll do all the trivial
archs tomorrow if I don't get too distracted by other things and then
we'll have a look at ia64 and sparc64 (or the other way around if I find
inspiration during the night).

Index: linux-work/include/asm-generic/tlb.h
===================================================================
--- linux-work.orig/include/asm-generic/tlb.h	2007-07-26 16:43:50.000000000 +1000
+++ linux-work/include/asm-generic/tlb.h	2007-07-26 16:57:11.000000000 +1000
@@ -33,48 +33,72 @@
   #define tlb_fast_mode(tlb) 1
 #endif
 
+/* arch may add fields to mmu_gather */
+#ifndef mmu_gather_arch_fields
+#define mmu_gather_arch_fields
+#define tlb_arch_init(tlb)		do { } while(0)
+#define tlb_arch_finish(tlb)		do { } while(0)
+#endif
+
 /* struct mmu_gather is an opaque type used by the mm code for passing around
  * any data needed by arch specific code for tlb_remove_page.
  */
 struct mmu_gather {
 	struct mm_struct	*mm;
+	unsigned int		mode;
+	unsigned int		need_flush;/* Really changed some ptes? */
 	unsigned int		nr;	/* set to ~0U means fast mode */
-	unsigned int		need_flush;/* Really unmapped some ptes? */
-	unsigned int		fullmm; /* non-zero means full mm flush */
+	mmu_gather_arch_fields
+	struct page **		pages;
+};
+
+/* per-cpu page list storage for an mmu_gather */
+struct mmu_gather_store {
 	struct page *		pages[FREE_PTE_NR];
 };
 
 /* Users of the generic TLB shootdown code must declare this storage space. */
-DECLARE_PER_CPU(struct mmu_gather, mmu_gathers);
+DECLARE_PER_CPU(struct mmu_gather_store, mmu_gather_store);
+
+/* Some flags, not all used at this stage though */
+#define TLB_MODE_FREE_PAGES	0x01	/* may free page */
+#define TLB_MODE_FREE_PGTABLES	0x02	/* may free page tables */
+#define TLB_MODE_IMMAP_LOCK	0x04	/* i_mmap_lock held */
+#define TLB_MODE_FULL		0x08	/* entire mm is flushed (exit) */
+#define TLB_MODE_COPY		0x10	/* mm is duplicated R/O (fork) */
+
 
 /* tlb_gather_mmu
  *	Return a pointer to an initialized struct mmu_gather.
  */
-static inline struct mmu_gather *
-tlb_gather_mmu(struct mm_struct *mm, unsigned int full_mm_flush)
+static inline void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
+				  unsigned int mode)
 {
-	struct mmu_gather *tlb = &get_cpu_var(mmu_gathers);
-
 	tlb->mm = mm;
+	tlb->mode = mode;
+	tlb->need_flush = 0;
+	tlb->pages = NULL;
 
 	/* Use fast mode if only one CPU is online */
 	tlb->nr = num_online_cpus() > 1 ? 0U : ~0U;
 
-	tlb->fullmm = full_mm_flush;
-
-	return tlb;
+	tlb_arch_init(tlb);
 }
 
-static inline void
-tlb_flush_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
+/* tlb_flush_mmu
+ *	Call at any time the pending TLB needs to be flushed
+ */
+static inline void tlb_flush_mmu(struct mmu_gather *tlb)
 {
 	if (!tlb->need_flush)
 		return;
 	tlb->need_flush = 0;
 	tlb_flush(tlb);
-	if (!tlb_fast_mode(tlb)) {
+	if (!tlb_fast_mode(tlb) && tlb->pages) {
 		free_pages_and_swap_cache(tlb->pages, tlb->nr);
+		put_cpu_var(mmu_gather_store);
 		tlb->nr = 0;
+		tlb->pages = NULL;
 	}
 }
 
@@ -82,17 +106,42 @@ tlb_flush_mmu(struct mmu_gather *tlb, un
  *	Called at the end of the shootdown operation to free up any resources
  *	that were required.
  */
-static inline void
-tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
+static inline void tlb_finish_mmu(struct mmu_gather *tlb)
 {
-	tlb_flush_mmu(tlb, start, end);
+	tlb_flush_mmu(tlb);
 
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
 
-	put_cpu_var(mmu_gathers);
+	tlb_arch_finish(tlb);
 }
 
+/* tlb_pte_lock_break
+ *	To be implemented by architectures that need to do something special
+ *	before the PTE lock is released
+ */
+#ifndef tlb_pte_lock_break
+static inline void tlb_pte_lock_break(struct mmu_gather *tlb) { }
+#endif
+
+/* tlb_start_vma
+ *	To be implemented by architectures that need to do something special
+ *	before starting to flush a VMA
+ */
+#ifndef tlb_start_vma
+static inline void tlb_start_vma(struct mmu_gather *tlb,
+				 struct vm_area_struct *vma) { }
+#endif
+
+/* tlb_end_vma
+ *	To be implemented by architectures that need to do something special
+ *	after finishing to flush a VMA
+ */
+#ifndef tlb_end_vma
+static inline void tlb_end_vma(struct mmu_gather *tlb,
+			       struct vm_area_struct *vma) { }
+#endif
+
 /* tlb_remove_page
  *	Must perform the equivalent to __free_pte(pte_get_and_clear(ptep)), while
  *	handling the additional races in SMP caused by other CPUs caching valid
@@ -105,9 +154,12 @@ static inline void tlb_remove_page(struc
 		free_page_and_swap_cache(page);
 		return;
 	}
+	/* Need to get pages ? */
+	if (!tlb->pages)
+		tlb->pages = get_cpu_var(mmu_gather_store).pages;
 	tlb->pages[tlb->nr++] = page;
 	if (tlb->nr >= FREE_PTE_NR)
-		tlb_flush_mmu(tlb, 0, 0);
+		tlb_flush_mmu(tlb);
 }
 
 /**
Index: linux-work/arch/powerpc/mm/tlb_64.c
===================================================================
--- linux-work.orig/arch/powerpc/mm/tlb_64.c	2007-07-26 16:43:50.000000000 +1000
+++ linux-work/arch/powerpc/mm/tlb_64.c	2007-07-26 16:44:31.000000000 +1000
@@ -36,7 +36,7 @@ DEFINE_PER_CPU(struct ppc64_tlb_batch, p
 /* This is declared as we are using the more or less generic
  * include/asm-powerpc/tlb.h file -- tgall
  */
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
+DEFINE_PER_CPU(struct mmu_gather_store, mmu_gather_store);
 DEFINE_PER_CPU(struct pte_freelist_batch *, pte_freelist_cur);
 unsigned long pte_freelist_forced_free;
 
Index: linux-work/include/asm-powerpc/tlb.h
===================================================================
--- linux-work.orig/include/asm-powerpc/tlb.h	2007-07-26 16:43:50.000000000 +1000
+++ linux-work/include/asm-powerpc/tlb.h	2007-07-26 16:44:31.000000000 +1000
@@ -25,9 +25,6 @@
 
 struct mmu_gather;
 
-#define tlb_start_vma(tlb, vma)	do { } while (0)
-#define tlb_end_vma(tlb, vma)	do { } while (0)
-
 #if !defined(CONFIG_PPC_STD_MMU)
 
 #define tlb_flush(tlb)			flush_tlb_mm((tlb)->mm)
Index: linux-work/mm/memory.c
===================================================================
--- linux-work.orig/mm/memory.c	2007-07-26 16:43:50.000000000 +1000
+++ linux-work/mm/memory.c	2007-07-26 16:44:31.000000000 +1000
@@ -201,7 +201,7 @@ static inline void free_pud_range(struct
  *
  * Must be called with pagetable lock held.
  */
-void free_pgd_range(struct mmu_gather **tlb,
+void free_pgd_range(struct mmu_gather *tlb,
 			unsigned long addr, unsigned long end,
 			unsigned long floor, unsigned long ceiling)
 {
@@ -252,20 +252,21 @@ void free_pgd_range(struct mmu_gather **
 		return;
 
 	start = addr;
-	pgd = pgd_offset((*tlb)->mm, addr);
+	pgd = pgd_offset(tlb->mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd))
 			continue;
-		free_pud_range(*tlb, pgd, addr, next, floor, ceiling);
+		free_pud_range(tlb, pgd, addr, next, floor, ceiling);
 	} while (pgd++, addr = next, addr != end);
 
-	if (!(*tlb)->fullmm)
-		flush_tlb_pgtables((*tlb)->mm, start, end);
+	/* That API could/should be moved elsewhere and cleaned up */
+	if (!(tlb->mode & TLB_MODE_FULL))
+		flush_tlb_pgtables(tlb->mm, start, end);
 }
 
-void free_pgtables(struct mmu_gather **tlb, struct vm_area_struct *vma,
-		unsigned long floor, unsigned long ceiling)
+void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
+		   unsigned long floor, unsigned long ceiling)
 {
 	while (vma) {
 		struct vm_area_struct *next = vma->vm_next;
@@ -277,6 +278,14 @@ void free_pgtables(struct mmu_gather **t
 		anon_vma_unlink(vma);
 		unlink_file_vma(vma);
 
+		/*
+		 * Check if there's a need_resched here, flush the batch. That
+		 * will drop the preempt block.
+		 */
+		if (need_resched()) {
+			tlb_flush_mmu(tlb);
+			cond_resched();
+		}
 		if (is_vm_hugetlb_page(vma)) {
 			hugetlb_free_pgd_range(tlb, addr, vma->vm_end,
 				floor, next? next->vm_start: ceiling);
@@ -294,6 +303,7 @@ void free_pgtables(struct mmu_gather **t
 			free_pgd_range(tlb, addr, vma->vm_end,
 				floor, next? next->vm_start: ceiling);
 		}
+
 		vma = next;
 	}
 }
@@ -696,6 +706,7 @@ static unsigned long zap_pte_range(struc
 
 	add_mm_rss(mm, file_rss, anon_rss);
 	arch_leave_lazy_mmu_mode();
+	tlb_pte_lock_break(tlb);
 	pte_unmap_unlock(pte - 1, ptl);
 
 	return addr;
@@ -806,17 +817,14 @@ static unsigned long unmap_page_range(st
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
 
 	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
 		unsigned long end;
@@ -832,18 +840,13 @@ unsigned long unmap_vmas(struct mmu_gath
 			*nr_accounted += (end - start) >> PAGE_SHIFT;
 
 		while (start != end) {
-			if (!tlb_start_valid) {
-				tlb_start = start;
-				tlb_start_valid = 1;
-			}
-
 			if (unlikely(is_vm_hugetlb_page(vma))) {
 				unmap_hugepage_range(vma, start, end);
 				zap_work -= (end - start) /
 						(HPAGE_SIZE / PAGE_SIZE);
 				start = end;
 			} else
-				start = unmap_page_range(*tlbp, vma,
+				start = unmap_page_range(tlb, vma,
 						start, end, &zap_work, details);
 
 			if (zap_work > 0) {
@@ -851,23 +854,18 @@ unsigned long unmap_vmas(struct mmu_gath
 				break;
 			}
 
-			tlb_finish_mmu(*tlbp, tlb_start, start);
-
 			if (need_resched() ||
 				(i_mmap_lock && need_lockbreak(i_mmap_lock))) {
-				if (i_mmap_lock) {
-					*tlbp = NULL;
+				if (i_mmap_lock)
 					goto out;
-				}
+				tlb_flush_mmu(tlb);
 				cond_resched();
 			}
-
-			*tlbp = tlb_gather_mmu(vma->vm_mm, fullmm);
-			tlb_start_valid = 0;
 			zap_work = ZAP_BLOCK_SIZE;
 		}
 	}
 out:
+	tlb_flush_mmu(tlb);
 	return start;	/* which is now the end (or restart) address */
 }
 
@@ -882,16 +880,18 @@ unsigned long zap_page_range(struct vm_a
 		unsigned long size, struct zap_details *details)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	struct mmu_gather *tlb;
+	struct mmu_gather tlb;
 	unsigned long end = address + size;
 	unsigned long nr_accounted = 0;
+	unsigned int mode = TLB_MODE_FREE_PAGES | TLB_MODE_FREE_PGTABLES;
 
 	lru_add_drain();
-	tlb = tlb_gather_mmu(mm, 0);
+	if (details && details->i_mmap_lock)
+		mode |= TLB_MODE_IMMAP_LOCK;
+	tlb_gather_mmu(&tlb, mm, mode);
 	update_hiwater_rss(mm);
 	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
-	if (tlb)
-		tlb_finish_mmu(tlb, address, end);
+	tlb_finish_mmu(&tlb);
 	return end;
 }
 
Index: linux-work/mm/mmap.c
===================================================================
--- linux-work.orig/mm/mmap.c	2007-07-26 16:43:50.000000000 +1000
+++ linux-work/mm/mmap.c	2007-07-26 16:44:31.000000000 +1000
@@ -1699,17 +1699,17 @@ static void unmap_region(struct mm_struc
 		unsigned long start, unsigned long end)
 {
 	struct vm_area_struct *next = prev? prev->vm_next: mm->mmap;
-	struct mmu_gather *tlb;
+	struct mmu_gather tlb;
 	unsigned long nr_accounted = 0;
 
 	lru_add_drain();
-	tlb = tlb_gather_mmu(mm, 0);
+	tlb_gather_mmu(&tlb, mm, TLB_MODE_FREE_PAGES | TLB_MODE_FREE_PGTABLES);
 	update_hiwater_rss(mm);
 	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
 	free_pgtables(&tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
 				 next? next->vm_start: 0);
-	tlb_finish_mmu(tlb, start, end);
+	tlb_finish_mmu(&tlb);
 }
 
 /*
@@ -1986,7 +1986,7 @@ EXPORT_SYMBOL(do_brk);
 /* Release all mmaps. */
 void exit_mmap(struct mm_struct *mm)
 {
-	struct mmu_gather *tlb;
+	struct mmu_gather tlb;
 	struct vm_area_struct *vma = mm->mmap;
 	unsigned long nr_accounted = 0;
 	unsigned long end;
@@ -1996,13 +1996,14 @@ void exit_mmap(struct mm_struct *mm)
 
 	lru_add_drain();
 	flush_cache_mm(mm);
-	tlb = tlb_gather_mmu(mm, 1);
+	tlb_gather_mmu(&tlb, mm,
+		       TLB_MODE_FULL | TLB_MODE_FREE_PAGES | TLB_MODE_FREE_PGTABLES);
 	/* Don't update_hiwater_rss(mm) here, do_exit already did */
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, 0);
-	tlb_finish_mmu(tlb, 0, end);
+	tlb_finish_mmu(&tlb);
 
 	/*
 	 * Walk the list again, actually closing and freeing it,
Index: linux-work/arch/powerpc/mm/hugetlbpage.c
===================================================================
--- linux-work.orig/arch/powerpc/mm/hugetlbpage.c	2007-07-26 16:43:50.000000000 +1000
+++ linux-work/arch/powerpc/mm/hugetlbpage.c	2007-07-26 16:44:31.000000000 +1000
@@ -240,7 +240,7 @@ static void hugetlb_free_pud_range(struc
  *
  * Must be called with pagetable lock held.
  */
-void hugetlb_free_pgd_range(struct mmu_gather **tlb,
+void hugetlb_free_pgd_range(struct mmu_gather *tlb,
 			    unsigned long addr, unsigned long end,
 			    unsigned long floor, unsigned long ceiling)
 {
@@ -300,13 +300,13 @@ void hugetlb_free_pgd_range(struct mmu_g
 		return;
 
 	start = addr;
-	pgd = pgd_offset((*tlb)->mm, addr);
+	pgd = pgd_offset(tlb->mm, addr);
 	do {
-		BUG_ON(get_slice_psize((*tlb)->mm, addr) != mmu_huge_psize);
+		BUG_ON(get_slice_psize(tlb->mm, addr) != mmu_huge_psize);
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd))
 			continue;
-		hugetlb_free_pud_range(*tlb, pgd, addr, next, floor, ceiling);
+		hugetlb_free_pud_range(tlb, pgd, addr, next, floor, ceiling);
 	} while (pgd++, addr = next, addr != end);
 }
 
Index: linux-work/fs/exec.c
===================================================================
--- linux-work.orig/fs/exec.c	2007-07-26 16:43:50.000000000 +1000
+++ linux-work/fs/exec.c	2007-07-26 16:44:31.000000000 +1000
@@ -525,7 +525,7 @@ static int shift_arg_pages(struct vm_are
 	unsigned long length = old_end - old_start;
 	unsigned long new_start = old_start - shift;
 	unsigned long new_end = old_end - shift;
-	struct mmu_gather *tlb;
+	struct mmu_gather tlb;
 
 	BUG_ON(new_start > new_end);
 
@@ -550,7 +550,7 @@ static int shift_arg_pages(struct vm_are
 		return -ENOMEM;
 
 	lru_add_drain();
-	tlb = tlb_gather_mmu(mm, 0);
+	tlb_gather_mmu(&tlb, mm, TLB_MODE_FREE_PGTABLES);
 	if (new_end > old_start) {
 		/*
 		 * when the old and new regions overlap clear from new_end.
@@ -567,7 +567,7 @@ static int shift_arg_pages(struct vm_are
 		free_pgd_range(&tlb, old_start, old_end, new_end,
 			vma->vm_next ? vma->vm_next->vm_start : 0);
 	}
-	tlb_finish_mmu(tlb, new_end, old_end);
+	tlb_finish_mmu(&tlb);
 
 	/*
 	 * shrink the vma to just the new range.
Index: linux-work/include/linux/hugetlb.h
===================================================================
--- linux-work.orig/include/linux/hugetlb.h	2007-07-26 16:43:50.000000000 +1000
+++ linux-work/include/linux/hugetlb.h	2007-07-26 16:44:31.000000000 +1000
@@ -54,7 +54,7 @@ void hugetlb_change_protection(struct vm
 #ifndef ARCH_HAS_HUGETLB_FREE_PGD_RANGE
 #define hugetlb_free_pgd_range	free_pgd_range
 #else
-void hugetlb_free_pgd_range(struct mmu_gather **tlb, unsigned long addr,
+void hugetlb_free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 			    unsigned long end, unsigned long floor,
 			    unsigned long ceiling);
 #endif
Index: linux-work/include/linux/mm.h
===================================================================
--- linux-work.orig/include/linux/mm.h	2007-07-26 16:43:50.000000000 +1000
+++ linux-work/include/linux/mm.h	2007-07-26 16:44:31.000000000 +1000
@@ -768,13 +768,13 @@ struct zap_details {
 struct page *vm_normal_page(struct vm_area_struct *, unsigned long, pte_t);
 unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size, struct zap_details *);
-unsigned long unmap_vmas(struct mmu_gather **tlb,
+unsigned long unmap_vmas(struct mmu_gather *tlb,
 		struct vm_area_struct *start_vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *);
-void free_pgd_range(struct mmu_gather **tlb, unsigned long addr,
+void free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 		unsigned long end, unsigned long floor, unsigned long ceiling);
-void free_pgtables(struct mmu_gather **tlb, struct vm_area_struct *start_vma,
+void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma);
Index: linux-work/arch/i386/mm/init.c
===================================================================
--- linux-work.orig/arch/i386/mm/init.c	2007-07-26 16:43:50.000000000 +1000
+++ linux-work/arch/i386/mm/init.c	2007-07-26 16:44:31.000000000 +1000
@@ -47,7 +47,7 @@
 
 unsigned int __VMALLOC_RESERVE = 128 << 20;
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
+DEFINE_PER_CPU(struct mmu_gather_store, mmu_gather_store);
 unsigned long highstart_pfn, highend_pfn;
 
 static int noinline do_test_wp_bit(void);
Index: linux-work/arch/powerpc/mm/init_32.c
===================================================================
--- linux-work.orig/arch/powerpc/mm/init_32.c	2007-07-26 16:43:50.000000000 +1000
+++ linux-work/arch/powerpc/mm/init_32.c	2007-07-26 16:44:31.000000000 +1000
@@ -55,7 +55,7 @@
 #endif
 #define MAX_LOW_MEM	CONFIG_LOWMEM_SIZE
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
+DEFINE_PER_CPU(struct mmu_gather_store, mmu_gather_store);
 
 unsigned long total_memory;
 unsigned long total_lowmem;
Index: linux-work/arch/x86_64/mm/init.c
===================================================================
--- linux-work.orig/arch/x86_64/mm/init.c	2007-07-26 16:43:50.000000000 +1000
+++ linux-work/arch/x86_64/mm/init.c	2007-07-26 16:44:31.000000000 +1000
@@ -53,7 +53,7 @@ EXPORT_SYMBOL(dma_ops);
 
 static unsigned long dma_reserve __initdata;
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
+DEFINE_PER_CPU(struct mmu_gather_store, mmu_gather_store);
 
 /*
  * NOTE: pagetable_init alloc all the fixmap pagetables contiguous on the
Index: linux-work/include/asm-i386/tlb.h
===================================================================
--- linux-work.orig/include/asm-i386/tlb.h	2007-07-26 16:43:50.000000000 +1000
+++ linux-work/include/asm-i386/tlb.h	2007-07-26 16:44:31.000000000 +1000
@@ -2,11 +2,8 @@
 #define _I386_TLB_H
 
 /*
- * x86 doesn't need any special per-pte or
- * per-vma handling..
+ * x86 doesn't need any special per-pte batch handling..
  */
-#define tlb_start_vma(tlb, vma) do { } while (0)
-#define tlb_end_vma(tlb, vma) do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
 
 /*
Index: linux-work/arch/avr32/mm/init.c
===================================================================
--- linux-work.orig/arch/avr32/mm/init.c	2007-07-26 16:44:43.000000000 +1000
+++ linux-work/arch/avr32/mm/init.c	2007-07-26 16:44:48.000000000 +1000
@@ -23,7 +23,7 @@
 #include <asm/setup.h>
 #include <asm/sections.h>
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
+DEFINE_PER_CPU(struct mmu_gather_store, mmu_gather_store);
 
 pgd_t swapper_pg_dir[PTRS_PER_PGD];
 
Index: linux-work/arch/sparc/mm/init.c
===================================================================
--- linux-work.orig/arch/sparc/mm/init.c	2007-07-26 16:46:28.000000000 +1000
+++ linux-work/arch/sparc/mm/init.c	2007-07-26 16:46:35.000000000 +1000
@@ -32,7 +32,7 @@
 #include <asm/tlb.h>
 #include <asm/prom.h>
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
+DEFINE_PER_CPU(struct mmu_gather_store, mmu_gather_store);
 
 unsigned long *sparc_valid_addr_bitmap;
 
Index: linux-work/arch/sparc64/mm/tlb.c
===================================================================
--- linux-work.orig/arch/sparc64/mm/tlb.c	2007-07-26 16:46:01.000000000 +1000
+++ linux-work/arch/sparc64/mm/tlb.c	2007-07-26 16:46:07.000000000 +1000
@@ -19,7 +19,7 @@
 
 /* Heavily inspired by the ppc64 code.  */
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers) = { 0, };
+DEFINE_PER_CPU(struct mmu_gather_store, mmu_gather_store) = { 0, };
 
 void flush_tlb_pending(void)
 {
Index: linux-work/arch/um/kernel/smp.c
===================================================================
--- linux-work.orig/arch/um/kernel/smp.c	2007-07-26 16:45:31.000000000 +1000
+++ linux-work/arch/um/kernel/smp.c	2007-07-26 16:45:38.000000000 +1000
@@ -8,7 +8,7 @@
 #include "asm/tlb.h"
 
 /* For some reason, mmu_gathers are referenced when CONFIG_SMP is off. */
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
+DEFINE_PER_CPU(struct mmu_gather_store, mmu_gather_store);
 
 #ifdef CONFIG_SMP
 
Index: linux-work/arch/xtensa/mm/init.c
===================================================================
--- linux-work.orig/arch/xtensa/mm/init.c	2007-07-26 16:44:58.000000000 +1000
+++ linux-work/arch/xtensa/mm/init.c	2007-07-26 16:45:11.000000000 +1000
@@ -38,7 +38,7 @@
 
 #define DEBUG 0
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
+DEFINE_PER_CPU(struct mmu_gather_store, mmu_gather_store);
 //static DEFINE_SPINLOCK(tlb_lock);
 
 /*
Index: linux-work/include/asm-sparc64/tlb.h
===================================================================
--- linux-work.orig/include/asm-sparc64/tlb.h	2007-07-26 16:47:56.000000000 +1000
+++ linux-work/include/asm-sparc64/tlb.h	2007-07-26 16:58:08.000000000 +1000
@@ -9,29 +9,11 @@
 
 #define TLB_BATCH_NR	192
 
-/*
- * For UP we don't need to worry about TLB flush
- * and page free order so much..
- */
-#ifdef CONFIG_SMP
-  #define FREE_PTE_NR	506
-  #define tlb_fast_mode(bp) ((bp)->pages_nr == ~0U)
-#else
-  #define FREE_PTE_NR	1
-  #define tlb_fast_mode(bp) 1
-#endif
-
-struct mmu_gather {
-	struct mm_struct *mm;
-	unsigned int pages_nr;
-	unsigned int need_flush;
-	unsigned int fullmm;
+#define mmu_gather_arch_fields			\
+	unsigned long vaddrs[TLB_BATCH_NR];	\
 	unsigned int tlb_nr;
-	unsigned long vaddrs[TLB_BATCH_NR];
-	struct page *pages[FREE_PTE_NR];
-};
 
-DECLARE_PER_CPU(struct mmu_gather, mmu_gathers);
+#include <asm-generic/tlb.h>
 
 #ifdef CONFIG_SMP
 extern void smp_flush_tlb_pending(struct mm_struct *,
@@ -41,30 +23,20 @@ extern void smp_flush_tlb_pending(struct
 extern void __flush_tlb_pending(unsigned long, unsigned long, unsigned long *);
 extern void flush_tlb_pending(void);
 
-static inline struct mmu_gather *tlb_gather_mmu(struct mm_struct *mm, unsigned int full_mm_flush)
+static inline void tlb_arch_init(struct mmu_gather *tlb)
 {
-	struct mmu_gather *mp = &get_cpu_var(mmu_gathers);
-
-	BUG_ON(mp->tlb_nr);
-
-	mp->mm = mm;
-	mp->pages_nr = num_online_cpus() > 1 ? 0U : ~0U;
-	mp->fullmm = full_mm_flush;
-
-	return mp;
+	tlb->tlb_nr = 0;
 }
 
-
-static inline void tlb_flush_mmu(struct mmu_gather *mp)
+static inline void tlb_arch_finish(struct mmu_gather *tlb)
 {
-	if (mp->need_flush) {
-		free_pages_and_swap_cache(mp->pages, mp->pages_nr);
-		mp->pages_nr = 0;
-		mp->need_flush = 0;
-	}
-
+	/* I changed the logic a bit here, DaveM, pls, explain me what it
+	 * did with fullmm ...
+	 */
+	flush_tlb_pending();
 }
 
+
 #ifdef CONFIG_SMP
 extern void smp_flush_tlb_mm(struct mm_struct *mm);
 #define do_flush_tlb_mm(mm) smp_flush_tlb_mm(mm)
@@ -72,32 +44,6 @@ extern void smp_flush_tlb_mm(struct mm_s
 #define do_flush_tlb_mm(mm) __flush_tlb_mm(CTX_HWBITS(mm->context), SECONDARY_CONTEXT)
 #endif
 
-static inline void tlb_finish_mmu(struct mmu_gather *mp, unsigned long start, unsigned long end)
-{
-	tlb_flush_mmu(mp);
-
-	if (mp->fullmm)
-		mp->fullmm = 0;
-	else
-		flush_tlb_pending();
-
-	/* keep the page table cache within bounds */
-	check_pgt_cache();
-
-	put_cpu_var(mmu_gathers);
-}
-
-static inline void tlb_remove_page(struct mmu_gather *mp, struct page *page)
-{
-	if (tlb_fast_mode(mp)) {
-		free_page_and_swap_cache(page);
-		return;
-	}
-	mp->need_flush = 1;
-	mp->pages[mp->pages_nr++] = page;
-	if (mp->pages_nr >= FREE_PTE_NR)
-		tlb_flush_mmu(mp);
-}
 
 #define tlb_remove_tlb_entry(mp,ptep,addr) do { } while (0)
 #define pte_free_tlb(mp,ptepage) pte_free(ptepage)
@@ -105,7 +51,5 @@ static inline void tlb_remove_page(struc
 #define pud_free_tlb(tlb,pudp) __pud_free_tlb(tlb,pudp)
 
 #define tlb_migrate_finish(mm)	do { } while (0)
-#define tlb_start_vma(tlb, vma) do { } while (0)
-#define tlb_end_vma(tlb, vma)	do { } while (0)
 
 #endif /* _SPARC64_TLB_H */
Index: linux-work/include/asm-x86_64/tlb.h
===================================================================
--- linux-work.orig/include/asm-x86_64/tlb.h	2007-07-26 16:57:29.000000000 +1000
+++ linux-work/include/asm-x86_64/tlb.h	2007-07-26 16:57:31.000000000 +1000
@@ -2,8 +2,6 @@
 #define TLB_H 1
 
 
-#define tlb_start_vma(tlb, vma) do { } while (0)
-#define tlb_end_vma(tlb, vma) do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
 
 #define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
