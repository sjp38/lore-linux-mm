From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 07 Aug 2007 17:19:52 +1000
Subject: [RFC/PATCH 9/12] mmu_gather on stack, part 1
In-Reply-To: <1186471185.826251.312410898174.qpush@grosgo>
Message-Id: <20070807071958.CD2F0DDDFA@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This is the first step of moving the mmu_gather to a stack based
data structure and removing the per-cpu usage.

This patch reworks the mmu_gather such that it's made of two parts,
one is a stack based data structure, which optionally points to a
list of page pointers used when freeing pages. That list is for now
still kept per-cpu.

It also massages the mmu_gather APIs a bit, to avoid having archs
re-implementing it, but instead, having hooks for archs to use.

With that patch, platforms that don't use the batch for freeing page
tables (though that could be considered a bug...) will now have
free_pgtables() run without preemption disabling.

NOTE: This is still a WIP, arm hasn't been adapted yet among others
(I need to understand why it's not batching page freeing at all in
the first place).

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

 arch/avr32/mm/init.c          |    2 
 arch/i386/mm/init.c           |    2 
 arch/ia64/mm/hugetlbpage.c    |    2 
 arch/powerpc/mm/hugetlbpage.c |    8 -
 arch/powerpc/mm/init_32.c     |    2 
 arch/powerpc/mm/tlb_64.c      |    2 
 arch/sparc/mm/init.c          |    2 
 arch/sparc64/mm/tlb.c         |    2 
 arch/um/kernel/smp.c          |    2 
 arch/x86_64/mm/init.c         |    2 
 arch/xtensa/mm/init.c         |    2 
 fs/exec.c                     |    6 -
 include/asm-generic/tlb.h     |   83 ++++++++++++++-----
 include/asm-i386/tlb.h        |    5 -
 include/asm-ia64/pgalloc.h    |    3 
 include/asm-ia64/tlb.h        |  180 ++++++++++--------------------------------
 include/asm-parisc/tlb.h      |   10 +-
 include/asm-powerpc/tlb.h     |    3 
 include/asm-sparc64/tlb.h     |    3 
 include/asm-x86_64/tlb.h      |    2 
 include/linux/hugetlb.h       |    2 
 include/linux/mm.h            |    6 -
 mm/memory.c                   |   52 +++++-------
 mm/mmap.c                     |   14 +--
 24 files changed, 166 insertions(+), 231 deletions(-)

Index: linux-work/include/asm-generic/tlb.h
===================================================================
--- linux-work.orig/include/asm-generic/tlb.h	2007-08-07 16:18:13.000000000 +1000
+++ linux-work/include/asm-generic/tlb.h	2007-08-07 16:23:53.000000000 +1000
@@ -33,48 +33,62 @@
   #define tlb_fast_mode(tlb) 1
 #endif
 
+/* arch may add fields to mmu_gather */
+#ifndef mmu_gather_arch
+struct mmu_gather_arch { };
+#define tlb_arch_init(tlb)		do { } while(0)
+#define tlb_arch_finish(tlb)		do { } while(0)
+#endif
+
 /* struct mmu_gather is an opaque type used by the mm code for passing around
  * any data needed by arch specific code for tlb_remove_page.
  */
 struct mmu_gather {
 	struct mm_struct	*mm;
+	unsigned int		need_flush;/* Really changed some ptes? */
 	unsigned int		nr;	/* set to ~0U means fast mode */
-	unsigned int		need_flush;/* Really unmapped some ptes? */
-	unsigned int		fullmm; /* non-zero means full mm flush */
+	struct mmu_gather_arch	archdata;
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
 
 /* tlb_gather_mmu
  *	Return a pointer to an initialized struct mmu_gather.
  */
-static inline struct mmu_gather *
-tlb_gather_mmu(struct mm_struct *mm, unsigned int full_mm_flush)
+static inline void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm)
 {
-	struct mmu_gather *tlb = &get_cpu_var(mmu_gathers);
-
 	tlb->mm = mm;
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
 
@@ -82,17 +96,42 @@ tlb_flush_mmu(struct mmu_gather *tlb, un
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
@@ -105,11 +144,18 @@ static inline void tlb_remove_page(struc
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
 
+#ifndef tlb_migrate_finish
+#define tlb_migrate_finish(mm) do {} while (0)
+#endif
+
 /**
  * tlb_remove_tlb_entry - remember a pte unmapping for later tlb invalidation.
  *
@@ -143,6 +189,5 @@ static inline void tlb_remove_page(struc
 		__pmd_free_tlb(tlb, pmdp, address);		\
 	} while (0)
 
-#define tlb_migrate_finish(mm) do {} while (0)
 
 #endif /* _ASM_GENERIC__TLB_H */
Index: linux-work/arch/powerpc/mm/tlb_64.c
===================================================================
--- linux-work.orig/arch/powerpc/mm/tlb_64.c	2007-08-07 16:18:13.000000000 +1000
+++ linux-work/arch/powerpc/mm/tlb_64.c	2007-08-07 16:23:53.000000000 +1000
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
--- linux-work.orig/include/asm-powerpc/tlb.h	2007-08-07 16:18:13.000000000 +1000
+++ linux-work/include/asm-powerpc/tlb.h	2007-08-07 16:23:53.000000000 +1000
@@ -25,9 +25,6 @@
 
 struct mmu_gather;
 
-#define tlb_start_vma(tlb, vma)	do { } while (0)
-#define tlb_end_vma(tlb, vma)	do { } while (0)
-
 #if !defined(CONFIG_PPC_STD_MMU)
 
 #define tlb_flush(tlb)			flush_tlb_mm((tlb)->mm)
Index: linux-work/mm/memory.c
===================================================================
--- linux-work.orig/mm/memory.c	2007-08-07 16:18:48.000000000 +1000
+++ linux-work/mm/memory.c	2007-08-07 16:23:53.000000000 +1000
@@ -202,9 +202,9 @@ static inline void free_pud_range(struct
  *
  * Must be called with pagetable lock held.
  */
-void free_pgd_range(struct mmu_gather **tlb,
-			unsigned long addr, unsigned long end,
-			unsigned long floor, unsigned long ceiling)
+void free_pgd_range(struct mmu_gather *tlb,
+		    unsigned long addr, unsigned long end,
+		    unsigned long floor, unsigned long ceiling)
 {
 	pgd_t *pgd;
 	unsigned long next;
@@ -253,16 +253,16 @@ void free_pgd_range(struct mmu_gather **
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
 }
 
-void free_pgtables(struct mmu_gather **tlb, struct vm_area_struct *vma,
+void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		unsigned long floor, unsigned long ceiling)
 {
 	while (vma) {
@@ -275,6 +275,14 @@ void free_pgtables(struct mmu_gather **t
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
@@ -292,6 +300,7 @@ void free_pgtables(struct mmu_gather **t
 			free_pgd_range(tlb, addr, vma->vm_end,
 				floor, next? next->vm_start: ceiling);
 		}
+
 		vma = next;
 	}
 }
@@ -693,6 +702,7 @@ static unsigned long zap_pte_range(struc
 
 	add_mm_rss(mm, file_rss, anon_rss);
 	arch_leave_lazy_mmu_mode();
+	tlb_pte_lock_break(tlb);
 	pte_unmap_unlock(pte - 1, ptl);
 
 	return addr;
@@ -803,17 +813,14 @@ static unsigned long unmap_page_range(st
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
@@ -829,18 +836,13 @@ unsigned long unmap_vmas(struct mmu_gath
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
@@ -848,23 +850,18 @@ unsigned long unmap_vmas(struct mmu_gath
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
 
@@ -879,16 +876,15 @@ unsigned long zap_page_range(struct vm_a
 		unsigned long size, struct zap_details *details)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	struct mmu_gather *tlb;
+	struct mmu_gather tlb;
 	unsigned long end = address + size;
 	unsigned long nr_accounted = 0;
 
 	lru_add_drain();
-	tlb = tlb_gather_mmu(mm, 0);
+	tlb_gather_mmu(&tlb, mm);
 	update_hiwater_rss(mm);
 	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
-	if (tlb)
-		tlb_finish_mmu(tlb, address, end);
+	tlb_finish_mmu(&tlb);
 	return end;
 }
 
Index: linux-work/mm/mmap.c
===================================================================
--- linux-work.orig/mm/mmap.c	2007-08-07 16:18:13.000000000 +1000
+++ linux-work/mm/mmap.c	2007-08-07 16:23:53.000000000 +1000
@@ -1733,17 +1733,17 @@ static void unmap_region(struct mm_struc
 		unsigned long start, unsigned long end)
 {
 	struct vm_area_struct *next = prev? prev->vm_next: mm->mmap;
-	struct mmu_gather *tlb;
+	struct mmu_gather tlb;
 	unsigned long nr_accounted = 0;
 
 	lru_add_drain();
-	tlb = tlb_gather_mmu(mm, 0);
+	tlb_gather_mmu(&tlb, mm);
 	update_hiwater_rss(mm);
 	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
 	free_pgtables(&tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
 				 next? next->vm_start: 0);
-	tlb_finish_mmu(tlb, start, end);
+	tlb_finish_mmu(&tlb);
 }
 
 /*
@@ -2020,7 +2020,7 @@ EXPORT_SYMBOL(do_brk);
 /* Release all mmaps. */
 void exit_mmap(struct mm_struct *mm)
 {
-	struct mmu_gather *tlb;
+	struct mmu_gather tlb;
 	struct vm_area_struct *vma = mm->mmap;
 	unsigned long nr_accounted = 0;
 	unsigned long end;
@@ -2031,15 +2031,17 @@ void exit_mmap(struct mm_struct *mm)
 	/* mm's last user has gone, and its about to be pulled down */
 	arch_exit_mmap(mm);
 
+	__set_bit(MMF_DEAD, &mm->flags);
 	lru_add_drain();
 	flush_cache_mm(mm);
-	tlb = tlb_gather_mmu(mm, 1);
+	tlb_gather_mmu(&tlb, mm);
+
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
--- linux-work.orig/arch/powerpc/mm/hugetlbpage.c	2007-08-07 16:18:13.000000000 +1000
+++ linux-work/arch/powerpc/mm/hugetlbpage.c	2007-08-07 16:23:53.000000000 +1000
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
--- linux-work.orig/fs/exec.c	2007-08-07 16:18:13.000000000 +1000
+++ linux-work/fs/exec.c	2007-08-07 16:23:53.000000000 +1000
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
+	tlb_gather_mmu(&tlb, mm);
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
--- linux-work.orig/include/linux/hugetlb.h	2007-08-07 16:18:13.000000000 +1000
+++ linux-work/include/linux/hugetlb.h	2007-08-07 16:23:53.000000000 +1000
@@ -56,7 +56,7 @@ void hugetlb_change_protection(struct vm
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
--- linux-work.orig/include/linux/mm.h	2007-08-07 16:18:13.000000000 +1000
+++ linux-work/include/linux/mm.h	2007-08-07 16:23:53.000000000 +1000
@@ -769,13 +769,13 @@ struct zap_details {
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
--- linux-work.orig/arch/i386/mm/init.c	2007-08-07 16:18:13.000000000 +1000
+++ linux-work/arch/i386/mm/init.c	2007-08-07 16:23:53.000000000 +1000
@@ -47,7 +47,7 @@
 
 unsigned int __VMALLOC_RESERVE = 128 << 20;
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
+DEFINE_PER_CPU(struct mmu_gather_store, mmu_gather_store);
 unsigned long highstart_pfn, highend_pfn;
 
 static int noinline do_test_wp_bit(void);
Index: linux-work/arch/powerpc/mm/init_32.c
===================================================================
--- linux-work.orig/arch/powerpc/mm/init_32.c	2007-08-07 16:18:13.000000000 +1000
+++ linux-work/arch/powerpc/mm/init_32.c	2007-08-07 16:23:53.000000000 +1000
@@ -55,7 +55,7 @@
 #endif
 #define MAX_LOW_MEM	CONFIG_LOWMEM_SIZE
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
+DEFINE_PER_CPU(struct mmu_gather_store, mmu_gather_store);
 
 unsigned long total_memory;
 unsigned long total_lowmem;
Index: linux-work/arch/x86_64/mm/init.c
===================================================================
--- linux-work.orig/arch/x86_64/mm/init.c	2007-08-07 16:18:13.000000000 +1000
+++ linux-work/arch/x86_64/mm/init.c	2007-08-07 16:23:53.000000000 +1000
@@ -53,7 +53,7 @@ EXPORT_SYMBOL(dma_ops);
 
 static unsigned long dma_reserve __initdata;
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
+DEFINE_PER_CPU(struct mmu_gather_store, mmu_gather_store);
 
 /*
  * NOTE: pagetable_init alloc all the fixmap pagetables contiguous on the
Index: linux-work/include/asm-i386/tlb.h
===================================================================
--- linux-work.orig/include/asm-i386/tlb.h	2007-08-07 16:18:13.000000000 +1000
+++ linux-work/include/asm-i386/tlb.h	2007-08-07 16:23:53.000000000 +1000
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
--- linux-work.orig/arch/avr32/mm/init.c	2007-08-07 16:18:13.000000000 +1000
+++ linux-work/arch/avr32/mm/init.c	2007-08-07 16:23:53.000000000 +1000
@@ -23,7 +23,7 @@
 #include <asm/setup.h>
 #include <asm/sections.h>
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
+DEFINE_PER_CPU(struct mmu_gather_store, mmu_gather_store);
 
 pgd_t swapper_pg_dir[PTRS_PER_PGD];
 
Index: linux-work/arch/sparc/mm/init.c
===================================================================
--- linux-work.orig/arch/sparc/mm/init.c	2007-08-07 16:18:13.000000000 +1000
+++ linux-work/arch/sparc/mm/init.c	2007-08-07 16:23:53.000000000 +1000
@@ -32,7 +32,7 @@
 #include <asm/tlb.h>
 #include <asm/prom.h>
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
+DEFINE_PER_CPU(struct mmu_gather_store, mmu_gather_store);
 
 unsigned long *sparc_valid_addr_bitmap;
 
Index: linux-work/arch/sparc64/mm/tlb.c
===================================================================
--- linux-work.orig/arch/sparc64/mm/tlb.c	2007-08-07 16:18:13.000000000 +1000
+++ linux-work/arch/sparc64/mm/tlb.c	2007-08-07 16:23:53.000000000 +1000
@@ -19,7 +19,7 @@
 
 /* Heavily inspired by the ppc64 code.  */
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
+DEFINE_PER_CPU(struct mmu_gather_store, mmu_gather_store);
 DEFINE_PER_CPU(struct tlb_batch, tlb_batch);
 
 void __flush_tlb_pending(struct tlb_batch *mp)
Index: linux-work/arch/um/kernel/smp.c
===================================================================
--- linux-work.orig/arch/um/kernel/smp.c	2007-08-07 16:18:13.000000000 +1000
+++ linux-work/arch/um/kernel/smp.c	2007-08-07 16:23:53.000000000 +1000
@@ -8,7 +8,7 @@
 #include "asm/tlb.h"
 
 /* For some reason, mmu_gathers are referenced when CONFIG_SMP is off. */
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
+DEFINE_PER_CPU(struct mmu_gather_store, mmu_gather_store);
 
 #ifdef CONFIG_SMP
 
Index: linux-work/arch/xtensa/mm/init.c
===================================================================
--- linux-work.orig/arch/xtensa/mm/init.c	2007-08-07 16:18:13.000000000 +1000
+++ linux-work/arch/xtensa/mm/init.c	2007-08-07 16:23:53.000000000 +1000
@@ -38,7 +38,7 @@
 
 #define DEBUG 0
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
+DEFINE_PER_CPU(struct mmu_gather_store, mmu_gather_store);
 //static DEFINE_SPINLOCK(tlb_lock);
 
 /*
Index: linux-work/include/asm-sparc64/tlb.h
===================================================================
--- linux-work.orig/include/asm-sparc64/tlb.h	2007-08-07 16:18:13.000000000 +1000
+++ linux-work/include/asm-sparc64/tlb.h	2007-08-07 16:23:53.000000000 +1000
@@ -52,7 +52,4 @@ extern void smp_flush_tlb_mm(struct mm_s
 #define __pte_free_tlb(mp,ptepage,address)	pte_free((mp)->mm,ptepage)
 #define __pmd_free_tlb(mp,pmdp,address)		pmd_free((mp)->mm,pmdp)
 
-#define tlb_start_vma(tlb, vma) do { } while (0)
-#define tlb_end_vma(tlb, vma)	do { } while (0)
-
 #endif /* _SPARC64_TLB_H */
Index: linux-work/include/asm-x86_64/tlb.h
===================================================================
--- linux-work.orig/include/asm-x86_64/tlb.h	2007-08-07 16:18:13.000000000 +1000
+++ linux-work/include/asm-x86_64/tlb.h	2007-08-07 16:23:53.000000000 +1000
@@ -2,8 +2,6 @@
 #define TLB_H 1
 
 
-#define tlb_start_vma(tlb, vma) do { } while (0)
-#define tlb_end_vma(tlb, vma) do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
 
 #define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
Index: linux-work/include/asm-ia64/pgalloc.h
===================================================================
--- linux-work.orig/include/asm-ia64/pgalloc.h	2007-08-07 16:18:13.000000000 +1000
+++ linux-work/include/asm-ia64/pgalloc.h	2007-08-07 16:23:53.000000000 +1000
@@ -48,7 +48,6 @@ static inline void pud_free(struct mm_st
 {
 	quicklist_free(0, NULL, pud);
 }
-#define __pud_free_tlb(tlb, pud, address)	pud_free((tlb)->mm, pud)
 #endif /* CONFIG_PGTABLE_4 */
 
 static inline void
@@ -67,7 +66,6 @@ static inline void pmd_free(struct mm_st
 	quicklist_free(0, NULL, pmd);
 }
 
-#define __pmd_free_tlb(tlb, pmd, address)	pmd_free((tlb)->mm, pmd)
 
 static inline void
 pmd_populate(struct mm_struct *mm, pmd_t * pmd_entry, struct page *pte)
@@ -109,6 +107,5 @@ static inline void check_pgt_cache(void)
 	quicklist_trim(0, NULL, 25, 16);
 }
 
-#define __pte_free_tlb(tlb, pte, address)	pte_free((tlb)->mm, pte)
 
 #endif				/* _ASM_IA64_PGALLOC_H */
Index: linux-work/include/asm-ia64/tlb.h
===================================================================
--- linux-work.orig/include/asm-ia64/tlb.h	2007-08-07 16:18:13.000000000 +1000
+++ linux-work/include/asm-ia64/tlb.h	2007-08-07 16:23:53.000000000 +1000
@@ -46,51 +46,30 @@
 #include <asm/tlbflush.h>
 #include <asm/machvec.h>
 
-#ifdef CONFIG_SMP
-# define FREE_PTE_NR		2048
-# define tlb_fast_mode(tlb)	((tlb)->nr == ~0U)
-#else
-# define FREE_PTE_NR		0
-# define tlb_fast_mode(tlb)	(1)
-#endif
-
-struct mmu_gather {
-	struct mm_struct	*mm;
-	unsigned int		nr;		/* == ~0U => fast mode */
-	unsigned char		fullmm;		/* non-zero means full mm flush */
-	unsigned char		need_flush;	/* really unmapped some PTEs? */
+struct mmu_gather_arch {
 	unsigned long		start_addr;
 	unsigned long		end_addr;
 	unsigned long		start_pgtable;
 	unsigned long		end_pgtable;
-	struct page 		*pages[FREE_PTE_NR];
 };
+#define mmu_gather_arch mmu_gather_arch
 
-/* Users of the generic TLB shootdown code must declare this storage space. */
-DECLARE_PER_CPU(struct mmu_gather, mmu_gathers);
 
-/*
- * Flush the TLB for address range START to END and, if not in fast mode, release the
+/* Flush the TLB for address range START to END and, if not in fast mode, release the
  * freed pages that where gathered up to this point.
  */
-static inline void
-ia64_tlb_flush_mmu (struct mmu_gather *tlb)
+static inline void __tlb_flush(struct mmu_gather_arch *tlba, struct mm_struct *mm)
 {
-	unsigned long start = tlb->start_addr;
-	unsigned long end = tlb->end_addr;
-	unsigned int nr;
-
-	if (!tlb->need_flush)
-		return;
-	tlb->need_flush = 0;
+	unsigned long start = tlba->start_addr;
+	unsigned long end = tlba->end_addr;
 
-	if (tlb->fullmm) {
+	if (test_bit(MMF_DEAD, &mm->flags)) {
 		/*
 		 * Tearing down the entire address space.  This happens both as a result
 		 * of exit() and execve().  The latter case necessitates the call to
 		 * flush_tlb_mm() here.
 		 */
-		flush_tlb_mm(tlb->mm);
+		flush_tlb_mm(mm);
 	} else if (unlikely (end - start >= 1024*1024*1024*1024UL
 			     || REGION_NUMBER(start) != REGION_NUMBER(end - 1)))
 	{
@@ -104,138 +83,65 @@ ia64_tlb_flush_mmu (struct mmu_gather *t
 		/*
 		 * XXX fix me: flush_tlb_range() should take an mm pointer instead of a
 		 * vma pointer.
+		 *
+		 * Will fix that once flush_tlb_range() is no more a generic hook, as
+		 * soon as the batch has been generalized. --BenH.
 		 */
 		struct vm_area_struct vma;
 
-		vma.vm_mm = tlb->mm;
+		vma.vm_mm = mm;
+
 		/* flush the address range from the tlb: */
 		flush_tlb_range(&vma, start, end);
+
 		/* now flush the virt. page-table area mapping the address range: */
-		if (tlb->start_pgtable < tlb->end_pgtable)
+		if (tlba->start_pgtable < tlba->end_pgtable)
 			flush_tlb_range(&vma,
-					ia64_thash(tlb->start_pgtable),
-					ia64_thash(tlb->end_pgtable));
+					ia64_thash(tlba->start_pgtable),
+					ia64_thash(tlba->end_pgtable));
 	}
 
-	/* lastly, release the freed pages */
-	nr = tlb->nr;
-	if (!tlb_fast_mode(tlb)) {
-		unsigned long i;
-		tlb->nr = 0;
-		tlb->start_addr = tlb->start_pgtable = ~0UL;
-		for (i = 0; i < nr; ++i)
-			free_page_and_swap_cache(tlb->pages[i]);
-	}
+	tlba->start_addr = tlba->start_pgtable = ~0UL;
 }
 
-/*
- * Return a pointer to an initialized struct mmu_gather.
- */
-static inline struct mmu_gather *
-tlb_gather_mmu (struct mm_struct *mm, unsigned int full_mm_flush)
+static inline void __tlb_arch_init(struct mmu_gather_arch *tlba)
 {
-	struct mmu_gather *tlb = &get_cpu_var(mmu_gathers);
-
-	tlb->mm = mm;
-	/*
-	 * Use fast mode if only 1 CPU is online.
-	 *
-	 * It would be tempting to turn on fast-mode for full_mm_flush as well.  But this
-	 * doesn't work because of speculative accesses and software prefetching: the page
-	 * table of "mm" may (and usually is) the currently active page table and even
-	 * though the kernel won't do any user-space accesses during the TLB shoot down, a
-	 * compiler might use speculation or lfetch.fault on what happens to be a valid
-	 * user-space address.  This in turn could trigger a TLB miss fault (or a VHPT
-	 * walk) and re-insert a TLB entry we just removed.  Slow mode avoids such
-	 * problems.  (We could make fast-mode work by switching the current task to a
-	 * different "mm" during the shootdown.) --davidm 08/02/2002
-	 */
-	tlb->nr = (num_online_cpus() == 1) ? ~0U : 0;
-	tlb->fullmm = full_mm_flush;
-	tlb->start_addr = tlb->start_pgtable = ~0UL;
-	return tlb;
+	tlba->start_addr = tlba->start_pgtable = ~0UL;
 }
 
-/*
- * Called at the end of the shootdown operation to free up any resources that were
- * collected.
- */
-static inline void
-tlb_finish_mmu (struct mmu_gather *tlb, unsigned long start, unsigned long end)
-{
-	/*
-	 * Note: tlb->nr may be 0 at this point, so we can't rely on tlb->start_addr and
-	 * tlb->end_addr.
-	 */
-	ia64_tlb_flush_mmu(tlb);
-
-	/* keep the page table cache within bounds */
-	check_pgt_cache();
-
-	put_cpu_var(mmu_gathers);
-}
-
-/*
- * Logically, this routine frees PAGE.  On MP machines, the actual freeing of the page
- * must be delayed until after the TLB has been flushed (see comments at the beginning of
- * this file).
- */
-static inline void
-tlb_remove_page (struct mmu_gather *tlb, struct page *page)
-{
-	tlb->need_flush = 1;
+#define tlb_flush(tlb)		__tlb_flush(&tlb->archdata, tlb->mm)
+#define tlb_arch_init(tlb)	__tlb_arch_init(&tlb->archdata)
+#define tlb_arch_finish(tlb)	do { } while(0)
+#define tlb_migrate_finish(mm)	platform_tlb_migrate_finish(mm)
 
-	if (tlb_fast_mode(tlb)) {
-		free_page_and_swap_cache(page);
-		return;
-	}
-	tlb->pages[tlb->nr++] = page;
-	if (tlb->nr >= FREE_PTE_NR)
-		ia64_tlb_flush_mmu(tlb);
-}
+#include <asm-generic/tlb.h>
 
 /*
- * Remove TLB entry for PTE mapped at virtual address ADDRESS.  This is called for any
- * PTE, not just those pointing to (normal) physical memory.
+ * Remove TLB entry for PTE mapped at virtual address ADDRESS.
+ * This is called for any PTE, not just those pointing to (normal)
+ * physical memory.
  */
-static inline void
-__tlb_remove_tlb_entry (struct mmu_gather *tlb, pte_t *ptep, unsigned long address)
+static inline void __tlb_remove_tlb_entry (struct mmu_gather *tlb, pte_t *ptep,
+					   unsigned long address)
 {
-	if (tlb->start_addr > address)
-		tlb->start_addr = address;
-	tlb->end_addr = address + PAGE_SIZE;
+	if (tlb->archdata.start_addr > address)
+		tlb->archdata.start_addr = address;
+	tlb->archdata.end_addr = address + PAGE_SIZE;
 }
 
-#define tlb_migrate_finish(mm)	platform_tlb_migrate_finish(mm)
-
-#define tlb_start_vma(tlb, vma)			do { } while (0)
-#define tlb_end_vma(tlb, vma)			do { } while (0)
 
-#define tlb_remove_tlb_entry(tlb, ptep, addr)		\
-do {							\
-	tlb->need_flush = 1;				\
-	__tlb_remove_tlb_entry(tlb, ptep, addr);	\
+#define __pte_free_tlb(tlb, ptep, addr)					\
+do {									\
+	if (tlb->archdata.start_pgtable > addr)				\
+		tlb->archdata.start_pgtable = addr;			\
+	tlb->archdata.end_pgtable = (addr + PMD_SIZE) & PMD_MASK;	\
+	pte_free((tlb)->mm, ptep);					\
 } while (0)
 
-#define pte_free_tlb(tlb, ptep, addr)			\
-do {							\
-	tlb->need_flush = 1;				\
-	if (tlb->start_pgtable > addr)			\
-		tlb->start_pgtable = addr;		\
-	tlb->end_pgtable = (addr + PMD_SIZE) & PMD_MASK;\
-	__pte_free_tlb(tlb, ptep, addr);		\
-} while (0)
+#define __pmd_free_tlb(tlb, pmd, address)	pmd_free((tlb)->mm, pmd)
 
-#define pmd_free_tlb(tlb, ptep, addr)			\
-do {							\
-	tlb->need_flush = 1;				\
-	__pmd_free_tlb(tlb, ptep, addr);		\
-} while (0)
-
-#define pud_free_tlb(tlb, pudp, addr)			\
-do {							\
-	tlb->need_flush = 1;				\
-	__pud_free_tlb(tlb, pudp, addr);		\
-} while (0)
+#ifdef CONFIG_PGTABLE_4
+#define __pud_free_tlb(tlb, pud, address)	pud_free((tlb)->mm, pud)
+#endif
 
 #endif /* _ASM_IA64_TLB_H */
Index: linux-work/include/asm-parisc/tlb.h
===================================================================
--- linux-work.orig/include/asm-parisc/tlb.h	2007-08-07 16:18:13.000000000 +1000
+++ linux-work/include/asm-parisc/tlb.h	2007-08-07 16:23:53.000000000 +1000
@@ -1,18 +1,18 @@
 #ifndef _PARISC_TLB_H
 #define _PARISC_TLB_H
 
-#define tlb_flush(tlb)			\
-do {	if ((tlb)->fullmm)		\
-		flush_tlb_mm((tlb)->mm);\
+#define tlb_flush(tlb)						\
+do {	if (test_bit(MMF_DEAD, &(tlb)->mm->flags))		\
+		flush_tlb_mm((tlb)->mm);			\
 } while (0)
 
 #define tlb_start_vma(tlb, vma) \
-do {	if (!(tlb)->fullmm)	\
+do {	if (!test_bit(MMF_DEAD, &(tlb)->mm->flags))		\
 		flush_cache_range(vma, vma->vm_start, vma->vm_end); \
 } while (0)
 
 #define tlb_end_vma(tlb, vma)	\
-do {	if (!(tlb)->fullmm)	\
+do {	if (!test_bit(MMF_DEAD, &(tlb)->mm->flags))		\
 		flush_tlb_range(vma, vma->vm_start, vma->vm_end); \
 } while (0)
 
Index: linux-work/arch/ia64/mm/hugetlbpage.c
===================================================================
--- linux-work.orig/arch/ia64/mm/hugetlbpage.c	2007-08-07 16:18:13.000000000 +1000
+++ linux-work/arch/ia64/mm/hugetlbpage.c	2007-08-07 16:23:53.000000000 +1000
@@ -114,7 +114,7 @@ follow_huge_pmd(struct mm_struct *mm, un
 	return NULL;
 }
 
-void hugetlb_free_pgd_range(struct mmu_gather **tlb,
+void hugetlb_free_pgd_range(struct mmu_gather *tlb,
 			unsigned long addr, unsigned long end,
 			unsigned long floor, unsigned long ceiling)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
