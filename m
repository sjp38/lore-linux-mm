Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id CD8D3900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 13:06:30 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so11639495pdb.2
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 10:06:30 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id yr1si1835637pbc.78.2015.06.03.10.06.27
        for <linux-mm@kvack.org>;
        Wed, 03 Jun 2015 10:06:28 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 18/36] arm, thp: remove infrastructure for handling splitting PMDs
Date: Wed,  3 Jun 2015 20:05:49 +0300
Message-Id: <1433351167-125878-19-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com>
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
 arch/arm/include/asm/pgtable-3level.h | 10 ----------
 arch/arm/lib/uaccess_with_memcpy.c    |  5 ++---
 arch/arm/mm/flush.c                   | 15 ---------------
 3 files changed, 2 insertions(+), 28 deletions(-)

diff --git a/arch/arm/include/asm/pgtable-3level.h b/arch/arm/include/asm/pgtable-3level.h
index 6d6012a320b2..d42f81f13618 100644
--- a/arch/arm/include/asm/pgtable-3level.h
+++ b/arch/arm/include/asm/pgtable-3level.h
@@ -88,7 +88,6 @@
 
 #define L_PMD_SECT_VALID	(_AT(pmdval_t, 1) << 0)
 #define L_PMD_SECT_DIRTY	(_AT(pmdval_t, 1) << 55)
-#define L_PMD_SECT_SPLITTING	(_AT(pmdval_t, 1) << 56)
 #define L_PMD_SECT_NONE		(_AT(pmdval_t, 1) << 57)
 #define L_PMD_SECT_RDONLY	(_AT(pteval_t, 1) << 58)
 
@@ -232,21 +231,12 @@ static inline pte_t pte_mkspecial(pte_t pte)
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 #define pmd_trans_huge(pmd)	(pmd_val(pmd) && !pmd_table(pmd))
-#define pmd_trans_splitting(pmd) (pmd_isset((pmd), L_PMD_SECT_SPLITTING))
-
-#ifdef CONFIG_HAVE_RCU_TABLE_FREE
-#define __HAVE_ARCH_PMDP_SPLITTING_FLUSH
-void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
-			  pmd_t *pmdp);
-#endif
-#endif
 
 #define PMD_BIT_FUNC(fn,op) \
 static inline pmd_t pmd_##fn(pmd_t pmd) { pmd_val(pmd) op; return pmd; }
 
 PMD_BIT_FUNC(wrprotect,	|= L_PMD_SECT_RDONLY);
 PMD_BIT_FUNC(mkold,	&= ~PMD_SECT_AF);
-PMD_BIT_FUNC(mksplitting, |= L_PMD_SECT_SPLITTING);
 PMD_BIT_FUNC(mkwrite,   &= ~L_PMD_SECT_RDONLY);
 PMD_BIT_FUNC(mkdirty,   |= L_PMD_SECT_DIRTY);
 PMD_BIT_FUNC(mkclean,   &= ~L_PMD_SECT_DIRTY);
diff --git a/arch/arm/lib/uaccess_with_memcpy.c b/arch/arm/lib/uaccess_with_memcpy.c
index 3e58d710013c..11af98f46f05 100644
--- a/arch/arm/lib/uaccess_with_memcpy.c
+++ b/arch/arm/lib/uaccess_with_memcpy.c
@@ -52,14 +52,13 @@ pin_page_for_write(const void __user *_addr, pte_t **ptep, spinlock_t **ptlp)
 	 *
 	 * Lock the page table for the destination and check
 	 * to see that it's still huge and whether or not we will
-	 * need to fault on write, or if we have a splitting THP.
+	 * need to fault on write.
 	 */
 	if (unlikely(pmd_thp_or_huge(*pmd))) {
 		ptl = &current->mm->page_table_lock;
 		spin_lock(ptl);
 		if (unlikely(!pmd_thp_or_huge(*pmd)
-			|| pmd_hugewillfault(*pmd)
-			|| pmd_trans_splitting(*pmd))) {
+			|| pmd_hugewillfault(*pmd))) {
 			spin_unlock(ptl);
 			return 0;
 		}
diff --git a/arch/arm/mm/flush.c b/arch/arm/mm/flush.c
index 34b66af516ea..77f229302032 100644
--- a/arch/arm/mm/flush.c
+++ b/arch/arm/mm/flush.c
@@ -400,18 +400,3 @@ void __flush_anon_page(struct vm_area_struct *vma, struct page *page, unsigned l
 	 */
 	__cpuc_flush_dcache_area(page_address(page), PAGE_SIZE);
 }
-
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-#ifdef CONFIG_HAVE_RCU_TABLE_FREE
-void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
-			  pmd_t *pmdp)
-{
-	pmd_t pmd = pmd_mksplitting(*pmdp);
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
