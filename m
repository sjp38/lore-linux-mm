Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0659E6B0070
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 02:12:45 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id et14so4701515pad.17
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 23:12:44 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ou3si58515607pdb.230.2014.12.07.23.12.40
        for <linux-mm@kvack.org>;
        Sun, 07 Dec 2014 23:12:41 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 4/4] mm/compaction: stop the isolation when we isolate enough freepage
Date: Mon,  8 Dec 2014 16:16:20 +0900
Message-Id: <1418022980-4584-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1418022980-4584-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1418022980-4584-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

From: Joonsoo Kim <js1304@gmail.com>

Currently, freepage isolation in one pageblock doesn't consider how many
freepages we isolate. When I traced flow of compaction, compaction
sometimes isolates more than 256 freepages to migrate just 32 pages.

In this patch, freepage isolation is stopped at the point that we
have more isolated freepage than isolated page for migration. This
results in slowing down free page scanner and make compaction success
rate higher.

stress-highalloc test in mmtests with non movable order 7 allocation shows
increase of compaction success rate and slight improvement of allocation
success rate.

Allocation success rate on phase 1 (%)
62.70 : 64.00

Compaction success rate (Compaction success * 100 / Compaction stalls, %)
35.13 : 41.50

pfn where both scanners meets on compaction complete
(separate test due to enormous tracepoint buffer)
(zone_start=4096, zone_end=1048576)
586034 : 654378

Signed-off-by: Joonsoo Kim <js1304@gmail.com>
---
 mm/compaction.c |   17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 2fd5f79..12223b9 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -422,6 +422,13 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 
 		/* If a page was split, advance to the end of it */
 		if (isolated) {
+			cc->nr_freepages += isolated;
+			if (!strict &&
+				cc->nr_migratepages <= cc->nr_freepages) {
+				blockpfn += isolated;
+				break;
+			}
+
 			blockpfn += isolated - 1;
 			cursor += isolated - 1;
 			continue;
@@ -831,7 +838,6 @@ static void isolate_freepages(struct compact_control *cc)
 	unsigned long isolate_start_pfn; /* exact pfn we start at */
 	unsigned long block_end_pfn;	/* end of current pageblock */
 	unsigned long low_pfn;	     /* lowest pfn scanner is able to scan */
-	int nr_freepages = cc->nr_freepages;
 	struct list_head *freelist = &cc->freepages;
 
 	/*
@@ -856,11 +862,11 @@ static void isolate_freepages(struct compact_control *cc)
 	 * pages on cc->migratepages. We stop searching if the migrate
 	 * and free page scanners meet or enough free pages are isolated.
 	 */
-	for (; block_start_pfn >= low_pfn && cc->nr_migratepages > nr_freepages;
+	for (; block_start_pfn >= low_pfn &&
+			cc->nr_migratepages > cc->nr_freepages;
 				block_end_pfn = block_start_pfn,
 				block_start_pfn -= pageblock_nr_pages,
 				isolate_start_pfn = block_start_pfn) {
-		unsigned long isolated;
 
 		/*
 		 * This can iterate a massively long zone without finding any
@@ -885,9 +891,8 @@ static void isolate_freepages(struct compact_control *cc)
 			continue;
 
 		/* Found a block suitable for isolating free pages from. */
-		isolated = isolate_freepages_block(cc, &isolate_start_pfn,
+		isolate_freepages_block(cc, &isolate_start_pfn,
 					block_end_pfn, freelist, false);
-		nr_freepages += isolated;
 
 		/*
 		 * Remember where the free scanner should restart next time,
@@ -919,8 +924,6 @@ static void isolate_freepages(struct compact_control *cc)
 	 */
 	if (block_start_pfn < low_pfn)
 		cc->free_pfn = cc->migrate_pfn;
-
-	cc->nr_freepages = nr_freepages;
 }
 
 /*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
