Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2B9B26B006E
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 11:50:35 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id q59so3908170wes.26
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 08:50:34 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cw1si2867752wib.7.2014.06.20.08.50.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Jun 2014 08:50:23 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH v3 13/13] mm, compaction: do not migrate pages when that cannot satisfy page fault allocation
Date: Fri, 20 Jun 2014 17:49:43 +0200
Message-Id: <1403279383-5862-14-git-send-email-vbabka@suse.cz>
In-Reply-To: <1403279383-5862-1-git-send-email-vbabka@suse.cz>
References: <1403279383-5862-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

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

In preliminary tests with stress-highalloc benchmark, this has reduced numbers
of scanned, isolated and migrated pages by about 10%, while the allocation
success rates dropped only by a few percent.

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
 mm/compaction.c | 51 +++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 39 insertions(+), 12 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 89eed1e..4577445 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -539,11 +539,20 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 				    (unevictable ? ISOLATE_UNEVICTABLE : 0);
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
@@ -613,7 +622,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		}
 
 		if (!pfn_valid_within(low_pfn))
-			continue;
+			goto isolation_failed;
 		nr_scanned++;
 
 		/*
@@ -624,7 +633,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		 */
 		page = pfn_to_page(low_pfn);
 		if (page_zone(page) != zone)
-			continue;
+			goto isolation_failed;
 
 		if (!valid_page)
 			valid_page = page;
@@ -664,7 +673,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 					goto isolate_success;
 				}
 			}
-			continue;
+			goto isolation_failed;
 		}
 
 		/*
@@ -684,7 +693,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 			if (next_capture_pfn)
 				next_capture_pfn =
 					ALIGN(low_pfn + 1, (1UL << cc->order));
-			continue;
+			goto isolation_failed;
 		}
 
 		/*
@@ -694,7 +703,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		 */
 		if (!page_mapping(page) &&
 		    page_count(page) > page_mapcount(page))
-			continue;
+			goto isolation_failed;
 
 		/* If we already hold the lock, we can skip some rechecking */
 		if (!locked) {
@@ -705,11 +714,11 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 
 			/* Recheck PageLRU and PageTransHuge under lock */
 			if (!PageLRU(page))
-				continue;
+				goto isolation_failed;
 			if (PageTransHuge(page)) {
 				low_pfn += (1 << compound_order(page)) - 1;
 				next_capture_pfn = low_pfn + 1;
-				continue;
+				goto isolation_failed;
 			}
 		}
 
@@ -717,7 +726,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 
 		/* Try isolate the page */
 		if (__isolate_lru_page(page, mode) != 0)
-			continue;
+			goto isolation_failed;
 
 		VM_BUG_ON_PAGE(PageTransCompound(page), page);
 
@@ -727,11 +736,14 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 isolate_success:
 		cc->finished_update_migrate = true;
 		list_add(&page->lru, migratelist);
-		cc->nr_migratepages++;
 		nr_isolated++;
 
-		/* Avoid isolating too much */
-		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX) {
+		/*
+		 * Avoid isolating too much, except if we try to capture a
+		 * free page and want to find out at once if it can be done
+		 * or we should skip to the next block.
+		 */
+		if (!skip_on_failure && nr_isolated == COMPACT_CLUSTER_MAX) {
 			++low_pfn;
 			break;
 		}
@@ -742,6 +754,20 @@ next_pageblock:
 		low_pfn = ALIGN(low_pfn + 1, pageblock_nr_pages) - 1;
 		if (next_capture_pfn)
 			next_capture_pfn = low_pfn + 1;
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
@@ -751,6 +777,7 @@ next_pageblock:
 	if (unlikely(low_pfn > end_pfn))
 		low_pfn = end_pfn;
 
+	cc->nr_migratepages = nr_isolated;
 	acct_isolated(zone, locked, cc);
 
 	if (locked)
@@ -760,7 +787,7 @@ next_pageblock:
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
