Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id BCD976B0276
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 04:49:26 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id fl2so1810049pad.7
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 01:49:26 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l123si1454521pfl.162.2016.10.26.01.49.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 01:49:25 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9Q8nCqX038072
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 04:49:24 -0400
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26apc58q0n-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 04:49:24 -0400
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 26 Oct 2016 02:49:23 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 1/5] mm: Use the correct page size when removing the page
Date: Wed, 26 Oct 2016 14:18:35 +0530
In-Reply-To: <20161026084839.27299-1-aneesh.kumar@linux.vnet.ibm.com>
References: <20161026084839.27299-1-aneesh.kumar@linux.vnet.ibm.com>
Message-Id: <20161026084839.27299-2-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We are removing a pmd hugepage here. Use the correct page size.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/huge_memory.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index cdcd25cb30fe..12c6685d4e97 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1398,12 +1398,12 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	if (vma_is_dax(vma)) {
 		spin_unlock(ptl);
 		if (is_huge_zero_pmd(orig_pmd))
-			tlb_remove_page(tlb, pmd_page(orig_pmd));
+			tlb_remove_page_size(tlb, pmd_page(orig_pmd), HPAGE_PMD_SIZE);
 	} else if (is_huge_zero_pmd(orig_pmd)) {
 		pte_free(tlb->mm, pgtable_trans_huge_withdraw(tlb->mm, pmd));
 		atomic_long_dec(&tlb->mm->nr_ptes);
 		spin_unlock(ptl);
-		tlb_remove_page(tlb, pmd_page(orig_pmd));
+		tlb_remove_page_size(tlb, pmd_page(orig_pmd), HPAGE_PMD_SIZE);
 	} else {
 		struct page *page = pmd_page(orig_pmd);
 		page_remove_rmap(page, true);
-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
