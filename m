Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7DF52280273
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 13:28:29 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id b71so117412440lfg.2
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 10:28:29 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l2si20326781wjg.109.2016.09.26.10.28.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 10:28:28 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8QHMR9H082306
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 13:28:26 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 25q529128y-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 13:28:26 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Mon, 26 Sep 2016 18:28:25 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id D71CC17D8024
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 18:30:23 +0100 (BST)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8QHSMWc12321120
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 17:28:22 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8QHSLL1008371
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 11:28:22 -0600
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: [PATCH v4 1/3] mm/hugetlb: fix memory offline with hugepage size > memory block size
Date: Mon, 26 Sep 2016 19:28:09 +0200
In-Reply-To: <20160926172811.94033-1-gerald.schaefer@de.ibm.com>
References: <20160926172811.94033-1-gerald.schaefer@de.ibm.com>
Message-Id: <20160926172811.94033-2-gerald.schaefer@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>

dissolve_free_huge_pages() will either run into the VM_BUG_ON() or a
list corruption and addressing exception when trying to set a memory
block offline that is part (but not the first part) of a "gigantic"
hugetlb page with a size > memory block size.

When no other smaller hugetlb page sizes are present, the VM_BUG_ON()
will trigger directly. In the other case we will run into an addressing
exception later, because dissolve_free_huge_page() will not work on the
head page of the compound hugetlb page which will result in a NULL
hstate from page_hstate().

To fix this, first remove the VM_BUG_ON() because it is wrong, and then
use the compound head page in dissolve_free_huge_page(). This means that
an unused pre-allocated gigantic page that has any part of itself inside
the memory block that is going offline will be dissolved completely.
Losing an unused gigantic hugepage is preferable to failing the memory
offline, for example in the situation where a (possibly faulty) memory
DIMM needs to go offline.

Fixes: c8721bbb ("mm: memory-hotplug: enable memory hotplug to handle hugepage")
Cc: <stable@vger.kernel.org>
Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
---
 mm/hugetlb.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 87e11d8..603bdd0 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1443,13 +1443,14 @@ static void dissolve_free_huge_page(struct page *page)
 {
 	spin_lock(&hugetlb_lock);
 	if (PageHuge(page) && !page_count(page)) {
-		struct hstate *h = page_hstate(page);
-		int nid = page_to_nid(page);
-		list_del(&page->lru);
+		struct page *head = compound_head(page);
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
@@ -1457,7 +1458,8 @@ static void dissolve_free_huge_page(struct page *page)
 /*
  * Dissolve free hugepages in a given pfn range. Used by memory hotplug to
  * make specified memory blocks removable from the system.
- * Note that start_pfn should aligned with (minimum) hugepage size.
+ * Note that this will dissolve a free gigantic hugepage completely, if any
+ * part of it lies within the given range.
  */
 void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
 {
@@ -1466,7 +1468,6 @@ void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
 	if (!hugepages_supported())
 		return;
 
-	VM_BUG_ON(!IS_ALIGNED(start_pfn, 1 << minimum_order));
 	for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << minimum_order)
 		dissolve_free_huge_page(pfn_to_page(pfn));
 }
-- 
2.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
