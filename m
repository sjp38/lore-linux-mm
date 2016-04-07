Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1D94D6B025E
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 01:38:02 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fe3so47914003pab.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 22:38:02 -0700 (PDT)
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com. [125.16.236.2])
        by mx.google.com with ESMTPS id q82si9299027pfi.220.2016.04.06.22.38.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 06 Apr 2016 22:38:01 -0700 (PDT)
Received: from localhost
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 7 Apr 2016 11:07:59 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u375cFmW11534694
	for <linux-mm@kvack.org>; Thu, 7 Apr 2016 11:08:15 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u375bpdM006220
	for <linux-mm@kvack.org>; Thu, 7 Apr 2016 11:07:55 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH 06/10] powerpc/hugetlb: Split the function 'huge_pte_offset'
Date: Thu,  7 Apr 2016 11:07:40 +0530
Message-Id: <1460007464-26726-7-git-send-email-khandual@linux.vnet.ibm.com>
In-Reply-To: <1460007464-26726-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1460007464-26726-1-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, mgorman@techsingularity.net, dave.hansen@intel.com, aneesh.kumar@linux.vnet.ibm.com, mpe@ellerman.id.au

Currently the function 'huge_pte_offset' has just got one version for all
possible configurations and platforms. This change splits that function
into two versions, first one for ARCH_WANT_GENERAL_HUGETLB implementation
and the other one for everything else. This change is again one of the
prerequisites towards enabling ARCH_WANT_GENERAL_ HUGETLB config option
on POWER platform.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 arch/powerpc/mm/hugetlbpage.c | 35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index e453918..8fc6d23 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -53,11 +53,46 @@ static unsigned nr_gpages;
 
 #define hugepd_none(hpd)	((hpd).pd == 0)
 
+#ifndef CONFIG_ARCH_WANT_GENERAL_HUGETLB
 pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
 {
 	/* Only called for hugetlbfs pages, hence can ignore THP */
 	return __find_linux_pte_or_hugepte(mm->pgd, addr, NULL, NULL);
 }
+#else /* CONFIG_ARCH_WANT_GENERAL_HUGETLB */
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
+#endif /* !CONFIG_ARCH_WANT_GENERAL_HUGETLB */
 
 #ifndef CONFIG_ARCH_WANT_GENERAL_HUGETLB
 static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
