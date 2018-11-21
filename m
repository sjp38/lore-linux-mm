Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D2D8B6B2574
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 04:23:24 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id o23so7270651pll.0
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 01:23:24 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x1si25766639pfn.111.2018.11.21.01.23.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 01:23:23 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wAL9J9fi088616
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 04:23:23 -0500
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2nw4c313ju-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 04:23:23 -0500
Received: from localhost
	by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 21 Nov 2018 09:23:21 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH V4 3/3] powerpc/mm/iommu: Allow large IOMMU page size only for hugetlb backing
Date: Wed, 21 Nov 2018 14:52:59 +0530
In-Reply-To: <20181121092259.16482-1-aneesh.kumar@linux.ibm.com>
References: <20181121092259.16482-1-aneesh.kumar@linux.ibm.com>
Message-Id: <20181121092259.16482-4-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Michal Hocko <mhocko@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, mpe@ellerman.id.au, paulus@samba.org, David Gibson <david@gibson.dropbear.id.au>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>

THP pages can get split during different code paths. An incremented reference
count do imply we will not split the compound page. But the pmd entry can be
converted to level 4 pte entries. Keep the code simpler by allowing large
IOMMU page size only if the guest ram is backed by hugetlb pages.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 arch/powerpc/mm/mmu_context_iommu.c | 24 +++++++-----------------
 1 file changed, 7 insertions(+), 17 deletions(-)

diff --git a/arch/powerpc/mm/mmu_context_iommu.c b/arch/powerpc/mm/mmu_context_iommu.c
index 1d5161f93ce6..0741d905ed04 100644
--- a/arch/powerpc/mm/mmu_context_iommu.c
+++ b/arch/powerpc/mm/mmu_context_iommu.c
@@ -95,8 +95,6 @@ long mm_iommu_get(struct mm_struct *mm, unsigned long ua, unsigned long entries,
 	struct mm_iommu_table_group_mem_t *mem;
 	long i, ret = 0, locked_entries = 0;
 	unsigned int pageshift;
-	unsigned long flags;
-	unsigned long cur_ua;
 
 	mutex_lock(&mem_list_mutex);
 
@@ -159,23 +157,15 @@ long mm_iommu_get(struct mm_struct *mm, unsigned long ua, unsigned long entries,
 	pageshift = PAGE_SHIFT;
 	for (i = 0; i < entries; ++i) {
 		struct page *page = mem->hpages[i];
-		cur_ua = ua + (i << PAGE_SHIFT);
 
-		if (mem->pageshift > PAGE_SHIFT && PageCompound(page)) {
-			pte_t *pte;
+		/*
+		 * Allow to use larger than 64k IOMMU pages. Only do that
+		 * if we are backed by hugetlb.
+		 */
+		if ((mem->pageshift > PAGE_SHIFT) && PageHuge(page)) {
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
+
+			pageshift = compound_order(head) + PAGE_SHIFT;
 		}
 		mem->pageshift = min(mem->pageshift, pageshift);
 		/*
-- 
2.17.2
