Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 209B56B0083
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 08:51:46 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so1365307bkt.14
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 05:51:45 -0800 (PST)
Subject: [PATCH v3 01/21] memcg: unify inactive_ratio calculation
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 23 Feb 2012 17:51:41 +0400
Message-ID: <20120223135141.12988.12236.stgit@zurg>
In-Reply-To: <20120223133728.12988.5432.stgit@zurg>
References: <20120223133728.12988.5432.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>

This patch removes precalculated zone->inactive_ratio.
Now it always calculated in inactive_anon_is_low() from current lru sizes.
After that we can merge memcg and non-memcg cases and drop duplicated code.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/memcontrol.h |   16 --------
 include/linux/mmzone.h     |    7 ----
 mm/memcontrol.c            |   38 -------------------
 mm/page_alloc.c            |   44 ----------------------
 mm/vmscan.c                |   88 ++++++++++++++++++++++++++++----------------
 mm/vmstat.c                |    6 +--
 6 files changed, 58 insertions(+), 141 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index bf4e1f4..8c4d74f 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -113,10 +113,6 @@ void mem_cgroup_iter_break(struct mem_cgroup *, struct mem_cgroup *);
 /*
  * For memory reclaim.
  */
-int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg,
-				    struct zone *zone);
-int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg,
-				    struct zone *zone);
 int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
 unsigned long mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg,
 					int nid, int zid, unsigned int lrumask);
@@ -319,18 +315,6 @@ static inline bool mem_cgroup_disabled(void)
 	return true;
 }
 
-static inline int
-mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg, struct zone *zone)
-{
-	return 1;
-}
-
-static inline int
-mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg, struct zone *zone)
-{
-	return 1;
-}
-
 static inline unsigned long
 mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg, int nid, int zid,
 				unsigned int lru_mask)
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index f10a54c..3e1f7ff 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -382,13 +382,6 @@ struct zone {
 	/* Zone statistics */
 	atomic_long_t		vm_stat[NR_VM_ZONE_STAT_ITEMS];
 
-	/*
-	 * The target ratio of ACTIVE_ANON to INACTIVE_ANON pages on
-	 * this zone's LRU.  Maintained by the pageout code.
-	 */
-	unsigned int inactive_ratio;
-
-
 	ZONE_PADDING(_pad2_)
 	/* Rarely used or read-mostly fields */
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ab315ab..b8039d2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1157,44 +1157,6 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg)
 	return ret;
 }
 
-int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg, struct zone *zone)
-{
-	unsigned long inactive_ratio;
-	int nid = zone_to_nid(zone);
-	int zid = zone_idx(zone);
-	unsigned long inactive;
-	unsigned long active;
-	unsigned long gb;
-
-	inactive = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
-						BIT(LRU_INACTIVE_ANON));
-	active = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
-					      BIT(LRU_ACTIVE_ANON));
-
-	gb = (inactive + active) >> (30 - PAGE_SHIFT);
-	if (gb)
-		inactive_ratio = int_sqrt(10 * gb);
-	else
-		inactive_ratio = 1;
-
-	return inactive * inactive_ratio < active;
-}
-
-int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg, struct zone *zone)
-{
-	unsigned long active;
-	unsigned long inactive;
-	int zid = zone_idx(zone);
-	int nid = zone_to_nid(zone);
-
-	inactive = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
-						BIT(LRU_INACTIVE_FILE));
-	active = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
-					      BIT(LRU_ACTIVE_FILE));
-
-	return (active > inactive);
-}
-
 struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
 						      struct zone *zone)
 {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a547177..38f6744 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5051,49 +5051,6 @@ void setup_per_zone_wmarks(void)
 }
 
 /*
- * The inactive anon list should be small enough that the VM never has to
- * do too much work, but large enough that each inactive page has a chance
- * to be referenced again before it is swapped out.
- *
- * The inactive_anon ratio is the target ratio of ACTIVE_ANON to
- * INACTIVE_ANON pages on this zone's LRU, maintained by the
- * pageout code. A zone->inactive_ratio of 3 means 3:1 or 25% of
- * the anonymous pages are kept on the inactive list.
- *
- * total     target    max
- * memory    ratio     inactive anon
- * -------------------------------------
- *   10MB       1         5MB
- *  100MB       1        50MB
- *    1GB       3       250MB
- *   10GB      10       0.9GB
- *  100GB      31         3GB
- *    1TB     101        10GB
- *   10TB     320        32GB
- */
-static void __meminit calculate_zone_inactive_ratio(struct zone *zone)
-{
-	unsigned int gb, ratio;
-
-	/* Zone size in gigabytes */
-	gb = zone->present_pages >> (30 - PAGE_SHIFT);
-	if (gb)
-		ratio = int_sqrt(10 * gb);
-	else
-		ratio = 1;
-
-	zone->inactive_ratio = ratio;
-}
-
-static void __meminit setup_per_zone_inactive_ratio(void)
-{
-	struct zone *zone;
-
-	for_each_zone(zone)
-		calculate_zone_inactive_ratio(zone);
-}
-
-/*
  * Initialise min_free_kbytes.
  *
  * For small machines we want it small (128k min).  For large machines
@@ -5131,7 +5088,6 @@ int __meminit init_per_zone_wmark_min(void)
 	setup_per_zone_wmarks();
 	refresh_zone_stat_thresholds();
 	setup_per_zone_lowmem_reserve();
-	setup_per_zone_inactive_ratio();
 	return 0;
 }
 module_init(init_per_zone_wmark_min)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 87e4d6a..39aa4d7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1779,29 +1779,38 @@ static void shrink_active_list(unsigned long nr_to_scan,
 }
 
 #ifdef CONFIG_SWAP
-static int inactive_anon_is_low_global(struct zone *zone)
-{
-	unsigned long active, inactive;
-
-	active = zone_page_state(zone, NR_ACTIVE_ANON);
-	inactive = zone_page_state(zone, NR_INACTIVE_ANON);
-
-	if (inactive * zone->inactive_ratio < active)
-		return 1;
-
-	return 0;
-}
-
 /**
  * inactive_anon_is_low - check if anonymous pages need to be deactivated
  * @zone: zone to check
- * @sc:   scan control of this context
  *
  * Returns true if the zone does not have enough inactive anon pages,
  * meaning some active anon pages need to be deactivated.
+ *
+ * The inactive anon list should be small enough that the VM never has to
+ * do too much work, but large enough that each inactive page has a chance
+ * to be referenced again before it is swapped out.
+ *
+ * The inactive_anon ratio is the target ratio of ACTIVE_ANON to
+ * INACTIVE_ANON pages on this zone's LRU, maintained by the
+ * pageout code. A zone->inactive_ratio of 3 means 3:1 or 25% of
+ * the anonymous pages are kept on the inactive list.
+ *
+ * total     target    max
+ * memory    ratio     inactive anon
+ * -------------------------------------
+ *   10MB       1         5MB
+ *  100MB       1        50MB
+ *    1GB       3       250MB
+ *   10GB      10       0.9GB
+ *  100GB      31         3GB
+ *    1TB     101        10GB
+ *   10TB     320        32GB
  */
 static int inactive_anon_is_low(struct mem_cgroup_zone *mz)
 {
+	unsigned long active, inactive;
+	unsigned int gb, ratio;
+
 	/*
 	 * If we don't have swap space, anonymous page deactivation
 	 * is pointless.
@@ -1809,11 +1818,26 @@ static int inactive_anon_is_low(struct mem_cgroup_zone *mz)
 	if (!total_swap_pages)
 		return 0;
 
-	if (!scanning_global_lru(mz))
-		return mem_cgroup_inactive_anon_is_low(mz->mem_cgroup,
-						       mz->zone);
+	if (scanning_global_lru(mz)) {
+		active = zone_page_state(mz->zone, NR_ACTIVE_ANON);
+		inactive = zone_page_state(mz->zone, NR_INACTIVE_ANON);
+	} else {
+		active = mem_cgroup_zone_nr_lru_pages(mz->mem_cgroup,
+				zone_to_nid(mz->zone), zone_idx(mz->zone),
+				BIT(LRU_ACTIVE_ANON));
+		inactive = mem_cgroup_zone_nr_lru_pages(mz->mem_cgroup,
+				zone_to_nid(mz->zone), zone_idx(mz->zone),
+				BIT(LRU_INACTIVE_ANON));
+	}
+
+	/* Total size in gigabytes */
+	gb = (active + inactive) >> (30 - PAGE_SHIFT);
+	if (gb)
+		ratio = int_sqrt(10 * gb);
+	else
+		ratio = 1;
 
-	return inactive_anon_is_low_global(mz->zone);
+	return inactive * ratio < active;
 }
 #else
 static inline int inactive_anon_is_low(struct mem_cgroup_zone *mz)
@@ -1822,16 +1846,6 @@ static inline int inactive_anon_is_low(struct mem_cgroup_zone *mz)
 }
 #endif
 
-static int inactive_file_is_low_global(struct zone *zone)
-{
-	unsigned long active, inactive;
-
-	active = zone_page_state(zone, NR_ACTIVE_FILE);
-	inactive = zone_page_state(zone, NR_INACTIVE_FILE);
-
-	return (active > inactive);
-}
-
 /**
  * inactive_file_is_low - check if file pages need to be deactivated
  * @mz: memory cgroup and zone to check
@@ -1848,11 +1862,21 @@ static int inactive_file_is_low_global(struct zone *zone)
  */
 static int inactive_file_is_low(struct mem_cgroup_zone *mz)
 {
-	if (!scanning_global_lru(mz))
-		return mem_cgroup_inactive_file_is_low(mz->mem_cgroup,
-						       mz->zone);
+	unsigned long active, inactive;
+
+	if (scanning_global_lru(mz)) {
+		active = zone_page_state(mz->zone, NR_ACTIVE_FILE);
+		inactive = zone_page_state(mz->zone, NR_INACTIVE_FILE);
+	} else {
+		active = mem_cgroup_zone_nr_lru_pages(mz->mem_cgroup,
+				zone_to_nid(mz->zone), zone_idx(mz->zone),
+				BIT(LRU_ACTIVE_FILE));
+		inactive = mem_cgroup_zone_nr_lru_pages(mz->mem_cgroup,
+				zone_to_nid(mz->zone), zone_idx(mz->zone),
+				BIT(LRU_INACTIVE_FILE));
+	}
 
-	return inactive_file_is_low_global(mz->zone);
+	return inactive < active;
 }
 
 static int inactive_list_is_low(struct mem_cgroup_zone *mz, int file)
diff --git a/mm/vmstat.c b/mm/vmstat.c
index f600557..2c813e1 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1017,11 +1017,9 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 	}
 	seq_printf(m,
 		   "\n  all_unreclaimable: %u"
-		   "\n  start_pfn:         %lu"
-		   "\n  inactive_ratio:    %u",
+		   "\n  start_pfn:         %lu",
 		   zone->all_unreclaimable,
-		   zone->zone_start_pfn,
-		   zone->inactive_ratio);
+		   zone->zone_start_pfn);
 	seq_putc(m, '\n');
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
