Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E744D6B0022
	for <linux-mm@kvack.org>; Mon,  2 May 2011 12:51:40 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V2 2/2] Add stats to monitor soft_limit reclaim
Date: Mon,  2 May 2011 09:50:25 -0700
Message-Id: <1304355025-1421-3-git-send-email-yinghan@google.com>
In-Reply-To: <1304355025-1421-1-git-send-email-yinghan@google.com>
References: <1304355025-1421-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

This patch extend the soft_limit reclaim stats to both global background
reclaim and global direct reclaim.

The following stats are renamed and added:

$cat /dev/cgroup/memory/A/memory.stat
soft_kswapd_steal 1053626
soft_kswapd_scan 1053693
soft_direct_steal 1481810
soft_direct_scan 1481996

changelog v2..v1:
1. rename the stats on soft_kswapd/direct_steal/scan.
2. fix the documentation to match the stat name.

Signed-off-by: Ying Han <yinghan@google.com>
---
 Documentation/cgroups/memory.txt |   16 +++++++--
 mm/memcontrol.c                  |   68 ++++++++++++++++++++++++++++----------
 2 files changed, 62 insertions(+), 22 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 0c40dab..575cf33 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -387,8 +387,14 @@ pgpgout		- # of pages paged out (equivalent to # of uncharging events).
 swap		- # of bytes of swap usage
 pgfault		- # of page faults.
 pgmajfault	- # of major page faults.
-soft_steal	- # of pages reclaimed from global hierarchical reclaim
-soft_scan	- # of pages scanned from global hierarchical reclaim
+soft_kswapd_steal- # of pages reclaimed in global hierarchical reclaim from
+		background reclaim
+soft_kswapd_scan - # of pages scanned in global hierarchical reclaim from
+		background reclaim
+soft_direct_steal- # of pages reclaimed in global hierarchical reclaim from
+		direct reclaim
+soft_direct_scan- # of pages scanned in global hierarchical reclaim from
+		direct reclaim
 inactive_anon	- # of bytes of anonymous memory and swap cache memory on
 		LRU list.
 active_anon	- # of bytes of anonymous and swap cache memory on active
@@ -412,8 +418,10 @@ total_pgpgout		- sum of all children's "pgpgout"
 total_swap		- sum of all children's "swap"
 total_pgfault		- sum of all children's "pgfault"
 total_pgmajfault	- sum of all children's "pgmajfault"
-total_soft_steal	- sum of all children's "soft_steal"
-total_soft_scan		- sum of all children's "soft_scan"
+total_soft_kswapd_steal	- sum of all children's "soft_kswapd_steal"
+total_soft_kswapd_scan	- sum of all children's "soft_kswapd_scan"
+total_soft_direct_steal	- sum of all children's "soft_direct_steal"
+total_soft_direct_scan	- sum of all children's "soft_direct_scan"
 total_inactive_anon	- sum of all children's "inactive_anon"
 total_active_anon	- sum of all children's "active_anon"
 total_inactive_file	- sum of all children's "inactive_file"
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c2776f1..da1fb2b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -96,10 +96,14 @@ enum mem_cgroup_events_index {
 	MEM_CGROUP_EVENTS_COUNT,	/* # of pages paged in/out */
 	MEM_CGROUP_EVENTS_PGFAULT,	/* # of page-faults */
 	MEM_CGROUP_EVENTS_PGMAJFAULT,	/* # of major page-faults */
-	MEM_CGROUP_EVENTS_SOFT_STEAL,	/* # of pages reclaimed from */
-					/* soft reclaim               */
-	MEM_CGROUP_EVENTS_SOFT_SCAN,	/* # of pages scanned from */
-					/* soft reclaim               */
+	MEM_CGROUP_EVENTS_SOFT_KSWAPD_STEAL, /* # of pages reclaimed from */
+					/* soft reclaim in background reclaim */
+	MEM_CGROUP_EVENTS_SOFT_KSWAPD_SCAN, /* # of pages scanned from */
+					/* soft reclaim in background reclaim */
+	MEM_CGROUP_EVENTS_SOFT_DIRECT_STEAL, /* # of pages reclaimed from */
+					/* soft reclaim in direct reclaim */
+	MEM_CGROUP_EVENTS_SOFT_DIRECT_SCAN, /* # of pages scanned from */
+					/* soft reclaim in direct reclaim */
 	MEM_CGROUP_EVENTS_NSTATS,
 };
 /*
@@ -640,14 +644,30 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
 	preempt_enable();
 }
 
-static void mem_cgroup_soft_steal(struct mem_cgroup *mem, int val)
+static void mem_cgroup_soft_steal(struct mem_cgroup *mem, bool is_kswapd,
+				  int val)
 {
-	this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_SOFT_STEAL], val);
+	if (is_kswapd)
+		this_cpu_add(
+			mem->stat->events[MEM_CGROUP_EVENTS_SOFT_KSWAPD_STEAL],
+									val);
+	else
+		this_cpu_add(
+			mem->stat->events[MEM_CGROUP_EVENTS_SOFT_DIRECT_STEAL],
+									val);
 }
 
-static void mem_cgroup_soft_scan(struct mem_cgroup *mem, int val)
+static void mem_cgroup_soft_scan(struct mem_cgroup *mem, bool is_kswapd,
+				 int val)
 {
-	this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_SOFT_SCAN], val);
+	if (is_kswapd)
+		this_cpu_add(
+			mem->stat->events[MEM_CGROUP_EVENTS_SOFT_KSWAPD_SCAN],
+									val);
+	else
+		this_cpu_add(
+			mem->stat->events[MEM_CGROUP_EVENTS_SOFT_DIRECT_SCAN],
+									val);
 }
 
 static unsigned long mem_cgroup_get_local_zonestat(struct mem_cgroup *mem,
@@ -1495,6 +1515,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 	bool noswap = reclaim_options & MEM_CGROUP_RECLAIM_NOSWAP;
 	bool shrink = reclaim_options & MEM_CGROUP_RECLAIM_SHRINK;
 	bool check_soft = reclaim_options & MEM_CGROUP_RECLAIM_SOFT;
+	bool is_kswapd = false;
 	unsigned long excess;
 	unsigned long nr_scanned;
 
@@ -1504,6 +1525,9 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 	if (root_mem->memsw_is_minimum)
 		noswap = true;
 
+	if (current_is_kswapd())
+		is_kswapd = true;
+
 	while (1) {
 		victim = mem_cgroup_select_victim(root_mem);
 		if (victim == root_mem) {
@@ -1544,8 +1568,8 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 				noswap, get_swappiness(victim), zone,
 				&nr_scanned);
 			*total_scanned += nr_scanned;
-			mem_cgroup_soft_steal(victim, ret);
-			mem_cgroup_soft_scan(victim, nr_scanned);
+			mem_cgroup_soft_steal(victim, is_kswapd, ret);
+			mem_cgroup_soft_scan(victim, is_kswapd, nr_scanned);
 		} else
 			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
 						noswap, get_swappiness(victim));
@@ -3840,8 +3864,10 @@ enum {
 	MCS_SWAP,
 	MCS_PGFAULT,
 	MCS_PGMAJFAULT,
-	MCS_SOFT_STEAL,
-	MCS_SOFT_SCAN,
+	MCS_SOFT_KSWAPD_STEAL,
+	MCS_SOFT_KSWAPD_SCAN,
+	MCS_SOFT_DIRECT_STEAL,
+	MCS_SOFT_DIRECT_SCAN,
 	MCS_INACTIVE_ANON,
 	MCS_ACTIVE_ANON,
 	MCS_INACTIVE_FILE,
@@ -3866,8 +3892,10 @@ struct {
 	{"swap", "total_swap"},
 	{"pgfault", "total_pgfault"},
 	{"pgmajfault", "total_pgmajfault"},
-	{"soft_steal", "total_soft_steal"},
-	{"soft_scan", "total_soft_scan"},
+	{"soft_kswapd_steal", "total_soft_kswapd_steal"},
+	{"soft_kswapd_scan", "total_soft_kswapd_scan"},
+	{"soft_direct_steal", "total_soft_direct_steal"},
+	{"soft_direct_scan", "total_soft_direct_scan"},
 	{"inactive_anon", "total_inactive_anon"},
 	{"active_anon", "total_active_anon"},
 	{"inactive_file", "total_inactive_file"},
@@ -3896,10 +3924,14 @@ mem_cgroup_get_local_stat(struct mem_cgroup *mem, struct mcs_total_stat *s)
 		val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_SWAPOUT);
 		s->stat[MCS_SWAP] += val * PAGE_SIZE;
 	}
-	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_SOFT_STEAL);
-	s->stat[MCS_SOFT_STEAL] += val;
-	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_SOFT_SCAN);
-	s->stat[MCS_SOFT_SCAN] += val;
+	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_SOFT_KSWAPD_STEAL);
+	s->stat[MCS_SOFT_KSWAPD_STEAL] += val;
+	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_SOFT_KSWAPD_SCAN);
+	s->stat[MCS_SOFT_KSWAPD_SCAN] += val;
+	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_SOFT_DIRECT_STEAL);
+	s->stat[MCS_SOFT_DIRECT_STEAL] += val;
+	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_SOFT_DIRECT_SCAN);
+	s->stat[MCS_SOFT_DIRECT_SCAN] += val;
 	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PGFAULT);
 	s->stat[MCS_PGFAULT] += val;
 	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PGMAJFAULT);
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
