Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id C7945280266
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 10:29:06 -0400 (EDT)
Received: by pdbbh15 with SMTP id bh15so57068863pdb.1
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 07:29:06 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ez11si36318526pac.113.2015.07.20.07.21.28
        for <linux-mm@kvack.org>;
        Mon, 20 Jul 2015 07:21:29 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9 17/36] arm64, thp: remove infrastructure for handling splitting PMDs
Date: Mon, 20 Jul 2015 17:20:50 +0300
Message-Id: <1437402069-105900-18-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com>
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
 arch/arm64/include/asm/pgtable.h |  8 --------
 arch/arm64/mm/flush.c            | 16 ----------------
 2 files changed, 24 deletions(-)

diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index bd5db28324ba..26c7dea80062 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -274,20 +274,12 @@ static inline pgprot_t mk_sect_prot(pgprot_t prot)
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 #define pmd_trans_huge(pmd)	(pmd_val(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT))
-#define pmd_trans_splitting(pmd)	pte_special(pmd_pte(pmd))
-#ifdef CONFIG_HAVE_RCU_TABLE_FREE
-#define __HAVE_ARCH_PMDP_SPLITTING_FLUSH
-struct vm_area_struct;
-void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
-			  pmd_t *pmdp);
-#endif /* CONFIG_HAVE_RCU_TABLE_FREE */
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
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
