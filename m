Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 07BC66B006C
	for <linux-mm@kvack.org>; Fri,  1 May 2015 01:43:57 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so81871857pab.3
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 22:43:56 -0700 (PDT)
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com. [122.248.162.1])
        by mx.google.com with ESMTPS id kj7si2781279pab.146.2015.04.30.22.43.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Apr 2015 22:43:55 -0700 (PDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 1 May 2015 11:13:52 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id D7E401258060
	for <linux-mm@kvack.org>; Fri,  1 May 2015 11:15:50 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t415hk7560948554
	for <linux-mm@kvack.org>; Fri, 1 May 2015 11:13:47 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t415hkNt005971
	for <linux-mm@kvack.org>; Fri, 1 May 2015 11:13:46 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 2/2] powerpc/thp: Remove _PAGE_SPLITTING and related code
Date: Fri,  1 May 2015 11:13:26 +0530
Message-Id: <1430459006-18142-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1430459006-18142-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1430459006-18142-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mpe@ellerman.id.au, paulus@samba.org, benh@kernel.crashing.org, kirill.shutemov@linux.intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

With the new thp refcounting we don't need to mark the PMD splitting.
Drop the code to handle this.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/kvm_book3s_64.h |   6 --
 arch/powerpc/include/asm/pgtable-ppc64.h |  29 ++------
 arch/powerpc/mm/hugepage-hash64.c        |   3 -
 arch/powerpc/mm/hugetlbpage.c            |   2 +-
 arch/powerpc/mm/pgtable_64.c             | 111 ++++++++++++-------------------
 mm/gup.c                                 |   2 +-
 6 files changed, 52 insertions(+), 101 deletions(-)

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
index 843cb35e6add..655dde8e9683 100644
--- a/arch/powerpc/include/asm/pgtable-ppc64.h
+++ b/arch/powerpc/include/asm/pgtable-ppc64.h
@@ -361,11 +361,6 @@ void pgtable_cache_init(void);
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
@@ -375,8 +370,7 @@ void pgtable_cache_init(void);
  * set of bits not changed in pmd_modify.
  */
 #define _HPAGE_CHG_MASK (PTE_RPN_MASK | _PAGE_HPTEFLAGS |		\
-			 _PAGE_DIRTY | _PAGE_ACCESSED | _PAGE_SPLITTING | \
-			 _PAGE_THP_HUGE)
+			 _PAGE_DIRTY | _PAGE_ACCESSED | _PAGE_THP_HUGE)
 
 #ifndef __ASSEMBLY__
 /*
@@ -458,13 +452,6 @@ static inline int pmd_trans_huge(pmd_t pmd)
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
 
@@ -517,12 +504,6 @@ static inline pmd_t pmd_mknotpresent(pmd_t pmd)
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
@@ -577,8 +558,12 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm, unsigned long addr,
 	pmd_hugepage_update(mm, addr, pmdp, _PAGE_RW, 0);
 }
 
-#define __HAVE_ARCH_PMDP_SPLITTING_FLUSH
-extern void pmdp_splitting_flush(struct vm_area_struct *vma,
+#define __HAVE_ARCH_PMDP_SPLITTING_FLUSH_NOTIFY
+extern void pmdp_splitting_flush_notify(struct vm_area_struct *vma,
+					unsigned long address, pmd_t *pmdp);
+
+#define __HAVE_ARCH_PMDP_COLLAPSE_FLUSH
+extern pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
 				 unsigned long address, pmd_t *pmdp);
 
 #define __HAVE_ARCH_PGTABLE_DEPOSIT
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
index f30ae0f7f570..dfd7db0cfbee 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -1008,7 +1008,7 @@ pte_t *find_linux_pte_or_hugepte(pgd_t *pgdir, unsigned long ea, unsigned *shift
 			 * hpte invalidate
 			 *
 			 */
-			if (pmd_none(pmd) || pmd_trans_splitting(pmd))
+			if (pmd_none(pmd))
 				return NULL;
 
 			if (pmd_huge(pmd) || pmd_large(pmd)) {
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index 91bb8836825a..fa49e2ff042b 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -36,6 +36,7 @@
 #include <linux/memblock.h>
 #include <linux/slab.h>
 #include <linux/hugetlb.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/pgalloc.h>
 #include <asm/page.h>
@@ -557,45 +558,9 @@ unsigned long pmd_hugepage_update(struct mm_struct *mm, unsigned long addr,
 pmd_t pmdp_clear_flush(struct vm_area_struct *vma, unsigned long address,
 		       pmd_t *pmdp)
 {
-	pmd_t pmd;
-
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
-	if (pmd_trans_huge(*pmdp)) {
-		pmd = pmdp_get_and_clear(vma->vm_mm, address, pmdp);
-	} else {
-		/*
-		 * khugepaged calls this for normal pmd
-		 */
-		pmd = *pmdp;
-		pmd_clear(pmdp);
-		/*
-		 * Wait for all pending hash_page to finish. This is needed
-		 * in case of subpage collapse. When we collapse normal pages
-		 * to hugepage, we first clear the pmd, then invalidate all
-		 * the PTE entries. The assumption here is that any low level
-		 * page fault will see a none pmd and take the slow path that
-		 * will wait on mmap_sem. But we could very well be in a
-		 * hash_page with local ptep pointer value. Such a hash page
-		 * can result in adding new HPTE entries for normal subpages.
-		 * That means we could be modifying the page content as we
-		 * copy them to a huge page. So wait for parallel hash_page
-		 * to finish before invalidating HPTE entries. We can do this
-		 * by sending an IPI to all the cpus and executing a dummy
-		 * function there.
-		 */
-		kick_all_cpus_sync();
-		/*
-		 * Now invalidate the hpte entries in the range
-		 * covered by pmd. This make sure we take a
-		 * fault and will find the pmd as none, which will
-		 * result in a major fault which takes mmap_sem and
-		 * hence wait for collapse to complete. Without this
-		 * the __collapse_huge_page_copy can result in copying
-		 * the old content.
-		 */
-		flush_tlb_pmd_range(vma->vm_mm, &pmd, address);
-	}
-	return pmd;
+	VM_BUG_ON(!pmd_trans_huge(*pmdp));
+	return pmdp_get_and_clear(vma->vm_mm, address, pmdp);
 }
 
 int pmdp_test_and_clear_young(struct vm_area_struct *vma,
@@ -622,49 +587,59 @@ int pmdp_clear_flush_young(struct vm_area_struct *vma,
  * We mark the pmd splitting and invalidate all the hpte
  * entries for this hugepage.
  */
-void pmdp_splitting_flush(struct vm_area_struct *vma,
-			  unsigned long address, pmd_t *pmdp)
+void pmdp_splitting_flush_notify(struct vm_area_struct *vma,
+				 unsigned long address, pmd_t *pmdp)
 {
-	unsigned long old, tmp;
-
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 
 #ifdef CONFIG_DEBUG_VM
 	WARN_ON(!pmd_trans_huge(*pmdp));
 	assert_spin_locked(&vma->vm_mm->page_table_lock);
 #endif
+	trace_hugepage_splitting(address, *pmdp);
+	pmdp_clear_flush_notify(vma, address, pmdp);
+	/*
+	 * This ensures that generic code that rely on IRQ disabling
+	 * to prevent a parallel THP PMD split work as expected.
+	 */
+	kick_all_cpus_sync();
+}
 
-#ifdef PTE_ATOMIC_UPDATES
+pmd_t pmdp_collapse_flush(struct vm_area_struct *vma, unsigned long address,
+			  pmd_t *pmdp)
+{
+	pmd_t pmd;
 
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
+	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+	pmd = *pmdp;
+	pmd_clear(pmdp);
 	/*
-	 * If we didn't had the splitting flag set, go and flush the
-	 * HPTE entries.
+	 * Wait for all pending hash_page to finish. This is needed
+	 * in case of subpage collapse. When we collapse normal pages
+	 * to hugepage, we first clear the pmd, then invalidate all
+	 * the PTE entries. The assumption here is that any low level
+	 * page fault will see a none pmd and take the slow path that
+	 * will wait on mmap_sem. But we could very well be in a
+	 * hash_page with local ptep pointer value. Such a hash page
+	 * can result in adding new HPTE entries for normal subpages.
+	 * That means we could be modifying the page content as we
+	 * copy them to a huge page. So wait for parallel hash_page
+	 * to finish before invalidating HPTE entries. We can do this
+	 * by sending an IPI to all the cpus and executing a dummy
+	 * function there.
 	 */
-	trace_hugepage_splitting(address, old);
-	if (!(old & _PAGE_SPLITTING)) {
-		/* We need to flush the hpte */
-		if (old & _PAGE_HASHPTE)
-			hpte_do_hugepage_flush(vma->vm_mm, address, pmdp, old);
-	}
+	kick_all_cpus_sync();
 	/*
-	 * This ensures that generic code that rely on IRQ disabling
-	 * to prevent a parallel THP split work as expected.
+	 * Now invalidate the hpte entries in the range
+	 * covered by pmd. This make sure we take a
+	 * fault and will find the pmd as none, which will
+	 * result in a major fault which takes mmap_sem and
+	 * hence wait for collapse to complete. Without this
+	 * the __collapse_huge_page_copy can result in copying
+	 * the old content.
 	 */
-	kick_all_cpus_sync();
+	flush_tlb_pmd_range(vma->vm_mm, &pmd, address);
+	return pmd;
 }
 
 /*
diff --git a/mm/gup.c b/mm/gup.c
index 0cebfa76fd0c..8375781b76f0 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1215,7 +1215,7 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 		pmd_t pmd = ACCESS_ONCE(*pmdp);
 
 		next = pmd_addr_end(addr, end);
-		if (pmd_none(pmd) || pmd_trans_splitting(pmd))
+		if (pmd_none(pmd))
 			return 0;
 
 		if (unlikely(pmd_trans_huge(pmd) || pmd_huge(pmd))) {
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
