Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 098576B0092
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 17:56:26 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so2948567bkw.14
        for <linux-mm@kvack.org>; Thu, 22 Mar 2012 14:56:26 -0700 (PDT)
Subject: [PATCH v6 2/7] mm/memcg: move reclaim_stat into lruvec
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Fri, 23 Mar 2012 01:56:23 +0400
Message-ID: <20120322215623.27814.16959.stgit@zurg>
In-Reply-To: <20120322214944.27814.42039.stgit@zurg>
References: <20120322214944.27814.42039.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

From: Hugh Dickins <hughd@google.com>

With mem_cgroup_disabled() now explicit, it becomes clear that the
zone_reclaim_stat structure actually belongs in lruvec, per-zone
when memcg is disabled but per-memcg per-zone when it's enabled.

We can delete mem_cgroup_get_reclaim_stat(), and change
update_page_reclaim_stat() to update just the one set of stats,
the one which get_scan_count() will actually use.

Signed-off-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    9 ---------
 include/linux/mmzone.h     |   29 ++++++++++++++---------------
 mm/memcontrol.c            |   27 +++++++--------------------
 mm/page_alloc.c            |    8 ++++----
 mm/swap.c                  |   14 ++++----------
 mm/vmscan.c                |    5 +----
 6 files changed, 30 insertions(+), 62 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index f94efd2..95dc32c 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -121,8 +121,6 @@ int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg,
 int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
 unsigned long mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg,
 					int nid, int zid, unsigned int lrumask);
-struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
-						      struct zone *zone);
 struct zone_reclaim_stat*
 mem_cgroup_get_reclaim_stat_from_page(struct page *page);
 extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
@@ -351,13 +349,6 @@ mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg, int nid, int zid,
 	return 0;
 }
 
-
-static inline struct zone_reclaim_stat*
-mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg, struct zone *zone)
-{
-	return NULL;
-}
-
 static inline struct zone_reclaim_stat*
 mem_cgroup_get_reclaim_stat_from_page(struct page *page)
 {
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index dff7115..9316931 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -159,8 +159,22 @@ static inline int is_unevictable_lru(enum lru_list lru)
 	return (lru == LRU_UNEVICTABLE);
 }
 
+struct zone_reclaim_stat {
+	/*
+	 * The pageout code in vmscan.c keeps track of how many of the
+	 * mem/swap backed and file backed pages are refeferenced.
+	 * The higher the rotated/scanned ratio, the more valuable
+	 * that cache is.
+	 *
+	 * The anon LRU stats live in [0], file LRU stats in [1]
+	 */
+	unsigned long		recent_rotated[2];
+	unsigned long		recent_scanned[2];
+};
+
 struct lruvec {
 	struct list_head lists[NR_LRU_LISTS];
+	struct zone_reclaim_stat reclaim_stat;
 };
 
 /* Mask used at gathering information at once (see memcontrol.c) */
@@ -287,19 +301,6 @@ enum zone_type {
 #error ZONES_SHIFT -- too many zones configured adjust calculation
 #endif
 
-struct zone_reclaim_stat {
-	/*
-	 * The pageout code in vmscan.c keeps track of how many of the
-	 * mem/swap backed and file backed pages are refeferenced.
-	 * The higher the rotated/scanned ratio, the more valuable
-	 * that cache is.
-	 *
-	 * The anon LRU stats live in [0], file LRU stats in [1]
-	 */
-	unsigned long		recent_rotated[2];
-	unsigned long		recent_scanned[2];
-};
-
 struct zone {
 	/* Fields commonly accessed by the page allocator */
 
@@ -374,8 +375,6 @@ struct zone {
 	spinlock_t		lru_lock;
 	struct lruvec		lruvec;
 
-	struct zone_reclaim_stat reclaim_stat;
-
 	unsigned long		pages_scanned;	   /* since last reclaim */
 	unsigned long		flags;		   /* zone flags, see below */
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b2ee6df..59697fb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -138,7 +138,6 @@ struct mem_cgroup_per_zone {
 
 	struct mem_cgroup_reclaim_iter reclaim_iter[DEF_PRIORITY + 1];
 
-	struct zone_reclaim_stat reclaim_stat;
 	struct rb_node		tree_node;	/* RB tree node */
 	unsigned long long	usage_in_excess;/* Set to the value by which */
 						/* the soft limit is exceeded*/
@@ -1233,16 +1232,6 @@ int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg, struct zone *zone)
 	return (active > inactive);
 }
 
-struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
-						      struct zone *zone)
-{
-	int nid = zone_to_nid(zone);
-	int zid = zone_idx(zone);
-	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid, zid);
-
-	return &mz->reclaim_stat;
-}
-
 struct zone_reclaim_stat *
 mem_cgroup_get_reclaim_stat_from_page(struct page *page)
 {
@@ -1258,7 +1247,7 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
 	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
 	smp_rmb();
 	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
-	return &mz->reclaim_stat;
+	return &mz->lruvec.reclaim_stat;
 }
 
 #define mem_cgroup_from_res_counter(counter, member)	\
@@ -4216,21 +4205,19 @@ static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
 	{
 		int nid, zid;
 		struct mem_cgroup_per_zone *mz;
+		struct zone_reclaim_stat *rstat;
 		unsigned long recent_rotated[2] = {0, 0};
 		unsigned long recent_scanned[2] = {0, 0};
 
 		for_each_online_node(nid)
 			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
 				mz = mem_cgroup_zoneinfo(memcg, nid, zid);
+				rstat = &mz->lruvec.reclaim_stat;
 
-				recent_rotated[0] +=
-					mz->reclaim_stat.recent_rotated[0];
-				recent_rotated[1] +=
-					mz->reclaim_stat.recent_rotated[1];
-				recent_scanned[0] +=
-					mz->reclaim_stat.recent_scanned[0];
-				recent_scanned[1] +=
-					mz->reclaim_stat.recent_scanned[1];
+				recent_rotated[0] += rstat->recent_rotated[0];
+				recent_rotated[1] += rstat->recent_rotated[1];
+				recent_scanned[0] += rstat->recent_scanned[0];
+				recent_scanned[1] += rstat->recent_scanned[1];
 			}
 		cb->fill(cb, "recent_rotated_anon", recent_rotated[0]);
 		cb->fill(cb, "recent_rotated_file", recent_rotated[1]);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index caea788..95ac749 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4317,10 +4317,10 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		zone_pcp_init(zone);
 		for_each_lru(lru)
 			INIT_LIST_HEAD(&zone->lruvec.lists[lru]);
-		zone->reclaim_stat.recent_rotated[0] = 0;
-		zone->reclaim_stat.recent_rotated[1] = 0;
-		zone->reclaim_stat.recent_scanned[0] = 0;
-		zone->reclaim_stat.recent_scanned[1] = 0;
+		zone->lruvec.reclaim_stat.recent_rotated[0] = 0;
+		zone->lruvec.reclaim_stat.recent_rotated[1] = 0;
+		zone->lruvec.reclaim_stat.recent_scanned[0] = 0;
+		zone->lruvec.reclaim_stat.recent_scanned[1] = 0;
 		zap_zone_vm_stats(zone);
 		zone->flags = 0;
 		if (!size)
diff --git a/mm/swap.c b/mm/swap.c
index 5c13f13..60d14da 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -279,21 +279,15 @@ void rotate_reclaimable_page(struct page *page)
 static void update_page_reclaim_stat(struct zone *zone, struct page *page,
 				     int file, int rotated)
 {
-	struct zone_reclaim_stat *reclaim_stat = &zone->reclaim_stat;
-	struct zone_reclaim_stat *memcg_reclaim_stat;
+	struct zone_reclaim_stat *reclaim_stat;
 
-	memcg_reclaim_stat = mem_cgroup_get_reclaim_stat_from_page(page);
+	reclaim_stat = mem_cgroup_get_reclaim_stat_from_page(page);
+	if (!reclaim_stat)
+		reclaim_stat = &zone->lruvec.reclaim_stat;
 
 	reclaim_stat->recent_scanned[file]++;
 	if (rotated)
 		reclaim_stat->recent_rotated[file]++;
-
-	if (!memcg_reclaim_stat)
-		return;
-
-	memcg_reclaim_stat->recent_scanned[file]++;
-	if (rotated)
-		memcg_reclaim_stat->recent_rotated[file]++;
 }
 
 static void __activate_page(struct page *page, void *arg)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c684f44..f4dca0c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -173,10 +173,7 @@ static bool global_reclaim(struct scan_control *sc)
 
 static struct zone_reclaim_stat *get_reclaim_stat(struct mem_cgroup_zone *mz)
 {
-	if (!mem_cgroup_disabled())
-		return mem_cgroup_get_reclaim_stat(mz->mem_cgroup, mz->zone);
-
-	return &mz->zone->reclaim_stat;
+	return &mem_cgroup_zone_lruvec(mz->zone, mz->mem_cgroup)->reclaim_stat;
 }
 
 static unsigned long zone_nr_lru_pages(struct mem_cgroup_zone *mz,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
