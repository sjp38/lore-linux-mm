Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB1CFmH6000401
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 1 Dec 2008 21:15:48 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 400CD45DE4F
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 21:15:48 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C89945DD71
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 21:15:48 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D93BCE18005
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 21:15:47 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E8A61DB8038
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 21:15:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 06/11] memcg: make inactive_anon_is_low()
In-Reply-To: <20081201205810.1CCA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081201205810.1CCA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20081201211457.1CDC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  1 Dec 2008 21:15:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
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



Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Cyrill Gorcunov <gorcunov@gmail.com>
CC: "Pekka Enberg" <penberg@cs.helsinki.fi>
Acked-by: Rik van Riel <riel@redhat.com>
---
 include/linux/memcontrol.h |    9 ++++++++
 mm/memcontrol.c            |   46 ++++++++++++++++++++++++++++++++++++++++++++-
 mm/vmscan.c                |   36 ++++++++++++++++++++++-------------
 3 files changed, 77 insertions(+), 14 deletions(-)

Index: b/include/linux/memcontrol.h
===================================================================
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -90,6 +90,8 @@ extern void mem_cgroup_record_reclaim_pr
 
 extern long mem_cgroup_calc_reclaim(struct mem_cgroup *mem, struct zone *zone,
 					int priority, enum lru_list lru);
+int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg,
+				    struct zone *zone);
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern int do_swap_account;
@@ -241,6 +243,13 @@ static inline bool mem_cgroup_oom_called
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
Index: b/mm/memcontrol.c
===================================================================
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
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
@@ -1346,6 +1363,29 @@ int mem_cgroup_shrink_usage(struct mm_st
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
@@ -1384,6 +1424,10 @@ static int mem_cgroup_resize_limit(struc
 				GFP_HIGHUSER_MOVABLE, false);
   		if (!progress)			retry_count--;
 	}
+
+	if (!ret)
+		mem_cgroup_set_inactive_ratio(memcg);
+
 	return ret;
 }
 
@@ -1968,7 +2012,7 @@ mem_cgroup_create(struct cgroup_subsys *
 		res_counter_init(&mem->res, NULL);
 		res_counter_init(&mem->memsw, NULL);
 	}
-
+	mem_cgroup_set_inactive_ratio(mem);
 	mem->last_scanned_child = NULL;
 
 	return &mem->css;
Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1369,14 +1369,7 @@ static void shrink_active_list(unsigned 
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
 
@@ -1389,6 +1382,25 @@ static int inactive_anon_is_low(struct z
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
@@ -1400,7 +1412,7 @@ static unsigned long shrink_list(enum lr
 	}
 
 	if (lru == LRU_ACTIVE_ANON &&
-	    (!scan_global_lru(sc) || inactive_anon_is_low(zone))) {
+	    inactive_anon_is_low(zone, sc)) {
 		shrink_active_list(nr_to_scan, zone, sc, priority, file);
 		return 0;
 	}
@@ -1565,9 +1577,7 @@ static void shrink_zone(int priority, st
 	 * Even if we did not try to evict anon pages at all, we want to
 	 * rebalance the anon lru active/inactive ratio.
 	 */
-	if (!scan_global_lru(sc) || inactive_anon_is_low(zone))
-		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
-	else if (!scan_global_lru(sc))
+	if (inactive_anon_is_low(zone, sc))
 		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
 
 	throttle_vm_writeout(sc->gfp_mask);
@@ -1863,7 +1873,7 @@ loop_again:
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
