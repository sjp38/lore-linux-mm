Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 39FB56B0320
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 04:32:32 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id a13so452761pgt.0
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 01:32:32 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 71sor181171plb.75.2018.01.03.01.32.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jan 2018 01:32:30 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/6] mm, hugetlb: integrate giga hugetlb more naturally to the allocation path
Date: Wed,  3 Jan 2018 10:32:09 +0100
Message-Id: <20180103093213.26329-3-mhocko@kernel.org>
In-Reply-To: <20180103093213.26329-1-mhocko@kernel.org>
References: <20180103093213.26329-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Gigantic hugetlb pages were ingrown to the hugetlb code as an alien
specie with a lot of special casing. The allocation path is not an
exception. Unnecessarily so to be honest. It is true that the underlying
allocator is different but that is an implementation detail.

This patch unifies the hugetlb allocation path that a prepares fresh
pool pages. alloc_fresh_gigantic_page basically copies alloc_fresh_huge_page
logic so we can move everything there. This will simplify set_max_huge_pages
which doesn't have to care about what kind of huge page we allocate.

Changes since RFC
- compile fix for !CONFIG_ARCH_HAS_GIGANTIC_PAGE

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/hugetlb.c | 55 ++++++++++++++-----------------------------------------
 1 file changed, 14 insertions(+), 41 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index a8959667f539..360765156c7c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1106,7 +1106,8 @@ static bool zone_spans_last_pfn(const struct zone *zone,
 	return zone_spans_pfn(zone, last_pfn);
 }
 
-static struct page *alloc_gigantic_page(int nid, struct hstate *h)
+static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
+		int nid, nodemask_t *nodemask)
 {
 	unsigned int order = huge_page_order(h);
 	unsigned long nr_pages = 1 << order;
@@ -1114,11 +1115,9 @@ static struct page *alloc_gigantic_page(int nid, struct hstate *h)
 	struct zonelist *zonelist;
 	struct zone *zone;
 	struct zoneref *z;
-	gfp_t gfp_mask;
 
-	gfp_mask = htlb_alloc_mask(h) | __GFP_THISNODE;
 	zonelist = node_zonelist(nid, gfp_mask);
-	for_each_zone_zonelist_nodemask(zone, z, zonelist, gfp_zone(gfp_mask), NULL) {
+	for_each_zone_zonelist_nodemask(zone, z, zonelist, gfp_zone(gfp_mask), nodemask) {
 		spin_lock_irqsave(&zone->lock, flags);
 
 		pfn = ALIGN(zone->zone_start_pfn, nr_pages);
@@ -1149,42 +1148,13 @@ static struct page *alloc_gigantic_page(int nid, struct hstate *h)
 static void prep_new_huge_page(struct hstate *h, struct page *page, int nid);
 static void prep_compound_gigantic_page(struct page *page, unsigned int order);
 
-static struct page *alloc_fresh_gigantic_page_node(struct hstate *h, int nid)
-{
-	struct page *page;
-
-	page = alloc_gigantic_page(nid, h);
-	if (page) {
-		prep_compound_gigantic_page(page, huge_page_order(h));
-		prep_new_huge_page(h, page, nid);
-		put_page(page); /* free it into the hugepage allocator */
-	}
-
-	return page;
-}
-
-static int alloc_fresh_gigantic_page(struct hstate *h,
-				nodemask_t *nodes_allowed)
-{
-	struct page *page = NULL;
-	int nr_nodes, node;
-
-	for_each_node_mask_to_alloc(h, nr_nodes, node, nodes_allowed) {
-		page = alloc_fresh_gigantic_page_node(h, node);
-		if (page)
-			return 1;
-	}
-
-	return 0;
-}
-
 #else /* !CONFIG_ARCH_HAS_GIGANTIC_PAGE */
 static inline bool gigantic_page_supported(void) { return false; }
+static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
+		int nid, nodemask_t *nodemask) { return NULL; }
 static inline void free_gigantic_page(struct page *page, unsigned int order) { }
 static inline void destroy_compound_gigantic_page(struct page *page,
 						unsigned int order) { }
-static inline int alloc_fresh_gigantic_page(struct hstate *h,
-					nodemask_t *nodes_allowed) { return 0; }
 #endif
 
 static void update_and_free_page(struct hstate *h, struct page *page)
@@ -1410,8 +1380,12 @@ static int alloc_fresh_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
 	gfp_t gfp_mask = htlb_alloc_mask(h) | __GFP_THISNODE;
 
 	for_each_node_mask_to_alloc(h, nr_nodes, node, nodes_allowed) {
-		page = __hugetlb_alloc_buddy_huge_page(h, gfp_mask,
-				node, nodes_allowed);
+		if (hstate_is_gigantic(h))
+			page = alloc_gigantic_page(h, gfp_mask,
+					node, nodes_allowed);
+		else
+			page = __hugetlb_alloc_buddy_huge_page(h, gfp_mask,
+					node, nodes_allowed);
 		if (page)
 			break;
 
@@ -1420,6 +1394,8 @@ static int alloc_fresh_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
 	if (!page)
 		return 0;
 
+	if (hstate_is_gigantic(h))
+		prep_compound_gigantic_page(page, huge_page_order(h));
 	prep_new_huge_page(h, page, page_to_nid(page));
 	put_page(page); /* free it into the hugepage allocator */
 
@@ -2307,10 +2283,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 		/* yield cpu to avoid soft lockup */
 		cond_resched();
 
-		if (hstate_is_gigantic(h))
-			ret = alloc_fresh_gigantic_page(h, nodes_allowed);
-		else
-			ret = alloc_fresh_huge_page(h, nodes_allowed);
+		ret = alloc_fresh_huge_page(h, nodes_allowed);
 		spin_lock(&hugetlb_lock);
 		if (!ret)
 			goto out;
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
