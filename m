Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8B24882F5F
	for <linux-mm@kvack.org>; Sun, 23 Aug 2015 22:20:36 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so6522429pac.1
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 19:20:36 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id n5si24994269pda.156.2015.08.23.19.20.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Aug 2015 19:20:35 -0700 (PDT)
Received: by pacdd16 with SMTP id dd16so84912936pac.2
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 19:20:35 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v2 9/9] mm/compaction: new threshold for compaction depleted zone
Date: Mon, 24 Aug 2015 11:19:33 +0900
Message-Id: <1440382773-16070-10-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, compaction algorithm become powerful. Migration scanner traverses
whole zone range. So, old threshold for depleted zone which is designed
to imitate compaction deferring approach isn't appropriate for current
compaction algorithm. If we adhere to current threshold, 1, we can't
avoid excessive overhead caused by compaction, because one compaction
for low order allocation would be easily successful in any situation.

This patch re-implements threshold calculation based on zone size and
allocation requested order. We judge whther compaction possibility is
depleted or not by number of successful compaction. Roughly, 1/100
of future scanned area should be allocated for high order page during
one comaction iteration in order to determine whether zone's compaction
possiblity is depleted or not.

Below is test result with following setup.

Memory is artificially fragmented to make order 3 allocation hard. And,
most of pageblocks are changed to movable migratetype.

  System: 512 MB with 32 MB Zram
  Memory: 25% memory is allocated to make fragmentation and 200 MB is
  	occupied by memory hogger. Most pageblocks are movable
  	migratetype.
  Fragmentation: Successful order 3 allocation candidates may be around
  	1500 roughly.
  Allocation attempts: Roughly 3000 order 3 allocation attempts
  	with GFP_NORETRY. This value is determined to saturate allocation
  	success.

Test: hogger-frag-movable

Success(N)                    94              83
compact_stall               3642            4048
compact_success              144             212
compact_fail                3498            3835
pgmigrate_success       15897219          216387
compact_isolated        31899553          487712
compact_migrate_scanned 59146745         2513245
compact_free_scanned    49566134         4124319

This change results in greatly decreasing compaction overhead when
zone's compaction possibility is nearly depleted. But, I should admit
that it's not perfect because compaction success rate is decreased.
More precise tuning threshold would restore this regression, but,
it highly depends on workload so I'm not doing it here.

Other test doesn't show big regression.

  System: 512 MB with 32 MB Zram
  Memory: 25% memory is allocated to make fragmentation and kernel
  	build is running on background. Most pageblocks are movable
  	migratetype.
  Fragmentation: Successful order 3 allocation candidates may be around
  	1500 roughly.
  Allocation attempts: Roughly 3000 order 3 allocation attempts
  	with GFP_NORETRY. This value is determined to saturate allocation
  	success.

Test: build-frag-movable

Success(N)                    89              87
compact_stall               4053            3642
compact_success              264             202
compact_fail                3788            3440
pgmigrate_success        6497642          153413
compact_isolated        13292640          353445
compact_migrate_scanned 69714502         2307433
compact_free_scanned    20243121         2325295

This looks like reasonable trade-off.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/compaction.c | 19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index e61ee77..e1b44a5 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -129,19 +129,24 @@ static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
 
 /* Do not skip compaction more than 64 times */
 #define COMPACT_MAX_FAILED 4
-#define COMPACT_MIN_DEPLETE_THRESHOLD 1UL
+#define COMPACT_MIN_DEPLETE_THRESHOLD 4UL
 #define COMPACT_MIN_SCAN_LIMIT (pageblock_nr_pages)
 
 static bool compaction_depleted(struct zone *zone)
 {
-	unsigned long threshold;
+	unsigned long nr_possible;
 	unsigned long success = zone->compact_success;
+	unsigned long threshold;
 
-	/*
-	 * Now, to imitate current compaction deferring approach,
-	 * choose threshold to 1. It will be changed in the future.
-	 */
-	threshold = COMPACT_MIN_DEPLETE_THRESHOLD;
+	nr_possible = zone->managed_pages >> zone->compact_order_failed;
+
+	/* Migration scanner normally scans less than 1/4 range of zone */
+	nr_possible >>= 2;
+
+	/* We hope to succeed more than 1/100 roughly */
+	threshold = nr_possible >> 7;
+
+	threshold = max(threshold, COMPACT_MIN_DEPLETE_THRESHOLD);
 	if (success >= threshold)
 		return false;
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
