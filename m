Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 488046B003A
	for <linux-mm@kvack.org>; Fri, 28 Mar 2014 11:01:48 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id d1so846967wiv.13
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 08:01:47 -0700 (PDT)
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
        by mx.google.com with ESMTPS id fy2si2327430wib.56.2014.03.28.08.01.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 28 Mar 2014 08:01:46 -0700 (PDT)
Received: by mail-we0-f169.google.com with SMTP id w62so2780064wes.0
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 08:01:46 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [RFC PATCH V4 4/7] arm: mm: Enable RCU fast_gup
Date: Fri, 28 Mar 2014 15:01:29 +0000
Message-Id: <1396018892-6773-5-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1396018892-6773-1-git-send-email-steve.capper@linaro.org>
References: <1396018892-6773-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, linux@arm.linux.org.uk, linux-mm@kvack.org, linux-arch@vger.kernel.org
Cc: peterz@infradead.org, gary.robertson@linaro.org, anders.roxell@linaro.org, akpm@linux-foundation.org, Steve Capper <steve.capper@linaro.org>

Activate the RCU fast_gup for ARM. We also need to force THP splits to
broadcast an IPI s.t. we block in the fast_gup page walker. As THP
splits are comparatively rare, this should not lead to a noticeable
performance degradation.

Signed-off-by: Steve Capper <steve.capper@linaro.org>
---
 arch/arm/Kconfig                      |  3 +++
 arch/arm/include/asm/pgtable-3level.h |  6 ++++++
 arch/arm/mm/flush.c                   | 19 +++++++++++++++++++
 3 files changed, 28 insertions(+)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 7d5340d..3cf589e 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -1788,6 +1788,9 @@ config ARCH_SELECT_MEMORY_MODEL
 config HAVE_ARCH_PFN_VALID
 	def_bool ARCH_HAS_HOLES_MEMORYMODEL || !SPARSEMEM
 
+config HAVE_RCU_GUP
+	def_bool y
+
 config HIGHMEM
 	bool "High Memory Support"
 	depends on MMU
diff --git a/arch/arm/include/asm/pgtable-3level.h b/arch/arm/include/asm/pgtable-3level.h
index b286ba9..fdc4a4f 100644
--- a/arch/arm/include/asm/pgtable-3level.h
+++ b/arch/arm/include/asm/pgtable-3level.h
@@ -226,6 +226,12 @@ static inline pte_t pte_mkspecial(pte_t pte)
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 #define pmd_trans_huge(pmd)	(pmd_val(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT))
 #define pmd_trans_splitting(pmd) (pmd_val(pmd) & PMD_SECT_SPLITTING)
+
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
+#define __HAVE_ARCH_PMDP_SPLITTING_FLUSH
+void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
+			  pmd_t *pmdp);
+#endif
 #endif
 
 #define PMD_BIT_FUNC(fn,op) \
diff --git a/arch/arm/mm/flush.c b/arch/arm/mm/flush.c
index 3387e60..91a2b59 100644
--- a/arch/arm/mm/flush.c
+++ b/arch/arm/mm/flush.c
@@ -377,3 +377,22 @@ void __flush_anon_page(struct vm_area_struct *vma, struct page *page, unsigned l
 	 */
 	__cpuc_flush_dcache_area(page_address(page), PAGE_SIZE);
 }
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
+static void thp_splitting_flush_sync(void *arg)
+{
+}
+
+void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
+			  pmd_t *pmdp)
+{
+	pmd_t pmd = pmd_mksplitting(*pmdp);
+	VM_BUG_ON(address & ~PMD_MASK);
+	set_pmd_at(vma->vm_mm, address, pmdp, pmd);
+
+	/* dummy IPI to serialise against fast_gup */
+	smp_call_function(thp_splitting_flush_sync, NULL, 1);
+}
+#endif /* CONFIG_HAVE_RCU_TABLE_FREE */
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
