Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 460C3828F3
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 05:13:00 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id o80so52622607wme.1
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 02:13:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e18si33298120wjz.212.2016.08.10.02.12.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Aug 2016 02:12:45 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v6 08/11] mm, compaction: create compact_gap wrapper
Date: Wed, 10 Aug 2016 11:12:23 +0200
Message-Id: <20160810091226.6709-9-vbabka@suse.cz>
In-Reply-To: <20160810091226.6709-1-vbabka@suse.cz>
References: <20160810091226.6709-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

Compaction uses a watermark gap of (2UL << order) pages at various places and
it's not immediately obvious why. Abstract it through a compact_gap() wrapper
to create a single place with a thorough explanation.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/compaction.h | 16 ++++++++++++++++
 mm/compaction.c            |  7 +++----
 mm/vmscan.c                |  6 +++---
 3 files changed, 22 insertions(+), 7 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index a1fba9994728..e7f0d34a90fe 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -58,6 +58,22 @@ enum compact_result {
 
 struct alloc_context; /* in mm/internal.h */
 
+/*
+ * Number of free order-0 pages that should be available above given watermark
+ * to make sure compaction has reasonable chance of not running out of free
+ * pages that it needs to isolate as migration target during its work.
+ */
+static inline unsigned long compact_gap(unsigned int order)
+{
+	/*
+	 * Although all the isolations for migration are temporary, compaction
+	 * may have up to 1 << order pages on its list and then try to split
+	 * an (order - 1) free page. At that point, a gap of 1 << order might
+	 * not be enough, so it's safer to require twice that amount.
+	 */
+	return 2UL << order;
+}
+
 #ifdef CONFIG_COMPACTION
 extern int sysctl_compact_memory;
 extern int sysctl_compaction_handler(struct ctl_table *table, int write,
diff --git a/mm/compaction.c b/mm/compaction.c
index 9bd788886b1a..ae6ecf8f8e70 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1391,11 +1391,10 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
 		return COMPACT_SUCCESS;
 
 	/*
-	 * Watermarks for order-0 must be met for compaction. Note the 2UL.
-	 * This is because during migration, copies of pages need to be
-	 * allocated and for a short time, the footprint is higher
+	 * Watermarks for order-0 must be met for compaction to be able to
+	 * isolate free pages for migration targets.
 	 */
-	watermark = low_wmark_pages(zone) + (2UL << order);
+	watermark = low_wmark_pages(zone) + compact_gap(order);
 	if (!__zone_watermark_ok(zone, 0, watermark, classzone_idx,
 				 alloc_flags, wmark_target))
 		return COMPACT_SKIPPED;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c84784765d3a..b676b4b51db0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2499,7 +2499,7 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 	 * If we have not reclaimed enough pages for compaction and the
 	 * inactive lists are large enough, continue reclaiming
 	 */
-	pages_for_compaction = (2UL << sc->order);
+	pages_for_compaction = compact_gap(sc->order);
 	inactive_lru_pages = node_page_state(pgdat, NR_INACTIVE_FILE);
 	if (get_nr_swap_pages() > 0)
 		inactive_lru_pages += node_page_state(pgdat, NR_INACTIVE_ANON);
@@ -2631,7 +2631,7 @@ static inline bool compaction_ready(struct zone *zone, struct scan_control *sc)
 	 * there is a buffer of free pages available to give compaction
 	 * a reasonable chance of completing and allocating the page
 	 */
-	watermark = high_wmark_pages(zone) + (2UL << sc->order);
+	watermark = high_wmark_pages(zone) + compact_gap(sc->order);
 	watermark_ok = zone_watermark_ok_safe(zone, 0, watermark, sc->reclaim_idx);
 
 	/*
@@ -3188,7 +3188,7 @@ static bool kswapd_shrink_node(pg_data_t *pgdat,
 	 * excessive reclaim. Assume that a process requested a high-order
 	 * can direct reclaim/compact.
 	 */
-	if (sc->order && sc->nr_reclaimed >= 2UL << sc->order)
+	if (sc->order && sc->nr_reclaimed >= compact_gap(sc->order))
 		sc->order = 0;
 
 	return sc->nr_scanned >= sc->nr_to_reclaim;
-- 
2.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
