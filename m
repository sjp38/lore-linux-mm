Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E88406B02B4
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:55:02 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y65so193353179pff.13
        for <linux-mm@kvack.org>; Wed, 24 May 2017 04:55:02 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c89si24163831pfk.21.2017.05.24.04.55.01
        for <linux-mm@kvack.org>;
        Wed, 24 May 2017 04:55:02 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v4 1/8] arm64: hugetlb: Refactor find_num_contig
Date: Wed, 24 May 2017 12:54:02 +0100
Message-Id: <20170524115409.31309-2-punit.agrawal@arm.com>
In-Reply-To: <20170524115409.31309-1-punit.agrawal@arm.com>
References: <20170524115409.31309-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Steve Capper <steve.capper@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com, linux-arch@vger.kernel.org, David Woods <dwoods@mellanox.com>, Punit Agrawal <punit.agrawal@arm.com>

From: Steve Capper <steve.capper@arm.com>

As we regularly check for contiguous pte's in the huge accessors, remove
this extra check from find_num_contig.

Cc: David Woods <dwoods@mellanox.com>
Signed-off-by: Steve Capper <steve.capper@arm.com>
[ Resolved rebase conflicts due to patch re-ordering ]
Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
---
 arch/arm64/mm/hugetlbpage.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index 69b8200b1cfd..710bf935a473 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -42,15 +42,13 @@ int pud_huge(pud_t pud)
 }
 
 static int find_num_contig(struct mm_struct *mm, unsigned long addr,
-			   pte_t *ptep, pte_t pte, size_t *pgsize)
+			   pte_t *ptep, size_t *pgsize)
 {
 	pgd_t *pgd = pgd_offset(mm, addr);
 	pud_t *pud;
 	pmd_t *pmd;
 
 	*pgsize = PAGE_SIZE;
-	if (!pte_cont(pte))
-		return 1;
 	pud = pud_offset(pgd, addr);
 	pmd = pmd_offset(pud, addr);
 	if ((pte_t *)pmd == ptep) {
@@ -65,15 +63,16 @@ void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 {
 	size_t pgsize;
 	int i;
-	int ncontig = find_num_contig(mm, addr, ptep, pte, &pgsize);
+	int ncontig;
 	unsigned long pfn;
 	pgprot_t hugeprot;
 
-	if (ncontig == 1) {
+	if (!pte_cont(pte)) {
 		set_pte_at(mm, addr, ptep, pte);
 		return;
 	}
 
+	ncontig = find_num_contig(mm, addr, ptep, &pgsize);
 	pfn = pte_pfn(pte);
 	hugeprot = __pgprot(pte_val(pfn_pte(pfn, __pgprot(0))) ^ pte_val(pte));
 	for (i = 0; i < ncontig; i++) {
@@ -188,7 +187,7 @@ pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
 		bool is_dirty = false;
 
 		cpte = huge_pte_offset(mm, addr);
-		ncontig = find_num_contig(mm, addr, cpte, *cpte, &pgsize);
+		ncontig = find_num_contig(mm, addr, cpte, &pgsize);
 		/* save the 1st pte to return */
 		pte = ptep_get_and_clear(mm, addr, cpte);
 		for (i = 1, addr += pgsize; i < ncontig; ++i, addr += pgsize) {
@@ -228,7 +227,7 @@ int huge_ptep_set_access_flags(struct vm_area_struct *vma,
 		cpte = huge_pte_offset(vma->vm_mm, addr);
 		pfn = pte_pfn(*cpte);
 		ncontig = find_num_contig(vma->vm_mm, addr, cpte,
-					  *cpte, &pgsize);
+					  &pgsize);
 		for (i = 0; i < ncontig; ++i, ++cpte, addr += pgsize) {
 			changed |= ptep_set_access_flags(vma, addr, cpte,
 							pfn_pte(pfn,
@@ -251,7 +250,7 @@ void huge_ptep_set_wrprotect(struct mm_struct *mm,
 		size_t pgsize = 0;
 
 		cpte = huge_pte_offset(mm, addr);
-		ncontig = find_num_contig(mm, addr, cpte, *cpte, &pgsize);
+		ncontig = find_num_contig(mm, addr, cpte, &pgsize);
 		for (i = 0; i < ncontig; ++i, ++cpte, addr += pgsize)
 			ptep_set_wrprotect(mm, addr, cpte);
 	} else {
@@ -269,7 +268,7 @@ void huge_ptep_clear_flush(struct vm_area_struct *vma,
 
 		cpte = huge_pte_offset(vma->vm_mm, addr);
 		ncontig = find_num_contig(vma->vm_mm, addr, cpte,
-					  *cpte, &pgsize);
+					  &pgsize);
 		for (i = 0; i < ncontig; ++i, ++cpte, addr += pgsize)
 			ptep_clear_flush(vma, addr, cpte);
 	} else {
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
