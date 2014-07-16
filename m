Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1972C6B00A7
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 09:49:32 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id hi2so1367752wib.11
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 06:49:31 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p7si691564wic.43.2014.07.16.06.49.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 06:49:15 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH V4 15/15] mm, compaction: do not migrate pages when that cannot satisfy page fault allocation
Date: Wed, 16 Jul 2014 15:48:23 +0200
Message-Id: <1405518503-27687-16-git-send-email-vbabka@suse.cz>
In-Reply-To: <1405518503-27687-1-git-send-email-vbabka@suse.cz>
References: <1405518503-27687-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

In direct compaction for a page fault, we want to allocate the high-order page
as soon as possible, so migrating from a cc->order aligned block of pages that
contains also unmigratable pages just adds to page fault latency.

This patch therefore makes the migration scanner skip to the next cc->order
aligned block of pages as soon as it cannot isolate a non-free page. Everything
isolated up to that point is put back.

In this mode, the nr_isolated limit to COMPACT_CLUSTER_MAX is not observed,
allowing the scanner to scan the whole block at once, instead of migrating
COMPACT_CLUSTER_MAX pages and then finding an unmigratable page in the next
call. This might however have some implications on direct reclaimers through
too_many_isolated().

In tests with stress-highalloc benchmark where __GFP_NO_KSWAPD was not used
and therefore the patch did not affect the benchmark itself, but only the
kernel compilations occuring in parallel, this patch has increased allocation
success rates of the benchmark by a few percent, and pages scanned by
compaction by almost 20%. The compaction successes in vmstat increased by 16%
so this is probably due to more successes translating to less deferring.
The compaction successes (and attempts) did increase for other processes than
the benchmark, which would be explained by those processes faulting THP pages
with __GFP_NO_KSWAPD. However, THP faults in vmstat did not increase, so
there either some problem in that area, or the direct compactions were
triggered by different allocations.

In tests where __GFP_NO_KSWAPD was used by the benchmark, the allocation
success rates improved from 15% to 20% in the first phase, and from 19% to 33%
in the second phase. Again, the amount of work done increased due to less
deferring.

[rientjes@google.com: skip_on_failure based on THP page faults]
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 50 ++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 40 insertions(+), 10 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 4fe091c..6271bf7 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -574,11 +574,20 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	struct page *page = NULL, *valid_page = NULL;
 	unsigned long capture_pfn = 0;   /* current candidate for capturing */
 	unsigned long next_capture_pfn = 0; /* next candidate for capturing */
+	bool skip_on_failure = false; /* skip block when isolation fails */
 
 	if (cc->order > 0 && cc->order <= pageblock_order && capture) {
 		/* This may be outside the zone, but we check that later */
 		capture_pfn = low_pfn & ~((1UL << cc->order) - 1);
 		next_capture_pfn = ALIGN(low_pfn + 1, (1UL << cc->order));
+		/*
+		 * It is too expensive for compaction to migrate pages from a
+		 * cc->order block of pages on page faults, unless the entire
+		 * block can become free. But hugepaged should try anyway for
+		 * THP so that general defragmentation happens.
+		 */
+		skip_on_failure = (cc->gfp_mask & __GFP_NO_KSWAPD)
+				&& !(current->flags & PF_KTHREAD);
 	}
 
 	/*
@@ -633,7 +642,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			break;
 
 		if (!pfn_valid_within(low_pfn))
-			continue;
+			goto isolation_failed;
 		nr_scanned++;
 
 		page = pfn_to_page(low_pfn);
@@ -676,7 +685,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 					goto isolate_success;
 				}
 			}
-			continue;
+			goto isolation_failed;
 		}
 
 		/*
@@ -699,7 +708,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			if (next_capture_pfn)
 				next_capture_pfn =
 					ALIGN(low_pfn + 1, (1UL << cc->order));
-			continue;
+			goto isolation_failed;
 		}
 
 		/*
@@ -709,7 +718,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		 */
 		if (!page_mapping(page) &&
 		    page_count(page) > page_mapcount(page))
-			continue;
+			goto isolation_failed;
 
 		/* If we already hold the lock, we can skip some rechecking */
 		if (!locked) {
@@ -720,13 +729,13 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 			/* Recheck PageLRU and PageTransHuge under lock */
 			if (!PageLRU(page))
-				continue;
+				goto isolation_failed;
 			if (PageTransHuge(page)) {
 				low_pfn += (1 << compound_order(page)) - 1;
 				if (next_capture_pfn)
 					next_capture_pfn = ALIGN(low_pfn + 1,
 							(1UL << cc->order));
-				continue;
+				goto isolation_failed;
 			}
 		}
 
@@ -734,7 +743,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 		/* Try isolate the page */
 		if (__isolate_lru_page(page, isolate_mode) != 0)
-			continue;
+			goto isolation_failed;
 
 		VM_BUG_ON_PAGE(PageTransCompound(page), page);
 
@@ -747,11 +756,32 @@ isolate_success:
 		cc->nr_migratepages++;
 		nr_isolated++;
 
-		/* Avoid isolating too much */
-		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX) {
+		/*
+		 * Avoid isolating too much, except if we try to capture a
+		 * free page and want to find out at once if it can be done
+		 * or we should skip to the next block.
+		 */
+		if (!skip_on_failure &&
+				cc->nr_migratepages == COMPACT_CLUSTER_MAX) {
 			++low_pfn;
 			break;
 		}
+
+		continue;
+
+isolation_failed:
+		if (skip_on_failure) {
+			if (nr_isolated) {
+				if (locked) {
+					spin_unlock_irqrestore(&zone->lru_lock,
+									flags);
+					locked = false;
+				}
+				putback_movable_pages(migratelist);
+				nr_isolated = 0;
+			}
+			low_pfn = next_capture_pfn - 1;
+		}
 	}
 
 	/*
@@ -770,7 +800,7 @@ isolate_success:
 	 * Update the pageblock-skip information and cached scanner pfn,
 	 * if the whole pageblock was scanned without isolating any page.
 	 */
-	if (low_pfn == end_pfn)
+	if (low_pfn == end_pfn && !skip_on_failure)
 		update_pageblock_skip(cc, valid_page, nr_isolated, true);
 
 	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
