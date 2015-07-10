Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id ECEC49003DA
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 13:43:05 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so55845215pdr.2
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 10:43:05 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id c11si15440173pat.225.2015.07.10.10.42.59
        for <linux-mm@kvack.org>;
        Fri, 10 Jul 2015 10:42:59 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 17/36] arm64, thp: remove infrastructure for handling splitting PMDs
Date: Fri, 10 Jul 2015 20:41:51 +0300
Message-Id: <1436550130-112636-18-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1436550130-112636-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1436550130-112636-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With new refcounting we don't need to mark PMDs splitting. Let's drop
code to handle this.

pmdp_splitting_flush() is not needed too: on splitting PMD we will do
pmdp_clear_flush() + set_pte_at(). pmdp_clear_flush() will do IPI as
needed for fast_gup.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/arm64/include/asm/pgtable.h |  9 ---------
 arch/arm64/mm/flush.c            | 16 ----------------
 2 files changed, 25 deletions(-)

diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index bd5db28324ba..37cdbf37934c 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -274,20 +274,11 @@ static inline pgprot_t mk_sect_prot(pgprot_t prot)
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 #define pmd_trans_huge(pmd)	(pmd_val(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT))
-#define pmd_trans_splitting(pmd)	pte_special(pmd_pte(pmd))
-#ifdef CONFIG_HAVE_RCU_TABLE_FREE
-#define __HAVE_ARCH_PMDP_SPLITTING_FLUSH
-struct vm_area_struct;
-void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
-			  pmd_t *pmdp);
-#endif /* CONFIG_HAVE_RCU_TABLE_FREE */
-#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #define pmd_dirty(pmd)		pte_dirty(pmd_pte(pmd))
 #define pmd_young(pmd)		pte_young(pmd_pte(pmd))
 #define pmd_dirty(pmd)		pte_dirty(pmd_pte(pmd))
 #define pmd_wrprotect(pmd)	pte_pmd(pte_wrprotect(pmd_pte(pmd)))
-#define pmd_mksplitting(pmd)	pte_pmd(pte_mkspecial(pmd_pte(pmd)))
 #define pmd_mkold(pmd)		pte_pmd(pte_mkold(pmd_pte(pmd)))
 #define pmd_mkwrite(pmd)	pte_pmd(pte_mkwrite(pmd_pte(pmd)))
 #define pmd_mkclean(pmd)	pte_pmd(pte_mkclean(pmd_pte(pmd)))
diff --git a/arch/arm64/mm/flush.c b/arch/arm64/mm/flush.c
index b6f14e8d2121..0d64089d28b5 100644
--- a/arch/arm64/mm/flush.c
+++ b/arch/arm64/mm/flush.c
@@ -104,19 +104,3 @@ EXPORT_SYMBOL(flush_dcache_page);
  */
 EXPORT_SYMBOL(flush_cache_all);
 EXPORT_SYMBOL(flush_icache_range);
-
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-#ifdef CONFIG_HAVE_RCU_TABLE_FREE
-void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
-			  pmd_t *pmdp)
-{
-	pmd_t pmd = pmd_mksplitting(*pmdp);
-
-	VM_BUG_ON(address & ~PMD_MASK);
-	set_pmd_at(vma->vm_mm, address, pmdp, pmd);
-
-	/* dummy IPI to serialise against fast_gup */
-	kick_all_cpus_sync();
-}
-#endif /* CONFIG_HAVE_RCU_TABLE_FREE */
-#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
