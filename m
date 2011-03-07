Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0CB608D003B
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 12:49:26 -0500 (EST)
Message-Id: <20110307172207.105394031@chello.nl>
Date: Mon, 07 Mar 2011 18:13:59 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 09/15] mm, sh: Convert sh to generic tlb
References: <20110307171350.989666626@chello.nl>
Content-Disposition: inline; filename=mm-sh-tlb-range.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Paul Mundt <lethal@linux-sh.org>

Cc: Paul Mundt <lethal@linux-sh.org>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/sh/Kconfig           |    1 
 arch/sh/include/asm/tlb.h |   98 ++--------------------------------------------
 2 files changed, 6 insertions(+), 93 deletions(-)

Index: linux-2.6/arch/sh/Kconfig
===================================================================
--- linux-2.6.orig/arch/sh/Kconfig
+++ linux-2.6/arch/sh/Kconfig
@@ -24,6 +24,7 @@ config SUPERH
 	select HAVE_SPARSE_IRQ
 	select RTC_LIB
 	select GENERIC_ATOMIC64
+	select HAVE_MMU_GATHER_RANGE if MMU
 	# Support the deprecated APIs until MFD and GPIOLIB catch up.
 	select GENERIC_HARDIRQS_NO_DEPRECATED if !MFD_SUPPORT && !GPIOLIB
 	help
Index: linux-2.6/arch/sh/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/sh/include/asm/tlb.h
+++ linux-2.6/arch/sh/include/asm/tlb.h
@@ -9,100 +9,14 @@
 #include <linux/pagemap.h>
 
 #ifdef CONFIG_MMU
-#include <asm/pgalloc.h>
-#include <asm/tlbflush.h>
-#include <asm/mmu_context.h>
-
-/*
- * TLB handling.  This allows us to remove pages from the page
- * tables, and efficiently handle the TLB issues.
- */
-struct mmu_gather {
-	struct mm_struct	*mm;
-	unsigned int		fullmm;
-	unsigned long		start, end;
-};
 
-static inline void init_tlb_gather(struct mmu_gather *tlb)
-{
-	tlb->start = TASK_SIZE;
-	tlb->end = 0;
-
-	if (tlb->fullmm) {
-		tlb->start = 0;
-		tlb->end = TASK_SIZE;
-	}
-}
-
-static inline void
-tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned int full_mm_flush)
-{
-	tlb->mm = mm;
-	tlb->fullmm = full_mm_flush;
-
-	init_tlb_gather(tlb);
-}
-
-static inline void
-tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
-{
-	if (tlb->fullmm)
-		flush_tlb_mm(tlb->mm);
-
-	/* keep the page table cache within bounds */
-	check_pgt_cache();
-}
-
-static inline void
-tlb_remove_tlb_entry(struct mmu_gather *tlb, pte_t *ptep, unsigned long address)
-{
-	if (tlb->start > address)
-		tlb->start = address;
-	if (tlb->end < address + PAGE_SIZE)
-		tlb->end = address + PAGE_SIZE;
-}
-
-/*
- * In the case of tlb vma handling, we can optimise these away in the
- * case where we're doing a full MM flush.  When we're doing a munmap,
- * the vmas are adjusted to only cover the region to be torn down.
- */
-static inline void
-tlb_start_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
-{
-	if (!tlb->fullmm)
-		flush_cache_range(vma, vma->vm_start, vma->vm_end);
-}
-
-static inline void
-tlb_end_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
-{
-	if (!tlb->fullmm && tlb->end) {
-		flush_tlb_range(vma, tlb->start, tlb->end);
-		init_tlb_gather(tlb);
-	}
-}
+#define __tlb_remove_tlb_entry(tlb, ptep, addr) do { } while (0)
 
-static inline void tlb_flush_mmu(struct mmu_gather *tlb)
-{
-}
+#define __pte_free_tlb(tlb, ptep, addr)	pte_free((tlb)->mm, ptep)
+#define __pmd_free_tlb(tlb, pmdp, addr)	pmd_free((tlb)->mm, pmdp)
+#define __pud_free_tlb(tlb, pudp, addr)	pud_free((tlb)->mm, pudp)
 
-static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
-{
-	free_page_and_swap_cache(page);
-	return 0;
-}
-
-static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
-{
-	__tlb_remove_page(tlb, page);
-}
-
-#define pte_free_tlb(tlb, ptep, addr)	pte_free((tlb)->mm, ptep)
-#define pmd_free_tlb(tlb, pmdp, addr)	pmd_free((tlb)->mm, pmdp)
-#define pud_free_tlb(tlb, pudp, addr)	pud_free((tlb)->mm, pudp)
-
-#define tlb_migrate_finish(mm)		do { } while (0)
+#include <asm-generic/tlb.h>
 
 #if defined(CONFIG_CPU_SH4) || defined(CONFIG_SUPERH64)
 extern void tlb_wire_entry(struct vm_area_struct *, unsigned long, pte_t);
@@ -122,8 +36,6 @@ static inline void tlb_unwire_entry(void
 
 #else /* CONFIG_MMU */
 
-#define tlb_start_vma(tlb, vma)				do { } while (0)
-#define tlb_end_vma(tlb, vma)				do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, pte, address)	do { } while (0)
 
 #include <asm-generic/tlb.h>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
