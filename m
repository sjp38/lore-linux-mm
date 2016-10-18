Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id AE6F36B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 05:02:48 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id f134so6813192lfg.6
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 02:02:48 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 24si21633028lfs.411.2016.10.18.02.02.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 02:02:47 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9I8wwsW102163
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 05:02:45 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0b-001b2d01.pphosted.com with ESMTP id 265dnyg2qj-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 05:02:45 -0400
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 18 Oct 2016 03:02:43 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH] mm/hugetlb: Use huge_pte_lock instead of opencoding the lock
Date: Tue, 18 Oct 2016 14:32:34 +0530
Message-Id: <20161018090234.22574-1-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

No functional change by this patch.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/hugetlb.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index da8fbd02b92e..2ff57dfb772d 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3648,8 +3648,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		vma_end_reservation(h, vma, address);
 	}
 
-	ptl = huge_pte_lockptr(h, mm, ptep);
-	spin_lock(ptl);
+	ptl = huge_pte_lock(h, mm, ptep);
 	size = i_size_read(mapping->host) >> huge_page_shift(h);
 	if (idx >= size)
 		goto backout;
@@ -4266,8 +4265,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 	if (!spte)
 		goto out;
 
-	ptl = huge_pte_lockptr(hstate_vma(vma), mm, spte);
-	spin_lock(ptl);
+	ptl = huge_pte_lock(hstate_vma(vma), mm, spte);
 	if (pud_none(*pud)) {
 		pud_populate(mm, pud,
 				(pmd_t *)((unsigned long)spte & PAGE_MASK));
-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
