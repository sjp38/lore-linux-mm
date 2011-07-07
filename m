Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 6D6DC9000C2
	for <linux-mm@kvack.org>; Thu,  7 Jul 2011 03:00:06 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 9EF2E3EE0C2
	for <linux-mm@kvack.org>; Thu,  7 Jul 2011 16:00:02 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 711FB45DEA7
	for <linux-mm@kvack.org>; Thu,  7 Jul 2011 16:00:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4209145DEA0
	for <linux-mm@kvack.org>; Thu,  7 Jul 2011 16:00:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 30A881DB8043
	for <linux-mm@kvack.org>; Thu,  7 Jul 2011 16:00:02 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CA6201DB8041
	for <linux-mm@kvack.org>; Thu,  7 Jul 2011 16:00:01 +0900 (JST)
Date: Thu, 7 Jul 2011 15:52:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH][Cleanup] memcg: consolidates memory cgroup lru stat
 functions
Message-Id: <20110707155217.909c429a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>

In mm/memcontrol.c, there are many lru stat functions as..

mem_cgroup_zone_nr_lru_pages
mem_cgroup_node_nr_file_lru_pages
mem_cgroup_nr_file_lru_pages
mem_cgroup_node_nr_anon_lru_pages
mem_cgroup_nr_anon_lru_pages
mem_cgroup_node_nr_unevictable_lru_pages
mem_cgroup_nr_unevictable_lru_pages
mem_cgroup_node_nr_lru_pages
mem_cgroup_nr_lru_pages
mem_cgroup_get_local_zonestat

Some of them are under #ifdef MAX_NUMNODES >1 and others are not.
This seems bad. This patch consolidates all functions into

mem_cgroup_zone_nr_lru_pages()
mem_cgroup_node_nr_lru_pages()
mem_cgroup_nr_lru_pages()

For these functions, "which LRU?" information is passed by a mask.

example)
mem_cgroup_nr_lru_pages(mem, BIT(LRU_ACTIVE_ANON))

And I added some macro as ALL_LRU, ALL_LRU_FILE, ALL_LRU_ANON.
example)
mem_cgroup_nr_lru_pages(mem, ALL_LRU)

BTW, considering layout of NUMA memory placement of counters, this patch seems
to be better. 

Now, when we gather all LRU information, we scan in following orer
    for_each_lru -> for_each_node -> for_each_zone.

This means we'll touch cache lines in different node in turn.

After patch, we'll scan 
    for_each_node -> for_each_zone -> for_each_lru(mask)

Then, we'll gather information in the same cacheline at once.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    3 
 include/linux/mmzone.h     |    6 +
 mm/memcontrol.c            |  176 ++++++++++++---------------------------------
 mm/vmscan.c                |    3 
 4 files changed, 58 insertions(+), 130 deletions(-)

Index: mmotm-0701/include/linux/memcontrol.h
===================================================================
--- mmotm-0701.orig/include/linux/memcontrol.h
+++ mmotm-0701/include/linux/memcontrol.h
@@ -109,8 +109,7 @@ int mem_cgroup_inactive_anon_is_low(stru
 int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
 int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
 unsigned long mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg,
-						struct zone *zone,
-						enum lru_list lru);
+					int nid, int zid, unsigned int lrumask);
 struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
 						      struct zone *zone);
 struct zone_reclaim_stat*
Index: mmotm-0701/mm/memcontrol.c
===================================================================
--- mmotm-0701.orig/mm/memcontrol.c
+++ mmotm-0701/mm/memcontrol.c
@@ -635,27 +635,44 @@ static void mem_cgroup_charge_statistics
 	preempt_enable();
 }
 
-static unsigned long
-mem_cgroup_get_zonestat_node(struct mem_cgroup *mem, int nid, enum lru_list idx)
+unsigned long
+mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *mem, int nid, int zid,
+			unsigned int lru_mask)
 {
 	struct mem_cgroup_per_zone *mz;
+	enum lru_list l;
+	unsigned long ret = 0;
+
+	mz = mem_cgroup_zoneinfo(mem, nid, zid);
+
+	for_each_lru(l) {
+		if (BIT(l) & lru_mask)
+			ret += MEM_CGROUP_ZSTAT(mz, l);
+	}
+	return ret;
+}
+
+static unsigned long
+mem_cgroup_node_nr_lru_pages(struct mem_cgroup *mem,
+			int nid, unsigned int lru_mask)
+{
 	u64 total = 0;
 	int zid;
 
-	for (zid = 0; zid < MAX_NR_ZONES; zid++) {
-		mz = mem_cgroup_zoneinfo(mem, nid, zid);
-		total += MEM_CGROUP_ZSTAT(mz, idx);
-	}
+	for (zid = 0; zid < MAX_NR_ZONES; zid++)
+		total += mem_cgroup_zone_nr_lru_pages(mem, nid, zid, lru_mask);
+
 	return total;
 }
-static unsigned long mem_cgroup_get_local_zonestat(struct mem_cgroup *mem,
-					enum lru_list idx)
+
+static unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *mem,
+			unsigned int lru_mask)
 {
 	int nid;
 	u64 total = 0;
 
-	for_each_online_node(nid)
-		total += mem_cgroup_get_zonestat_node(mem, nid, idx);
+	for_each_node_state(nid, N_HIGH_MEMORY)
+		total += mem_cgroup_node_nr_lru_pages(mem, nid, lru_mask);
 	return total;
 }
 
@@ -1076,8 +1093,8 @@ static int calc_inactive_ratio(struct me
 	unsigned long gb;
 	unsigned long inactive_ratio;
 
-	inactive = mem_cgroup_get_local_zonestat(memcg, LRU_INACTIVE_ANON);
-	active = mem_cgroup_get_local_zonestat(memcg, LRU_ACTIVE_ANON);
+	inactive = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_INACTIVE_ANON));
+	active = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_ACTIVE_ANON));
 
 	gb = (inactive + active) >> (30 - PAGE_SHIFT);
 	if (gb)
@@ -1116,109 +1133,12 @@ int mem_cgroup_inactive_file_is_low(stru
 	unsigned long active;
 	unsigned long inactive;
 
-	inactive = mem_cgroup_get_local_zonestat(memcg, LRU_INACTIVE_FILE);
-	active = mem_cgroup_get_local_zonestat(memcg, LRU_ACTIVE_FILE);
+	inactive = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_INACTIVE_FILE));
+	active = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_ACTIVE_FILE));
 
 	return (active > inactive);
 }
 
-unsigned long mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg,
-						struct zone *zone,
-						enum lru_list lru)
-{
-	int nid = zone_to_nid(zone);
-	int zid = zone_idx(zone);
-	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid, zid);
-
-	return MEM_CGROUP_ZSTAT(mz, lru);
-}
-
-static unsigned long mem_cgroup_node_nr_file_lru_pages(struct mem_cgroup *memcg,
-							int nid)
-{
-	unsigned long ret;
-
-	ret = mem_cgroup_get_zonestat_node(memcg, nid, LRU_INACTIVE_FILE) +
-		mem_cgroup_get_zonestat_node(memcg, nid, LRU_ACTIVE_FILE);
-
-	return ret;
-}
-
-static unsigned long mem_cgroup_node_nr_anon_lru_pages(struct mem_cgroup *memcg,
-							int nid)
-{
-	unsigned long ret;
-
-	ret = mem_cgroup_get_zonestat_node(memcg, nid, LRU_INACTIVE_ANON) +
-		mem_cgroup_get_zonestat_node(memcg, nid, LRU_ACTIVE_ANON);
-	return ret;
-}
-
-#if MAX_NUMNODES > 1
-static unsigned long mem_cgroup_nr_file_lru_pages(struct mem_cgroup *memcg)
-{
-	u64 total = 0;
-	int nid;
-
-	for_each_node_state(nid, N_HIGH_MEMORY)
-		total += mem_cgroup_node_nr_file_lru_pages(memcg, nid);
-
-	return total;
-}
-
-static unsigned long mem_cgroup_nr_anon_lru_pages(struct mem_cgroup *memcg)
-{
-	u64 total = 0;
-	int nid;
-
-	for_each_node_state(nid, N_HIGH_MEMORY)
-		total += mem_cgroup_node_nr_anon_lru_pages(memcg, nid);
-
-	return total;
-}
-
-static unsigned long
-mem_cgroup_node_nr_unevictable_lru_pages(struct mem_cgroup *memcg, int nid)
-{
-	return mem_cgroup_get_zonestat_node(memcg, nid, LRU_UNEVICTABLE);
-}
-
-static unsigned long
-mem_cgroup_nr_unevictable_lru_pages(struct mem_cgroup *memcg)
-{
-	u64 total = 0;
-	int nid;
-
-	for_each_node_state(nid, N_HIGH_MEMORY)
-		total += mem_cgroup_node_nr_unevictable_lru_pages(memcg, nid);
-
-	return total;
-}
-
-static unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
-							int nid)
-{
-	enum lru_list l;
-	u64 total = 0;
-
-	for_each_lru(l)
-		total += mem_cgroup_get_zonestat_node(memcg, nid, l);
-
-	return total;
-}
-
-static unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg)
-{
-	u64 total = 0;
-	int nid;
-
-	for_each_node_state(nid, N_HIGH_MEMORY)
-		total += mem_cgroup_node_nr_lru_pages(memcg, nid);
-
-	return total;
-}
-#endif /* CONFIG_NUMA */
-
 struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
 						      struct zone *zone)
 {
@@ -1575,11 +1495,11 @@ mem_cgroup_select_victim(struct mem_cgro
 static bool test_mem_cgroup_node_reclaimable(struct mem_cgroup *mem,
 		int nid, bool noswap)
 {
-	if (mem_cgroup_node_nr_file_lru_pages(mem, nid))
+	if (mem_cgroup_node_nr_lru_pages(mem, nid, LRU_ALL_FILE))
 		return true;
 	if (noswap || !total_swap_pages)
 		return false;
-	if (mem_cgroup_node_nr_anon_lru_pages(mem, nid))
+	if (mem_cgroup_node_nr_lru_pages(mem, nid, LRU_ALL_ANON))
 		return true;
 	return false;
 
@@ -4101,15 +4021,15 @@ mem_cgroup_get_local_stat(struct mem_cgr
 	s->stat[MCS_PGMAJFAULT] += val;
 
 	/* per zone stat */
-	val = mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_ANON);
+	val = mem_cgroup_nr_lru_pages(mem, BIT(LRU_INACTIVE_ANON));
 	s->stat[MCS_INACTIVE_ANON] += val * PAGE_SIZE;
-	val = mem_cgroup_get_local_zonestat(mem, LRU_ACTIVE_ANON);
+	val = mem_cgroup_nr_lru_pages(mem, BIT(LRU_ACTIVE_ANON));
 	s->stat[MCS_ACTIVE_ANON] += val * PAGE_SIZE;
-	val = mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_FILE);
+	val = mem_cgroup_nr_lru_pages(mem, BIT(LRU_INACTIVE_FILE));
 	s->stat[MCS_INACTIVE_FILE] += val * PAGE_SIZE;
-	val = mem_cgroup_get_local_zonestat(mem, LRU_ACTIVE_FILE);
+	val = mem_cgroup_nr_lru_pages(mem, BIT(LRU_ACTIVE_FILE));
 	s->stat[MCS_ACTIVE_FILE] += val * PAGE_SIZE;
-	val = mem_cgroup_get_local_zonestat(mem, LRU_UNEVICTABLE);
+	val = mem_cgroup_nr_lru_pages(mem, BIT(LRU_UNEVICTABLE));
 	s->stat[MCS_UNEVICTABLE] += val * PAGE_SIZE;
 }
 
@@ -4131,35 +4051,37 @@ static int mem_control_numa_stat_show(st
 	struct cgroup *cont = m->private;
 	struct mem_cgroup *mem_cont = mem_cgroup_from_cont(cont);
 
-	total_nr = mem_cgroup_nr_lru_pages(mem_cont);
+	total_nr = mem_cgroup_nr_lru_pages(mem_cont, LRU_ALL);
 	seq_printf(m, "total=%lu", total_nr);
 	for_each_node_state(nid, N_HIGH_MEMORY) {
-		node_nr = mem_cgroup_node_nr_lru_pages(mem_cont, nid);
+		node_nr = mem_cgroup_node_nr_lru_pages(mem_cont, nid, LRU_ALL);
 		seq_printf(m, " N%d=%lu", nid, node_nr);
 	}
 	seq_putc(m, '\n');
 
-	file_nr = mem_cgroup_nr_file_lru_pages(mem_cont);
+	file_nr = mem_cgroup_nr_lru_pages(mem_cont, LRU_ALL_FILE);
 	seq_printf(m, "file=%lu", file_nr);
 	for_each_node_state(nid, N_HIGH_MEMORY) {
-		node_nr = mem_cgroup_node_nr_file_lru_pages(mem_cont, nid);
+		node_nr = mem_cgroup_node_nr_lru_pages(mem_cont, nid,
+				LRU_ALL_FILE);
 		seq_printf(m, " N%d=%lu", nid, node_nr);
 	}
 	seq_putc(m, '\n');
 
-	anon_nr = mem_cgroup_nr_anon_lru_pages(mem_cont);
+	anon_nr = mem_cgroup_nr_lru_pages(mem_cont, LRU_ALL_ANON);
 	seq_printf(m, "anon=%lu", anon_nr);
 	for_each_node_state(nid, N_HIGH_MEMORY) {
-		node_nr = mem_cgroup_node_nr_anon_lru_pages(mem_cont, nid);
+		node_nr = mem_cgroup_node_nr_lru_pages(mem_cont, nid,
+				LRU_ALL_ANON);
 		seq_printf(m, " N%d=%lu", nid, node_nr);
 	}
 	seq_putc(m, '\n');
 
-	unevictable_nr = mem_cgroup_nr_unevictable_lru_pages(mem_cont);
+	unevictable_nr = mem_cgroup_nr_lru_pages(mem_cont, BIT(LRU_UNEVICTABLE));
 	seq_printf(m, "unevictable=%lu", unevictable_nr);
 	for_each_node_state(nid, N_HIGH_MEMORY) {
-		node_nr = mem_cgroup_node_nr_unevictable_lru_pages(mem_cont,
-									nid);
+		node_nr = mem_cgroup_node_nr_lru_pages(mem_cont, nid,
+				BIT(LRU_UNEVICTABLE));
 		seq_printf(m, " N%d=%lu", nid, node_nr);
 	}
 	seq_putc(m, '\n');
Index: mmotm-0701/mm/vmscan.c
===================================================================
--- mmotm-0701.orig/mm/vmscan.c
+++ mmotm-0701/mm/vmscan.c
@@ -171,7 +171,8 @@ static unsigned long zone_nr_lru_pages(s
 				struct scan_control *sc, enum lru_list lru)
 {
 	if (!scanning_global_lru(sc))
-		return mem_cgroup_zone_nr_lru_pages(sc->mem_cgroup, zone, lru);
+		return mem_cgroup_zone_nr_lru_pages(sc->mem_cgroup,
+				zone_to_nid(zone), zone_idx(zone), BIT(lru));
 
 	return zone_page_state(zone, NR_LRU_BASE + lru);
 }
Index: mmotm-0701/include/linux/mmzone.h
===================================================================
--- mmotm-0701.orig/include/linux/mmzone.h
+++ mmotm-0701/include/linux/mmzone.h
@@ -158,6 +158,12 @@ static inline int is_unevictable_lru(enu
 	return (l == LRU_UNEVICTABLE);
 }
 
+/* Mask used at gathering information at once (see memcontrol.c) */
+#define LRU_ALL_FILE (BIT(LRU_INACTIVE_FILE) | BIT(LRU_ACTIVE_FILE))
+#define LRU_ALL_ANON (BIT(LRU_INACTIVE_ANON) | BIT(LRU_ACTIVE_ANON))
+#define LRU_ALL_EVICTABLE (LRU_ALL_FILE | LRU_ALL_ANON)
+#define LRU_ALL	     ((1 << NR_LRU_LISTS) - 1)
+
 enum zone_watermarks {
 	WMARK_MIN,
 	WMARK_LOW,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
