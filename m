Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id 7F9766B005A
	for <linux-mm@kvack.org>; Fri, 28 Mar 2014 11:02:00 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id w61so2801570wes.32
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 08:02:00 -0700 (PDT)
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
        by mx.google.com with ESMTPS id o13si2340493wij.21.2014.03.28.08.01.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 28 Mar 2014 08:01:59 -0700 (PDT)
Received: by mail-we0-f176.google.com with SMTP id x48so2783044wes.35
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 08:01:58 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [RFC PATCH V4 7/7] arm64: mm: Enable RCU fast_gup
Date: Fri, 28 Mar 2014 15:01:32 +0000
Message-Id: <1396018892-6773-8-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1396018892-6773-1-git-send-email-steve.capper@linaro.org>
References: <1396018892-6773-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, linux@arm.linux.org.uk, linux-mm@kvack.org, linux-arch@vger.kernel.org
Cc: peterz@infradead.org, gary.robertson@linaro.org, anders.roxell@linaro.org, akpm@linux-foundation.org, Steve Capper <steve.capper@linaro.org>

Activate the RCU fast_gup for ARM64. We also need to force THP splits
to broadcast an IPI s.t. we block in the fast_gup page walker. As THP
splits are comparatively rare, this should not lead to a noticeable
performance degradation.

Signed-off-by: Steve Capper <steve.capper@linaro.org>
---
 arch/arm64/Kconfig               |  3 +++
 arch/arm64/include/asm/pgtable.h |  4 ++++
 arch/arm64/mm/flush.c            | 19 +++++++++++++++++++
 3 files changed, 26 insertions(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 6185f95..9f5a81a 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -86,6 +86,9 @@ config GENERIC_CSUM
 config GENERIC_CALIBRATE_DELAY
 	def_bool y
 
+config HAVE_RCU_GUP
+	def_bool y
+
 config ZONE_DMA32
 	def_bool y
 
diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index aa3917c..0e148ae 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -245,6 +245,10 @@ static inline void set_pte_at(struct mm_struct *mm, unsigned long addr,
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 #define pmd_trans_huge(pmd)	(pmd_val(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT))
 #define pmd_trans_splitting(pmd) (pmd_val(pmd) & PMD_SECT_SPLITTING)
+#define __HAVE_ARCH_PMDP_SPLITTING_FLUSH
+struct vm_area_struct;
+void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
+			  pmd_t *pmdp);
 #endif
 
 #define PMD_BIT_FUNC(fn,op) \
diff --git a/arch/arm64/mm/flush.c b/arch/arm64/mm/flush.c
index e4193e3..ddf96c1 100644
--- a/arch/arm64/mm/flush.c
+++ b/arch/arm64/mm/flush.c
@@ -103,3 +103,22 @@ EXPORT_SYMBOL(flush_dcache_page);
  */
 EXPORT_SYMBOL(flush_cache_all);
 EXPORT_SYMBOL(flush_icache_range);
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
