Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 68B836B003D
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 05:09:36 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 4 Apr 2013 14:34:18 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 406673940058
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 14:39:29 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3499NDb9765374
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 14:39:23 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3499Rpx023592
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 20:09:28 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 4/6] mm/hugetlb: use already exist huge_page_order() instead of h->order 
Date: Thu,  4 Apr 2013 17:09:12 +0800
Message-Id: <1365066554-29195-5-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1365066554-29195-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1365066554-29195-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Use already exist interface huge_page_order() instead of h->order to get 
huge page order.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/hugetlb.c |   36 +++++++++++++++++++-----------------
 1 file changed, 19 insertions(+), 17 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 328f140..0cae950 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -593,7 +593,8 @@ static void update_and_free_page(struct hstate *h, struct page *page)
 	struct page *p;
 	int order = huge_page_order(h);
 
-	VM_BUG_ON(!hugetlb_shrink_gigantic_pool && h->order >= MAX_ORDER);
+	VM_BUG_ON(!hugetlb_shrink_gigantic_pool &&
+					huge_page_order(h) >= MAX_ORDER);
 
 	h->nr_huge_pages--;
 	h->nr_huge_pages_node[page_to_nid(page)]--;
@@ -722,7 +723,7 @@ static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
 {
 	struct page *page;
 
-	if (h->order >= MAX_ORDER)
+	if (huge_page_order(h) >= MAX_ORDER)
 		return NULL;
 
 	page = alloc_pages_exact_node(nid,
@@ -876,7 +877,7 @@ static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
 	struct page *page;
 	unsigned int r_nid;
 
-	if (h->order >= MAX_ORDER)
+	if (huge_page_order(h) >= MAX_ORDER)
 		return NULL;
 
 	/*
@@ -1071,7 +1072,7 @@ static void return_unused_surplus_pages(struct hstate *h,
 	h->resv_huge_pages -= unused_resv_pages;
 
 	/* Cannot return gigantic pages currently */
-	if (h->order >= MAX_ORDER)
+	if (huge_page_order(h) >= MAX_ORDER)
 		return;
 
 	nr_pages = min(unused_resv_pages, h->surplus_huge_pages);
@@ -1265,7 +1266,7 @@ static void __init gather_bootmem_prealloc(void)
 #endif
 		__ClearPageReserved(page);
 		WARN_ON(page_count(page) != 1);
-		prep_compound_huge_page(page, h->order);
+		prep_compound_huge_page(page, huge_page_order(h));
 		prep_new_huge_page(h, page, page_to_nid(page));
 		/*
 		 * If we had gigantic hugepages allocated at boot time, we need
@@ -1273,8 +1274,8 @@ static void __init gather_bootmem_prealloc(void)
 		 * fix confusing memory reports from free(1) and another
 		 * side-effects, like CommitLimit going negative.
 		 */
-		if (h->order > (MAX_ORDER - 1))
-			totalram_pages += 1 << h->order;
+		if (huge_page_order(h) > (MAX_ORDER - 1))
+			totalram_pages += 1 << huge_page_order(h);
 	}
 }
 
@@ -1283,7 +1284,7 @@ static void __init hugetlb_hstate_alloc_pages(struct hstate *h)
 	unsigned long i;
 
 	for (i = 0; i < h->max_huge_pages; ++i) {
-		if (h->order >= MAX_ORDER) {
+		if (huge_page_order(h) >= MAX_ORDER) {
 			if (!alloc_bootmem_huge_page(h))
 				break;
 		} else if (!alloc_fresh_huge_page(h,
@@ -1299,7 +1300,7 @@ static void __init hugetlb_init_hstates(void)
 
 	for_each_hstate(h) {
 		/* oversize hugepages were init'ed in early boot */
-		if (h->order < MAX_ORDER)
+		if (huge_page_order(h) < MAX_ORDER)
 			hugetlb_hstate_alloc_pages(h);
 	}
 }
@@ -1333,7 +1334,7 @@ static void try_to_free_low(struct hstate *h, unsigned long count,
 {
 	int i;
 
-	if (h->order >= MAX_ORDER)
+	if (huge_page_order(h) >= MAX_ORDER)
 		return;
 
 	for_each_node_mask(i, *nodes_allowed) {
@@ -1416,8 +1417,8 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 {
 	unsigned long min_count, ret;
 
-	if (h->order >= MAX_ORDER && (!hugetlb_shrink_gigantic_pool ||
-				count > persistent_huge_pages(h)))
+	if (huge_page_order(h) >= MAX_ORDER && (!hugetlb_shrink_gigantic_pool
+				|| count > persistent_huge_pages(h)))
 		return h->max_huge_pages;
 
 	/*
@@ -1543,7 +1544,7 @@ static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
 		goto out;
 
 	h = kobj_to_hstate(kobj, &nid);
-	if (h->order >= MAX_ORDER && !hugetlb_shrink_gigantic_pool) {
+	if (huge_page_order(h) >= MAX_ORDER && !hugetlb_shrink_gigantic_pool) {
 		err = -EINVAL;
 		goto out;
 	}
@@ -1626,7 +1627,7 @@ static ssize_t nr_overcommit_hugepages_store(struct kobject *kobj,
 	unsigned long input;
 	struct hstate *h = kobj_to_hstate(kobj, NULL);
 
-	if (h->order >= MAX_ORDER)
+	if (huge_page_order(h) >= MAX_ORDER)
 		return -EINVAL;
 
 	err = strict_strtoul(buf, 10, &input);
@@ -2037,7 +2038,8 @@ static int hugetlb_sysctl_handler_common(bool obey_mempolicy,
 
 	tmp = h->max_huge_pages;
 
-	if (write && h->order >= MAX_ORDER && !hugetlb_shrink_gigantic_pool)
+	if (write && huge_page_order(h) >= MAX_ORDER &&
+						!hugetlb_shrink_gigantic_pool)
 		return -EINVAL;
 
 	table->data = &tmp;
@@ -2102,7 +2104,7 @@ int hugetlb_overcommit_handler(struct ctl_table *table, int write,
 
 	tmp = h->nr_overcommit_huge_pages;
 
-	if (write && h->order >= MAX_ORDER)
+	if (write && huge_page_order(h) >= MAX_ORDER)
 		return -EINVAL;
 
 	table->data = &tmp;
@@ -3093,7 +3095,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	flush_tlb_range(vma, start, end);
 	mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
 
-	return pages << h->order;
+	return pages << huge_page_order(h);
 }
 
 int hugetlb_reserve_pages(struct inode *inode,
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
