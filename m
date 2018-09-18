Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id E9F3D8E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 08:52:18 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id l191-v6so1550378oig.23
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 05:52:18 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o10-v6si6107857oth.7.2018.09.18.05.52.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Sep 2018 05:52:17 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8ICoj2D034848
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 08:52:16 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mk1cvrw66-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 08:52:16 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Tue, 18 Sep 2018 13:52:14 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH 2/2] s390/tlb: convert to generic mmu_gather
Date: Tue, 18 Sep 2018 14:51:51 +0200
In-Reply-To: <20180918125151.31744-1-schwidefsky@de.ibm.com>
References: <20180918125151.31744-1-schwidefsky@de.ibm.com>
Message-Id: <20180918125151.31744-3-schwidefsky@de.ibm.com>
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: will.deacon@arm.com, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com, Linus Torvalds <torvalds@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 arch/s390/Kconfig           |   3 +
 arch/s390/include/asm/tlb.h | 130 ++++++++++++++------------------------------
 arch/s390/mm/pgalloc.c      |  63 +--------------------
 3 files changed, 44 insertions(+), 152 deletions(-)

diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index 9a9c7a6fe925..b864462ac4a6 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -157,10 +157,13 @@ config S390
 	select HAVE_MEMBLOCK
 	select HAVE_MEMBLOCK_NODE_MAP
 	select HAVE_MEMBLOCK_PHYS_MAP
+	select HAVE_MMU_GATHER_NO_GATHER
 	select HAVE_MOD_ARCH_SPECIFIC
 	select HAVE_NOP_MCOUNT
 	select HAVE_OPROFILE
 	select HAVE_PERF_EVENTS
+	select HAVE_RCU_TABLE_FREE
+	select HAVE_RCU_TABLE_INVALIDATE
 	select HAVE_REGS_AND_STACK_ACCESS_API
 	select HAVE_RSEQ
 	select HAVE_SYSCALL_TRACEPOINTS
diff --git a/arch/s390/include/asm/tlb.h b/arch/s390/include/asm/tlb.h
index cf3d64313740..cb99f8310c3a 100644
--- a/arch/s390/include/asm/tlb.h
+++ b/arch/s390/include/asm/tlb.h
@@ -22,98 +22,39 @@
  * Pages used for the page tables is a different story. FIXME: more
  */
 
-#include <linux/mm.h>
-#include <linux/pagemap.h>
-#include <linux/swap.h>
-#include <asm/processor.h>
-#include <asm/pgalloc.h>
-#include <asm/tlbflush.h>
-
-struct mmu_gather {
-	struct mm_struct *mm;
-	struct mmu_table_batch *batch;
-	unsigned int fullmm;
-	unsigned long start, end;
-};
-
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
-
-static inline void
-arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
-			unsigned long start, unsigned long end)
-{
-	tlb->mm = mm;
-	tlb->start = start;
-	tlb->end = end;
-	tlb->fullmm = !(start | (end+1));
-	tlb->batch = NULL;
-}
-
-static inline void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
-{
-	__tlb_flush_mm_lazy(tlb->mm);
-}
-
-static inline void tlb_flush_mmu_free(struct mmu_gather *tlb)
-{
-	tlb_table_flush(tlb);
-}
-
+void __tlb_remove_table(void *_table);
+static inline void tlb_flush(struct mmu_gather *tlb);
+static inline bool __tlb_remove_page_size(struct mmu_gather *tlb,
+					  struct page *page, int page_size);
 
-static inline void tlb_flush_mmu(struct mmu_gather *tlb)
-{
-	tlb_flush_mmu_tlbonly(tlb);
-	tlb_flush_mmu_free(tlb);
-}
+#define tlb_start_vma(tlb, vma)			do { } while (0)
+#define tlb_end_vma(tlb, vma)			do { } while (0)
 
-static inline void
-arch_tlb_finish_mmu(struct mmu_gather *tlb,
-		unsigned long start, unsigned long end, bool force)
-{
-	if (force) {
-		tlb->start = start;
-		tlb->end = end;
-	}
+#define tlb_flush tlb_flush
+#define pte_free_tlb pte_free_tlb
+#define pmd_free_tlb pmd_free_tlb
+#define p4d_free_tlb p4d_free_tlb
+#define pud_free_tlb pud_free_tlb
 
-	tlb_flush_mmu(tlb);
-}
+#include <asm/pgalloc.h>
+#include <asm/tlbflush.h>
+#include <asm-generic/tlb.h>
 
 /*
  * Release the page cache reference for a pte removed by
  * tlb_ptep_clear_flush. In both flush modes the tlb for a page cache page
  * has already been freed, so just do free_page_and_swap_cache.
  */
-static inline bool __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
-{
-	free_page_and_swap_cache(page);
-	return false; /* avoid calling tlb_flush_mmu */
-}
-
-static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
-{
-	free_page_and_swap_cache(page);
-}
-
 static inline bool __tlb_remove_page_size(struct mmu_gather *tlb,
 					  struct page *page, int page_size)
 {
-	return __tlb_remove_page(tlb, page);
+	free_page_and_swap_cache(page);
+	return false;
 }
 
-static inline void tlb_remove_page_size(struct mmu_gather *tlb,
-					struct page *page, int page_size)
+static inline void tlb_flush(struct mmu_gather *tlb)
 {
-	return tlb_remove_page(tlb, page);
+	__tlb_flush_mm_lazy(tlb->mm);
 }
 
 /*
@@ -121,9 +62,18 @@ static inline void tlb_remove_page_size(struct mmu_gather *tlb,
  * page table from the tlb.
  */
 static inline void pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
-				unsigned long address)
+                                unsigned long address)
 {
-	page_table_free_rcu(tlb, (unsigned long *) pte, address);
+	__tlb_adjust_range(tlb, address, PAGE_SIZE);
+	tlb->mm->context.flush_mm = 1;
+	tlb->freed_tables = 1;
+	tlb->cleared_ptes = 1;
+	/*
+	 * page_table_free_rcu takes care of the allocation bit masks
+	 * of the 2K table fragments in the 4K page table page,
+	 * then calls tlb_remove_table.
+	 */
+        page_table_free_rcu(tlb, (unsigned long *) pte, address);
 }
 
 /*
@@ -139,6 +89,10 @@ static inline void pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd,
 	if (tlb->mm->context.asce_limit <= _REGION3_SIZE)
 		return;
 	pgtable_pmd_page_dtor(virt_to_page(pmd));
+	__tlb_adjust_range(tlb, address, PAGE_SIZE);
+	tlb->mm->context.flush_mm = 1;
+	tlb->freed_tables = 1;
+	tlb->cleared_puds = 1;
 	tlb_remove_table(tlb, pmd);
 }
 
@@ -154,6 +108,10 @@ static inline void p4d_free_tlb(struct mmu_gather *tlb, p4d_t *p4d,
 {
 	if (tlb->mm->context.asce_limit <= _REGION1_SIZE)
 		return;
+	__tlb_adjust_range(tlb, address, PAGE_SIZE);
+	tlb->mm->context.flush_mm = 1;
+	tlb->freed_tables = 1;
+	tlb->cleared_p4ds = 1;
 	tlb_remove_table(tlb, p4d);
 }
 
@@ -169,19 +127,11 @@ static inline void pud_free_tlb(struct mmu_gather *tlb, pud_t *pud,
 {
 	if (tlb->mm->context.asce_limit <= _REGION2_SIZE)
 		return;
+	tlb->mm->context.flush_mm = 1;
+	tlb->freed_tables = 1;
+	tlb->cleared_puds = 1;
 	tlb_remove_table(tlb, pud);
 }
 
-#define tlb_start_vma(tlb, vma)			do { } while (0)
-#define tlb_end_vma(tlb, vma)			do { } while (0)
-#define tlb_remove_tlb_entry(tlb, ptep, addr)	do { } while (0)
-#define tlb_remove_pmd_tlb_entry(tlb, pmdp, addr)	do { } while (0)
-#define tlb_migrate_finish(mm)			do { } while (0)
-#define tlb_remove_huge_tlb_entry(h, tlb, ptep, address)	\
-	tlb_remove_tlb_entry(tlb, ptep, address)
-
-static inline void tlb_change_page_size(struct mmu_gather *tlb, unsigned int page_size)
-{
-}
 
 #endif /* _S390_TLB_H */
diff --git a/arch/s390/mm/pgalloc.c b/arch/s390/mm/pgalloc.c
index 76d89ee8b428..f7656a0b3a1a 100644
--- a/arch/s390/mm/pgalloc.c
+++ b/arch/s390/mm/pgalloc.c
@@ -288,7 +288,7 @@ void page_table_free_rcu(struct mmu_gather *tlb, unsigned long *table,
 	tlb_remove_table(tlb, table);
 }
 
-static void __tlb_remove_table(void *_table)
+void __tlb_remove_table(void *_table)
 {
 	unsigned int mask = (unsigned long) _table & 3;
 	void *table = (void *)((unsigned long) _table ^ mask);
@@ -314,67 +314,6 @@ static void __tlb_remove_table(void *_table)
 	}
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
-		call_rcu_sched(&(*batch)->rcu, tlb_remove_table_rcu);
-		*batch = NULL;
-	}
-}
-
-void tlb_remove_table(struct mmu_gather *tlb, void *table)
-{
-	struct mmu_table_batch **batch = &tlb->batch;
-
-	tlb->mm->context.flush_mm = 1;
-	if (*batch == NULL) {
-		*batch = (struct mmu_table_batch *)
-			__get_free_page(GFP_NOWAIT | __GFP_NOWARN);
-		if (*batch == NULL) {
-			__tlb_flush_mm_lazy(tlb->mm);
-			tlb_remove_table_one(table);
-			return;
-		}
-		(*batch)->nr = 0;
-	}
-	(*batch)->tables[(*batch)->nr++] = table;
-	if ((*batch)->nr == MAX_TABLE_BATCH)
-		tlb_flush_mmu(tlb);
-}
-
 /*
  * Base infrastructure required to generate basic asces, region, segment,
  * and page tables that do not make use of enhanced features like EDAT1.
-- 
2.16.4
