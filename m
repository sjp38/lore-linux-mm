Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 49B106B006E
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 05:33:24 -0400 (EDT)
Received: by wgez8 with SMTP id z8so31118432wge.0
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 02:33:23 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m8si16754494wje.41.2015.06.10.02.33.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Jun 2015 02:33:19 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 3/6] mm, compaction: encapsulate resetting cached scanner positions
Date: Wed, 10 Jun 2015 11:32:31 +0200
Message-Id: <1433928754-966-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1433928754-966-1-git-send-email-vbabka@suse.cz>
References: <1433928754-966-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

Resetting the cached compaction scanner positions is now done implicitly in
__reset_isolation_suitable() and compact_finished(). Encapsulate the
functionality in a new function reset_cached_positions() and call it explicitly
where needed.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 7e0a814..d334bb3 100644
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
@@ -250,8 +254,10 @@ void reset_isolation_suitable(pg_data_t *pgdat)
 			continue;
 
 		/* Only flush if a full compaction finished recently */
-		if (zone->compact_blockskip_flush)
+		if (zone->compact_blockskip_flush) {
 			__reset_isolation_suitable(zone);
+			reset_cached_positions(zone);
+		}
 	}
 }
 
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
@@ -1329,8 +1333,10 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	 * is about to be retried after being deferred. kswapd does not do
 	 * this reset as it'll reset the cached information when going to sleep.
 	 */
-	if (compaction_restarting(zone, cc->order) && !current_is_kswapd())
+	if (compaction_restarting(zone, cc->order) && !current_is_kswapd()) {
 		__reset_isolation_suitable(zone);
+		reset_cached_positions(zone);
+	}
 
 	/*
 	 * Setup to move all movable pages to the end of the zone. Used cached
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
