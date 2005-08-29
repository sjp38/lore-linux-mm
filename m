Message-Id: <200508292245.j7TMjfZc029237@shell0.pdx.osdl.net>
Subject: hugetlb-check-pd_present-in-huge_pte_offset.patch added to -mm tree
From: akpm@osdl.org
Date: Mon, 29 Aug 2005 15:48:08 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: agl@us.ibm.com, linux-mm@kvack.org, mm-commits@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The patch titled

     hugetlb: check p?d_present in huge_pte_offset()

has been added to the -mm tree.  Its filename is

     hugetlb-check-pd_present-in-huge_pte_offset.patch

Patches currently in -mm which might be from agl@us.ibm.com are

hugetlb-add-pte_huge-macro.patch
hugetlb-move-stale-pte-check-into-huge_pte_alloc.patch
hugetlb-check-pd_present-in-huge_pte_offset.patch



From: Adam Litke <agl@us.ibm.com>

For demand faulting, we cannot assume that the page tables will be
populated.  Do what the rest of the architectures do and test p?d_present()
while walking down the page table.

Signed-off-by: Adam Litke <agl@us.ibm.com>
Cc: <linux-mm@kvack.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 arch/i386/mm/hugetlbpage.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff -puN arch/i386/mm/hugetlbpage.c~hugetlb-check-pd_present-in-huge_pte_offset arch/i386/mm/hugetlbpage.c
--- 25/arch/i386/mm/hugetlbpage.c~hugetlb-check-pd_present-in-huge_pte_offset	Mon Aug 29 15:48:06 2005
+++ 25-akpm/arch/i386/mm/hugetlbpage.c	Mon Aug 29 15:48:06 2005
@@ -46,8 +46,11 @@ pte_t *huge_pte_offset(struct mm_struct 
 	pmd_t *pmd = NULL;
 
 	pgd = pgd_offset(mm, addr);
-	pud = pud_offset(pgd, addr);
-	pmd = pmd_offset(pud, addr);
+	if (pgd_present(*pgd)) {
+		pud = pud_offset(pgd, addr);
+		if (pud_present(*pud))
+			pmd = pmd_offset(pud, addr);
+	}
 	return (pte_t *) pmd;
 }
 
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
