Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id DEB6B6B01E2
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 01:49:56 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 3/7] hugetlb: add allocate function for hugepage migration
Date: Fri,  2 Jul 2010 14:47:22 +0900
Message-Id: <1278049646-29769-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1278049646-29769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1278049646-29769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

We can't use existing hugepage allocation functions to allocate hugepage
for page migration, because page migration can happen asynchronously with
the running processes and page migration users should call the allocation
function with physical addresses (not virtual addresses) as arguments.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
---
 include/linux/hugetlb.h |    3 ++
 mm/hugetlb.c            |   83 +++++++++++++++++++++++++++++++++++++---------
 2 files changed, 69 insertions(+), 17 deletions(-)

diff --git v2.6.35-rc3-hwpoison/include/linux/hugetlb.h v2.6.35-rc3-hwpoison/include/linux/hugetlb.h
index f479700..0b73c53 100644
--- v2.6.35-rc3-hwpoison/include/linux/hugetlb.h
+++ v2.6.35-rc3-hwpoison/include/linux/hugetlb.h
@@ -228,6 +228,8 @@ struct huge_bootmem_page {
 	struct hstate *hstate;
 };
 
+struct page *alloc_huge_page_node(struct hstate *h, int nid);
+
 /* arch callback */
 int __init alloc_bootmem_huge_page(struct hstate *h);
 
@@ -303,6 +305,7 @@ static inline struct hstate *page_hstate(struct page *page)
 
 #else
 struct hstate {};
+#define alloc_huge_page_node(h, nid) NULL
 #define alloc_bootmem_huge_page(h) NULL
 #define hstate_file(f) NULL
 #define hstate_vma(v) NULL
diff --git v2.6.35-rc3-hwpoison/mm/hugetlb.c v2.6.35-rc3-hwpoison/mm/hugetlb.c
index 5c77a73..d7c462b 100644
--- v2.6.35-rc3-hwpoison/mm/hugetlb.c
+++ v2.6.35-rc3-hwpoison/mm/hugetlb.c
@@ -466,6 +466,18 @@ static void enqueue_huge_page(struct hstate *h, struct page *page)
 	h->free_huge_pages_node[nid]++;
 }
 
+static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
+{
+	struct page *page;
+	if (list_empty(&h->hugepage_freelists[nid]))
+		return NULL;
+	page = list_entry(h->hugepage_freelists[nid].next, struct page, lru);
+	list_del(&page->lru);
+	h->free_huge_pages--;
+	h->free_huge_pages_node[nid]--;
+	return page;
+}
+
 static struct page *dequeue_huge_page_vma(struct hstate *h,
 				struct vm_area_struct *vma,
 				unsigned long address, int avoid_reserve)
@@ -497,18 +509,13 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 						MAX_NR_ZONES - 1, nodemask) {
 		nid = zone_to_nid(zone);
-		if (cpuset_zone_allowed_softwall(zone, htlb_alloc_mask) &&
-		    !list_empty(&h->hugepage_freelists[nid])) {
-			page = list_entry(h->hugepage_freelists[nid].next,
-					  struct page, lru);
-			list_del(&page->lru);
-			h->free_huge_pages--;
-			h->free_huge_pages_node[nid]--;
-
-			if (!avoid_reserve)
-				decrement_hugepage_resv_vma(h, vma);
-
-			break;
+		if (cpuset_zone_allowed_softwall(zone, htlb_alloc_mask)) {
+			page = dequeue_huge_page_node(h, nid);
+			if (page) {
+				if (!avoid_reserve)
+					decrement_hugepage_resv_vma(h, vma);
+				break;
+			}
 		}
 	}
 err:
@@ -616,7 +623,7 @@ int PageHuge(struct page *page)
 }
 EXPORT_SYMBOL_GPL(PageHuge);
 
-static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
+static struct page *__alloc_huge_page_node(struct hstate *h, int nid)
 {
 	struct page *page;
 
@@ -627,14 +634,56 @@ static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
 		htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|
 						__GFP_REPEAT|__GFP_NOWARN,
 		huge_page_order(h));
+	if (page && arch_prepare_hugepage(page)) {
+		__free_pages(page, huge_page_order(h));
+		return NULL;
+	}
+
+	return page;
+}
+
+static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
+{
+	struct page *page = __alloc_huge_page_node(h, nid);
+	if (page)
+		prep_new_huge_page(h, page, nid);
+	return page;
+}
+
+static struct page *alloc_buddy_huge_page_node(struct hstate *h, int nid)
+{
+	struct page *page = __alloc_huge_page_node(h, nid);
 	if (page) {
-		if (arch_prepare_hugepage(page)) {
-			__free_pages(page, huge_page_order(h));
+		set_compound_page_dtor(page, free_huge_page);
+		spin_lock(&hugetlb_lock);
+		h->nr_huge_pages++;
+		h->nr_huge_pages_node[nid]++;
+		spin_unlock(&hugetlb_lock);
+		put_page_testzero(page);
+	}
+	return page;
+}
+
+struct page *alloc_huge_page_node(struct hstate *h, int nid)
+{
+	struct page *page;
+
+	spin_lock(&hugetlb_lock);
+	get_mems_allowed();
+	page = dequeue_huge_page_node(h, nid);
+	put_mems_allowed();
+	spin_unlock(&hugetlb_lock);
+
+	if (!page) {
+		page = alloc_buddy_huge_page_node(h, nid);
+		if (!page) {
+			__count_vm_event(HTLB_BUDDY_PGALLOC_FAIL);
 			return NULL;
-		}
-		prep_new_huge_page(h, page, nid);
+		} else
+			__count_vm_event(HTLB_BUDDY_PGALLOC);
 	}
 
+	set_page_refcounted(page);
 	return page;
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
