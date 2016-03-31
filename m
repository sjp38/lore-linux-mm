Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 4ABE16B0253
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 04:51:03 -0400 (EDT)
Received: by mail-wm0-f49.google.com with SMTP id p65so215163419wmp.1
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 01:51:03 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gg9si10638084wjb.115.2016.03.31.01.51.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 31 Mar 2016 01:51:01 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 3/4] mm, compaction: skip blocks where isolation fails in async direct compaction
Date: Thu, 31 Mar 2016 10:50:35 +0200
Message-Id: <1459414236-9219-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1459414236-9219-1-git-send-email-vbabka@suse.cz>
References: <1459414236-9219-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

The goal of direct compaction is to quickly make a high-order page available
for the pending allocation. Within an aligned block of pages of desired order,
a single allocated page that cannot be isolated for migration means that the
block cannot fully merge to a buddy page that would satisfy the allocation
request. Therefore we can reduce the allocation stall by skipping the rest of
the block immediately on isolation failure. For async compaction, this also
means a higher chance of succeeding until it detects contention.

We however shouldn't completely sacrifice the second objective of compaction,
which is to reduce overal long-term memory fragmentation. As a compromise,
perform the eager skipping only in direct async compaction, while sync
compaction (including kcompactd) remains thorough.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 84 ++++++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 77 insertions(+), 7 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 74b4b775459e..fe94d22d9144 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -644,6 +644,8 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	bool locked = false;
 	struct page *page = NULL, *valid_page = NULL;
 	unsigned long start_pfn = low_pfn;
+	bool skip_on_failure = false;
+	unsigned long next_skip_pfn = 0;
 
 	/*
 	 * Ensure that there are not too many pages isolated from the LRU
@@ -664,10 +666,37 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	if (compact_should_abort(cc))
 		return 0;
 
+	if (cc->direct_compaction && (cc->mode == MIGRATE_ASYNC)) {
+		skip_on_failure = true;
+		next_skip_pfn = block_end_pfn(low_pfn, cc->order);
+	}
+
 	/* Time to isolate some pages for migration */
 	for (; low_pfn < end_pfn; low_pfn++) {
 		bool is_lru;
 
+		if (skip_on_failure && low_pfn >= next_skip_pfn) {
+			/*
+			 * We have isolated all migration candidates in the
+			 * previous order-aligned block, and did not skip it due
+			 * to failure. We should migrate the pages now and
+			 * hopefully succeed compaction.
+			 */
+			if (nr_isolated)
+				break;
+
+			/*
+			 * We failed to isolate in the previous order-aligned
+			 * block. Set the new boundary to the end of the
+			 * current block. Note we can't simply increase
+			 * next_skip_pfn by 1 << order, as low_pfn might have
+			 * been incremented by a higher number due to skipping
+			 * a compound or a high-order buddy page in the
+			 * previous loop iteration.
+			 */
+			next_skip_pfn = block_end_pfn(low_pfn, cc->order);
+		}
+
 		/*
 		 * Periodically drop the lock (if held) regardless of its
 		 * contention, to give chance to IRQs. Abort async compaction
@@ -679,7 +708,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			break;
 
 		if (!pfn_valid_within(low_pfn))
-			continue;
+			goto isolate_fail;
 		nr_scanned++;
 
 		page = pfn_to_page(low_pfn);
@@ -734,11 +763,11 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			if (likely(comp_order < MAX_ORDER))
 				low_pfn += (1UL << comp_order) - 1;
 
-			continue;
+			goto isolate_fail;
 		}
 
 		if (!is_lru)
-			continue;
+			goto isolate_fail;
 
 		/*
 		 * Migration will fail if an anonymous page is pinned in memory,
@@ -747,7 +776,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		 */
 		if (!page_mapping(page) &&
 		    page_count(page) > page_mapcount(page))
-			continue;
+			goto isolate_fail;
 
 		/* If we already hold the lock, we can skip some rechecking */
 		if (!locked) {
@@ -758,7 +787,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 			/* Recheck PageLRU and PageCompound under lock */
 			if (!PageLRU(page))
-				continue;
+				goto isolate_fail;
 
 			/*
 			 * Page become compound since the non-locked check,
@@ -767,7 +796,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			 */
 			if (unlikely(PageCompound(page))) {
 				low_pfn += (1UL << compound_order(page)) - 1;
-				continue;
+				goto isolate_fail;
 			}
 		}
 
@@ -775,7 +804,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 		/* Try isolate the page */
 		if (__isolate_lru_page(page, isolate_mode) != 0)
-			continue;
+			goto isolate_fail;
 
 		VM_BUG_ON_PAGE(PageCompound(page), page);
 
@@ -801,6 +830,35 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			++low_pfn;
 			break;
 		}
+
+		continue;
+isolate_fail:
+		if (!skip_on_failure)
+			continue;
+
+		/*
+		 * We have isolated some pages, but then failed. Release them
+		 * instead of migrating, as we cannot form the cc->order buddy
+		 * page anyway.
+		 */
+		if (nr_isolated) {
+			if (locked) {
+				spin_unlock_irqrestore(&zone->lru_lock,	flags);
+				locked = false;
+			}
+			putback_movable_pages(migratelist);
+			nr_isolated = 0;
+			cc->last_migrated_pfn = 0;
+		}
+
+		if (low_pfn < next_skip_pfn) {
+			low_pfn = next_skip_pfn - 1;
+			/*
+			 * The check near the loop beginning would have updated
+			 * next_skip_pfn too, but this is a bit simpler.
+			 */
+			next_skip_pfn += 1UL << cc->order;
+		}
 	}
 
 	/*
@@ -1409,6 +1467,18 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 				ret = COMPACT_CONTENDED;
 				goto out;
 			}
+			/*
+			 * We failed to migrate at least one page in the current
+			 * order-aligned block, so skip the rest of it.
+			 */
+			if (cc->direct_compaction &&
+						(cc->mode == MIGRATE_ASYNC)) {
+				cc->migrate_pfn = block_end_pfn(
+						cc->migrate_pfn - 1, cc->order);
+				/* Draining pcplists is useless in this case */
+				cc->last_migrated_pfn = 0;
+
+			}
 		}
 
 check_drain:
-- 
2.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
