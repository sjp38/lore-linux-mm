Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id BC0D26B0253
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 11:54:30 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b130so20271805wmc.2
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 08:54:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id ey2si24878116wjd.209.2016.09.20.08.54.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Sep 2016 08:54:29 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8KFsFaU117993
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 11:54:28 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 25jkn4yem1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 11:54:28 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Tue, 20 Sep 2016 16:54:26 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id C2B18219005E
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 16:53:41 +0100 (BST)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8KFsLrQ24641980
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 15:54:21 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8KFsLum032444
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 09:54:21 -0600
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: [PATCH 1/1] mm/hugetlb: fix memory offline with hugepage size > memory block size
Date: Tue, 20 Sep 2016 17:53:54 +0200
In-Reply-To: <20160920155354.54403-1-gerald.schaefer@de.ibm.com>
References: <20160920155354.54403-1-gerald.schaefer@de.ibm.com>
Message-Id: <20160920155354.54403-2-gerald.schaefer@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

dissolve_free_huge_pages() will either run into the VM_BUG_ON() or a
list corruption and addressing exception when trying to set a memory
block offline that is part (but not the first part) of a gigantic
hugetlb page with a size > memory block size.

When no other smaller hugepage sizes are present, the VM_BUG_ON() will
trigger directly. In the other case we will run into an addressing
exception later, because dissolve_free_huge_page() will not use the head
page of the compound hugetlb page which will result in a NULL hstate
from page_hstate(). list_del() would also not work well on a tail page.

To fix this, first remove the VM_BUG_ON() because it is wrong, and then
use the compound head page in dissolve_free_huge_page().

Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
---
 mm/hugetlb.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 87e11d8..65e723c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1441,15 +1441,17 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
  */
 static void dissolve_free_huge_page(struct page *page)
 {
+	struct page *head = compound_head(page);
+
 	spin_lock(&hugetlb_lock);
-	if (PageHuge(page) && !page_count(page)) {
-		struct hstate *h = page_hstate(page);
-		int nid = page_to_nid(page);
-		list_del(&page->lru);
+	if (!page_count(head)) {
+		struct hstate *h = page_hstate(head);
+		int nid = page_to_nid(head);
+		list_del(&head->lru);
 		h->free_huge_pages--;
 		h->free_huge_pages_node[nid]--;
 		h->max_huge_pages--;
-		update_and_free_page(h, page);
+		update_and_free_page(h, head);
 	}
 	spin_unlock(&hugetlb_lock);
 }
@@ -1466,9 +1468,9 @@ void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
 	if (!hugepages_supported())
 		return;
 
-	VM_BUG_ON(!IS_ALIGNED(start_pfn, 1 << minimum_order));
 	for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << minimum_order)
-		dissolve_free_huge_page(pfn_to_page(pfn));
+		if (PageHuge(pfn_to_page(pfn)))
+			dissolve_free_huge_page(pfn_to_page(pfn));
 }
 
 /*
-- 
2.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
