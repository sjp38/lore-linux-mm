Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 80CA16B00EA
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 03:54:22 -0400 (EDT)
Received: by mail-lpp01m010-f41.google.com with SMTP id z14so991336lag.14
        for <linux-mm@kvack.org>; Thu, 26 Apr 2012 00:54:21 -0700 (PDT)
Subject: [PATCH 08/12] mm/vmscan: push lruvec pointer into
 inactive_list_is_low()
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 26 Apr 2012 11:54:19 +0400
Message-ID: <20120426075419.18961.76824.stgit@zurg>
In-Reply-To: <20120426074632.18961.17803.stgit@zurg>
References: <20120426074632.18961.17803.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch switches mem_cgroup_inactive_anon_is_low() to lruvec pointers,
mem_cgroup_get_lruvec_size() is more effective than mem_cgroup_zone_nr_lru_pages()

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/memcontrol.h |   10 ++++------
 mm/memcontrol.c            |   20 ++++++--------------
 mm/vmscan.c                |   40 ++++++++++++++++++++++------------------
 3 files changed, 32 insertions(+), 38 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 7980187..88877a9 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -117,10 +117,8 @@ void mem_cgroup_iter_break(struct mem_cgroup *, struct mem_cgroup *);
 /*
  * For memory reclaim.
  */
-int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg,
-				    struct zone *zone);
-int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg,
-				    struct zone *zone);
+int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec);
+int mem_cgroup_inactive_file_is_low(struct lruvec *lruvec);
 int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
 unsigned long mem_cgroup_get_lruvec_size(struct lruvec *lruvec, enum lru_list);
 struct zone_reclaim_stat*
@@ -329,13 +327,13 @@ static inline bool mem_cgroup_disabled(void)
 }
 
 static inline int
-mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg, struct zone *zone)
+mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
 {
 	return 1;
 }
 
 static inline int
-mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg, struct zone *zone)
+mem_cgroup_inactive_file_is_low(struct lruvec *lruvec)
 {
 	return 1;
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2cb6f4d..07c15dd 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1208,19 +1208,15 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg)
 	return ret;
 }
 
-int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg, struct zone *zone)
+int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
 {
 	unsigned long inactive_ratio;
-	int nid = zone_to_nid(zone);
-	int zid = zone_idx(zone);
 	unsigned long inactive;
 	unsigned long active;
 	unsigned long gb;
 
-	inactive = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
-						BIT(LRU_INACTIVE_ANON));
-	active = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
-					      BIT(LRU_ACTIVE_ANON));
+	inactive = mem_cgroup_get_lruvec_size(lruvec, LRU_INACTIVE_ANON);
+	active = mem_cgroup_get_lruvec_size(lruvec, LRU_ACTIVE_ANON);
 
 	gb = (inactive + active) >> (30 - PAGE_SHIFT);
 	if (gb)
@@ -1231,17 +1227,13 @@ int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg, struct zone *zone)
 	return inactive * inactive_ratio < active;
 }
 
-int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg, struct zone *zone)
+int mem_cgroup_inactive_file_is_low(struct lruvec *lruvec)
 {
 	unsigned long active;
 	unsigned long inactive;
-	int zid = zone_idx(zone);
-	int nid = zone_to_nid(zone);
 
-	inactive = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
-						BIT(LRU_INACTIVE_FILE));
-	active = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
-					      BIT(LRU_ACTIVE_FILE));
+	inactive = mem_cgroup_get_lruvec_size(lruvec, LRU_INACTIVE_FILE);
+	active = mem_cgroup_get_lruvec_size(lruvec, LRU_ACTIVE_FILE);
 
 	return (active > inactive);
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6d46117..c055d6e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1530,13 +1530,12 @@ static int inactive_anon_is_low_global(struct zone *zone)
 
 /**
  * inactive_anon_is_low - check if anonymous pages need to be deactivated
- * @zone: zone to check
- * @sc:   scan control of this context
+ * @lruvec: LRU vector to check
  *
  * Returns true if the zone does not have enough inactive anon pages,
  * meaning some active anon pages need to be deactivated.
  */
-static int inactive_anon_is_low(struct mem_cgroup_zone *mz)
+static int inactive_anon_is_low(struct lruvec *lruvec)
 {
 	/*
 	 * If we don't have swap space, anonymous page deactivation
@@ -1546,13 +1545,12 @@ static int inactive_anon_is_low(struct mem_cgroup_zone *mz)
 		return 0;
 
 	if (!mem_cgroup_disabled())
-		return mem_cgroup_inactive_anon_is_low(mz->mem_cgroup,
-						       mz->zone);
+		return mem_cgroup_inactive_anon_is_low(lruvec);
 
-	return inactive_anon_is_low_global(mz->zone);
+	return inactive_anon_is_low_global(lruvec_zone(lruvec));
 }
 #else
-static inline int inactive_anon_is_low(struct mem_cgroup_zone *mz)
+static inline int inactive_anon_is_low(struct lruvec *lruvec)
 {
 	return 0;
 }
@@ -1570,7 +1568,7 @@ static int inactive_file_is_low_global(struct zone *zone)
 
 /**
  * inactive_file_is_low - check if file pages need to be deactivated
- * @mz: memory cgroup and zone to check
+ * @lruvec: LRU vector to check
  *
  * When the system is doing streaming IO, memory pressure here
  * ensures that active file pages get deactivated, until more
@@ -1582,21 +1580,20 @@ static int inactive_file_is_low_global(struct zone *zone)
  * This uses a different ratio than the anonymous pages, because
  * the page cache uses a use-once replacement algorithm.
  */
-static int inactive_file_is_low(struct mem_cgroup_zone *mz)
+static int inactive_file_is_low(struct lruvec *lruvec)
 {
 	if (!mem_cgroup_disabled())
-		return mem_cgroup_inactive_file_is_low(mz->mem_cgroup,
-						       mz->zone);
+		return mem_cgroup_inactive_file_is_low(lruvec);
 
-	return inactive_file_is_low_global(mz->zone);
+	return inactive_file_is_low_global(lruvec_zone(lruvec));
 }
 
-static int inactive_list_is_low(struct mem_cgroup_zone *mz, int file)
+static int inactive_list_is_low(struct lruvec *lruvec, int file)
 {
 	if (file)
-		return inactive_file_is_low(mz);
+		return inactive_file_is_low(lruvec);
 	else
-		return inactive_anon_is_low(mz);
+		return inactive_anon_is_low(lruvec);
 }
 
 static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
@@ -1606,7 +1603,10 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 	int file = is_file_lru(lru);
 
 	if (is_active_lru(lru)) {
-		if (inactive_list_is_low(mz, file))
+		struct lruvec *lruvec = mem_cgroup_zone_lruvec(mz->zone,
+							       mz->mem_cgroup);
+
+		if (inactive_list_is_low(lruvec, file))
 			shrink_active_list(nr_to_scan, mz, sc, lru);
 		return 0;
 	}
@@ -1835,6 +1835,9 @@ static void shrink_mem_cgroup_zone(struct mem_cgroup_zone *mz,
 	unsigned long nr_reclaimed, nr_scanned;
 	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
 	struct blk_plug plug;
+	struct lruvec *lruvec;
+
+	lruvec = mem_cgroup_zone_lruvec(mz->zone, mz->mem_cgroup);
 
 restart:
 	nr_reclaimed = 0;
@@ -1873,7 +1876,7 @@ restart:
 	 * Even if we did not try to evict anon pages at all, we want to
 	 * rebalance the anon lru active/inactive ratio.
 	 */
-	if (inactive_anon_is_low(mz))
+	if (inactive_anon_is_low(lruvec))
 		shrink_active_list(SWAP_CLUSTER_MAX, mz,
 				   sc, LRU_ACTIVE_ANON);
 
@@ -2306,12 +2309,13 @@ static void age_active_anon(struct zone *zone, struct scan_control *sc)
 
 	memcg = mem_cgroup_iter(NULL, NULL, NULL);
 	do {
+		struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
 		struct mem_cgroup_zone mz = {
 			.mem_cgroup = memcg,
 			.zone = zone,
 		};
 
-		if (inactive_anon_is_low(&mz))
+		if (inactive_anon_is_low(lruvec))
 			shrink_active_list(SWAP_CLUSTER_MAX, &mz,
 					   sc, LRU_ACTIVE_ANON);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
