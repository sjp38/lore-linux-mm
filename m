Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 073AD900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 13:06:46 -0400 (EDT)
Received: by pabqy3 with SMTP id qy3so11098932pab.3
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 10:06:45 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id hq3si1800802pac.164.2015.06.03.10.06.35
        for <linux-mm@kvack.org>;
        Wed, 03 Jun 2015 10:06:35 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 21/36] s390, thp: remove infrastructure for handling splitting PMDs
Date: Wed,  3 Jun 2015 20:05:52 +0300
Message-Id: <1433351167-125878-22-git-send-email-kirill.shutemov@linux.intel.com>
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
 arch/s390/include/asm/pgtable.h | 15 +--------------
 arch/s390/mm/gup.c              | 11 +----------
 arch/s390/mm/pgtable.c          | 16 ----------------
 3 files changed, 2 insertions(+), 40 deletions(-)

diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index cf7e7c6bab9d..06bf2f1367f9 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -380,7 +380,6 @@ static inline int is_module_addr(void *addr)
 
 #define _SEGMENT_ENTRY_DIRTY	0x2000	/* SW segment dirty bit */
 #define _SEGMENT_ENTRY_YOUNG	0x1000	/* SW segment young bit */
-#define _SEGMENT_ENTRY_SPLIT	0x0800	/* THP splitting bit */
 #define _SEGMENT_ENTRY_LARGE	0x0400	/* STE-format control, large page */
 #define _SEGMENT_ENTRY_READ	0x0002	/* SW segment read bit */
 #define _SEGMENT_ENTRY_WRITE	0x0001	/* SW segment write bit */
@@ -404,8 +403,6 @@ static inline int is_module_addr(void *addr)
  * read-write, old segment table entries (origin!=0)
  */
 
-#define _SEGMENT_ENTRY_SPLIT_BIT 11	/* THP splitting bit number */
-
 /* Page status table bits for virtualization */
 #define PGSTE_ACC_BITS	0xf000000000000000UL
 #define PGSTE_FP_BIT	0x0800000000000000UL
@@ -617,10 +614,6 @@ static inline int pmd_bad(pmd_t pmd)
 	return (pmd_val(pmd) & ~_SEGMENT_ENTRY_BITS) != 0;
 }
 
-#define __HAVE_ARCH_PMDP_SPLITTING_FLUSH
-extern void pmdp_splitting_flush(struct vm_area_struct *vma,
-				 unsigned long addr, pmd_t *pmdp);
-
 #define  __HAVE_ARCH_PMDP_SET_ACCESS_FLAGS
 extern int pmdp_set_access_flags(struct vm_area_struct *vma,
 				 unsigned long address, pmd_t *pmdp,
@@ -1494,7 +1487,7 @@ static inline pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
 	if (pmd_large(pmd)) {
 		pmd_val(pmd) &= _SEGMENT_ENTRY_ORIGIN_LARGE |
 			_SEGMENT_ENTRY_DIRTY | _SEGMENT_ENTRY_YOUNG |
-			_SEGMENT_ENTRY_LARGE | _SEGMENT_ENTRY_SPLIT;
+			_SEGMENT_ENTRY_LARGE;
 		pmd_val(pmd) |= massage_pgprot_pmd(newprot);
 		if (!(pmd_val(pmd) & _SEGMENT_ENTRY_DIRTY))
 			pmd_val(pmd) |= _SEGMENT_ENTRY_PROTECT;
@@ -1602,12 +1595,6 @@ extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 #define __HAVE_ARCH_PGTABLE_WITHDRAW
 extern pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp);
 
-static inline int pmd_trans_splitting(pmd_t pmd)
-{
-	return (pmd_val(pmd) & _SEGMENT_ENTRY_LARGE) &&
-		(pmd_val(pmd) & _SEGMENT_ENTRY_SPLIT);
-}
-
 static inline void set_pmd_at(struct mm_struct *mm, unsigned long addr,
 			      pmd_t *pmdp, pmd_t entry)
 {
diff --git a/arch/s390/mm/gup.c b/arch/s390/mm/gup.c
index dab30527ad41..83eb4629bdb2 100644
--- a/arch/s390/mm/gup.c
+++ b/arch/s390/mm/gup.c
@@ -104,16 +104,7 @@ static inline int gup_pmd_range(pud_t *pudp, pud_t pud, unsigned long addr,
 		pmd = *pmdp;
 		barrier();
 		next = pmd_addr_end(addr, end);
-		/*
-		 * The pmd_trans_splitting() check below explains why
-		 * pmdp_splitting_flush() has to serialize with
-		 * smp_call_function() against our disabled IRQs, to stop
-		 * this gup-fast code from running while we set the
-		 * splitting bit in the pmd. Returning zero will take
-		 * the slow path that will call wait_split_huge_page()
-		 * if the pmd is still in splitting state.
-		 */
-		if (pmd_none(pmd) || pmd_trans_splitting(pmd))
+		if (pmd_none(pmd))
 			return 0;
 		if (unlikely(pmd_large(pmd))) {
 			if (!gup_huge_pmd(pmdp, pmd, addr, next,
diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index b2c1542f2ba2..5736232f7936 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -1419,22 +1419,6 @@ int pmdp_set_access_flags(struct vm_area_struct *vma,
 	return 1;
 }
 
-static void pmdp_splitting_flush_sync(void *arg)
-{
-	/* Simply deliver the interrupt */
-}
-
-void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
-			  pmd_t *pmdp)
-{
-	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
-	if (!test_and_set_bit(_SEGMENT_ENTRY_SPLIT_BIT,
-			      (unsigned long *) pmdp)) {
-		/* need to serialize against gup-fast (IRQ disabled) */
-		smp_call_function(pmdp_splitting_flush_sync, NULL, 1);
-	}
-}
-
 void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 				pgtable_t pgtable)
 {
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
