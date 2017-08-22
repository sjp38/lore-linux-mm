Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 959982803D0
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 06:44:25 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id w127so9199376pfd.5
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 03:44:25 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d4si9823440plj.559.2017.08.22.03.44.24
        for <linux-mm@kvack.org>;
        Tue, 22 Aug 2017 03:44:24 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v7 5/9] arm64: hugetlb: Handle swap entries in huge_pte_offset() for contiguous hugepages
Date: Tue, 22 Aug 2017 11:42:45 +0100
Message-Id: <20170822104249.2189-6-punit.agrawal@arm.com>
In-Reply-To: <20170822104249.2189-1-punit.agrawal@arm.com>
References: <20170822104249.2189-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: will.deacon@arm.com, catalin.marinas@arm.com
Cc: Punit Agrawal <punit.agrawal@arm.com>, linux-mm@kvack.org, steve.capper@arm.com, linux-arm-kernel@lists.infradead.org, mark.rutland@arm.com, David Woods <dwoods@mellanox.com>

huge_pte_offset() was updated to correctly handle swap entries for
hugepages. With the addition of the size parameter, it is now possible
to disambiguate whether the request is for a regular hugepage or a
contiguous hugepage.

Fix huge_pte_offset() for contiguous hugepages by using the size to find
the correct page table entry.

Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
Cc: David Woods <dwoods@mellanox.com>
---
 arch/arm64/mm/hugetlbpage.c | 21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index 594232598cac..b95e24dc3477 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -214,6 +214,7 @@ pte_t *huge_pte_offset(struct mm_struct *mm,
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
+	pte_t *pte;
 
 	pgd = pgd_offset(mm, addr);
 	pr_debug("%s: addr:0x%lx pgd:%p\n", __func__, addr, pgd);
@@ -221,19 +222,29 @@ pte_t *huge_pte_offset(struct mm_struct *mm,
 		return NULL;
 
 	pud = pud_offset(pgd, addr);
-	if (pud_none(*pud))
+	if (sz != PUD_SIZE && pud_none(*pud))
 		return NULL;
-	/* swap or huge page */
-	if (!pud_present(*pud) || pud_huge(*pud))
+	/* hugepage or swap? */
+	if (pud_huge(*pud) || !pud_present(*pud))
 		return (pte_t *)pud;
 	/* table; check the next level */
 
+	if (sz == CONT_PMD_SIZE)
+		addr &= CONT_PMD_MASK;
+
 	pmd = pmd_offset(pud, addr);
-	if (pmd_none(*pmd))
+	if (!(sz == PMD_SIZE || sz == CONT_PMD_SIZE) &&
+	    pmd_none(*pmd))
 		return NULL;
-	if (!pmd_present(*pmd) || pmd_huge(*pmd))
+	if (pmd_huge(*pmd) || !pmd_present(*pmd))
 		return (pte_t *)pmd;
 
+	if (sz == CONT_PTE_SIZE) {
+		pte = pte_offset_kernel(
+			pmd, (addr & CONT_PTE_MASK));
+		return pte;
+	}
+
 	return NULL;
 }
 
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
