Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D6AA06B004A
	for <linux-mm@kvack.org>; Mon, 11 Jul 2011 06:38:17 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 039CD3EE0C0
	for <linux-mm@kvack.org>; Mon, 11 Jul 2011 19:38:14 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D8DFF3A62C2
	for <linux-mm@kvack.org>; Mon, 11 Jul 2011 19:38:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BF12245DE9E
	for <linux-mm@kvack.org>; Mon, 11 Jul 2011 19:38:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AD87B1DB8054
	for <linux-mm@kvack.org>; Mon, 11 Jul 2011 19:38:13 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F3001DB804F
	for <linux-mm@kvack.org>; Mon, 11 Jul 2011 19:38:13 +0900 (JST)
Date: Mon, 11 Jul 2011 19:30:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH v2] memcg: add vmscan_stat
Message-Id: <20110711193036.5a03858d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>


This patch is onto mmotm-0710... got bigger than expected ;(
==
[PATCH] add memory.vmscan_stat

commit log of commit 0ae5e89 " memcg: count the soft_limit reclaim in..."
says it adds scanning stats to memory.stat file. But it doesn't because
we considered we needed to make a concensus for such new APIs.

This patch is a trial to add memory.scan_stat. This shows
  - the number of scanned pages(total, anon, file)
  - the number of rotated pages(total, anon, file)
  - the number of freed pages(total, anon, file)
  - the number of elaplsed time (including sleep/pause time)

  for both of direct/soft reclaim.

The biggest difference with oringinal Ying's one is that this file
can be reset by some write, as

  # echo 0 ...../memory.scan_stat

Example of output is here. This is a result after make -j 6 kernel
under 300M limit.

[kamezawa@bluextal ~]$ cat /cgroup/memory/A/memory.scan_stat
[kamezawa@bluextal ~]$ cat /cgroup/memory/A/memory.vmscan_stat
scanned_pages_by_limit 9471864
scanned_anon_pages_by_limit 6640629
scanned_file_pages_by_limit 2831235
rotated_pages_by_limit 4243974
rotated_anon_pages_by_limit 3971968
rotated_file_pages_by_limit 272006
freed_pages_by_limit 2318492
freed_anon_pages_by_limit 962052
freed_file_pages_by_limit 1356440
elapsed_ns_by_limit 351386416101
scanned_pages_by_system 0
scanned_anon_pages_by_system 0
scanned_file_pages_by_system 0
rotated_pages_by_system 0
rotated_anon_pages_by_system 0
rotated_file_pages_by_system 0
freed_pages_by_system 0
freed_anon_pages_by_system 0
freed_file_pages_by_system 0
elapsed_ns_by_system 0
scanned_pages_by_limit_under_hierarchy 9471864
scanned_anon_pages_by_limit_under_hierarchy 6640629
scanned_file_pages_by_limit_under_hierarchy 2831235
rotated_pages_by_limit_under_hierarchy 4243974
rotated_anon_pages_by_limit_under_hierarchy 3971968
rotated_file_pages_by_limit_under_hierarchy 272006
freed_pages_by_limit_under_hierarchy 2318492
freed_anon_pages_by_limit_under_hierarchy 962052
freed_file_pages_by_limit_under_hierarchy 1356440
elapsed_ns_by_limit_under_hierarchy 351386416101
scanned_pages_by_system_under_hierarchy 0
scanned_anon_pages_by_system_under_hierarchy 0
scanned_file_pages_by_system_under_hierarchy 0
rotated_pages_by_system_under_hierarchy 0
rotated_anon_pages_by_system_under_hierarchy 0
rotated_file_pages_by_system_under_hierarchy 0
freed_pages_by_system_under_hierarchy 0
freed_anon_pages_by_system_under_hierarchy 0
freed_file_pages_by_system_under_hierarchy 0
elapsed_ns_by_system_under_hierarchy 0


total_xxxx is for hierarchy management.

This will be useful for further memcg developments and need to be
developped before we do some complicated rework on LRU/softlimit
management.

This patch adds a new struct memcg_scanrecord into scan_control struct.
sc->nr_scanned at el is not designed for exporting information. For example,
nr_scanned is reset frequentrly and incremented +2 at scanning mapped pages.

For avoiding complexity, I added a new param in scan_control which is for
exporting scanning score.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Changelog:
  - renamed as vmscan_stat
  - handle file/anon
  - added "rotated"
  - changed names of param in vmscan_stat.
---
 Documentation/cgroups/memory.txt |   85 +++++++++++++++++++
 include/linux/memcontrol.h       |   19 ++++
 include/linux/swap.h             |    6 -
 mm/memcontrol.c                  |  172 +++++++++++++++++++++++++++++++++++++--
 mm/vmscan.c                      |   39 +++++++-
 5 files changed, 303 insertions(+), 18 deletions(-)

Index: mmotm-0710/Documentation/cgroups/memory.txt
===================================================================
--- mmotm-0710.orig/Documentation/cgroups/memory.txt
+++ mmotm-0710/Documentation/cgroups/memory.txt
@@ -380,7 +380,7 @@ will be charged as a new owner of it.
 
 5.2 stat file
 
-memory.stat file includes following statistics
+5.2.1 memory.stat file includes following statistics
 
 # per-memory cgroup local status
 cache		- # of bytes of page cache memory.
@@ -438,6 +438,89 @@ Note:
 	 file_mapped is accounted only when the memory cgroup is owner of page
 	 cache.)
 
+5.2.2 memory.vmscan_stat
+
+memory.vmscan_stat includes statistics information for memory scanning and
+freeing, reclaiming. The statistics shows memory scanning information since
+memory cgroup creation and can be reset to 0 by writing 0 as
+
+ #echo 0 > ../memory.vmscan_stat
+
+This file contains following statistics.
+
+[param]_[file_or_anon]_pages_by_[reason]_[under_heararchy]
+[param]_elapsed_ns_by_[reason]_[under_hierarchy]
+
+For example,
+
+  scanned_file_pages_by_limit indicates the number of scanned
+  file pages at vmscan.
+
+Now, 3 parameters are supported
+
+  scanned - the number of pages scanned by vmscan
+  rotated - the number of pages activated at vmscan
+  freed   - the number of pages freed by vmscan
+
+If "rotated" is high against scanned/freed, the memcg seems busy.
+
+Now, 2 reason are supported
+
+  limit - the memory cgroup's limit
+  system - global memory pressure + softlimit
+           (global memory pressure not under softlimit is not handled now)
+
+When under_hierarchy is added in the tail, the number indicates the
+total memcg scan of its children and itself.
+
+elapsed_ns is a elapsed time in nanosecond. This may include sleep time
+and not indicates CPU usage. So, please take this as just showing
+latency.
+
+Here is an example.
+
+# cat /cgroup/memory/A/memory.vmscan_stat
+scanned_pages_by_limit 9471864
+scanned_anon_pages_by_limit 6640629
+scanned_file_pages_by_limit 2831235
+rotated_pages_by_limit 4243974
+rotated_anon_pages_by_limit 3971968
+rotated_file_pages_by_limit 272006
+freed_pages_by_limit 2318492
+freed_anon_pages_by_limit 962052
+freed_file_pages_by_limit 1356440
+elapsed_ns_by_limit 351386416101
+scanned_pages_by_system 0
+scanned_anon_pages_by_system 0
+scanned_file_pages_by_system 0
+rotated_pages_by_system 0
+rotated_anon_pages_by_system 0
+rotated_file_pages_by_system 0
+freed_pages_by_system 0
+freed_anon_pages_by_system 0
+freed_file_pages_by_system 0
+elapsed_ns_by_system 0
+scanned_pages_by_limit_under_hierarchy 9471864
+scanned_anon_pages_by_limit_under_hierarchy 6640629
+scanned_file_pages_by_limit_under_hierarchy 2831235
+rotated_pages_by_limit_under_hierarchy 4243974
+rotated_anon_pages_by_limit_under_hierarchy 3971968
+rotated_file_pages_by_limit_under_hierarchy 272006
+freed_pages_by_limit_under_hierarchy 2318492
+freed_anon_pages_by_limit_under_hierarchy 962052
+freed_file_pages_by_limit_under_hierarchy 1356440
+elapsed_ns_by_limit_under_hierarchy 351386416101
+scanned_pages_by_system_under_hierarchy 0
+scanned_anon_pages_by_system_under_hierarchy 0
+scanned_file_pages_by_system_under_hierarchy 0
+rotated_pages_by_system_under_hierarchy 0
+rotated_anon_pages_by_system_under_hierarchy 0
+rotated_file_pages_by_system_under_hierarchy 0
+freed_pages_by_system_under_hierarchy 0
+freed_anon_pages_by_system_under_hierarchy 0
+freed_file_pages_by_system_under_hierarchy 0
+elapsed_ns_by_system_under_hierarchy 0
+
 5.3 swappiness
 
 Similar to /proc/sys/vm/swappiness, but affecting a hierarchy of groups only.
Index: mmotm-0710/include/linux/memcontrol.h
===================================================================
--- mmotm-0710.orig/include/linux/memcontrol.h
+++ mmotm-0710/include/linux/memcontrol.h
@@ -39,6 +39,16 @@ extern unsigned long mem_cgroup_isolate_
 					struct mem_cgroup *mem_cont,
 					int active, int file);
 
+struct memcg_scanrecord {
+	struct mem_cgroup *mem; /* scanend memory cgroup */
+	struct mem_cgroup *root; /* scan target hierarchy root */
+	int context;		/* scanning context (see memcontrol.c) */
+	unsigned long nr_scanned[2]; /* the number of scanned pages */
+	unsigned long nr_rotated[2]; /* the number of rotated pages */
+	unsigned long nr_freed[2]; /* the number of freed pages */
+	unsigned long elapsed; /* nsec of time elapsed while scanning */
+};
+
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 /*
  * All "charge" functions with gfp_mask should use GFP_KERNEL or
@@ -117,6 +127,15 @@ mem_cgroup_get_reclaim_stat_from_page(st
 extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 					struct task_struct *p);
 
+extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
+						  gfp_t gfp_mask, bool noswap,
+						  struct memcg_scanrecord *rec);
+extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
+						gfp_t gfp_mask, bool noswap,
+						struct zone *zone,
+						struct memcg_scanrecord *rec,
+						unsigned long *nr_scanned);
+
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern int do_swap_account;
 #endif
Index: mmotm-0710/include/linux/swap.h
===================================================================
--- mmotm-0710.orig/include/linux/swap.h
+++ mmotm-0710/include/linux/swap.h
@@ -253,12 +253,6 @@ static inline void lru_cache_add_file(st
 /* linux/mm/vmscan.c */
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask, nodemask_t *mask);
-extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
-						  gfp_t gfp_mask, bool noswap);
-extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
-						gfp_t gfp_mask, bool noswap,
-						struct zone *zone,
-						unsigned long *nr_scanned);
 extern int __isolate_lru_page(struct page *page, int mode, int file);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
Index: mmotm-0710/mm/memcontrol.c
===================================================================
--- mmotm-0710.orig/mm/memcontrol.c
+++ mmotm-0710/mm/memcontrol.c
@@ -204,6 +204,50 @@ struct mem_cgroup_eventfd_list {
 static void mem_cgroup_threshold(struct mem_cgroup *mem);
 static void mem_cgroup_oom_notify(struct mem_cgroup *mem);
 
+enum {
+	SCAN_BY_LIMIT,
+	SCAN_BY_SYSTEM,
+	NR_SCAN_CONTEXT,
+	SCAN_BY_SHRINK,	/* not recorded now */
+};
+
+enum {
+	SCAN,
+	SCAN_ANON,
+	SCAN_FILE,
+	ROTATE,
+	ROTATE_ANON,
+	ROTATE_FILE,
+	FREED,
+	FREED_ANON,
+	FREED_FILE,
+	ELAPSED,
+	NR_SCANSTATS,
+};
+
+struct scanstat {
+	spinlock_t	lock;
+	unsigned long	stats[NR_SCAN_CONTEXT][NR_SCANSTATS];
+	unsigned long	rootstats[NR_SCAN_CONTEXT][NR_SCANSTATS];
+};
+
+const char *scanstat_string[NR_SCANSTATS] = {
+	"scanned_pages",
+	"scanned_anon_pages",
+	"scanned_file_pages",
+	"rotated_pages",
+	"rotated_anon_pages",
+	"rotated_file_pages",
+	"freed_pages",
+	"freed_anon_pages",
+	"freed_file_pages",
+	"elapsed_ns",
+};
+#define SCANSTAT_WORD_LIMIT	"_by_limit"
+#define SCANSTAT_WORD_SYSTEM	"_by_system"
+#define SCANSTAT_WORD_HIERARCHY	"_under_hierarchy"
+
+
 /*
  * The memory controller data structure. The memory controller controls both
  * page cache and RSS per cgroup. We would eventually like to provide
@@ -266,7 +310,8 @@ struct mem_cgroup {
 
 	/* For oom notifier event fd */
 	struct list_head oom_notify;
-
+	/* For recording LRU-scan statistics */
+	struct scanstat scanstat;
 	/*
 	 * Should we move charges of a task when a task is moved into this
 	 * mem_cgroup ? And what type of charges should we move ?
@@ -1619,6 +1664,44 @@ bool mem_cgroup_reclaimable(struct mem_c
 }
 #endif
 
+static void __mem_cgroup_record_scanstat(unsigned long *stats,
+			   struct memcg_scanrecord *rec)
+{
+
+	stats[SCAN] += rec->nr_scanned[0] + rec->nr_scanned[1];
+	stats[SCAN_ANON] += rec->nr_scanned[0];
+	stats[SCAN_FILE] += rec->nr_scanned[1];
+
+	stats[ROTATE] += rec->nr_rotated[0] + rec->nr_rotated[1];
+	stats[ROTATE_ANON] += rec->nr_rotated[0];
+	stats[ROTATE_FILE] += rec->nr_rotated[1];
+
+	stats[FREED] += rec->nr_freed[0] + rec->nr_freed[1];
+	stats[FREED_ANON] += rec->nr_freed[0];
+	stats[FREED_FILE] += rec->nr_freed[1];
+
+	stats[ELAPSED] += rec->elapsed;
+}
+
+static void mem_cgroup_record_scanstat(struct memcg_scanrecord *rec)
+{
+	struct mem_cgroup *mem;
+	int context = rec->context;
+
+	if (context >= NR_SCAN_CONTEXT)
+		return;
+
+	mem = rec->mem;
+	spin_lock(&mem->scanstat.lock);
+	__mem_cgroup_record_scanstat(mem->scanstat.stats[context], rec);
+	spin_unlock(&mem->scanstat.lock);
+
+	mem = rec->root;
+	spin_lock(&mem->scanstat.lock);
+	__mem_cgroup_record_scanstat(mem->scanstat.rootstats[context], rec);
+	spin_unlock(&mem->scanstat.lock);
+}
+
 /*
  * Scan the hierarchy if needed to reclaim memory. We remember the last child
  * we reclaimed from, so that we don't end up penalizing one child extensively
@@ -1643,8 +1726,9 @@ static int mem_cgroup_hierarchical_recla
 	bool noswap = reclaim_options & MEM_CGROUP_RECLAIM_NOSWAP;
 	bool shrink = reclaim_options & MEM_CGROUP_RECLAIM_SHRINK;
 	bool check_soft = reclaim_options & MEM_CGROUP_RECLAIM_SOFT;
+	struct memcg_scanrecord rec;
 	unsigned long excess;
-	unsigned long nr_scanned;
+	unsigned long scanned;
 
 	excess = res_counter_soft_limit_excess(&root_mem->res) >> PAGE_SHIFT;
 
@@ -1652,6 +1736,15 @@ static int mem_cgroup_hierarchical_recla
 	if (!check_soft && root_mem->memsw_is_minimum)
 		noswap = true;
 
+	if (shrink)
+		rec.context = SCAN_BY_SHRINK;
+	else if (check_soft)
+		rec.context = SCAN_BY_SYSTEM;
+	else
+		rec.context = SCAN_BY_LIMIT;
+
+	rec.root = root_mem;
+
 	while (1) {
 		victim = mem_cgroup_select_victim(root_mem);
 		if (victim == root_mem) {
@@ -1692,14 +1785,23 @@ static int mem_cgroup_hierarchical_recla
 			css_put(&victim->css);
 			continue;
 		}
+		rec.mem = victim;
+		rec.nr_scanned[0] = 0;
+		rec.nr_scanned[1] = 0;
+		rec.nr_rotated[0] = 0;
+		rec.nr_rotated[1] = 0;
+		rec.nr_freed[0] = 0;
+		rec.nr_freed[1] = 0;
+		rec.elapsed = 0;
 		/* we use swappiness of local cgroup */
 		if (check_soft) {
 			ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
-				noswap, zone, &nr_scanned);
-			*total_scanned += nr_scanned;
+				noswap, zone, &rec, &scanned);
+			*total_scanned += scanned;
 		} else
 			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
-						noswap);
+						noswap, &rec);
+		mem_cgroup_record_scanstat(&rec);
 		css_put(&victim->css);
 		/*
 		 * At shrinking usage, we can't check we should stop here or
@@ -3688,14 +3790,18 @@ try_to_free:
 	/* try to free all pages in this cgroup */
 	shrink = 1;
 	while (nr_retries && mem->res.usage > 0) {
+		struct memcg_scanrecord rec;
 		int progress;
 
 		if (signal_pending(current)) {
 			ret = -EINTR;
 			goto out;
 		}
+		rec.context = SCAN_BY_SHRINK;
+		rec.mem = mem;
+		rec.root = mem;
 		progress = try_to_free_mem_cgroup_pages(mem, GFP_KERNEL,
-						false);
+						false, &rec);
 		if (!progress) {
 			nr_retries--;
 			/* maybe some writeback is necessary */
@@ -4539,6 +4645,54 @@ static int mem_control_numa_stat_open(st
 }
 #endif /* CONFIG_NUMA */
 
+static int mem_cgroup_vmscan_stat_read(struct cgroup *cgrp,
+				struct cftype *cft,
+				struct cgroup_map_cb *cb)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+	char string[64];
+	int i;
+
+	for (i = 0; i < NR_SCANSTATS; i++) {
+		strcpy(string, scanstat_string[i]);
+		strcat(string, SCANSTAT_WORD_LIMIT);
+		cb->fill(cb, string,  mem->scanstat.stats[SCAN_BY_LIMIT][i]);
+	}
+
+	for (i = 0; i < NR_SCANSTATS; i++) {
+		strcpy(string, scanstat_string[i]);
+		strcat(string, SCANSTAT_WORD_SYSTEM);
+		cb->fill(cb, string,  mem->scanstat.stats[SCAN_BY_SYSTEM][i]);
+	}
+
+	for (i = 0; i < NR_SCANSTATS; i++) {
+		strcpy(string, scanstat_string[i]);
+		strcat(string, SCANSTAT_WORD_LIMIT);
+		strcat(string, SCANSTAT_WORD_HIERARCHY);
+		cb->fill(cb, string,  mem->scanstat.rootstats[SCAN_BY_LIMIT][i]);
+	}
+	for (i = 0; i < NR_SCANSTATS; i++) {
+		strcpy(string, scanstat_string[i]);
+		strcat(string, SCANSTAT_WORD_SYSTEM);
+		strcat(string, SCANSTAT_WORD_HIERARCHY);
+		cb->fill(cb, string,  mem->scanstat.rootstats[SCAN_BY_SYSTEM][i]);
+	}
+	return 0;
+}
+
+static int mem_cgroup_reset_vmscan_stat(struct cgroup *cgrp,
+				unsigned int event)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+
+	spin_lock(&mem->scanstat.lock);
+	memset(&mem->scanstat.stats, 0, sizeof(mem->scanstat.stats));
+	memset(&mem->scanstat.rootstats, 0, sizeof(mem->scanstat.rootstats));
+	spin_unlock(&mem->scanstat.lock);
+	return 0;
+}
+
+
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
@@ -4609,6 +4763,11 @@ static struct cftype mem_cgroup_files[] 
 		.mode = S_IRUGO,
 	},
 #endif
+	{
+		.name = "vmscan_stat",
+		.read_map = mem_cgroup_vmscan_stat_read,
+		.trigger = mem_cgroup_reset_vmscan_stat,
+	},
 };
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
@@ -4872,6 +5031,7 @@ mem_cgroup_create(struct cgroup_subsys *
 	atomic_set(&mem->refcnt, 1);
 	mem->move_charge_at_immigrate = 0;
 	mutex_init(&mem->thresholds_lock);
+	spin_lock_init(&mem->scanstat.lock);
 	return &mem->css;
 free_out:
 	__mem_cgroup_free(mem);
Index: mmotm-0710/mm/vmscan.c
===================================================================
--- mmotm-0710.orig/mm/vmscan.c
+++ mmotm-0710/mm/vmscan.c
@@ -105,6 +105,7 @@ struct scan_control {
 
 	/* Which cgroup do we reclaim from */
 	struct mem_cgroup *mem_cgroup;
+	struct memcg_scanrecord *memcg_record;
 
 	/*
 	 * Nodemask of nodes allowed by the caller. If NULL, all nodes
@@ -1307,6 +1308,8 @@ putback_lru_pages(struct zone *zone, str
 			int file = is_file_lru(lru);
 			int numpages = hpage_nr_pages(page);
 			reclaim_stat->recent_rotated[file] += numpages;
+			if (!scanning_global_lru(sc))
+				sc->memcg_record->nr_rotated[file] += numpages;
 		}
 		if (!pagevec_add(&pvec, page)) {
 			spin_unlock_irq(&zone->lru_lock);
@@ -1350,6 +1353,10 @@ static noinline_for_stack void update_is
 
 	reclaim_stat->recent_scanned[0] += *nr_anon;
 	reclaim_stat->recent_scanned[1] += *nr_file;
+	if (!scanning_global_lru(sc)) {
+		sc->memcg_record->nr_scanned[0] += *nr_anon;
+		sc->memcg_record->nr_scanned[1] += *nr_file;
+	}
 }
 
 /*
@@ -1457,6 +1464,9 @@ shrink_inactive_list(unsigned long nr_to
 
 	nr_reclaimed = shrink_page_list(&page_list, zone, sc);
 
+	if (!scanning_global_lru(sc))
+		sc->memcg_record->nr_freed[file] += nr_reclaimed;
+
 	/* Check if we should syncronously wait for writeback */
 	if (should_reclaim_stall(nr_taken, nr_reclaimed, priority, sc)) {
 		set_reclaim_mode(priority, sc, true);
@@ -1562,6 +1572,8 @@ static void shrink_active_list(unsigned 
 	}
 
 	reclaim_stat->recent_scanned[file] += nr_taken;
+	if (!scanning_global_lru(sc))
+		sc->memcg_record->nr_scanned[file] += nr_taken;
 
 	__count_zone_vm_events(PGREFILL, zone, pgscanned);
 	if (file)
@@ -1613,6 +1625,8 @@ static void shrink_active_list(unsigned 
 	 * get_scan_ratio.
 	 */
 	reclaim_stat->recent_rotated[file] += nr_rotated;
+	if (!scanning_global_lru(sc))
+		sc->memcg_record->nr_rotated[file] += nr_rotated;
 
 	move_active_pages_to_lru(zone, &l_active,
 						LRU_ACTIVE + file * LRU_FILE);
@@ -2207,9 +2221,10 @@ unsigned long try_to_free_pages(struct z
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 
 unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
-						gfp_t gfp_mask, bool noswap,
-						struct zone *zone,
-						unsigned long *nr_scanned)
+					gfp_t gfp_mask, bool noswap,
+					struct zone *zone,
+					struct memcg_scanrecord *rec,
+					unsigned long *scanned)
 {
 	struct scan_control sc = {
 		.nr_scanned = 0,
@@ -2219,7 +2234,9 @@ unsigned long mem_cgroup_shrink_node_zon
 		.may_swap = !noswap,
 		.order = 0,
 		.mem_cgroup = mem,
+		.memcg_record = rec,
 	};
+	unsigned long start, end;
 
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
@@ -2228,6 +2245,7 @@ unsigned long mem_cgroup_shrink_node_zon
 						      sc.may_writepage,
 						      sc.gfp_mask);
 
+	start = sched_clock();
 	/*
 	 * NOTE: Although we can get the priority field, using it
 	 * here is not a good idea, since it limits the pages we can scan.
@@ -2236,19 +2254,25 @@ unsigned long mem_cgroup_shrink_node_zon
 	 * the priority and make it zero.
 	 */
 	shrink_zone(0, zone, &sc);
+	end = sched_clock();
+
+	if (rec)
+		rec->elapsed += end - start;
+	*scanned = sc.nr_scanned;
 
 	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
 
-	*nr_scanned = sc.nr_scanned;
 	return sc.nr_reclaimed;
 }
 
 unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 					   gfp_t gfp_mask,
-					   bool noswap)
+					   bool noswap,
+					   struct memcg_scanrecord *rec)
 {
 	struct zonelist *zonelist;
 	unsigned long nr_reclaimed;
+	unsigned long start, end;
 	int nid;
 	struct scan_control sc = {
 		.may_writepage = !laptop_mode,
@@ -2257,6 +2281,7 @@ unsigned long try_to_free_mem_cgroup_pag
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.order = 0,
 		.mem_cgroup = mem_cont,
+		.memcg_record = rec,
 		.nodemask = NULL, /* we don't care the placement */
 		.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 				(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK),
@@ -2265,6 +2290,7 @@ unsigned long try_to_free_mem_cgroup_pag
 		.gfp_mask = sc.gfp_mask,
 	};
 
+	start = sched_clock();
 	/*
 	 * Unlike direct reclaim via alloc_pages(), memcg's reclaim doesn't
 	 * take care of from where we get pages. So the node where we start the
@@ -2279,6 +2305,9 @@ unsigned long try_to_free_mem_cgroup_pag
 					    sc.gfp_mask);
 
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc, &shrink);
+	end = sched_clock();
+	if (rec)
+		rec->elapsed += end - start;
 
 	trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
