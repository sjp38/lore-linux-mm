Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1B8246B039F
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 09:38:05 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y62so6653372pfd.17
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 06:38:05 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z63si20673293pfz.321.2017.04.05.06.38.03
        for <linux-mm@kvack.org>;
        Wed, 05 Apr 2017 06:38:04 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v2 2/9] arm64: hugetlbpages: Support handling swap entries in huge_pte_offset()
Date: Wed,  5 Apr 2017 14:37:15 +0100
Message-Id: <20170405133722.6406-3-punit.agrawal@arm.com>
In-Reply-To: <20170405133722.6406-1-punit.agrawal@arm.com>
References: <20170405133722.6406-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, will.deacon@arm.com, akpm@linux-foundation.org, mark.rutland@arm.com
Cc: Punit Agrawal <punit.agrawal@arm.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, tbaicar@codeaurora.org, kirill.shutemov@linux.intel.com, mike.kravetz@oracle.com, hillf.zj@alibaba-inc.com, steve.capper@arm.com, David Woods <dwoods@mellanox.com>

huge_pte_offset() does not correctly handle poisoned or migration page
table entries. It returns NULL instead of the offset when it encounters
a swap entry. This leads to errors such as

[  344.165544] mm/pgtable-generic.c:33: bad pmd 000000083af00074.

in the kernel log when unmapping memory on process exit.

huge_pte_offset() is now provided with the size of the hugepage being
accessed. Use the size to find the correct page table entry to return.

Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
Cc: David Woods <dwoods@mellanox.com>
---
 arch/arm64/mm/hugetlbpage.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index 1bc08ae49e6a..009648c4500f 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -194,36 +194,36 @@ pte_t *huge_pte_offset(struct mm_struct *mm,
 {
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
