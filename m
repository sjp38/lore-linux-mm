Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 060F96B0074
	for <linux-mm@kvack.org>; Wed, 24 Jun 2015 20:43:09 -0400 (EDT)
Received: by pdbci14 with SMTP id ci14so41152036pdb.2
        for <linux-mm@kvack.org>; Wed, 24 Jun 2015 17:43:08 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id l9si42249635pdj.235.2015.06.24.17.42.55
        for <linux-mm@kvack.org>;
        Wed, 24 Jun 2015 17:42:56 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH 10/10] mm/compaction: new threshold for compaction depleted zone
Date: Thu, 25 Jun 2015 09:45:21 +0900
Message-Id: <1435193121-25880-11-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
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
most of pageblocks are changed to unmovable migratetype.

  System: 512 MB with 32 MB Zram
  Memory: 25% memory is allocated to make fragmentation and 200 MB is
  	occupied by memory hogger. Most pageblocks are unmovable
  	migratetype.
  Fragmentation: Successful order 3 allocation candidates may be around
  	1500 roughly.
  Allocation attempts: Roughly 3000 order 3 allocation attempts
  	with GFP_NORETRY. This value is determined to saturate allocation
  	success.

Test: hogger-frag-unmovable
                                  redesign  threshold
compact_free_scanned               6441095    2235764
compact_isolated                   2711081     647701
compact_migrate_scanned            4175464    1697292
compact_stall                         2059       2092
compact_success                        207        210
pgmigrate_success                  1348113     318395
Success:                                44         40
Success(N):                             90         83

This change results in greatly decreasing compaction overhead when
zone's compaction possibility is nearly depleted. But, I should admit
that it's not perfect because compaction success rate is decreased.
More precise tuning threshold would restore this regression, but,
it highly depends on workload so I'm not doing it here.

Other test doesn't show any regression.

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
                                  redesign  threshold
compact_free_scanned               2359553    1461131
compact_isolated                    907515     387373
compact_migrate_scanned            3785605    2177090
compact_stall                         2195       2157
compact_success                        247        225
pgmigrate_success                   439739     182366
Success:                                43         43
Success(N):                             89         90

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/compaction.c | 19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 99f533f..63702b3 100644
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
+	/* Migration scanner can scans more than 1/4 range of zone */
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
