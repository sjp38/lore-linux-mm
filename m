Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7F40E6B0039
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 11:43:48 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id ho1so8659794wib.16
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 08:43:48 -0700 (PDT)
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
        by mx.google.com with ESMTPS id cg2si41744819wjb.78.2014.08.21.08.43.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 21 Aug 2014 08:43:47 -0700 (PDT)
Received: by mail-we0-f181.google.com with SMTP id k48so9550600wev.40
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 08:43:46 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [PATH V2 3/6] arm: mm: Enable HAVE_RCU_TABLE_FREE logic
Date: Thu, 21 Aug 2014 16:43:29 +0100
Message-Id: <1408635812-31584-4-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1408635812-31584-1-git-send-email-steve.capper@linaro.org>
References: <1408635812-31584-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, linux@arm.linux.org.uk, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: will.deacon@arm.com, gary.robertson@linaro.org, christoffer.dall@linaro.org, peterz@infradead.org, anders.roxell@linaro.org, akpm@linux-foundation.org, dann.frazier@canonical.com, mark.rutland@arm.com, mgorman@suse.de, Steve Capper <steve.capper@linaro.org>

In order to implement fast_get_user_pages we need to ensure that the
page table walker is protected from page table pages being freed from
under it.

This patch enables HAVE_RCU_TABLE_FREE, any page table pages belonging
to address spaces with multiple users will be call_rcu_sched freed.
Meaning that disabling interrupts will block the free and protect
the fast gup page walker.

Signed-off-by: Steve Capper <steve.capper@linaro.org>
---
 arch/arm/Kconfig           |  1 +
 arch/arm/include/asm/tlb.h | 38 ++++++++++++++++++++++++++++++++++++--
 2 files changed, 37 insertions(+), 2 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index c49a775..cc740d2 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -60,6 +60,7 @@ config ARM
 	select HAVE_PERF_EVENTS
 	select HAVE_PERF_REGS
 	select HAVE_PERF_USER_STACK_DUMP
+	select HAVE_RCU_TABLE_FREE if (SMP && ARM_LPAE)
 	select HAVE_REGS_AND_STACK_ACCESS_API
 	select HAVE_SYSCALL_TRACEPOINTS
 	select HAVE_UID16
diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
index f1a0dac..3cadb72 100644
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
 static inline void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
 {
 	tlb_flush(tlb);
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
+	tlb_table_flush(tlb);
+#endif
 }
 
 static inline void tlb_flush_mmu_free(struct mmu_gather *tlb)
@@ -129,6 +159,10 @@ tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long start
 	tlb->pages = tlb->local;
 	tlb->nr = 0;
 	__tlb_alloc_page(tlb);
+
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
+	tlb->batch = NULL;
+#endif
 }
 
 static inline void
@@ -205,7 +239,7 @@ static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
 	tlb_add_flush(tlb, addr + SZ_1M);
 #endif
 
-	tlb_remove_page(tlb, pte);
+	tlb_remove_entry(tlb, pte);
 }
 
 static inline void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmdp,
@@ -213,7 +247,7 @@ static inline void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmdp,
 {
 #ifdef CONFIG_ARM_LPAE
 	tlb_add_flush(tlb, addr);
-	tlb_remove_page(tlb, virt_to_page(pmdp));
+	tlb_remove_entry(tlb, virt_to_page(pmdp));
 #endif
 }
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
