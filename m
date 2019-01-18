Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 858AE8E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 12:55:12 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id m19so5262586edc.6
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 09:55:12 -0800 (PST)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.106])
        by mx.google.com with ESMTPS id v14-v6si3876451ejw.273.2019.01.18.09.55.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 09:55:10 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 729001C30FC
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 17:55:10 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 20/22] mm, compaction: Sample pageblocks for free pages
Date: Fri, 18 Jan 2019 17:51:34 +0000
Message-Id: <20190118175136.31341-21-mgorman@techsingularity.net>
In-Reply-To: <20190118175136.31341-1-mgorman@techsingularity.net>
References: <20190118175136.31341-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

Once fast searching finishes, there is a possibility that the linear
scanner is scanning full blocks found by the fast scanner earlier. This
patch uses an adaptive stride to sample pageblocks for free pages. The
more consecutive full pageblocks encountered, the larger the stride until
a pageblock with free pages is found. The scanners might meet slightly
sooner but it is an acceptable risk given that the search of the free
lists may still encounter the pages and adjust the cached PFN of the free
scanner accordingly.

                                     5.0.0-rc1              5.0.0-rc1
                              roundrobin-v3r17       samplefree-v3r17
Amean     fault-both-1         0.00 (   0.00%)        0.00 *   0.00%*
Amean     fault-both-3      2752.37 (   0.00%)     2729.95 (   0.81%)
Amean     fault-both-5      4341.69 (   0.00%)     4397.80 (  -1.29%)
Amean     fault-both-7      6308.75 (   0.00%)     6097.61 (   3.35%)
Amean     fault-both-12    10241.81 (   0.00%)     9407.15 (   8.15%)
Amean     fault-both-18    13736.09 (   0.00%)    10857.63 *  20.96%*
Amean     fault-both-24    16853.95 (   0.00%)    13323.24 *  20.95%*
Amean     fault-both-30    15862.61 (   0.00%)    17345.44 (  -9.35%)
Amean     fault-both-32    18450.85 (   0.00%)    16892.00 (   8.45%)

The latency is mildly improved offseting some overhead from earlier
patches that are prerequisites for the rest of the series.  However,
a major impact is on the free scan rate with an 82% reduction.

                                5.0.0-rc1      5.0.0-rc1
                         roundrobin-v3r17 samplefree-v3r17
Compaction migrate scanned    21607271            20116887
Compaction free scanned       95336406            16668703

It's also the first time in the series where the number of pages scanned
by the migration scanner is greater than the free scanner due to the
increased search efficiency.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/compaction.c | 28 ++++++++++++++++++++++------
 1 file changed, 22 insertions(+), 6 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 7d39ff08269a..74bf620e3dcd 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -440,6 +440,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 				unsigned long *start_pfn,
 				unsigned long end_pfn,
 				struct list_head *freelist,
+				unsigned int stride,
 				bool strict)
 {
 	int nr_scanned = 0, total_isolated = 0;
@@ -449,10 +450,14 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 	unsigned long blockpfn = *start_pfn;
 	unsigned int order;
 
+	/* Strict mode is for isolation, speed is secondary */
+	if (strict)
+		stride = 1;
+
 	cursor = pfn_to_page(blockpfn);
 
 	/* Isolate free pages. */
-	for (; blockpfn < end_pfn; blockpfn++, cursor++) {
+	for (; blockpfn < end_pfn; blockpfn += stride, cursor += stride) {
 		int isolated;
 		struct page *page = cursor;
 
@@ -614,7 +619,7 @@ isolate_freepages_range(struct compact_control *cc,
 			break;
 
 		isolated = isolate_freepages_block(cc, &isolate_start_pfn,
-						block_end_pfn, &freelist, true);
+					block_end_pfn, &freelist, 0, true);
 
 		/*
 		 * In strict mode, isolate_freepages_block() returns 0 if
@@ -1132,7 +1137,7 @@ fast_isolate_around(struct compact_control *cc, unsigned long pfn, unsigned long
 
 	/* Scan before */
 	if (start_pfn != pfn) {
-		isolate_freepages_block(cc, &start_pfn, pfn, &cc->freepages, false);
+		isolate_freepages_block(cc, &start_pfn, pfn, &cc->freepages, 1, false);
 		if (cc->nr_freepages >= cc->nr_migratepages)
 			return;
 	}
@@ -1140,7 +1145,7 @@ fast_isolate_around(struct compact_control *cc, unsigned long pfn, unsigned long
 	/* Scan after */
 	start_pfn = pfn + nr_isolated;
 	if (start_pfn != end_pfn)
-		isolate_freepages_block(cc, &start_pfn, end_pfn, &cc->freepages, false);
+		isolate_freepages_block(cc, &start_pfn, end_pfn, &cc->freepages, 1, false);
 
 	/* Skip this pageblock in the future as it's full or nearly full */
 	if (cc->nr_freepages < cc->nr_migratepages)
@@ -1332,6 +1337,7 @@ static void isolate_freepages(struct compact_control *cc)
 	unsigned long block_end_pfn;	/* end of current pageblock */
 	unsigned long low_pfn;	     /* lowest pfn scanner is able to scan */
 	struct list_head *freelist = &cc->freepages;
+	unsigned int stride;
 
 	/* Try a small search of the free lists for a candidate */
 	isolate_start_pfn = fast_isolate_freepages(cc);
@@ -1354,6 +1360,7 @@ static void isolate_freepages(struct compact_control *cc)
 	block_end_pfn = min(block_start_pfn + pageblock_nr_pages,
 						zone_end_pfn(zone));
 	low_pfn = pageblock_end_pfn(cc->migrate_pfn);
+	stride = cc->mode == MIGRATE_ASYNC ? COMPACT_CLUSTER_MAX : 1;
 
 	/*
 	 * Isolate free pages until enough are available to migrate the
@@ -1364,6 +1371,8 @@ static void isolate_freepages(struct compact_control *cc)
 				block_end_pfn = block_start_pfn,
 				block_start_pfn -= pageblock_nr_pages,
 				isolate_start_pfn = block_start_pfn) {
+		unsigned long nr_isolated;
+
 		/*
 		 * This can iterate a massively long zone without finding any
 		 * suitable migration targets, so periodically check resched.
@@ -1385,8 +1394,8 @@ static void isolate_freepages(struct compact_control *cc)
 			continue;
 
 		/* Found a block suitable for isolating free pages from. */
-		isolate_freepages_block(cc, &isolate_start_pfn, block_end_pfn,
-					freelist, false);
+		nr_isolated = isolate_freepages_block(cc, &isolate_start_pfn,
+					block_end_pfn, freelist, stride, false);
 
 		/* Update the skip hint if the full pageblock was scanned */
 		if (isolate_start_pfn == block_end_pfn)
@@ -1410,6 +1419,13 @@ static void isolate_freepages(struct compact_control *cc)
 			 */
 			break;
 		}
+
+		/* Adjust stride depending on isolation */
+		if (nr_isolated) {
+			stride = 1;
+			continue;
+		}
+		stride = min_t(unsigned int, COMPACT_CLUSTER_MAX, stride << 1);
 	}
 
 	/*
-- 
2.16.4
