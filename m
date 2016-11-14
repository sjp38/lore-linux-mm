Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2506D6B0253
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 10:20:39 -0500 (EST)
Received: by mail-pa0-f70.google.com with SMTP id kr7so91665364pab.5
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 07:20:39 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 75si22614665pfa.10.2016.11.14.07.20.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Nov 2016 07:20:37 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAEFIkRq022734
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 10:20:36 -0500
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26qefj4fsb-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 10:20:36 -0500
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 14 Nov 2016 08:20:34 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH v2 1/2] hugetlb: Change the function prototype to take vma_area_struct as arg
Date: Mon, 14 Nov 2016 20:50:19 +0530
Message-Id: <20161114152020.4608-1-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This help us to find the hugetlb page size which we need ot use on some
archs like ppc64 for tlbflush. This also make the interface consistent
with other hugetlb functions

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
NOTE: This series is dependent on another series posted here.
https://lists.ozlabs.org/pipermail/linuxppc-dev/2016-November/150948.html

 arch/arm/include/asm/hugetlb-3level.h        |  8 ++++----
 arch/arm64/include/asm/hugetlb.h             |  4 ++--
 arch/arm64/mm/hugetlbpage.c                  |  7 +++++--
 arch/ia64/include/asm/hugetlb.h              |  8 ++++----
 arch/metag/include/asm/hugetlb.h             |  8 ++++----
 arch/mips/include/asm/hugetlb.h              |  7 ++++---
 arch/parisc/include/asm/hugetlb.h            |  4 ++--
 arch/parisc/mm/hugetlbpage.c                 |  6 ++++--
 arch/powerpc/include/asm/book3s/32/pgtable.h |  4 ++--
 arch/powerpc/include/asm/book3s/64/hugetlb.h |  4 ++--
 arch/powerpc/include/asm/hugetlb.h           |  6 +++---
 arch/powerpc/include/asm/nohash/32/pgtable.h |  4 ++--
 arch/powerpc/include/asm/nohash/64/pgtable.h |  4 ++--
 arch/s390/include/asm/hugetlb.h              | 12 ++++++------
 arch/s390/mm/hugetlbpage.c                   |  3 ++-
 arch/sh/include/asm/hugetlb.h                |  8 ++++----
 arch/sparc/include/asm/hugetlb.h             |  6 +++---
 arch/sparc/mm/hugetlbpage.c                  |  3 ++-
 arch/tile/include/asm/hugetlb.h              |  8 ++++----
 arch/x86/include/asm/hugetlb.h               |  8 ++++----
 mm/hugetlb.c                                 |  6 +++---
 21 files changed, 68 insertions(+), 60 deletions(-)

diff --git a/arch/arm/include/asm/hugetlb-3level.h b/arch/arm/include/asm/hugetlb-3level.h
index d4014fbe5ea3..b71839e1786f 100644
--- a/arch/arm/include/asm/hugetlb-3level.h
+++ b/arch/arm/include/asm/hugetlb-3level.h
@@ -49,16 +49,16 @@ static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
 	ptep_clear_flush(vma, addr, ptep);
 }
 
-static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
+static inline void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
 					   unsigned long addr, pte_t *ptep)
 {
-	ptep_set_wrprotect(mm, addr, ptep);
+	ptep_set_wrprotect(vma->vm_mm, addr, ptep);
 }
 
-static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
+static inline pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma,
 					    unsigned long addr, pte_t *ptep)
 {
-	return ptep_get_and_clear(mm, addr, ptep);
+	return ptep_get_and_clear(vma->vm_mm, addr, ptep);
 }
 
 static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
index bbc1e35aa601..4e54d4b58d3e 100644
--- a/arch/arm64/include/asm/hugetlb.h
+++ b/arch/arm64/include/asm/hugetlb.h
@@ -76,9 +76,9 @@ extern void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 extern int huge_ptep_set_access_flags(struct vm_area_struct *vma,
 				      unsigned long addr, pte_t *ptep,
 				      pte_t pte, int dirty);
-extern pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
+extern pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma,
 				     unsigned long addr, pte_t *ptep);
-extern void huge_ptep_set_wrprotect(struct mm_struct *mm,
+extern void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
 				    unsigned long addr, pte_t *ptep);
 extern void huge_ptep_clear_flush(struct vm_area_struct *vma,
 				  unsigned long addr, pte_t *ptep);
diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index 2e49bd252fe7..5c8903433cd9 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -197,10 +197,11 @@ pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
 	return entry;
 }
 
-pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
+pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma,
 			      unsigned long addr, pte_t *ptep)
 {
 	pte_t pte;
+	struct mm_struct *mm = vma->vm_mm;
 
 	if (pte_cont(*ptep)) {
 		int ncontig, i;
@@ -263,9 +264,11 @@ int huge_ptep_set_access_flags(struct vm_area_struct *vma,
 	}
 }
 
-void huge_ptep_set_wrprotect(struct mm_struct *mm,
+void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
 			     unsigned long addr, pte_t *ptep)
 {
+	struct mm_struct *mm = vma->vm_mm;
+
 	if (pte_cont(*ptep)) {
 		int ncontig, i;
 		pte_t *cpte;
diff --git a/arch/ia64/include/asm/hugetlb.h b/arch/ia64/include/asm/hugetlb.h
index ef65f026b11e..eb1c1d674200 100644
--- a/arch/ia64/include/asm/hugetlb.h
+++ b/arch/ia64/include/asm/hugetlb.h
@@ -26,10 +26,10 @@ static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 	set_pte_at(mm, addr, ptep, pte);
 }
 
-static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
+static inline pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma,
 					    unsigned long addr, pte_t *ptep)
 {
-	return ptep_get_and_clear(mm, addr, ptep);
+	return ptep_get_and_clear(vma->vm_mm, addr, ptep);
 }
 
 static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
@@ -47,10 +47,10 @@ static inline pte_t huge_pte_wrprotect(pte_t pte)
 	return pte_wrprotect(pte);
 }
 
-static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
+static inline void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
 					   unsigned long addr, pte_t *ptep)
 {
-	ptep_set_wrprotect(mm, addr, ptep);
+	ptep_set_wrprotect(vma->vm_mm, addr, ptep);
 }
 
 static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
diff --git a/arch/metag/include/asm/hugetlb.h b/arch/metag/include/asm/hugetlb.h
index 905ed422dbeb..310b103127a6 100644
--- a/arch/metag/include/asm/hugetlb.h
+++ b/arch/metag/include/asm/hugetlb.h
@@ -28,10 +28,10 @@ static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 	set_pte_at(mm, addr, ptep, pte);
 }
 
-static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
+static inline pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma,
 					    unsigned long addr, pte_t *ptep)
 {
-	return ptep_get_and_clear(mm, addr, ptep);
+	return ptep_get_and_clear(vma->vm_mm, addr, ptep);
 }
 
 static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
@@ -49,10 +49,10 @@ static inline pte_t huge_pte_wrprotect(pte_t pte)
 	return pte_wrprotect(pte);
 }
 
-static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
+static inline void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
 					   unsigned long addr, pte_t *ptep)
 {
-	ptep_set_wrprotect(mm, addr, ptep);
+	ptep_set_wrprotect(vma->vm_mm, addr, ptep);
 }
 
 static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
diff --git a/arch/mips/include/asm/hugetlb.h b/arch/mips/include/asm/hugetlb.h
index 982bc0685330..4380acbff8e2 100644
--- a/arch/mips/include/asm/hugetlb.h
+++ b/arch/mips/include/asm/hugetlb.h
@@ -53,11 +53,12 @@ static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 	set_pte_at(mm, addr, ptep, pte);
 }
 
-static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
+static inline pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma,
 					    unsigned long addr, pte_t *ptep)
 {
 	pte_t clear;
 	pte_t pte = *ptep;
+	struct mm_struct *mm = vma->vm_mm;
 
 	pte_val(clear) = (unsigned long)invalid_pte_table;
 	set_pte_at(mm, addr, ptep, clear);
@@ -81,10 +82,10 @@ static inline pte_t huge_pte_wrprotect(pte_t pte)
 	return pte_wrprotect(pte);
 }
 
-static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
+static inline void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
 					   unsigned long addr, pte_t *ptep)
 {
-	ptep_set_wrprotect(mm, addr, ptep);
+	ptep_set_wrprotect(vma->vm_mm, addr, ptep);
 }
 
 static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
diff --git a/arch/parisc/include/asm/hugetlb.h b/arch/parisc/include/asm/hugetlb.h
index a65d888716c4..3a6070842016 100644
--- a/arch/parisc/include/asm/hugetlb.h
+++ b/arch/parisc/include/asm/hugetlb.h
@@ -8,7 +8,7 @@
 void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 		     pte_t *ptep, pte_t pte);
 
-pte_t huge_ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
+pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma, unsigned long addr,
 			      pte_t *ptep);
 
 static inline int is_hugepage_only_range(struct mm_struct *mm,
@@ -54,7 +54,7 @@ static inline pte_t huge_pte_wrprotect(pte_t pte)
 	return pte_wrprotect(pte);
 }
 
-void huge_ptep_set_wrprotect(struct mm_struct *mm,
+void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
 					   unsigned long addr, pte_t *ptep);
 
 int huge_ptep_set_access_flags(struct vm_area_struct *vma,
diff --git a/arch/parisc/mm/hugetlbpage.c b/arch/parisc/mm/hugetlbpage.c
index 5d6eea925cf4..e01fd08ed72c 100644
--- a/arch/parisc/mm/hugetlbpage.c
+++ b/arch/parisc/mm/hugetlbpage.c
@@ -142,11 +142,12 @@ void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 }
 
 
-pte_t huge_ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
+pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma, unsigned long addr,
 			      pte_t *ptep)
 {
 	unsigned long flags;
 	pte_t entry;
+	struct mm_struct *mm = vma->vma_mm;
 
 	purge_tlb_start(flags);
 	entry = *ptep;
@@ -157,11 +158,12 @@ pte_t huge_ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
 }
 
 
-void huge_ptep_set_wrprotect(struct mm_struct *mm,
+void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
 				unsigned long addr, pte_t *ptep)
 {
 	unsigned long flags;
 	pte_t old_pte;
+	struct mm_struct *mm = vma->vm_mm;
 
 	purge_tlb_start(flags);
 	old_pte = *ptep;
diff --git a/arch/powerpc/include/asm/book3s/32/pgtable.h b/arch/powerpc/include/asm/book3s/32/pgtable.h
index 0713626e9189..34c8fd0c5d04 100644
--- a/arch/powerpc/include/asm/book3s/32/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/32/pgtable.h
@@ -216,10 +216,10 @@ static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr,
 {
 	pte_update(ptep, (_PAGE_RW | _PAGE_HWWRITE), _PAGE_RO);
 }
-static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
+static inline void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
 					   unsigned long addr, pte_t *ptep)
 {
-	ptep_set_wrprotect(mm, addr, ptep);
+	ptep_set_wrprotect(vma->vm_mm, addr, ptep);
 }
 
 
diff --git a/arch/powerpc/include/asm/book3s/64/hugetlb.h b/arch/powerpc/include/asm/book3s/64/hugetlb.h
index 9a64f356a8e8..80fa0c828413 100644
--- a/arch/powerpc/include/asm/book3s/64/hugetlb.h
+++ b/arch/powerpc/include/asm/book3s/64/hugetlb.h
@@ -63,13 +63,13 @@ static inline unsigned long huge_pte_update(struct mm_struct *mm, unsigned long
 	return hash__pte_update(mm, addr, ptep, clr, set, true);
 }
 
-static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
+static inline void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
 					   unsigned long addr, pte_t *ptep)
 {
 	if ((pte_raw(*ptep) & cpu_to_be64(_PAGE_WRITE)) == 0)
 		return;
 
-	huge_pte_update(mm, addr, ptep, _PAGE_WRITE, 0);
+	huge_pte_update(vma->vm_mm, addr, ptep, _PAGE_WRITE, 0);
 }
 
 #endif
diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
index 058d6311de87..bb1bf23d6f90 100644
--- a/arch/powerpc/include/asm/hugetlb.h
+++ b/arch/powerpc/include/asm/hugetlb.h
@@ -132,11 +132,11 @@ static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 	set_pte_at(mm, addr, ptep, pte);
 }
 
-static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
+static inline pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma,
 					    unsigned long addr, pte_t *ptep)
 {
 #ifdef CONFIG_PPC64
-	return __pte(huge_pte_update(mm, addr, ptep, ~0UL, 0));
+	return __pte(huge_pte_update(vma->vm_mm, addr, ptep, ~0UL, 0));
 #else
 	return __pte(pte_update(ptep, ~0UL, 0));
 #endif
@@ -146,7 +146,7 @@ static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
 					 unsigned long addr, pte_t *ptep)
 {
 	pte_t pte;
-	pte = huge_ptep_get_and_clear(vma->vm_mm, addr, ptep);
+	pte = huge_ptep_get_and_clear(vma, addr, ptep);
 	flush_hugetlb_page(vma, addr);
 }
 
diff --git a/arch/powerpc/include/asm/nohash/32/pgtable.h b/arch/powerpc/include/asm/nohash/32/pgtable.h
index 24ee66bf7223..db83c15f1d54 100644
--- a/arch/powerpc/include/asm/nohash/32/pgtable.h
+++ b/arch/powerpc/include/asm/nohash/32/pgtable.h
@@ -260,10 +260,10 @@ static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr,
 {
 	pte_update(ptep, (_PAGE_RW | _PAGE_HWWRITE), _PAGE_RO);
 }
-static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
+static inline void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
 					   unsigned long addr, pte_t *ptep)
 {
-	ptep_set_wrprotect(mm, addr, ptep);
+	ptep_set_wrprotect(vma->vm_mm, addr, ptep);
 }
 
 
diff --git a/arch/powerpc/include/asm/nohash/64/pgtable.h b/arch/powerpc/include/asm/nohash/64/pgtable.h
index 86d49dc60ec6..16c77d923209 100644
--- a/arch/powerpc/include/asm/nohash/64/pgtable.h
+++ b/arch/powerpc/include/asm/nohash/64/pgtable.h
@@ -257,13 +257,13 @@ static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr,
 	pte_update(mm, addr, ptep, _PAGE_RW, 0, 0);
 }
 
-static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
+static inline void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
 					   unsigned long addr, pte_t *ptep)
 {
 	if ((pte_val(*ptep) & _PAGE_RW) == 0)
 		return;
 
-	pte_update(mm, addr, ptep, _PAGE_RW, 0, 1);
+	pte_update(vma->vm_mm, addr, ptep, _PAGE_RW, 0, 1);
 }
 
 /*
diff --git a/arch/s390/include/asm/hugetlb.h b/arch/s390/include/asm/hugetlb.h
index 4c7fac75090e..eb411d59ab77 100644
--- a/arch/s390/include/asm/hugetlb.h
+++ b/arch/s390/include/asm/hugetlb.h
@@ -19,7 +19,7 @@
 void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 		     pte_t *ptep, pte_t pte);
 pte_t huge_ptep_get(pte_t *ptep);
-pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
+pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma,
 			      unsigned long addr, pte_t *ptep);
 
 /*
@@ -50,7 +50,7 @@ static inline void huge_pte_clear(struct mm_struct *mm, unsigned long addr,
 static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
 					 unsigned long address, pte_t *ptep)
 {
-	huge_ptep_get_and_clear(vma->vm_mm, address, ptep);
+	huge_ptep_get_and_clear(vma, address, ptep);
 }
 
 static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
@@ -59,17 +59,17 @@ static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
 {
 	int changed = !pte_same(huge_ptep_get(ptep), pte);
 	if (changed) {
-		huge_ptep_get_and_clear(vma->vm_mm, addr, ptep);
+		huge_ptep_get_and_clear(vma, addr, ptep);
 		set_huge_pte_at(vma->vm_mm, addr, ptep, pte);
 	}
 	return changed;
 }
 
-static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
+static inline void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
 					   unsigned long addr, pte_t *ptep)
 {
-	pte_t pte = huge_ptep_get_and_clear(mm, addr, ptep);
-	set_huge_pte_at(mm, addr, ptep, pte_wrprotect(pte));
+	pte_t pte = huge_ptep_get_and_clear(vma, addr, ptep);
+	set_huge_pte_at(vma->vm_mm, addr, ptep, pte_wrprotect(pte));
 }
 
 static inline pte_t mk_huge_pte(struct page *page, pgprot_t pgprot)
diff --git a/arch/s390/mm/hugetlbpage.c b/arch/s390/mm/hugetlbpage.c
index cd404aa3931c..61146137b0d2 100644
--- a/arch/s390/mm/hugetlbpage.c
+++ b/arch/s390/mm/hugetlbpage.c
@@ -136,12 +136,13 @@ pte_t huge_ptep_get(pte_t *ptep)
 	return __rste_to_pte(pte_val(*ptep));
 }
 
-pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
+pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma,
 			      unsigned long addr, pte_t *ptep)
 {
 	pte_t pte = huge_ptep_get(ptep);
 	pmd_t *pmdp = (pmd_t *) ptep;
 	pud_t *pudp = (pud_t *) ptep;
+	struct mm_struct *mm = vma->vm_mm;
 
 	if ((pte_val(*ptep) & _REGION_ENTRY_TYPE_MASK) == _REGION_ENTRY_TYPE_R3)
 		pudp_xchg_direct(mm, addr, pudp, __pud(_REGION3_ENTRY_EMPTY));
diff --git a/arch/sh/include/asm/hugetlb.h b/arch/sh/include/asm/hugetlb.h
index ef489a56fcce..925cbc0b4da9 100644
--- a/arch/sh/include/asm/hugetlb.h
+++ b/arch/sh/include/asm/hugetlb.h
@@ -40,10 +40,10 @@ static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 	set_pte_at(mm, addr, ptep, pte);
 }
 
-static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
+static inline pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma,
 					    unsigned long addr, pte_t *ptep)
 {
-	return ptep_get_and_clear(mm, addr, ptep);
+	return ptep_get_and_clear(vma->vm_mm, addr, ptep);
 }
 
 static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
@@ -61,10 +61,10 @@ static inline pte_t huge_pte_wrprotect(pte_t pte)
 	return pte_wrprotect(pte);
 }
 
-static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
+static inline void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
 					   unsigned long addr, pte_t *ptep)
 {
-	ptep_set_wrprotect(mm, addr, ptep);
+	ptep_set_wrprotect(vma->vm_mm, addr, ptep);
 }
 
 static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
diff --git a/arch/sparc/include/asm/hugetlb.h b/arch/sparc/include/asm/hugetlb.h
index dcbf985ab243..c7c21738b46c 100644
--- a/arch/sparc/include/asm/hugetlb.h
+++ b/arch/sparc/include/asm/hugetlb.h
@@ -8,7 +8,7 @@
 void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 		     pte_t *ptep, pte_t pte);
 
-pte_t huge_ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
+pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma, unsigned long addr,
 			      pte_t *ptep);
 
 static inline int is_hugepage_only_range(struct mm_struct *mm,
@@ -46,11 +46,11 @@ static inline pte_t huge_pte_wrprotect(pte_t pte)
 	return pte_wrprotect(pte);
 }
 
-static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
+static inline void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
 					   unsigned long addr, pte_t *ptep)
 {
 	pte_t old_pte = *ptep;
-	set_huge_pte_at(mm, addr, ptep, pte_wrprotect(old_pte));
+	set_huge_pte_at(vma->vm_mm, addr, ptep, pte_wrprotect(old_pte));
 }
 
 static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
diff --git a/arch/sparc/mm/hugetlbpage.c b/arch/sparc/mm/hugetlbpage.c
index 988acc8b1b80..c5d1fb4a83a7 100644
--- a/arch/sparc/mm/hugetlbpage.c
+++ b/arch/sparc/mm/hugetlbpage.c
@@ -174,10 +174,11 @@ void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 	maybe_tlb_batch_add(mm, addr + REAL_HPAGE_SIZE, ptep, orig, 0);
 }
 
-pte_t huge_ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
+pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma, unsigned long addr,
 			      pte_t *ptep)
 {
 	pte_t entry;
+	struct mm_struct *mm = vma->vm_mm;
 
 	entry = *ptep;
 	if (pte_present(entry))
diff --git a/arch/tile/include/asm/hugetlb.h b/arch/tile/include/asm/hugetlb.h
index 2fac5be4de26..aab3ff1cdb10 100644
--- a/arch/tile/include/asm/hugetlb.h
+++ b/arch/tile/include/asm/hugetlb.h
@@ -54,10 +54,10 @@ static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 	set_pte(ptep, pte);
 }
 
-static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
+static inline pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma,
 					    unsigned long addr, pte_t *ptep)
 {
-	return ptep_get_and_clear(mm, addr, ptep);
+	return ptep_get_and_clear(vma->vm_mm, addr, ptep);
 }
 
 static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
@@ -76,10 +76,10 @@ static inline pte_t huge_pte_wrprotect(pte_t pte)
 	return pte_wrprotect(pte);
 }
 
-static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
+static inline void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
 					   unsigned long addr, pte_t *ptep)
 {
-	ptep_set_wrprotect(mm, addr, ptep);
+	ptep_set_wrprotect(vma->vm_mm, addr, ptep);
 }
 
 static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
diff --git a/arch/x86/include/asm/hugetlb.h b/arch/x86/include/asm/hugetlb.h
index 3a106165e03a..47b7a102a6a2 100644
--- a/arch/x86/include/asm/hugetlb.h
+++ b/arch/x86/include/asm/hugetlb.h
@@ -41,10 +41,10 @@ static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 	set_pte_at(mm, addr, ptep, pte);
 }
 
-static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
+static inline pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma,
 					    unsigned long addr, pte_t *ptep)
 {
-	return ptep_get_and_clear(mm, addr, ptep);
+	return ptep_get_and_clear(vma->vm_mm, addr, ptep);
 }
 
 static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
@@ -63,10 +63,10 @@ static inline pte_t huge_pte_wrprotect(pte_t pte)
 	return pte_wrprotect(pte);
 }
 
-static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
+static inline void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
 					   unsigned long addr, pte_t *ptep)
 {
-	ptep_set_wrprotect(mm, addr, ptep);
+	ptep_set_wrprotect(vma->vm_mm, addr, ptep);
 }
 
 static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ec49d9ef1eef..6b140f213e33 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3182,7 +3182,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 			set_huge_pte_at(dst, addr, dst_pte, entry);
 		} else {
 			if (cow) {
-				huge_ptep_set_wrprotect(src, addr, src_pte);
+				huge_ptep_set_wrprotect(vma, addr, src_pte);
 				mmu_notifier_invalidate_range(src, mmun_start,
 								   mmun_end);
 			}
@@ -3271,7 +3271,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			set_vma_resv_flags(vma, HPAGE_RESV_UNMAPPED);
 		}
 
-		pte = huge_ptep_get_and_clear(mm, address, ptep);
+		pte = huge_ptep_get_and_clear(vma, address, ptep);
 		tlb_remove_tlb_entry(tlb, ptep, address);
 		if (huge_pte_dirty(pte))
 			set_page_dirty(page);
@@ -4020,7 +4020,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 			continue;
 		}
 		if (!huge_pte_none(pte)) {
-			pte = huge_ptep_get_and_clear(mm, address, ptep);
+			pte = huge_ptep_get_and_clear(vma, address, ptep);
 			pte = pte_mkhuge(huge_pte_modify(pte, newprot));
 			pte = arch_make_huge_pte(pte, vma, NULL, 0);
 			set_huge_pte_at(mm, address, ptep, pte);
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
