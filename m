Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6CE6E6B003A
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 22:44:00 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id kx10so8561808pab.21
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 19:44:00 -0800 (PST)
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com. [122.248.162.7])
        by mx.google.com with ESMTPS id m8si21065269pbq.359.2014.02.11.19.43.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 19:43:59 -0800 (PST)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 12 Feb 2014 09:13:54 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 3EA951258053
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 09:15:45 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1C3hjmc48759036
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 09:13:45 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1C3hnct020064
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 09:13:50 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 1/3] powerpc: mm: Add new set flag argument to pte/pmd update function
Date: Wed, 12 Feb 2014 09:13:36 +0530
Message-Id: <1392176618-23667-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1392176618-23667-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1392176618-23667-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, riel@redhat.com, mgorman@suse.de, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We will use this later to set the _PAGE_NUMA bit.

Acked-by: Mel Gorman <mgorman@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/hugetlb.h       |  2 +-
 arch/powerpc/include/asm/pgtable-ppc64.h | 26 +++++++++++++++-----------
 arch/powerpc/mm/pgtable_64.c             | 12 +++++++-----
 arch/powerpc/mm/subpage-prot.c           |  2 +-
 4 files changed, 24 insertions(+), 18 deletions(-)

diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
index d750336b171d..623f2971ce0e 100644
--- a/arch/powerpc/include/asm/hugetlb.h
+++ b/arch/powerpc/include/asm/hugetlb.h
@@ -127,7 +127,7 @@ static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
 					    unsigned long addr, pte_t *ptep)
 {
 #ifdef CONFIG_PPC64
-	return __pte(pte_update(mm, addr, ptep, ~0UL, 1));
+	return __pte(pte_update(mm, addr, ptep, ~0UL, 0, 1));
 #else
 	return __pte(pte_update(ptep, ~0UL, 0));
 #endif
diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
index bc141c950b1e..eb9261024f51 100644
--- a/arch/powerpc/include/asm/pgtable-ppc64.h
+++ b/arch/powerpc/include/asm/pgtable-ppc64.h
@@ -195,6 +195,7 @@ extern void hpte_need_flush(struct mm_struct *mm, unsigned long addr,
 static inline unsigned long pte_update(struct mm_struct *mm,
 				       unsigned long addr,
 				       pte_t *ptep, unsigned long clr,
+				       unsigned long set,
 				       int huge)
 {
 #ifdef PTE_ATOMIC_UPDATES
@@ -205,14 +206,15 @@ static inline unsigned long pte_update(struct mm_struct *mm,
 	andi.	%1,%0,%6\n\
 	bne-	1b \n\
 	andc	%1,%0,%4 \n\
+	or	%1,%1,%7\n\
 	stdcx.	%1,0,%3 \n\
 	bne-	1b"
 	: "=&r" (old), "=&r" (tmp), "=m" (*ptep)
-	: "r" (ptep), "r" (clr), "m" (*ptep), "i" (_PAGE_BUSY)
+	: "r" (ptep), "r" (clr), "m" (*ptep), "i" (_PAGE_BUSY), "r" (set)
 	: "cc" );
 #else
 	unsigned long old = pte_val(*ptep);
-	*ptep = __pte(old & ~clr);
+	*ptep = __pte((old & ~clr) | set);
 #endif
 	/* huge pages use the old page table lock */
 	if (!huge)
@@ -231,9 +233,9 @@ static inline int __ptep_test_and_clear_young(struct mm_struct *mm,
 {
 	unsigned long old;
 
-       	if ((pte_val(*ptep) & (_PAGE_ACCESSED | _PAGE_HASHPTE)) == 0)
+	if ((pte_val(*ptep) & (_PAGE_ACCESSED | _PAGE_HASHPTE)) == 0)
 		return 0;
-	old = pte_update(mm, addr, ptep, _PAGE_ACCESSED, 0);
+	old = pte_update(mm, addr, ptep, _PAGE_ACCESSED, 0, 0);
 	return (old & _PAGE_ACCESSED) != 0;
 }
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
@@ -252,7 +254,7 @@ static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr,
 	if ((pte_val(*ptep) & _PAGE_RW) == 0)
 		return;
 
-	pte_update(mm, addr, ptep, _PAGE_RW, 0);
+	pte_update(mm, addr, ptep, _PAGE_RW, 0, 0);
 }
 
 static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
@@ -261,7 +263,7 @@ static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
 	if ((pte_val(*ptep) & _PAGE_RW) == 0)
 		return;
 
-	pte_update(mm, addr, ptep, _PAGE_RW, 1);
+	pte_update(mm, addr, ptep, _PAGE_RW, 0, 1);
 }
 
 /*
@@ -284,14 +286,14 @@ static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
 static inline pte_t ptep_get_and_clear(struct mm_struct *mm,
 				       unsigned long addr, pte_t *ptep)
 {
-	unsigned long old = pte_update(mm, addr, ptep, ~0UL, 0);
+	unsigned long old = pte_update(mm, addr, ptep, ~0UL, 0, 0);
 	return __pte(old);
 }
 
 static inline void pte_clear(struct mm_struct *mm, unsigned long addr,
 			     pte_t * ptep)
 {
-	pte_update(mm, addr, ptep, ~0UL, 0);
+	pte_update(mm, addr, ptep, ~0UL, 0, 0);
 }
 
 
@@ -506,7 +508,9 @@ extern int pmdp_set_access_flags(struct vm_area_struct *vma,
 
 extern unsigned long pmd_hugepage_update(struct mm_struct *mm,
 					 unsigned long addr,
-					 pmd_t *pmdp, unsigned long clr);
+					 pmd_t *pmdp,
+					 unsigned long clr,
+					 unsigned long set);
 
 static inline int __pmdp_test_and_clear_young(struct mm_struct *mm,
 					      unsigned long addr, pmd_t *pmdp)
@@ -515,7 +519,7 @@ static inline int __pmdp_test_and_clear_young(struct mm_struct *mm,
 
 	if ((pmd_val(*pmdp) & (_PAGE_ACCESSED | _PAGE_HASHPTE)) == 0)
 		return 0;
-	old = pmd_hugepage_update(mm, addr, pmdp, _PAGE_ACCESSED);
+	old = pmd_hugepage_update(mm, addr, pmdp, _PAGE_ACCESSED, 0);
 	return ((old & _PAGE_ACCESSED) != 0);
 }
 
@@ -542,7 +546,7 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm, unsigned long addr,
 	if ((pmd_val(*pmdp) & _PAGE_RW) == 0)
 		return;
 
-	pmd_hugepage_update(mm, addr, pmdp, _PAGE_RW);
+	pmd_hugepage_update(mm, addr, pmdp, _PAGE_RW, 0);
 }
 
 #define __HAVE_ARCH_PMDP_SPLITTING_FLUSH
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index 65b7b65e8708..62bf5e8e78da 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -510,7 +510,8 @@ int pmdp_set_access_flags(struct vm_area_struct *vma, unsigned long address,
 }
 
 unsigned long pmd_hugepage_update(struct mm_struct *mm, unsigned long addr,
-				  pmd_t *pmdp, unsigned long clr)
+				  pmd_t *pmdp, unsigned long clr,
+				  unsigned long set)
 {
 
 	unsigned long old, tmp;
@@ -526,14 +527,15 @@ unsigned long pmd_hugepage_update(struct mm_struct *mm, unsigned long addr,
 		andi.	%1,%0,%6\n\
 		bne-	1b \n\
 		andc	%1,%0,%4 \n\
+		or	%1,%1,%7\n\
 		stdcx.	%1,0,%3 \n\
 		bne-	1b"
 	: "=&r" (old), "=&r" (tmp), "=m" (*pmdp)
-	: "r" (pmdp), "r" (clr), "m" (*pmdp), "i" (_PAGE_BUSY)
+	: "r" (pmdp), "r" (clr), "m" (*pmdp), "i" (_PAGE_BUSY), "r" (set)
 	: "cc" );
 #else
 	old = pmd_val(*pmdp);
-	*pmdp = __pmd(old & ~clr);
+	*pmdp = __pmd((old & ~clr) | set);
 #endif
 	if (old & _PAGE_HASHPTE)
 		hpte_do_hugepage_flush(mm, addr, pmdp);
@@ -708,7 +710,7 @@ void set_pmd_at(struct mm_struct *mm, unsigned long addr,
 void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
 		     pmd_t *pmdp)
 {
-	pmd_hugepage_update(vma->vm_mm, address, pmdp, _PAGE_PRESENT);
+	pmd_hugepage_update(vma->vm_mm, address, pmdp, _PAGE_PRESENT, 0);
 }
 
 /*
@@ -835,7 +837,7 @@ pmd_t pmdp_get_and_clear(struct mm_struct *mm,
 	unsigned long old;
 	pgtable_t *pgtable_slot;
 
-	old = pmd_hugepage_update(mm, addr, pmdp, ~0UL);
+	old = pmd_hugepage_update(mm, addr, pmdp, ~0UL, 0);
 	old_pmd = __pmd(old);
 	/*
 	 * We have pmd == none and we are holding page_table_lock.
diff --git a/arch/powerpc/mm/subpage-prot.c b/arch/powerpc/mm/subpage-prot.c
index a770df2dae70..6c0b1f5f8d2c 100644
--- a/arch/powerpc/mm/subpage-prot.c
+++ b/arch/powerpc/mm/subpage-prot.c
@@ -78,7 +78,7 @@ static void hpte_flush_range(struct mm_struct *mm, unsigned long addr,
 	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	arch_enter_lazy_mmu_mode();
 	for (; npages > 0; --npages) {
-		pte_update(mm, addr, pte, 0, 0);
+		pte_update(mm, addr, pte, 0, 0, 0);
 		addr += PAGE_SIZE;
 		++pte;
 	}
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
