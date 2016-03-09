Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2CCF16B0256
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 07:12:03 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id td3so11669028pab.2
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 04:12:03 -0800 (PST)
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com. [202.81.31.140])
        by mx.google.com with ESMTPS id 75si12199686pfs.118.2016.03.09.04.11.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 09 Mar 2016 04:12:00 -0800 (PST)
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 9 Mar 2016 22:11:56 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 7B65A2CE805A
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 23:11:50 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u29CBgap4129052
	for <linux-mm@kvack.org>; Wed, 9 Mar 2016 23:11:50 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u29CBHxv021501
	for <linux-mm@kvack.org>; Wed, 9 Mar 2016 23:11:18 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC 4/9] powerpc/mm: Split huge_pte_alloc function for BOOK3S 64K
Date: Wed,  9 Mar 2016 17:40:45 +0530
Message-Id: <1457525450-4262-4-git-send-email-khandual@linux.vnet.ibm.com>
In-Reply-To: <1457525450-4262-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1457525450-4262-1-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aneesh.kumar@linux.vnet.ibm.com, mpe@ellerman.id.au

From: root <root@ltcalpine2-lp8.aus.stglabs.ibm.com>

Currently the 'huge_pte_alloc' function has two versions, one for the
BOOK3S and the other one for the BOOK3E platforms. This change splits
the BOOK3S version into two parts, one for the 4K page size based
implementation and the other one for the 64K page sized implementation.
This change is one of the prerequisites towards enabling GENERAL_HUGETLB
implementation for BOOK3S 64K based huge pages.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 arch/powerpc/mm/hugetlbpage.c | 67 +++++++++++++++++++++++++++----------------
 1 file changed, 43 insertions(+), 24 deletions(-)

diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 744e24b..a49c6ae 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -59,6 +59,7 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
 	return __find_linux_pte_or_hugepte(mm->pgd, addr, NULL, NULL);
 }
 
+#if !defined(CONFIG_PPC_64K_PAGES) || !defined(CONFIG_PPC_BOOK3S_64)
 static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
 			   unsigned long address, unsigned pdshift, unsigned pshift)
 {
@@ -117,6 +118,7 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
 	spin_unlock(&mm->page_table_lock);
 	return 0;
 }
+#endif /* !defined(CONFIG_PPC_64K_PAGES) || !defined(CONFIG_PPC_BOOK3S_64) */
 
 /*
  * These macros define how to determine which level of the page table holds
@@ -131,6 +133,7 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
 #endif
 
 #ifdef CONFIG_PPC_BOOK3S_64
+#ifdef CONFIG_PPC_4K_PAGES
 /*
  * At this point we do the placement change only for BOOK3S 64. This would
  * possibly work on other subarchs.
@@ -146,32 +149,23 @@ pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz
 
 	addr &= ~(sz-1);
 	pg = pgd_offset(mm, addr);
-
-	if (pshift == PGDIR_SHIFT)
-		/* 16GB huge page */
-		return (pte_t *) pg;
-	else if (pshift > PUD_SHIFT)
-		/*
-		 * We need to use hugepd table
-		 */
+	if (pshift > PUD_SHIFT) {
 		hpdp = (hugepd_t *)pg;
-	else {
-		pdshift = PUD_SHIFT;
-		pu = pud_alloc(mm, pg, addr);
-		if (pshift == PUD_SHIFT)
-			return (pte_t *)pu;
-		else if (pshift > PMD_SHIFT)
-			hpdp = (hugepd_t *)pu;
-		else {
-			pdshift = PMD_SHIFT;
-			pm = pmd_alloc(mm, pu, addr);
-			if (pshift == PMD_SHIFT)
-				/* 16MB hugepage */
-				return (pte_t *)pm;
-			else
-				hpdp = (hugepd_t *)pm;
-		}
+		goto hugepd_search;
+	}
+
+	pdshift = PUD_SHIFT;
+	pu = pud_alloc(mm, pg, addr);
+	if (pshift > PMD_SHIFT) {
+		hpdp = (hugepd_t *)pu;
+		goto hugepd_search;
 	}
+
+	pdshift = PMD_SHIFT;
+	pm = pmd_alloc(mm, pu, addr);
+	hpdp = (hugepd_t *)pm;
+
+hugepd_search:
 	if (!hpdp)
 		return NULL;
 
@@ -184,6 +178,31 @@ pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz
 }
 
 #else
+pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz)
+{
+	pgd_t *pg;
+	pud_t *pu;
+	pmd_t *pm;
+	unsigned pshift = __ffs(sz);
+
+	addr &= ~(sz-1);
+	pg = pgd_offset(mm, addr);
+
+	if (pshift == PGDIR_SHIFT)	/* 16GB Huge Page */
+		return (pte_t *)pg;
+
+	pu = pud_alloc(mm, pg, addr);	/* NA, skipped */
+	if (pshift == PUD_SHIFT)
+		return (pte_t *)pu;
+
+	pm = pmd_alloc(mm, pu, addr);	/* 16MB Huge Page */
+	if (pshift == PMD_SHIFT)
+		return (pte_t *)pm;
+
+	return NULL;
+}
+#endif
+#else
 
 pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz)
 {
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
