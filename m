Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id B6A0D6B025E
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 01:48:13 -0400 (EDT)
Received: by mail-pf0-f169.google.com with SMTP id n1so48868043pfn.2
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 22:48:13 -0700 (PDT)
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com. [125.16.236.6])
        by mx.google.com with ESMTPS id se2si9404755pac.54.2016.04.06.22.48.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 06 Apr 2016 22:48:12 -0700 (PDT)
Received: from localhost
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 7 Apr 2016 11:08:03 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u375cFNj13631824
	for <linux-mm@kvack.org>; Thu, 7 Apr 2016 11:08:16 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u375bq0V006292
	for <linux-mm@kvack.org>; Thu, 7 Apr 2016 11:07:57 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH 08/10] powerpc/hugetlb: Selectively enable ARCH_WANT_GENERAL_HUGETLB
Date: Thu,  7 Apr 2016 11:07:42 +0530
Message-Id: <1460007464-26726-9-git-send-email-khandual@linux.vnet.ibm.com>
In-Reply-To: <1460007464-26726-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1460007464-26726-1-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, mgorman@techsingularity.net, dave.hansen@intel.com, aneesh.kumar@linux.vnet.ibm.com, mpe@ellerman.id.au

This enables ARCH_WANT_GENERAL_HUGETLB config option only for BOOK3S
platforms with 64K page size implementation. Existing arch specific
functions for ARCH_WANT_GENERAL_HUGETLB config like 'huge_pte_alloc'
and 'huge_pte_offset' are no longer required and are removed with
this change.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 arch/powerpc/Kconfig          |  4 +++
 arch/powerpc/mm/hugetlbpage.c | 58 -------------------------------------------
 2 files changed, 4 insertions(+), 58 deletions(-)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 7cd32c0..9b3ce18 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -33,6 +33,10 @@ config HAVE_SETUP_PER_CPU_AREA
 config NEED_PER_CPU_EMBED_FIRST_CHUNK
 	def_bool PPC64
 
+config ARCH_WANT_GENERAL_HUGETLB
+	depends on HUGETLB_PAGE && PPC_64K_PAGES && PPC_BOOK3S_64
+	def_bool y
+
 config NR_IRQS
 	int "Number of virtual interrupt numbers"
 	range 32 32768
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 4f44c62..bd0e584 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -59,39 +59,6 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
 	/* Only called for hugetlbfs pages, hence can ignore THP */
 	return __find_linux_pte_or_hugepte(mm->pgd, addr, NULL, NULL);
 }
-#else /* CONFIG_ARCH_WANT_GENERAL_HUGETLB */
-pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
-{
-	pgd_t pgd, *pgdp;
-	pud_t pud, *pudp;
-	pmd_t pmd, *pmdp;
-
-	pgdp = mm->pgd + pgd_index(addr);
-	pgd  = READ_ONCE(*pgdp);
-
-	if (pgd_none(pgd))
-		return NULL;
-
-	if (pgd_huge(pgd))
-		return (pte_t *)pgdp;
-
-	pudp = pud_offset(&pgd, addr);
-	pud  = READ_ONCE(*pudp);
-	if (pud_none(pud))
-		return NULL;
-
-	if (pud_huge(pud))
-		return (pte_t *)pudp;
-
-	pmdp = pmd_offset(&pud, addr);
-	pmd  = READ_ONCE(*pmdp);
-	if (pmd_none(pmd))
-		return NULL;
-
-	if (pmd_huge(pmd))
-		return (pte_t *)pmdp;
-	return NULL;
-}
 #endif /* !CONFIG_ARCH_WANT_GENERAL_HUGETLB */
 
 #ifndef CONFIG_ARCH_WANT_GENERAL_HUGETLB
@@ -210,31 +177,6 @@ hugepd_search:
 
 	return hugepte_offset(*hpdp, addr, pdshift);
 }
-
-#else /* CONFIG_ARCH_WANT_GENERAL_HUGETLB */
-pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz)
-{
-	pgd_t *pg;
-	pud_t *pu;
-	pmd_t *pm;
-	unsigned pshift = __ffs(sz);
-
-	addr &= ~(sz-1);
-	pg = pgd_offset(mm, addr);
-
-	if (pshift == PGDIR_SHIFT)	/* 16GB Huge Page */
-		return (pte_t *)pg;
-
-	pu = pud_alloc(mm, pg, addr);	/* NA, skipped */
-	if (pshift == PUD_SHIFT)
-		return (pte_t *)pu;
-
-	pm = pmd_alloc(mm, pu, addr);	/* 16MB Huge Page */
-	if (pshift == PMD_SHIFT)
-		return (pte_t *)pm;
-
-	return NULL;
-}
 #endif /* !CONFIG_ARCH_WANT_GENERAL_HUGETLB */
 #else
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
