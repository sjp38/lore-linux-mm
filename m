Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3A5076B006E
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 05:05:50 -0500 (EST)
Received: by mail-we0-f172.google.com with SMTP id k11so30427951wes.3
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 02:05:49 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u8si2803641wia.105.2015.01.19.02.05.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 Jan 2015 02:05:42 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 5/5] mm, compaction: set pivot pfn to the pfn when scanners met last time
Date: Mon, 19 Jan 2015 11:05:20 +0100
Message-Id: <1421661920-4114-6-git-send-email-vbabka@suse.cz>
In-Reply-To: <1421661920-4114-1-git-send-email-vbabka@suse.cz>
References: <1421661920-4114-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

The previous patch has prepared compaction scanners to start at arbitrary
pivot pfn within the zone, but left the pivot at the first pfn of the zone.
This patch introduces actual changing of the pivot pfn.

Our goal is to remove the bias in compaction under memory pressure, where
the migration scanner scans only the first half (or less) of the zone where
it cannot succeed anymore. At the same time we want to avoid frequent changes
of the pivot which would result in migrating pages back and forth without much
benefit. So the question is how often to change the pivot, and to which pfn
it should be set.

Another thing to consider is that the scanners mark pageblocks as unsuitable
for scanning via update_pageblock_skip(), which is a single bit per pageblock.
However, pageblock being unsuitable as a source of free pages is completely
different condition from pageblock being unsuitable as the source of
migratable pages. Thus, changing the pivot should be accompanied with
resetting the skip bits. The resetting is currently done either when kswapd
goes to sleep, or when compaction is being restarted from the longest possible
deferred compaction period.

Thus as a conservative first step, this patch does not increase the frequency
of skip bits resetting, and ties changing the pivot only to the situations
where compaction is restarted from being deferred. This happens when
compaction has failed a lot with the previous pivot, and most pageblocks were
already marked as unsuitable. Thus, most migrations occured relatively long
ago and we are not going to frequently migrate back and forth.

The pivot position is simply set to the pageblock where the scanners have met
during the last finished compaction. This means that migration scanner will
immediately scan pageblocks that it couldn't reach with the previous pivot.

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
 include/linux/mmzone.h |  2 ++
 mm/compaction.c        | 22 +++++++++++++++++-----
 2 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 47aa181..7801886 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -505,6 +505,8 @@ struct zone {
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
 	/* pfn where compaction scanners have initially started last time */
 	unsigned long		compact_cached_pivot_pfn;
+	/* pfn where compaction scanners have met last time */
+	unsigned long		compact_cached_last_met_pfn;
 	/* pfn where compaction free scanner should start */
 	unsigned long		compact_cached_free_pfn;
 	/* pfn where async and sync compaction migration scanner should start */
diff --git a/mm/compaction.c b/mm/compaction.c
index abae89a..70792c5 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -125,10 +125,16 @@ static inline bool isolation_suitable(struct compact_control *cc,
 
 /*
  * Invalidate cached compaction scanner positions, so that compact_zone()
- * will reinitialize them on the next compaction.
+ * will reinitialize them on the next compaction. Optionally reset the
+ * initial pivot position for the scanners to the position where the scanners
+ * have met the last time.
  */
-static void reset_cached_positions(struct zone *zone)
+static void reset_cached_positions(struct zone *zone, bool update_pivot)
 {
+	if (update_pivot)
+		zone->compact_cached_pivot_pfn =
+					zone->compact_cached_last_met_pfn;
+
 	/* Invalid values are re-initialized in compact_zone */
 	zone->compact_cached_migrate_pfn[0] = 0;
 	zone->compact_cached_migrate_pfn[1] = 0;
@@ -1193,7 +1199,13 @@ static int compact_finished(struct zone *zone, struct compact_control *cc,
 	/* Compaction run completes if the migrate and free scanner meet */
 	if (compact_scanners_met(cc)) {
 		/* Let the next compaction start anew. */
-		reset_cached_positions(zone);
+		reset_cached_positions(zone, false);
+		/* 
+		 * Remember where compaction scanners met for the next time
+		 * the pivot pfn is changed.
+		 */
+		zone->compact_cached_last_met_pfn =
+				cc->migrate_pfn & ~(pageblock_nr_pages-1);
 
 		/*
 		 * Mark that the PG_migrate_skip information should be cleared
@@ -1321,7 +1333,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	 */
 	if (compaction_restarting(zone, cc->order) && !current_is_kswapd()) {
 		__reset_isolation_suitable(zone);
-		reset_cached_positions(zone);
+		reset_cached_positions(zone, true);
 	}
 
 	/*
@@ -1334,7 +1346,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		cc->pivot_pfn = start_pfn;
 		zone->compact_cached_pivot_pfn = cc->pivot_pfn;
 		/* When starting position was invalid, reset the rest */
-		reset_cached_positions(zone);
+		reset_cached_positions(zone, false);
 	}
 
 	cc->migrate_pfn = zone->compact_cached_migrate_pfn[sync];
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
