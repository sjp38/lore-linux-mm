Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CA8606B0055
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 05:47:39 -0400 (EDT)
Date: Mon, 17 Aug 2009 10:47:44 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH] page-allocator: Limit the number of MIGRATE_RESERVE
	pageblocks per zone
Message-ID: <20090817094744.GA21306@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

After anti-fragmentation was merged, a bug was reported whereby devices that
depended on high-order atomic allocations were not failing. The solution
was to preserve a property in the buddy allocator which tended to keep the
minimum number of free pages in the zone at the lower physical addresses
and contiguous. To preserve this property, MIGRATE_RESERVE was introduced
and a number of pageblocks at the start of a zone would be marked "reserve",
the number of which depended on min_free_kbytes.

Anti-fragmentation works by avoiding the mixing of page migratetypes within
the same pageblock. One way of helping this is to increase min_free_kbytes
because it becomes less like that it will be necessary to place pages of
different migratetypes within the same pageblock. However, as the number
of MIGRATE_RESERVE is unbounded, the free memory is kept there in large
contiguous blocks instead of helping anti-fragmentation as much as it
should. With the page-allocator tracepoint patches applied, it was found
during anti-fragmentation tests that the number of fragmentation-related events
were far higher than expected even with min_free_kbytes at higher values.

This patch limits the number of MIGRATE_RESERVE blocks that exist per zone to
two. For example, with a sufficient min_free_kbytes, 4MB of memory will be
kept aside on an x86-64 and remain more or less free and contiguous for the
systems uptime. This should be sufficient for devices depending on high-order
atomic allocations while helping fragmentation control when min_free_kbytes
is tuned appropriately. As side-effect of this patch is that the reserve
variable is converted to int as unsigned long was the wrong type to use
when ensuring that only the required number of reserve blocks are created.

With the patches applied, fragmentation-related events as measured by the
page allocator tracepoints were significantly reduced when running some
fragmentation stress-tests on systems with min_free_kbytes tuned to a value
appropriate for hugepage allocations at runtime. On x86, the events recorded
were reduced by 99.8%, on x86-64 by 99.72% and on ppc64 by 99.83%.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
--- 
 mm/page_alloc.c |   12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index caa9268..61548d1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2768,7 +2768,8 @@ static void setup_zone_migrate_reserve(struct zone *zone)
 {
 	unsigned long start_pfn, pfn, end_pfn;
 	struct page *page;
-	unsigned long reserve, block_migratetype;
+	unsigned long block_migratetype;
+	int reserve;
 
 	/* Get the start pfn, end pfn and the number of blocks to reserve */
 	start_pfn = zone->zone_start_pfn;
@@ -2776,6 +2777,15 @@ static void setup_zone_migrate_reserve(struct zone *zone)
 	reserve = roundup(min_wmark_pages(zone), pageblock_nr_pages) >>
 							pageblock_order;
 
+	/*
+	 * Reserve blocks are generally in place to help high-order atomic
+	 * allocations that are short-lived. A min_free_kbytes value that
+	 * would result in more than 2 reserve blocks for atomic allocations
+	 * is assumed to be in place to help anti-fragmentation for the
+	 * future allocation of hugepages at runtime.
+	 */
+	reserve = min(2, reserve);
+
 	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
 		if (!pfn_valid(pfn))
 			continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
