Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A99FD6B002D
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 11:21:27 -0500 (EST)
Date: Fri, 11 Nov 2011 16:21:19 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: Reduce the amount of work done when updating
 min_free_kbytes
Message-ID: <20111111162119.GP3083@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

When min_free_kbytes is updated, some pageblocks are marked MIGRATE_RESERVE.
Ordinarily, this work is unnoticable as it happens early in boot but on
large machines with 1TB of memory, this has been reported to delay
boot times, probably due to the NUMA distances involved.

The bulk of the work is due to calling calling pageblock_is_reserved()
an unnecessary amount of times and accessing far more struct page
metadata than is necessary. This patch significantly reduces the
amount of work done by setup_zone_migrate_reserve() improving boot
times on 1TB machines.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c |   35 +++++++++++++++++++----------------
 1 files changed, 19 insertions(+), 16 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9dd443d..c95e4c9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3401,25 +3401,28 @@ static void setup_zone_migrate_reserve(struct zone *zone)
 		if (page_to_nid(page) != zone_to_nid(zone))
 			continue;
 
-		/* Blocks with reserved pages will never free, skip them. */
-		block_end_pfn = min(pfn + pageblock_nr_pages, end_pfn);
-		if (pageblock_is_reserved(pfn, block_end_pfn))
-			continue;
-
 		block_migratetype = get_pageblock_migratetype(page);
 
-		/* If this block is reserved, account for it */
-		if (reserve > 0 && block_migratetype == MIGRATE_RESERVE) {
-			reserve--;
-			continue;
-		}
+		/* Only test what is necessary when the reserves are not met */
+		if (reserve > 0) {
+			/* Blocks with reserved pages will never free, skip them. */
+			block_end_pfn = min(pfn + pageblock_nr_pages, end_pfn);
+			if (pageblock_is_reserved(pfn, block_end_pfn))
+				continue;
 
-		/* Suitable for reserving if this block is movable */
-		if (reserve > 0 && block_migratetype == MIGRATE_MOVABLE) {
-			set_pageblock_migratetype(page, MIGRATE_RESERVE);
-			move_freepages_block(zone, page, MIGRATE_RESERVE);
-			reserve--;
-			continue;
+			/* If this block is reserved, account for it */
+			if (block_migratetype == MIGRATE_RESERVE) {
+				reserve--;
+				continue;
+			}
+
+			/* Suitable for reserving if this block is movable */
+			if (block_migratetype == MIGRATE_MOVABLE) {
+				set_pageblock_migratetype(page, MIGRATE_RESERVE);
+				move_freepages_block(zone, page, MIGRATE_RESERVE);
+				reserve--;
+				continue;
+			}
 		}
 
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
