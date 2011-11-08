Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 83F516B006C
	for <linux-mm@kvack.org>; Tue,  8 Nov 2011 16:25:50 -0500 (EST)
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch 05/10] mm: move memcg hierarchy reclaim to generic reclaim code
Date: Tue,  8 Nov 2011 22:23:23 +0100
Message-Id: <1320787408-22866-6-git-send-email-jweiner@redhat.com>
In-Reply-To: <1320787408-22866-1-git-send-email-jweiner@redhat.com>
References: <1320787408-22866-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Memory cgroup limit reclaim and traditional global pressure reclaim
will soon share the same code to reclaim from a hierarchical tree of
memory cgroups.

In preparation of this, move the two right next to each other in
shrink_zone().

The mem_cgroup_hierarchical_reclaim() polymath is split into a soft
limit reclaim function, which still does hierarchy walking on its own,
and a limit (shrinking) reclaim function, which relies on generic
reclaim code to walk the hierarchy.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Reviewed-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 include/linux/memcontrol.h |   24 ++++++
 mm/memcontrol.c            |  169 ++++++++++++++++++++++----------------------
 mm/vmscan.c                |   43 ++++++++++-
 3 files changed, 148 insertions(+), 88 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index b87068a..6952016 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -40,6 +40,12 @@ extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct mem_cgroup *mem_cont,
 					int active, int file);
 
+struct mem_cgroup_reclaim_cookie {
+	struct zone *zone;
+	int priority;
+	unsigned int generation;
+};
+
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 /*
  * All "charge" functions with gfp_mask should use GFP_KERNEL or
@@ -103,6 +109,11 @@ mem_cgroup_prepare_migration(struct page *page,
 extern void mem_cgroup_end_migration(struct mem_cgroup *memcg,
 	struct page *oldpage, struct page *newpage, bool migration_ok);
 
+struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *,
+				   struct mem_cgroup *,
+				   struct mem_cgroup_reclaim_cookie *);
+void mem_cgroup_iter_break(struct mem_cgroup *, struct mem_cgroup *);
+
 /*
  * For memory reclaim.
  */
@@ -276,6 +287,19 @@ static inline void mem_cgroup_end_migration(struct mem_cgroup *memcg,
 {
 }
 
+static inline struct mem_cgroup *
+mem_cgroup_iter(struct mem_cgroup *root,
+		struct mem_cgroup *prev,
+		struct mem_cgroup_reclaim_cookie *reclaim)
+{
+	return NULL;
+}
+
+static inline void mem_cgroup_iter_break(struct mem_cgroup *root,
+					 struct mem_cgroup *prev)
+{
+}
+
 static inline int mem_cgroup_get_reclaim_priority(struct mem_cgroup *memcg)
 {
 	return 0;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 100595b..4305686 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -364,8 +364,6 @@ enum charge_type {
 #define MEM_CGROUP_RECLAIM_NOSWAP	(1 << MEM_CGROUP_RECLAIM_NOSWAP_BIT)
 #define MEM_CGROUP_RECLAIM_SHRINK_BIT	0x1
 #define MEM_CGROUP_RECLAIM_SHRINK	(1 << MEM_CGROUP_RECLAIM_SHRINK_BIT)
-#define MEM_CGROUP_RECLAIM_SOFT_BIT	0x2
-#define MEM_CGROUP_RECLAIM_SOFT		(1 << MEM_CGROUP_RECLAIM_SOFT_BIT)
 
 static void mem_cgroup_get(struct mem_cgroup *memcg);
 static void mem_cgroup_put(struct mem_cgroup *memcg);
@@ -791,20 +789,33 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
 	return memcg;
 }
 
-struct mem_cgroup_reclaim_cookie {
-	struct zone *zone;
-	int priority;
-	unsigned int generation;
-};
-
-static struct mem_cgroup *
-mem_cgroup_iter(struct mem_cgroup *root,
-		struct mem_cgroup *prev,
-		struct mem_cgroup_reclaim_cookie *reclaim)
+/**
+ * mem_cgroup_iter - iterate over memory cgroup hierarchy
+ * @root: hierarchy root
+ * @prev: previously returned memcg, NULL on first invocation
+ * @reclaim: cookie for shared reclaim walks, NULL for full walks
+ *
+ * Returns references to children of the hierarchy below @root, or
+ * @root itself, or %NULL after a full round-trip.
+ *
+ * Caller must pass the return value in @prev on subsequent
+ * invocations for reference counting, or use mem_cgroup_iter_break()
+ * to cancel a hierarchy walk before the round-trip is complete.
+ *
+ * Reclaimers can specify a zone and a priority level in @reclaim to
+ * divide up the memcgs in the hierarchy among all concurrent
+ * reclaimers operating on the same zone and priority.
+ */
+struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
+				   struct mem_cgroup *prev,
+				   struct mem_cgroup_reclaim_cookie *reclaim)
 {
 	struct mem_cgroup *memcg = NULL;
 	int id = 0;
 
+	if (mem_cgroup_disabled())
+		return NULL;
+
 	if (!root)
 		root = root_mem_cgroup;
 
@@ -860,8 +871,13 @@ mem_cgroup_iter(struct mem_cgroup *root,
 	return memcg;
 }
 
-static void mem_cgroup_iter_break(struct mem_cgroup *root,
-				  struct mem_cgroup *prev)
+/**
+ * mem_cgroup_iter_break - abort a hierarchy walk prematurely
+ * @root: hierarchy root
+ * @prev: last visited hierarchy member as returned by mem_cgroup_iter()
+ */
+void mem_cgroup_iter_break(struct mem_cgroup *root,
+			   struct mem_cgroup *prev)
 {
 	if (!root)
 		root = root_mem_cgroup;
@@ -1489,6 +1505,42 @@ u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
 	return min(limit, memsw);
 }
 
+static unsigned long mem_cgroup_reclaim(struct mem_cgroup *memcg,
+					gfp_t gfp_mask,
+					unsigned long flags)
+{
+	unsigned long total = 0;
+	bool noswap = false;
+	int loop;
+
+	if (flags & MEM_CGROUP_RECLAIM_NOSWAP)
+		noswap = true;
+	if (!(flags & MEM_CGROUP_RECLAIM_SHRINK) && memcg->memsw_is_minimum)
+		noswap = true;
+
+	for (loop = 0; loop < MEM_CGROUP_MAX_RECLAIM_LOOPS; loop++) {
+		if (loop)
+			drain_all_stock_async(memcg);
+		total += try_to_free_mem_cgroup_pages(memcg, gfp_mask, noswap);
+		/*
+		 * Allow limit shrinkers, which are triggered directly
+		 * by userspace, to catch signals and stop reclaim
+		 * after minimal progress, regardless of the margin.
+		 */
+		if (total && (flags & MEM_CGROUP_RECLAIM_SHRINK))
+			break;
+		if (mem_cgroup_margin(memcg))
+			break;
+		/*
+		 * If nothing was reclaimed after two attempts, there
+		 * may be no reclaimable pages in this hierarchy.
+		 */
+		if (loop && !total)
+			break;
+	}
+	return total;
+}
+
 /**
  * test_mem_cgroup_node_reclaimable
  * @mem: the target memcg
@@ -1626,30 +1678,14 @@ bool mem_cgroup_reclaimable(struct mem_cgroup *memcg, bool noswap)
 }
 #endif
 
-/*
- * Scan the hierarchy if needed to reclaim memory. We remember the last child
- * we reclaimed from, so that we don't end up penalizing one child extensively
- * based on its position in the children list.
- *
- * root_memcg is the original ancestor that we've been reclaim from.
- *
- * We give up and return to the caller when we visit root_memcg twice.
- * (other groups can be removed while we're walking....)
- *
- * If shrink==true, for avoiding to free too much, this returns immedieately.
- */
-static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_memcg,
-						struct zone *zone,
-						gfp_t gfp_mask,
-						unsigned long reclaim_options,
-						unsigned long *total_scanned)
+static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
+				   struct zone *zone,
+				   gfp_t gfp_mask,
+				   unsigned long *total_scanned)
 {
 	struct mem_cgroup *victim = NULL;
-	int ret, total = 0;
+	int total = 0;
 	int loop = 0;
-	bool noswap = reclaim_options & MEM_CGROUP_RECLAIM_NOSWAP;
-	bool shrink = reclaim_options & MEM_CGROUP_RECLAIM_SHRINK;
-	bool check_soft = reclaim_options & MEM_CGROUP_RECLAIM_SOFT;
 	unsigned long excess;
 	unsigned long nr_scanned;
 	struct mem_cgroup_reclaim_cookie reclaim = {
@@ -1659,29 +1695,17 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_memcg,
 
 	excess = res_counter_soft_limit_excess(&root_memcg->res) >> PAGE_SHIFT;
 
-	/* If memsw_is_minimum==1, swap-out is of-no-use. */
-	if (!check_soft && !shrink && root_memcg->memsw_is_minimum)
-		noswap = true;
-
 	while (1) {
 		victim = mem_cgroup_iter(root_memcg, victim, &reclaim);
 		if (!victim) {
 			loop++;
-			/*
-			 * We are not draining per cpu cached charges during
-			 * soft limit reclaim  because global reclaim doesn't
-			 * care about charges. It tries to free some memory and
-			 * charges will not give any.
-			 */
-			if (!check_soft && loop >= 1)
-				drain_all_stock_async(root_memcg);
 			if (loop >= 2) {
 				/*
 				 * If we have not been able to reclaim
 				 * anything, it might because there are
 				 * no reclaimable pages under this hierarchy
 				 */
-				if (!check_soft || !total)
+				if (!total)
 					break;
 				/*
 				 * We want to do more targeted reclaim.
@@ -1695,30 +1719,12 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_memcg,
 			}
 			continue;
 		}
-		if (!mem_cgroup_reclaimable(victim, noswap)) {
-			/* this cgroup's local usage == 0 */
+		if (!mem_cgroup_reclaimable(victim, false))
 			continue;
-		}
-		/* we use swappiness of local cgroup */
-		if (check_soft) {
-			ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
-				noswap, zone, &nr_scanned);
-			*total_scanned += nr_scanned;
-		} else
-			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
-						noswap);
-		total += ret;
-		/*
-		 * At shrinking usage, we can't check we should stop here or
-		 * reclaim more. It's depends on callers. last_scanned_child
-		 * will work enough for keeping fairness under tree.
-		 */
-		if (shrink)
-			break;
-		if (check_soft) {
-			if (!res_counter_soft_limit_excess(&root_memcg->res))
-				break;
-		} else if (mem_cgroup_margin(root_memcg))
+		total += mem_cgroup_shrink_node_zone(victim, gfp_mask, false,
+						     zone, &nr_scanned);
+		*total_scanned += nr_scanned;
+		if (!res_counter_soft_limit_excess(&root_memcg->res))
 			break;
 	}
 	mem_cgroup_iter_break(root_memcg, victim);
@@ -2215,8 +2221,7 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	if (!(gfp_mask & __GFP_WAIT))
 		return CHARGE_WOULDBLOCK;
 
-	ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
-					      gfp_mask, flags, NULL);
+	ret = mem_cgroup_reclaim(mem_over_limit, gfp_mask, flags);
 	if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
 		return CHARGE_RETRY;
 	/*
@@ -3449,9 +3454,8 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 		if (!ret)
 			break;
 
-		mem_cgroup_hierarchical_reclaim(memcg, NULL, GFP_KERNEL,
-						MEM_CGROUP_RECLAIM_SHRINK,
-						NULL);
+		mem_cgroup_reclaim(memcg, GFP_KERNEL,
+				   MEM_CGROUP_RECLAIM_SHRINK);
 		curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
 		/* Usage is reduced ? */
   		if (curusage >= oldusage)
@@ -3509,10 +3513,9 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 		if (!ret)
 			break;
 
-		mem_cgroup_hierarchical_reclaim(memcg, NULL, GFP_KERNEL,
-						MEM_CGROUP_RECLAIM_NOSWAP |
-						MEM_CGROUP_RECLAIM_SHRINK,
-						NULL);
+		mem_cgroup_reclaim(memcg, GFP_KERNEL,
+				   MEM_CGROUP_RECLAIM_NOSWAP |
+				   MEM_CGROUP_RECLAIM_SHRINK);
 		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
 		/* Usage is reduced ? */
 		if (curusage >= oldusage)
@@ -3555,10 +3558,8 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 			break;
 
 		nr_scanned = 0;
-		reclaimed = mem_cgroup_hierarchical_reclaim(mz->mem, zone,
-						gfp_mask,
-						MEM_CGROUP_RECLAIM_SOFT,
-						&nr_scanned);
+		reclaimed = mem_cgroup_soft_reclaim(mz->mem, zone,
+						    gfp_mask, &nr_scanned);
 		nr_reclaimed += reclaimed;
 		*total_scanned += nr_scanned;
 		spin_lock(&mctz->lock);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b8e22a9..10f8ca0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2115,12 +2115,43 @@ restart:
 static void shrink_zone(int priority, struct zone *zone,
 			struct scan_control *sc)
 {
-	struct mem_cgroup_zone mz = {
-		.mem_cgroup = sc->target_mem_cgroup,
+	struct mem_cgroup *root = sc->target_mem_cgroup;
+	struct mem_cgroup_reclaim_cookie reclaim = {
 		.zone = zone,
+		.priority = priority,
 	};
+	struct mem_cgroup *memcg;
+
+	if (global_reclaim(sc)) {
+		struct mem_cgroup_zone mz = {
+			.mem_cgroup = NULL,
+			.zone = zone,
+		};
+
+		shrink_mem_cgroup_zone(priority, &mz, sc);
+		return;
+	}
+
+	memcg = mem_cgroup_iter(root, NULL, &reclaim);
+	do {
+		struct mem_cgroup_zone mz = {
+			.mem_cgroup = memcg,
+			.zone = zone,
+		};
 
-	shrink_mem_cgroup_zone(priority, &mz, sc);
+		shrink_mem_cgroup_zone(priority, &mz, sc);
+		/*
+		 * Limit reclaim has historically picked one memcg and
+		 * scanned it with decreasing priority levels until
+		 * nr_to_reclaim had been reclaimed.  This priority
+		 * cycle is thus over after a single memcg.
+		 */
+		if (!global_reclaim(sc)) {
+			mem_cgroup_iter_break(root, memcg);
+			break;
+		}
+		memcg = mem_cgroup_iter(root, memcg, &reclaim);
+	} while (memcg);
 }
 
 /*
@@ -2385,6 +2416,10 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 		.order = 0,
 		.target_mem_cgroup = mem,
 	};
+	struct mem_cgroup_zone mz = {
+		.mem_cgroup = mem,
+		.zone = zone,
+	};
 
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
@@ -2400,7 +2435,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 	 * will pick up pages from other mem cgroup's as well. We hack
 	 * the priority and make it zero.
 	 */
-	shrink_zone(0, zone, &sc);
+	shrink_mem_cgroup_zone(0, &mz, &sc);
 
 	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
 
-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
