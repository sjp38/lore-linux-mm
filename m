Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9596B7721
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 01:44:08 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id p14-v6so11751978oip.0
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 22:44:08 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id u4-v6si2627558oif.129.2018.09.05.22.44.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 22:44:07 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w865hiZi146248
	for <linux-mm@kvack.org>; Thu, 6 Sep 2018 01:44:06 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mathwfss1-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Sep 2018 01:44:06 -0400
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 6 Sep 2018 01:44:06 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [RFC PATCH V2 3/4] powerpc/mm/iommu: Allow large IOMMU page size only for hugetlb backing
Date: Thu,  6 Sep 2018 11:13:41 +0530
In-Reply-To: <20180906054342.25094-1-aneesh.kumar@linux.ibm.com>
References: <20180906054342.25094-1-aneesh.kumar@linux.ibm.com>
Message-Id: <20180906054342.25094-3-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Alexey Kardashevskiy <aik@ozlabs.ru>, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>

THP pages can get split during different code paths. An incremented reference
count do imply we will not split the compound page. But the pmd entry can be
converted to level 4 pte entries. Keep the code simpler by allowing large
IOMMU page size only if the guest ram is backed by hugetlb pages.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 arch/powerpc/mm/mmu_context_iommu.c | 16 ++--------------
 1 file changed, 2 insertions(+), 14 deletions(-)

diff --git a/arch/powerpc/mm/mmu_context_iommu.c b/arch/powerpc/mm/mmu_context_iommu.c
index c9ee9e23845f..f472965f7638 100644
--- a/arch/powerpc/mm/mmu_context_iommu.c
+++ b/arch/powerpc/mm/mmu_context_iommu.c
@@ -212,21 +212,9 @@ long mm_iommu_get(struct mm_struct *mm, unsigned long ua, unsigned long entries,
 		}
 populate:
 		pageshift = PAGE_SHIFT;
-		if (mem->pageshift > PAGE_SHIFT && PageCompound(page)) {
-			pte_t *pte;
+		if (mem->pageshift > PAGE_SHIFT && PageHuge(page)) {
 			struct page *head = compound_head(page);
-			unsigned int compshift = compound_order(head);
-			unsigned int pteshift;
-
-			local_irq_save(flags); /* disables as well */
-			pte = find_linux_pte(mm->pgd, cur_ua, NULL, &pteshift);
-
-			/* Double check it is still the same pinned page */
-			if (pte && pte_page(*pte) == head &&
-			    pteshift == compshift + PAGE_SHIFT)
-				pageshift = max_t(unsigned int, pteshift,
-						PAGE_SHIFT);
-			local_irq_restore(flags);
+			pageshift = compound_order(head) + PAGE_SHIFT;
 		}
 		mem->pageshift = min(mem->pageshift, pageshift);
 		mem->hpas[i] = page_to_pfn(page) << PAGE_SHIFT;
-- 
2.17.1
