Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 172776B0071
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 04:26:13 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so53843396pdb.2
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 01:26:12 -0700 (PDT)
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com. [122.248.162.1])
        by mx.google.com with ESMTPS id c1si2406958pdk.235.2015.04.30.01.26.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Apr 2015 01:26:12 -0700 (PDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 30 Apr 2015 13:56:08 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id A25113940053
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 13:56:05 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3U8PpCO56295610
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 13:55:51 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3U8Po0v029908
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 13:55:50 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 2/3] powerpc/thp: Remove _PAGE_SPLITTING and related code
Date: Thu, 30 Apr 2015 13:55:40 +0530
Message-Id: <1430382341-8316-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1430382341-8316-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1430382341-8316-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, paulus@samba.org, benh@kernel.crashing.org, kirill.shutemov@linux.intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

With the new thp refcounting we don't need to mark the PMD splitting.
Drop the code to handle this.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/kvm_book3s_64.h |  6 -----
 arch/powerpc/include/asm/pgtable-ppc64.h | 27 ++++-------------------
 arch/powerpc/mm/hugepage-hash64.c        |  3 ---
 arch/powerpc/mm/hugetlbpage.c            |  2 +-
 arch/powerpc/mm/pgtable_64.c             | 38 +++++---------------------------
 mm/gup.c                                 |  2 +-
 6 files changed, 12 insertions(+), 66 deletions(-)

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
index 843cb35e6add..ff275443a040 100644
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
@@ -577,9 +558,9 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm, unsigned long addr,
 	pmd_hugepage_update(mm, addr, pmdp, _PAGE_RW, 0);
 }
 
-#define __HAVE_ARCH_PMDP_SPLITTING_FLUSH
-extern void pmdp_splitting_flush(struct vm_area_struct *vma,
-				 unsigned long address, pmd_t *pmdp);
+#define __HAVE_ARCH_PMDP_SPLITTING_FLUSH_NOTIFY
+extern void pmdp_splitting_flush_notify(struct vm_area_struct *vma,
+					unsigned long address, pmd_t *pmdp);
 
 #define __HAVE_ARCH_PGTABLE_DEPOSIT
 extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
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
index 91bb8836825a..89b356250be3 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -36,6 +36,7 @@
 #include <linux/memblock.h>
 #include <linux/slab.h>
 #include <linux/hugetlb.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/pgalloc.h>
 #include <asm/page.h>
@@ -622,47 +623,20 @@ int pmdp_clear_flush_young(struct vm_area_struct *vma,
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
+	trace_hugepage_splitting(address, *pmdp);
+	pmdp_clear_flush_notify(vma, address, pmdp);
 	/*
 	 * This ensures that generic code that rely on IRQ disabling
-	 * to prevent a parallel THP split work as expected.
+	 * to prevent a parallel THP PMD split work as expected.
 	 */
 	kick_all_cpus_sync();
 }
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
