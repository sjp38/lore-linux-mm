Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 36FD26B0038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 03:11:04 -0500 (EST)
Received: by wmww144 with SMTP id w144so10188895wmw.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 00:11:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k18si9807449wjw.112.2015.12.03.00.11.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 03 Dec 2015 00:11:02 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 2/3] mm, compaction: make async direct compaction skip blocks where isolation fails
Date: Thu,  3 Dec 2015 09:10:46 +0100
Message-Id: <1449130247-8040-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1449130247-8040-1-git-send-email-vbabka@suse.cz>
References: <1449130247-8040-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Aaron Lu <aaron.lu@intel.com>
Cc: linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

The goal of direct compaction is to quickly make a high-order page available.
Within an aligned block of pages of desired order, a single allocated page that
cannot be isolated for migration means that the block cannot fulfill the
allocation request. Therefore we can reduce the latency by skipping such blocks
immediately on isolation failures.  For async compaction, this also means a
higher chance of succeeding until it becomes contended.

We however shouldn't completely sacrifice the second objective of compaction,
which is to reduce overal long-term memory fragmentation. As a compromise,
perform the eager skipping only in direct async compaction, while sync
compaction remains thorough.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 55 ++++++++++++++++++++++++++++++++++++++++++++++++-------
 mm/internal.h   |  1 +
 2 files changed, 49 insertions(+), 7 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 9c14d10ad3e5..f94518b5b1c9 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -672,6 +672,8 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	bool locked = false;
 	struct page *page = NULL, *valid_page = NULL;
 	unsigned long start_pfn = low_pfn;
+	bool skip_on_failure = false;
+	unsigned long next_skip_pfn = 0;
 
 	/*
 	 * Ensure that there are not too many pages isolated from the LRU
@@ -692,10 +694,24 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	if (compact_should_abort(cc))
 		return 0;
 
+	if (cc->direct_compaction && (cc->mode == MIGRATE_ASYNC))
+		skip_on_failure = true;
+
 	/* Time to isolate some pages for migration */
 	for (; low_pfn < end_pfn; low_pfn++) {
 		bool is_lru;
 
+		if (skip_on_failure && low_pfn >= next_skip_pfn) {
+			if (nr_isolated)
+				break;
+			/*
+			 * low_pfn might have been incremented by arbitrary
+			 * number due to skipping a compound or a high-order
+			 * buddy page in the previous iteration
+			 */
+			next_skip_pfn = ALIGN(low_pfn + 1, (1UL << cc->order));
+		}
+
 		/*
 		 * Periodically drop the lock (if held) regardless of its
 		 * contention, to give chance to IRQs. Abort async compaction
@@ -707,7 +723,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			break;
 
 		if (!pfn_valid_within(low_pfn))
-			continue;
+			goto isolate_fail;
 		nr_scanned++;
 
 		page = pfn_to_page(low_pfn);
@@ -762,11 +778,11 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
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
@@ -775,7 +791,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		 */
 		if (!page_mapping(page) &&
 		    page_count(page) > page_mapcount(page))
-			continue;
+			goto isolate_fail;
 
 		/* If we already hold the lock, we can skip some rechecking */
 		if (!locked) {
@@ -786,7 +802,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 			/* Recheck PageLRU and PageCompound under lock */
 			if (!PageLRU(page))
-				continue;
+				goto isolate_fail;
 
 			/*
 			 * Page become compound since the non-locked check,
@@ -795,7 +811,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			 */
 			if (unlikely(PageCompound(page))) {
 				low_pfn += (1UL << compound_order(page)) - 1;
-				continue;
+				goto isolate_fail;
 			}
 		}
 
@@ -803,7 +819,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 		/* Try isolate the page */
 		if (__isolate_lru_page(page, isolate_mode) != 0)
-			continue;
+			goto isolate_fail;
 
 		VM_BUG_ON_PAGE(PageCompound(page), page);
 
@@ -829,6 +845,30 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			++low_pfn;
 			break;
 		}
+
+		continue;
+isolate_fail:
+		if (!skip_on_failure)
+			continue;
+
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
@@ -1495,6 +1535,7 @@ static unsigned long compact_zone_order(struct zone *zone, int order,
 		.mode = mode,
 		.alloc_flags = alloc_flags,
 		.classzone_idx = classzone_idx,
+		.direct_compaction = true,
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
diff --git a/mm/internal.h b/mm/internal.h
index 38e24b89e4c4..079ba14afe55 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -205,6 +205,7 @@ struct compact_control {
 	unsigned long last_migrated_pfn;/* Not yet flushed page being freed */
 	enum migrate_mode mode;		/* Async or sync migration mode */
 	bool ignore_skip_hint;		/* Scan blocks even if marked skip */
+	bool direct_compaction;		/* Low latency over thoroughness */
 	int order;			/* order a direct compactor needs */
 	const gfp_t gfp_mask;		/* gfp mask of a direct compactor */
 	const int alloc_flags;		/* alloc flags of a direct compactor */
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
