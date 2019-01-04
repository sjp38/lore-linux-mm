Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E5C0D8E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 07:52:46 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id b3so35181023edi.0
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 04:52:46 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id u22-v6si2809239ejb.233.2019.01.04.04.52.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 04:52:45 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id EA6291C1CDA
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 12:52:44 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 14/25] mm, compaction: Avoid rescanning the same pageblock multiple times
Date: Fri,  4 Jan 2019 12:50:00 +0000
Message-Id: <20190104125011.16071-15-mgorman@techsingularity.net>
In-Reply-To: <20190104125011.16071-1-mgorman@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Pageblocks are marked for skip when no pages are isolated after a scan.
However, it's possible to hit corner cases where the migration scanner
gets stuck near the boundary between the source and target scanner. Due
to pages being migrated in blocks of COMPACT_CLUSTER_MAX, pages that
are migrated can be reallocated before the pageblock is complete. The
pageblock is not necessarily skipped so it can be rescanned multiple
times. Similarly, a pageblock with some dirty/writeback pages may fail
to isolate and be rescanned until writeback completes which is wasteful.

This patch tracks if a pageblock is being rescanned. If so, then the entire
pageblock will be migrated as one operation. This narrows the race window
during which pages can be reallocated during migration. Secondly, if there
are pages that cannot be isolated then the pageblock will still be fully
scanned and marked for skipping. On the second rescan, the pageblock skip
is set and the migration scanner makes progress.

                                        4.20.0                 4.20.0
                              finishscan-v2r15         norescan-v2r15
Amean     fault-both-3      3729.80 (   0.00%)     2872.13 *  23.00%*
Amean     fault-both-5      5148.49 (   0.00%)     4330.56 *  15.89%*
Amean     fault-both-7      7393.24 (   0.00%)     6496.63 (  12.13%)
Amean     fault-both-12    11709.32 (   0.00%)    10280.59 (  12.20%)
Amean     fault-both-18    16626.82 (   0.00%)    11079.19 *  33.37%*
Amean     fault-both-24    19944.34 (   0.00%)    17207.80 *  13.72%*
Amean     fault-both-30    23435.53 (   0.00%)    17736.13 *  24.32%*
Amean     fault-both-32    23948.70 (   0.00%)    18509.41 *  22.71%*

                                   4.20.0                 4.20.0
                         finishscan-v2r15         norescan-v2r15
Percentage huge-1         0.00 (   0.00%)        0.00 (   0.00%)
Percentage huge-3        88.39 (   0.00%)       96.87 (   9.60%)
Percentage huge-5        92.07 (   0.00%)       94.63 (   2.77%)
Percentage huge-7        91.96 (   0.00%)       93.83 (   2.03%)
Percentage huge-12       93.38 (   0.00%)       92.65 (  -0.78%)
Percentage huge-18       91.89 (   0.00%)       93.66 (   1.94%)
Percentage huge-24       91.37 (   0.00%)       93.15 (   1.95%)
Percentage huge-30       92.77 (   0.00%)       93.16 (   0.42%)
Percentage huge-32       87.97 (   0.00%)       92.58 (   5.24%)

The fault latency reduction is large and while the THP allocation
success rate is only slightly higher, it's already high at this
point of the series.

Compaction migrate scanned    60718343.00    31772603.00
Compaction free scanned      933061894.00    63267928.00

Migration scan rates are reduced by 48% and free scan rates are
also reduced as the same migration source block is not being selected
multiple times. The corner case where migration scan rates go through the
roof due to a dirty/writeback pageblock located at the boundary of the
migration/free scanner did not happen in this case. When it does happen,
the scan rates multiple by factors measured in the hundreds and would be
misleading to present.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/compaction.c | 32 ++++++++++++++++++++++++++------
 mm/internal.h   |  1 +
 2 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 9438f0564ed5..9c2cc7955446 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -959,8 +959,11 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		cc->nr_migratepages++;
 		nr_isolated++;
 
-		/* Avoid isolating too much */
-		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX) {
+		/*
+		 * Avoid isolating too much unless this block is being
+		 * rescanned (e.g. dirty/writeback pages, parallel allocation).
+		 */
+		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX && !cc->rescan) {
 			++low_pfn;
 			break;
 		}
@@ -1007,11 +1010,14 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		spin_unlock_irqrestore(zone_lru_lock(zone), flags);
 
 	/*
-	 * Updated the cached scanner pfn if the pageblock was scanned
-	 * without isolating a page. The pageblock may not be marked
-	 * skipped already if there were no LRU pages in the block.
+	 * Updated the cached scanner pfn once the pageblock has been scanned
+	 * Pages will either be migrated in which case there is no point
+	 * scanning in the near future or migration failed in which case the
+	 * failure reason may persist. The block is marked for skipping if
+	 * there were no pages isolated in the block or if the block is
+	 * rescanned twice in a row.
 	 */
-	if (low_pfn == end_pfn && !nr_isolated) {
+	if (low_pfn == end_pfn && (!nr_isolated || cc->rescan)) {
 		if (valid_page && !skip_updated)
 			set_pageblock_skip(valid_page);
 		update_cached_migrate(cc, low_pfn);
@@ -2031,6 +2037,20 @@ static enum compact_result compact_zone(struct compact_control *cc)
 		int err;
 		unsigned long start_pfn = cc->migrate_pfn;
 
+		/*
+		 * Avoid multiple rescans which can happen if a page cannot be
+		 * isolated (dirty/writeback in async mode) or if the migrated
+		 * pages are being allocated before the pageblock is cleared.
+		 * The first rescan will capture the entire pageblock for
+		 * migration. If it fails, it'll be marked skip and scanning
+		 * will proceed as normal.
+		 */
+		cc->rescan = false;
+		if (pageblock_start_pfn(last_migrated_pfn) ==
+		    pageblock_start_pfn(start_pfn)) {
+			cc->rescan = true;
+		}
+
 		switch (isolate_migratepages(cc->zone, cc)) {
 		case ISOLATE_ABORT:
 			ret = COMPACT_CONTENDED;
diff --git a/mm/internal.h b/mm/internal.h
index b25b33c5dd80..e5ca2a10b8ad 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -204,6 +204,7 @@ struct compact_control {
 	bool direct_compaction;		/* False from kcompactd or /proc/... */
 	bool whole_zone;		/* Whole zone should/has been scanned */
 	bool contended;			/* Signal lock or sched contention */
+	bool rescan;			/* Rescanning the same pageblock */
 };
 
 unsigned long
-- 
2.16.4
