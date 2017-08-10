Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B7CF46B0313
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 13:11:01 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j83so12755189pfe.10
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 10:11:01 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k16si4800867pli.369.2017.08.10.10.11.00
        for <linux-mm@kvack.org>;
        Thu, 10 Aug 2017 10:11:00 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v6 5/9] arm64: hugetlb: Handle swap entries in huge_pte_offset() for contiguous hugepages
Date: Thu, 10 Aug 2017 18:09:02 +0100
Message-Id: <20170810170906.30772-6-punit.agrawal@arm.com>
In-Reply-To: <20170810170906.30772-1-punit.agrawal@arm.com>
References: <20170810170906.30772-1-punit.agrawal@arm.com>
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
 arch/arm64/mm/hugetlbpage.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index d3a6713048a2..09e79785c019 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -210,6 +210,7 @@ pte_t *huge_pte_offset(struct mm_struct *mm,
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
+	pte_t *pte;
 
 	pgd = pgd_offset(mm, addr);
 	pr_debug("%s: addr:0x%lx pgd:%p\n", __func__, addr, pgd);
@@ -217,19 +218,29 @@ pte_t *huge_pte_offset(struct mm_struct *mm,
 		return NULL;
 
 	pud = pud_offset(pgd, addr);
-	if (pud_none(*pud))
+	if (pud_none(*pud) && sz != PUD_SIZE)
 		return NULL;
 	/* swap or huge page */
 	if (!pud_present(*pud) || pud_huge(*pud))
 		return (pte_t *)pud;
 	/* table; check the next level */
 
+	if (sz == CONT_PMD_SIZE)
+		addr &= CONT_PMD_MASK;
+
 	pmd = pmd_offset(pud, addr);
-	if (pmd_none(*pmd))
+	if (pmd_none(*pmd) &&
+	    !(sz == PMD_SIZE || sz == CONT_PMD_SIZE))
 		return NULL;
 	if (!pmd_present(*pmd) || pmd_huge(*pmd))
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
