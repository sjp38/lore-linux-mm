Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id BE3A86B03C2
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 10:11:34 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id w37so6026765wrc.2
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 07:11:34 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id k206si3208009wma.17.2017.02.28.07.11.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 07:11:33 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id u63so2881854wmu.2
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 07:11:33 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH stable-4.9 1/2] mm, vmscan: cleanup lru size claculations
Date: Tue, 28 Feb 2017 16:11:07 +0100
Message-Id: <20170228151108.20853-2-mhocko@kernel.org>
In-Reply-To: <20170228151108.20853-1-mhocko@kernel.org>
References: <20170228151108.20853-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable tree <stable@vger.kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>

From: Michal Hocko <mhocko@suse.com>

commit fd538803731e50367b7c59ce4ad3454426a3d671 upstream.

lruvec_lru_size returns the full size of the LRU list while we sometimes
need a value reduced only to eligible zones (e.g.  for lowmem requests).
inactive_list_is_low is one such user.  Later patches will add more of
them.  Add a new parameter to lruvec_lru_size and allow it filter out
zones which are not eligible for the given context.

Link: http://lkml.kernel.org/r/20170117103702.28542-2-mhocko@kernel.org
Signed-off-by: Michal Hocko <mhocko@suse.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
Acked-by: Minchan Kim <minchan@kernel.org>
Acked-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
---
 include/linux/mmzone.h |  2 +-
 mm/vmscan.c            | 81 ++++++++++++++++++++++++--------------------------
 mm/workingset.c        |  2 +-
 3 files changed, 41 insertions(+), 44 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index f99c993dd500..7e273e243a13 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -779,7 +779,7 @@ static inline struct pglist_data *lruvec_pgdat(struct lruvec *lruvec)
 #endif
 }
 
-extern unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru);
+extern unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru, int zone_idx);
 
 #ifdef CONFIG_HAVE_MEMORY_PRESENT
 void memory_present(int nid, unsigned long start, unsigned long end);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index fa30010a5277..cd516c632e8f 100644
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
@@ -2028,11 +2045,10 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 						struct scan_control *sc)
 {
 	unsigned long inactive_ratio;
-	unsigned long inactive;
-	unsigned long active;
+	unsigned long inactive, active;
+	enum lru_list inactive_lru = file * LRU_FILE;
+	enum lru_list active_lru = file * LRU_FILE + LRU_ACTIVE;
 	unsigned long gb;
-	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
-	int zid;
 
 	/*
 	 * If we don't have swap space, anonymous page deactivation
@@ -2041,27 +2057,8 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 	if (!file && !total_swap_pages)
 		return false;
 
-	inactive = lruvec_lru_size(lruvec, file * LRU_FILE);
-	active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE);
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
@@ -2208,7 +2205,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * system is under heavy pressure.
 	 */
 	if (!inactive_list_is_low(lruvec, true, sc) &&
-	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE) >> sc->priority) {
+	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE, MAX_NR_ZONES) >> sc->priority) {
 		scan_balance = SCAN_FILE;
 		goto out;
 	}
@@ -2234,10 +2231,10 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
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
@@ -2275,7 +2272,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 			unsigned long size;
 			unsigned long scan;
 
-			size = lruvec_lru_size(lruvec, lru);
+			size = lruvec_lru_size(lruvec, lru, MAX_NR_ZONES);
 			scan = size >> sc->priority;
 
 			if (!scan && pass && force_scan)
diff --git a/mm/workingset.c b/mm/workingset.c
index fb1f9183d89a..33f6f4db32fd 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -266,7 +266,7 @@ bool workingset_refault(void *shadow)
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
