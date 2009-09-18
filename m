Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D7D736B00C2
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 05:03:56 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8I93ui9001679
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 18 Sep 2009 18:03:56 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D7AA945DE5D
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 18:03:55 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C74745DE4F
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 18:03:55 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 512EC1DB803B
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 18:03:55 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7FBDA8F8009
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 18:03:54 +0900 (JST)
Date: Fri, 18 Sep 2009 18:01:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 9/11]memcg: clean up zonestat funcs
Message-Id: <20090918180151.e988381a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090918174757.672f1e8e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090909173903.afc86d85.kamezawa.hiroyu@jp.fujitsu.com>
	<20090918174757.672f1e8e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch does
  - rename mem_cgroup_get_local_zonestat() to be mem_cgroup_get_lru_stat().
    I named the function as "local" but this "local" was ambiguous.
    This local means "not considering hierarchy"...
    Maybe get_lru_stat() is better name.

  - moves zone statitics related functions after xxx_cgroup_zoneinfo function.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   68 ++++++++++++++++++++++++++++----------------------------
 1 file changed, 35 insertions(+), 33 deletions(-)

Index: mmotm-2.6.31-Sep17/mm/memcontrol.c
===================================================================
--- mmotm-2.6.31-Sep17.orig/mm/memcontrol.c
+++ mmotm-2.6.31-Sep17/mm/memcontrol.c
@@ -434,6 +434,32 @@ page_cgroup_zoneinfo(struct page_cgroup 
 	return mem_cgroup_zoneinfo(mem, nid, zid);
 }
 
+unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
+				       struct zone *zone,
+				       enum lru_list lru)
+{
+	int nid = zone->zone_pgdat->node_id;
+	int zid = zone_idx(zone);
+	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid, zid);
+
+	return MEM_CGROUP_ZSTAT(mz, lru);
+}
+
+static unsigned long mem_cgroup_get_lru_stat(struct mem_cgroup *mem,
+					enum lru_list idx)
+{
+	int nid, zid;
+	struct mem_cgroup_per_zone *mz;
+	u64 total = 0;
+
+	for_each_online_node(nid)
+		for (zid = 0; zid < MAX_NR_ZONES; zid++) {
+			mz = mem_cgroup_zoneinfo(mem, nid, zid);
+			total += MEM_CGROUP_ZSTAT(mz, idx);
+		}
+	return total;
+}
+
 static struct mem_cgroup_tree_per_zone *
 soft_limit_tree_node_zone(int nid, int zid)
 {
@@ -640,20 +666,6 @@ static void mem_cgroup_charge_statistics
 	put_cpu();
 }
 
-static unsigned long mem_cgroup_get_local_zonestat(struct mem_cgroup *mem,
-					enum lru_list idx)
-{
-	int nid, zid;
-	struct mem_cgroup_per_zone *mz;
-	u64 total = 0;
-
-	for_each_online_node(nid)
-		for (zid = 0; zid < MAX_NR_ZONES; zid++) {
-			mz = mem_cgroup_zoneinfo(mem, nid, zid);
-			total += MEM_CGROUP_ZSTAT(mz, idx);
-		}
-	return total;
-}
 
 /*
  * Call callback function against all cgroup under hierarchy tree.
@@ -882,8 +894,8 @@ static int calc_inactive_ratio(struct me
 	unsigned long gb;
 	unsigned long inactive_ratio;
 
-	inactive = mem_cgroup_get_local_zonestat(memcg, LRU_INACTIVE_ANON);
-	active = mem_cgroup_get_local_zonestat(memcg, LRU_ACTIVE_ANON);
+	inactive = mem_cgroup_get_lru_stat(memcg, LRU_INACTIVE_ANON);
+	active = mem_cgroup_get_lru_stat(memcg, LRU_ACTIVE_ANON);
 
 	gb = (inactive + active) >> (30 - PAGE_SHIFT);
 	if (gb)
@@ -922,22 +934,12 @@ int mem_cgroup_inactive_file_is_low(stru
 	unsigned long active;
 	unsigned long inactive;
 
-	inactive = mem_cgroup_get_local_zonestat(memcg, LRU_INACTIVE_FILE);
-	active = mem_cgroup_get_local_zonestat(memcg, LRU_ACTIVE_FILE);
+	inactive = mem_cgroup_get_lru_stat(memcg, LRU_INACTIVE_FILE);
+	active = mem_cgroup_get_lru_stat(memcg, LRU_ACTIVE_FILE);
 
 	return (active > inactive);
 }
 
-unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
-				       struct zone *zone,
-				       enum lru_list lru)
-{
-	int nid = zone->zone_pgdat->node_id;
-	int zid = zone_idx(zone);
-	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid, zid);
-
-	return MEM_CGROUP_ZSTAT(mz, lru);
-}
 
 struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
 						      struct zone *zone)
@@ -2967,15 +2969,15 @@ static int mem_cgroup_get_local_stat(str
 	}
 
 	/* per zone stat */
-	val = mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_ANON);
+	val = mem_cgroup_get_lru_stat(mem, LRU_INACTIVE_ANON);
 	s->stat[MCS_INACTIVE_ANON] += val * PAGE_SIZE;
-	val = mem_cgroup_get_local_zonestat(mem, LRU_ACTIVE_ANON);
+	val = mem_cgroup_get_lru_stat(mem, LRU_ACTIVE_ANON);
 	s->stat[MCS_ACTIVE_ANON] += val * PAGE_SIZE;
-	val = mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_FILE);
+	val = mem_cgroup_get_lru_stat(mem, LRU_INACTIVE_FILE);
 	s->stat[MCS_INACTIVE_FILE] += val * PAGE_SIZE;
-	val = mem_cgroup_get_local_zonestat(mem, LRU_ACTIVE_FILE);
+	val = mem_cgroup_get_lru_stat(mem, LRU_ACTIVE_FILE);
 	s->stat[MCS_ACTIVE_FILE] += val * PAGE_SIZE;
-	val = mem_cgroup_get_local_zonestat(mem, LRU_UNEVICTABLE);
+	val = mem_cgroup_get_lru_stat(mem, LRU_UNEVICTABLE);
 	s->stat[MCS_UNEVICTABLE] += val * PAGE_SIZE;
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
