Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6876B0253
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 07:11:59 -0500 (EST)
Received: by mail-io0-f182.google.com with SMTP id m184so63115143iof.1
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 04:11:59 -0800 (PST)
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com. [202.81.31.144])
        by mx.google.com with ESMTPS id 197si10388535ioz.11.2016.03.09.04.11.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 09 Mar 2016 04:11:58 -0800 (PST)
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 9 Mar 2016 22:11:54 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 08A1E3578056
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 23:11:53 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u29CBiSc66584768
	for <linux-mm@kvack.org>; Wed, 9 Mar 2016 23:11:53 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u29CBK4L021624
	for <linux-mm@kvack.org>; Wed, 9 Mar 2016 23:11:20 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC 5/9] powerpc/mm: Split huge_pte_offset function for BOOK3S 64K
Date: Wed,  9 Mar 2016 17:40:46 +0530
Message-Id: <1457525450-4262-5-git-send-email-khandual@linux.vnet.ibm.com>
In-Reply-To: <1457525450-4262-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1457525450-4262-1-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aneesh.kumar@linux.vnet.ibm.com, mpe@ellerman.id.au

Currently the 'huge_pte_offset' function has only one version for
all the configuations and platforms. This change splits the function
into two versions, one for 64K page size based BOOK3S implementation
and the other one for everything else. This change is also one of the
prerequisites towards enabling GENERAL_HUGETLB implementation for
BOOK3S 64K based huge pages.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 arch/powerpc/mm/hugetlbpage.c | 35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index a49c6ae..f834a74 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -53,11 +53,46 @@ static unsigned nr_gpages;
 
 #define hugepd_none(hpd)	((hpd).pd == 0)
 
+#if !defined(CONFIG_PPC_64K_PAGES) || !defined(CONFIG_PPC_BOOK3S_64)
 pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
 {
 	/* Only called for hugetlbfs pages, hence can ignore THP */
 	return __find_linux_pte_or_hugepte(mm->pgd, addr, NULL, NULL);
 }
+#else
+pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
+{
+	pgd_t pgd, *pgdp;
+	pud_t pud, *pudp;
+	pmd_t pmd, *pmdp;
+
+	pgdp = mm->pgd + pgd_index(addr);
+	pgd  = READ_ONCE(*pgdp);
+
+	if (pgd_none(pgd))
+		return NULL;
+
+	if (pgd_huge(pgd))
+		return (pte_t *)pgdp;
+
+	pudp = pud_offset(&pgd, addr);
+	pud  = READ_ONCE(*pudp);
+	if (pud_none(pud))
+		return NULL;
+
+	if (pud_huge(pud))
+		return (pte_t *)pudp;
+
+	pmdp = pmd_offset(&pud, addr);
+	pmd  = READ_ONCE(*pmdp);
+	if (pmd_none(pmd))
+		return NULL;
+
+	if (pmd_huge(pmd))
+		return (pte_t *)pmdp;
+	return NULL;
+}
+#endif /* !defined(CONFIG_PPC_64K_PAGES) || !defined(CONFIG_PPC_BOOK3S_64) */
 
 #if !defined(CONFIG_PPC_64K_PAGES) || !defined(CONFIG_PPC_BOOK3S_64)
 static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
