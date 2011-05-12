Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6FCA0900001
	for <linux-mm@kvack.org>; Thu, 12 May 2011 10:54:46 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [rfc patch 4/6] memcg: reclaim statistics
Date: Thu, 12 May 2011 16:53:56 +0200
Message-Id: <1305212038-15445-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

TODO: write proper changelog.  Here is an excerpt from
http://lkml.kernel.org/r/20110428123652.GM12437@cmpxchg.org:

: 1. Limit-triggered direct reclaim
:
: The memory cgroup hits its limit and the task does direct reclaim from
: its own memcg.  We probably want statistics for this separately from
: background reclaim to see how successful background reclaim is, the
: same reason we have this separation in the global vmstat as well.
:
: 	pgscan_direct_limit
: 	pgfree_direct_limit
:
: 2. Limit-triggered background reclaim
:
: This is the watermark-based asynchroneous reclaim that is currently in
: discussion.  It's triggered by the memcg breaching its watermark,
: which is relative to its hard-limit.  I named it kswapd because I
: still think kswapd should do this job, but it is all open for
: discussion, obviously.  Treat it as meaning 'background' or
: 'asynchroneous'.
:
: 	pgscan_kswapd_limit
: 	pgfree_kswapd_limit
:
: 3. Hierarchy-triggered direct reclaim
:
: A condition outside the memcg leads to a task directly reclaiming from
: this memcg.  This could be global memory pressure for example, but
: also a parent cgroup hitting its limit.  It's probably helpful to
: assume global memory pressure meaning that the root cgroup hit its
: limit, conceptually.  We don't have that yet, but this could be the
: direct softlimit reclaim Ying mentioned above.
:
: 	pgscan_direct_hierarchy
: 	pgsteal_direct_hierarchy
:
: 4. Hierarchy-triggered background reclaim
:
: An outside condition leads to kswapd reclaiming from this memcg, like
: kswapd doing softlimit pushback due to global memory pressure.
:
: 	pgscan_kswapd_hierarchy
: 	pgsteal_kswapd_hierarchy
:
: ---
:
: With these stats in place, you can see how much pressure there is on
: your memcg hierarchy.  This includes machine utilization and if you
: overcommitted too much on a global level if there is a lot of reclaim
: activity indicated in the hierarchical stats.
:
: With the limit-based stats, you can see the amount of internal
: pressure of memcgs, which shows you if you overcommitted on a local
: level.
:
: And for both cases, you can also see the effectiveness of background
: reclaim by comparing the direct and the kswapd stats.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |    9 ++++++
 mm/memcontrol.c            |   63 ++++++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                |    7 +++++
 3 files changed, 79 insertions(+), 0 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 58728c7..a4c84db 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -105,6 +105,8 @@ extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
  * For memory reclaim.
  */
 void mem_cgroup_hierarchy_walk(struct mem_cgroup *, struct mem_cgroup **);
+void mem_cgroup_count_reclaim(struct mem_cgroup *, bool, bool,
+			      unsigned long, unsigned long);
 int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
 int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
 unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
@@ -296,6 +298,13 @@ static inline void mem_cgroup_hierarchy_walk(struct mem_cgroup *start,
 	*iter = start;
 }
 
+static inline void mem_cgroup_count_reclaim(struct mem_cgroup *mem,
+					    bool kswapd, bool hierarchy,
+					    unsigned long scanned,
+					    unsigned long reclaimed)
+{
+}
+
 static inline int
 mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index edcd55a..d762706 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -90,10 +90,24 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_NSTATS,
 };
 
+#define RECLAIM_RECLAIMED 1
+#define RECLAIM_HIERARCHY 2
+#define RECLAIM_KSWAPD 4
+
 enum mem_cgroup_events_index {
 	MEM_CGROUP_EVENTS_PGPGIN,	/* # of pages paged in */
 	MEM_CGROUP_EVENTS_PGPGOUT,	/* # of pages paged out */
 	MEM_CGROUP_EVENTS_COUNT,	/* # of pages paged in/out */
+	RECLAIM_BASE,
+	PGSCAN_DIRECT_LIMIT = RECLAIM_BASE,
+	PGFREE_DIRECT_LIMIT = RECLAIM_BASE + RECLAIM_RECLAIMED,
+	PGSCAN_DIRECT_HIERARCHY = RECLAIM_BASE + RECLAIM_HIERARCHY,
+	PGSTEAL_DIRECT_HIERARCHY = RECLAIM_BASE + RECLAIM_HIERARCHY + RECLAIM_RECLAIMED,
+	/* you know the drill... */
+	PGSCAN_KSWAPD_LIMIT,
+	PGFREE_KSWAPD_LIMIT,
+	PGSCAN_KSWAPD_HIERARCHY,
+	PGSTEAL_KSWAPD_HIERARCHY,
 	MEM_CGROUP_EVENTS_NSTATS,
 };
 /*
@@ -575,6 +589,23 @@ static void mem_cgroup_swap_statistics(struct mem_cgroup *mem,
 	this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_SWAPOUT], val);
 }
 
+void mem_cgroup_count_reclaim(struct mem_cgroup *mem,
+			      bool kswapd, bool hierarchy,
+			      unsigned long scanned, unsigned long reclaimed)
+{
+	unsigned int base = RECLAIM_BASE;
+
+	if (!mem)
+		mem = root_mem_cgroup;
+	if (kswapd)
+		base += RECLAIM_KSWAPD;
+	if (hierarchy)
+		base += RECLAIM_HIERARCHY;
+
+	this_cpu_add(mem->stat->events[base], scanned);
+	this_cpu_add(mem->stat->events[base + RECLAIM_RECLAIMED], reclaimed);
+}
+
 static unsigned long mem_cgroup_read_events(struct mem_cgroup *mem,
 					    enum mem_cgroup_events_index idx)
 {
@@ -3817,6 +3848,14 @@ enum {
 	MCS_FILE_MAPPED,
 	MCS_PGPGIN,
 	MCS_PGPGOUT,
+	MCS_PGSCAN_DIRECT_LIMIT,
+	MCS_PGFREE_DIRECT_LIMIT,
+	MCS_PGSCAN_DIRECT_HIERARCHY,
+	MCS_PGSTEAL_DIRECT_HIERARCHY,
+	MCS_PGSCAN_KSWAPD_LIMIT,
+	MCS_PGFREE_KSWAPD_LIMIT,
+	MCS_PGSCAN_KSWAPD_HIERARCHY,
+	MCS_PGSTEAL_KSWAPD_HIERARCHY,
 	MCS_SWAP,
 	MCS_INACTIVE_ANON,
 	MCS_ACTIVE_ANON,
@@ -3839,6 +3878,14 @@ struct {
 	{"mapped_file", "total_mapped_file"},
 	{"pgpgin", "total_pgpgin"},
 	{"pgpgout", "total_pgpgout"},
+	{"pgscan_direct_limit", "total_pgscan_direct_limit"},
+	{"pgfree_direct_limit", "total_pgfree_direct_limit"},
+	{"pgscan_direct_hierarchy", "total_pgscan_direct_hierarchy"},
+	{"pgsteal_direct_hierarchy", "total_pgsteal_direct_hierarchy"},
+	{"pgscan_kswapd_limit", "total_pgscan_kswapd_limit"},
+	{"pgfree_kswapd_limit", "total_pgfree_kswapd_limit"},
+	{"pgscan_kswapd_hierarchy", "total_pgscan_kswapd_hierarchy"},
+	{"pgsteal_kswapd_hierarchy", "total_pgsteal_kswapd_hierarchy"},
 	{"swap", "total_swap"},
 	{"inactive_anon", "total_inactive_anon"},
 	{"active_anon", "total_active_anon"},
@@ -3864,6 +3911,22 @@ mem_cgroup_get_local_stat(struct mem_cgroup *mem, struct mcs_total_stat *s)
 	s->stat[MCS_PGPGIN] += val;
 	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PGPGOUT);
 	s->stat[MCS_PGPGOUT] += val;
+	val = mem_cgroup_read_events(mem, PGSCAN_DIRECT_LIMIT);
+	s->stat[MCS_PGSCAN_DIRECT_LIMIT] += val;
+	val = mem_cgroup_read_events(mem, PGFREE_DIRECT_LIMIT);
+	s->stat[MCS_PGFREE_DIRECT_LIMIT] += val;
+	val = mem_cgroup_read_events(mem, PGSCAN_DIRECT_HIERARCHY);
+	s->stat[MCS_PGSCAN_DIRECT_HIERARCHY] += val;
+	val = mem_cgroup_read_events(mem, PGSTEAL_DIRECT_HIERARCHY);
+	s->stat[MCS_PGSTEAL_DIRECT_HIERARCHY] += val;
+	val = mem_cgroup_read_events(mem, PGSCAN_KSWAPD_LIMIT);
+	s->stat[MCS_PGSCAN_KSWAPD_LIMIT] += val;
+	val = mem_cgroup_read_events(mem, PGFREE_KSWAPD_LIMIT);
+	s->stat[MCS_PGFREE_KSWAPD_LIMIT] += val;
+	val = mem_cgroup_read_events(mem, PGSCAN_KSWAPD_HIERARCHY);
+	s->stat[MCS_PGSCAN_KSWAPD_HIERARCHY] += val;
+	val = mem_cgroup_read_events(mem, PGSTEAL_KSWAPD_HIERARCHY);
+	s->stat[MCS_PGSTEAL_KSWAPD_HIERARCHY] += val;
 	if (do_swap_account) {
 		val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_SWAPOUT);
 		s->stat[MCS_SWAP] += val * PAGE_SIZE;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index e2a3647..0e45ceb 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1961,9 +1961,16 @@ static void shrink_zone(int priority, struct zone *zone,
 	struct mem_cgroup *mem = NULL;
 
 	do {
+		unsigned long reclaimed = sc->nr_reclaimed;
+		unsigned long scanned = sc->nr_scanned;
+
 		mem_cgroup_hierarchy_walk(root, &mem);
 		sc->current_memcg = mem;
 		do_shrink_zone(priority, zone, sc);
+		mem_cgroup_count_reclaim(mem, current_is_kswapd(),
+					 mem != root, /* limit or hierarchy? */
+					 sc->nr_scanned - scanned,
+					 sc->nr_reclaimed - reclaimed);
 	} while (mem != root);
 
 	/* For good measure, noone higher up the stack should look at it */
-- 
1.7.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
