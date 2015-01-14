Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 22D9F6B0032
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 06:37:38 -0500 (EST)
Received: by mail-ig0-f182.google.com with SMTP id hn15so8303600igb.3
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 03:37:37 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id ga8si1606392icb.31.2015.01.14.03.37.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jan 2015 03:37:36 -0800 (PST)
From: Vinayak Menon <vinmenon@codeaurora.org>
Subject: [PATCH v2] mm: vmscan: fix the page state calculation in too_many_isolated
Date: Wed, 14 Jan 2015 17:06:59 +0530
Message-Id: <1421235419-30736-1-git-send-email-vinmenon@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, mhocko@suse.cz, mgorman@suse.de, minchan@kernel.org, Vinayak Menon <vinmenon@codeaurora.org>

It is observed that sometimes multiple tasks get blocked for long
in the congestion_wait loop below, in shrink_inactive_list. This
is because of vm_stat values not being synced.

(__schedule) from [<c0a03328>]
(schedule_timeout) from [<c0a04940>]
(io_schedule_timeout) from [<c01d585c>]
(congestion_wait) from [<c01cc9d8>]
(shrink_inactive_list) from [<c01cd034>]
(shrink_zone) from [<c01cdd08>]
(try_to_free_pages) from [<c01c442c>]
(__alloc_pages_nodemask) from [<c01f1884>]
(new_slab) from [<c09fcf60>]
(__slab_alloc) from [<c01f1a6c>]

In one such instance, zone_page_state(zone, NR_ISOLATED_FILE)
had returned 14, zone_page_state(zone, NR_INACTIVE_FILE)
returned 92, and GFP_IOFS was set, and this resulted
in too_many_isolated returning true. But one of the CPU's
pageset vm_stat_diff had NR_ISOLATED_FILE as "-14". So the
actual isolated count was zero. As there weren't any more
updates to NR_ISOLATED_FILE and vmstat_update deffered work
had not been scheduled yet, 7 tasks were spinning in the
congestion wait loop for around 4 seconds, in the direct
reclaim path.

This patch uses zone_page_state_snapshot instead, but restricts
its usage to avoid performance penalty.

Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
---
 mm/vmscan.c | 56 +++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 37 insertions(+), 19 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5e8772b..266551f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1392,6 +1392,32 @@ int isolate_lru_page(struct page *page)
 	return ret;
 }
 
+static int __too_many_isolated(struct zone *zone, int file,
+	struct scan_control *sc, int safe)
+{
+	unsigned long inactive, isolated;
+
+	if (safe) {
+		inactive = zone_page_state_snapshot(zone,
+				NR_INACTIVE_ANON + 2 * file);
+		isolated = zone_page_state_snapshot(zone,
+				NR_ISOLATED_ANON + file);
+	} else {
+		inactive = zone_page_state(zone, NR_INACTIVE_ANON + 2 * file);
+		isolated = zone_page_state(zone, NR_ISOLATED_ANON + file);
+	}
+
+	/*
+	 * GFP_NOIO/GFP_NOFS callers are allowed to isolate more pages, so they
+	 * won't get blocked by normal direct-reclaimers, forming a circular
+	 * deadlock.
+	 */
+	if ((sc->gfp_mask & GFP_IOFS) == GFP_IOFS)
+		inactive >>= 3;
+
+	return isolated > inactive;
+}
+
 /*
  * A direct reclaimer may isolate SWAP_CLUSTER_MAX pages from the LRU list and
  * then get resheduled. When there are massive number of tasks doing page
@@ -1400,33 +1426,22 @@ int isolate_lru_page(struct page *page)
  * unnecessary swapping, thrashing and OOM.
  */
 static int too_many_isolated(struct zone *zone, int file,
-		struct scan_control *sc)
+		struct scan_control *sc, int safe)
 {
-	unsigned long inactive, isolated;
-
 	if (current_is_kswapd())
 		return 0;
 
 	if (!global_reclaim(sc))
 		return 0;
 
-	if (file) {
-		inactive = zone_page_state(zone, NR_INACTIVE_FILE);
-		isolated = zone_page_state(zone, NR_ISOLATED_FILE);
-	} else {
-		inactive = zone_page_state(zone, NR_INACTIVE_ANON);
-		isolated = zone_page_state(zone, NR_ISOLATED_ANON);
+	if (unlikely(__too_many_isolated(zone, file, sc, 0))) {
+		if (safe)
+			return __too_many_isolated(zone, file, sc, safe);
+		else
+			return 1;
 	}
 
-	/*
-	 * GFP_NOIO/GFP_NOFS callers are allowed to isolate more pages, so they
-	 * won't get blocked by normal direct-reclaimers, forming a circular
-	 * deadlock.
-	 */
-	if ((sc->gfp_mask & GFP_IOFS) == GFP_IOFS)
-		inactive >>= 3;
-
-	return isolated > inactive;
+	return 0;
 }
 
 static noinline_for_stack void
@@ -1516,15 +1531,18 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	unsigned long nr_immediate = 0;
 	isolate_mode_t isolate_mode = 0;
 	int file = is_file_lru(lru);
+	int safe = 0;
 	struct zone *zone = lruvec_zone(lruvec);
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 
-	while (unlikely(too_many_isolated(zone, file, sc))) {
+	while (unlikely(too_many_isolated(zone, file, sc, safe))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 		/* We are about to die and free our memory. Return now. */
 		if (fatal_signal_pending(current))
 			return SWAP_CLUSTER_MAX;
+
+		safe = 1;
 	}
 
 	lru_add_drain();
-- 
QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
