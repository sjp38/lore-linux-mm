Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 640978E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 12:53:31 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e29so5313619ede.19
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 09:53:31 -0800 (PST)
Received: from outbound-smtp26.blacknight.com (outbound-smtp26.blacknight.com. [81.17.249.194])
        by mx.google.com with ESMTPS id a16-v6si230705ejx.192.2019.01.18.09.53.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 09:53:29 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp26.blacknight.com (Postfix) with ESMTPS id C9604B87ED
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 17:53:28 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 10/22] mm, compaction: Keep migration source private to a single compaction instance
Date: Fri, 18 Jan 2019 17:51:24 +0000
Message-Id: <20190118175136.31341-11-mgorman@techsingularity.net>
In-Reply-To: <20190118175136.31341-1-mgorman@techsingularity.net>
References: <20190118175136.31341-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

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
Amean     fault-both-1         0.00 (   0.00%)        0.00 *   0.00%*
Amean     fault-both-3      3390.40 (   0.00%)     3024.41 (  10.80%)
Amean     fault-both-5      5082.28 (   0.00%)     4749.30 (   6.55%)
Amean     fault-both-7      7012.51 (   0.00%)     6454.95 (   7.95%)
Amean     fault-both-12    11346.63 (   0.00%)    10324.83 (   9.01%)
Amean     fault-both-18    15324.19 (   0.00%)    12896.82 *  15.84%*
Amean     fault-both-24    16088.50 (   0.00%)    13470.60 *  16.27%*
Amean     fault-both-30    18723.42 (   0.00%)    17143.99 (   8.44%)
Amean     fault-both-32    18612.01 (   0.00%)    17743.91 (   4.66%)

                                5.0.0-rc1              5.0.0-rc1
                            findmig-v3r15          isolmig-v3r15
Percentage huge-3        89.83 (   0.00%)       92.96 (   3.48%)
Percentage huge-5        91.96 (   0.00%)       93.26 (   1.41%)
Percentage huge-7        92.85 (   0.00%)       93.63 (   0.84%)
Percentage huge-12       92.74 (   0.00%)       92.80 (   0.07%)
Percentage huge-18       91.71 (   0.00%)       91.62 (  -0.10%)
Percentage huge-24       92.13 (   0.00%)       91.50 (  -0.69%)
Percentage huge-30       93.79 (   0.00%)       92.73 (  -1.13%)
Percentage huge-32       91.27 (   0.00%)       91.94 (   0.74%)

This shows a reasonable reduction in latency as multiple compaction
scanners do not operate on the same blocks with a similar allocation
success rate.

Compaction migrate scanned    41093126    25646769

Migration scan rates are reduced by 38%.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 124 ++++++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 99 insertions(+), 25 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 92d10eb3d1c7..7c4c9cce7907 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -285,13 +285,52 @@ void reset_isolation_suitable(pg_data_t *pgdat)
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
@@ -310,16 +349,8 @@ static void update_pageblock_skip(struct compact_control *cc,
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
@@ -334,10 +365,19 @@ static inline bool pageblock_skip_persistent(struct page *page)
 }
 
 static inline void update_pageblock_skip(struct compact_control *cc,
-			struct page *page, unsigned long nr_isolated,
-			bool migrate_scanner)
+			struct page *page, unsigned long nr_isolated)
 {
 }
+
+static void update_cached_migrate(struct compact_control *cc, unsigned long pfn)
+{
+}
+
+static bool test_and_set_skip(struct compact_control *cc, struct page *page,
+							unsigned long pfn)
+{
+	return false;
+}
 #endif /* CONFIG_COMPACTION */
 
 /*
@@ -567,7 +607,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 
 	/* Update the pageblock-skip if the whole pageblock was scanned */
 	if (blockpfn == end_pfn)
-		update_pageblock_skip(cc, valid_page, total_isolated, false);
+		update_pageblock_skip(cc, valid_page, total_isolated);
 
 	cc->total_free_scanned += nr_scanned;
 	if (total_isolated)
@@ -702,6 +742,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	unsigned long start_pfn = low_pfn;
 	bool skip_on_failure = false;
 	unsigned long next_skip_pfn = 0;
+	bool skip_updated = false;
 
 	/*
 	 * Ensure that there are not too many pages isolated from the LRU
@@ -768,8 +809,19 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
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
@@ -850,8 +902,19 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
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
@@ -929,15 +992,20 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
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
@@ -1321,8 +1389,6 @@ static unsigned long fast_find_migrateblock(struct compact_control *cc)
 			nr_scanned++;
 			free_pfn = page_to_pfn(freepage);
 			if (free_pfn < high_pfn) {
-				update_fast_start_pfn(cc, free_pfn);
-
 				/*
 				 * Avoid if skipped recently. Ideally it would
 				 * move to the tail but even safe iteration of
@@ -1339,6 +1405,7 @@ static unsigned long fast_find_migrateblock(struct compact_control *cc)
 				/* Reorder to so a future search skips recent pages */
 				move_freelist_tail(freelist, freepage);
 
+				update_fast_start_pfn(cc, free_pfn);
 				pfn = pageblock_start_pfn(free_pfn);
 				cc->fast_search_fail = 0;
 				set_pageblock_skip(freepage);
@@ -1427,8 +1494,15 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 		if (!page)
 			continue;
 
-		/* If isolation recently failed, do not retry */
-		if (!isolation_suitable(cc, page) && !fast_find_block)
+		/*
+		 * If isolation recently failed, do not retry. Only check the
+		 * pageblock once. COMPACT_CLUSTER_MAX causes a pageblock
+		 * to be visited multiple times. Assume skip was checked
+		 * before making it "skip" so other compaction instances do
+		 * not scan the same block.
+		 */
+		if (IS_ALIGNED(low_pfn, pageblock_nr_pages) &&
+		    !fast_find_block && !isolation_suitable(cc, page))
 			continue;
 
 		/*
-- 
2.16.4
