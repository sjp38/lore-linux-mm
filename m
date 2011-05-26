Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 9C7AA6B0028
	for <linux-mm@kvack.org>; Thu, 26 May 2011 01:43:25 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 61E373EE0AE
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:43:22 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4854345DF21
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:43:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 32B2F45DF27
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:43:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 260EEEF8001
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:43:22 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DCB69E08002
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:43:21 +0900 (JST)
Date: Thu, 26 May 2011 14:36:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH v3 10/10] memcg : reclaim statistics
Message-Id: <20110526143631.adc2c911.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>


This patch adds a file memory.reclaim_stat.

This file shows following.
==
recent_scan_success_ratio  12 # recent reclaim/scan ratio.
limit_scan_pages 671	      # scan caused by hitting limit.
limit_freed_pages 538	      # freed pages by limit_scan
limit_elapsed_ns 518555076    # elapsed time in LRU scanning by limit.
soft_scan_pages 0	      # scan caused by softlimit.
soft_freed_pages 0	      # freed pages by soft_scan.
soft_elapsed_ns 0	      # elapsed time in LRU scanning by softlimit.
margin_scan_pages 16744221    # scan caused by auto-keep-margin
margin_freed_pages 565943     # freed pages by auto-keep-margin.
margin_elapsed_ns 5545388791  # elapsed time in LRU scanning by auto-keep-margin

This patch adds a new file rather than adding more stats to memory.stat. By it,
this support "reset" accounting by

  # echo 0 > .../memory.reclaim_stat

This is good for debug and tuning.

TODO:
 - add Documentaion.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   87 ++++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 79 insertions(+), 8 deletions(-)

Index: memcg_async/mm/memcontrol.c
===================================================================
--- memcg_async.orig/mm/memcontrol.c
+++ memcg_async/mm/memcontrol.c
@@ -216,6 +216,13 @@ static void mem_cgroup_update_margin_to_
 static void mem_cgroup_may_async_reclaim(struct mem_cgroup *mem);
 static void mem_cgroup_reflesh_scan_ratio(struct mem_cgroup *mem);
 
+enum scan_type {
+	LIMIT_SCAN,	/* scan memory because memcg hits limit */
+	SOFT_SCAN,	/* scan memory because of soft limit */
+	MARGIN_SCAN,	/* scan memory for making margin to limit */
+	NR_SCAN_TYPES,
+};
+
 /*
  * The memory controller data structure. The memory controller controls both
  * page cache and RSS per cgroup. We would eventually like to provide
@@ -300,6 +307,13 @@ struct mem_cgroup {
 	unsigned long	scanned;
 	unsigned long	reclaimed;
 	unsigned long	next_scanratio_update;
+	/* For statistics */
+	struct {
+		unsigned long nr_scanned_pages;
+		unsigned long nr_reclaimed_pages;
+		unsigned long elapsed_ns;
+	} scan_stat[NR_SCAN_TYPES];
+
 	/*
 	 * percpu counter.
 	 */
@@ -1426,7 +1440,9 @@ unsigned int mem_cgroup_swappiness(struc
 
 static void __mem_cgroup_update_scan_ratio(struct mem_cgroup *mem,
 				unsigned long scanned,
-				unsigned long reclaimed)
+				unsigned long reclaimed,
+				unsigned long elapsed,
+				enum scan_type type)
 {
 	unsigned long limit;
 
@@ -1439,6 +1455,9 @@ static void __mem_cgroup_update_scan_rat
 		mem->scanned /= 2;
 		mem->reclaimed /= 2;
 	}
+	mem->scan_stat[type].nr_scanned_pages += scanned;
+	mem->scan_stat[type].nr_reclaimed_pages += reclaimed;
+	mem->scan_stat[type].elapsed_ns += elapsed;
 	spin_unlock(&mem->scan_stat_lock);
 }
 
@@ -1448,6 +1467,8 @@ static void __mem_cgroup_update_scan_rat
  * @root : root memcg of hierarchy walk.
  * @scanned : scanned pages
  * @reclaimed: reclaimed pages.
+ * @elapsed: used time for memory reclaim
+ * @type : scan type as LIMIT_SCAN, SOFT_SCAN, MARGIN_SCAN.
  *
  * record scan/reclaim ratio to the memcg both to a child and it's root
  * mem cgroup, which is a reclaim target. This value is used for
@@ -1457,11 +1478,14 @@ static void __mem_cgroup_update_scan_rat
 static void mem_cgroup_update_scan_ratio(struct mem_cgroup *mem,
 				  struct mem_cgroup *root,
 				unsigned long scanned,
-				unsigned long reclaimed)
+				unsigned long reclaimed,
+				unsigned long elapsed,
+				int type)
 {
-	__mem_cgroup_update_scan_ratio(mem, scanned, reclaimed);
+	__mem_cgroup_update_scan_ratio(mem, scanned, reclaimed, elapsed, type);
 	if (mem != root)
-		__mem_cgroup_update_scan_ratio(root, scanned, reclaimed);
+		__mem_cgroup_update_scan_ratio(root, scanned, reclaimed,
+					elapsed, type);
 
 }
 
@@ -1906,6 +1930,7 @@ static int mem_cgroup_hierarchical_recla
 	bool is_kswapd = false;
 	unsigned long excess;
 	unsigned long nr_scanned;
+	unsigned long start, end, elapsed;
 
 	excess = res_counter_soft_limit_excess(&root_mem->res) >> PAGE_SHIFT;
 
@@ -1947,18 +1972,24 @@ static int mem_cgroup_hierarchical_recla
 		}
 		/* we use swappiness of local cgroup */
 		if (check_soft) {
+			start = sched_clock();
 			ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
 				noswap, zone, &nr_scanned);
+			end = sched_clock();
+			elapsed = end - start;
 			*total_scanned += nr_scanned;
 			mem_cgroup_soft_steal(victim, is_kswapd, ret);
 			mem_cgroup_soft_scan(victim, is_kswapd, nr_scanned);
 			mem_cgroup_update_scan_ratio(victim,
-					root_mem, nr_scanned, ret);
+				root_mem, nr_scanned, ret, elapsed, SOFT_SCAN);
 		} else {
+			start = sched_clock();
 			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
 					noswap, &nr_scanned);
+			end = sched_clock();
+			elapsed = end - start;
 			mem_cgroup_update_scan_ratio(victim,
-					root_mem, nr_scanned, ret);
+				root_mem, nr_scanned, ret, elapsed, LIMIT_SCAN);
 		}
 		css_put(&victim->css);
 		/*
@@ -4003,7 +4034,7 @@ static void mem_cgroup_async_shrink_work
 	struct delayed_work *dw = to_delayed_work(work);
 	struct mem_cgroup *mem, *victim;
 	long nr_to_reclaim;
-	unsigned long nr_scanned, nr_reclaimed;
+	unsigned long nr_scanned, nr_reclaimed, start, end;
 	int delay = 0;
 
 	mem = container_of(dw, struct mem_cgroup, async_work);
@@ -4022,9 +4053,12 @@ static void mem_cgroup_async_shrink_work
 	if (!victim)
 		goto finish_scan;
 
+	start = sched_clock();
 	nr_reclaimed = mem_cgroup_shrink_rate_limited(victim, nr_to_reclaim,
 					&nr_scanned);
-	mem_cgroup_update_scan_ratio(victim, mem, nr_scanned, nr_reclaimed);
+	end = sched_clock();
+	mem_cgroup_update_scan_ratio(victim, mem, nr_scanned, nr_reclaimed,
+			end - start, MARGIN_SCAN);
 	css_put(&victim->css);
 
 	/* If margin is enough big, stop */
@@ -4680,6 +4714,38 @@ static int mem_control_stat_show(struct 
 	return 0;
 }
 
+static int mem_cgroup_reclaim_stat_read(struct cgroup *cont, struct cftype *cft,
+				 struct cgroup_map_cb *cb)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+	u64 val;
+	int i; /* for indexing scan_stat[] */
+
+	val = mem->reclaimed * 100 / mem->scanned;
+	cb->fill(cb, "recent_scan_success_ratio", val);
+	i  = LIMIT_SCAN;
+	cb->fill(cb, "limit_scan_pages", mem->scan_stat[i].nr_scanned_pages);
+	cb->fill(cb, "limit_freed_pages", mem->scan_stat[i].nr_reclaimed_pages);
+	cb->fill(cb, "limit_elapsed_ns", mem->scan_stat[i].elapsed_ns);
+	i = SOFT_SCAN;
+	cb->fill(cb, "soft_scan_pages", mem->scan_stat[i].nr_scanned_pages);
+	cb->fill(cb, "soft_freed_pages", mem->scan_stat[i].nr_reclaimed_pages);
+	cb->fill(cb, "soft_elapsed_ns", mem->scan_stat[i].elapsed_ns);
+	i = MARGIN_SCAN;
+	cb->fill(cb, "margin_scan_pages", mem->scan_stat[i].nr_scanned_pages);
+	cb->fill(cb, "margin_freed_pages", mem->scan_stat[i].nr_reclaimed_pages);
+	cb->fill(cb, "margin_elapsed_ns", mem->scan_stat[i].elapsed_ns);
+	return 0;
+}
+
+static int mem_cgroup_reclaim_stat_reset(struct cgroup *cgrp, unsigned int event)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+	memset(mem->scan_stat, 0, sizeof(mem->scan_stat));
+	return 0;
+}
+
+
 /*
  * User flags for async_control is a subset of mem->async_flags. But
  * this needs to be defined independently to hide implemation details.
@@ -5163,6 +5229,11 @@ static struct cftype mem_cgroup_files[] 
 		.open = mem_control_numa_stat_open,
 	},
 #endif
+	{
+		.name = "reclaim_stat",
+		.read_map = mem_cgroup_reclaim_stat_read,
+		.trigger = mem_cgroup_reclaim_stat_reset,
+	}
 };
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
