Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id EDD2C6B028F
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 04:29:43 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 83so100545824pfx.1
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 01:29:43 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n8si3197248paw.303.2016.11.10.01.29.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Nov 2016 01:29:43 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAA9SptC081929
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 04:29:42 -0500
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26mm3sxefc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 04:29:42 -0500
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 10 Nov 2016 02:29:41 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 4/4] powerpc/mm: update pte_update to not do full mm tlb flush
Date: Thu, 10 Nov 2016 14:59:18 +0530
In-Reply-To: <20161110092918.21139-1-aneesh.kumar@linux.vnet.ibm.com>
References: <20161110092918.21139-1-aneesh.kumar@linux.vnet.ibm.com>
Message-Id: <20161110092918.21139-4-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

When we are updating pte, we just need to flush the tlb mapping for
that pte. Right now we do a full mm flush because we don't track page
size. Update the interface to track the page size and use that to
do the right tlb flush.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/hugetlb.h | 16 +++++++++++++++-
 arch/powerpc/include/asm/book3s/64/pgtable.h | 16 ++++++++++------
 arch/powerpc/include/asm/book3s/64/radix.h   | 19 ++++++++-----------
 arch/powerpc/include/asm/hugetlb.h           |  2 +-
 arch/powerpc/mm/pgtable-radix.c              |  2 +-
 5 files changed, 35 insertions(+), 20 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/hugetlb.h b/arch/powerpc/include/asm/book3s/64/hugetlb.h
index 58e00dbbf15c..dfe917b40f26 100644
--- a/arch/powerpc/include/asm/book3s/64/hugetlb.h
+++ b/arch/powerpc/include/asm/book3s/64/hugetlb.h
@@ -29,13 +29,27 @@ static inline int hstate_get_psize(struct hstate *hstate)
 	}
 }
 
+static inline unsigned long huge_pte_update(struct vm_area_struct *vma, unsigned long addr,
+					    pte_t *ptep, unsigned long clr,
+					    unsigned long set)
+{
+	unsigned long pg_sz;
+
+	VM_WARN_ON(!is_vm_hugetlb_page(vma));
+	pg_sz = huge_page_size(hstate_vma(vma));
+
+	if (radix_enabled())
+		return radix__pte_update(vma->vm_mm, addr, ptep, clr, set, pg_sz);
+	return hash__pte_update(vma->vm_mm, addr, ptep, clr, set, true);
+}
+
 static inline void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
 					   unsigned long addr, pte_t *ptep)
 {
 	if ((pte_raw(*ptep) & cpu_to_be64(_PAGE_WRITE)) == 0)
 		return;
 
-	pte_update(vma->vm_mm, addr, ptep, _PAGE_WRITE, 0, 1);
+	huge_pte_update(vma, addr, ptep, _PAGE_WRITE, 0);
 }
 
 #endif
diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index ef2eef1ba99a..09869ad37aba 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -301,12 +301,16 @@ extern unsigned long pci_io_base;
 
 static inline unsigned long pte_update(struct mm_struct *mm, unsigned long addr,
 				       pte_t *ptep, unsigned long clr,
-				       unsigned long set, int huge)
+				       unsigned long set,
+				       unsigned long pg_sz)
 {
+	bool huge = (pg_sz != PAGE_SIZE);
+
 	if (radix_enabled())
-		return radix__pte_update(mm, addr, ptep, clr, set, huge);
+		return radix__pte_update(mm, addr, ptep, clr, set, pg_sz);
 	return hash__pte_update(mm, addr, ptep, clr, set, huge);
 }
+
 /*
  * For hash even if we have _PAGE_ACCESSED = 0, we do a pte_update.
  * We currently remove entries from the hashtable regardless of whether
@@ -324,7 +328,7 @@ static inline int __ptep_test_and_clear_young(struct mm_struct *mm,
 
 	if ((pte_raw(*ptep) & cpu_to_be64(_PAGE_ACCESSED | H_PAGE_HASHPTE)) == 0)
 		return 0;
-	old = pte_update(mm, addr, ptep, _PAGE_ACCESSED, 0, 0);
+	old = pte_update(mm, addr, ptep, _PAGE_ACCESSED, 0, PAGE_SIZE);
 	return (old & _PAGE_ACCESSED) != 0;
 }
 
@@ -343,21 +347,21 @@ static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr,
 	if ((pte_raw(*ptep) & cpu_to_be64(_PAGE_WRITE)) == 0)
 		return;
 
-	pte_update(mm, addr, ptep, _PAGE_WRITE, 0, 0);
+	pte_update(mm, addr, ptep, _PAGE_WRITE, 0, PAGE_SIZE);
 }
 
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
 static inline pte_t ptep_get_and_clear(struct mm_struct *mm,
 				       unsigned long addr, pte_t *ptep)
 {
-	unsigned long old = pte_update(mm, addr, ptep, ~0UL, 0, 0);
+	unsigned long old = pte_update(mm, addr, ptep, ~0UL, 0, PAGE_SIZE);
 	return __pte(old);
 }
 
 static inline void pte_clear(struct mm_struct *mm, unsigned long addr,
 			     pte_t * ptep)
 {
-	pte_update(mm, addr, ptep, ~0UL, 0, 0);
+	pte_update(mm, addr, ptep, ~0UL, 0, PAGE_SIZE);
 }
 
 static inline int pte_write(pte_t pte)
diff --git a/arch/powerpc/include/asm/book3s/64/radix.h b/arch/powerpc/include/asm/book3s/64/radix.h
index 279b2f68e00f..aec6e8ee6e27 100644
--- a/arch/powerpc/include/asm/book3s/64/radix.h
+++ b/arch/powerpc/include/asm/book3s/64/radix.h
@@ -129,15 +129,16 @@ static inline unsigned long __radix_pte_update(pte_t *ptep, unsigned long clr,
 
 
 static inline unsigned long radix__pte_update(struct mm_struct *mm,
-					unsigned long addr,
-					pte_t *ptep, unsigned long clr,
-					unsigned long set,
-					int huge)
+					      unsigned long addr,
+					      pte_t *ptep, unsigned long clr,
+					      unsigned long set,
+					      unsigned long pg_sz)
 {
 	unsigned long old_pte;
 
 	if (cpu_has_feature(CPU_FTR_POWER9_DD1)) {
 
+		int psize;
 		unsigned long new_pte;
 
 		old_pte = __radix_pte_update(ptep, ~0, 0);
@@ -146,18 +147,14 @@ static inline unsigned long radix__pte_update(struct mm_struct *mm,
 		 * new value of pte
 		 */
 		new_pte = (old_pte | set) & ~clr;
-
-		/*
-		 * For now let's do heavy pid flush
-		 * radix__flush_tlb_page_psize(mm, addr, mmu_virtual_psize);
-		 */
-		radix__flush_tlb_mm(mm);
+		psize = radix_get_mmu_psize(pg_sz);
+		radix__flush_tlb_page_psize(mm, addr, psize);
 
 		__radix_pte_update(ptep, 0, new_pte);
 	} else
 		old_pte = __radix_pte_update(ptep, clr, set);
 	asm volatile("ptesync" : : : "memory");
-	if (!huge)
+	if (pg_sz == PAGE_SIZE)
 		assert_pte_locked(mm, addr);
 
 	return old_pte;
diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
index b152e0c8dc4e..f0731dff76c2 100644
--- a/arch/powerpc/include/asm/hugetlb.h
+++ b/arch/powerpc/include/asm/hugetlb.h
@@ -136,7 +136,7 @@ static inline pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma,
 					    unsigned long addr, pte_t *ptep)
 {
 #ifdef CONFIG_PPC64
-	return __pte(pte_update(vma->vm_mm, addr, ptep, ~0UL, 0, 1));
+	return __pte(huge_pte_update(vma, addr, ptep, ~0UL, 0));
 #else
 	return __pte(pte_update(ptep, ~0UL, 0));
 #endif
diff --git a/arch/powerpc/mm/pgtable-radix.c b/arch/powerpc/mm/pgtable-radix.c
index 6b1ffc449158..735be6821e90 100644
--- a/arch/powerpc/mm/pgtable-radix.c
+++ b/arch/powerpc/mm/pgtable-radix.c
@@ -482,7 +482,7 @@ unsigned long radix__pmd_hugepage_update(struct mm_struct *mm, unsigned long add
 	assert_spin_locked(&mm->page_table_lock);
 #endif
 
-	old = radix__pte_update(mm, addr, (pte_t *)pmdp, clr, set, 1);
+	old = radix__pte_update(mm, addr, (pte_t *)pmdp, clr, set, HPAGE_PMD_SIZE);
 	trace_hugepage_update(addr, old, clr, set);
 
 	return old;
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
