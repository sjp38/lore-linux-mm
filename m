Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id D5E6C6B025B
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 11:28:35 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so38765485wib.0
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 08:28:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b13si8971013wjr.104.2015.07.31.08.28.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 31 Jul 2015 08:28:25 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 3/5] mm, compaction: encapsulate resetting cached scanner positions
Date: Fri, 31 Jul 2015 17:28:05 +0200
Message-Id: <1438356487-7082-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1438356487-7082-1-git-send-email-vbabka@suse.cz>
References: <1438356487-7082-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Michal Nazarewicz <mina86@mina86.com>

Reseting the cached compaction scanner positions is now open-coded in
__reset_isolation_suitable() and compact_finished(). Encapsulate the
functionality in a new function reset_cached_positions().

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Acked-by: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 7e0a814..07b6104 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -207,6 +207,13 @@ static inline bool isolation_suitable(struct compact_control *cc,
 	return !get_pageblock_skip(page);
 }
 
+static void reset_cached_positions(struct zone *zone)
+{
+	zone->compact_cached_migrate_pfn[0] = zone->zone_start_pfn;
+	zone->compact_cached_migrate_pfn[1] = zone->zone_start_pfn;
+	zone->compact_cached_free_pfn = zone_end_pfn(zone);
+}
+
 /*
  * This function is called to clear all cached information on pageblocks that
  * should be skipped for page isolation when the migrate and free page scanner
@@ -218,9 +225,6 @@ static void __reset_isolation_suitable(struct zone *zone)
 	unsigned long end_pfn = zone_end_pfn(zone);
 	unsigned long pfn;
 
-	zone->compact_cached_migrate_pfn[0] = start_pfn;
-	zone->compact_cached_migrate_pfn[1] = start_pfn;
-	zone->compact_cached_free_pfn = end_pfn;
 	zone->compact_blockskip_flush = false;
 
 	/* Walk the zone and mark every pageblock as suitable for isolation */
@@ -238,6 +242,8 @@ static void __reset_isolation_suitable(struct zone *zone)
 
 		clear_pageblock_skip(page);
 	}
+
+	reset_cached_positions(zone);
 }
 
 void reset_isolation_suitable(pg_data_t *pgdat)
@@ -1164,9 +1170,7 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
 	/* Compaction run completes if the migrate and free scanner meet */
 	if (compact_scanners_met(cc)) {
 		/* Let the next compaction start anew. */
-		zone->compact_cached_migrate_pfn[0] = zone->zone_start_pfn;
-		zone->compact_cached_migrate_pfn[1] = zone->zone_start_pfn;
-		zone->compact_cached_free_pfn = zone_end_pfn(zone);
+		reset_cached_positions(zone);
 
 		/*
 		 * Mark that the PG_migrate_skip information should be cleared
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
