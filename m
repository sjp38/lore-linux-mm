Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C88368E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 07:52:26 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id i55so35179058ede.14
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 04:52:26 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id e16-v6si384789ejk.23.2019.01.04.04.52.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 04:52:24 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 935591C213D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 12:52:24 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 12/25] mm, compaction: Keep migration source private to a single compaction instance
Date: Fri,  4 Jan 2019 12:49:58 +0000
Message-Id: <20190104125011.16071-13-mgorman@techsingularity.net>
In-Reply-To: <20190104125011.16071-1-mgorman@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Due to either a fast search of the free list or a linear scan, it is
possible for multiple compaction instances to pick the same pageblock
for migration.  This is lucky for one scanner and increased scanning for
all the others. It also allows a race between requests on which first
allocates the resulting free block.

This patch tests and updates the pageblock skip for the migration scanner
carefully. When isolating a block, it will check and skip if the block is
already in use. Once the zone lock is acquired, it will be rechecked so
that only one scanner can set the pageblock skip for exclusive use. Any
scanner contending will continue with a linear scan. The skip bit is
still set if no pages can be isolated in a range. While this may result
in redundant scanning, it avoids unnecessarily acquiring the zone lock
when there are no suitable migration sources.

1-socket thpscale
                                        4.20.0                 4.20.0
                                 findmig-v2r15          isolmig-v2r15
Amean     fault-both-1         0.00 (   0.00%)        0.00 *   0.00%*
Amean     fault-both-3      3505.69 (   0.00%)     3066.68 *  12.52%*
Amean     fault-both-5      5794.13 (   0.00%)     4298.49 *  25.81%*
Amean     fault-both-7      7663.09 (   0.00%)     5986.99 *  21.87%*
Amean     fault-both-12    10983.36 (   0.00%)     9324.85 (  15.10%)
Amean     fault-both-18    13602.71 (   0.00%)    13350.05 (   1.86%)
Amean     fault-both-24    16145.77 (   0.00%)    13491.77 *  16.44%*
Amean     fault-both-30    19753.82 (   0.00%)    15630.86 *  20.87%*
Amean     fault-both-32    20616.16 (   0.00%)    17428.50 *  15.46%*

This is the first patch that shows a significant reduction in latency as
multiple compaction scanners do not operate on the same blocks. There is
a small increase in the success rate

                               4.20.0-rc6             4.20.0-rc6
                             findmig-v1r4           isolmig-v1r4
Percentage huge-3        90.58 (   0.00%)       95.84 (   5.81%)
Percentage huge-5        91.34 (   0.00%)       94.19 (   3.12%)
Percentage huge-7        92.21 (   0.00%)       93.78 (   1.71%)
Percentage huge-12       92.48 (   0.00%)       94.33 (   2.00%)
Percentage huge-18       91.65 (   0.00%)       94.15 (   2.72%)
Percentage huge-24       90.23 (   0.00%)       94.23 (   4.43%)
Percentage huge-30       90.17 (   0.00%)       95.17 (   5.54%)
Percentage huge-32       89.72 (   0.00%)       93.59 (   4.32%)

Compaction migrate scanned    54168306    25516488
Compaction free scanned      800530954    87603321

Migration scan rates are reduced by 52%.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/compaction.c | 126 ++++++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 99 insertions(+), 27 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 137e32e8a2f5..24e3a9db4b70 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -279,13 +279,52 @@ void reset_isolation_suitable(pg_data_t *pgdat)
 	}
 }
 
+/*
+ * Sets the pageblock skip bit if it was clear. Note that this is a hint as
+ * locks are not required for read/writers. Returns true if it was already set.
+ */
+static bool test_and_set_skip(struct compact_control *cc, struct page *page,
+							unsigned long pfn)
+{
+	bool skip;
+
+	/* Do no update if skip hint is being ignored */
+	if (cc->ignore_skip_hint)
+		return false;
+
+	if (!IS_ALIGNED(pfn, pageblock_nr_pages))
+		return false;
+
+	skip = get_pageblock_skip(page);
+	if (!skip && !cc->no_set_skip_hint)
+		set_pageblock_skip(page);
+
+	return skip;
+}
+
+static void update_cached_migrate(struct compact_control *cc, unsigned long pfn)
+{
+	struct zone *zone = cc->zone;
+
+	pfn = pageblock_end_pfn(pfn);
+
+	/* Set for isolation rather than compaction */
+	if (cc->no_set_skip_hint)
+		return;
+
+	if (pfn > zone->compact_cached_migrate_pfn[0])
+		zone->compact_cached_migrate_pfn[0] = pfn;
+	if (cc->mode != MIGRATE_ASYNC &&
+	    pfn > zone->compact_cached_migrate_pfn[1])
+		zone->compact_cached_migrate_pfn[1] = pfn;
+}
+
 /*
  * If no pages were isolated then mark this pageblock to be skipped in the
  * future. The information is later cleared by __reset_isolation_suitable().
  */
 static void update_pageblock_skip(struct compact_control *cc,
-			struct page *page, unsigned long nr_isolated,
-			bool migrate_scanner)
+			struct page *page, unsigned long nr_isolated)
 {
 	struct zone *zone = cc->zone;
 	unsigned long pfn;
@@ -304,16 +343,8 @@ static void update_pageblock_skip(struct compact_control *cc,
 	pfn = page_to_pfn(page);
 
 	/* Update where async and sync compaction should restart */
-	if (migrate_scanner) {
-		if (pfn > zone->compact_cached_migrate_pfn[0])
-			zone->compact_cached_migrate_pfn[0] = pfn;
-		if (cc->mode != MIGRATE_ASYNC &&
-		    pfn > zone->compact_cached_migrate_pfn[1])
-			zone->compact_cached_migrate_pfn[1] = pfn;
-	} else {
-		if (pfn < zone->compact_cached_free_pfn)
-			zone->compact_cached_free_pfn = pfn;
-	}
+	if (pfn < zone->compact_cached_free_pfn)
+		zone->compact_cached_free_pfn = pfn;
 }
 #else
 static inline bool isolation_suitable(struct compact_control *cc,
@@ -328,10 +359,19 @@ static inline bool pageblock_skip_persistent(struct page *page)
 }
 
 static inline void update_pageblock_skip(struct compact_control *cc,
-			struct page *page, unsigned long nr_isolated,
-			bool migrate_scanner)
+			struct page *page, unsigned long nr_isolated)
+{
+}
+
+static void update_cached_migrate(struct compact_control *cc, unsigned long pfn)
 {
 }
+
+static bool test_and_set_skip(struct compact_control *cc, struct page *page,
+							unsigned long pfn)
+{
+	return false;
+}
 #endif /* CONFIG_COMPACTION */
 
 /*
@@ -570,7 +610,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 
 	/* Update the pageblock-skip if the whole pageblock was scanned */
 	if (blockpfn == end_pfn)
-		update_pageblock_skip(cc, valid_page, total_isolated, false);
+		update_pageblock_skip(cc, valid_page, total_isolated);
 
 	cc->total_free_scanned += nr_scanned;
 	if (total_isolated)
@@ -705,6 +745,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	unsigned long start_pfn = low_pfn;
 	bool skip_on_failure = false;
 	unsigned long next_skip_pfn = 0;
+	bool skip_updated = false;
 
 	/*
 	 * Ensure that there are not too many pages isolated from the LRU
@@ -771,8 +812,19 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 		page = pfn_to_page(low_pfn);
 
-		if (!valid_page)
+		/*
+		 * Check if the pageblock has already been marked skipped.
+		 * Only the aligned PFN is checked as the caller isolates
+		 * COMPACT_CLUSTER_MAX at a time so the second call must
+		 * not falsely conclude that the block should be skipped.
+		 */
+		if (!valid_page && IS_ALIGNED(low_pfn, pageblock_nr_pages)) {
+			if (!cc->ignore_skip_hint && get_pageblock_skip(page)) {
+				low_pfn = end_pfn;
+				goto isolate_abort;
+			}
 			valid_page = page;
+		}
 
 		/*
 		 * Skip if free. We read page order here without zone lock
@@ -860,8 +912,19 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		if (!locked) {
 			locked = compact_trylock_irqsave(zone_lru_lock(zone),
 								&flags, cc);
-			if (!locked)
+
+			/* Allow future scanning if the lock is contended */
+			if (!locked) {
+				clear_pageblock_skip(page);
 				break;
+			}
+
+			/* Try get exclusive access under lock */
+			if (!skip_updated) {
+				skip_updated = true;
+				if (test_and_set_skip(cc, page, low_pfn))
+					goto isolate_abort;
+			}
 
 			/* Recheck PageLRU and PageCompound under lock */
 			if (!PageLRU(page))
@@ -939,15 +1002,20 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	if (unlikely(low_pfn > end_pfn))
 		low_pfn = end_pfn;
 
+isolate_abort:
 	if (locked)
 		spin_unlock_irqrestore(zone_lru_lock(zone), flags);
 
 	/*
-	 * Update the pageblock-skip information and cached scanner pfn,
-	 * if the whole pageblock was scanned without isolating any page.
+	 * Updated the cached scanner pfn if the pageblock was scanned
+	 * without isolating a page. The pageblock may not be marked
+	 * skipped already if there were no LRU pages in the block.
 	 */
-	if (low_pfn == end_pfn)
-		update_pageblock_skip(cc, valid_page, nr_isolated, true);
+	if (low_pfn == end_pfn && !nr_isolated) {
+		if (valid_page && !skip_updated)
+			set_pageblock_skip(valid_page);
+		update_cached_migrate(cc, low_pfn);
+	}
 
 	trace_mm_compaction_isolate_migratepages(start_pfn, low_pfn,
 						nr_scanned, nr_isolated);
@@ -1332,8 +1400,6 @@ static unsigned long fast_find_migrateblock(struct compact_control *cc)
 			nr_scanned++;
 			free_pfn = page_to_pfn(freepage);
 			if (free_pfn < high_pfn) {
-				update_fast_start_pfn(cc, free_pfn);
-
 				/*
 				 * Avoid if skipped recently. Move to the tail
 				 * of the list so it will not be found again
@@ -1355,9 +1421,9 @@ static unsigned long fast_find_migrateblock(struct compact_control *cc)
 				/* Reorder to so a future search skips recent pages */
 				move_freelist_tail(freelist, freepage);
 
+				update_fast_start_pfn(cc, free_pfn);
 				pfn = pageblock_start_pfn(free_pfn);
 				cc->fast_search_fail = 0;
-				set_pageblock_skip(freepage);
 				break;
 			}
 
@@ -1427,7 +1493,6 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 			low_pfn = block_end_pfn,
 			block_start_pfn = block_end_pfn,
 			block_end_pfn += pageblock_nr_pages) {
-
 		/*
 		 * This can potentially iterate a massively long zone with
 		 * many pageblocks unsuitable, so periodically check if we
@@ -1442,8 +1507,15 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 		if (!page)
 			continue;
 
-		/* If isolation recently failed, do not retry */
-		if (!isolation_suitable(cc, page))
+		/*
+		 * If isolation recently failed, do not retry. Only check the
+		 * pageblock once. COMPACT_CLUSTER_MAX causes a pageblock
+		 * to be visited multiple times. Assume skip was checked
+		 * before making it "skip" so other compaction instances do
+		 * not scan the same block.
+		 */
+		if (IS_ALIGNED(low_pfn, pageblock_nr_pages) &&
+		    !isolation_suitable(cc, page))
 			continue;
 
 		/*
-- 
2.16.4
