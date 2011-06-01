Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8F2D96B0023
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 02:25:46 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 3/8] memcg: reclaim statistics
Date: Wed,  1 Jun 2011 08:25:14 +0200
Message-Id: <1306909519-7286-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, there are no statistics whatsoever that would give an
insight into how memory is reclaimed from specific memcgs.

This patch introduces statistics that break down into the following
categories.

1. Limit-triggered direct reclaim

   pgscan_direct_limit
   pgreclaim_direct_limit

   These counters indicate the number of pages scanned and reclaimed
   directly by tasks that needed to allocate memory while the memcg
   had reached its hard limit.

2. Limit-triggered background reclaim

   pgscan_background_limit
   pgreclaim_background_limit

   These counters indicate the number of pages scanned and reclaimed
   by a kernel thread while the memcg's usage was coming close to the
   hard limit, so to prevent allocators from having to drop into
   direct reclaim.

   There is currently no mechanism in the kernel that would increase
   those counters, but there is per-memcg watermark reclaim in the
   workings that would fall into this category.

3. Hierarchy-triggered direct reclaim

   pgscan_direct_hierarchy
   pgreclaim_direct_hierarchy

   These counters indicate the number of pages scanned and reclaimed
   directly by tasks that needed to allocate memory in hierarchical
   parents of the memcg while those parents where experiencing memory
   shortness.

   For now, this could be either because of a hard limit in the
   parents, or because of global memory pressure.

4. Hierarchy-triggered background reclaim

   pgscan_background_hierarchy
   pgreclaim_background_hierarchy

   These counters indicate the number of pages scanned and reclaimed
   by a kernel thread while one of the memcgs hierarchical parents was
   coming close to running out of memory.

   For now, this only accounts for the work done by kswapd to balance
   zones, but there is also per-memcg watermark reclaim in the
   workings that would fall into this category.

The counters for limit-triggered reclaim always inform about pressure
that exists within the memcg and if the workload is too big for its
container.  The counters for hierarchy-triggered reclaim on the other
hand inform about the pressure outside the memcg, such as the limit of
a parent or physical memory shortness.  Having this distinction helps
locating the cause for a thrashing workload in the hierarchy.

In addition, the distinction between direct and background reclaim
shows how well background reclaim can keep up or whether it is
overwhelmed and forces allocators into direct reclaim.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |    9 ++++++
 mm/memcontrol.c            |   61 ++++++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                |    6 ++++
 3 files changed, 76 insertions(+), 0 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 332b0a6..8f402b9 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -108,6 +108,8 @@ void mem_cgroup_stop_hierarchy_walk(struct mem_cgroup *, struct mem_cgroup *);
 /*
  * For memory reclaim.
  */
+void mem_cgroup_count_reclaim(struct mem_cgroup *, bool, bool,
+			      unsigned long, unsigned long);
 int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
 int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
 unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
@@ -293,6 +295,13 @@ static inline bool mem_cgroup_disabled(void)
 	return true;
 }
 
+static inline void mem_cgroup_count_reclaim(struct mem_cgroup *mem,
+					    bool background, bool hierarchy,
+					    unsigned long scanned,
+					    unsigned long reclaimed)
+{
+}
+
 static inline int
 mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 850176e..983efe4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -90,10 +90,24 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_NSTATS,
 };
 
+#define RECLAIM_RECLAIMED 1
+#define RECLAIM_BACKGROUND 2
+#define RECLAIM_HIERARCHY 4
+
 enum mem_cgroup_events_index {
 	MEM_CGROUP_EVENTS_PGPGIN,	/* # of pages paged in */
 	MEM_CGROUP_EVENTS_PGPGOUT,	/* # of pages paged out */
 	MEM_CGROUP_EVENTS_COUNT,	/* # of pages paged in/out */
+	RECLAIM_BASE,
+	/* base + [!]hierarchy + [!]background + [!]reclaimed */
+	PGSCAN_DIRECT_LIMIT = RECLAIM_BASE,
+	PGRECLAIM_DIRECT_LIMIT,
+	PGSCAN_BACKGROUND_LIMIT,
+	PGRECLAIM_BACKGROUND_LIMIT,
+	PGSCAN_DIRECT_HIERARCHY,
+	PGRECLAIM_DIRECT_HIERARCHY,
+	PGSCAN_BACKGROUND_HIERARCHY,
+	PGRECLAIM_BACKGROUND_HIERARCHY,
 	MEM_CGROUP_EVENTS_NSTATS,
 };
 /*
@@ -585,6 +599,21 @@ static void mem_cgroup_swap_statistics(struct mem_cgroup *mem,
 	this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_SWAPOUT], val);
 }
 
+void mem_cgroup_count_reclaim(struct mem_cgroup *mem,
+			      bool background, bool hierarchy,
+			      unsigned long scanned, unsigned long reclaimed)
+{
+	unsigned int base = RECLAIM_BASE;
+
+	if (hierarchy)
+		base += RECLAIM_HIERARCHY;
+	if (background)
+		base += RECLAIM_BACKGROUND;
+
+	this_cpu_add(mem->stat->events[base], scanned);
+	this_cpu_add(mem->stat->events[base + RECLAIM_RECLAIMED], reclaimed);
+}
+
 static unsigned long mem_cgroup_read_events(struct mem_cgroup *mem,
 					    enum mem_cgroup_events_index idx)
 {
@@ -3821,6 +3850,14 @@ enum {
 	MCS_FILE_MAPPED,
 	MCS_PGPGIN,
 	MCS_PGPGOUT,
+	MCS_PGSCAN_DIRECT_LIMIT,
+	MCS_PGRECLAIM_DIRECT_LIMIT,
+	MCS_PGSCAN_BACKGROUND_LIMIT,
+	MCS_PGRECLAIM_BACKGROUND_LIMIT,
+	MCS_PGSCAN_DIRECT_HIERARCHY,
+	MCS_PGRECLAIM_DIRECT_HIERARCHY,
+	MCS_PGSCAN_BACKGROUND_HIERARCHY,
+	MCS_PGRECLAIM_BACKGROUND_HIERARCHY,
 	MCS_SWAP,
 	MCS_INACTIVE_ANON,
 	MCS_ACTIVE_ANON,
@@ -3843,6 +3880,14 @@ struct {
 	{"mapped_file", "total_mapped_file"},
 	{"pgpgin", "total_pgpgin"},
 	{"pgpgout", "total_pgpgout"},
+	{"pgscan_direct_limit", "total_pgscan_direct_limit"},
+	{"pgreclaim_direct_limit", "total_pgreclaim_direct_limit"},
+	{"pgscan_background_limit", "total_pgscan_background_limit"},
+	{"pgreclaim_background_limit", "total_pgreclaim_background_limit"},
+	{"pgscan_direct_hierarchy", "total_pgscan_direct_hierarchy"},
+	{"pgreclaim_direct_hierarchy", "total_pgreclaim_direct_hierarchy"},
+	{"pgscan_background_hierarchy", "total_pgscan_background_hierarchy"},
+	{"pgreclaim_background_hierarchy", "total_pgreclaim_background_hierarchy"},
 	{"swap", "total_swap"},
 	{"inactive_anon", "total_inactive_anon"},
 	{"active_anon", "total_active_anon"},
@@ -3868,6 +3913,22 @@ mem_cgroup_get_local_stat(struct mem_cgroup *mem, struct mcs_total_stat *s)
 	s->stat[MCS_PGPGIN] += val;
 	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PGPGOUT);
 	s->stat[MCS_PGPGOUT] += val;
+	val = mem_cgroup_read_events(mem, PGSCAN_DIRECT_LIMIT);
+	s->stat[MCS_PGSCAN_DIRECT_LIMIT] += val;
+	val = mem_cgroup_read_events(mem, PGRECLAIM_DIRECT_LIMIT);
+	s->stat[MCS_PGRECLAIM_DIRECT_LIMIT] += val;
+	val = mem_cgroup_read_events(mem, PGSCAN_BACKGROUND_LIMIT);
+	s->stat[MCS_PGSCAN_BACKGROUND_LIMIT] += val;
+	val = mem_cgroup_read_events(mem, PGRECLAIM_BACKGROUND_LIMIT);
+	s->stat[MCS_PGRECLAIM_BACKGROUND_LIMIT] += val;
+	val = mem_cgroup_read_events(mem, PGSCAN_DIRECT_HIERARCHY);
+	s->stat[MCS_PGSCAN_DIRECT_HIERARCHY] += val;
+	val = mem_cgroup_read_events(mem, PGRECLAIM_DIRECT_HIERARCHY);
+	s->stat[MCS_PGRECLAIM_DIRECT_HIERARCHY] += val;
+	val = mem_cgroup_read_events(mem, PGSCAN_BACKGROUND_HIERARCHY);
+	s->stat[MCS_PGSCAN_BACKGROUND_HIERARCHY] += val;
+	val = mem_cgroup_read_events(mem, PGRECLAIM_BACKGROUND_HIERARCHY);
+	s->stat[MCS_PGRECLAIM_BACKGROUND_HIERARCHY] += val;
 	if (do_swap_account) {
 		val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_SWAPOUT);
 		s->stat[MCS_SWAP] += val * PAGE_SIZE;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7e9bfca..c7d4b44 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1985,10 +1985,16 @@ static void shrink_zone(int priority, struct zone *zone,
 
 	first = mem = mem_cgroup_hierarchy_walk(root, mem);
 	for (;;) {
+		unsigned long reclaimed = sc->nr_reclaimed;
+		unsigned long scanned = sc->nr_scanned;
 		unsigned long nr_reclaimed;
 
 		sc->mem_cgroup = mem;
 		do_shrink_zone(priority, zone, sc);
+		mem_cgroup_count_reclaim(mem, current_is_kswapd(),
+					 mem != root, /* limit or hierarchy? */
+					 sc->nr_scanned - scanned,
+					 sc->nr_reclaimed - reclaimed);
 
 		nr_reclaimed = sc->nr_reclaimed - nr_reclaimed_before;
 		if (nr_reclaimed >= sc->nr_to_reclaim)
-- 
1.7.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
