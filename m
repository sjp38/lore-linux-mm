Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 852F76B004D
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 04:16:12 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n338GPIu004501
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 3 Apr 2009 17:16:25 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 126EB45DD83
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:16:25 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FEB945DD79
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:16:24 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 32E92E18008
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:16:24 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B030C1DB8019
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:16:23 +0900 (JST)
Date: Fri, 3 Apr 2009 17:14:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 6/9] active inactive ratio for private
Message-Id: <20090403171457.4a7ab4e1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090403170835.a2d6cbc3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090403170835.a2d6cbc3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Current memcg's active/inactive ratio calclation ignores zone.
(It's designed for reducing usage of memcg and not for recovering
 from  memory shortage.)

But softlimit should take care of zone, later.

Changelog v1->v2:
 - fixed buggy argument in mem_cgroup_inactive_anon_is_low

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    4 ++--
 mm/memcontrol.c            |   26 ++++++++++++++++++++------
 mm/vmscan.c                |    2 +-
 3 files changed, 23 insertions(+), 9 deletions(-)

Index: softlimit-test2/mm/memcontrol.c
===================================================================
--- softlimit-test2.orig/mm/memcontrol.c
+++ softlimit-test2/mm/memcontrol.c
@@ -564,15 +564,28 @@ void mem_cgroup_record_reclaim_priority(
 	spin_unlock(&mem->reclaim_param_lock);
 }
 
-static int calc_inactive_ratio(struct mem_cgroup *memcg, unsigned long *present_pages)
+static int calc_inactive_ratio(struct mem_cgroup *memcg,
+			       unsigned long *present_pages,
+			       struct zone *z)
 {
 	unsigned long active;
 	unsigned long inactive;
 	unsigned long gb;
 	unsigned long inactive_ratio;
 
-	inactive = mem_cgroup_get_local_zonestat(memcg, LRU_INACTIVE_ANON);
-	active = mem_cgroup_get_local_zonestat(memcg, LRU_ACTIVE_ANON);
+	if (!z) {
+		inactive = mem_cgroup_get_local_zonestat(memcg,
+							 LRU_INACTIVE_ANON);
+		active = mem_cgroup_get_local_zonestat(memcg, LRU_ACTIVE_ANON);
+	} else {
+		int nid = z->zone_pgdat->node_id;
+		int zid = zone_idx(z);
+		struct mem_cgroup_per_zone *mz;
+
+		mz = mem_cgroup_zoneinfo(memcg, nid, zid);
+		inactive = MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_ANON);
+		active = MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_ANON);
+	}
 
 	gb = (inactive + active) >> (30 - PAGE_SHIFT);
 	if (gb)
@@ -588,14 +601,14 @@ static int calc_inactive_ratio(struct me
 	return inactive_ratio;
 }
 
-int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg)
+int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg, struct zone *z)
 {
 	unsigned long active;
 	unsigned long inactive;
 	unsigned long present_pages[2];
 	unsigned long inactive_ratio;
 
-	inactive_ratio = calc_inactive_ratio(memcg, present_pages);
+	inactive_ratio = calc_inactive_ratio(memcg, present_pages, z);
 
 	inactive = present_pages[0];
 	active = present_pages[1];
@@ -2366,7 +2379,8 @@ static int mem_control_stat_show(struct 
 
 
 #ifdef CONFIG_DEBUG_VM
-	cb->fill(cb, "inactive_ratio", calc_inactive_ratio(mem_cont, NULL));
+	cb->fill(cb, "inactive_ratio",
+			calc_inactive_ratio(mem_cont, NULL, NULL));
 
 	{
 		int nid, zid;
Index: softlimit-test2/include/linux/memcontrol.h
===================================================================
--- softlimit-test2.orig/include/linux/memcontrol.h
+++ softlimit-test2/include/linux/memcontrol.h
@@ -93,7 +93,7 @@ extern void mem_cgroup_note_reclaim_prio
 							int priority);
 extern void mem_cgroup_record_reclaim_priority(struct mem_cgroup *mem,
 							int priority);
-int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
+int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg, struct zone *z);
 unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
 				       struct zone *zone,
 				       enum lru_list lru);
@@ -234,7 +234,7 @@ static inline bool mem_cgroup_oom_called
 }
 
 static inline int
-mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg)
+mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg, struct zone *z)
 {
 	return 1;
 }
Index: softlimit-test2/mm/vmscan.c
===================================================================
--- softlimit-test2.orig/mm/vmscan.c
+++ softlimit-test2/mm/vmscan.c
@@ -1347,7 +1347,7 @@ static int inactive_anon_is_low(struct z
 	if (scanning_global_lru(sc))
 		low = inactive_anon_is_low_global(zone);
 	else
-		low = mem_cgroup_inactive_anon_is_low(sc->mem_cgroup);
+		low = mem_cgroup_inactive_anon_is_low(sc->mem_cgroup, NULL);
 	return low;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
