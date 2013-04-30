Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id B61AE6B010E
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 12:31:11 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id l18so675074wgh.24
        for <linux-mm@kvack.org>; Tue, 30 Apr 2013 09:31:10 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [RFC PATCH 4/9] x86: mm: Remove general hugetlb code from x86.
Date: Tue, 30 Apr 2013 17:30:43 +0100
Message-Id: <1367339448-21727-5-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1367339448-21727-1-git-send-email-steve.capper@linaro.org>
References: <1367339448-21727-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Cc: Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steve Capper <steve.capper@linaro.org>

huge_pte_alloc, huge_pte_offset and follow_huge_p[mu]d have
already been copied over to mm.

This patch removes the x86 copies of these functions and activates
the general ones by enabling:
CONFIG_ARCH_WANT_GENERAL_HUGETLB

Signed-off-by: Steve Capper <steve.capper@linaro.org>
---
 arch/x86/Kconfig          |  3 +++
 arch/x86/mm/hugetlbpage.c | 67 -----------------------------------------------
 2 files changed, 3 insertions(+), 67 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 60e3c402..db1ff87 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -215,6 +215,9 @@ config ARCH_SUSPEND_POSSIBLE
 config ARCH_WANT_HUGE_PMD_SHARE
 	def_bool y
 
+config ARCH_WANT_GENERAL_HUGETLB
+	def_bool y
+
 config ZONE_DMA32
 	bool
 	default X86_64
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 7e522a3..7e73e8c 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -16,49 +16,6 @@
 #include <asm/tlbflush.h>
 #include <asm/pgalloc.h>
 
-pte_t *huge_pte_alloc(struct mm_struct *mm,
-			unsigned long addr, unsigned long sz)
-{
-	pgd_t *pgd;
-	pud_t *pud;
-	pte_t *pte = NULL;
-
-	pgd = pgd_offset(mm, addr);
-	pud = pud_alloc(mm, pgd, addr);
-	if (pud) {
-		if (sz == PUD_SIZE) {
-			pte = (pte_t *)pud;
-		} else {
-			BUG_ON(sz != PMD_SIZE);
-			if (pud_none(*pud))
-				pte = huge_pmd_share(mm, addr, pud);
-			else
-				pte = (pte_t *)pmd_alloc(mm, pud, addr);
-		}
-	}
-	BUG_ON(pte && !pte_none(*pte) && !pte_huge(*pte));
-
-	return pte;
-}
-
-pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
-{
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd = NULL;
-
-	pgd = pgd_offset(mm, addr);
-	if (pgd_present(*pgd)) {
-		pud = pud_offset(pgd, addr);
-		if (pud_present(*pud)) {
-			if (pud_large(*pud))
-				return (pte_t *)pud;
-			pmd = pmd_offset(pud, addr);
-		}
-	}
-	return (pte_t *) pmd;
-}
-
 #if 0	/* This is just for testing */
 struct page *
 follow_huge_addr(struct mm_struct *mm, unsigned long address, int write)
@@ -120,30 +77,6 @@ int pud_huge(pud_t pud)
 	return !!(pud_val(pud) & _PAGE_PSE);
 }
 
-struct page *
-follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-		pmd_t *pmd, int write)
-{
-	struct page *page;
-
-	page = pte_page(*(pte_t *)pmd);
-	if (page)
-		page += ((address & ~PMD_MASK) >> PAGE_SHIFT);
-	return page;
-}
-
-struct page *
-follow_huge_pud(struct mm_struct *mm, unsigned long address,
-		pud_t *pud, int write)
-{
-	struct page *page;
-
-	page = pte_page(*(pte_t *)pud);
-	if (page)
-		page += ((address & ~PUD_MASK) >> PAGE_SHIFT);
-	return page;
-}
-
 #endif
 
 /* x86_64 also uses this file */
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
