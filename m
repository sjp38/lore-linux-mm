Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 9D9966B0080
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 17:41:48 -0400 (EDT)
Message-Id: <20120627212831.427991657@chello.nl>
Date: Wed, 27 Jun 2012 23:15:52 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 12/20] mm, arm: Convert arm to generic tlb
References: <20120627211540.459910855@chello.nl>
Content-Disposition: inline; filename=mm-arm-tlb-range.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

Might want to optimize the tlb_flush() function to do a full mm flush
when the range is 'large', IA64 does this too.

Cc: Russell King <rmk@arm.linux.org.uk>
Fixes-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/arm/Kconfig           |    1 
 arch/arm/include/asm/tlb.h |  181 +++------------------------------------------
 include/asm-generic/tlb.h  |    4 
 3 files changed, 19 insertions(+), 167 deletions(-)
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -45,6 +45,7 @@ config ARM
 	select GENERIC_SMP_IDLE_THREAD
 	select KTIME_SCALAR
 	select GENERIC_CLOCKEVENTS_BROADCAST if SMP
+	select HAVE_MMU_GATHER_RANGE if MMU
 	help
 	  The ARM series is a line of low-power-consumption RISC chip designs
 	  licensed by ARM Ltd and targeted at embedded applications and
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -27,183 +27,37 @@
 
 #else /* !CONFIG_MMU */
 
-#include <linux/swap.h>
-#include <asm/pgalloc.h>
-#include <asm/tlbflush.h>
-
-/*
- * We need to delay page freeing for SMP as other CPUs can access pages
- * which have been removed but not yet had their TLB entries invalidated.
- * Also, as ARMv7 speculative prefetch can drag new entries into the TLB,
- * we need to apply this same delaying tactic to ensure correct operation.
- */
-#if defined(CONFIG_SMP) || defined(CONFIG_CPU_32v7)
-#define tlb_fast_mode(tlb)	0
-#else
-#define tlb_fast_mode(tlb)	1
-#endif
-
-#define MMU_GATHER_BUNDLE	8
-
-/*
- * TLB handling.  This allows us to remove pages from the page
- * tables, and efficiently handle the TLB issues.
- */
-struct mmu_gather {
-	struct mm_struct	*mm;
-	unsigned int		fullmm;
-	struct vm_area_struct	*vma;
-	unsigned long		range_start;
-	unsigned long		range_end;
-	unsigned int		nr;
-	unsigned int		max;
-	struct page		**pages;
-	struct page		*local[MMU_GATHER_BUNDLE];
-};
-
-DECLARE_PER_CPU(struct mmu_gather, mmu_gathers);
-
-/*
- * This is unnecessarily complex.  There's three ways the TLB shootdown
- * code is used:
- *  1. Unmapping a range of vmas.  See zap_page_range(), unmap_region().
- *     tlb->fullmm = 0, and tlb_start_vma/tlb_end_vma will be called.
- *     tlb->vma will be non-NULL.
- *  2. Unmapping all vmas.  See exit_mmap().
- *     tlb->fullmm = 1, and tlb_start_vma/tlb_end_vma will be called.
- *     tlb->vma will be non-NULL.  Additionally, page tables will be freed.
- *  3. Unmapping argument pages.  See shift_arg_pages().
- *     tlb->fullmm = 0, but tlb_start_vma/tlb_end_vma will not be called.
- *     tlb->vma will be NULL.
- */
-static inline void tlb_flush(struct mmu_gather *tlb)
-{
-	if (tlb->fullmm || !tlb->vma)
-		flush_tlb_mm(tlb->mm);
-	else if (tlb->range_end > 0) {
-		flush_tlb_range(tlb->vma, tlb->range_start, tlb->range_end);
-		tlb->range_start = TASK_SIZE;
-		tlb->range_end = 0;
-	}
-}
-
-static inline void tlb_add_flush(struct mmu_gather *tlb, unsigned long addr)
-{
-	if (!tlb->fullmm) {
-		if (addr < tlb->range_start)
-			tlb->range_start = addr;
-		if (addr + PAGE_SIZE > tlb->range_end)
-			tlb->range_end = addr + PAGE_SIZE;
-	}
-}
-
-static inline void __tlb_alloc_page(struct mmu_gather *tlb)
-{
-	unsigned long addr = __get_free_pages(GFP_NOWAIT | __GFP_NOWARN, 0);
-
-	if (addr) {
-		tlb->pages = (void *)addr;
-		tlb->max = PAGE_SIZE / sizeof(struct page *);
-	}
-}
-
-static inline void tlb_flush_mmu(struct mmu_gather *tlb)
-{
-	tlb_flush(tlb);
-	if (!tlb_fast_mode(tlb)) {
-		free_pages_and_swap_cache(tlb->pages, tlb->nr);
-		tlb->nr = 0;
-		if (tlb->pages == tlb->local)
-			__tlb_alloc_page(tlb);
-	}
-}
+#define __tlb_remove_tlb_entry(tlb, ptep, addr) do { } while (0)
 
 static inline void
-tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned int fullmm)
-{
-	tlb->mm = mm;
-	tlb->fullmm = fullmm;
-	tlb->vma = NULL;
-	tlb->max = ARRAY_SIZE(tlb->local);
-	tlb->pages = tlb->local;
-	tlb->nr = 0;
-	__tlb_alloc_page(tlb);
-}
+__pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte, unsigned long addr);
 
 static inline void
-tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
-{
-	tlb_flush_mmu(tlb);
-
-	/* keep the page table cache within bounds */
-	check_pgt_cache();
-
-	if (tlb->pages != tlb->local)
-		free_pages((unsigned long)tlb->pages, 0);
-}
+__pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmdp, unsigned long addr);
 
 /*
- * Memorize the range for the TLB flush.
+ * ARMv7 speculative prefetch can drag new entries into the TLB at any time
+ * so we have to unconditionally disable tlb_fast_mode, even on UP.
  */
-static inline void
-tlb_remove_tlb_entry(struct mmu_gather *tlb, pte_t *ptep, unsigned long addr)
-{
-	tlb_add_flush(tlb, addr);
-}
+#ifdef CONFIG_CPU_32v7
+#define tlb_fast_mode(tlb)	(0)
+#endif
 
-/*
- * In the case of tlb vma handling, we can optimise these away in the
- * case where we're doing a full MM flush.  When we're doing a munmap,
- * the vmas are adjusted to only cover the region to be torn down.
- */
-static inline void
-tlb_start_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
-{
-	if (!tlb->fullmm) {
-		flush_cache_range(vma, vma->vm_start, vma->vm_end);
-		tlb->vma = vma;
-		tlb->range_start = TASK_SIZE;
-		tlb->range_end = 0;
-	}
-}
+#include <asm-generic/tlb.h>
 
 static inline void
-tlb_end_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
-{
-	if (!tlb->fullmm)
-		tlb_flush(tlb);
-}
-
-static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
-{
-	if (tlb_fast_mode(tlb)) {
-		free_page_and_swap_cache(page);
-		return 1; /* avoid calling tlb_flush_mmu */
-	}
-
-	tlb->pages[tlb->nr++] = page;
-	VM_BUG_ON(tlb->nr > tlb->max);
-	return tlb->max - tlb->nr;
-}
-
-static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
-{
-	if (!__tlb_remove_page(tlb, page))
-		tlb_flush_mmu(tlb);
-}
-
-static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
-	unsigned long addr)
+__pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte, unsigned long addr)
 {
 	pgtable_page_dtor(pte);
 
+#ifndef CONFIG_ARM_LPAE
 	/*
 	 * With the classic ARM MMU, a pte page has two corresponding pmd
 	 * entries, each covering 1MB.
 	 */
-	addr &= PMD_MASK;
-	tlb_add_flush(tlb, addr + SZ_1M - PAGE_SIZE);
-	tlb_add_flush(tlb, addr + SZ_1M);
+	addr = (addr & PMD_MASK) + SZ_1M;
+	tlb_track_range(tlb, addr - PAGE_SIZE, addr + PAGE_SIZE);
+#endif
 
 	tlb_remove_page(tlb, pte);
 }
@@ -212,16 +66,9 @@ static inline void __pmd_free_tlb(struct
 				  unsigned long addr)
 {
 #ifdef CONFIG_ARM_LPAE
-	tlb_add_flush(tlb, addr);
 	tlb_remove_page(tlb, virt_to_page(pmdp));
 #endif
 }
 
-#define pte_free_tlb(tlb, ptep, addr, end)	__pte_free_tlb(tlb, ptep, addr)
-#define pmd_free_tlb(tlb, pmdp, addr, end)	__pmd_free_tlb(tlb, pmdp, addr)
-#define pud_free_tlb(tlb, pudp, addr, end)	pud_free((tlb)->mm, pudp)
-
-#define tlb_migrate_finish(mm)		do { } while (0)
-
 #endif /* CONFIG_MMU */
 #endif
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -286,6 +286,10 @@ static inline void tlb_flush(struct mmu_
  * Some architectures (s390) do a TLB flush from their ptep_get_and_clear*()
  * functions, these archs don't need another TLB invalidate and can free their
  * pages immediately. They'll over-ride tlb_fast_mode with a constant enable.
+ *
+ * Other archs (ARMv7) can have speculative TLB loaders such that we have
+ * concurrency, even on UP, and have to over-ride tlb_fast_mode with a constant
+ * disable.
  */
 #ifndef tlb_fast_mode
 static inline int tlb_fast_mode(struct mmu_gather *tlb)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
