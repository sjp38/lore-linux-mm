Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 255F56B0038
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 13:59:18 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id x48so4347837wes.35
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 10:59:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id k4si4754654wiz.31.2014.04.10.10.59.14
        for <linux-mm@kvack.org>;
        Thu, 10 Apr 2014 10:59:15 -0700 (PDT)
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: [PATCH 2/5] hugetlb: add hstate_is_gigantic()
Date: Thu, 10 Apr 2014 13:58:42 -0400
Message-Id: <1397152725-20990-3-git-send-email-lcapitulino@redhat.com>
In-Reply-To: <1397152725-20990-1-git-send-email-lcapitulino@redhat.com>
References: <1397152725-20990-1-git-send-email-lcapitulino@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, mtosatti@redhat.com, aarcange@redhat.com, mgorman@suse.de, akpm@linux-foundation.org, andi@firstfloor.org, davidlohr@hp.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, riel@redhat.com, n-horiguchi@ah.jp.nec.com, kirill@shutemov.name

Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
 include/linux/hugetlb.h |  5 +++++
 mm/hugetlb.c            | 28 ++++++++++++++--------------
 2 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 5b337cf..62a8b88 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -343,6 +343,11 @@ static inline unsigned huge_page_shift(struct hstate *h)
 	return h->order + PAGE_SHIFT;
 }
 
+static inline bool hstate_is_gigantic(struct hstate *h)
+{
+	return huge_page_order(h) >= MAX_ORDER;
+}
+
 static inline unsigned int pages_per_huge_page(struct hstate *h)
 {
 	return 1 << h->order;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 957231b..a5e679b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -611,7 +611,7 @@ static void update_and_free_page(struct hstate *h, struct page *page)
 {
 	int i;
 
-	VM_BUG_ON(h->order >= MAX_ORDER);
+	VM_BUG_ON(hstate_is_gigantic(h));
 
 	h->nr_huge_pages--;
 	h->nr_huge_pages_node[page_to_nid(page)]--;
@@ -664,7 +664,7 @@ static void free_huge_page(struct page *page)
 	if (restore_reserve)
 		h->resv_huge_pages++;
 
-	if (h->surplus_huge_pages_node[nid] && huge_page_order(h) < MAX_ORDER) {
+	if (h->surplus_huge_pages_node[nid] && !hstate_is_gigantic(h)) {
 		/* remove the page from active list */
 		list_del(&page->lru);
 		update_and_free_page(h, page);
@@ -768,7 +768,7 @@ static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
 {
 	struct page *page;
 
-	if (h->order >= MAX_ORDER)
+	if (hstate_is_gigantic(h))
 		return NULL;
 
 	page = alloc_pages_exact_node(nid,
@@ -962,7 +962,7 @@ static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
 	struct page *page;
 	unsigned int r_nid;
 
-	if (h->order >= MAX_ORDER)
+	if (hstate_is_gigantic(h))
 		return NULL;
 
 	/*
@@ -1155,7 +1155,7 @@ static void return_unused_surplus_pages(struct hstate *h,
 	h->resv_huge_pages -= unused_resv_pages;
 
 	/* Cannot return gigantic pages currently */
-	if (h->order >= MAX_ORDER)
+	if (hstate_is_gigantic(h))
 		return;
 
 	nr_pages = min(unused_resv_pages, h->surplus_huge_pages);
@@ -1354,7 +1354,7 @@ static void __init gather_bootmem_prealloc(void)
 		 * fix confusing memory reports from free(1) and another
 		 * side-effects, like CommitLimit going negative.
 		 */
-		if (h->order > (MAX_ORDER - 1))
+		if (hstate_is_gigantic(h))
 			adjust_managed_page_count(page, 1 << h->order);
 	}
 }
@@ -1364,7 +1364,7 @@ static void __init hugetlb_hstate_alloc_pages(struct hstate *h)
 	unsigned long i;
 
 	for (i = 0; i < h->max_huge_pages; ++i) {
-		if (h->order >= MAX_ORDER) {
+		if (hstate_is_gigantic(h)) {
 			if (!alloc_bootmem_huge_page(h))
 				break;
 		} else if (!alloc_fresh_huge_page(h,
@@ -1380,7 +1380,7 @@ static void __init hugetlb_init_hstates(void)
 
 	for_each_hstate(h) {
 		/* oversize hugepages were init'ed in early boot */
-		if (h->order < MAX_ORDER)
+		if (!hstate_is_gigantic(h))
 			hugetlb_hstate_alloc_pages(h);
 	}
 }
@@ -1414,7 +1414,7 @@ static void try_to_free_low(struct hstate *h, unsigned long count,
 {
 	int i;
 
-	if (h->order >= MAX_ORDER)
+	if (hstate_is_gigantic(h))
 		return;
 
 	for_each_node_mask(i, *nodes_allowed) {
@@ -1477,7 +1477,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 {
 	unsigned long min_count, ret;
 
-	if (h->order >= MAX_ORDER)
+	if (hstate_is_gigantic(h))
 		return h->max_huge_pages;
 
 	/*
@@ -1604,7 +1604,7 @@ static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
 		goto out;
 
 	h = kobj_to_hstate(kobj, &nid);
-	if (h->order >= MAX_ORDER) {
+	if (hstate_is_gigantic(h)) {
 		err = -EINVAL;
 		goto out;
 	}
@@ -1687,7 +1687,7 @@ static ssize_t nr_overcommit_hugepages_store(struct kobject *kobj,
 	unsigned long input;
 	struct hstate *h = kobj_to_hstate(kobj, NULL);
 
-	if (h->order >= MAX_ORDER)
+	if (hstate_is_gigantic(h))
 		return -EINVAL;
 
 	err = kstrtoul(buf, 10, &input);
@@ -2112,7 +2112,7 @@ static int hugetlb_sysctl_handler_common(bool obey_mempolicy,
 
 	tmp = h->max_huge_pages;
 
-	if (write && h->order >= MAX_ORDER)
+	if (write && hstate_is_gigantic(h))
 		return -EINVAL;
 
 	table->data = &tmp;
@@ -2165,7 +2165,7 @@ int hugetlb_overcommit_handler(struct ctl_table *table, int write,
 
 	tmp = h->nr_overcommit_huge_pages;
 
-	if (write && h->order >= MAX_ORDER)
+	if (write && hstate_is_gigantic(h))
 		return -EINVAL;
 
 	table->data = &tmp;
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
