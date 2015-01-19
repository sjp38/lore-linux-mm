Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1356B0070
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 05:05:54 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id r20so7457962wiv.4
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 02:05:53 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r3si20290063wic.39.2015.01.19.02.05.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 Jan 2015 02:05:42 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 3/5] mm, compaction: encapsulate resetting cached scanner positions
Date: Mon, 19 Jan 2015 11:05:18 +0100
Message-Id: <1421661920-4114-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1421661920-4114-1-git-send-email-vbabka@suse.cz>
References: <1421661920-4114-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

Reseting the cached compaction scanner positions is now done implicitly in
__reset_isolation_suitable() and compact_finished(). Encapsulate the
functionality in a new function reset_cached_positions() and call it
explicitly where needed.

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
index 45799a4..5626220 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -123,6 +123,13 @@ static inline bool isolation_suitable(struct compact_control *cc,
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
@@ -134,9 +141,6 @@ static void __reset_isolation_suitable(struct zone *zone)
 	unsigned long end_pfn = zone_end_pfn(zone);
 	unsigned long pfn;
 
-	zone->compact_cached_migrate_pfn[0] = start_pfn;
-	zone->compact_cached_migrate_pfn[1] = start_pfn;
-	zone->compact_cached_free_pfn = end_pfn;
 	zone->compact_blockskip_flush = false;
 
 	/* Walk the zone and mark every pageblock as suitable for isolation */
@@ -166,8 +170,10 @@ void reset_isolation_suitable(pg_data_t *pgdat)
 			continue;
 
 		/* Only flush if a full compaction finished recently */
-		if (zone->compact_blockskip_flush)
+		if (zone->compact_blockskip_flush) {
 			__reset_isolation_suitable(zone);
+			reset_cached_positions(zone);
+		}
 	}
 }
 
@@ -1059,9 +1065,7 @@ static int compact_finished(struct zone *zone, struct compact_control *cc,
 	/* Compaction run completes if the migrate and free scanner meet */
 	if (compact_scanners_met(cc)) {
 		/* Let the next compaction start anew. */
-		zone->compact_cached_migrate_pfn[0] = zone->zone_start_pfn;
-		zone->compact_cached_migrate_pfn[1] = zone->zone_start_pfn;
-		zone->compact_cached_free_pfn = zone_end_pfn(zone);
+		reset_cached_positions(zone);
 
 		/*
 		 * Mark that the PG_migrate_skip information should be cleared
@@ -1187,8 +1191,10 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
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
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
