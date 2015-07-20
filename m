Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id D1C89280256
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 10:22:04 -0400 (EDT)
Received: by iggf3 with SMTP id f3so82592020igg.1
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 07:22:04 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id a20si16482149ioe.144.2015.07.20.07.21.58
        for <linux-mm@kvack.org>;
        Mon, 20 Jul 2015 07:21:59 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9 20/36] powerpc, thp: remove infrastructure for handling splitting PMDs
Date: Mon, 20 Jul 2015 17:20:53 +0300
Message-Id: <1437402069-105900-21-git-send-email-kirill.shutemov@linux.intel.com>
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
Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/pgtable-ppc64.h | 25 +---------------
 arch/powerpc/mm/hugepage-hash64.c        |  3 --
 arch/powerpc/mm/hugetlbpage.c            |  4 ---
 arch/powerpc/mm/pgtable_64.c             | 49 --------------------------------
 4 files changed, 1 insertion(+), 80 deletions(-)

diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
index 58c61500993f..d5d854bd47c1 100644
--- a/arch/powerpc/include/asm/pgtable-ppc64.h
+++ b/arch/powerpc/include/asm/pgtable-ppc64.h
@@ -358,11 +358,6 @@ void pgtable_cache_init(void);
 #endif /* __ASSEMBLY__ */
 
 /*
- * THP pages can't be special. So use the _PAGE_SPECIAL
- */
-#define _PAGE_SPLITTING _PAGE_SPECIAL
-
-/*
  * We need to differentiate between explicit huge page and THP huge
  * page, since THP huge page also need to track real subpage details
  */
@@ -372,8 +367,7 @@ void pgtable_cache_init(void);
  * set of bits not changed in pmd_modify.
  */
 #define _HPAGE_CHG_MASK (PTE_RPN_MASK | _PAGE_HPTEFLAGS |		\
-			 _PAGE_DIRTY | _PAGE_ACCESSED | _PAGE_SPLITTING | \
-			 _PAGE_THP_HUGE)
+			 _PAGE_DIRTY | _PAGE_ACCESSED | _PAGE_THP_HUGE)
 
 #ifndef __ASSEMBLY__
 /*
@@ -455,13 +449,6 @@ static inline int pmd_trans_huge(pmd_t pmd)
 	return (pmd_val(pmd) & 0x3) && (pmd_val(pmd) & _PAGE_THP_HUGE);
 }
 
-static inline int pmd_trans_splitting(pmd_t pmd)
-{
-	if (pmd_trans_huge(pmd))
-		return pmd_val(pmd) & _PAGE_SPLITTING;
-	return 0;
-}
-
 extern int has_transparent_hugepage(void);
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
@@ -514,12 +501,6 @@ static inline pmd_t pmd_mknotpresent(pmd_t pmd)
 	return pmd;
 }
 
-static inline pmd_t pmd_mksplitting(pmd_t pmd)
-{
-	pmd_val(pmd) |= _PAGE_SPLITTING;
-	return pmd;
-}
-
 #define __HAVE_ARCH_PMD_SAME
 static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_b)
 {
@@ -570,10 +551,6 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm, unsigned long addr,
 	pmd_hugepage_update(mm, addr, pmdp, _PAGE_RW, 0);
 }
 
-#define __HAVE_ARCH_PMDP_SPLITTING_FLUSH
-extern void pmdp_splitting_flush(struct vm_area_struct *vma,
-				 unsigned long address, pmd_t *pmdp);
-
 extern pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
 				 unsigned long address, pmd_t *pmdp);
 #define pmdp_collapse_flush pmdp_collapse_flush
diff --git a/arch/powerpc/mm/hugepage-hash64.c b/arch/powerpc/mm/hugepage-hash64.c
index 43dafb9d6a46..adc3860ce9e7 100644
--- a/arch/powerpc/mm/hugepage-hash64.c
+++ b/arch/powerpc/mm/hugepage-hash64.c
@@ -39,9 +39,6 @@ int __hash_page_thp(unsigned long ea, unsigned long access, unsigned long vsid,
 		/* If PMD busy, retry the access */
 		if (unlikely(old_pmd & _PAGE_BUSY))
 			return 0;
-		/* If PMD is trans splitting retry the access */
-		if (unlikely(old_pmd & _PAGE_SPLITTING))
-			return 0;
 		/* If PMD permissions don't match, take page fault */
 		if (unlikely(access & ~old_pmd))
 			return 1;
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index f119edaa6961..dfab6627ca63 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -1015,10 +1015,6 @@ pte_t *__find_linux_pte_or_hugepte(pgd_t *pgdir, unsigned long ea,
 			/*
 			 * A hugepage collapse is captured by pmd_none, because
 			 * it mark the pmd none and do a hpte invalidate.
-			 *
-			 * We don't worry about pmd_trans_splitting here, The
-			 * caller if it needs to handle the splitting case
-			 * should check for that.
 			 */
 			if (pmd_none(pmd))
 				return NULL;
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index 876232d64126..ac8f12d3cfce 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -614,55 +614,6 @@ int pmdp_clear_flush_young(struct vm_area_struct *vma,
 }
 
 /*
- * We mark the pmd splitting and invalidate all the hpte
- * entries for this hugepage.
- */
-void pmdp_splitting_flush(struct vm_area_struct *vma,
-			  unsigned long address, pmd_t *pmdp)
-{
-	unsigned long old, tmp;
-
-	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
-
-#ifdef CONFIG_DEBUG_VM
-	WARN_ON(!pmd_trans_huge(*pmdp));
-	assert_spin_locked(&vma->vm_mm->page_table_lock);
-#endif
-
-#ifdef PTE_ATOMIC_UPDATES
-
-	__asm__ __volatile__(
-	"1:	ldarx	%0,0,%3\n\
-		andi.	%1,%0,%6\n\
-		bne-	1b \n\
-		ori	%1,%0,%4 \n\
-		stdcx.	%1,0,%3 \n\
-		bne-	1b"
-	: "=&r" (old), "=&r" (tmp), "=m" (*pmdp)
-	: "r" (pmdp), "i" (_PAGE_SPLITTING), "m" (*pmdp), "i" (_PAGE_BUSY)
-	: "cc" );
-#else
-	old = pmd_val(*pmdp);
-	*pmdp = __pmd(old | _PAGE_SPLITTING);
-#endif
-	/*
-	 * If we didn't had the splitting flag set, go and flush the
-	 * HPTE entries.
-	 */
-	trace_hugepage_splitting(address, old);
-	if (!(old & _PAGE_SPLITTING)) {
-		/* We need to flush the hpte */
-		if (old & _PAGE_HASHPTE)
-			hpte_do_hugepage_flush(vma->vm_mm, address, pmdp, old);
-	}
-	/*
-	 * This ensures that generic code that rely on IRQ disabling
-	 * to prevent a parallel THP split work as expected.
-	 */
-	kick_all_cpus_sync();
-}
-
-/*
  * We want to put the pgtable in pmd and use pgtable for tracking
  * the base page size hptes
  */
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
