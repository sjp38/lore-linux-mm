Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id C734382F5F
	for <linux-mm@kvack.org>; Sun, 23 Aug 2015 22:20:15 -0400 (EDT)
Received: by pacti10 with SMTP id ti10so11680910pac.0
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 19:20:15 -0700 (PDT)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com. [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id kk7si21117155pab.28.2015.08.23.19.20.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Aug 2015 19:20:15 -0700 (PDT)
Received: by pdob1 with SMTP id b1so47328218pdo.2
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 19:20:14 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v2 5/9] mm/compaction: allow to scan nonmovable pageblock when depleted state
Date: Mon, 24 Aug 2015 11:19:29 +0900
Message-Id: <1440382773-16070-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Currently, freescanner doesn't scan non-movable pageblock, because if
freepages in non-movable pageblock are exhausted, another movable
pageblock would be used for non-movable allocation and it could cause
fragmentation.

But, we should know that watermark check for compaction doesn't
distinguish where freepage is. If all freepages are in non-movable
pageblock, although, system has enough freepages and watermark check
is passed, freepage scanner can't get any freepage and compaction will
be failed. There is no way to get precise number of freepage on movable
pageblock and no way to reclaim only used pages in movable pageblock.
Therefore, I think that best way to overcome this situation is
to use freepage in non-movable pageblock in compaction.

My test setup for this situation is:

Memory is artificially fragmented to make order 3 allocation hard. And,
most of pageblocks are changed to unmovable migratetype.

  System: 512 MB with 32 MB Zram
  Memory: 25% memory is allocated to make fragmentation and kernel build
  	is running on background.
  Fragmentation: Successful order 3 allocation candidates may be around
  	1500 roughly.
  Allocation attempts: Roughly 3000 order 3 allocation attempts
  	with GFP_NORETRY. This value is determined to saturate allocation
  	success.

Below is the result of this test.

Test: build-frag-unmovable

Kernel:	Base vs Nonmovable

Success(N)                    37              64
compact_stall                624            5056
compact_success              103             419
compact_fail                 521            4637
pgmigrate_success          22004          277106
compact_isolated           61021         1056863
compact_migrate_scanned  2609360        70252458
compact_free_scanned     4808989        23091292

Column 'Success(N) are calculated by following equations.

Success(N) = successful allocation * 100 / order 3 candidates

Result shows that success rate is roughly doubled in this case
because we can search more area.

Because we just allow freepage scanner to scan non-movable pageblock
in very limited situation, more scanning events happen. But, allowing
in very limited situation results in a very important benefit that
memory isn't fragmented more than before. Fragmentation effect is
measured on following patch so please refer it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/mmzone.h |  1 +
 mm/compaction.c        | 27 +++++++++++++++++++++++++--
 2 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index e13b732..5cae0ad 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -545,6 +545,7 @@ enum zone_flags {
 					 */
 	ZONE_FAIR_DEPLETED,		/* fair zone policy batch depleted */
 	ZONE_COMPACTION_DEPLETED,	/* compaction possiblity depleted */
+	ZONE_COMPACTION_SCANALLFREE,	/* scan all kinds of pageblocks */
 };
 
 static inline unsigned long zone_end_pfn(const struct zone *zone)
diff --git a/mm/compaction.c b/mm/compaction.c
index 1817564..b58f162 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -243,9 +243,17 @@ static void __reset_isolation_suitable(struct zone *zone)
 	zone->compact_cached_free_pfn = end_pfn;
 	zone->compact_blockskip_flush = false;
 
+	clear_bit(ZONE_COMPACTION_SCANALLFREE, &zone->flags);
 	if (compaction_depleted(zone)) {
 		if (test_bit(ZONE_COMPACTION_DEPLETED, &zone->flags))
 			zone->compact_depletion_depth++;
+
+			/* Last resort to make high-order page */
+			if (!zone->compact_success) {
+				set_bit(ZONE_COMPACTION_SCANALLFREE,
+					&zone->flags);
+			}
+
 		else {
 			set_bit(ZONE_COMPACTION_DEPLETED, &zone->flags);
 			zone->compact_depletion_depth = 0;
@@ -914,7 +922,8 @@ isolate_migratepages_range(struct compact_control *cc, unsigned long start_pfn,
 #ifdef CONFIG_COMPACTION
 
 /* Returns true if the page is within a block suitable for migration to */
-static bool suitable_migration_target(struct page *page)
+static bool suitable_migration_target(struct compact_control *cc,
+					struct page *page)
 {
 	/* If the page is a large free page, then disallow migration */
 	if (PageBuddy(page)) {
@@ -931,6 +940,16 @@ static bool suitable_migration_target(struct page *page)
 	if (migrate_async_suitable(get_pageblock_migratetype(page)))
 		return true;
 
+	/*
+	 * Allow to scan all kinds of pageblock. Without this relaxation,
+	 * all freepage could be in non-movable pageblock and compaction
+	 * can be satuarated and cannot make high-order page even if there
+	 * is enough freepage in the system.
+	 */
+	if (cc->mode != MIGRATE_ASYNC &&
+		test_bit(ZONE_COMPACTION_SCANALLFREE, &cc->zone->flags))
+		return true;
+
 	/* Otherwise skip the block */
 	return false;
 }
@@ -992,7 +1011,7 @@ static void isolate_freepages(struct compact_control *cc)
 			continue;
 
 		/* Check the block is suitable for migration */
-		if (!suitable_migration_target(page))
+		if (!suitable_migration_target(cc, page))
 			continue;
 
 		/* If isolation recently failed, do not retry */
@@ -1494,6 +1513,10 @@ out:
 	if (test_bit(ZONE_COMPACTION_DEPLETED, &zone->flags)) {
 		if (!compaction_depleted(zone))
 			clear_bit(ZONE_COMPACTION_DEPLETED, &zone->flags);
+
+		if (zone->compact_success &&
+			test_bit(ZONE_COMPACTION_SCANALLFREE, &zone->flags))
+			clear_bit(ZONE_COMPACTION_SCANALLFREE, &zone->flags);
 	}
 
 	return ret;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
