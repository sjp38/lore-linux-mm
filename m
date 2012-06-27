Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 8AE5B6B0068
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 17:41:14 -0400 (EDT)
Message-Id: <20120627212830.838775622@chello.nl>
Date: Wed, 27 Jun 2012 23:15:44 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 04/20] mm, s390: use generic RCU page-table freeing code
References: <20120627211540.459910855@chello.nl>
Content-Disposition: inline; filename=s390-use-generic-rcu-page-table-free.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

Now that we fixed the problem that caused the revert cd94154cc6a
("[S390] fix tlb flushing for page table pages") of the original
36409f6353fc2 ("[S390] use generic RCU page-table freeing code"), we
can revert the revert.

Original-patch-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/s390/Kconfig               |    1 
 arch/s390/include/asm/pgalloc.h |    3 +
 arch/s390/include/asm/tlb.h     |   22 +++++++++++++
 arch/s390/mm/pgtable.c          |   63 +---------------------------------------
 4 files changed, 28 insertions(+), 61 deletions(-)

--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -84,6 +84,7 @@ config S390
 	select HAVE_KERNEL_XZ
 	select HAVE_ARCH_MUTEX_CPU_RELAX
 	select HAVE_ARCH_JUMP_LABEL if !MARCH_G5
+	select HAVE_RCU_TABLE_FREE if SMP
 	select ARCH_SAVE_PAGE_KEYS if HIBERNATION
 	select HAVE_MEMBLOCK
 	select HAVE_MEMBLOCK_NODE_MAP
--- a/arch/s390/include/asm/pgalloc.h
+++ b/arch/s390/include/asm/pgalloc.h
@@ -22,7 +22,10 @@ void crst_table_free(struct mm_struct *,
 
 unsigned long *page_table_alloc(struct mm_struct *, unsigned long);
 void page_table_free(struct mm_struct *, unsigned long *);
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
 void page_table_free_rcu(struct mmu_gather *, unsigned long *);
+void __tlb_remove_table(void *_table);
+#endif
 
 static inline void clear_table(unsigned long *s, unsigned long val, size_t n)
 {
--- a/arch/s390/include/asm/tlb.h
+++ b/arch/s390/include/asm/tlb.h
@@ -30,10 +30,14 @@
 
 struct mmu_gather {
 	struct mm_struct *mm;
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	struct mmu_table_batch *batch;
+#endif
 	unsigned int fullmm;
+	unsigned int need_flush;
 };
 
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
 struct mmu_table_batch {
 	struct rcu_head		rcu;
 	unsigned int		nr;
@@ -45,6 +49,7 @@ struct mmu_table_batch {
 
 extern void tlb_table_flush(struct mmu_gather *tlb);
 extern void tlb_remove_table(struct mmu_gather *tlb, void *table);
+#endif
 
 static inline void tlb_gather_mmu(struct mmu_gather *tlb,
 				  struct mm_struct *mm,
@@ -52,20 +57,29 @@ static inline void tlb_gather_mmu(struct
 {
 	tlb->mm = mm;
 	tlb->fullmm = full_mm_flush;
+	tlb->need_flush = 0;
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb->batch = NULL;
+#endif
 	if (tlb->fullmm)
 		__tlb_flush_mm(mm);
 }
 
 static inline void tlb_flush_mmu(struct mmu_gather *tlb)
 {
+	if (!tlb->need_flush)
+		return;
+	tlb->need_flush = 0;
+	__tlb_flush_mm(tlb->mm);
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb_table_flush(tlb);
+#endif
 }
 
 static inline void tlb_finish_mmu(struct mmu_gather *tlb,
 				  unsigned long start, unsigned long end)
 {
-	tlb_table_flush(tlb);
+	tlb_flush_mmu(tlb);
 }
 
 /*
@@ -91,8 +105,10 @@ static inline void tlb_remove_page(struc
 static inline void pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
 				unsigned long address)
 {
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	if (!tlb->fullmm)
 		return page_table_free_rcu(tlb, (unsigned long *) pte);
+#endif
 	page_table_free(tlb->mm, (unsigned long *) pte);
 }
 
@@ -109,8 +125,10 @@ static inline void pmd_free_tlb(struct m
 #ifdef CONFIG_64BIT
 	if (tlb->mm->context.asce_limit <= (1UL << 31))
 		return;
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	if (!tlb->fullmm)
 		return tlb_remove_table(tlb, pmd);
+#endif
 	crst_table_free(tlb->mm, (unsigned long *) pmd);
 #endif
 }
@@ -128,8 +146,10 @@ static inline void pud_free_tlb(struct m
 #ifdef CONFIG_64BIT
 	if (tlb->mm->context.asce_limit <= (1UL << 42))
 		return;
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	if (!tlb->fullmm)
 		return tlb_remove_table(tlb, pud);
+#endif
 	crst_table_free(tlb->mm, (unsigned long *) pud);
 #endif
 }
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -678,6 +678,8 @@ void page_table_free(struct mm_struct *m
 	}
 }
 
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
+
 static void __page_table_free_rcu(void *table, unsigned bit)
 {
 	struct page *page;
@@ -731,66 +733,7 @@ void __tlb_remove_table(void *_table)
 		free_pages((unsigned long) table, ALLOC_ORDER);
 }
 
-static void tlb_remove_table_smp_sync(void *arg)
-{
-	/* Simply deliver the interrupt */
-}
-
-static void tlb_remove_table_one(void *table)
-{
-	/*
-	 * This isn't an RCU grace period and hence the page-tables cannot be
-	 * assumed to be actually RCU-freed.
-	 *
-	 * It is however sufficient for software page-table walkers that rely
-	 * on IRQ disabling. See the comment near struct mmu_table_batch.
-	 */
-	smp_call_function(tlb_remove_table_smp_sync, NULL, 1);
-	__tlb_remove_table(table);
-}
-
-static void tlb_remove_table_rcu(struct rcu_head *head)
-{
-	struct mmu_table_batch *batch;
-	int i;
-
-	batch = container_of(head, struct mmu_table_batch, rcu);
-
-	for (i = 0; i < batch->nr; i++)
-		__tlb_remove_table(batch->tables[i]);
-
-	free_page((unsigned long)batch);
-}
-
-void tlb_table_flush(struct mmu_gather *tlb)
-{
-	struct mmu_table_batch **batch = &tlb->batch;
-
-	if (*batch) {
-		__tlb_flush_mm(tlb->mm);
-		call_rcu_sched(&(*batch)->rcu, tlb_remove_table_rcu);
-		*batch = NULL;
-	}
-}
-
-void tlb_remove_table(struct mmu_gather *tlb, void *table)
-{
-	struct mmu_table_batch **batch = &tlb->batch;
-
-	if (*batch == NULL) {
-		*batch = (struct mmu_table_batch *)
-			__get_free_page(GFP_NOWAIT | __GFP_NOWARN);
-		if (*batch == NULL) {
-			__tlb_flush_mm(tlb->mm);
-			tlb_remove_table_one(table);
-			return;
-		}
-		(*batch)->nr = 0;
-	}
-	(*batch)->tables[(*batch)->nr++] = table;
-	if ((*batch)->nr == MAX_TABLE_BATCH)
-		tlb_table_flush(tlb);
-}
+#endif
 
 /*
  * switch on pgstes for its userspace process (for kvm)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
