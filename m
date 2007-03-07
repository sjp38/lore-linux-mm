Date: Wed, 7 Mar 2007 21:13:59 +0000
Subject: [PATCH] 2.6.21-rc2-mm2 Fix boot problem on IA64 with CONFIG_HOLE_IN_ZONES and CONFIG_PAGE_GROUP_BY_MOBILITY
Message-ID: <20070307211359.GA6736@skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, clameter@engr.sgi.com
List-ID: <linux-mm.kvack.org>

Usually, a mem_map is aligned on MAX_ORDER_NR_PAGES boundaries and the
struct pages are always valid. However, this is not always the case when
CONFIG_HOLES_IN_ZONE is set.

move_freepages_block() checks that pages within a MAX_ORDER_NR_PAGES block
are in the same zone using page_zone(). However, if an invalid page is
passed to page_zone(), it can result in breakage on machines requiring
CONFIG_HOLES_IN_ZONE. This patch avoids the use of page_zone() and instead
checks the PFNs against the PFN ranges of the zone.  This fixes a boot
problem on IA64 using the config arch/ia64/configs/sn2_defconfig .

Credit to Christoph Lameter for testing, reporting the bug and verifying
this fixes the problem. Credit to Andy Whitcroft for giving the patch a
quick review to ensure no functionality was changed.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc2-mm2-clean/mm/page_alloc.c linux-2.6.21-rc2-mm2-ia64_movefreepages_fix/mm/page_alloc.c
--- linux-2.6.21-rc2-mm2-clean/mm/page_alloc.c	2007-03-07 09:36:31.000000000 +0000
+++ linux-2.6.21-rc2-mm2-ia64_movefreepages_fix/mm/page_alloc.c	2007-03-07 14:17:43.000000000 +0000
@@ -734,18 +734,19 @@ int move_freepages(struct zone *zone,
 
 int move_freepages_block(struct zone *zone, struct page *page, int migratetype)
 {
-	unsigned long start_pfn;
+	unsigned long start_pfn, end_pfn;
 	struct page *start_page, *end_page;
 
 	start_pfn = page_to_pfn(page);
 	start_pfn = start_pfn & ~(MAX_ORDER_NR_PAGES-1);
 	start_page = pfn_to_page(start_pfn);
 	end_page = start_page + MAX_ORDER_NR_PAGES;
+	end_pfn = start_pfn + MAX_ORDER_NR_PAGES;
 
 	/* Do not cross zone boundaries */
-	if (page_zone(page) != page_zone(start_page))
+	if (start_pfn < zone->zone_start_pfn)
 		start_page = page;
-	if (page_zone(page) != page_zone(end_page))
+	if (end_pfn >= zone->zone_start_pfn + zone->spanned_pages)
 		return 0;
 
 	return move_freepages(zone, start_page, end_page, migratetype);
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
