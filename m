Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id B32206B0010
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 17:21:29 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id v134so3901772ith.1
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 14:21:29 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id v1si4390475iob.113.2018.02.12.14.21.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Feb 2018 14:21:28 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 3/3] mm/hugetlb: use find_alloc_contig_pages() to allocate gigantic pages
Date: Mon, 12 Feb 2018 14:20:56 -0800
Message-Id: <20180212222056.9735-4-mike.kravetz@oracle.com>
In-Reply-To: <20180212222056.9735-1-mike.kravetz@oracle.com>
References: <20180212222056.9735-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>

Use the new find_alloc_contig_pages() interface for the allocation of
gigantic pages.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 88 +++++-------------------------------------------------------
 1 file changed, 6 insertions(+), 82 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 9a334f5fb730..4c0c4f86dcda 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1060,92 +1060,16 @@ static void destroy_compound_gigantic_page(struct page *page,
 	__ClearPageHead(page);
 }
 
-static void free_gigantic_page(struct page *page, unsigned int order)
+static void free_gigantic_page(struct page *page, struct hstate *h)
 {
-	free_contig_range(page_to_pfn(page), 1 << order);
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
+	free_contig_pages(page, pages_per_huge_page(h));
 }
 
 static struct page *alloc_gigantic_page(int nid, struct hstate *h)
 {
-	unsigned int order = huge_page_order(h);
-	unsigned long nr_pages = 1 << order;
-	unsigned long ret, pfn, flags;
-	struct zonelist *zonelist;
-	struct zone *zone;
-	struct zoneref *z;
-	gfp_t gfp_mask;
-
-	gfp_mask = htlb_alloc_mask(h) | __GFP_THISNODE;
-	zonelist = node_zonelist(nid, gfp_mask);
-	for_each_zone_zonelist_nodemask(zone, z, zonelist, gfp_zone(gfp_mask), NULL) {
-		spin_lock_irqsave(&zone->lock, flags);
+	gfp_t gfp_mask = htlb_alloc_mask(h) | __GFP_THISNODE;
 
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
+	return find_alloc_contig_pages(huge_page_order(h), gfp_mask, nid, NULL);
 }
 
 static void prep_new_huge_page(struct hstate *h, struct page *page, int nid);
@@ -1181,7 +1105,7 @@ static int alloc_fresh_gigantic_page(struct hstate *h,
 
 #else /* !CONFIG_ARCH_HAS_GIGANTIC_PAGE */
 static inline bool gigantic_page_supported(void) { return false; }
-static inline void free_gigantic_page(struct page *page, unsigned int order) { }
+static void free_gigantic_page(struct page *page, struct hstate *h) { }
 static inline void destroy_compound_gigantic_page(struct page *page,
 						unsigned int order) { }
 static inline int alloc_fresh_gigantic_page(struct hstate *h,
@@ -1208,7 +1132,7 @@ static void update_and_free_page(struct hstate *h, struct page *page)
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
