Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3D9766B0258
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 07:12:07 -0500 (EST)
Received: by mail-ig0-f182.google.com with SMTP id vf5so9676045igb.0
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 04:12:07 -0800 (PST)
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com. [202.81.31.142])
        by mx.google.com with ESMTPS id c19si10361179igr.27.2016.03.09.04.12.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 09 Mar 2016 04:12:02 -0800 (PST)
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 9 Mar 2016 22:11:58 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 682342BB0057
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 23:11:56 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u29CBm1662128168
	for <linux-mm@kvack.org>; Wed, 9 Mar 2016 23:11:56 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u29CBMID021763
	for <linux-mm@kvack.org>; Wed, 9 Mar 2016 23:11:23 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC 6/9] powerpc/hugetlb: Enable ARCH_WANT_GENERAL_HUGETLB for BOOK3S 64K
Date: Wed,  9 Mar 2016 17:40:47 +0530
Message-Id: <1457525450-4262-6-git-send-email-khandual@linux.vnet.ibm.com>
In-Reply-To: <1457525450-4262-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1457525450-4262-1-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aneesh.kumar@linux.vnet.ibm.com, mpe@ellerman.id.au

This enables ARCH_WANT_GENERAL_HUGETLB for BOOK3S 64K in Kconfig.
It also implements a new function 'pte_huge' which is required by
function 'huge_pte_alloc' from generic VM. Existing BOOK3S 64K
specific functions 'huge_pte_alloc' and 'huge_pte_offset' (which
are no longer required) are removed with this change.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 arch/powerpc/Kconfig                          |  4 ++
 arch/powerpc/include/asm/book3s/64/hash-64k.h |  8 ++++
 arch/powerpc/mm/hugetlbpage.c                 | 60 ---------------------------
 3 files changed, 12 insertions(+), 60 deletions(-)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 9faa18c..c6920bb 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -33,6 +33,10 @@ config HAVE_SETUP_PER_CPU_AREA
 config NEED_PER_CPU_EMBED_FIRST_CHUNK
 	def_bool PPC64
 
+config ARCH_WANT_GENERAL_HUGETLB
+	depends on PPC_64K_PAGES && PPC_BOOK3S_64
+	def_bool y
+
 config NR_IRQS
 	int "Number of virtual interrupt numbers"
 	range 32 32768
diff --git a/arch/powerpc/include/asm/book3s/64/hash-64k.h b/arch/powerpc/include/asm/book3s/64/hash-64k.h
index 849bbec..5e9b9b9 100644
--- a/arch/powerpc/include/asm/book3s/64/hash-64k.h
+++ b/arch/powerpc/include/asm/book3s/64/hash-64k.h
@@ -143,6 +143,14 @@ extern bool __rpte_sub_valid(real_pte_t rpte, unsigned long index);
  * Defined in such a way that we can optimize away code block at build time
  * if CONFIG_HUGETLB_PAGE=n.
  */
+static inline int pte_huge(pte_t pte)
+{
+	/*
+	 * leaf pte for huge page
+	 */
+	return !!(pte_val(pte) & _PAGE_PTE);
+}
+
 static inline int pmd_huge(pmd_t pmd)
 {
 	/*
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index f834a74..f6e4712 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -59,42 +59,7 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
 	/* Only called for hugetlbfs pages, hence can ignore THP */
 	return __find_linux_pte_or_hugepte(mm->pgd, addr, NULL, NULL);
 }
-#else
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
 
-	pmdp = pmd_offset(&pud, addr);
-	pmd  = READ_ONCE(*pmdp);
-	if (pmd_none(pmd))
-		return NULL;
-
-	if (pmd_huge(pmd))
-		return (pte_t *)pmdp;
-	return NULL;
-}
-#endif /* !defined(CONFIG_PPC_64K_PAGES) || !defined(CONFIG_PPC_BOOK3S_64) */
-
-#if !defined(CONFIG_PPC_64K_PAGES) || !defined(CONFIG_PPC_BOOK3S_64)
 static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
 			   unsigned long address, unsigned pdshift, unsigned pshift)
 {
@@ -211,31 +176,6 @@ hugepd_search:
 
 	return hugepte_offset(*hpdp, addr, pdshift);
 }
-
-#else
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
 #endif
 #else
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
