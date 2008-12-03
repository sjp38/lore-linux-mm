Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB3516Lx019870
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Dec 2008 14:01:06 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 05FFC45DD80
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 14:01:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D0CD745DD7D
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 14:01:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B3E351DB803E
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 14:01:05 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 624F11DB803A
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 14:01:05 +0900 (JST)
Date: Wed, 3 Dec 2008 14:00:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH  11/21] memcg-make-inactive_anon_is_low.patch
Message-Id: <20081203140016.0c9bc53a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081203134718.6b60986f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081203134718.6b60986f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, gorcunov@gmail.com, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

Changelog:
 v1 -> v2:
   - add detail patch description
   - fix coding style in mem_cgroup_set_inactive_ratio()
   - add comment to mem_cgroup_set_inactive_ratio
   - remove extra newline
   - memcg::inactiveratio change type to unsigned int


The inactive_anon_is_low() is key component of active/inactive anon balancing on reclaim.
However current inactive_anon_is_low() function only consider global reclaim.

Therefore, we need following ugly scan_global_lru() condision.

	if (lru == LRU_ACTIVE_ANON &&
	    (!scan_global_lru(sc) || inactive_anon_is_low(zone))) {
		shrink_active_list(nr_to_scan, zone, sc, priority, file);
		return 0;


it cause that memcg reclaim always deactivate pages when shrink_list() is called.
To make mem_cgroup_inactive_anon_is_low() improve active/inactive anon balancing of memcgroup.


Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Cyrill Gorcunov <gorcunov@gmail.com>
CC: "Pekka Enberg" <penberg@cs.helsinki.fi>
 include/linux/memcontrol.h |    9 ++++++++
 mm/memcontrol.c            |   46 ++++++++++++++++++++++++++++++++++++++++++++-
 mm/vmscan.c                |   36 ++++++++++++++++++++++-------------
 3 files changed, 77 insertions(+), 14 deletions(-)

Index: mmotm-2.6.28-Dec02/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.28-Dec02.orig/include/linux/memcontrol.h
+++ mmotm-2.6.28-Dec02/include/linux/memcontrol.h
@@ -100,6 +100,8 @@ extern void mem_cgroup_record_reclaim_pr
 
 extern long mem_cgroup_calc_reclaim(struct mem_cgroup *mem, struct zone *zone,
 					int priority, enum lru_list lru);
+int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg,
+				    struct zone *zone);
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern int do_swap_account;
@@ -251,6 +253,13 @@ static inline bool mem_cgroup_oom_called
 {
 	return false;
 }
+
+static inline int
+mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg, struct zone *zone)
+{
+	return 1;
+}
+
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */
Index: mmotm-2.6.28-Dec02/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Dec02.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Dec02/mm/memcontrol.c
@@ -156,6 +156,9 @@ struct mem_cgroup {
 	unsigned long	last_oom_jiffies;
 	int		obsolete;
 	atomic_t	refcnt;
+
+	unsigned int inactive_ratio;
+
 	/*
 	 * statistics. This must be placed at the end of memcg.
 	 */
@@ -431,6 +434,20 @@ long mem_cgroup_calc_reclaim(struct mem_
 	return (nr_pages >> priority);
 }
 
+int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg, struct zone *zone)
+{
+	unsigned long active;
+	unsigned long inactive;
+
+	inactive = mem_cgroup_get_all_zonestat(memcg, LRU_INACTIVE_ANON);
+	active = mem_cgroup_get_all_zonestat(memcg, LRU_ACTIVE_ANON);
+
+	if (inactive * memcg->inactive_ratio < active)
+		return 1;
+
+	return 0;
+}
+
 unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct list_head *dst,
 					unsigned long *scanned, int order,
@@ -1360,6 +1377,29 @@ int mem_cgroup_shrink_usage(struct mm_st
 	return 0;
 }
 
+/*
+ * The inactive anon list should be small enough that the VM never has to
+ * do too much work, but large enough that each inactive page has a chance
+ * to be referenced again before it is swapped out.
+ *
+ * this calculation is straightforward porting from
+ * page_alloc.c::setup_per_zone_inactive_ratio().
+ * it describe more detail.
+ */
+static void mem_cgroup_set_inactive_ratio(struct mem_cgroup *memcg)
+{
+	unsigned int gb, ratio;
+
+	gb = res_counter_read_u64(&memcg->res, RES_LIMIT) >> 30;
+	if (gb)
+		ratio = int_sqrt(10 * gb);
+	else
+		ratio = 1;
+
+	memcg->inactive_ratio = ratio;
+
+}
+
 static DEFINE_MUTEX(set_limit_mutex);
 
 static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
@@ -1398,6 +1438,10 @@ static int mem_cgroup_resize_limit(struc
 				GFP_KERNEL, false);
   		if (!progress)			retry_count--;
 	}
+
+	if (!ret)
+		mem_cgroup_set_inactive_ratio(memcg);
+
 	return ret;
 }
 
@@ -1982,7 +2026,7 @@ mem_cgroup_create(struct cgroup_subsys *
 		res_counter_init(&mem->res, NULL);
 		res_counter_init(&mem->memsw, NULL);
 	}
-
+	mem_cgroup_set_inactive_ratio(mem);
 	mem->last_scanned_child = NULL;
 
 	return &mem->css;
Index: mmotm-2.6.28-Dec02/mm/vmscan.c
===================================================================
--- mmotm-2.6.28-Dec02.orig/mm/vmscan.c
+++ mmotm-2.6.28-Dec02/mm/vmscan.c
@@ -1364,14 +1364,7 @@ static void shrink_active_list(unsigned 
 	pagevec_release(&pvec);
 }
 
-/**
- * inactive_anon_is_low - check if anonymous pages need to be deactivated
- * @zone: zone to check
- *
- * Returns true if the zone does not have enough inactive anon pages,
- * meaning some active anon pages need to be deactivated.
- */
-static int inactive_anon_is_low(struct zone *zone)
+static int inactive_anon_is_low_global(struct zone *zone)
 {
 	unsigned long active, inactive;
 
@@ -1384,6 +1377,25 @@ static int inactive_anon_is_low(struct z
 	return 0;
 }
 
+/**
+ * inactive_anon_is_low - check if anonymous pages need to be deactivated
+ * @zone: zone to check
+ * @sc:   scan control of this context
+ *
+ * Returns true if the zone does not have enough inactive anon pages,
+ * meaning some active anon pages need to be deactivated.
+ */
+static int inactive_anon_is_low(struct zone *zone, struct scan_control *sc)
+{
+	int low;
+
+	if (scan_global_lru(sc))
+		low = inactive_anon_is_low_global(zone);
+	else
+		low = mem_cgroup_inactive_anon_is_low(sc->mem_cgroup, zone);
+	return low;
+}
+
 static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 	struct zone *zone, struct scan_control *sc, int priority)
 {
@@ -1395,7 +1407,7 @@ static unsigned long shrink_list(enum lr
 	}
 
 	if (lru == LRU_ACTIVE_ANON &&
-	    (!scan_global_lru(sc) || inactive_anon_is_low(zone))) {
+	    inactive_anon_is_low(zone, sc)) {
 		shrink_active_list(nr_to_scan, zone, sc, priority, file);
 		return 0;
 	}
@@ -1560,9 +1572,7 @@ static void shrink_zone(int priority, st
 	 * Even if we did not try to evict anon pages at all, we want to
 	 * rebalance the anon lru active/inactive ratio.
 	 */
-	if (!scan_global_lru(sc) || inactive_anon_is_low(zone))
-		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
-	else if (!scan_global_lru(sc))
+	if (inactive_anon_is_low(zone, sc))
 		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
 
 	throttle_vm_writeout(sc->gfp_mask);
@@ -1858,7 +1868,7 @@ loop_again:
 			 * Do some background aging of the anon list, to give
 			 * pages a chance to be referenced before reclaiming.
 			 */
-			if (inactive_anon_is_low(zone))
+			if (inactive_anon_is_low(zone, &sc))
 				shrink_active_list(SWAP_CLUSTER_MAX, zone,
 							&sc, priority, 0);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
