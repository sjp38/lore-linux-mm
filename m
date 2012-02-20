Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id DB7F46B00EF
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 12:23:20 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so6268158bkt.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 09:23:20 -0800 (PST)
Subject: [PATCH v2 11/22] mm: add lruvec->reclaim_stat
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 20 Feb 2012 21:23:18 +0400
Message-ID: <20120220172317.22196.27952.stgit@zurg>
In-Reply-To: <20120220171138.22196.65847.stgit@zurg>
References: <20120220171138.22196.65847.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Merge memcg and non-memcg reclaim stat. We need to update only one.
Move zone->reclaimer_stat and mem_cgroup_per_zone->reclaimer_stat to struct lruvec.

struct lruvec will become operating unit for recalimer logic,
thus this is perfect place for these counters.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/memcontrol.h |   17 --------------
 include/linux/mmzone.h     |    4 ++-
 mm/memcontrol.c            |   52 +++++---------------------------------------
 mm/page_alloc.c            |    6 ++---
 mm/swap.c                  |   12 ++--------
 mm/vmscan.c                |    5 +++-
 6 files changed, 15 insertions(+), 81 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index cc6061a..1d00222 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -111,10 +111,6 @@ unsigned int mem_cgroup_inactive_ratio(struct mem_cgroup *memcg);
 int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
 unsigned long mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg,
 					int nid, int zid, unsigned int lrumask);
-struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
-						      struct zone *zone);
-struct zone_reclaim_stat*
-mem_cgroup_get_reclaim_stat_from_page(struct page *page);
 extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 					struct task_struct *p);
 extern void mem_cgroup_replace_page_cache(struct page *oldpage,
@@ -299,19 +295,6 @@ mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg, int nid, int zid,
 	return 0;
 }
 
-
-static inline struct zone_reclaim_stat*
-mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg, struct zone *zone)
-{
-	return NULL;
-}
-
-static inline struct zone_reclaim_stat*
-mem_cgroup_get_reclaim_stat_from_page(struct page *page)
-{
-	return NULL;
-}
-
 static inline void
 mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index bd2cae4..9fd82b1 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -303,6 +303,8 @@ struct lruvec {
 #endif
 	struct list_head	pages_lru[NR_LRU_LISTS];
 	unsigned long		pages_count[NR_LRU_LISTS];
+
+	struct zone_reclaim_stat	reclaim_stat;
 };
 
 struct zone {
@@ -379,8 +381,6 @@ struct zone {
 	spinlock_t		lru_lock;
 	struct lruvec		lruvec;
 
-	struct zone_reclaim_stat reclaim_stat;
-
 	unsigned long		pages_scanned;	   /* since last reclaim */
 	unsigned long		flags;		   /* zone flags, see below */
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e29420d..5c1414b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -138,7 +138,6 @@ struct mem_cgroup_per_zone {
 
 	struct mem_cgroup_reclaim_iter reclaim_iter[DEF_PRIORITY + 1];
 
-	struct zone_reclaim_stat reclaim_stat;
 	struct rb_node		tree_node;	/* RB tree node */
 	unsigned long long	usage_in_excess;/* Set to the value by which */
 						/* the soft limit is exceeded*/
@@ -447,15 +446,6 @@ struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *memcg)
 	return &memcg->css;
 }
 
-static struct mem_cgroup_per_zone *
-page_cgroup_zoneinfo(struct mem_cgroup *memcg, struct page *page)
-{
-	int nid = page_to_nid(page);
-	int zid = page_zonenum(page);
-
-	return mem_cgroup_zoneinfo(memcg, nid, zid);
-}
-
 static struct mem_cgroup_tree_per_zone *
 soft_limit_tree_node_zone(int nid, int zid)
 {
@@ -1097,34 +1087,6 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg)
 	return ret;
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
-struct zone_reclaim_stat *
-mem_cgroup_get_reclaim_stat_from_page(struct page *page)
-{
-	struct page_cgroup *pc;
-	struct mem_cgroup_per_zone *mz;
-
-	if (mem_cgroup_disabled())
-		return NULL;
-
-	pc = lookup_page_cgroup(page);
-	if (!PageCgroupUsed(pc))
-		return NULL;
-	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
-	smp_rmb();
-	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
-	return &mz->reclaim_stat;
-}
-
 #define mem_cgroup_from_res_counter(counter, member)	\
 	container_of(counter, struct mem_cgroup, member)
 
@@ -4094,21 +4056,19 @@ static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
 	{
 		int nid, zid;
 		struct mem_cgroup_per_zone *mz;
+		struct zone_reclaim_stat *rs;
 		unsigned long recent_rotated[2] = {0, 0};
 		unsigned long recent_scanned[2] = {0, 0};
 
 		for_each_online_node(nid)
 			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
 				mz = mem_cgroup_zoneinfo(memcg, nid, zid);
+				rs = &mz->lruvec.reclaim_stat;
 
-				recent_rotated[0] +=
-					mz->reclaim_stat.recent_rotated[0];
-				recent_rotated[1] +=
-					mz->reclaim_stat.recent_rotated[1];
-				recent_scanned[0] +=
-					mz->reclaim_stat.recent_scanned[0];
-				recent_scanned[1] +=
-					mz->reclaim_stat.recent_scanned[1];
+				recent_rotated[0] += rs->recent_rotated[0];
+				recent_rotated[1] += rs->recent_rotated[1];
+				recent_scanned[0] += rs->recent_scanned[0];
+				recent_scanned[1] += rs->recent_scanned[1];
 			}
 		cb->fill(cb, "recent_rotated_anon", recent_rotated[0]);
 		cb->fill(cb, "recent_rotated_file", recent_rotated[1]);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c500084..72263e4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4370,10 +4370,8 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		zone->lruvec.node = pgdat;
 		zone->lruvec.zone = zone;
 #endif
-		zone->reclaim_stat.recent_rotated[0] = 0;
-		zone->reclaim_stat.recent_rotated[1] = 0;
-		zone->reclaim_stat.recent_scanned[0] = 0;
-		zone->reclaim_stat.recent_scanned[1] = 0;
+		memset(&zone->lruvec.reclaim_stat, 0,
+				sizeof(struct zone_reclaim_stat));
 		zap_zone_vm_stats(zone);
 		zone->flags = 0;
 		if (!size)
diff --git a/mm/swap.c b/mm/swap.c
index 4363daf..f31bd45 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -282,21 +282,13 @@ void rotate_reclaimable_page(struct page *page)
 static void update_page_reclaim_stat(struct zone *zone, struct page *page,
 				     int file, int rotated)
 {
-	struct zone_reclaim_stat *reclaim_stat = &zone->reclaim_stat;
-	struct zone_reclaim_stat *memcg_reclaim_stat;
+	struct zone_reclaim_stat *reclaim_stat;
 
-	memcg_reclaim_stat = mem_cgroup_get_reclaim_stat_from_page(page);
+	reclaim_stat = &page_lruvec(page)->reclaim_stat;
 
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
index 6889a39..f2eb9c4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -190,9 +190,10 @@ static bool scanning_global_lru(struct mem_cgroup_zone *mz)
 static struct zone_reclaim_stat *get_reclaim_stat(struct mem_cgroup_zone *mz)
 {
 	if (!scanning_global_lru(mz))
-		return mem_cgroup_get_reclaim_stat(mz->mem_cgroup, mz->zone);
+		return &mem_cgroup_zone_lruvec(mz->zone,
+				mz->mem_cgroup)->reclaim_stat;
 
-	return &mz->zone->reclaim_stat;
+	return &mz->zone->lruvec.reclaim_stat;
 }
 
 static unsigned long zone_nr_lru_pages(struct mem_cgroup_zone *mz,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
