Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1FB746B003C
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 11:43:56 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id n3so8649344wiv.1
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 08:43:55 -0700 (PDT)
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
        by mx.google.com with ESMTPS id m3si9825716wix.100.2014.08.21.08.43.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 21 Aug 2014 08:43:54 -0700 (PDT)
Received: by mail-we0-f172.google.com with SMTP id x48so9556304wes.3
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 08:43:54 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [PATH V2 6/6] arm64: mm: Enable RCU fast_gup
Date: Thu, 21 Aug 2014 16:43:32 +0100
Message-Id: <1408635812-31584-7-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1408635812-31584-1-git-send-email-steve.capper@linaro.org>
References: <1408635812-31584-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, linux@arm.linux.org.uk, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: will.deacon@arm.com, gary.robertson@linaro.org, christoffer.dall@linaro.org, peterz@infradead.org, anders.roxell@linaro.org, akpm@linux-foundation.org, dann.frazier@canonical.com, mark.rutland@arm.com, mgorman@suse.de, Steve Capper <steve.capper@linaro.org>

Activate the RCU fast_gup for ARM64. We also need to force THP splits
to broadcast an IPI s.t. we block in the fast_gup page walker. As THP
splits are comparatively rare, this should not lead to a noticeable
performance degradation.

Some pre-requisite functions pud_write and pud_page are also added.

Signed-off-by: Steve Capper <steve.capper@linaro.org>
---
 arch/arm64/Kconfig               |  3 +++
 arch/arm64/include/asm/pgtable.h | 11 ++++++++++-
 arch/arm64/mm/flush.c            | 15 +++++++++++++++
 3 files changed, 28 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index ce9062b..f03273d 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -108,6 +108,9 @@ config GENERIC_CALIBRATE_DELAY
 config ZONE_DMA
 	def_bool y
 
+config HAVE_RCU_GUP
+	def_bool y
+
 config ARCH_DMA_ADDR_T_64BIT
 	def_bool y
 
diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index ffe1ba0..f2a48e9 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -256,7 +256,13 @@ static inline pmd_t pte_pmd(pte_t pte)
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 #define pmd_trans_huge(pmd)	(pmd_val(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT))
 #define pmd_trans_splitting(pmd)	pte_special(pmd_pte(pmd))
-#endif
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
+#define __HAVE_ARCH_PMDP_SPLITTING_FLUSH
+struct vm_area_struct;
+void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
+			  pmd_t *pmdp);
+#endif /* CONFIG_HAVE_RCU_TABLE_FREE */
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #define pmd_young(pmd)		pte_young(pmd_pte(pmd))
 #define pmd_wrprotect(pmd)	pte_pmd(pte_wrprotect(pmd_pte(pmd)))
@@ -277,6 +283,7 @@ static inline pmd_t pte_pmd(pte_t pte)
 #define mk_pmd(page,prot)	pfn_pmd(page_to_pfn(page),prot)
 
 #define pmd_page(pmd)           pfn_to_page(__phys_to_pfn(pmd_val(pmd) & PHYS_MASK))
+#define pud_write(pud)		pmd_write(__pmd(pud_val(pud)))
 #define pud_pfn(pud)		(((pud_val(pud) & PUD_MASK) & PHYS_MASK) >> PAGE_SHIFT)
 
 #define set_pmd_at(mm, addr, pmdp, pmd)	set_pte_at(mm, addr, (pte_t *)pmdp, pmd_pte(pmd))
@@ -376,6 +383,8 @@ static inline pmd_t *pmd_offset(pud_t *pud, unsigned long addr)
 	return (pmd_t *)pud_page_vaddr(*pud) + pmd_index(addr);
 }
 
+#define pud_page(pud)           pmd_page(__pmd(pud_val(pud)))
+
 #endif	/* CONFIG_ARM64_PGTABLE_LEVELS > 2 */
 
 #if CONFIG_ARM64_PGTABLE_LEVELS > 3
diff --git a/arch/arm64/mm/flush.c b/arch/arm64/mm/flush.c
index 0d64089..2d5fd47 100644
--- a/arch/arm64/mm/flush.c
+++ b/arch/arm64/mm/flush.c
@@ -104,3 +104,18 @@ EXPORT_SYMBOL(flush_dcache_page);
  */
 EXPORT_SYMBOL(flush_cache_all);
 EXPORT_SYMBOL(flush_icache_range);
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
+void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
+			  pmd_t *pmdp)
+{
+	pmd_t pmd = pmd_mksplitting(*pmdp);
+	VM_BUG_ON(address & ~PMD_MASK);
+	set_pmd_at(vma->vm_mm, address, pmdp, pmd);
+
+	/* dummy IPI to serialise against fast_gup */
+	kick_all_cpus_sync();
+}
+#endif /* CONFIG_HAVE_RCU_TABLE_FREE */
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
