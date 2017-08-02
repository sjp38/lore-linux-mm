Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id CF2D96B05BB
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 05:50:20 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v77so44502497pgb.15
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 02:50:20 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r59si14337949plb.145.2017.08.02.02.50.19
        for <linux-mm@kvack.org>;
        Wed, 02 Aug 2017 02:50:19 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v5 3/9] arm64: hugetlb: Spring clean huge pte accessors
Date: Wed,  2 Aug 2017 10:48:58 +0100
Message-Id: <20170802094904.27749-4-punit.agrawal@arm.com>
In-Reply-To: <20170802094904.27749-1-punit.agrawal@arm.com>
References: <20170802094904.27749-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: will.deacon@arm.com, catalin.marinas@arm.com
Cc: Steve Capper <steve.capper@arm.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, mark.rutland@arm.com, David Woods <dwoods@mellanox.com>, Punit Agrawal <punit.agrawal@arm.com>

From: Steve Capper <steve.capper@arm.com>

This patch aims to re-structure the huge pte accessors without affecting
their functionality. Control flow is changed to reduce indentation and
expanded use is made of post for loop variable modification.

It is then much easier to add break-before-make semantics in a subsequent
patch.

Cc: David Woods <dwoods@mellanox.com>
Signed-off-by: Steve Capper <steve.capper@arm.com>
Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
Reviewed-by: Mark Rutland <mark.rutland@arm.com>
---
 arch/arm64/mm/hugetlbpage.c | 119 ++++++++++++++++++++------------------------
 1 file changed, 54 insertions(+), 65 deletions(-)

diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index cb84ca33bc6b..08deed7c71f0 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -74,7 +74,7 @@ void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 	size_t pgsize;
 	int i;
 	int ncontig;
-	unsigned long pfn;
+	unsigned long pfn, dpfn;
 	pgprot_t hugeprot;
 
 	/*
@@ -90,14 +90,13 @@ void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 
 	ncontig = find_num_contig(mm, addr, ptep, &pgsize);
 	pfn = pte_pfn(pte);
+	dpfn = pgsize >> PAGE_SHIFT;
 	hugeprot = pte_pgprot(pte);
-	for (i = 0; i < ncontig; i++) {
+
+	for (i = 0; i < ncontig; i++, ptep++, addr += pgsize, pfn += dpfn) {
 		pr_debug("%s: set pte %p to 0x%llx\n", __func__, ptep,
 			 pte_val(pfn_pte(pfn, hugeprot)));
 		set_pte_at(mm, addr, ptep, pfn_pte(pfn, hugeprot));
-		ptep++;
-		pfn += pgsize >> PAGE_SHIFT;
-		addr += pgsize;
 	}
 }
 
@@ -195,91 +194,81 @@ pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
 pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
 			      unsigned long addr, pte_t *ptep)
 {
-	pte_t pte;
-
-	if (pte_cont(*ptep)) {
-		int ncontig, i;
-		size_t pgsize;
-		bool is_dirty = false;
-
-		ncontig = find_num_contig(mm, addr, ptep, &pgsize);
-		/* save the 1st pte to return */
-		pte = ptep_get_and_clear(mm, addr, ptep);
-		for (i = 1, addr += pgsize; i < ncontig; ++i, addr += pgsize) {
-			/*
-			 * If HW_AFDBM is enabled, then the HW could
-			 * turn on the dirty bit for any of the page
-			 * in the set, so check them all.
-			 */
-			++ptep;
-			if (pte_dirty(ptep_get_and_clear(mm, addr, ptep)))
-				is_dirty = true;
-		}
-		if (is_dirty)
-			return pte_mkdirty(pte);
-		else
-			return pte;
-	} else {
+	int ncontig, i;
+	size_t pgsize;
+	pte_t orig_pte = huge_ptep_get(ptep);
+
+	if (!pte_cont(orig_pte))
 		return ptep_get_and_clear(mm, addr, ptep);
+
+	ncontig = find_num_contig(mm, addr, ptep, &pgsize);
+	for (i = 0; i < ncontig; i++, addr += pgsize, ptep++) {
+		/*
+		 * If HW_AFDBM is enabled, then the HW could
+		 * turn on the dirty bit for any of the page
+		 * in the set, so check them all.
+		 */
+		if (pte_dirty(ptep_get_and_clear(mm, addr, ptep)))
+			orig_pte = pte_mkdirty(orig_pte);
 	}
+
+	return orig_pte;
 }
 
 int huge_ptep_set_access_flags(struct vm_area_struct *vma,
 			       unsigned long addr, pte_t *ptep,
 			       pte_t pte, int dirty)
 {
-	if (pte_cont(pte)) {
-		int ncontig, i, changed = 0;
-		size_t pgsize = 0;
-		unsigned long pfn = pte_pfn(pte);
-		/* Select all bits except the pfn */
-		pgprot_t hugeprot = pte_pgprot(pte);
-
-		pfn = pte_pfn(pte);
-		ncontig = find_num_contig(vma->vm_mm, addr, ptep,
-					  &pgsize);
-		for (i = 0; i < ncontig; ++i, ++ptep, addr += pgsize) {
-			changed |= ptep_set_access_flags(vma, addr, ptep,
-							pfn_pte(pfn,
-								hugeprot),
-							dirty);
-			pfn += pgsize >> PAGE_SHIFT;
-		}
-		return changed;
-	} else {
+	int ncontig, i, changed = 0;
+	size_t pgsize = 0;
+	unsigned long pfn = pte_pfn(pte), dpfn;
+	pgprot_t hugeprot;
+
+	if (!pte_cont(pte))
 		return ptep_set_access_flags(vma, addr, ptep, pte, dirty);
+
+	ncontig = find_num_contig(vma->vm_mm, addr, ptep, &pgsize);
+	dpfn = pgsize >> PAGE_SHIFT;
+	hugeprot = pte_pgprot(pte);
+
+	for (i = 0; i < ncontig; i++, ptep++, addr += pgsize, pfn += dpfn) {
+		changed |= ptep_set_access_flags(vma, addr, ptep,
+				pfn_pte(pfn, hugeprot), dirty);
 	}
+
+	return changed;
 }
 
 void huge_ptep_set_wrprotect(struct mm_struct *mm,
 			     unsigned long addr, pte_t *ptep)
 {
-	if (pte_cont(*ptep)) {
-		int ncontig, i;
-		size_t pgsize = 0;
+	int ncontig, i;
+	size_t pgsize;
 
-		ncontig = find_num_contig(mm, addr, ptep, &pgsize);
-		for (i = 0; i < ncontig; ++i, ++ptep, addr += pgsize)
-			ptep_set_wrprotect(mm, addr, ptep);
-	} else {
+	if (!pte_cont(*ptep)) {
 		ptep_set_wrprotect(mm, addr, ptep);
+		return;
 	}
+
+	ncontig = find_num_contig(mm, addr, ptep, &pgsize);
+	for (i = 0; i < ncontig; i++, ptep++, addr += pgsize)
+		ptep_set_wrprotect(mm, addr, ptep);
 }
 
 void huge_ptep_clear_flush(struct vm_area_struct *vma,
 			   unsigned long addr, pte_t *ptep)
 {
-	if (pte_cont(*ptep)) {
-		int ncontig, i;
-		size_t pgsize = 0;
-
-		ncontig = find_num_contig(vma->vm_mm, addr, ptep,
-					  &pgsize);
-		for (i = 0; i < ncontig; ++i, ++ptep, addr += pgsize)
-			ptep_clear_flush(vma, addr, ptep);
-	} else {
+	int ncontig, i;
+	size_t pgsize;
+
+	if (!pte_cont(*ptep)) {
 		ptep_clear_flush(vma, addr, ptep);
+		return;
 	}
+
+	ncontig = find_num_contig(vma->vm_mm, addr, ptep, &pgsize);
+	for (i = 0; i < ncontig; i++, ptep++, addr += pgsize)
+		ptep_clear_flush(vma, addr, ptep);
 }
 
 static __init int setup_hugepagesz(char *opt)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
