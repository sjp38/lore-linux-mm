Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3F1856B006E
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 07:34:38 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fb1so52074155pad.10
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 04:34:38 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id fv6si13635104pdb.108.2015.01.30.04.34.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 Jan 2015 04:34:37 -0800 (PST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so51905333pab.5
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 04:34:37 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v2 2/4] mm/compaction: stop the isolation when we isolate enough freepage
Date: Fri, 30 Jan 2015 21:34:10 +0900
Message-Id: <1422621252-29859-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1422621252-29859-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1422621252-29859-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo <iamjoonsoo.kim@lge.com>

Currently, freepage isolation in one pageblock doesn't consider how many
freepages we isolate. When I traced flow of compaction, compaction
sometimes isolates more than 256 freepages to migrate just 32 pages.

In this patch, freepage isolation is stopped at the point that we
have more isolated freepage than isolated page for migration. This
results in slowing down free page scanner and make compaction success
rate higher.

stress-highalloc test in mmtests with non movable order 7 allocation shows
increase of compaction success rate.

Compaction success rate (Compaction success * 100 / Compaction stalls, %)
27.13 : 31.82

pfn where both scanners meets on compaction complete
(separate test due to enormous tracepoint buffer)
(zone_start=4096, zone_end=1048576)
586034 : 654378

In fact, I didn't fully understand why this patch results in such good
result. There was a guess that not used freepages are released to pcp list
and on next compaction trial we won't isolate them again so compaction
success rate would decrease. To prevent this effect, I tested with adding
pcp drain code on release_freepages(), but, it has no good effect.

Anyway, this patch reduces waste time to isolate unneeded freepages so
seems reasonable.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/compaction.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 4954e19..782772d 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -490,6 +490,13 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 
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
@@ -899,7 +906,6 @@ static void isolate_freepages(struct compact_control *cc)
 	unsigned long isolate_start_pfn; /* exact pfn we start at */
 	unsigned long block_end_pfn;	/* end of current pageblock */
 	unsigned long low_pfn;	     /* lowest pfn scanner is able to scan */
-	int nr_freepages = cc->nr_freepages;
 	struct list_head *freelist = &cc->freepages;
 
 	/*
@@ -924,11 +930,11 @@ static void isolate_freepages(struct compact_control *cc)
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
@@ -953,9 +959,8 @@ static void isolate_freepages(struct compact_control *cc)
 			continue;
 
 		/* Found a block suitable for isolating free pages from. */
-		isolated = isolate_freepages_block(cc, &isolate_start_pfn,
+		isolate_freepages_block(cc, &isolate_start_pfn,
 					block_end_pfn, freelist, false);
-		nr_freepages += isolated;
 
 		/*
 		 * Remember where the free scanner should restart next time,
@@ -987,8 +992,6 @@ static void isolate_freepages(struct compact_control *cc)
 	 */
 	if (block_start_pfn < low_pfn)
 		cc->free_pfn = cc->migrate_pfn;
-
-	cc->nr_freepages = nr_freepages;
 }
 
 /*
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
