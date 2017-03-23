Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 770A56B0352
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 08:58:57 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id g2so414309191pge.7
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 05:58:57 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z13si3990960pfj.93.2017.03.23.05.58.56
        for <linux-mm@kvack.org>;
        Thu, 23 Mar 2017 05:58:56 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [RFC PATCH 2/2] arm64: hugetlbpages: Correctly handle swap entries in huge_pte_offset()
Date: Thu, 23 Mar 2017 12:58:23 +0000
Message-Id: <20170323125823.429-3-punit.agrawal@arm.com>
In-Reply-To: <20170323125823.429-1-punit.agrawal@arm.com>
References: <20170323125823.429-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Punit Agrawal <punit.agrawal@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, David Woods <dwoods@mellanox.com>

huge_pte_offset() does not correctly handle poisoned or migration page
table entries. Not knowing the size of the hugepage entry being
requested only compounded the problem.

The recently added hstate parameter can be used to determine the size of
hugepage being accessed. Use the size to find the correct page table
entry to return when coming across a swap page table entry.

Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
Cc: David Woods <dwoods@mellanox.com>
---
 arch/arm64/mm/hugetlbpage.c | 31 ++++++++++++++++---------------
 1 file changed, 16 insertions(+), 15 deletions(-)

diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index 75d8cc3e138b..db108fa6e197 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -191,38 +191,39 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
 
 pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr, struct hstate *h)
 {
+	unsigned long sz = huge_page_size(h);
 	pgd_t *pgd;
 	pud_t *pud;
-	pmd_t *pmd = NULL;
-	pte_t *pte = NULL;
+	pmd_t *pmd;
+	pte_t *pte;
 
 	pgd = pgd_offset(mm, addr);
 	pr_debug("%s: addr:0x%lx pgd:%p\n", __func__, addr, pgd);
 	if (!pgd_present(*pgd))
 		return NULL;
+
 	pud = pud_offset(pgd, addr);
-	if (!pud_present(*pud))
+	if (pud_none(*pud) && sz != PUD_SIZE)
 		return NULL;
-
-	if (pud_huge(*pud))
+	else if (!pud_table(*pud))
 		return (pte_t *)pud;
+
+	if (sz == CONT_PMD_SIZE)
+		addr &= CONT_PMD_MASK;
+
 	pmd = pmd_offset(pud, addr);
-	if (!pmd_present(*pmd))
+	if (pmd_none(*pmd) &&
+	    !(sz == PMD_SIZE || sz == CONT_PMD_SIZE))
 		return NULL;
-
-	if (pte_cont(pmd_pte(*pmd))) {
-		pmd = pmd_offset(
-			pud, (addr & CONT_PMD_MASK));
-		return (pte_t *)pmd;
-	}
-	if (pmd_huge(*pmd))
+	else if (!pmd_table(*pmd))
 		return (pte_t *)pmd;
-	pte = pte_offset_kernel(pmd, addr);
-	if (pte_present(*pte) && pte_cont(*pte)) {
+
+	if (sz == CONT_PTE_SIZE) {
 		pte = pte_offset_kernel(
 			pmd, (addr & CONT_PTE_MASK));
 		return pte;
 	}
+
 	return NULL;
 }
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
