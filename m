Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 68E776B02F3
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:55:18 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y65so193356553pff.13
        for <linux-mm@kvack.org>; Wed, 24 May 2017 04:55:18 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v12si24027967pfj.72.2017.05.24.04.55.17
        for <linux-mm@kvack.org>;
        Wed, 24 May 2017 04:55:17 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v4 2/8] arm64: hugetlb: Remove spurious calls to huge_ptep_offset
Date: Wed, 24 May 2017 12:54:03 +0100
Message-Id: <20170524115409.31309-3-punit.agrawal@arm.com>
In-Reply-To: <20170524115409.31309-1-punit.agrawal@arm.com>
References: <20170524115409.31309-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Steve Capper <steve.capper@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com, linux-arch@vger.kernel.org, David Woods <dwoods@mellanox.com>, Punit Agrawal <punit.agrawal@arm.com>

From: Steve Capper <steve.capper@arm.com>

We don't need to call huge_ptep_offset as our accessors are already
supplied with the pte_t *. This patch removes those spurious calls.

Cc: David Woods <dwoods@mellanox.com>
Signed-off-by: Steve Capper <steve.capper@arm.com>
[ Resolved rebase conflicts due to patch re-ordering ]
Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
---
 arch/arm64/mm/hugetlbpage.c | 37 ++++++++++++++-----------------------
 1 file changed, 14 insertions(+), 23 deletions(-)

diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index 710bf935a473..f89aa8fa5855 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -183,21 +183,19 @@ pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
 	if (pte_cont(*ptep)) {
 		int ncontig, i;
 		size_t pgsize;
-		pte_t *cpte;
 		bool is_dirty = false;
 
-		cpte = huge_pte_offset(mm, addr);
-		ncontig = find_num_contig(mm, addr, cpte, &pgsize);
+		ncontig = find_num_contig(mm, addr, ptep, &pgsize);
 		/* save the 1st pte to return */
-		pte = ptep_get_and_clear(mm, addr, cpte);
+		pte = ptep_get_and_clear(mm, addr, ptep);
 		for (i = 1, addr += pgsize; i < ncontig; ++i, addr += pgsize) {
 			/*
 			 * If HW_AFDBM is enabled, then the HW could
 			 * turn on the dirty bit for any of the page
 			 * in the set, so check them all.
 			 */
-			++cpte;
-			if (pte_dirty(ptep_get_and_clear(mm, addr, cpte)))
+			++ptep;
+			if (pte_dirty(ptep_get_and_clear(mm, addr, ptep)))
 				is_dirty = true;
 		}
 		if (is_dirty)
@@ -213,8 +211,6 @@ int huge_ptep_set_access_flags(struct vm_area_struct *vma,
 			       unsigned long addr, pte_t *ptep,
 			       pte_t pte, int dirty)
 {
-	pte_t *cpte;
-
 	if (pte_cont(pte)) {
 		int ncontig, i, changed = 0;
 		size_t pgsize = 0;
@@ -224,12 +220,11 @@ int huge_ptep_set_access_flags(struct vm_area_struct *vma,
 			__pgprot(pte_val(pfn_pte(pfn, __pgprot(0))) ^
 				 pte_val(pte));
 
-		cpte = huge_pte_offset(vma->vm_mm, addr);
-		pfn = pte_pfn(*cpte);
-		ncontig = find_num_contig(vma->vm_mm, addr, cpte,
+		pfn = pte_pfn(pte);
+		ncontig = find_num_contig(vma->vm_mm, addr, ptep,
 					  &pgsize);
-		for (i = 0; i < ncontig; ++i, ++cpte, addr += pgsize) {
-			changed |= ptep_set_access_flags(vma, addr, cpte,
+		for (i = 0; i < ncontig; ++i, ++ptep, addr += pgsize) {
+			changed |= ptep_set_access_flags(vma, addr, ptep,
 							pfn_pte(pfn,
 								hugeprot),
 							dirty);
@@ -246,13 +241,11 @@ void huge_ptep_set_wrprotect(struct mm_struct *mm,
 {
 	if (pte_cont(*ptep)) {
 		int ncontig, i;
-		pte_t *cpte;
 		size_t pgsize = 0;
 
-		cpte = huge_pte_offset(mm, addr);
-		ncontig = find_num_contig(mm, addr, cpte, &pgsize);
-		for (i = 0; i < ncontig; ++i, ++cpte, addr += pgsize)
-			ptep_set_wrprotect(mm, addr, cpte);
+		ncontig = find_num_contig(mm, addr, ptep, &pgsize);
+		for (i = 0; i < ncontig; ++i, ++ptep, addr += pgsize)
+			ptep_set_wrprotect(mm, addr, ptep);
 	} else {
 		ptep_set_wrprotect(mm, addr, ptep);
 	}
@@ -263,14 +256,12 @@ void huge_ptep_clear_flush(struct vm_area_struct *vma,
 {
 	if (pte_cont(*ptep)) {
 		int ncontig, i;
-		pte_t *cpte;
 		size_t pgsize = 0;
 
-		cpte = huge_pte_offset(vma->vm_mm, addr);
-		ncontig = find_num_contig(vma->vm_mm, addr, cpte,
+		ncontig = find_num_contig(vma->vm_mm, addr, ptep,
 					  &pgsize);
-		for (i = 0; i < ncontig; ++i, ++cpte, addr += pgsize)
-			ptep_clear_flush(vma, addr, cpte);
+		for (i = 0; i < ncontig; ++i, ++ptep, addr += pgsize)
+			ptep_clear_flush(vma, addr, ptep);
 	} else {
 		ptep_clear_flush(vma, addr, ptep);
 	}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
