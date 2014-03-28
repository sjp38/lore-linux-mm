Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6B1F46B0039
	for <linux-mm@kvack.org>; Fri, 28 Mar 2014 11:01:46 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id l18so3596783wgh.4
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 08:01:45 -0700 (PDT)
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
        by mx.google.com with ESMTPS id gr7si2335249wib.56.2014.03.28.08.01.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 28 Mar 2014 08:01:45 -0700 (PDT)
Received: by mail-wg0-f46.google.com with SMTP id b13so3597730wgh.17
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 08:01:44 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [RFC PATCH V4 3/7] arm: mm: Enable HAVE_RCU_TABLE_FREE logic
Date: Fri, 28 Mar 2014 15:01:28 +0000
Message-Id: <1396018892-6773-4-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1396018892-6773-1-git-send-email-steve.capper@linaro.org>
References: <1396018892-6773-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, linux@arm.linux.org.uk, linux-mm@kvack.org, linux-arch@vger.kernel.org
Cc: peterz@infradead.org, gary.robertson@linaro.org, anders.roxell@linaro.org, akpm@linux-foundation.org, Steve Capper <steve.capper@linaro.org>

In order to implement fast_get_user_pages we need to ensure that the
page table walker is protected from page table pages being freed from
under it.

One way to achieve this is to have the walker disable interrupts, and
rely on IPIs from the TLB flushing code blocking before the page table
pages are freed.

On some ARM platforms we have hardware TLB invalidation, thus the TLB
flushing code won't necessarily broadcast IPIs. Also spuriously
broadcasting IPIs can hurt system performance if done too often.

This problem has already been solved on PowerPC and Sparc by batching
up page table pages belonging to more than one mm_user, then scheduling
an rcu_sched callback to free the pages. If one were to disable
interrupts, that would delay the scheduling interrupts thus block the
page table pages being freed. This logic has also been promoted to core
code and is activated when one enables HAVE_RCU_TABLE_FREE.

This patch enables HAVE_RCU_TABLE_FREE and incorporates it into the
existing ARM TLB logic.

Signed-off-by: Steve Capper <steve.capper@linaro.org>
---
 arch/arm/Kconfig           |  1 +
 arch/arm/include/asm/tlb.h | 38 ++++++++++++++++++++++++++++++++++++--
 2 files changed, 37 insertions(+), 2 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 1594945..7d5340d 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -58,6 +58,7 @@ config ARM
 	select HAVE_PERF_EVENTS
 	select HAVE_PERF_REGS
 	select HAVE_PERF_USER_STACK_DUMP
+	select HAVE_RCU_TABLE_FREE if SMP
 	select HAVE_REGS_AND_STACK_ACCESS_API
 	select HAVE_SYSCALL_TRACEPOINTS
 	select HAVE_UID16
diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
index 0baf7f0..eaf7578 100644
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -35,12 +35,39 @@
 
 #define MMU_GATHER_BUNDLE	8
 
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
+static inline void __tlb_remove_table(void *_table)
+{
+	free_page_and_swap_cache((struct page *)_table);
+}
+
+struct mmu_table_batch {
+	struct rcu_head		rcu;
+	unsigned int		nr;
+	void			*tables[0];
+};
+
+#define MAX_TABLE_BATCH		\
+	((PAGE_SIZE - sizeof(struct mmu_table_batch)) / sizeof(void *))
+
+extern void tlb_table_flush(struct mmu_gather *tlb);
+extern void tlb_remove_table(struct mmu_gather *tlb, void *table);
+
+#define tlb_remove_entry(tlb, entry)	tlb_remove_table(tlb, entry)
+#else
+#define tlb_remove_entry(tlb, entry)	tlb_remove_page(tlb, entry)
+#endif /* CONFIG_HAVE_RCU_TABLE_FREE */
+
 /*
  * TLB handling.  This allows us to remove pages from the page
  * tables, and efficiently handle the TLB issues.
  */
 struct mmu_gather {
 	struct mm_struct	*mm;
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
+	struct mmu_table_batch	*batch;
+	unsigned int		need_flush;
+#endif
 	unsigned int		fullmm;
 	struct vm_area_struct	*vma;
 	unsigned long		start, end;
@@ -101,6 +128,9 @@ static inline void __tlb_alloc_page(struct mmu_gather *tlb)
 static inline void tlb_flush_mmu(struct mmu_gather *tlb)
 {
 	tlb_flush(tlb);
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
+	tlb_table_flush(tlb);
+#endif
 	free_pages_and_swap_cache(tlb->pages, tlb->nr);
 	tlb->nr = 0;
 	if (tlb->pages == tlb->local)
@@ -119,6 +149,10 @@ tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long start
 	tlb->pages = tlb->local;
 	tlb->nr = 0;
 	__tlb_alloc_page(tlb);
+
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
+	tlb->batch = NULL;
+#endif
 }
 
 static inline void
@@ -195,7 +229,7 @@ static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
 	tlb_add_flush(tlb, addr + SZ_1M);
 #endif
 
-	tlb_remove_page(tlb, pte);
+	tlb_remove_entry(tlb, pte);
 }
 
 static inline void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmdp,
@@ -203,7 +237,7 @@ static inline void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmdp,
 {
 #ifdef CONFIG_ARM_LPAE
 	tlb_add_flush(tlb, addr);
-	tlb_remove_page(tlb, virt_to_page(pmdp));
+	tlb_remove_entry(tlb, virt_to_page(pmdp));
 #endif
 }
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
