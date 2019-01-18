Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 018108E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 12:54:52 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id z10so5254853edz.15
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 09:54:51 -0800 (PST)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id w11si2420117edl.223.2019.01.18.09.54.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 09:54:50 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 1BE1D98BD2
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 17:54:50 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 18/22] mm, compaction: Reduce premature advancement of the migration target scanner
Date: Fri, 18 Jan 2019 17:51:32 +0000
Message-Id: <20190118175136.31341-19-mgorman@techsingularity.net>
In-Reply-To: <20190118175136.31341-1-mgorman@techsingularity.net>
References: <20190118175136.31341-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

The fast isolation of free pages allows the cached PFN of the free
scanner to advance faster than necessary depending on the contents
of the free list. The key is that fast_isolate_freepages() can update
zone->compact_cached_free_pfn via isolate_freepages_block().  When the
fast search fails, the linear scan can start from a point that has skipped
valid migration targets, particularly pageblocks with just low-order
free pages. This can cause the migration source/target scanners to meet
prematurely causing a reset.

This patch starts by avoiding an update of the pageblock skip information
and cached PFN from isolate_freepages_block() and puts the responsibility
of updating that information in the callers. The fast scanner will update
the cached PFN if and only if it finds a block that is higher than the
existing cached PFN and sets the skip if the pageblock is full or nearly
full. The linear scanner will update skipped information and the cached
PFN only when a block is completely scanned. The total impact is that
the free scanner advances more slowly as it is primarily driven by the
linear scanner instead of the fast search.

                                     5.0.0-rc1              5.0.0-rc1
                               noresched-v3r17         slowfree-v3r17
Amean     fault-both-3      2965.68 (   0.00%)     3036.75 (  -2.40%)
Amean     fault-both-5      3995.90 (   0.00%)     4522.24 * -13.17%*
Amean     fault-both-7      5842.12 (   0.00%)     6365.35 (  -8.96%)
Amean     fault-both-12     9550.87 (   0.00%)    10340.93 (  -8.27%)
Amean     fault-both-18    13304.72 (   0.00%)    14732.46 ( -10.73%)
Amean     fault-both-24    14618.59 (   0.00%)    16288.96 ( -11.43%)
Amean     fault-both-30    16650.96 (   0.00%)    16346.21 (   1.83%)
Amean     fault-both-32    17145.15 (   0.00%)    19317.49 ( -12.67%)

The impact to latency is higher than the last version but it appears to
be due to a slight increase in the free scan rates which is a potential
side-effect of the patch. However, this is necessary for later patches that
are more careful about how pageblocks are treated as earlier iterations
of those patches hit corner cases where the restarts were punishing and
very visible.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 27 ++++++++++-----------------
 1 file changed, 10 insertions(+), 17 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 293d9a9e6f00..04ec7d4da719 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -330,10 +330,9 @@ static void update_cached_migrate(struct compact_control *cc, unsigned long pfn)
  * future. The information is later cleared by __reset_isolation_suitable().
  */
 static void update_pageblock_skip(struct compact_control *cc,
-			struct page *page, unsigned long nr_isolated)
+			struct page *page, unsigned long pfn)
 {
 	struct zone *zone = cc->zone;
-	unsigned long pfn;
 
 	if (cc->no_set_skip_hint)
 		return;
@@ -341,13 +340,8 @@ static void update_pageblock_skip(struct compact_control *cc,
 	if (!page)
 		return;
 
-	if (nr_isolated)
-		return;
-
 	set_pageblock_skip(page);
 
-	pfn = page_to_pfn(page);
-
 	/* Update where async and sync compaction should restart */
 	if (pfn < zone->compact_cached_free_pfn)
 		zone->compact_cached_free_pfn = pfn;
@@ -365,7 +359,7 @@ static inline bool pageblock_skip_persistent(struct page *page)
 }
 
 static inline void update_pageblock_skip(struct compact_control *cc,
-			struct page *page, unsigned long nr_isolated)
+			struct page *page, unsigned long pfn)
 {
 }
 
@@ -449,7 +443,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 				bool strict)
 {
 	int nr_scanned = 0, total_isolated = 0;
-	struct page *cursor, *valid_page = NULL;
+	struct page *cursor;
 	unsigned long flags = 0;
 	bool locked = false;
 	unsigned long blockpfn = *start_pfn;
@@ -476,9 +470,6 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 		if (!pfn_valid_within(blockpfn))
 			goto isolate_fail;
 
-		if (!valid_page)
-			valid_page = page;
-
 		/*
 		 * For compound pages such as THP and hugetlbfs, we can save
 		 * potentially a lot of iterations if we skip them at once.
@@ -566,10 +557,6 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 	if (strict && blockpfn < end_pfn)
 		total_isolated = 0;
 
-	/* Update the pageblock-skip if the whole pageblock was scanned */
-	if (blockpfn == end_pfn)
-		update_pageblock_skip(cc, valid_page, total_isolated);
-
 	cc->total_free_scanned += nr_scanned;
 	if (total_isolated)
 		count_compact_events(COMPACTISOLATED, total_isolated);
@@ -1293,8 +1280,10 @@ fast_isolate_freepages(struct compact_control *cc)
 		}
 	}
 
-	if (highest && highest > cc->zone->compact_cached_free_pfn)
+	if (highest && highest >= cc->zone->compact_cached_free_pfn) {
+		highest -= pageblock_nr_pages;
 		cc->zone->compact_cached_free_pfn = highest;
+	}
 
 	cc->total_free_scanned += nr_scanned;
 	if (!page)
@@ -1374,6 +1363,10 @@ static void isolate_freepages(struct compact_control *cc)
 		isolate_freepages_block(cc, &isolate_start_pfn, block_end_pfn,
 					freelist, false);
 
+		/* Update the skip hint if the full pageblock was scanned */
+		if (isolate_start_pfn == block_end_pfn)
+			update_pageblock_skip(cc, page, block_start_pfn);
+
 		/* Are enough freepages isolated? */
 		if (cc->nr_freepages >= cc->nr_migratepages) {
 			if (isolate_start_pfn >= block_end_pfn) {
-- 
2.16.4
