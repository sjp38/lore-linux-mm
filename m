Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 148406B0069
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 05:37:12 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id ez4so12901588wjd.2
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 02:37:12 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id w110si24513091wrc.16.2017.01.17.02.37.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 02:37:10 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id d140so21019758wmd.2
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 02:37:10 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/3] mm, vmscan: cleanup lru size claculations
Date: Tue, 17 Jan 2017 11:37:00 +0100
Message-Id: <20170117103702.28542-2-mhocko@kernel.org>
In-Reply-To: <20170117103702.28542-1-mhocko@kernel.org>
References: <20170117103702.28542-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

lruvec_lru_size returns the full size of the LRU list while we sometimes
need a value reduced only to eligible zones (e.g. for lowmem requests).
inactive_list_is_low is one such user. Later patches will add more of
them. Add a new parameter to lruvec_lru_size and allow it filter out
zones which are not eligible for the given context.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
Acked-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mmzone.h |  2 +-
 mm/vmscan.c            | 89 +++++++++++++++++++++++++-------------------------
 mm/workingset.c        |  2 +-
 3 files changed, 46 insertions(+), 47 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d1d440cff60e..91f69aa0d581 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -780,7 +780,7 @@ static inline struct pglist_data *lruvec_pgdat(struct lruvec *lruvec)
 #endif
 }
 
-extern unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru);
+extern unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru, int zone_idx);
 
 #ifdef CONFIG_HAVE_MEMORY_PRESENT
 void memory_present(int nid, unsigned long start, unsigned long end);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index cf940af609fd..aed39dc272c0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -234,22 +234,39 @@ bool pgdat_reclaimable(struct pglist_data *pgdat)
 		pgdat_reclaimable_pages(pgdat) * 6;
 }
 
-unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru)
+/**
+ * lruvec_lru_size -  Returns the number of pages on the given LRU list.
+ * @lruvec: lru vector
+ * @lru: lru to use
+ * @zone_idx: zones to consider (use MAX_NR_ZONES for the whole LRU list)
+ */
+unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru, int zone_idx)
 {
+	unsigned long lru_size;
+	int zid;
+
 	if (!mem_cgroup_disabled())
-		return mem_cgroup_get_lru_size(lruvec, lru);
+		lru_size = mem_cgroup_get_lru_size(lruvec, lru);
+	else
+		lru_size = node_page_state(lruvec_pgdat(lruvec), NR_LRU_BASE + lru);
 
-	return node_page_state(lruvec_pgdat(lruvec), NR_LRU_BASE + lru);
-}
+	for (zid = zone_idx + 1; zid < MAX_NR_ZONES; zid++) {
+		struct zone *zone = &lruvec_pgdat(lruvec)->node_zones[zid];
+		unsigned long size;
 
-unsigned long lruvec_zone_lru_size(struct lruvec *lruvec, enum lru_list lru,
-				   int zone_idx)
-{
-	if (!mem_cgroup_disabled())
-		return mem_cgroup_get_zone_lru_size(lruvec, lru, zone_idx);
+		if (!managed_zone(zone))
+			continue;
+
+		if (!mem_cgroup_disabled())
+			size = mem_cgroup_get_zone_lru_size(lruvec, lru, zid);
+		else
+			size = zone_page_state(&lruvec_pgdat(lruvec)->node_zones[zid],
+				       NR_ZONE_LRU_BASE + lru);
+		lru_size -= min(size, lru_size);
+	}
+
+	return lru_size;
 
-	return zone_page_state(&lruvec_pgdat(lruvec)->node_zones[zone_idx],
-			       NR_ZONE_LRU_BASE + lru);
 }
 
 /*
@@ -2051,11 +2068,10 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 						struct scan_control *sc, bool trace)
 {
 	unsigned long inactive_ratio;
-	unsigned long total_inactive, inactive;
-	unsigned long total_active, active;
+	unsigned long inactive, active;
+	enum lru_list inactive_lru = file * LRU_FILE;
+	enum lru_list active_lru = file * LRU_FILE + LRU_ACTIVE;
 	unsigned long gb;
-	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
-	int zid;
 
 	/*
 	 * If we don't have swap space, anonymous page deactivation
@@ -2064,27 +2080,8 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 	if (!file && !total_swap_pages)
 		return false;
 
-	total_inactive = inactive = lruvec_lru_size(lruvec, file * LRU_FILE);
-	total_active = active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE);
-
-	/*
-	 * For zone-constrained allocations, it is necessary to check if
-	 * deactivations are required for lowmem to be reclaimed. This
-	 * calculates the inactive/active pages available in eligible zones.
-	 */
-	for (zid = sc->reclaim_idx + 1; zid < MAX_NR_ZONES; zid++) {
-		struct zone *zone = &pgdat->node_zones[zid];
-		unsigned long inactive_zone, active_zone;
-
-		if (!managed_zone(zone))
-			continue;
-
-		inactive_zone = lruvec_zone_lru_size(lruvec, file * LRU_FILE, zid);
-		active_zone = lruvec_zone_lru_size(lruvec, (file * LRU_FILE) + LRU_ACTIVE, zid);
-
-		inactive -= min(inactive, inactive_zone);
-		active -= min(active, active_zone);
-	}
+	inactive = lruvec_lru_size(lruvec, inactive_lru, sc->reclaim_idx);
+	active = lruvec_lru_size(lruvec, active_lru, sc->reclaim_idx);
 
 	gb = (inactive + active) >> (30 - PAGE_SHIFT);
 	if (gb)
@@ -2093,10 +2090,12 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 		inactive_ratio = 1;
 
 	if (trace)
-		trace_mm_vmscan_inactive_list_is_low(pgdat->node_id,
+		trace_mm_vmscan_inactive_list_is_low(lruvec_pgdat(lruvec)->node_id,
 				sc->reclaim_idx,
-				total_inactive, inactive,
-				total_active, active, inactive_ratio, file);
+				lruvec_lru_size(lruvec, inactive_lru, MAX_NR_ZONES), inactive,
+				lruvec_lru_size(lruvec, active_lru, MAX_NR_ZONES), active,
+				inactive_ratio, file);
+
 	return inactive * inactive_ratio < active;
 }
 
@@ -2236,7 +2235,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * system is under heavy pressure.
 	 */
 	if (!inactive_list_is_low(lruvec, true, sc, false) &&
-	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE) >> sc->priority) {
+	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE, MAX_NR_ZONES) >> sc->priority) {
 		scan_balance = SCAN_FILE;
 		goto out;
 	}
@@ -2262,10 +2261,10 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * anon in [0], file in [1]
 	 */
 
-	anon  = lruvec_lru_size(lruvec, LRU_ACTIVE_ANON) +
-		lruvec_lru_size(lruvec, LRU_INACTIVE_ANON);
-	file  = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE) +
-		lruvec_lru_size(lruvec, LRU_INACTIVE_FILE);
+	anon  = lruvec_lru_size(lruvec, LRU_ACTIVE_ANON, MAX_NR_ZONES) +
+		lruvec_lru_size(lruvec, LRU_INACTIVE_ANON, MAX_NR_ZONES);
+	file  = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE, MAX_NR_ZONES) +
+		lruvec_lru_size(lruvec, LRU_INACTIVE_FILE, MAX_NR_ZONES);
 
 	spin_lock_irq(&pgdat->lru_lock);
 	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
@@ -2303,7 +2302,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 			unsigned long size;
 			unsigned long scan;
 
-			size = lruvec_lru_size(lruvec, lru);
+			size = lruvec_lru_size(lruvec, lru, MAX_NR_ZONES);
 			scan = size >> sc->priority;
 
 			if (!scan && pass && force_scan)
diff --git a/mm/workingset.c b/mm/workingset.c
index abb58ffa3c64..a67f5796b995 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -267,7 +267,7 @@ bool workingset_refault(void *shadow)
 	}
 	lruvec = mem_cgroup_lruvec(pgdat, memcg);
 	refault = atomic_long_read(&lruvec->inactive_age);
-	active_file = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE);
+	active_file = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE, MAX_NR_ZONES);
 	rcu_read_unlock();
 
 	/*
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
