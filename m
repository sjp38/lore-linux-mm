Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id D9DFE6B0009
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 22:09:36 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id v195-v6so9287850ita.1
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 19:09:36 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id n124si2988657ion.224.2018.04.16.19.09.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 19:09:35 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 3/3] mm/hugetlb: use find_alloc_contig_pages() to allocate gigantic pages
Date: Mon, 16 Apr 2018 19:09:15 -0700
Message-Id: <20180417020915.11786-4-mike.kravetz@oracle.com>
In-Reply-To: <20180417020915.11786-1-mike.kravetz@oracle.com>
References: <20180417020915.11786-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Reinette Chatre <reinette.chatre@intel.com>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

Use the new find_alloc_contig_pages() interface for the allocation of
gigantic pages and remove associated code in hugetlb.c.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 87 +++++-------------------------------------------------------
 1 file changed, 6 insertions(+), 81 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c81072ce7510..a209767cb808 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1053,91 +1053,16 @@ static void destroy_compound_gigantic_page(struct page *page,
 	__ClearPageHead(page);
 }
 
-static void free_gigantic_page(struct page *page, unsigned int order)
+static void free_gigantic_page(struct page *page, struct hstate *h)
 {
-	free_contig_range(page_to_pfn(page), 1UL << order);
-}
-
-static int __alloc_gigantic_page(unsigned long start_pfn,
-				unsigned long nr_pages, gfp_t gfp_mask)
-{
-	unsigned long end_pfn = start_pfn + nr_pages;
-	return alloc_contig_range(start_pfn, end_pfn, MIGRATE_MOVABLE,
-				  gfp_mask);
-}
-
-static bool pfn_range_valid_gigantic(struct zone *z,
-			unsigned long start_pfn, unsigned long nr_pages)
-{
-	unsigned long i, end_pfn = start_pfn + nr_pages;
-	struct page *page;
-
-	for (i = start_pfn; i < end_pfn; i++) {
-		if (!pfn_valid(i))
-			return false;
-
-		page = pfn_to_page(i);
-
-		if (page_zone(page) != z)
-			return false;
-
-		if (PageReserved(page))
-			return false;
-
-		if (page_count(page) > 0)
-			return false;
-
-		if (PageHuge(page))
-			return false;
-	}
-
-	return true;
-}
-
-static bool zone_spans_last_pfn(const struct zone *zone,
-			unsigned long start_pfn, unsigned long nr_pages)
-{
-	unsigned long last_pfn = start_pfn + nr_pages - 1;
-	return zone_spans_pfn(zone, last_pfn);
+	free_contig_pages(page, (unsigned long)pages_per_huge_page(h));
 }
 
 static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
 		int nid, nodemask_t *nodemask)
 {
-	unsigned int order = huge_page_order(h);
-	unsigned long nr_pages = 1 << order;
-	unsigned long ret, pfn, flags;
-	struct zonelist *zonelist;
-	struct zone *zone;
-	struct zoneref *z;
-
-	zonelist = node_zonelist(nid, gfp_mask);
-	for_each_zone_zonelist_nodemask(zone, z, zonelist, gfp_zone(gfp_mask), nodemask) {
-		spin_lock_irqsave(&zone->lock, flags);
-
-		pfn = ALIGN(zone->zone_start_pfn, nr_pages);
-		while (zone_spans_last_pfn(zone, pfn, nr_pages)) {
-			if (pfn_range_valid_gigantic(zone, pfn, nr_pages)) {
-				/*
-				 * We release the zone lock here because
-				 * alloc_contig_range() will also lock the zone
-				 * at some point. If there's an allocation
-				 * spinning on this lock, it may win the race
-				 * and cause alloc_contig_range() to fail...
-				 */
-				spin_unlock_irqrestore(&zone->lock, flags);
-				ret = __alloc_gigantic_page(pfn, nr_pages, gfp_mask);
-				if (!ret)
-					return pfn_to_page(pfn);
-				spin_lock_irqsave(&zone->lock, flags);
-			}
-			pfn += nr_pages;
-		}
-
-		spin_unlock_irqrestore(&zone->lock, flags);
-	}
-
-	return NULL;
+	return find_alloc_contig_pages(huge_page_order(h), gfp_mask, nid,
+					nodemask);
 }
 
 static void prep_new_huge_page(struct hstate *h, struct page *page, int nid);
@@ -1147,7 +1072,7 @@ static void prep_compound_gigantic_page(struct page *page, unsigned int order);
 static inline bool gigantic_page_supported(void) { return false; }
 static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
 		int nid, nodemask_t *nodemask) { return NULL; }
-static inline void free_gigantic_page(struct page *page, unsigned int order) { }
+static inline void free_gigantic_page(struct page *page, struct hstate *h) { }
 static inline void destroy_compound_gigantic_page(struct page *page,
 						unsigned int order) { }
 #endif
@@ -1172,7 +1097,7 @@ static void update_and_free_page(struct hstate *h, struct page *page)
 	set_page_refcounted(page);
 	if (hstate_is_gigantic(h)) {
 		destroy_compound_gigantic_page(page, huge_page_order(h));
-		free_gigantic_page(page, huge_page_order(h));
+		free_gigantic_page(page, h);
 	} else {
 		__free_pages(page, huge_page_order(h));
 	}
-- 
2.13.6
