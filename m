Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3A8ED8E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 12:53:51 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id i55so5264060ede.14
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 09:53:51 -0800 (PST)
Received: from outbound-smtp13.blacknight.com (outbound-smtp13.blacknight.com. [46.22.139.230])
        by mx.google.com with ESMTPS id k13si3535974edl.377.2019.01.18.09.53.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 09:53:49 -0800 (PST)
Received: from mail.blacknight.com (unknown [81.17.254.16])
	by outbound-smtp13.blacknight.com (Postfix) with ESMTPS id 2B06B1C35C8
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 17:53:49 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 12/22] mm, compaction: Avoid rescanning the same pageblock multiple times
Date: Fri, 18 Jan 2019 17:51:26 +0000
Message-Id: <20190118175136.31341-13-mgorman@techsingularity.net>
In-Reply-To: <20190118175136.31341-1-mgorman@techsingularity.net>
References: <20190118175136.31341-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

Pageblocks are marked for skip when no pages are isolated after a scan.
However, it's possible to hit corner cases where the migration scanner
gets stuck near the boundary between the source and target scanner. Due
to pages being migrated in blocks of COMPACT_CLUSTER_MAX, pages that
are migrated can be reallocated before the pageblock is complete. The
pageblock is not necessarily skipped so it can be rescanned multiple
times. Similarly, a pageblock with some dirty/writeback pages may fail
to migrate and be rescanned until writeback completes which is wasteful.

This patch tracks if a pageblock is being rescanned. If so, then the entire
pageblock will be migrated as one operation. This narrows the race window
during which pages can be reallocated during migration. Secondly, if there
are pages that cannot be isolated then the pageblock will still be fully
scanned and marked for skipping. On the second rescan, the pageblock skip
is set and the migration scanner makes progress.

                                     5.0.0-rc1              5.0.0-rc1
                                findfree-v3r16         norescan-v3r16
Amean     fault-both-1         0.00 (   0.00%)        0.00 *   0.00%*
Amean     fault-both-3      3200.68 (   0.00%)     3002.07 (   6.21%)
Amean     fault-both-5      4847.75 (   0.00%)     4684.47 (   3.37%)
Amean     fault-both-7      6658.92 (   0.00%)     6815.54 (  -2.35%)
Amean     fault-both-12    11077.62 (   0.00%)    10864.02 (   1.93%)
Amean     fault-both-18    12403.97 (   0.00%)    12247.52 (   1.26%)
Amean     fault-both-24    15607.10 (   0.00%)    15683.99 (  -0.49%)
Amean     fault-both-30    18752.27 (   0.00%)    18620.02 (   0.71%)
Amean     fault-both-32    21207.54 (   0.00%)    19250.28 *   9.23%*

                                5.0.0-rc1              5.0.0-rc1
                           findfree-v3r16         norescan-v3r16
Percentage huge-3        96.86 (   0.00%)       95.00 (  -1.91%)
Percentage huge-5        93.72 (   0.00%)       94.22 (   0.53%)
Percentage huge-7        94.31 (   0.00%)       92.35 (  -2.08%)
Percentage huge-12       92.66 (   0.00%)       91.90 (  -0.82%)
Percentage huge-18       91.51 (   0.00%)       89.58 (  -2.11%)
Percentage huge-24       90.50 (   0.00%)       90.03 (  -0.52%)
Percentage huge-30       91.57 (   0.00%)       89.14 (  -2.65%)
Percentage huge-32       91.00 (   0.00%)       90.58 (  -0.46%)

Negligible difference but this was likely a case when the specific corner
case was not hit. A previous run of the same patch based on an earlier
iteration of the series showed large differences where migration rates
could be halved when the corner case was hit.

The specific corner case where migration scan rates go through the roof
was due to a dirty/writeback pageblock located at the boundary of the
migration/free scanner did not happen in this case. When it does happen,
the scan rates multipled by massive margins.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 32 ++++++++++++++++++++++++++------
 mm/internal.h   |  1 +
 2 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 19fea4a7b3f4..a31fea7b3f96 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -949,8 +949,11 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
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
@@ -997,11 +1000,14 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
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
@@ -2033,6 +2039,20 @@ static enum compact_result compact_zone(struct compact_control *cc)
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
index 983cb975545f..d5b999e5eb5f 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -205,6 +205,7 @@ struct compact_control {
 	bool direct_compaction;		/* False from kcompactd or /proc/... */
 	bool whole_zone;		/* Whole zone should/has been scanned */
 	bool contended;			/* Signal lock or sched contention */
+	bool rescan;			/* Rescanning the same pageblock */
 };
 
 unsigned long
-- 
2.16.4
