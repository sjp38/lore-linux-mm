Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 518899003CD
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 11:21:24 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so50714251pac.2
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 08:21:24 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id rm9si41952280pab.171.2015.09.03.08.14.00
        for <linux-mm@kvack.org>;
        Thu, 03 Sep 2015 08:14:00 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv10 24/36] x86, thp: remove infrastructure for handling splitting PMDs
Date: Thu,  3 Sep 2015 18:13:10 +0300
Message-Id: <1441293202-137314-25-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1441293202-137314-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1441293202-137314-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With new refcounting we don't need to mark PMDs splitting. Let's drop
code to handle this.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
Acked-by: Jerome Marchand <jmarchan@redhat.com>
---
 arch/x86/include/asm/pgtable.h       |  9 ---------
 arch/x86/include/asm/pgtable_types.h |  2 --
 arch/x86/mm/gup.c                    | 13 +------------
 arch/x86/mm/pgtable.c                | 14 --------------
 4 files changed, 1 insertion(+), 37 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index b964d54300e1..a8fdfe0d7277 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -158,11 +158,6 @@ static inline int pmd_large(pmd_t pte)
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-static inline int pmd_trans_splitting(pmd_t pmd)
-{
-	return pmd_val(pmd) & _PAGE_SPLITTING;
-}
-
 static inline int pmd_trans_huge(pmd_t pmd)
 {
 	return pmd_val(pmd) & _PAGE_PSE;
@@ -800,10 +795,6 @@ extern int pmdp_clear_flush_young(struct vm_area_struct *vma,
 				  unsigned long address, pmd_t *pmdp);
 
 
-#define __HAVE_ARCH_PMDP_SPLITTING_FLUSH
-extern void pmdp_splitting_flush(struct vm_area_struct *vma,
-				 unsigned long addr, pmd_t *pmdp);
-
 #define __HAVE_ARCH_PMD_WRITE
 static inline int pmd_write(pmd_t pmd)
 {
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 13f310bfc09a..d173197cfd9e 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -22,7 +22,6 @@
 #define _PAGE_BIT_PAT_LARGE	12	/* On 2MB or 1GB pages */
 #define _PAGE_BIT_SPECIAL	_PAGE_BIT_SOFTW1
 #define _PAGE_BIT_CPA_TEST	_PAGE_BIT_SOFTW1
-#define _PAGE_BIT_SPLITTING	_PAGE_BIT_SOFTW2 /* only valid on a PSE pmd */
 #define _PAGE_BIT_HIDDEN	_PAGE_BIT_SOFTW3 /* hidden by kmemcheck */
 #define _PAGE_BIT_SOFT_DIRTY	_PAGE_BIT_SOFTW3 /* software dirty tracking */
 #define _PAGE_BIT_NX           63       /* No execute: only valid after cpuid check */
@@ -46,7 +45,6 @@
 #define _PAGE_PAT_LARGE (_AT(pteval_t, 1) << _PAGE_BIT_PAT_LARGE)
 #define _PAGE_SPECIAL	(_AT(pteval_t, 1) << _PAGE_BIT_SPECIAL)
 #define _PAGE_CPA_TEST	(_AT(pteval_t, 1) << _PAGE_BIT_CPA_TEST)
-#define _PAGE_SPLITTING	(_AT(pteval_t, 1) << _PAGE_BIT_SPLITTING)
 #define __HAVE_ARCH_PTE_SPECIAL
 
 #ifdef CONFIG_KMEMCHECK
diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index 62a887a3cf50..49bbbc57603b 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -157,18 +157,7 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 		pmd_t pmd = *pmdp;
 
 		next = pmd_addr_end(addr, end);
-		/*
-		 * The pmd_trans_splitting() check below explains why
-		 * pmdp_splitting_flush has to flush the tlb, to stop
-		 * this gup-fast code from running while we set the
-		 * splitting bit in the pmd. Returning zero will take
-		 * the slow path that will call wait_split_huge_page()
-		 * if the pmd is still in splitting state. gup-fast
-		 * can't because it has irq disabled and
-		 * wait_split_huge_page() would never return as the
-		 * tlb flush IPI wouldn't run.
-		 */
-		if (pmd_none(pmd) || pmd_trans_splitting(pmd))
+		if (pmd_none(pmd))
 			return 0;
 		if (unlikely(pmd_large(pmd) || !pmd_present(pmd))) {
 			/*
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index fb0a9dd1d6e4..f52caf9c519b 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -509,20 +509,6 @@ int pmdp_clear_flush_young(struct vm_area_struct *vma,
 
 	return young;
 }
-
-void pmdp_splitting_flush(struct vm_area_struct *vma,
-			  unsigned long address, pmd_t *pmdp)
-{
-	int set;
-	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
-	set = !test_and_set_bit(_PAGE_BIT_SPLITTING,
-				(unsigned long *)pmdp);
-	if (set) {
-		pmd_update(vma->vm_mm, address, pmdp);
-		/* need tlb flush only to serialize against gup-fast */
-		flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
-	}
-}
 #endif
 
 /**
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
