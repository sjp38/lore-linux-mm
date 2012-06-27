Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id F084E6B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 17:42:10 -0400 (EDT)
Message-Id: <20120627212831.353649870@chello.nl>
Date: Wed, 27 Jun 2012 23:15:51 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 11/20] mm, s390: Convert to use generic mmu_gather
References: <20120627211540.459910855@chello.nl>
Content-Disposition: inline; filename=s390-mmu_range.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

Now that s390 is using the generic RCU freeing of page-table pages,
all that remains different wrt the generic mmu_gather code is the lack
of mmu_gather based TLB flushing for regular entries.

S390 doesn't need a TLB flush after ptep_get_and_clear_full() and
before __tlb_remove_page() because its ptep_get_and_clear*() family
already does a full TLB invalidate. Therefore force it to use
tlb_fast_mode.

Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/s390/include/asm/pgtable.h |    1 
 arch/s390/include/asm/tlb.h     |   85 ++++------------------------------------
 include/asm-generic/tlb.h       |    7 +++
 3 files changed, 17 insertions(+), 76 deletions(-)
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -1242,6 +1242,7 @@ extern int s390_enable_sie(void);
  * No page table caches to initialise
  */
 #define pgtable_cache_init()	do { } while (0)
+#define check_pgt_cache()	do { } while (0)
 
 #include <asm-generic/pgtable.h>
 
--- a/arch/s390/include/asm/tlb.h
+++ b/arch/s390/include/asm/tlb.h
@@ -28,82 +28,16 @@
 #include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
 
-struct mmu_gather {
-	struct mm_struct *mm;
-#ifdef CONFIG_HAVE_RCU_TABLE_FREE
-	struct mmu_table_batch *batch;
-#endif
-	unsigned int fullmm;
-	unsigned int need_flush;
-};
-
-#ifdef CONFIG_HAVE_RCU_TABLE_FREE
-struct mmu_table_batch {
-	struct rcu_head		rcu;
-	unsigned int		nr;
-	void			*tables[0];
-};
-
-#define MAX_TABLE_BATCH		\
-	((PAGE_SIZE - sizeof(struct mmu_table_batch)) / sizeof(void *))
-
-extern void tlb_table_flush(struct mmu_gather *tlb);
-extern void tlb_remove_table(struct mmu_gather *tlb, void *table);
-#endif
-
-static inline void tlb_gather_mmu(struct mmu_gather *tlb,
-				  struct mm_struct *mm,
-				  unsigned int full_mm_flush)
-{
-	tlb->mm = mm;
-	tlb->fullmm = full_mm_flush;
-	tlb->need_flush = 0;
-#ifdef CONFIG_HAVE_RCU_TABLE_FREE
-	tlb->batch = NULL;
-#endif
-	if (tlb->fullmm)
-		__tlb_flush_mm(mm);
-}
-
-static inline void tlb_flush_mmu(struct mmu_gather *tlb)
-{
-	if (!tlb->need_flush)
-		return;
-	tlb->need_flush = 0;
-	__tlb_flush_mm(tlb->mm);
-#ifdef CONFIG_HAVE_RCU_TABLE_FREE
-	tlb_table_flush(tlb);
-#endif
-}
-
-static inline void tlb_finish_mmu(struct mmu_gather *tlb,
-				  unsigned long start, unsigned long end)
-{
-	tlb_flush_mmu(tlb);
-}
+#define tlb_fast_mode(tlb)	(1)
 
-/*
- * Release the page cache reference for a pte removed by
- * tlb_ptep_clear_flush. In both flush modes the tlb for a page cache page
- * has already been freed, so just do free_page_and_swap_cache.
- */
-static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
-{
-	free_page_and_swap_cache(page);
-	return 1; /* avoid calling tlb_flush_mmu */
-}
-
-static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
-{
-	free_page_and_swap_cache(page);
-}
+#include <asm-generic/tlb.h>
 
 /*
  * pte_free_tlb frees a pte table and clears the CRSTE for the
  * page table from the tlb.
  */
-static inline void pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
-				unsigned long address, unsigned long end)
+static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
+				unsigned long address)
 {
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	if (!tlb->fullmm)
@@ -119,8 +53,8 @@ static inline void pte_free_tlb(struct m
  * as the pgd. pmd_free_tlb checks the asce_limit against 2GB
  * to avoid the double free of the pmd in this case.
  */
-static inline void pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd,
-				unsigned long address, unsigned long end)
+static inline void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd,
+				unsigned long address)
 {
 #ifdef CONFIG_64BIT
 	if (tlb->mm->context.asce_limit <= (1UL << 31))
@@ -140,8 +74,8 @@ static inline void pmd_free_tlb(struct m
  * as the pgd. pud_free_tlb checks the asce_limit against 4TB
  * to avoid the double free of the pud in this case.
  */
-static inline void pud_free_tlb(struct mmu_gather *tlb, pud_t *pud,
-				unsigned long address, unsigned long end)
+static inline void __pud_free_tlb(struct mmu_gather *tlb, pud_t *pud,
+				unsigned long address)
 {
 #ifdef CONFIG_64BIT
 	if (tlb->mm->context.asce_limit <= (1UL << 42))
@@ -156,7 +90,6 @@ static inline void pud_free_tlb(struct m
 
 #define tlb_start_vma(tlb, vma)			do { } while (0)
 #define tlb_end_vma(tlb, vma)			do { } while (0)
-#define tlb_remove_tlb_entry(tlb, ptep, addr)	do { } while (0)
-#define tlb_migrate_finish(mm)			do { } while (0)
+#define __tlb_remove_tlb_entry(tlb, ptep, addr)	do { } while (0)
 
 #endif /* _S390_TLB_H */
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -207,6 +207,12 @@ static inline void tlb_flush(struct mmu_
 
 #endif /* CONFIG_HAVE_MMU_GATHER_RANGE */
 
+/*
+ * Some architectures (s390) do a TLB flush from their ptep_get_and_clear*()
+ * functions, these archs don't need another TLB invalidate and can free their
+ * pages immediately. They'll over-ride tlb_fast_mode with a constant enable.
+ */
+#ifndef tlb_fast_mode
 static inline int tlb_fast_mode(struct mmu_gather *tlb)
 {
 #ifdef CONFIG_SMP
@@ -219,6 +225,7 @@ static inline int tlb_fast_mode(struct m
 	return 1;
 #endif
 }
+#endif
 
 void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, bool fullmm);
 void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
