Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 29AE190010F
	for <linux-mm@kvack.org>; Thu, 12 May 2011 14:47:54 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [RFC PATCH 4/4] Add some debugging stats
Date: Thu, 12 May 2011 11:47:12 -0700
Message-Id: <1305226032-21448-5-git-send-email-yinghan@google.com>
In-Reply-To: <1305226032-21448-1-git-send-email-yinghan@google.com>
References: <1305226032-21448-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

This patch is not intended to be included but only including debugging
stats.

It includes counters memcg being inserted/deleted in the list. And also
counters where zone_wmark_ok() fullfilled from soft_limit reclaim.

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h    |   14 ++++++++++++++
 include/linux/vm_event_item.h |    1 +
 mm/memcontrol.c               |   23 +++++++++++++++++++++++
 mm/vmscan.c                   |    3 ++-
 mm/vmstat.c                   |    2 ++
 5 files changed, 42 insertions(+), 1 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index c7fcb26..d97aa1c 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -121,6 +121,10 @@ extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 extern int do_swap_account;
 #endif
 
+/* background reclaim stats */
+void mem_cgroup_list_insert(struct mem_cgroup *memcg, int val);
+void mem_cgroup_list_remove(struct mem_cgroup *memcg, int val);
+
 static inline bool mem_cgroup_disabled(void)
 {
 	if (mem_cgroup_subsys.disabled)
@@ -363,6 +367,16 @@ static inline
 void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
 {
 }
+
+static inline void mem_cgroup_list_insert(struct mem_cgroup *memcg,
+					  int val)
+{
+}
+
+static inline void mem_cgroup_list_remove(struct mem_cgroup *memcg,
+					  int val)
+{
+}
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 03b90cdc..f226bfd 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -35,6 +35,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSWAPD_INODESTEAL,
 		KSWAPD_LOW_WMARK_HIT_QUICKLY, KSWAPD_HIGH_WMARK_HIT_QUICKLY,
 		KSWAPD_SKIP_CONGESTION_WAIT,
+		KSWAPD_ZONE_WMARK_OK, KSWAPD_SOFT_LIMIT_ZONE_WMARK_OK,
 		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
 #ifdef CONFIG_COMPACTION
 		COMPACTBLOCKS, COMPACTPAGES, COMPACTPAGEFAILED,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b87ccc8..bd7c481 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -103,6 +103,8 @@ enum mem_cgroup_events_index {
 					/* soft reclaim in direct reclaim */
 	MEM_CGROUP_EVENTS_SOFT_DIRECT_SCAN, /* # of pages scanned from */
 					/* soft reclaim in direct reclaim */
+	MEM_CGROUP_EVENTS_LIST_INSERT,
+	MEM_CGROUP_EVENTS_LIST_REMOVE,
 	MEM_CGROUP_EVENTS_NSTATS,
 };
 /*
@@ -411,6 +413,7 @@ __mem_cgroup_insert_exceeded(struct mem_cgroup *mem,
 
 	list_add(&mz->soft_limit_list, &mclz->list);
 	mz->on_list = true;
+	mem_cgroup_list_insert(mem, 1);
 }
 
 static void
@@ -437,6 +440,7 @@ __mem_cgroup_remove_exceeded(struct mem_cgroup *mem,
 
 	list_del(&mz->soft_limit_list);
 	mz->on_list = false;
+	mem_cgroup_list_remove(mem, 1);
 }
 
 static void
@@ -550,6 +554,16 @@ void mem_cgroup_pgmajfault(struct mem_cgroup *mem, int val)
 	this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_PGMAJFAULT], val);
 }
 
+void mem_cgroup_list_insert(struct mem_cgroup *mem, int val)
+{
+	this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_LIST_INSERT], val);
+}
+
+void mem_cgroup_list_remove(struct mem_cgroup *mem, int val)
+{
+	this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_LIST_REMOVE], val);
+}
+
 static unsigned long mem_cgroup_read_events(struct mem_cgroup *mem,
 					    enum mem_cgroup_events_index idx)
 {
@@ -3422,6 +3436,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 		if (zone_watermark_ok_safe(zone, order,
 				high_wmark_pages(zone) + balance_gap,
 				end_zone, 0)) {
+			count_vm_events(KSWAPD_SOFT_LIMIT_ZONE_WMARK_OK, 1);
 			break;
 		}
 
@@ -3838,6 +3853,8 @@ enum {
 	MCS_SOFT_KSWAPD_SCAN,
 	MCS_SOFT_DIRECT_STEAL,
 	MCS_SOFT_DIRECT_SCAN,
+	MCS_LIST_INSERT,
+	MCS_LIST_REMOVE,
 	MCS_INACTIVE_ANON,
 	MCS_ACTIVE_ANON,
 	MCS_INACTIVE_FILE,
@@ -3866,6 +3883,8 @@ struct {
 	{"soft_kswapd_scan", "total_soft_kswapd_scan"},
 	{"soft_direct_steal", "total_soft_direct_steal"},
 	{"soft_direct_scan", "total_soft_direct_scan"},
+	{"list_insert", "total_list_insert"},
+	{"list_remove", "total_list_remove"},
 	{"inactive_anon", "total_inactive_anon"},
 	{"active_anon", "total_active_anon"},
 	{"inactive_file", "total_inactive_file"},
@@ -3906,6 +3925,10 @@ mem_cgroup_get_local_stat(struct mem_cgroup *mem, struct mcs_total_stat *s)
 	s->stat[MCS_PGFAULT] += val;
 	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PGMAJFAULT);
 	s->stat[MCS_PGMAJFAULT] += val;
+	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_LIST_INSERT);
+	s->stat[MCS_LIST_INSERT] += val;
+	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_LIST_REMOVE);
+	s->stat[MCS_LIST_REMOVE] += val;
 
 	/* per zone stat */
 	val = mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_ANON);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9d79070..fc3da68 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2492,11 +2492,12 @@ loop_again:
 				zone_clear_flag(zone, ZONE_CONGESTED);
 				if (i <= *classzone_idx)
 					balanced += zone->present_pages;
+				count_vm_events(KSWAPD_ZONE_WMARK_OK, 1);
 			}
-
 		}
 		if (all_zones_ok || (order && pgdat_balanced(pgdat, balanced, *classzone_idx)))
 			break;		/* kswapd: all done */
+
 		/*
 		 * OK, kswapd is getting into trouble.  Take a nap, then take
 		 * another pass across the zones.
diff --git a/mm/vmstat.c b/mm/vmstat.c
index a2b7344..2b3a7e5 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -922,6 +922,8 @@ const char * const vmstat_text[] = {
 	"kswapd_low_wmark_hit_quickly",
 	"kswapd_high_wmark_hit_quickly",
 	"kswapd_skip_congestion_wait",
+	"kswapd_zone_wmark_ok",
+	"kswapd_soft_limit_zone_wmark_ok",
 	"pageoutrun",
 	"allocstall",
 
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
