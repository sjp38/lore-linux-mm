Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBB3E613027271
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 11 Dec 2008 12:14:06 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id ECE7D45DE54
	for <linux-mm@kvack.org>; Thu, 11 Dec 2008 12:14:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BC01845DE52
	for <linux-mm@kvack.org>; Thu, 11 Dec 2008 12:14:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8184D1DB803F
	for <linux-mm@kvack.org>; Thu, 11 Dec 2008 12:14:05 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 22DCA1DB8041
	for <linux-mm@kvack.org>; Thu, 11 Dec 2008 12:14:05 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 5/6] fix inactive_ratio under hierarchy
In-Reply-To: <20081209201023.65bb98e6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081209200213.0e2128c1.kamezawa.hiroyu@jp.fujitsu.com> <20081209201023.65bb98e6.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20081211121006.4FF1.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 11 Dec 2008 12:14:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi

> ex)In following tree,
> 	/opt/cgroup/01		limit=1G
> 	/opt/cgroup/01/A	limit=500M
> 	/opt/cgroup/01/A/B	limit=unlimited
> 	/opt/cgroup/01/A/C	limit=50M
> 	/opt/cgroup/01/Z	limit=700M
> 
> 
> 	/opt/cgroup/01's inactive_ratio is calculated by limit of 1G.
> 	/opt/cgroup/01/A's inactive_ratio is calculated by limit of 500M 
> 	/opt/cgroup/01/A/B's inactive_ratio is calculated by limit of 500M.
> 	/opt/cgroup/01/A/C's inactive_ratio is calculated by limit of 50M.
> 	/opt/cgroup/01's inactive_ratio is calculated by limit of 700M.

this is one of good choice.
but I think it is a bit complex rule.


How about this?

===============
Currently, inactive_ratio of memcg is calculated at setting limit.
because page_alloc.c does so and current implementation is straightforward porting.

However, memcg introduced hierarchy feature recently.
In hierarchy restriction, memory limit is not only decided memory.limit_in_bytes of current cgroup,
but also parent limit and sibling memory usage.

Then, The optimal inactive_ratio is changed frequently.
So, everytime calculation is better.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Balbir Singh <balbir@linux.vnet.ibm.com>
---
 include/linux/memcontrol.h |    3 --
 mm/memcontrol.c            |   64 +++++++++++++++++++++------------------------
 mm/vmscan.c                |    2 -
 3 files changed, 33 insertions(+), 36 deletions(-)

Index: b/include/linux/memcontrol.h
===================================================================
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -95,8 +95,7 @@ extern void mem_cgroup_note_reclaim_prio
 							int priority);
 extern void mem_cgroup_record_reclaim_priority(struct mem_cgroup *mem,
 							int priority);
-int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg,
-				    struct zone *zone);
+int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
 unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
 				       struct zone *zone,
 				       enum lru_list lru);
Index: b/mm/memcontrol.c
===================================================================
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -167,9 +167,6 @@ struct mem_cgroup {
 
 	unsigned int	swappiness;
 
-
-	unsigned int inactive_ratio;
-
 	/*
 	 * statistics. This must be placed at the end of memcg.
 	 */
@@ -433,15 +430,43 @@ void mem_cgroup_record_reclaim_priority(
 	spin_unlock(&mem->reclaim_param_lock);
 }
 
-int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg, struct zone *zone)
+static int calc_inactive_ratio(struct mem_cgroup *memcg, unsigned long *present_pages)
 {
 	unsigned long active;
 	unsigned long inactive;
+	unsigned long gb;
+	unsigned long inactive_ratio;
 
 	inactive = mem_cgroup_get_all_zonestat(memcg, LRU_INACTIVE_ANON);
 	active = mem_cgroup_get_all_zonestat(memcg, LRU_ACTIVE_ANON);
 
-	if (inactive * memcg->inactive_ratio < active)
+	gb = (inactive + active) >> (30 - PAGE_SHIFT);
+	if (gb)
+		inactive_ratio = int_sqrt(10 * gb);
+	else
+		inactive_ratio = 1;
+
+	if (present_pages) {
+		present_pages[0] = inactive;
+		present_pages[1] = active;
+	}
+
+	return inactive_ratio;
+}
+
+int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg)
+{
+	unsigned long active;
+	unsigned long inactive;
+	unsigned long present_pages[2];
+	unsigned long inactive_ratio;
+
+	inactive_ratio = calc_inactive_ratio(memcg, present_pages);
+
+	inactive = present_pages[0];
+	active = present_pages[1];
+
+	if (inactive * inactive_ratio < active)
 		return 1;
 
 	return 0;
@@ -1410,29 +1435,6 @@ int mem_cgroup_shrink_usage(struct mm_st
 	return 0;
 }
 
-/*
- * The inactive anon list should be small enough that the VM never has to
- * do too much work, but large enough that each inactive page has a chance
- * to be referenced again before it is swapped out.
- *
- * this calculation is straightforward porting from
- * page_alloc.c::setup_per_zone_inactive_ratio().
- * it describe more detail.
- */
-static void mem_cgroup_set_inactive_ratio(struct mem_cgroup *memcg)
-{
-	unsigned int gb, ratio;
-
-	gb = res_counter_read_u64(&memcg->res, RES_LIMIT) >> 30;
-	if (gb)
-		ratio = int_sqrt(10 * gb);
-	else
-		ratio = 1;
-
-	memcg->inactive_ratio = ratio;
-
-}
-
 static DEFINE_MUTEX(set_limit_mutex);
 
 static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
@@ -1472,9 +1474,6 @@ static int mem_cgroup_resize_limit(struc
   		if (!progress)			retry_count--;
 	}
 
-	if (!ret)
-		mem_cgroup_set_inactive_ratio(memcg);
-
 	return ret;
 }
 
@@ -1833,7 +1832,7 @@ static int mem_control_stat_show(struct 
 	}
 
 #ifdef CONFIG_DEBUG_VM
-	cb->fill(cb, "inactive_ratio", mem_cont->inactive_ratio);
+	cb->fill(cb, "inactive_ratio", calc_inactive_ratio(mem_cont, NULL));
 
 	{
 		int nid, zid;
@@ -2125,7 +2124,6 @@ mem_cgroup_create(struct cgroup_subsys *
 		res_counter_init(&mem->res, NULL);
 		res_counter_init(&mem->memsw, NULL);
 	}
-	mem_cgroup_set_inactive_ratio(mem);
 	mem->last_scanned_child = NULL;
 	spin_lock_init(&mem->reclaim_param_lock);
 
Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1394,7 +1394,7 @@ static int inactive_anon_is_low(struct z
 	if (scanning_global_lru(sc))
 		low = inactive_anon_is_low_global(zone);
 	else
-		low = mem_cgroup_inactive_anon_is_low(sc->mem_cgroup, zone);
+		low = mem_cgroup_inactive_anon_is_low(sc->mem_cgroup);
 	return low;
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
