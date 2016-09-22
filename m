Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 92552280256
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 12:29:51 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id cg13so158163517pac.1
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 09:29:51 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id qp8si2750889pac.89.2016.09.22.09.29.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 09:29:50 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8MGSIeE013963
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 12:29:50 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25mcyfq562-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 12:29:50 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Thu, 22 Sep 2016 17:29:42 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 07C0917D8024
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 17:31:39 +0100 (BST)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8MGTdk623396640
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 16:29:39 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8MGTcXG018454
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 10:29:39 -0600
Date: Thu, 22 Sep 2016 18:29:37 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: [PATCH v3] mm/hugetlb: fix memory offline with hugepage size >
 memory block size
In-Reply-To: <20160922154549.483ee313@thinkpad>
References: <20160920155354.54403-1-gerald.schaefer@de.ibm.com>
	<20160920155354.54403-2-gerald.schaefer@de.ibm.com>
	<05d701d213d1$7fb70880$7f251980$@alibaba-inc.com>
	<20160921143534.0dd95fe7@thinkpad>
	<20160922095137.GC11875@dhcp22.suse.cz>
	<20160922154549.483ee313@thinkpad>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20160922182937.38af9d0e@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>

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
Losing the gigantic hugepage is preferable to failing the memory offline,
for example in the situation where a (possibly faulty) memory DIMM needs
to go offline.

Also move the PageHuge() and page_count() checks out of
dissolve_free_huge_page() in order to only take the spin_lock when
actually removing a hugepage.

Fixes: c8721bbb ("mm: memory-hotplug: enable memory hotplug to handle hugepage")
Cc: <stable@vger.kernel.org>
Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
---
Changes in v3:
- Add Fixes: c8721bbb
- Add Cc: stable
- Elaborate on losing the gigantic page vs. failing memory offline
- Move page_count() check out of dissolve_free_huge_page()

Changes in v2:
- Update comment in dissolve_free_huge_pages()
- Change locking in dissolve_free_huge_page()

 mm/hugetlb.c | 34 +++++++++++++++++++---------------
 1 file changed, 19 insertions(+), 15 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 87e11d8..29e10a2 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1436,39 +1436,43 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
 }
 
 /*
- * Dissolve a given free hugepage into free buddy pages. This function does
- * nothing for in-use (including surplus) hugepages.
+ * Dissolve a given free hugepage into free buddy pages.
  */
 static void dissolve_free_huge_page(struct page *page)
 {
+	struct page *head = compound_head(page);
+	struct hstate *h = page_hstate(head);
+	int nid = page_to_nid(head);
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
+ * This function does nothing for in-use (including surplus) hugepages.
  */
 void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
 {
 	unsigned long pfn;
+	struct page *page;
 
 	if (!hugepages_supported())
 		return;
 
-	VM_BUG_ON(!IS_ALIGNED(start_pfn, 1 << minimum_order));
-	for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << minimum_order)
-		dissolve_free_huge_page(pfn_to_page(pfn));
+	for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << minimum_order) {
+		page = pfn_to_page(pfn);
+		if (PageHuge(page) && !page_count(page))
+			dissolve_free_huge_page(page);
+	}
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
