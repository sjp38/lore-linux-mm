Date: Fri, 13 Jul 2007 21:39:18 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: mmu_gather changes & generalization
In-Reply-To: <1184287915.6059.163.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0707132126001.5377@blonde.wat.veritas.com>
References: <1184046405.6059.17.camel@localhost.localdomain>
 <Pine.LNX.4.64.0707112100050.16237@blonde.wat.veritas.com>
 <1184195933.6059.111.camel@localhost.localdomain>
 <Pine.LNX.4.64.0707121715500.4887@blonde.wat.veritas.com>
 <1184287915.6059.163.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Fri, 13 Jul 2007, Benjamin Herrenschmidt wrote:
> 
> I don't care about the small macros that just set/test bits like
> pte_exec. I want to remove the ones that do more than that and are
> unused (ptep_test_and_clear_dirty() was a good example, there was some
> semantics subtleties vs. flushing or not flusing, etc...). Those things
> need to go if they aren't used.

Yes, David Rientjes and Zach Amsden and I kept going back and forth
over its sister ptep_test_and_clear_young(): it is hard to work out
where to place what kind of flush, particularly when it has no users.
Martin eliminating ptep_test_and_clear_dirty looked like a good answer.

> I'll have a look after the next -mm to see what's left. There may be
> nothing left to cleanup :-)

It sounds like I misunderstood how far your cleanup was to reach.
Maybe there isn't such a big multi-arch-build deal as I implied.

Here's the 2.6.22 version of what I worked on just after 2.6.16.
As I said before, if you find it useful to build upon, do so;
but if not, not.  From something you said earlier, I've a
feeling we'll be fighting over where to place the TLB flushes,
inside or outside the page table lock.

A few notes:

Keep in mind: hard to have low preemption latency with decent throughput
in zap_pte_range - easier than it once was now the ptl is taken lower down,
but big problem when truncation/invalidation holds i_mmap_lock to scan the
vma prio_tree - drop that lock and it has to restart.  Not satisfactorily
solved yet (sometimes I think we should collapse the prio_tree into a list
for the duration of the unmapping: no problem putting a marker in the list).

The mmu_gather of pages to be freed after TLB flush represents a signficant
quantity of deferred work, particularly when those pages are in swapcache:
we do want preemption enabled while freeing them, but we don't want to lose
our place in the prio_tree very often.

Don't be misled by inclusion of patches to ia64 and powerpc hugetlbpage.c,
that's just to replace **tlb by *tlb in one function: the real mmu_gather
conversion is yet to be done there.

Only i386 and x86_64 have been converted, built and (inadequately) tested so
far: but most arches shouldn't need more than removing their DEFINE_PER_CPU,
with arm and arm26 probably just wanting to use more of the generic code.

sparc64 uses a flush_tlb_pending technique which defers a lot of work until
context switch, when it cannot be preempted: I've given little thought to it.
powerpc appeared similar to sparc64, but you've changed it since 2.6.16.

I've removed the start,end args to tlb_finish_mmu, and several levels above
it: the tlb_start_valid business in unmap_vmas always seemed ugly to me,
only ia64 has made use of them, and I cannot see why it shouldn't just
record first and last addr when its tlb_remove_tlb_entry is called.
But since ia64 isn't done yet, that end of it isn't seen in the patch.

Hugh

---
 arch/i386/mm/init.c           |    1 
 arch/ia64/mm/hugetlbpage.c    |    2 
 arch/powerpc/mm/hugetlbpage.c |    8 -
 arch/x86_64/mm/init.c         |    2 
 include/asm-generic/pgtable.h |   12 --
 include/asm-generic/tlb.h     |  109 +++++++++++----------
 include/asm-x86_64/tlbflush.h |    4 
 include/linux/hugetlb.h       |    2 
 include/linux/mm.h            |   11 --
 include/linux/swap.h          |    5 -
 mm/fremap.c                   |    2 
 mm/memory.c                   |  209 ++++++++++++++++--------------------------
 mm/mmap.c                     |   34 ++----
 mm/swap_state.c               |   12 --
 14 files changed, 163 insertions(+), 250 deletions(-)

--- 2.6.22/arch/i386/mm/init.c	2007-07-09 00:32:17.000000000 +0100
+++ linux/arch/i386/mm/init.c	2007-07-12 19:47:28.000000000 +0100
@@ -47,7 +47,6 @@
 
 unsigned int __VMALLOC_RESERVE = 128 << 20;
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
 unsigned long highstart_pfn, highend_pfn;
 
 static int noinline do_test_wp_bit(void);
--- 2.6.22/arch/ia64/mm/hugetlbpage.c	2007-07-09 00:32:17.000000000 +0100
+++ linux/arch/ia64/mm/hugetlbpage.c	2007-07-12 19:47:28.000000000 +0100
@@ -114,7 +114,7 @@ follow_huge_pmd(struct mm_struct *mm, un
 	return NULL;
 }
 
-void hugetlb_free_pgd_range(struct mmu_gather **tlb,
+void hugetlb_free_pgd_range(struct mmu_gather *tlb,
 			unsigned long addr, unsigned long end,
 			unsigned long floor, unsigned long ceiling)
 {
--- 2.6.22/arch/powerpc/mm/hugetlbpage.c	2007-07-09 00:32:17.000000000 +0100
+++ linux/arch/powerpc/mm/hugetlbpage.c	2007-07-12 19:47:28.000000000 +0100
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
 
--- 2.6.22/arch/x86_64/mm/init.c	2007-07-09 00:32:17.000000000 +0100
+++ linux/arch/x86_64/mm/init.c	2007-07-12 19:47:28.000000000 +0100
@@ -53,8 +53,6 @@ EXPORT_SYMBOL(dma_ops);
 
 static unsigned long dma_reserve __initdata;
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
-
 /*
  * NOTE: pagetable_init alloc all the fixmap pagetables contiguous on the
  * physical space so we can cache the place of the first one and move
--- 2.6.22/include/asm-generic/pgtable.h	2007-07-09 00:32:17.000000000 +0100
+++ linux/include/asm-generic/pgtable.h	2007-07-12 19:47:28.000000000 +0100
@@ -111,18 +111,6 @@ do {				  					\
 })
 #endif
 
-/*
- * Some architectures may be able to avoid expensive synchronization
- * primitives when modifications are made to PTE's which are already
- * not present, or in the process of an address space destruction.
- */
-#ifndef __HAVE_ARCH_PTE_CLEAR_NOT_PRESENT_FULL
-#define pte_clear_not_present_full(__mm, __address, __ptep, __full)	\
-do {									\
-	pte_clear((__mm), (__address), (__ptep));			\
-} while (0)
-#endif
-
 #ifndef __HAVE_ARCH_PTEP_CLEAR_FLUSH
 #define ptep_clear_flush(__vma, __address, __ptep)			\
 ({									\
--- 2.6.22/include/asm-generic/tlb.h	2006-11-29 21:57:37.000000000 +0000
+++ linux/include/asm-generic/tlb.h	2007-07-12 19:47:28.000000000 +0100
@@ -17,65 +17,77 @@
 #include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
 
-/*
- * For UP we don't need to worry about TLB flush
- * and page free order so much..
- */
-#ifdef CONFIG_SMP
-  #ifdef ARCH_FREE_PTR_NR
-    #define FREE_PTR_NR   ARCH_FREE_PTR_NR
-  #else
-    #define FREE_PTE_NR	506
-  #endif
-  #define tlb_fast_mode(tlb) ((tlb)->nr == ~0U)
-#else
-  #define FREE_PTE_NR	1
-  #define tlb_fast_mode(tlb) 1
-#endif
+#define TLB_TRUNC		0	/* i_mmap_lock is held */
+#define TLB_UNMAP		1	/* normal munmap or zap */
+#define TLB_EXIT		2	/* tearing down whole mm */
+
+#define TLB_FALLBACK_PAGES	8	/* a few entries on the stack */
 
 /* struct mmu_gather is an opaque type used by the mm code for passing around
  * any data needed by arch specific code for tlb_remove_page.
  */
 struct mmu_gather {
-	struct mm_struct	*mm;
-	unsigned int		nr;	/* set to ~0U means fast mode */
-	unsigned int		need_flush;/* Really unmapped some ptes? */
-	unsigned int		fullmm; /* non-zero means full mm flush */
-	struct page *		pages[FREE_PTE_NR];
+	struct mm_struct *mm;
+	short		nr;
+	short		max;
+	short		need_flush;	/* Really unmapped some ptes? */
+	short		mode;
+	struct page **	pages;
+	struct page *	fallback_pages[TLB_FALLBACK_PAGES];
 };
 
-/* Users of the generic TLB shootdown code must declare this storage space. */
-DECLARE_PER_CPU(struct mmu_gather, mmu_gathers);
-
 /* tlb_gather_mmu
- *	Return a pointer to an initialized struct mmu_gather.
+ *	Initialize struct mmu_gather.
  */
-static inline struct mmu_gather *
-tlb_gather_mmu(struct mm_struct *mm, unsigned int full_mm_flush)
+static inline void
+tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, int mode)
 {
-	struct mmu_gather *tlb = &get_cpu_var(mmu_gathers);
-
 	tlb->mm = mm;
-
-	/* Use fast mode if only one CPU is online */
-	tlb->nr = num_online_cpus() > 1 ? 0U : ~0U;
-
-	tlb->fullmm = full_mm_flush;
-
-	return tlb;
+	tlb->nr = 0;
+	tlb->max = TLB_FALLBACK_PAGES;
+	tlb->need_flush = 0;
+	tlb->mode = mode;
+	tlb->pages = tlb->fallback_pages;
+	/* temporarily erase fallback_pages for clearer debug traces */
+	memset(tlb->fallback_pages, 0, sizeof(tlb->fallback_pages));
 }
 
 static inline void
-tlb_flush_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
+tlb_flush_mmu(struct mmu_gather *tlb)
 {
 	if (!tlb->need_flush)
 		return;
 	tlb->need_flush = 0;
 	tlb_flush(tlb);
-	if (!tlb_fast_mode(tlb)) {
-		free_pages_and_swap_cache(tlb->pages, tlb->nr);
-		tlb->nr = 0;
+	free_pages_and_swap_cache(tlb->pages, tlb->nr);
+	tlb->nr = 0;
+}
+
+static inline int
+tlb_is_extensible(struct mmu_gather *tlb)
+{
+#ifdef CONFIG_PREEMPT
+	return tlb->mode != TLB_TRUNC;
+#else
+	return 1;
+#endif
+}
+
+static inline int
+tlb_is_full(struct mmu_gather *tlb)
+{
+	if (tlb->nr < tlb->max)
+		return 0;
+	if (tlb->pages == tlb->fallback_pages && tlb_is_extensible(tlb)) {
+		struct page **pages = (void *)__get_free_pages(GFP_ATOMIC|__GFP_NOWARN, 0);
+		if (pages) {
+			memcpy(pages, tlb->pages, sizeof(tlb->fallback_pages));
+			tlb->pages = pages;
+			tlb->max = PAGE_SIZE / sizeof(struct page *);
+			return 0;
+		}
 	}
+	return 1;
 }
 
 /* tlb_finish_mmu
@@ -83,14 +95,11 @@ tlb_flush_mmu(struct mmu_gather *tlb, un
  *	that were required.
  */
 static inline void
-tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
+tlb_finish_mmu(struct mmu_gather *tlb)
 {
-	tlb_flush_mmu(tlb, start, end);
-
-	/* keep the page table cache within bounds */
-	check_pgt_cache();
-
-	put_cpu_var(mmu_gathers);
+	tlb_flush_mmu(tlb);
+	if (tlb->pages != tlb->fallback_pages)
+		free_pages((unsigned long)tlb->pages, 0);
 }
 
 /* tlb_remove_page
@@ -100,14 +109,10 @@ tlb_finish_mmu(struct mmu_gather *tlb, u
  */
 static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 {
+	if (tlb->nr >= tlb->max)
+		tlb_flush_mmu(tlb);
 	tlb->need_flush = 1;
-	if (tlb_fast_mode(tlb)) {
-		free_page_and_swap_cache(page);
-		return;
-	}
 	tlb->pages[tlb->nr++] = page;
-	if (tlb->nr >= FREE_PTE_NR)
-		tlb_flush_mmu(tlb, 0, 0);
 }
 
 /**
--- 2.6.22/include/asm-x86_64/tlbflush.h	2007-07-09 00:32:17.000000000 +0100
+++ linux/include/asm-x86_64/tlbflush.h	2007-07-12 19:47:28.000000000 +0100
@@ -86,10 +86,6 @@ static inline void flush_tlb_range(struc
 #define TLBSTATE_OK	1
 #define TLBSTATE_LAZY	2
 
-/* Roughly an IPI every 20MB with 4k pages for freeing page table
-   ranges. Cost is about 42k of memory for each CPU. */
-#define ARCH_FREE_PTE_NR 5350	
-
 #endif
 
 #define flush_tlb_kernel_range(start, end) flush_tlb_all()
--- 2.6.22/include/linux/hugetlb.h	2007-07-09 00:32:17.000000000 +0100
+++ linux/include/linux/hugetlb.h	2007-07-12 19:47:28.000000000 +0100
@@ -52,7 +52,7 @@ void hugetlb_change_protection(struct vm
 #ifndef ARCH_HAS_HUGETLB_FREE_PGD_RANGE
 #define hugetlb_free_pgd_range	free_pgd_range
 #else
-void hugetlb_free_pgd_range(struct mmu_gather **tlb, unsigned long addr,
+void hugetlb_free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 			    unsigned long end, unsigned long floor,
 			    unsigned long ceiling);
 #endif
--- 2.6.22/include/linux/mm.h	2007-07-09 00:32:17.000000000 +0100
+++ linux/include/linux/mm.h	2007-07-12 19:47:28.000000000 +0100
@@ -738,15 +738,12 @@ struct zap_details {
 };
 
 struct page *vm_normal_page(struct vm_area_struct *, unsigned long, pte_t);
-unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
+void zap_page_range(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size, struct zap_details *);
-unsigned long unmap_vmas(struct mmu_gather **tlb,
-		struct vm_area_struct *start_vma, unsigned long start_addr,
-		unsigned long end_addr, unsigned long *nr_accounted,
-		struct zap_details *);
-void free_pgd_range(struct mmu_gather **tlb, unsigned long addr,
+void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma);
+void free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 		unsigned long end, unsigned long floor, unsigned long ceiling);
-void free_pgtables(struct mmu_gather **tlb, struct vm_area_struct *start_vma,
+void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma);
--- 2.6.22/include/linux/swap.h	2007-04-26 04:08:32.000000000 +0100
+++ linux/include/linux/swap.h	2007-07-12 19:47:28.000000000 +0100
@@ -232,7 +232,6 @@ extern void delete_from_swap_cache(struc
 extern int move_to_swap_cache(struct page *, swp_entry_t);
 extern int move_from_swap_cache(struct page *, unsigned long,
 		struct address_space *);
-extern void free_page_and_swap_cache(struct page *);
 extern void free_pages_and_swap_cache(struct page **, int);
 extern struct page * lookup_swap_cache(swp_entry_t);
 extern struct page * read_swap_cache_async(swp_entry_t, struct vm_area_struct *vma,
@@ -287,9 +286,7 @@ static inline void disable_swap_token(vo
 #define si_swapinfo(val) \
 	do { (val)->freeswap = (val)->totalswap = 0; } while (0)
 /* only sparc can not include linux/pagemap.h in this file
- * so leave page_cache_release and release_pages undeclared... */
-#define free_page_and_swap_cache(page) \
-	page_cache_release(page)
+ * so leave release_pages undeclared... */
 #define free_pages_and_swap_cache(pages, nr) \
 	release_pages((pages), (nr), 0);
 
--- 2.6.22/mm/fremap.c	2007-02-04 18:44:54.000000000 +0000
+++ linux/mm/fremap.c	2007-07-12 19:47:28.000000000 +0100
@@ -39,7 +39,7 @@ static int zap_pte(struct mm_struct *mm,
 	} else {
 		if (!pte_file(pte))
 			free_swap_and_cache(pte_to_swp_entry(pte));
-		pte_clear_not_present_full(mm, addr, ptep, 0);
+		pte_clear(mm, addr, ptep);
 	}
 	return !!page;
 }
--- 2.6.22/mm/memory.c	2007-07-09 00:32:17.000000000 +0100
+++ linux/mm/memory.c	2007-07-12 19:47:28.000000000 +0100
@@ -203,7 +203,7 @@ static inline void free_pud_range(struct
  *
  * Must be called with pagetable lock held.
  */
-void free_pgd_range(struct mmu_gather **tlb,
+void free_pgd_range(struct mmu_gather *tlb,
 			unsigned long addr, unsigned long end,
 			unsigned long floor, unsigned long ceiling)
 {
@@ -254,19 +254,19 @@ void free_pgd_range(struct mmu_gather **
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
+	if (tlb->mode != TLB_EXIT)
+		flush_tlb_pgtables(tlb->mm, start, end);
 }
 
-void free_pgtables(struct mmu_gather **tlb, struct vm_area_struct *vma,
+void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		unsigned long floor, unsigned long ceiling)
 {
 	while (vma) {
@@ -298,6 +298,9 @@ void free_pgtables(struct mmu_gather **t
 		}
 		vma = next;
 	}
+
+	/* keep the page table cache within bounds */
+	check_pgt_cache();
 }
 
 int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address)
@@ -621,24 +624,36 @@ int copy_page_range(struct mm_struct *ds
 static unsigned long zap_pte_range(struct mmu_gather *tlb,
 				struct vm_area_struct *vma, pmd_t *pmd,
 				unsigned long addr, unsigned long end,
-				long *zap_work, struct zap_details *details)
+				struct zap_details *details)
 {
+	spinlock_t *i_mmap_lock = details? details->i_mmap_lock: NULL;
 	struct mm_struct *mm = tlb->mm;
 	pte_t *pte;
 	spinlock_t *ptl;
 	int file_rss = 0;
 	int anon_rss = 0;
+	int progress;
 
+again:
+	progress = 0;
 	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	arch_enter_lazy_mmu_mode();
 	do {
-		pte_t ptent = *pte;
+		pte_t ptent;
+
+		if (progress >= 64) {
+			progress = 0;
+			if (need_resched() ||
+			    need_lockbreak(ptl) ||
+			    (i_mmap_lock && need_lockbreak(i_mmap_lock)))
+				break;
+		}
+		ptent = *pte;
 		if (pte_none(ptent)) {
-			(*zap_work)--;
+			progress++;
 			continue;
 		}
-
-		(*zap_work) -= PAGE_SIZE;
+		progress += 8;
 
 		if (pte_present(ptent)) {
 			struct page *page;
@@ -662,8 +677,10 @@ static unsigned long zap_pte_range(struc
 				     page->index > details->last_index))
 					continue;
 			}
+			if (tlb_is_full(tlb))
+				break;
 			ptent = ptep_get_and_clear_full(mm, addr, pte,
-							tlb->fullmm);
+						tlb->mode == TLB_EXIT);
 			tlb_remove_tlb_entry(tlb, pte, addr);
 			if (unlikely(!page))
 				continue;
@@ -693,20 +710,27 @@ static unsigned long zap_pte_range(struc
 			continue;
 		if (!pte_file(ptent))
 			free_swap_and_cache(pte_to_swp_entry(ptent));
-		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
-	} while (pte++, addr += PAGE_SIZE, (addr != end && *zap_work > 0));
+		pte_clear(mm, addr, pte);
+	} while (pte++, addr += PAGE_SIZE, addr != end);
 
 	add_mm_rss(mm, file_rss, anon_rss);
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(pte - 1, ptl);
 
+	if (!i_mmap_lock) {
+		cond_resched();
+		if (tlb_is_full(tlb))
+			tlb_flush_mmu(tlb);
+		if (addr != end)
+			goto again;
+	}
 	return addr;
 }
 
 static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
 				struct vm_area_struct *vma, pud_t *pud,
 				unsigned long addr, unsigned long end,
-				long *zap_work, struct zap_details *details)
+				struct zap_details *details)
 {
 	pmd_t *pmd;
 	unsigned long next;
@@ -715,20 +739,18 @@ static inline unsigned long zap_pmd_rang
 	do {
 		next = pmd_addr_end(addr, end);
 		if (pmd_none_or_clear_bad(pmd)) {
-			(*zap_work)--;
+			addr = next;
 			continue;
 		}
-		next = zap_pte_range(tlb, vma, pmd, addr, next,
-						zap_work, details);
-	} while (pmd++, addr = next, (addr != end && *zap_work > 0));
-
+		addr = zap_pte_range(tlb, vma, pmd, addr, next, details);
+	} while (pmd++, addr == next && addr != end);
 	return addr;
 }
 
 static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
 				struct vm_area_struct *vma, pgd_t *pgd,
 				unsigned long addr, unsigned long end,
-				long *zap_work, struct zap_details *details)
+				struct zap_details *details)
 {
 	pud_t *pud;
 	unsigned long next;
@@ -737,20 +759,18 @@ static inline unsigned long zap_pud_rang
 	do {
 		next = pud_addr_end(addr, end);
 		if (pud_none_or_clear_bad(pud)) {
-			(*zap_work)--;
+			addr = next;
 			continue;
 		}
-		next = zap_pmd_range(tlb, vma, pud, addr, next,
-						zap_work, details);
-	} while (pud++, addr = next, (addr != end && *zap_work > 0));
-
+		addr = zap_pmd_range(tlb, vma, pud, addr, next, details);
+	} while (pud++, addr == next && addr != end);
 	return addr;
 }
 
 static unsigned long unmap_page_range(struct mmu_gather *tlb,
 				struct vm_area_struct *vma,
 				unsigned long addr, unsigned long end,
-				long *zap_work, struct zap_details *details)
+				struct zap_details *details)
 {
 	pgd_t *pgd;
 	unsigned long next;
@@ -764,137 +784,62 @@ static unsigned long unmap_page_range(st
 	do {
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd)) {
-			(*zap_work)--;
+			addr = next;
 			continue;
 		}
-		next = zap_pud_range(tlb, vma, pgd, addr, next,
-						zap_work, details);
-	} while (pgd++, addr = next, (addr != end && *zap_work > 0));
+		addr = zap_pud_range(tlb, vma, pgd, addr, next, details);
+	} while (pgd++, addr == next && addr != end);
 	tlb_end_vma(tlb, vma);
-
 	return addr;
 }
 
-#ifdef CONFIG_PREEMPT
-# define ZAP_BLOCK_SIZE	(8 * PAGE_SIZE)
-#else
-/* No preempt: go for improved straight-line efficiency */
-# define ZAP_BLOCK_SIZE	(1024 * PAGE_SIZE)
-#endif
-
 /**
  * unmap_vmas - unmap a range of memory covered by a list of vma's
- * @tlbp: address of the caller's struct mmu_gather
+ * @tlb: address of the caller's struct mmu_gather
  * @vma: the starting vma
- * @start_addr: virtual address at which to start unmapping
- * @end_addr: virtual address at which to end unmapping
- * @nr_accounted: Place number of unmapped pages in vm-accountable vma's here
- * @details: details of nonlinear truncation or shared cache invalidation
- *
- * Returns the end address of the unmapping (restart addr if interrupted).
  *
  * Unmap all pages in the vma list.
- *
- * We aim to not hold locks for too long (for scheduling latency reasons).
- * So zap pages in ZAP_BLOCK_SIZE bytecounts.  This means we need to
- * return the ending mmu_gather to the caller.
- *
- * Only addresses between `start' and `end' will be unmapped.
- *
  * The VMA list must be sorted in ascending virtual address order.
- *
- * unmap_vmas() assumes that the caller will flush the whole unmapped address
- * range after unmap_vmas() returns.  So the only responsibility here is to
- * ensure that any thus-far unmapped pages are flushed before unmap_vmas()
- * drops the lock and schedules.
- */
-unsigned long unmap_vmas(struct mmu_gather **tlbp,
-		struct vm_area_struct *vma, unsigned long start_addr,
-		unsigned long end_addr, unsigned long *nr_accounted,
-		struct zap_details *details)
+ */
+void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *vma)
 {
-	long zap_work = ZAP_BLOCK_SIZE;
-	unsigned long tlb_start = 0;	/* For tlb_finish_mmu */
-	int tlb_start_valid = 0;
-	unsigned long start = start_addr;
-	spinlock_t *i_mmap_lock = details? details->i_mmap_lock: NULL;
-	int fullmm = (*tlbp)->fullmm;
-
-	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
-		unsigned long end;
-
-		start = max(vma->vm_start, start_addr);
-		if (start >= vma->vm_end)
-			continue;
-		end = min(vma->vm_end, end_addr);
-		if (end <= vma->vm_start)
-			continue;
+	unsigned long nr_accounted = 0;
 
+	while (vma) {
 		if (vma->vm_flags & VM_ACCOUNT)
-			*nr_accounted += (end - start) >> PAGE_SHIFT;
-
-		while (start != end) {
-			if (!tlb_start_valid) {
-				tlb_start = start;
-				tlb_start_valid = 1;
-			}
-
-			if (unlikely(is_vm_hugetlb_page(vma))) {
-				unmap_hugepage_range(vma, start, end);
-				zap_work -= (end - start) /
-						(HPAGE_SIZE / PAGE_SIZE);
-				start = end;
-			} else
-				start = unmap_page_range(*tlbp, vma,
-						start, end, &zap_work, details);
-
-			if (zap_work > 0) {
-				BUG_ON(start != end);
-				break;
-			}
+			nr_accounted += vma_pages(vma);
 
-			tlb_finish_mmu(*tlbp, tlb_start, start);
-
-			if (need_resched() ||
-				(i_mmap_lock && need_lockbreak(i_mmap_lock))) {
-				if (i_mmap_lock) {
-					*tlbp = NULL;
-					goto out;
-				}
-				cond_resched();
-			}
-
-			*tlbp = tlb_gather_mmu(vma->vm_mm, fullmm);
-			tlb_start_valid = 0;
-			zap_work = ZAP_BLOCK_SIZE;
-		}
+		if (unlikely(is_vm_hugetlb_page(vma)))
+			unmap_hugepage_range(vma, vma->vm_start, vma->vm_end);
+		else
+			unmap_page_range(tlb, vma, vma->vm_start, vma->vm_end, NULL);
+		vma = vma->vm_next;
 	}
-out:
-	return start;	/* which is now the end (or restart) address */
+
+	vm_unacct_memory(nr_accounted);
 }
 
 /**
  * zap_page_range - remove user pages in a given range
  * @vma: vm_area_struct holding the applicable pages
  * @address: starting address of pages to zap
- * @size: number of bytes to zap
+ * @end: ending address of pages to zap
  * @details: details of nonlinear truncation or shared cache invalidation
  */
-unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
+void zap_page_range(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size, struct zap_details *details)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	struct mmu_gather *tlb;
+	struct mmu_gather tlb;
 	unsigned long end = address + size;
-	unsigned long nr_accounted = 0;
 
-	lru_add_drain();
-	tlb = tlb_gather_mmu(mm, 0);
+	BUG_ON(is_vm_hugetlb_page(vma));
+	BUG_ON(address < vma->vm_start || end > vma->vm_end);
+
+	tlb_gather_mmu(&tlb, mm, TLB_UNMAP);
 	update_hiwater_rss(mm);
-	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
-	if (tlb)
-		tlb_finish_mmu(tlb, address, end);
-	return end;
+	unmap_page_range(&tlb, vma, address, end, details);
+	tlb_finish_mmu(&tlb);
 }
 
 /*
@@ -1822,6 +1767,8 @@ static int unmap_mapping_range_vma(struc
 		unsigned long start_addr, unsigned long end_addr,
 		struct zap_details *details)
 {
+	struct mm_struct *mm = vma->vm_mm;
+	struct mmu_gather tlb;
 	unsigned long restart_addr;
 	int need_break;
 
@@ -1836,8 +1783,12 @@ again:
 		}
 	}
 
-	restart_addr = zap_page_range(vma, start_addr,
-					end_addr - start_addr, details);
+	tlb_gather_mmu(&tlb, mm, TLB_TRUNC);
+	update_hiwater_rss(mm);
+	restart_addr = unmap_page_range(&tlb, vma,
+					start_addr, end_addr, details);
+	tlb_finish_mmu(&tlb);
+
 	need_break = need_resched() ||
 			need_lockbreak(details->i_mmap_lock);
 
--- 2.6.22/mm/mmap.c	2007-07-09 00:32:17.000000000 +0100
+++ linux/mm/mmap.c	2007-07-12 19:47:28.000000000 +0100
@@ -36,8 +36,7 @@
 #endif
 
 static void unmap_region(struct mm_struct *mm,
-		struct vm_area_struct *vma, struct vm_area_struct *prev,
-		unsigned long start, unsigned long end);
+		struct vm_area_struct *vma, struct vm_area_struct *prev);
 
 /*
  * WARNING: the debugging will use recursive algorithms so never enable this
@@ -1165,7 +1164,7 @@ unmap_and_free_vma:
 	fput(file);
 
 	/* Undo any partial mapping done by a device driver. */
-	unmap_region(mm, vma, prev, vma->vm_start, vma->vm_end);
+	unmap_region(mm, vma, prev);
 	charged = 0;
 free_vma:
 	kmem_cache_free(vm_area_cachep, vma);
@@ -1677,21 +1676,17 @@ static void remove_vma_list(struct mm_st
  * Called with the mm semaphore held.
  */
 static void unmap_region(struct mm_struct *mm,
-		struct vm_area_struct *vma, struct vm_area_struct *prev,
-		unsigned long start, unsigned long end)
+		struct vm_area_struct *vma, struct vm_area_struct *prev)
 {
 	struct vm_area_struct *next = prev? prev->vm_next: mm->mmap;
-	struct mmu_gather *tlb;
-	unsigned long nr_accounted = 0;
+	struct mmu_gather tlb;
 
-	lru_add_drain();
-	tlb = tlb_gather_mmu(mm, 0);
+	tlb_gather_mmu(&tlb, mm, TLB_UNMAP);
 	update_hiwater_rss(mm);
-	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
-	vm_unacct_memory(nr_accounted);
+	unmap_vmas(&tlb, vma);
 	free_pgtables(&tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
 				 next? next->vm_start: 0);
-	tlb_finish_mmu(tlb, start, end);
+	tlb_finish_mmu(&tlb);
 }
 
 /*
@@ -1829,7 +1824,7 @@ int do_munmap(struct mm_struct *mm, unsi
 	 * Remove the vma's, and unmap the actual pages
 	 */
 	detach_vmas_to_be_unmapped(mm, vma, prev, end);
-	unmap_region(mm, vma, prev, start, end);
+	unmap_region(mm, vma, prev);
 
 	/* Fix up all other VM information */
 	remove_vma_list(mm, vma);
@@ -1968,23 +1963,18 @@ EXPORT_SYMBOL(do_brk);
 /* Release all mmaps. */
 void exit_mmap(struct mm_struct *mm)
 {
-	struct mmu_gather *tlb;
+	struct mmu_gather tlb;
 	struct vm_area_struct *vma = mm->mmap;
-	unsigned long nr_accounted = 0;
-	unsigned long end;
 
 	/* mm's last user has gone, and its about to be pulled down */
 	arch_exit_mmap(mm);
 
-	lru_add_drain();
 	flush_cache_mm(mm);
-	tlb = tlb_gather_mmu(mm, 1);
+	tlb_gather_mmu(&tlb, mm, TLB_EXIT);
 	/* Don't update_hiwater_rss(mm) here, do_exit already did */
-	/* Use -1 here to ensure all VMAs in the mm are unmapped */
-	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
-	vm_unacct_memory(nr_accounted);
+	unmap_vmas(&tlb, vma);
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, 0);
-	tlb_finish_mmu(tlb, 0, end);
+	tlb_finish_mmu(&tlb);
 
 	/*
 	 * Walk the list again, actually closing and freeing it,
--- 2.6.22/mm/swap_state.c	2006-09-20 04:42:06.000000000 +0100
+++ linux/mm/swap_state.c	2007-07-12 19:47:28.000000000 +0100
@@ -258,16 +258,6 @@ static inline void free_swap_cache(struc
 	}
 }
 
-/* 
- * Perform a free_page(), also freeing any swap cache associated with
- * this page if it is the last user of the page.
- */
-void free_page_and_swap_cache(struct page *page)
-{
-	free_swap_cache(page);
-	page_cache_release(page);
-}
-
 /*
  * Passed an array of pages, drop them all from swapcache and then release
  * them.  They are removed from the LRU and freed if this is their last use.
@@ -286,6 +276,8 @@ void free_pages_and_swap_cache(struct pa
 		release_pages(pagep, todo, 0);
 		pagep += todo;
 		nr -= todo;
+		if (nr && !preempt_count())
+			cond_resched();
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
