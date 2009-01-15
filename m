Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9EFEC6B006A
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 05:33:52 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0FAXn4l006223
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 15 Jan 2009 19:33:49 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F300645DD81
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 19:33:48 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CF4E445DD78
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 19:33:48 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 953D31DB8043
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 19:33:48 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E6AA31DB8040
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 19:33:47 +0900 (JST)
Date: Thu, 15 Jan 2009 19:32:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 4/4] memcg : read_statistics update to show total score
Message-Id: <20090115193243.0355840b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090115192120.9956911b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090115192120.9956911b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This is an demonstration for scan by CSS ID.
word "hierachical" is better than "total" ?

==
From: KAMEZAWA Hiroyuki <kamzawa.hiroyu@jp.fujitsu.com>

Clean up memory.stat file routine and show "total" hierarchical stat.

This patch does
  - renamed get_all_zonestat to be get_local_zonestat.
  - remove old mem_cgroup_stat_desc, which is only for per-cpu stat.
  - add mcs_stat to cover both of per-cpu/per-lru stat.
  - add "total" stat of hierarchy (*)
  - add a callback system to scan all memcg under a root.

== "total_xxx" is added.
[kamezawa@localhost ~]$ cat /opt/cgroup/xxx/memory.stat 
cache 0
rss 0
pgpgin 0
pgpgout 0
inactive_anon 0
active_anon 0
inactive_file 0
active_file 0
unevictable 0
hierarchical_memory_limit 50331648
hierarchical_memsw_limit 9223372036854775807
total_cache 65536
total_rss 192512
total_pgpgin 218
total_pgpgout 155
total_inactive_anon 0
total_active_anon 135168
total_inactive_file 61440
total_active_file 4096
total_unevictable 0
==
(*) maybe the user can do calc hierarchical stat by his own program
   in userland but if it can be written in clean way, it's worth to be
   shown, I think.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
Index: mmotm-2.6.29-Jan14/mm/memcontrol.c
===================================================================
--- mmotm-2.6.29-Jan14.orig/mm/memcontrol.c
+++ mmotm-2.6.29-Jan14/mm/memcontrol.c
@@ -250,7 +250,7 @@ page_cgroup_zoneinfo(struct page_cgroup 
 	return mem_cgroup_zoneinfo(mem, nid, zid);
 }
 
-static unsigned long mem_cgroup_get_all_zonestat(struct mem_cgroup *mem,
+static unsigned long mem_cgroup_get_local_zonestat(struct mem_cgroup *mem,
 					enum lru_list idx)
 {
 	int nid, zid;
@@ -504,8 +504,8 @@ static int calc_inactive_ratio(struct me
 	unsigned long gb;
 	unsigned long inactive_ratio;
 
-	inactive = mem_cgroup_get_all_zonestat(memcg, LRU_INACTIVE_ANON);
-	active = mem_cgroup_get_all_zonestat(memcg, LRU_ACTIVE_ANON);
+	inactive = mem_cgroup_get_local_zonestat(memcg, LRU_INACTIVE_ANON);
+	active = mem_cgroup_get_local_zonestat(memcg, LRU_ACTIVE_ANON);
 
 	gb = (inactive + active) >> (30 - PAGE_SHIFT);
 	if (gb)
@@ -661,6 +661,41 @@ static unsigned int get_swappiness(struc
 }
 
 /*
+ * Call callback function against all cgroup under hierarchy tree.
+ */
+static int mem_cgroup_walk_tree(struct mem_cgroup *root, void *data,
+			  int (*func)(struct mem_cgroup *, void *))
+{
+	int found, ret, nextid;
+	struct cgroup_subsys_state *css;
+	struct mem_cgroup *mem;
+
+	if (!root->use_hierarchy)
+		return (*func)(root, data);
+
+	nextid = 1;
+	do {
+		ret = 0;
+		mem = NULL;
+
+		rcu_read_lock();
+		css = css_get_next(&mem_cgroup_subsys, nextid, &root->css,
+				   &found);
+		if (css && css_is_populated(css) && css_tryget(css))
+			mem = container_of(css, struct mem_cgroup, css);
+		rcu_read_unlock();
+
+		if (mem) {
+			ret = (*func)(mem, data);
+			css_put(&mem->css);
+		}
+		nextid = found + 1;
+	} while (!ret && css);
+
+	return ret;
+}
+
+/*
  * Visit the first child (need not be the first child as per the ordering
  * of the cgroup list, since we track last_scanned_child) of @mem and use
  * that to reclaim free pages from.
@@ -1843,54 +1878,90 @@ static int mem_cgroup_reset(struct cgrou
 	return 0;
 }
 
-static const struct mem_cgroup_stat_desc {
-	const char *msg;
-	u64 unit;
-} mem_cgroup_stat_desc[] = {
-	[MEM_CGROUP_STAT_CACHE] = { "cache", PAGE_SIZE, },
-	[MEM_CGROUP_STAT_RSS] = { "rss", PAGE_SIZE, },
-	[MEM_CGROUP_STAT_PGPGIN_COUNT] = {"pgpgin", 1, },
-	[MEM_CGROUP_STAT_PGPGOUT_COUNT] = {"pgpgout", 1, },
+
+/* For read statistics */
+enum {
+	MCS_CACHE,
+	MCS_RSS,
+	MCS_PGPGIN,
+	MCS_PGPGOUT,
+	MCS_INACTIVE_ANON,
+	MCS_ACTIVE_ANON,
+	MCS_INACTIVE_FILE,
+	MCS_ACTIVE_FILE,
+	MCS_UNEVICTABLE,
+	NR_MCS_STAT,
+};
+
+struct mcs_total_stat {
+	s64 stat[NR_MCS_STAT];
+};
+
+struct {
+	char *local_name;
+	char *total_name;
+} memcg_stat_strings[NR_MCS_STAT] = {
+	{"cache", "total_cache"},
+	{"rss", "total_rss"},
+	{"pgpgin", "total_pgpgin"},
+	{"pgpgout", "total_pgpgout"},
+	{"inactive_anon", "total_inactive_anon"},
+	{"active_anon", "total_active_anon"},
+	{"inactive_file", "total_inactive_file"},
+	{"active_file", "total_active_file"},
+	{"unevictable", "total_unevictable"}
 };
 
+
+static int mem_cgroup_get_local_stat(struct mem_cgroup *mem, void *data)
+{
+	struct mcs_total_stat *s = data;
+	s64 val;
+
+	/* per cpu stat */
+	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_CACHE);
+	s->stat[MCS_CACHE] += val * PAGE_SIZE;
+	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_RSS);
+	s->stat[MCS_RSS] += val * PAGE_SIZE;
+	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_PGPGIN_COUNT);
+	s->stat[MCS_PGPGIN] += val;
+	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_PGPGOUT_COUNT);
+	s->stat[MCS_PGPGOUT] += val;
+
+	/* per zone stat */
+	val = mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_ANON);
+	s->stat[MCS_INACTIVE_ANON] += val * PAGE_SIZE;
+	val = mem_cgroup_get_local_zonestat(mem, LRU_ACTIVE_ANON);
+	s->stat[MCS_ACTIVE_ANON] += val * PAGE_SIZE;
+	val = mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_FILE);
+	s->stat[MCS_INACTIVE_FILE] += val * PAGE_SIZE;
+	val = mem_cgroup_get_local_zonestat(mem, LRU_ACTIVE_FILE);
+	s->stat[MCS_ACTIVE_FILE] += val * PAGE_SIZE;
+	val = mem_cgroup_get_local_zonestat(mem, LRU_UNEVICTABLE);
+	s->stat[MCS_UNEVICTABLE] += val * PAGE_SIZE;
+	return 0;
+}
+
+static void
+mem_cgroup_get_total_stat(struct mem_cgroup *mem, struct mcs_total_stat *s)
+{
+	mem_cgroup_walk_tree(mem, s, mem_cgroup_get_local_stat);
+}
+
 static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
 				 struct cgroup_map_cb *cb)
 {
 	struct mem_cgroup *mem_cont = mem_cgroup_from_cont(cont);
-	struct mem_cgroup_stat *stat = &mem_cont->stat;
+	struct mcs_total_stat mystat;
 	int i;
 
-	for (i = 0; i < ARRAY_SIZE(stat->cpustat[0].count); i++) {
-		s64 val;
+	memset(&mystat, 0, sizeof(mystat));
+	mem_cgroup_get_local_stat(mem_cont, &mystat);
 
-		val = mem_cgroup_read_stat(stat, i);
-		val *= mem_cgroup_stat_desc[i].unit;
-		cb->fill(cb, mem_cgroup_stat_desc[i].msg, val);
-	}
-	/* showing # of active pages */
-	{
-		unsigned long active_anon, inactive_anon;
-		unsigned long active_file, inactive_file;
-		unsigned long unevictable;
-
-		inactive_anon = mem_cgroup_get_all_zonestat(mem_cont,
-						LRU_INACTIVE_ANON);
-		active_anon = mem_cgroup_get_all_zonestat(mem_cont,
-						LRU_ACTIVE_ANON);
-		inactive_file = mem_cgroup_get_all_zonestat(mem_cont,
-						LRU_INACTIVE_FILE);
-		active_file = mem_cgroup_get_all_zonestat(mem_cont,
-						LRU_ACTIVE_FILE);
-		unevictable = mem_cgroup_get_all_zonestat(mem_cont,
-							LRU_UNEVICTABLE);
-
-		cb->fill(cb, "active_anon", (active_anon) * PAGE_SIZE);
-		cb->fill(cb, "inactive_anon", (inactive_anon) * PAGE_SIZE);
-		cb->fill(cb, "active_file", (active_file) * PAGE_SIZE);
-		cb->fill(cb, "inactive_file", (inactive_file) * PAGE_SIZE);
-		cb->fill(cb, "unevictable", unevictable * PAGE_SIZE);
+	for (i = 0; i < NR_MCS_STAT; i++)
+		cb->fill(cb, memcg_stat_strings[i].local_name, mystat.stat[i]);
 
-	}
+	/* Hierarchical information */
 	{
 		unsigned long long limit, memsw_limit;
 		memcg_get_hierarchical_limit(mem_cont, &limit, &memsw_limit);
@@ -1899,6 +1970,12 @@ static int mem_control_stat_show(struct 
 			cb->fill(cb, "hierarchical_memsw_limit", memsw_limit);
 	}
 
+	memset(&mystat, 0, sizeof(mystat));
+	mem_cgroup_get_total_stat(mem_cont, &mystat);
+	for (i = 0; i < NR_MCS_STAT; i++)
+		cb->fill(cb, memcg_stat_strings[i].total_name, mystat.stat[i]);
+
+
 #ifdef CONFIG_DEBUG_VM
 	cb->fill(cb, "inactive_ratio", calc_inactive_ratio(mem_cont, NULL));
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
