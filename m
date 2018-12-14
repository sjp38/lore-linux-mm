Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 751F28E021D
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 18:05:35 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c53so3488015edc.9
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 15:05:35 -0800 (PST)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id v3-v6si981560eji.60.2018.12.14.15.05.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 15:05:33 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 66E911C1DF6
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 23:05:33 +0000 (GMT)
Date: Fri, 14 Dec 2018 23:05:31 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 12/14] mm, compaction: Use free lists to quickly locate a
 migration target
Message-ID: <20181214230531.GC29005@techsingularity.net>
References: <20181214230310.572-1-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181214230310.572-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

Similar to the migration scanner, this uses the free lists to quickly
locate a migration target. The search is different in that lower orders
will be searched for a suitable high PFN if necessary but the search
is still bound. This is justified on the grounds that the free scanner
typically scans linearly much more than the migration scanner.

If a free page is found, it is isolated and the full pageblock is scanned
for any remaining free pages. This is done so that it's possible to mark
the pageblock for skipping in the near future.

1-socket thpfioscale
                                    4.20.0-rc6             4.20.0-rc6
                                  isolmig-v1r4          findfree-v1r8
Amean     fault-both-3      2980.25 (   0.00%)     2911.07 (   2.32%)
Amean     fault-both-5      4393.04 (   0.00%)     4692.96 (  -6.83%)
Amean     fault-both-7      5797.16 (   0.00%)     6449.17 ( -11.25%)
Amean     fault-both-12     9849.61 (   0.00%)     9778.40 (   0.72%)
Amean     fault-both-18    13816.96 (   0.00%)    11756.92 (  14.91%)
Amean     fault-both-24    16255.20 (   0.00%)    13675.93 *  15.87%*
Amean     fault-both-30    15741.25 (   0.00%)    17195.41 (  -9.24%)
Amean     fault-both-32    16624.73 (   0.00%)    18150.08 (  -9.18%)

The impact on latency is variable but the search is optimistic and
sensitive to the exact system state. Success rates are similar but
the major impact is to the rate of scanning

                            4.20.0-rc6  4.20.0-rc6
                          isolmig-v1r4findfree-v1r8
Compaction migrate scanned    25587453    27634284
Compaction free scanned       87735894    55279519

The free scan rates are reduced by 37%.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/compaction.c | 201 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 197 insertions(+), 4 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index b0309bf409b3..ba3035dcc548 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1117,7 +1117,7 @@ static inline bool compact_scanners_met(struct compact_control *cc)
 
 /* Reorder the free list to reduce repeated future searches */
 static void
-move_freelist_tail(struct list_head *freelist, struct page *freepage)
+move_freelist_head(struct list_head *freelist, struct page *freepage)
 {
 	LIST_HEAD(sublist);
 
@@ -1128,6 +1128,193 @@ move_freelist_tail(struct list_head *freelist, struct page *freepage)
 	}
 }
 
+static void
+move_freelist_tail(struct list_head *freelist, struct page *freepage)
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
+	unsigned int order_scanned = 0, nr_scanned = 0;
+	unsigned long low_pfn, min_pfn, high_pfn = 0, highest = 0;
+	unsigned long nr_isolated = 0;
+	unsigned long distance;
+	struct page *page = NULL;
+	bool scan_start = false;
+	int order;
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
+		return 0;
+
+	low_pfn = page_to_pfn(page);
+	fast_isolate_around(cc, low_pfn, nr_isolated);
+	return low_pfn;
+}
+
 /*
  * Based on information in the current compact_control, find blocks
  * suitable for isolating free pages from and then isolate them.
@@ -1142,6 +1329,11 @@ static void isolate_freepages(struct compact_control *cc)
 	unsigned long low_pfn;	     /* lowest pfn scanner is able to scan */
 	struct list_head *freelist = &cc->freepages;
 
+	/* Try a small search of the free lists for a candidate */
+	isolate_start_pfn = fast_isolate_freepages(cc);
+	if (isolate_start_pfn)
+		goto splitmap;
+
 	/*
 	 * Initialise the free scanner. The starting point is where we last
 	 * successfully isolated from, zone-cached value, or the end of the
@@ -1218,9 +1410,6 @@ static void isolate_freepages(struct compact_control *cc)
 		}
 	}
 
-	/* __isolate_free_page() does not map the pages */
-	split_map_pages(freelist);
-
 	/*
 	 * Record where the free scanner will restart next time. Either we
 	 * broke from the loop and set isolate_start_pfn based on the last
@@ -1228,6 +1417,10 @@ static void isolate_freepages(struct compact_control *cc)
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
