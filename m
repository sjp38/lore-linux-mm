Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BEE408D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 12:48:51 -0500 (EST)
Message-Id: <20110307172207.172882920@chello.nl>
Date: Mon, 07 Mar 2011 18:14:00 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 10/15] mm, um, Convert um to generic tlb
References: <20110307171350.989666626@chello.nl>
Content-Disposition: inline; filename=um-tlb-range.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Jeff Dike <jdike@addtoit.com>


Cc: Jeff Dike <jdike@addtoit.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/um/Kconfig.common    |    1 
 arch/um/include/asm/tlb.h |  111 +---------------------------------------------
 arch/um/kernel/tlb.c      |   13 -----
 3 files changed, 4 insertions(+), 121 deletions(-)

Index: linux-2.6/arch/um/Kconfig.common
===================================================================
--- linux-2.6.orig/arch/um/Kconfig.common
+++ linux-2.6/arch/um/Kconfig.common
@@ -8,6 +8,7 @@ config UML
 	default y
 	select HAVE_GENERIC_HARDIRQS
 	select GENERIC_HARDIRQS_NO_DEPRECATED
+	select HAVE_MMU_GATHER_RANGE
 
 config MMU
 	bool
Index: linux-2.6/arch/um/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/um/include/asm/tlb.h
+++ linux-2.6/arch/um/include/asm/tlb.h
@@ -7,114 +7,9 @@
 #include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
 
-#define tlb_start_vma(tlb, vma) do { } while (0)
-#define tlb_end_vma(tlb, vma) do { } while (0)
-#define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
-
-/* struct mmu_gather is an opaque type used by the mm code for passing around
- * any data needed by arch specific code for tlb_remove_page.
- */
-struct mmu_gather {
-	struct mm_struct	*mm;
-	unsigned int		need_flush; /* Really unmapped some ptes? */
-	unsigned long		start;
-	unsigned long		end;
-	unsigned int		fullmm; /* non-zero means full mm flush */
-};
-
-static inline void __tlb_remove_tlb_entry(struct mmu_gather *tlb, pte_t *ptep,
-					  unsigned long address)
-{
-	if (tlb->start > address)
-		tlb->start = address;
-	if (tlb->end < address + PAGE_SIZE)
-		tlb->end = address + PAGE_SIZE;
-}
-
-static inline void init_tlb_gather(struct mmu_gather *tlb)
-{
-	tlb->need_flush = 0;
-
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
-extern void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
-			       unsigned long end);
-
-static inline void
-tlb_flush_mmu(struct mmu_gather *tlb)
-{
-	if (!tlb->need_flush)
-		return;
-
-	flush_tlb_mm_range(tlb->mm, tlb->start, tlb->end);
-	init_tlb_gather(tlb);
-}
-
-/* tlb_finish_mmu
- *	Called at the end of the shootdown operation to free up any resources
- *	that were required.
- */
-static inline void
-tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
-{
-	tlb_flush_mmu(tlb);
-
-	/* keep the page table cache within bounds */
-	check_pgt_cache();
-}
-
-/* tlb_remove_page
- *	Must perform the equivalent to __free_pte(pte_get_and_clear(ptep)),
- *	while handling the additional races in SMP caused by other CPUs
- *	caching valid mappings in their TLBs.
- */
-static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
-{
-	tlb->need_flush = 1;
-	free_page_and_swap_cache(page);
-	return 0;
-}
-
-static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
-{
-	__tlb_remove_page(tlb, page);
-}
-
-/**
- * tlb_remove_tlb_entry - remember a pte unmapping for later tlb invalidation.
- *
- * Record the fact that pte's were really umapped in ->need_flush, so we can
- * later optimise away the tlb invalidate.   This helps when userspace is
- * unmapping already-unmapped pages, which happens quite a lot.
- */
-#define tlb_remove_tlb_entry(tlb, ptep, address)		\
-	do {							\
-		tlb->need_flush = 1;				\
-		__tlb_remove_tlb_entry(tlb, ptep, address);	\
-	} while (0)
-
-#define pte_free_tlb(tlb, ptep, addr) __pte_free_tlb(tlb, ptep, addr)
-
-#define pud_free_tlb(tlb, pudp, addr) __pud_free_tlb(tlb, pudp, addr)
-
-#define pmd_free_tlb(tlb, pmdp, addr) __pmd_free_tlb(tlb, pmdp, addr)
-
+#define __tlb_remove_tlb_entry(tlb, ptep, addr) do { } while (0)
 #define tlb_migrate_finish(mm) do {} while (0)
 
+#include <asm-generic/tlb.h>
+
 #endif
Index: linux-2.6/arch/um/kernel/tlb.c
===================================================================
--- linux-2.6.orig/arch/um/kernel/tlb.c
+++ linux-2.6/arch/um/kernel/tlb.c
@@ -500,19 +500,6 @@ void flush_tlb_range(struct vm_area_stru
 	else fix_range(vma->vm_mm, start, end, 0);
 }
 
-void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
-			unsigned long end)
-{
-	/*
-	 * Don't bother flushing if this address space is about to be
-	 * destroyed.
-	 */
-	if (atomic_read(&mm->mm_users) == 0)
-		return;
-
-	fix_range(mm, start, end, 0);
-}
-
 void flush_tlb_mm(struct mm_struct *mm)
 {
 	struct vm_area_struct *vma = mm->mmap;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
