Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5A6D46B003C
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 10:04:16 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id q5so11653763wiv.10
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 07:04:15 -0700 (PDT)
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
        by mx.google.com with ESMTPS id pk9si6880333wjc.9.2014.09.26.07.04.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 26 Sep 2014 07:04:14 -0700 (PDT)
Received: by mail-wg0-f47.google.com with SMTP id y10so9901522wgg.6
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 07:04:14 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [PATCH V4 4/6] arm: mm: Enable RCU fast_gup
Date: Fri, 26 Sep 2014 15:03:51 +0100
Message-Id: <1411740233-28038-5-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1411740233-28038-1-git-send-email-steve.capper@linaro.org>
References: <1411740233-28038-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, linux@arm.linux.org.uk, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: will.deacon@arm.com, gary.robertson@linaro.org, christoffer.dall@linaro.org, peterz@infradead.org, anders.roxell@linaro.org, akpm@linux-foundation.org, dann.frazier@canonical.com, mark.rutland@arm.com, mgorman@suse.de, hughd@google.com, Steve Capper <steve.capper@linaro.org>

Activate the RCU fast_gup for ARM. We also need to force THP splits to
broadcast an IPI s.t. we block in the fast_gup page walker. As THP
splits are comparatively rare, this should not lead to a noticeable
performance degradation.

Some pre-requisite functions pud_write and pud_page are also added.

Signed-off-by: Steve Capper <steve.capper@linaro.org>
Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
---
 arch/arm/Kconfig                      |  4 ++++
 arch/arm/include/asm/pgtable-3level.h |  8 ++++++++
 arch/arm/mm/flush.c                   | 15 +++++++++++++++
 3 files changed, 27 insertions(+)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index cc740d2..0e5b47f 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -1645,6 +1645,10 @@ config ARCH_SELECT_MEMORY_MODEL
 config HAVE_ARCH_PFN_VALID
 	def_bool ARCH_HAS_HOLES_MEMORYMODEL || !SPARSEMEM
 
+config HAVE_GENERIC_RCU_GUP
+	def_bool y
+	depends on ARM_LPAE
+
 config HIGHMEM
 	bool "High Memory Support"
 	depends on MMU
diff --git a/arch/arm/include/asm/pgtable-3level.h b/arch/arm/include/asm/pgtable-3level.h
index 16122d4..a31ecdad 100644
--- a/arch/arm/include/asm/pgtable-3level.h
+++ b/arch/arm/include/asm/pgtable-3level.h
@@ -224,6 +224,8 @@ static inline pte_t pte_mkspecial(pte_t pte)
 #define __HAVE_ARCH_PMD_WRITE
 #define pmd_write(pmd)		(pmd_isclear((pmd), L_PMD_SECT_RDONLY))
 #define pmd_dirty(pmd)		(pmd_isset((pmd), L_PMD_SECT_DIRTY))
+#define pud_page(pud)		pmd_page(__pmd(pud_val(pud)))
+#define pud_write(pud)		pmd_write(__pmd(pud_val(pud)))
 
 #define pmd_hugewillfault(pmd)	(!pmd_young(pmd) || !pmd_write(pmd))
 #define pmd_thp_or_huge(pmd)	(pmd_huge(pmd) || pmd_trans_huge(pmd))
@@ -231,6 +233,12 @@ static inline pte_t pte_mkspecial(pte_t pte)
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 #define pmd_trans_huge(pmd)	(pmd_val(pmd) && !pmd_table(pmd))
 #define pmd_trans_splitting(pmd) (pmd_isset((pmd), L_PMD_SECT_SPLITTING))
+
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
+#define __HAVE_ARCH_PMDP_SPLITTING_FLUSH
+void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
+			  pmd_t *pmdp);
+#endif
 #endif
 
 #define PMD_BIT_FUNC(fn,op) \
diff --git a/arch/arm/mm/flush.c b/arch/arm/mm/flush.c
index 43d54f5..265b836 100644
--- a/arch/arm/mm/flush.c
+++ b/arch/arm/mm/flush.c
@@ -400,3 +400,18 @@ void __flush_anon_page(struct vm_area_struct *vma, struct page *page, unsigned l
 	 */
 	__cpuc_flush_dcache_area(page_address(page), PAGE_SIZE);
 }
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
