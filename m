Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 936386B0260
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 04:00:02 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 55so944742wrx.21
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 01:00:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 93si1325806edm.421.2017.12.13.01.00.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Dec 2017 01:00:00 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 7/8] mm, compaction: prescan all MIGRATE_MOVABLE pageblocks
Date: Wed, 13 Dec 2017 09:59:14 +0100
Message-Id: <20171213085915.9278-8-vbabka@suse.cz>
In-Reply-To: <20171213085915.9278-1-vbabka@suse.cz>
References: <20171213085915.9278-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

The migration scanner for direct compaction now prescans MIGRATE_MOVABLE blocks
for MIGRATE_MOVABLE allocations and skips those where it appears that there are
unmovable pages that can prevent forming the high-order free page.

We can extend this strategy to !MIGRATE_MOVABLE allocations scanning
MIGRATE_MOVABLE blocks, in orde to prevent wasteful migrations. The difference
is that for these kind of allocations we want to migrate all pages from the
pageblock to prevent future allocations falling back to different movable
blocks. This patch thus adds a prescanning mode for that goal.

For other types of pageblocks we still scan and migrate everything we can to
make room for further allocations of the same migratetype.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 35 ++++++++++++++++++++++++++---------
 1 file changed, 26 insertions(+), 9 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 99c34a903688..3e6a37162d77 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -750,12 +750,16 @@ check_isolate_candidate(struct page *page, unsigned long *pfn,
  * block, so that actual isolation can begin from there, or end_pfn if no such
  * block was found.
  *
+ * When skip_on_failure is false, we want to know whether there is a suitable
+ * cc->order aligned block, but then we migrate all other pages in the
+ * pageblock as well. So we return the starting pfn unchanged.
+ *
  * The highest prescanned page is stored in cc->prescan_pfn.
  */
 static unsigned long
 prescan_migratepages_block(unsigned long prescan_pfn, unsigned long end_pfn,
 		struct compact_control *cc, struct page *valid_page,
-		bool *skipped_pages)
+		bool *skipped_pages, bool skip_on_failure)
 {
 	bool prescan_found = false;
 	unsigned long scan_start_pfn = prescan_pfn;
@@ -779,7 +783,8 @@ prescan_migratepages_block(unsigned long prescan_pfn, unsigned long end_pfn,
 			 * make sure the proper scan skips the former.
 			 */
 			next_skip_pfn = block_end_pfn(prescan_pfn, cc->order);
-			scan_start_pfn = prescan_pfn;
+			if (skip_on_failure)
+				scan_start_pfn = prescan_pfn;
 		}
 
 		if (!(prescan_pfn % SWAP_CLUSTER_MAX))
@@ -800,7 +805,7 @@ prescan_migratepages_block(unsigned long prescan_pfn, unsigned long end_pfn,
 			 * if we have only seen free pages so far, update the
 			 * proper scanner's starting pfn to skip over them.
 			 */
-			if (!prescan_found)
+			if (!prescan_found && skip_on_failure)
 				scan_start_pfn = prescan_pfn;
 			continue;
 		}
@@ -822,10 +827,14 @@ prescan_migratepages_block(unsigned long prescan_pfn, unsigned long end_pfn,
 		}
 	}
 
-	cc->prescan_pfn = min(prescan_pfn, end_pfn);
 	if (nr_prescanned)
 		count_compact_events(COMPACTMIGRATE_PRESCANNED, nr_prescanned);
 
+	if (!skip_on_failure && prescan_pfn < end_pfn)
+		cc->prescan_pfn = end_pfn;
+	else
+		cc->prescan_pfn = min(prescan_pfn, end_pfn);
+
 	return scan_start_pfn;
 }
 
@@ -889,14 +898,22 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	 * If we are skipping blocks where isolation has failed, we also don't
 	 * attempt to isolate, until we prescan the whole cc->order block ahead
 	 * to check that it contains only pages that can be isolated (or free).
+	 *
+	 * For !MIGRATE_MOVABLE allocations we don't skip on failure, because
+	 * we want to migrate away everything to make space for future
+	 * allocations of the same type so that they don't have to fallback.
+	 * But we still don't isolate for migration in a movable pageblock where
+	 * we are not likely to succeed. So we also prescan it first.
 	 */
 	if (cc->direct_compaction && !cc->finishing_block) {
 		pageblock_mt = get_pageblock_migratetype(valid_page);
-		if (pageblock_mt == MIGRATE_MOVABLE
-		    && cc->migratetype == MIGRATE_MOVABLE) {
+		if (pageblock_mt == MIGRATE_MOVABLE) {
 			prescan_block = true;
-			skip_on_failure = true;
-			next_skip_pfn = block_end_pfn(low_pfn, cc->order);
+
+			if (cc->migratetype == MIGRATE_MOVABLE) {
+				skip_on_failure = true;
+				next_skip_pfn = block_end_pfn(low_pfn, cc->order);
+			}
 		}
 	}
 
@@ -907,7 +924,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	 */
 	if (prescan_block && cc->prescan_pfn < next_skip_pfn) {
 		low_pfn = prescan_migratepages_block(low_pfn, end_pfn, cc,
-						valid_page, &skipped_pages);
+				valid_page, &skipped_pages, skip_on_failure);
 		if (skip_on_failure)
 			next_skip_pfn = block_end_pfn(low_pfn, cc->order);
 	}
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
