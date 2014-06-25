Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id AA49F6B0039
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 11:40:50 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id n12so2143189wgh.19
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 08:40:48 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
        by mx.google.com with ESMTPS id xn13si7485776wib.13.2014.06.25.08.40.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Jun 2014 08:40:44 -0700 (PDT)
Received: by mail-wi0-f178.google.com with SMTP id n15so2750557wiw.5
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 08:40:43 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [PATCH 5/6] arm64: mm: Enable HAVE_RCU_TABLE_FREE logic
Date: Wed, 25 Jun 2014 16:40:23 +0100
Message-Id: <1403710824-24340-6-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1403710824-24340-1-git-send-email-steve.capper@linaro.org>
References: <1403710824-24340-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, linux@arm.linux.org.uk, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: will.deacon@arm.com, gary.robertson@linaro.org, christoffer.dall@linaro.org, peterz@infradead.org, anders.roxell@linaro.org, akpm@linux-foundation.org, Steve Capper <steve.capper@linaro.org>

In order to implement fast_get_user_pages we need to ensure that the
page table walker is protected from page table pages being freed from
under it.

This patch enables HAVE_RCU_TABLE_FREE, any page table pages belonging
to address spaces with multiple users will be call_rcu_sched freed.
Meaning that disabling interrupts will block the free and protect the
fast gup page walker.

Signed-off-by: Steve Capper <steve.capper@linaro.org>
---
 arch/arm64/Kconfig           |  1 +
 arch/arm64/include/asm/tlb.h | 18 ++++++++++++++++--
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index a474de34..e1d2eef 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -49,6 +49,7 @@ config ARM64
 	select HAVE_PERF_EVENTS
 	select HAVE_PERF_REGS
 	select HAVE_PERF_USER_STACK_DUMP
+	select HAVE_RCU_TABLE_FREE
 	select HAVE_SYSCALL_TRACEPOINTS
 	select IRQ_DOMAIN
 	select MODULES_USE_ELF_RELA
diff --git a/arch/arm64/include/asm/tlb.h b/arch/arm64/include/asm/tlb.h
index 80e2c08..8e4dde5 100644
--- a/arch/arm64/include/asm/tlb.h
+++ b/arch/arm64/include/asm/tlb.h
@@ -23,6 +23,20 @@
 
 #include <asm-generic/tlb.h>
 
+#include <linux/pagemap.h>
+#include <linux/swap.h>
+
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
+
+#define tlb_remove_entry(tlb, entry)	tlb_remove_table(tlb, entry)
+static inline void __tlb_remove_table(void *_table)
+{
+	free_page_and_swap_cache((struct page *)_table);
+}
+#else
+#define tlb_remove_entry(tlb, entry)	tlb_remove_page(tlb, entry)
+#endif /* CONFIG_HAVE_RCU_TABLE_FREE */
+
 /*
  * There's three ways the TLB shootdown code is used:
  *  1. Unmapping a range of vmas.  See zap_page_range(), unmap_region().
@@ -88,7 +102,7 @@ static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
 {
 	pgtable_page_dtor(pte);
 	tlb_add_flush(tlb, addr);
-	tlb_remove_page(tlb, pte);
+	tlb_remove_entry(tlb, pte);
 }
 
 #ifndef CONFIG_ARM64_64K_PAGES
@@ -96,7 +110,7 @@ static inline void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmdp,
 				  unsigned long addr)
 {
 	tlb_add_flush(tlb, addr);
-	tlb_remove_page(tlb, virt_to_page(pmdp));
+	tlb_remove_entry(tlb, virt_to_page(pmdp));
 }
 #endif
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
