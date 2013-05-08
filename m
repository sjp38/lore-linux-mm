Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id D89926B00B1
	for <linux-mm@kvack.org>; Wed,  8 May 2013 05:53:26 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id u54so1618126wes.29
        for <linux-mm@kvack.org>; Wed, 08 May 2013 02:53:25 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [RFC PATCH v2 11/11] ARM64: mm: THP support.
Date: Wed,  8 May 2013 10:52:43 +0100
Message-Id: <1368006763-30774-12-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1368006763-30774-1-git-send-email-steve.capper@linaro.org>
References: <1368006763-30774-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Cc: Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, patches@linaro.org, Steve Capper <steve.capper@linaro.org>

Bring Transparent HugePage support to ARM. The size of a
transparent huge page depends on the normal page size. A
transparent huge page is always represented as a pmd.

If PAGE_SIZE is 4KB, THPs are 2MB.
If PAGE_SIZE is 64KB, THPs are 512MB.

Signed-off-by: Steve Capper <steve.capper@linaro.org>
---
 arch/arm64/Kconfig                     |  3 ++
 arch/arm64/include/asm/pgtable-hwdef.h |  4 +++
 arch/arm64/include/asm/pgtable.h       | 55 ++++++++++++++++++++++++++++++++++
 arch/arm64/include/asm/tlb.h           |  6 ++++
 arch/arm64/include/asm/tlbflush.h      |  2 ++
 5 files changed, 70 insertions(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index a5f76cf..93a3b9e 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -194,6 +194,9 @@ config ARCH_WANT_GENERAL_HUGETLB
 config ARCH_WANT_HUGE_PMD_SHARE
 	def_bool y if !ARM64_64K_PAGES
 
+config HAVE_ARCH_TRANSPARENT_HUGEPAGE
+	def_bool y
+
 source "mm/Kconfig"
 
 config FORCE_MAX_ZONEORDER
diff --git a/arch/arm64/include/asm/pgtable-hwdef.h b/arch/arm64/include/asm/pgtable-hwdef.h
index e6e0a0d..63c9d0d 100644
--- a/arch/arm64/include/asm/pgtable-hwdef.h
+++ b/arch/arm64/include/asm/pgtable-hwdef.h
@@ -42,6 +42,10 @@
 /*
  * Section
  */
+#define PMD_SECT_VALID		(_AT(pmdval_t, 1) << 0)
+#define PMD_SECT_PROT_NONE	(_AT(pmdval_t, 1) << 2)
+#define PMD_SECT_USER		(_AT(pmdval_t, 1) << 6)		/* AP[1] */
+#define PMD_SECT_RDONLY		(_AT(pmdval_t, 1) << 7)		/* AP[2] */
 #define PMD_SECT_S		(_AT(pmdval_t, 3) << 8)
 #define PMD_SECT_AF		(_AT(pmdval_t, 1) << 10)
 #define PMD_SECT_NG		(_AT(pmdval_t, 1) << 11)
diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index 6bcbcfd..fd17e0b 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -188,6 +188,61 @@ static inline void set_pte_at(struct mm_struct *mm, unsigned long addr,
 #define __HAVE_ARCH_PTE_SPECIAL
 
 /*
+ * Software PMD bits for THP
+ */
+
+#define PMD_SECT_DIRTY		(_AT(pmdval_t, 1) << 55)
+#define PMD_SECT_SPLITTING	(_AT(pmdval_t, 1) << 57)
+
+/*
+ * THP definitions.
+ */
+#define pmd_young(pmd)		(pmd_val(pmd) & PMD_SECT_AF)
+
+#define __HAVE_ARCH_PMD_WRITE
+#define pmd_write(pmd)		(!(pmd_val(pmd) & PMD_SECT_RDONLY))
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#define pmd_trans_huge(pmd)	(pmd_val(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT))
+#define pmd_trans_splitting(pmd) (pmd_val(pmd) & PMD_SECT_SPLITTING)
+#endif
+
+#define PMD_BIT_FUNC(fn,op) \
+static inline pmd_t pmd_##fn(pmd_t pmd) { pmd_val(pmd) op; return pmd; }
+
+PMD_BIT_FUNC(wrprotect,	|= PMD_SECT_RDONLY);
+PMD_BIT_FUNC(mkold,	&= ~PMD_SECT_AF);
+PMD_BIT_FUNC(mksplitting, |= PMD_SECT_SPLITTING);
+PMD_BIT_FUNC(mkwrite,   &= ~PMD_SECT_RDONLY);
+PMD_BIT_FUNC(mkdirty,   |= PMD_SECT_DIRTY);
+PMD_BIT_FUNC(mkyoung,   |= PMD_SECT_AF);
+PMD_BIT_FUNC(mknotpresent, &= ~PMD_TYPE_MASK);
+
+#define pmd_mkhuge(pmd)		(__pmd(pmd_val(pmd) & ~PMD_TABLE_BIT))
+
+#define pmd_pfn(pmd)		(((pmd_val(pmd) & PMD_MASK) & PHYS_MASK) >> PAGE_SHIFT)
+#define pfn_pmd(pfn,prot)	(__pmd(((phys_addr_t)(pfn) << PAGE_SHIFT) | pgprot_val(prot)))
+#define mk_pmd(page,prot)	pfn_pmd(page_to_pfn(page),prot)
+
+#define pmd_page(pmd)           pfn_to_page(__phys_to_pfn(pmd_val(pmd) & PHYS_MASK))
+
+static inline pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
+{
+	const pmdval_t mask = PMD_SECT_USER | PMD_SECT_PXN | PMD_SECT_UXN |
+			      PMD_SECT_RDONLY | PMD_SECT_PROT_NONE |
+			      PMD_SECT_VALID;
+	pmd_val(pmd) = (pmd_val(pmd) & ~mask) | (pgprot_val(newprot) & mask);
+	return pmd;
+}
+
+#define set_pmd_at(mm, addr, pmdp, pmd)	set_pmd(pmdp, pmd)
+
+static inline int has_transparent_hugepage(void)
+{
+	return 1;
+}
+
+/*
  * Mark the prot value as uncacheable and unbufferable.
  */
 #define pgprot_noncached(prot) \
diff --git a/arch/arm64/include/asm/tlb.h b/arch/arm64/include/asm/tlb.h
index 654f096..46b3beb 100644
--- a/arch/arm64/include/asm/tlb.h
+++ b/arch/arm64/include/asm/tlb.h
@@ -187,4 +187,10 @@ static inline void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmdp,
 
 #define tlb_migrate_finish(mm)		do { } while (0)
 
+static inline void
+tlb_remove_pmd_tlb_entry(struct mmu_gather *tlb, pmd_t *pmdp, unsigned long addr)
+{
+	tlb_add_flush(tlb, addr);
+}
+
 #endif
diff --git a/arch/arm64/include/asm/tlbflush.h b/arch/arm64/include/asm/tlbflush.h
index 122d632..8b48203 100644
--- a/arch/arm64/include/asm/tlbflush.h
+++ b/arch/arm64/include/asm/tlbflush.h
@@ -117,6 +117,8 @@ static inline void update_mmu_cache(struct vm_area_struct *vma,
 	dsb();
 }
 
+#define update_mmu_cache_pmd(vma, address, pmd) do { } while (0)
+
 #endif
 
 #endif
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
