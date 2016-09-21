Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 42C2C6B026A
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 08:35:44 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id wk8so89758293pab.3
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 05:35:44 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v4si40587355paa.285.2016.09.21.05.35.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Sep 2016 05:35:43 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8LCW1JT054000
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 08:35:42 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25kkb620xu-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 08:35:42 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Wed, 21 Sep 2016 13:35:39 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 0B03317D8062
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 13:37:35 +0100 (BST)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8LCZanf43647042
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 12:35:36 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8LCZZdw024245
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 08:35:35 -0400
Date: Wed, 21 Sep 2016 14:35:34 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: [PATCH v2 1/1] mm/hugetlb: fix memory offline with hugepage size >
 memory block size
In-Reply-To: <05d701d213d1$7fb70880$7f251980$@alibaba-inc.com>
References: <20160920155354.54403-1-gerald.schaefer@de.ibm.com>
	<20160920155354.54403-2-gerald.schaefer@de.ibm.com>
	<05d701d213d1$7fb70880$7f251980$@alibaba-inc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20160921143534.0dd95fe7@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K .
 V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

dissolve_free_huge_pages() will either run into the VM_BUG_ON() or a
list corruption and addressing exception when trying to set a memory
block offline that is part (but not the first part) of a hugetlb page
with a size > memory block size.

When no other smaller hugetlb page sizes are present, the VM_BUG_ON()
will trigger directly. In the other case we will run into an addressing
exception later, because dissolve_free_huge_page() will not work on the
head page of the compound hugetlb page which will result in a NULL
hstate from page_hstate().

To fix this, first remove the VM_BUG_ON() because it is wrong, and then
use the compound head page in dissolve_free_huge_page().

Also change locking in dissolve_free_huge_page(), so that it only takes
the lock when actually removing a hugepage.

Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
---
Changes in v2:
- Update comment in dissolve_free_huge_pages()
- Change locking in dissolve_free_huge_page()

 mm/hugetlb.c | 31 +++++++++++++++++++------------
 1 file changed, 19 insertions(+), 12 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 87e11d8..1522af8 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1441,23 +1441,30 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
  */
 static void dissolve_free_huge_page(struct page *page)
 {
+	struct page *head = compound_head(page);
+	struct hstate *h;
+	int nid;
+
+	if (page_count(head))
+		return;
+
+	h = page_hstate(head);
+	nid = page_to_nid(head);
+
 	spin_lock(&hugetlb_lock);
-	if (PageHuge(page) && !page_count(page)) {
-		struct hstate *h = page_hstate(page);
-		int nid = page_to_nid(page);
-		list_del(&page->lru);
-		h->free_huge_pages--;
-		h->free_huge_pages_node[nid]--;
-		h->max_huge_pages--;
-		update_and_free_page(h, page);
-	}
+	list_del(&head->lru);
+	h->free_huge_pages--;
+	h->free_huge_pages_node[nid]--;
+	h->max_huge_pages--;
+	update_and_free_page(h, head);
 	spin_unlock(&hugetlb_lock);
 }
 
 /*
  * Dissolve free hugepages in a given pfn range. Used by memory hotplug to
  * make specified memory blocks removable from the system.
- * Note that start_pfn should aligned with (minimum) hugepage size.
+ * Note that this will dissolve a free gigantic hugepage completely, if any
+ * part of it lies within the given range.
  */
 void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
 {
@@ -1466,9 +1473,9 @@ void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
