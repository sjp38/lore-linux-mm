Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id A81A76B02B1
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 11:24:16 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id m184so192252304qkb.1
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 08:24:16 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id d187si14784013qkf.270.2016.09.26.08.24.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 08:24:16 -0700 (PDT)
From: zi.yan@sent.com
Subject: [PATCH v1 12/12] mm: ppc64: Add THP migration support for ppc64.
Date: Mon, 26 Sep 2016 11:22:34 -0400
Message-Id: <20160926152234.14809-13-zi.yan@sent.com>
In-Reply-To: <20160926152234.14809-1-zi.yan@sent.com>
References: <20160926152234.14809-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: benh@kernel.crashing.org, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, Zi Yan <zi.yan@cs.rutgers.edu>

From: Zi Yan <zi.yan@cs.rutgers.edu>

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
---
 arch/powerpc/Kconfig                         |  4 ++++
 arch/powerpc/include/asm/book3s/64/pgtable.h | 23 +++++++++++++++++++++++
 2 files changed, 27 insertions(+)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 927d2ab..84ffd4c 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -553,6 +553,10 @@ config ARCH_SPARSEMEM_DEFAULT
 config SYS_SUPPORTS_HUGETLBFS
 	bool
 
+config ARCH_ENABLE_THP_MIGRATION
+	def_bool y
+	depends on PPC64 && TRANSPARENT_HUGEPAGE && MIGRATION
+
 source "mm/Kconfig"
 
 config ARCH_MEMORY_PROBE
diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 263bf39..9dee0467 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -521,7 +521,9 @@ static inline bool pte_user(pte_t pte)
  * Clear bits not found in swap entries here.
  */
 #define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val((pte)) & ~_PAGE_PTE })
+#define __pmd_to_swp_entry(pte)	((swp_entry_t) { pmd_val((pte)) & ~_PAGE_PTE })
 #define __swp_entry_to_pte(x)	__pte((x).val | _PAGE_PTE)
+#define __swp_entry_to_pmd(x)	__pmd((x).val | _PAGE_PTE)
 
 #ifdef CONFIG_MEM_SOFT_DIRTY
 #define _PAGE_SWP_SOFT_DIRTY   (1UL << (SWP_TYPE_BITS + _PAGE_BIT_SWAP_TYPE))
@@ -662,6 +664,10 @@ static inline int pmd_bad(pmd_t pmd)
 		return radix__pmd_bad(pmd);
 	return hash__pmd_bad(pmd);
 }
+static inline int __pmd_present(pmd_t pte)
+{
+	return !!(pmd_val(pte) & _PAGE_PRESENT);
+}
 
 static inline void pud_set(pud_t *pudp, unsigned long val)
 {
@@ -850,6 +856,23 @@ static inline pte_t *pmdp_ptep(pmd_t *pmd)
 #define pmd_soft_dirty(pmd)    pte_soft_dirty(pmd_pte(pmd))
 #define pmd_mksoft_dirty(pmd)  pte_pmd(pte_mksoft_dirty(pmd_pte(pmd)))
 #define pmd_clear_soft_dirty(pmd) pte_pmd(pte_clear_soft_dirty(pmd_pte(pmd)))
+
+#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
+static inline pmd_t pmd_swp_mksoft_dirty(pmd_t pmd)
+{
+	return pte_pmd(pte_swp_mksoft_dirty(pmd_pte(pmd)));
+}
+
+static inline int pmd_swp_soft_dirty(pmd_t pmd)
+{
+	return pte_swp_soft_dirty(pmd_pte(pmd));
+}
+
+static inline pmd_t pmd_swp_clear_soft_dirty(pmd_t pmd)
+{
+	return pte_pmd(pte_swp_clear_soft_dirty(pmd_pte(pmd)));
+}
+#endif
 #endif /* CONFIG_HAVE_ARCH_SOFT_DIRTY */
 
 #ifdef CONFIG_NUMA_BALANCING
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
