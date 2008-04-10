Message-Id: <20080410171101.936927000@nick.local0.net>
References: <20080410170232.015351000@nick.local0.net>
Date: Fri, 11 Apr 2008 03:02:47 +1000
From: npiggin@suse.de
Subject: [patch 15/17] x86: support GB hugepages on 64-bit
Content-Disposition: inline; filename=x86-support-GB-hugetlb-pages.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.orgakpm@linux-foundation.org
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pj@sgi.com, andi@firstfloor.org, kniht@linux.vnet.ibm.comlinux-kernel@vger.kernel.orglinux-mm@kvack.orgpj@sgi.comandi@firstfloor.orgkniht@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

---
 arch/x86/mm/hugetlbpage.c |   18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

Index: linux-2.6/arch/x86/mm/hugetlbpage.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/hugetlbpage.c
+++ linux-2.6/arch/x86/mm/hugetlbpage.c
@@ -133,9 +133,14 @@ pte_t *huge_pte_alloc(struct mm_struct *
 	pgd = pgd_offset(mm, addr);
 	pud = pud_alloc(mm, pgd, addr);
 	if (pud) {
-		if (pud_none(*pud))
-			huge_pmd_share(mm, addr, pud);
-		pte = (pte_t *) pmd_alloc(mm, pud, addr);
+		if (sz == PUD_SIZE) {
+			pte = (pte_t *)pud;
+		} else {
+			BUG_ON(sz != PMD_SIZE);
+			if (pud_none(*pud))
+				huge_pmd_share(mm, addr, pud);
+			pte = (pte_t *) pmd_alloc(mm, pud, addr);
+		}
 	}
 	BUG_ON(pte && !pte_none(*pte) && !pte_huge(*pte));
 
@@ -151,8 +156,11 @@ pte_t *huge_pte_offset(struct mm_struct 
 	pgd = pgd_offset(mm, addr);
 	if (pgd_present(*pgd)) {
 		pud = pud_offset(pgd, addr);
-		if (pud_present(*pud))
+		if (pud_present(*pud)) {
+			if (pud_large(*pud))
+				return (pte_t *)pud;
 			pmd = pmd_offset(pud, addr);
+		}
 	}
 	return (pte_t *) pmd;
 }
@@ -215,7 +223,7 @@ int pmd_huge(pmd_t pmd)
 
 int pud_huge(pud_t pud)
 {
-	return 0;
+	return !!(pud_val(pud) & _PAGE_PSE);
 }
 
 struct page *

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
