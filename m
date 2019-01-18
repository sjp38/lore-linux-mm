Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9D0C28E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 12:53:41 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id b7so5259311eda.10
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 09:53:41 -0800 (PST)
Received: from outbound-smtp16.blacknight.com (outbound-smtp16.blacknight.com. [46.22.139.233])
        by mx.google.com with ESMTPS id h13-v6si4521001eja.107.2019.01.18.09.53.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 09:53:39 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp16.blacknight.com (Postfix) with ESMTPS id F3E431C35B5
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 17:53:38 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 11/22] mm, compaction: Use free lists to quickly locate a migration target
Date: Fri, 18 Jan 2019 17:51:25 +0000
Message-Id: <20190118175136.31341-12-mgorman@techsingularity.net>
In-Reply-To: <20190118175136.31341-1-mgorman@techsingularity.net>
References: <20190118175136.31341-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

Similar to the migration scanner, this patch uses the free lists to quickly
locate a migration target. The search is different in that lower orders
will be searched for a suitable high PFN if necessary but the search
is still bound. This is justified on the grounds that the free scanner
typically scans linearly much more than the migration scanner.

If a free page is found, it is isolated and compaction continues if enough
pages were isolated. For SYNC* scanning, the full pageblock is scanned
for any remaining free pages so that is can be marked for skipping in
the near future.

1-socket thpfioscale
                                     5.0.0-rc1              5.0.0-rc1
                                 isolmig-v3r15         findfree-v3r16
Amean     fault-both-3      3024.41 (   0.00%)     3200.68 (  -5.83%)
Amean     fault-both-5      4749.30 (   0.00%)     4847.75 (  -2.07%)
Amean     fault-both-7      6454.95 (   0.00%)     6658.92 (  -3.16%)
Amean     fault-both-12    10324.83 (   0.00%)    11077.62 (  -7.29%)
Amean     fault-both-18    12896.82 (   0.00%)    12403.97 (   3.82%)
Amean     fault-both-24    13470.60 (   0.00%)    15607.10 * -15.86%*
Amean     fault-both-30    17143.99 (   0.00%)    18752.27 (  -9.38%)
Amean     fault-both-32    17743.91 (   0.00%)    21207.54 * -19.52%*

The impact on latency is variable but the search is optimistic and
sensitive to the exact system state. Success rates are similar but
the major impact is to the rate of scanning

                                5.0.0-rc1      5.0.0-rc1
                            isolmig-v3r15 findfree-v3r16
Compaction migrate scanned    25646769          29507205
Compaction free scanned      201558184         100359571

The free scan rates are reduced by 50%. The 2-socket reductions for the
free scanner are more dramatic which is a likely reflection that the
machine has more memory.

[dan.carpenter@oracle.com: Fix static checker warning]
[vbabka@suse.cz: Correct number of pages scanned for lower orders]
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/compaction.c | 218 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 213 insertions(+), 5 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 7c4c9cce7907..19fea4a7b3f4 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1124,7 +1124,29 @@ static inline bool compact_scanners_met(struct compact_control *cc)
 		<= (cc->migrate_pfn >> pageblock_order);
 }
 
-/* Reorder the free list to reduce repeated future searches */
+/*
+ * Used when scanning for a suitable migration target which scans freelists
+ * in reverse. Reorders the list such as the unscanned pages are scanned
+ * first on the next iteration of the free scanner
+ */
+static void
+move_freelist_head(struct list_head *freelist, struct page *freepage)
+{
+	LIST_HEAD(sublist);
+
+	if (!list_is_last(freelist, &freepage->lru)) {
+		list_cut_before(&sublist, freelist, &freepage->lru);
+		if (!list_empty(&sublist))
+			list_splice_tail(&sublist, freelist);
+	}
+}
+
+/*
+ * Similar to move_freelist_head except used by the migration scanner
+ * when scanning forward. It's possible for these list operations to
+ * move against each other if they search the free list exactly in
+ * lockstep.
+ */
 static void
 move_freelist_tail(struct list_head *freelist, struct page *freepage)
 {
@@ -1137,6 +1159,186 @@ move_freelist_tail(struct list_head *freelist, struct page *freepage)
 	}
 }
 
+static void
+fast_isolate_around(struct compact_control *cc, unsigned long pfn, unsigned long nr_isolated)
+{
+	unsigned long start_pfn, end_pfn;
+	struct page *page = pfn_to_page(pfn);
+
+	/* Do not search around if there are enough pages already */
+	if (cc->nr_freepages >= cc->nr_migratepages)
+		return;
+
+	/* Minimise scanning during async compaction */
+	if (cc->direct_compaction && cc->mode == MIGRATE_ASYNC)
+		return;
+
+	/* Pageblock boundaries */
+	start_pfn = pageblock_start_pfn(pfn);
+	end_pfn = min(start_pfn + pageblock_nr_pages, zone_end_pfn(cc->zone));
+
+	/* Scan before */
+	if (start_pfn != pfn) {
+		isolate_freepages_block(cc, &start_pfn, pfn, &cc->freepages, false);
+		if (cc->nr_freepages >= cc->nr_migratepages)
+			return;
+	}
+
+	/* Scan after */
+	start_pfn = pfn + nr_isolated;
+	if (start_pfn != end_pfn)
+		isolate_freepages_block(cc, &start_pfn, end_pfn, &cc->freepages, false);
+
+	/* Skip this pageblock in the future as it's full or nearly full */
+	if (cc->nr_freepages < cc->nr_migratepages)
+		set_pageblock_skip(page);
+}
+
+static unsigned long
+fast_isolate_freepages(struct compact_control *cc)
+{
+	unsigned int limit = min(1U, freelist_scan_limit(cc) >> 1);
+	unsigned int nr_scanned = 0;
+	unsigned long low_pfn, min_pfn, high_pfn = 0, highest = 0;
+	unsigned long nr_isolated = 0;
+	unsigned long distance;
+	struct page *page = NULL;
+	bool scan_start = false;
+	int order;
+
+	/* Full compaction passes in a negative order */
+	if (cc->order <= 0)
+		return cc->free_pfn;
+
+	/*
+	 * If starting the scan, use a deeper search and use the highest
+	 * PFN found if a suitable one is not found.
+	 */
+	if (cc->free_pfn == pageblock_start_pfn(zone_end_pfn(cc->zone) - 1)) {
+		limit = pageblock_nr_pages >> 1;
+		scan_start = true;
+	}
+
+	/*
+	 * Preferred point is in the top quarter of the scan space but take
+	 * a pfn from the top half if the search is problematic.
+	 */
+	distance = (cc->free_pfn - cc->migrate_pfn);
+	low_pfn = pageblock_start_pfn(cc->free_pfn - (distance >> 2));
+	min_pfn = pageblock_start_pfn(cc->free_pfn - (distance >> 1));
+
+	if (WARN_ON_ONCE(min_pfn > low_pfn))
+		low_pfn = min_pfn;
+
+	for (order = cc->order - 1;
+	     order >= 0 && !page;
+	     order--) {
+		struct free_area *area = &cc->zone->free_area[order];
+		struct list_head *freelist;
+		struct page *freepage;
+		unsigned long flags;
+		unsigned int order_scanned = 0;
+
+		if (!area->nr_free)
+			continue;
+
+		spin_lock_irqsave(&cc->zone->lock, flags);
+		freelist = &area->free_list[MIGRATE_MOVABLE];
+		list_for_each_entry_reverse(freepage, freelist, lru) {
+			unsigned long pfn;
+
+			order_scanned++;
+			nr_scanned++;
+			pfn = page_to_pfn(freepage);
+
+			if (pfn >= highest)
+				highest = pageblock_start_pfn(pfn);
+
+			if (pfn >= low_pfn) {
+				cc->fast_search_fail = 0;
+				page = freepage;
+				break;
+			}
+
+			if (pfn >= min_pfn && pfn > high_pfn) {
+				high_pfn = pfn;
+
+				/* Shorten the scan if a candidate is found */
+				limit >>= 1;
+			}
+
+			if (order_scanned >= limit)
+				break;
+		}
+
+		/* Use a minimum pfn if a preferred one was not found */
+		if (!page && high_pfn) {
+			page = pfn_to_page(high_pfn);
+
+			/* Update freepage for the list reorder below */
+			freepage = page;
+		}
+
+		/* Reorder to so a future search skips recent pages */
+		move_freelist_head(freelist, freepage);
+
+		/* Isolate the page if available */
+		if (page) {
+			if (__isolate_free_page(page, order)) {
+				set_page_private(page, order);
+				nr_isolated = 1 << order;
+				cc->nr_freepages += nr_isolated;
+				list_add_tail(&page->lru, &cc->freepages);
+				count_compact_events(COMPACTISOLATED, nr_isolated);
+			} else {
+				/* If isolation fails, abort the search */
+				order = -1;
+				page = NULL;
+			}
+		}
+
+		spin_unlock_irqrestore(&cc->zone->lock, flags);
+
+		/*
+		 * Smaller scan on next order so the total scan ig related
+		 * to freelist_scan_limit.
+		 */
+		if (order_scanned >= limit)
+			limit = min(1U, limit >> 1);
+	}
+
+	if (!page) {
+		cc->fast_search_fail++;
+		if (scan_start) {
+			/*
+			 * Use the highest PFN found above min. If one was
+			 * not found, be pessemistic for direct compaction
+			 * and use the min mark.
+			 */
+			if (highest) {
+				page = pfn_to_page(highest);
+				cc->free_pfn = highest;
+			} else {
+				if (cc->direct_compaction) {
+					page = pfn_to_page(min_pfn);
+					cc->free_pfn = min_pfn;
+				}
+			}
+		}
+	}
+
+	if (highest && highest > cc->zone->compact_cached_free_pfn)
+		cc->zone->compact_cached_free_pfn = highest;
+
+	cc->total_free_scanned += nr_scanned;
+	if (!page)
+		return cc->free_pfn;
+
+	low_pfn = page_to_pfn(page);
+	fast_isolate_around(cc, low_pfn, nr_isolated);
+	return low_pfn;
+}
+
 /*
  * Based on information in the current compact_control, find blocks
  * suitable for isolating free pages from and then isolate them.
@@ -1151,6 +1353,11 @@ static void isolate_freepages(struct compact_control *cc)
 	unsigned long low_pfn;	     /* lowest pfn scanner is able to scan */
 	struct list_head *freelist = &cc->freepages;
 
+	/* Try a small search of the free lists for a candidate */
+	isolate_start_pfn = fast_isolate_freepages(cc);
+	if (cc->nr_freepages)
+		goto splitmap;
+
 	/*
 	 * Initialise the free scanner. The starting point is where we last
 	 * successfully isolated from, zone-cached value, or the end of the
@@ -1163,7 +1370,7 @@ static void isolate_freepages(struct compact_control *cc)
 	 * is using.
 	 */
 	isolate_start_pfn = cc->free_pfn;
-	block_start_pfn = pageblock_start_pfn(cc->free_pfn);
+	block_start_pfn = pageblock_start_pfn(isolate_start_pfn);
 	block_end_pfn = min(block_start_pfn + pageblock_nr_pages,
 						zone_end_pfn(zone));
 	low_pfn = pageblock_end_pfn(cc->migrate_pfn);
@@ -1227,9 +1434,6 @@ static void isolate_freepages(struct compact_control *cc)
 		}
 	}
 
-	/* __isolate_free_page() does not map the pages */
-	split_map_pages(freelist);
-
 	/*
 	 * Record where the free scanner will restart next time. Either we
 	 * broke from the loop and set isolate_start_pfn based on the last
@@ -1237,6 +1441,10 @@ static void isolate_freepages(struct compact_control *cc)
 	 * and the loop terminated due to isolate_start_pfn < low_pfn
 	 */
 	cc->free_pfn = isolate_start_pfn;
+
+splitmap:
+	/* __isolate_free_page() does not map the pages */
+	split_map_pages(freelist);
 }
 
 /*
-- 
2.16.4
