Message-Id: <200509032256.j83Mud0B023224@shell0.pdx.osdl.net>
Subject: [patch 040/220] hugetlb: check p?d_present in huge_pte_offset()
From: akpm@osdl.org
Date: Sat, 03 Sep 2005 15:55:01 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: akpm@osdl.org, agl@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

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
--- devel/arch/i386/mm/hugetlbpage.c~hugetlb-check-pd_present-in-huge_pte_offset	2005-09-03 15:46:14.000000000 -0700
+++ devel-akpm/arch/i386/mm/hugetlbpage.c	2005-09-03 15:52:25.000000000 -0700
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
