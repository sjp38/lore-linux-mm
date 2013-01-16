Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 1B8A96B0083
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:26:45 -0500 (EST)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 15 Jan 2013 17:26:44 -0700
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id A50AA19D806C
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 17:25:48 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0G0Pl90219962
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 17:25:48 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0G0PkxL031447
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 17:25:47 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 09/17] mm/page_alloc: use zone_end_pfn() & zone_spans_pfn()
Date: Tue, 15 Jan 2013 16:24:46 -0800
Message-Id: <1358295894-24167-10-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Cody P Schafer <jmesmon@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

From: Cody P Schafer <jmesmon@gmail.com>

Change several open coded zone_end_pfn()s and a zone_spans_pfn() in the
page allocator to use the provided helper functions.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c5d70ce..f8ed277 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1272,7 +1272,7 @@ void mark_free_pages(struct zone *zone)
 
 	spin_lock_irqsave(&zone->lock, flags);
 
-	max_zone_pfn = zone->zone_start_pfn + zone->spanned_pages;
+	max_zone_pfn = zone_end_pfn(zone);
 	for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++)
 		if (pfn_valid(pfn)) {
 			struct page *page = pfn_to_page(pfn);
@@ -3775,7 +3775,7 @@ static void setup_zone_migrate_reserve(struct zone *zone)
 	 * the block.
 	 */
 	start_pfn = zone->zone_start_pfn;
-	end_pfn = start_pfn + zone->spanned_pages;
+	end_pfn = zone_end_pfn(zone);
 	start_pfn = roundup(start_pfn, pageblock_nr_pages);
 	reserve = roundup(min_wmark_pages(zone), pageblock_nr_pages) >>
 							pageblock_order;
@@ -3889,7 +3889,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		 * pfn out of zone.
 		 */
 		if ((z->zone_start_pfn <= pfn)
-		    && (pfn < z->zone_start_pfn + z->spanned_pages)
+		    && (pfn < zone_end_pfn(z))
 		    && !(pfn & (pageblock_nr_pages - 1)))
 			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
 
@@ -4617,7 +4617,7 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
 		 * for the buddy allocator to function correctly.
 		 */
 		start = pgdat->node_start_pfn & ~(MAX_ORDER_NR_PAGES - 1);
-		end = pgdat->node_start_pfn + pgdat->node_spanned_pages;
+		end = pgdat_end_pfn(pgdat);
 		end = ALIGN(end, MAX_ORDER_NR_PAGES);
 		size =  (end - start) * sizeof(struct page);
 		map = alloc_remap(pgdat->node_id, size);
@@ -5735,8 +5735,7 @@ bool is_pageblock_removable_nolock(struct page *page)
 
 	zone = page_zone(page);
 	pfn = page_to_pfn(page);
-	if (zone->zone_start_pfn > pfn ||
-			zone->zone_start_pfn + zone->spanned_pages <= pfn)
+	if (!zone_spans_pfn(zone, pfn))
 		return false;
 
 	return !has_unmovable_pages(zone, page, 0, true);
-- 
1.8.0.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
