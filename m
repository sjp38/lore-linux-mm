Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 06FB2900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 13:06:33 -0400 (EDT)
Received: by payr10 with SMTP id r10so11228787pay.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 10:06:32 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id fl4si1824970pab.108.2015.06.03.10.06.27
        for <linux-mm@kvack.org>;
        Wed, 03 Jun 2015 10:06:28 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 20/36] powerpc, thp: remove infrastructure for handling splitting PMDs
Date: Wed,  3 Jun 2015 20:05:51 +0300
Message-Id: <1433351167-125878-21-git-send-email-kirill.shutemov@linux.intel.com>
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
 arch/powerpc/include/asm/kvm_book3s_64.h |  6 ----
 arch/powerpc/include/asm/pgtable-ppc64.h | 25 +---------------
 arch/powerpc/mm/hugepage-hash64.c        |  3 --
 arch/powerpc/mm/hugetlbpage.c            |  7 +----
 arch/powerpc/mm/pgtable_64.c             | 49 --------------------------------
 5 files changed, 2 insertions(+), 88 deletions(-)

diff --git a/arch/powerpc/include/asm/kvm_book3s_64.h b/arch/powerpc/include/asm/kvm_book3s_64.h
index 2d81e202bdcc..9a96fe3caa48 100644
--- a/arch/powerpc/include/asm/kvm_book3s_64.h
+++ b/arch/powerpc/include/asm/kvm_book3s_64.h
@@ -298,12 +298,6 @@ static inline pte_t kvmppc_read_update_linux_pte(pte_t *ptep, int writing,
 			cpu_relax();
 			continue;
 		}
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-		/* If hugepage and is trans splitting return None */
-		if (unlikely(hugepage &&
-			     pmd_trans_splitting(pte_pmd(old_pte))))
-			return __pte(0);
-#endif
 		/* If pte is not present return None */
 		if (unlikely(!(old_pte & _PAGE_PRESENT)))
 			return __pte(0);
diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
index 012e3adab7f8..5729b303d206 100644
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
 #define pmdp_collapse_flush pmdp_collapse_flush
 extern pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
 				 unsigned long address, pmd_t *pmdp);
diff --git a/arch/powerpc/mm/hugepage-hash64.c b/arch/powerpc/mm/hugepage-hash64.c
index 86686514ae13..078f7207afd2 100644
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
index 5f979e51ef7b..a09ff52b906e 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -997,13 +997,8 @@ pte_t *find_linux_pte_or_hugepte(pgd_t *pgdir, unsigned long ea, unsigned *shift
 			/*
 			 * A hugepage collapse is captured by pmd_none, because
 			 * it mark the pmd none and do a hpte invalidate.
-			 *
-			 * A hugepage split is captured by pmd_trans_splitting
-			 * because we mark the pmd trans splitting and do a
-			 * hpte invalidate
-			 *
 			 */
-			if (pmd_none(pmd) || pmd_trans_splitting(pmd))
+			if (pmd_none(pmd))
 				return NULL;
 
 			if (pmd_huge(pmd) || pmd_large(pmd)) {
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index 52c4827bceb0..7bad475bc235 100644
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
