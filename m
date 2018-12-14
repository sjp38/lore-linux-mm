Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 46D738E021D
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 18:05:17 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x15so3463515edd.2
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 15:05:17 -0800 (PST)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id 26-v6si682808ejl.106.2018.12.14.15.05.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 15:05:15 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 32DC4987B6
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 23:05:15 +0000 (UTC)
Date: Fri, 14 Dec 2018 23:05:13 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 11/14] mm, compaction: Keep migration source private to a
 single compaction instance
Message-ID: <20181214230513.GB29005@techsingularity.net>
References: <20181214230310.572-1-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181214230310.572-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

Due to either a fast search of the free list or a linear scan, it's possible
for multiple compaction instances to pick the same pageblock for migration.
This is lucky for one scanner and increased scanning for all the others. It
also opens a race to allocate the resulting free block.

This patch tests and updates the pageblock skip for the migration scanner
more carefully. When isolating a block, it will check and skip if the block
is already in use. Once the zone lock is acquired, it will be rechecked so
that only one scanner can set the pageblock skip for exclusive use. Any
scanner contending will continue with a linear scan. The skip bit is still
set if no pages can be isolated in a range. While this may result in redundant
scanning, it avoids unnecessarily acquiring the zone lock when there are
no suitable migration sources.

1-socket thpscale
                                    4.20.0-rc6             4.20.0-rc6
                                  findmig-v1r4           isolmig-v1r4
Amean     fault-both-3      3545.40 (   0.00%)     2980.25 *  15.94%*
Amean     fault-both-5      5431.98 (   0.00%)     4393.04 *  19.13%*
Amean     fault-both-7      7185.11 (   0.00%)     5797.16 *  19.32%*
Amean     fault-both-12    11424.68 (   0.00%)     9849.61 (  13.79%)
Amean     fault-both-18    14170.10 (   0.00%)    13816.96 (   2.49%)
Amean     fault-both-24    16143.57 (   0.00%)    16255.20 (  -0.69%)
Amean     fault-both-30    19207.96 (   0.00%)    15741.25 *  18.05%*
Amean     fault-both-32    20051.01 (   0.00%)    16624.73 *  17.09%*

This is the first patch that shows a significant reduction in latency
as multiple compaction scanners do not operate on the same blocks. There
is a small increase in the success rate

                               4.20.0-rc6             4.20.0-rc6
                             findmig-v1r4           isolmig-v1r4
Percentage huge-3        91.95 (   0.00%)       95.97 (   4.37%)
Percentage huge-5        91.40 (   0.00%)       94.78 (   3.70%)
Percentage huge-7        92.94 (   0.00%)       93.94 (   1.07%)
Percentage huge-12       92.13 (   0.00%)       93.77 (   1.78%)
Percentage huge-18       91.01 (   0.00%)       94.57 (   3.91%)
Percentage huge-24       89.56 (   0.00%)       93.71 (   4.63%)
Percentage huge-30       90.26 (   0.00%)       94.14 (   4.30%)
Percentage huge-32       90.70 (   0.00%)       94.44 (   4.12%)

Compaction migrate scanned    51005450    25587453
Compaction free scanned      780359464    87735894

Migration scan rates are reduced by 49%. At the time of writing, the
2-socket results are not yet available.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/compaction.c | 112 +++++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 87 insertions(+), 25 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 65c7ab1847a0..b0309bf409b3 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -279,13 +279,51 @@ void reset_isolation_suitable(pg_data_t *pgdat)
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
@@ -304,16 +342,8 @@ static void update_pageblock_skip(struct compact_control *cc,
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
@@ -561,7 +591,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 
 	/* Update the pageblock-skip if the whole pageblock was scanned */
 	if (blockpfn == end_pfn)
-		update_pageblock_skip(cc, valid_page, total_isolated, false);
+		update_pageblock_skip(cc, valid_page, total_isolated);
 
 	cc->total_free_scanned += nr_scanned;
 	if (total_isolated)
@@ -696,6 +726,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	unsigned long start_pfn = low_pfn;
 	bool skip_on_failure = false;
 	unsigned long next_skip_pfn = 0;
+	bool skip_updated = false;
 
 	/*
 	 * Ensure that there are not too many pages isolated from the LRU
@@ -762,8 +793,19 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
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
@@ -851,8 +893,19 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
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
@@ -930,15 +983,20 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
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
@@ -1323,8 +1381,6 @@ static unsigned long fast_find_migrateblock(struct compact_control *cc)
 			nr_scanned++;
 			free_pfn = page_to_pfn(freepage);
 			if (free_pfn < high_pfn) {
-				update_fast_start_pfn(cc, free_pfn);
-
 				/*
 				 * Avoid if skipped recently. Move to the tail
 				 * of the list so it will not be found again
@@ -1346,9 +1402,9 @@ static unsigned long fast_find_migrateblock(struct compact_control *cc)
 				/* Reorder to so a future search skips recent pages */
 				move_freelist_tail(freelist, freepage);
 
+				update_fast_start_pfn(cc, free_pfn);
 				pfn = pageblock_start_pfn(free_pfn);
 				cc->fast_search_fail = 0;
-				set_pageblock_skip(freepage);
 				break;
 			}
 
@@ -1418,7 +1474,6 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 			low_pfn = block_end_pfn,
 			block_start_pfn = block_end_pfn,
 			block_end_pfn += pageblock_nr_pages) {
-
 		/*
 		 * This can potentially iterate a massively long zone with
 		 * many pageblocks unsuitable, so periodically check if we
@@ -1433,8 +1488,15 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
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
