Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id CB12B6B025F
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 04:00:02 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id p190so905183wmd.0
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 01:00:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v21si1486905edb.428.2017.12.13.01.00.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Dec 2017 01:00:00 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 4/8] mm, compaction: skip on isolation failure also in sync compaction
Date: Wed, 13 Dec 2017 09:59:11 +0100
Message-Id: <20171213085915.9278-5-vbabka@suse.cz>
In-Reply-To: <20171213085915.9278-1-vbabka@suse.cz>
References: <20171213085915.9278-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

When scanning for async direct compaction for movable allocation, migration
scanner skips all pages of an order-aligned block once a page fails isolation,
because a single page is enough to prevent forming a free page of given order.
The same is true for sync compaction, so extend the heuristic to there as well.

But make sure we don't skip inside !MOVABLE pageblocks, where we generally want
to migrate all movable pages away from them to prevent non-movable allocations
falling back to more movable blocks before using up all non-movable blocks for
non-movable allocations. Until now this goal relied on async direct compaction
for movable allocation scanning only movable pageblocks, and sync direct
compaction to not skip at all.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 00dc46343093..4f93a7307fb5 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -703,6 +703,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	unsigned long start_pfn = low_pfn;
 	bool skip_on_failure = false, skipped_pages = false;
 	unsigned long next_skip_pfn = 0;
+	int pageblock_mt;
 
 	/*
 	 * Ensure that there are not too many pages isolated from the LRU
@@ -723,10 +724,13 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	if (compact_should_abort(cc))
 		return 0;
 
-	if (cc->direct_compaction && (cc->mode == MIGRATE_ASYNC) &&
-			cc->migratetype == MIGRATE_MOVABLE) {
-		skip_on_failure = true;
-		next_skip_pfn = block_end_pfn(low_pfn, cc->order);
+	if (cc->direct_compaction && !cc->finishing_block) {
+		pageblock_mt = get_pageblock_migratetype(valid_page);
+		if (pageblock_mt == MIGRATE_MOVABLE
+		    && cc->migratetype == MIGRATE_MOVABLE) {
+			skip_on_failure = true;
+			next_skip_pfn = block_end_pfn(low_pfn, cc->order);
+		}
 	}
 
 	/* Time to isolate some pages for migration */
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
