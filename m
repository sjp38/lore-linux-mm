Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EAE468D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 01:56:59 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V3 2/2] add stats to monitor soft_limit reclaim
Date: Mon, 28 Mar 2011 22:56:26 -0700
Message-Id: <1301378186-23199-3-git-send-email-yinghan@google.com>
In-Reply-To: <1301378186-23199-1-git-send-email-yinghan@google.com>
References: <1301378186-23199-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

The stat is added:

/dev/cgroup/*/memory.stat
soft_steal:        - # of pages reclaimed from soft_limit hierarchical reclaim
soft_scan:         - # of pages scanned from soft_limit hierarchical reclaim
total_soft_steal:  - # sum of all children's "soft_steal"
total_soft_scan:   - # sum of all children's "soft_scan"

Change v3..v2
1. add the soft_scan stat
2. count the soft_scan and soft_steal within hierarchical reclaim
3. removed the unnecessary export in memcontrol.h

Signed-off-by: Ying Han <yinghan@google.com>
---
 Documentation/cgroups/memory.txt |    4 ++++
 include/linux/memcontrol.h       |    1 -
 mm/memcontrol.c                  |   25 +++++++++++++++++++++++++
 3 files changed, 29 insertions(+), 1 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index b6ed61c..3bf0047 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -385,6 +385,8 @@ mapped_file	- # of bytes of mapped file (includes tmpfs/shmem)
 pgpgin		- # of pages paged in (equivalent to # of charging events).
 pgpgout		- # of pages paged out (equivalent to # of uncharging events).
 swap		- # of bytes of swap usage
+soft_steal	- # of pages reclaimed from global hierarchical reclaim
+soft_scan	- # of pages scanned from global hierarchical reclaim
 inactive_anon	- # of bytes of anonymous memory and swap cache memory on
 		LRU list.
 active_anon	- # of bytes of anonymous and swap cache memory on active
@@ -406,6 +408,8 @@ total_mapped_file	- sum of all children's "cache"
 total_pgpgin		- sum of all children's "pgpgin"
 total_pgpgout		- sum of all children's "pgpgout"
 total_swap		- sum of all children's "swap"
+total_soft_steal	- sum of all children's "soft_steal"
+total_soft_scan		- sum of all children's "soft_scan"
 total_inactive_anon	- sum of all children's "inactive_anon"
 total_active_anon	- sum of all children's "active_anon"
 total_inactive_file	- sum of all children's "inactive_file"
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 01281ac..9d094fc 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -115,7 +115,6 @@ struct zone_reclaim_stat*
 mem_cgroup_get_reclaim_stat_from_page(struct page *page);
 extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 					struct task_struct *p);
-
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern int do_swap_account;
 #endif
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 67fff28..29f213c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -94,6 +94,10 @@ enum mem_cgroup_events_index {
 	MEM_CGROUP_EVENTS_PGPGIN,	/* # of pages paged in */
 	MEM_CGROUP_EVENTS_PGPGOUT,	/* # of pages paged out */
 	MEM_CGROUP_EVENTS_COUNT,	/* # of pages paged in/out */
+	MEM_CGROUP_EVENTS_SOFT_STEAL,	/* # of pages reclaimed from */
+					/* soft reclaim               */
+	MEM_CGROUP_EVENTS_SOFT_SCAN,	/* # of pages scanned from */
+					/* soft reclaim               */
 	MEM_CGROUP_EVENTS_NSTATS,
 };
 /*
@@ -624,6 +628,16 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
 	preempt_enable();
 }
 
+static void mem_cgroup_soft_steal(struct mem_cgroup *mem, int val)
+{
+	this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_SOFT_STEAL], val);
+}
+
+static void mem_cgroup_soft_scan(struct mem_cgroup *mem, int val)
+{
+	this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_SOFT_SCAN], val);
+}
+
 static unsigned long mem_cgroup_get_local_zonestat(struct mem_cgroup *mem,
 					enum lru_list idx)
 {
@@ -1491,6 +1505,8 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 				noswap, get_swappiness(victim), zone,
 				&nr_scanned);
 			*total_scanned += nr_scanned;
+			mem_cgroup_soft_steal(victim, ret);
+			mem_cgroup_soft_scan(victim, nr_scanned);
 		} else
 			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
 						noswap, get_swappiness(victim));
@@ -3326,6 +3342,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						&nr_scanned);
 		nr_reclaimed += reclaimed;
 		*total_scanned += nr_scanned;
+
 		spin_lock(&mctz->lock);
 
 		/*
@@ -3783,6 +3800,8 @@ enum {
 	MCS_PGPGIN,
 	MCS_PGPGOUT,
 	MCS_SWAP,
+	MCS_SOFT_STEAL,
+	MCS_SOFT_SCAN,
 	MCS_INACTIVE_ANON,
 	MCS_ACTIVE_ANON,
 	MCS_INACTIVE_FILE,
@@ -3805,6 +3824,8 @@ struct {
 	{"pgpgin", "total_pgpgin"},
 	{"pgpgout", "total_pgpgout"},
 	{"swap", "total_swap"},
+	{"soft_steal", "total_soft_steal"},
+	{"soft_scan", "total_soft_scan"},
 	{"inactive_anon", "total_inactive_anon"},
 	{"active_anon", "total_active_anon"},
 	{"inactive_file", "total_inactive_file"},
@@ -3833,6 +3854,10 @@ mem_cgroup_get_local_stat(struct mem_cgroup *mem, struct mcs_total_stat *s)
 		val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_SWAPOUT);
 		s->stat[MCS_SWAP] += val * PAGE_SIZE;
 	}
+	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_SOFT_STEAL);
+	s->stat[MCS_SOFT_STEAL] += val;
+	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_SOFT_SCAN);
+	s->stat[MCS_SOFT_SCAN] += val;
 
 	/* per zone stat */
 	val = mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_ANON);
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
