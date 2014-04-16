Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id DFF8C6B0080
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 07:46:59 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id hi2so1218701wib.11
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 04:46:59 -0700 (PDT)
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
        by mx.google.com with ESMTPS id ma4si7807369wic.20.2014.04.16.04.46.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Apr 2014 04:46:58 -0700 (PDT)
Received: by mail-we0-f173.google.com with SMTP id w61so10628769wes.18
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 04:46:58 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [PATCH V2 5/5] arm: mm: Add Transparent HugePage support for non-LPAE
Date: Wed, 16 Apr 2014 12:46:43 +0100
Message-Id: <1397648803-15961-6-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1397648803-15961-1-git-send-email-steve.capper@linaro.org>
References: <1397648803-15961-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@arm.linux.org.uk, akpm@linux-foundation.org
Cc: will.deacon@arm.com, catalin.marinas@arm.com, robherring2@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, gerald.schaefer@de.ibm.com, Steve Capper <steve.capper@linaro.org>

Much of the required code for THP has been implemented in the
earlier non-LPAE HugeTLB patch.

One more domain bit is used (to store whether or not the THP is
splitting).

Some THP helper functions are defined; and we have to re-define
pmd_page such that it distinguishes between page tables and
sections.

Signed-off-by: Steve Capper <steve.capper@linaro.org>
---
 arch/arm/Kconfig                      |  2 +-
 arch/arm/include/asm/pgtable-2level.h | 32 ++++++++++++++++++++++++++++++++
 arch/arm/include/asm/pgtable-3level.h |  1 +
 arch/arm/include/asm/pgtable.h        |  2 --
 arch/arm/include/asm/tlb.h            |  3 +++
 5 files changed, 37 insertions(+), 3 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 5e80fad..f5d4354 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -1836,7 +1836,7 @@ config SYS_SUPPORTS_HUGETLBFS
 
 config HAVE_ARCH_TRANSPARENT_HUGEPAGE
        def_bool y
-       depends on ARM_LPAE
+       depends on SYS_SUPPORTS_HUGETLBFS
 
 config ARCH_WANT_GENERAL_HUGETLB
 	def_bool y
diff --git a/arch/arm/include/asm/pgtable-2level.h b/arch/arm/include/asm/pgtable-2level.h
index 323e19f..bc1a7b8 100644
--- a/arch/arm/include/asm/pgtable-2level.h
+++ b/arch/arm/include/asm/pgtable-2level.h
@@ -212,6 +212,7 @@ static inline pmd_t *pmd_offset(pud_t *pud, unsigned long addr)
  */
 #define PMD_DSECT_DIRTY		(_AT(pmdval_t, 1) << 5)
 #define PMD_DSECT_AF		(_AT(pmdval_t, 1) << 6)
+#define PMD_DSECT_SPLITTING	(_AT(pmdval_t, 1) << 7)
 
 #define PMD_BIT_FUNC(fn,op) \
 static inline pmd_t pmd_##fn(pmd_t pmd) { pmd_val(pmd) op; return pmd; }
@@ -232,6 +233,16 @@ extern pgprot_t get_huge_pgprot(pgprot_t newprot);
 
 #define pfn_pmd(pfn,prot) __pmd(__pfn_to_phys(pfn) | pgprot_val(prot));
 #define mk_pmd(page,prot) pfn_pmd(page_to_pfn(page),get_huge_pgprot(prot));
+#define pmd_mkhuge(pmd)	(pmd)
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#define pmd_trans_splitting(pmd)       (pmd_val(pmd) & PMD_DSECT_SPLITTING)
+#define pmd_trans_huge(pmd)            (pmd_thp_or_huge(pmd))
+#else
+static inline int pmd_trans_huge(pmd_t pmd);
+#endif
+
+#define pmd_mknotpresent(pmd)  (__pmd(0))
 
 PMD_BIT_FUNC(mkdirty, |= PMD_DSECT_DIRTY);
 PMD_BIT_FUNC(mkwrite, |= PMD_SECT_AP_WRITE);
@@ -239,6 +250,8 @@ PMD_BIT_FUNC(wrprotect,	&= ~PMD_SECT_AP_WRITE);
 PMD_BIT_FUNC(mknexec,	|= PMD_SECT_XN);
 PMD_BIT_FUNC(rmprotnone, |= PMD_TYPE_SECT);
 PMD_BIT_FUNC(mkyoung, |= PMD_DSECT_AF);
+PMD_BIT_FUNC(mkold, &= ~PMD_DSECT_AF);
+PMD_BIT_FUNC(mksplitting, |= PMD_DSECT_SPLITTING);
 
 #define pmd_young(pmd)			(pmd_val(pmd) & PMD_DSECT_AF)
 #define pmd_write(pmd)			(pmd_val(pmd) & PMD_SECT_AP_WRITE)
@@ -279,6 +292,25 @@ static inline pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
 	return pmd;
 }
 
+static inline int has_transparent_hugepage(void)
+{
+	return 1;
+}
+
+static inline struct page *pmd_page(pmd_t pmd)
+{
+	/*
+	 * for a section, we need to mask off more of the pmd
+	 * before looking up the page as it is a section descriptor.
+	 *
+	 * pmd_page only gets sections from the thp code.
+	 */
+	if (pmd_trans_huge(pmd))
+		return (phys_to_page(pmd_val(pmd) & HPAGE_MASK));
+
+	return phys_to_page(pmd_val(pmd) & PHYS_MASK);
+}
+
 #endif /* __ASSEMBLY__ */
 
 #endif /* _ASM_PGTABLE_2LEVEL_H */
diff --git a/arch/arm/include/asm/pgtable-3level.h b/arch/arm/include/asm/pgtable-3level.h
index a4b71c1..82c61d6 100644
--- a/arch/arm/include/asm/pgtable-3level.h
+++ b/arch/arm/include/asm/pgtable-3level.h
@@ -214,6 +214,7 @@ static inline pmd_t *pmd_offset(pud_t *pud, unsigned long addr)
 
 #define pmd_hugewillfault(pmd)	(!pmd_young(pmd) || !pmd_write(pmd))
 #define pmd_thp_or_huge(pmd)	(pmd_val(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT))
+#define pmd_page(pmd)		pfn_to_page(__phys_to_pfn(pmd_val(pmd) & PHYS_MASK))
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 #define pmd_trans_huge(pmd)	(pmd_val(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT))
diff --git a/arch/arm/include/asm/pgtable.h b/arch/arm/include/asm/pgtable.h
index 576511f2..95f1909 100644
--- a/arch/arm/include/asm/pgtable.h
+++ b/arch/arm/include/asm/pgtable.h
@@ -189,8 +189,6 @@ static inline pte_t *pmd_page_vaddr(pmd_t pmd)
 	return __va(pmd_val(pmd) & PHYS_MASK & (s32)PAGE_MASK);
 }
 
-#define pmd_page(pmd)		pfn_to_page(__phys_to_pfn(pmd_val(pmd) & PHYS_MASK))
-
 #ifndef CONFIG_HIGHPTE
 #define __pte_map(pmd)		pmd_page_vaddr(*(pmd))
 #define __pte_unmap(pte)	do { } while (0)
diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
index b2498e6..77037d9 100644
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -218,6 +218,9 @@ static inline void
 tlb_remove_pmd_tlb_entry(struct mmu_gather *tlb, pmd_t *pmdp, unsigned long addr)
 {
 	tlb_add_flush(tlb, addr);
+#ifndef CONFIG_ARM_LPAE
+	tlb_add_flush(tlb, addr + SZ_1M);
+#endif
 }
 
 #define pte_free_tlb(tlb, ptep, addr)	__pte_free_tlb(tlb, ptep, addr)
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
