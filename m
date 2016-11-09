Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BE1A66B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 02:09:17 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 144so69097193pfv.5
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 23:09:17 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0086.outbound.protection.outlook.com. [104.47.0.86])
        by mx.google.com with ESMTPS id g6si40750779pfa.52.2016.11.08.23.09.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 08 Nov 2016 23:09:16 -0800 (PST)
From: Huang Shijie <shijie.huang@arm.com>
Subject: [PATCH v2 2/2] mm: hugetlb: support gigantic surplus pages
Date: Wed, 9 Nov 2016 15:08:14 +0800
Message-ID: <1478675294-2507-1-git-send-email-shijie.huang@arm.com>
In-Reply-To: <1478141499-13825-3-git-send-email-shijie.huang@arm.com>
References: <1478141499-13825-3-git-send-email-shijie.huang@arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, catalin.marinas@arm.com
Cc: n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org, Huang Shijie <shijie.huang@arm.com>

When testing the gigantic page whose order is too large for the buddy
allocator, the libhugetlbfs test case "counter.sh" will fail.

The failure is caused by:
 1) kernel fails to allocate a gigantic page for the surplus case.
    And the gather_surplus_pages() will return NULL in the end.

 2) The condition checks for "over-commit" is wrong.

This patch adds code to allocate the gigantic page in the
__alloc_huge_page(). After this patch, gather_surplus_pages()
can return a gigantic page for the surplus case.

This patch changes the condition checks for:
     return_unused_surplus_pages()
     nr_overcommit_hugepages_store()
     hugetlb_overcommit_handler()

This patch also set @nid with proper value when NUMA_NO_NODE is
passed to alloc_gigantic_page().

After this patch, the counter.sh can pass for the gigantic page.

Acked-by: Steve Capper <steve.capper@arm.com>
Signed-off-by: Huang Shijie <shijie.huang@arm.com>
---
  1. fix the wrong check in hugetlb_overcommit_handler();
  2. try to fix the s390 issue.
---
 mm/hugetlb.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 9fdfc24..5dbfd62 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1095,6 +1095,9 @@ static struct page *alloc_gigantic_page(int nid, unsigned int order)
 	unsigned long ret, pfn, flags;
 	struct zone *z;
 
+	if (nid == NUMA_NO_NODE)
+		nid = numa_mem_id();
+
 	z = NODE_DATA(nid)->node_zones;
 	for (; z - NODE_DATA(nid)->node_zones < MAX_NR_ZONES; z++) {
 		spin_lock_irqsave(&z->lock, flags);
@@ -1578,7 +1581,7 @@ static struct page *__alloc_huge_page(struct hstate *h,
 	struct page *page;
 	unsigned int r_nid;
 
-	if (hstate_is_gigantic(h))
+	if (hstate_is_gigantic(h) && !gigantic_page_supported())
 		return NULL;
 
 	/*
@@ -1623,7 +1626,13 @@ static struct page *__alloc_huge_page(struct hstate *h,
 	}
 	spin_unlock(&hugetlb_lock);
 
-	page = __hugetlb_alloc_buddy_huge_page(h, vma, addr, nid);
+	if (hstate_is_gigantic(h))  {
+		page = alloc_gigantic_page(nid, huge_page_order(h));
+		if (page)
+			prep_compound_gigantic_page(page, huge_page_order(h));
+	} else {
+		page = __hugetlb_alloc_buddy_huge_page(h, vma, addr, nid);
+	}
 
 	spin_lock(&hugetlb_lock);
 	if (page) {
@@ -1790,8 +1799,7 @@ static void return_unused_surplus_pages(struct hstate *h,
 	/* Uncommit the reservation */
 	h->resv_huge_pages -= unused_resv_pages;
 
-	/* Cannot return gigantic pages currently */
-	if (hstate_is_gigantic(h))
+	if (hstate_is_gigantic(h) && !gigantic_page_supported())
 		return;
 
 	nr_pages = min(unused_resv_pages, h->surplus_huge_pages);
@@ -2443,7 +2451,7 @@ static ssize_t nr_overcommit_hugepages_store(struct kobject *kobj,
 	unsigned long input;
 	struct hstate *h = kobj_to_hstate(kobj, NULL);
 
-	if (hstate_is_gigantic(h))
+	if (hstate_is_gigantic(h) && !gigantic_page_supported())
 		return -EINVAL;
 
 	err = kstrtoul(buf, 10, &input);
@@ -2884,7 +2892,7 @@ int hugetlb_overcommit_handler(struct ctl_table *table, int write,
 
 	tmp = h->nr_overcommit_huge_pages;
 
-	if (write && hstate_is_gigantic(h))
+	if (write && hstate_is_gigantic(h) && !gigantic_page_supported())
 		return -EINVAL;
 
 	table->data = &tmp;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
