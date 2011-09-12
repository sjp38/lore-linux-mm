Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id E1A7D6B0259
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 06:58:03 -0400 (EDT)
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch 0/11] mm: memcg naturalization -rc3
Date: Mon, 12 Sep 2011 12:57:17 +0200
Message-Id: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi everyone,

this is the third revision of the memcg naturalization patch set.  Due
to controversy, I dropped the reclaim statistics and the soft limit
reclaim rewrite.  What's left is mostly making the per-memcg LRU lists
exclusive.

Christoph suggested making struct mem_cgroup part of the core and have
reclaim always operate on at least a skeleton root_mem_cgroup with
basic LRU info even on !CONFIG_MEMCG kernels.  I agree that we should
go there, but in its current form this would drag a lot of ugly memcg
internals out into the public and I'd prefer another struct mem_cgroup
shakedown and the soft limit stuff to be done before this step.  But
we are getting there.

Changelog since -rc2
- consolidated all memcg hierarchy iteration constructs
- pass struct mem_cgroup_zone down the reclaim stack
- fix concurrent full hierarchy round-trip detection
- split out moving memcg reclaim from hierarchical global reclaim
- drop reclaim statistics
- rename do_shrink_zone to shrink_mem_cgroup_zone
- fix anon pre-aging to operate on per-memcg lrus
- revert to traditional limit reclaim hierarchy iteration
- split out lruvec introduction
- kill __add_page_to_lru_list
- fix LRU-accounting during swapcache/pagecache charging
- fix LRU-accounting of uncharged swapcache
- split out removing array id from pc->flags
- drop soft limit rework

More introduction and test results are included in the changelog of
the first patch.

 include/linux/memcontrol.h  |   74 +++--
 include/linux/mm_inline.h   |   21 +-
 include/linux/mmzone.h      |   10 +-
 include/linux/page_cgroup.h |   34 ---
 mm/memcontrol.c             |  688 ++++++++++++++++++++-----------------------
 mm/page_alloc.c             |    2 +-
 mm/page_cgroup.c            |   59 +----
 mm/swap.c                   |   24 +-
 mm/vmscan.c                 |  447 +++++++++++++++++-----------
 9 files changed, 674 insertions(+), 685 deletions(-)

The series is based on v3.1-rc3-mmotm-2011-08-24-14-08-14 plus the
following fixes from the not-yet-released -mm:

    Revert "memcg: add memory.vmscan_stat"
    memcg: skip scanning active lists based on individual list size
    mm: memcg: close race between charge and putback

Rolled-up diff of those attached.  Comments welcome!

	Hannes

---

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 6f3c598..06eb6d9 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -380,7 +380,7 @@ will be charged as a new owner of it.
 
 5.2 stat file
 
-5.2.1 memory.stat file includes following statistics
+memory.stat file includes following statistics
 
 # per-memory cgroup local status
 cache		- # of bytes of page cache memory.
@@ -438,89 +438,6 @@ Note:
 	 file_mapped is accounted only when the memory cgroup is owner of page
 	 cache.)
 
-5.2.2 memory.vmscan_stat
-
-memory.vmscan_stat includes statistics information for memory scanning and
-freeing, reclaiming. The statistics shows memory scanning information since
-memory cgroup creation and can be reset to 0 by writing 0 as
-
- #echo 0 > ../memory.vmscan_stat
-
-This file contains following statistics.
-
-[param]_[file_or_anon]_pages_by_[reason]_[under_heararchy]
-[param]_elapsed_ns_by_[reason]_[under_hierarchy]
-
-For example,
-
-  scanned_file_pages_by_limit indicates the number of scanned
-  file pages at vmscan.
-
-Now, 3 parameters are supported
-
-  scanned - the number of pages scanned by vmscan
-  rotated - the number of pages activated at vmscan
-  freed   - the number of pages freed by vmscan
-
-If "rotated" is high against scanned/freed, the memcg seems busy.
-
-Now, 2 reason are supported
-
-  limit - the memory cgroup's limit
-  system - global memory pressure + softlimit
-           (global memory pressure not under softlimit is not handled now)
-
-When under_hierarchy is added in the tail, the number indicates the
-total memcg scan of its children and itself.
-
-elapsed_ns is a elapsed time in nanosecond. This may include sleep time
-and not indicates CPU usage. So, please take this as just showing
-latency.
-
-Here is an example.
-
-# cat /cgroup/memory/A/memory.vmscan_stat
-scanned_pages_by_limit 9471864
-scanned_anon_pages_by_limit 6640629
-scanned_file_pages_by_limit 2831235
-rotated_pages_by_limit 4243974
-rotated_anon_pages_by_limit 3971968
-rotated_file_pages_by_limit 272006
-freed_pages_by_limit 2318492
-freed_anon_pages_by_limit 962052
-freed_file_pages_by_limit 1356440
-elapsed_ns_by_limit 351386416101
-scanned_pages_by_system 0
-scanned_anon_pages_by_system 0
-scanned_file_pages_by_system 0
-rotated_pages_by_system 0
-rotated_anon_pages_by_system 0
-rotated_file_pages_by_system 0
-freed_pages_by_system 0
-freed_anon_pages_by_system 0
-freed_file_pages_by_system 0
-elapsed_ns_by_system 0
-scanned_pages_by_limit_under_hierarchy 9471864
-scanned_anon_pages_by_limit_under_hierarchy 6640629
-scanned_file_pages_by_limit_under_hierarchy 2831235
-rotated_pages_by_limit_under_hierarchy 4243974
-rotated_anon_pages_by_limit_under_hierarchy 3971968
-rotated_file_pages_by_limit_under_hierarchy 272006
-freed_pages_by_limit_under_hierarchy 2318492
-freed_anon_pages_by_limit_under_hierarchy 962052
-freed_file_pages_by_limit_under_hierarchy 1356440
-elapsed_ns_by_limit_under_hierarchy 351386416101
-scanned_pages_by_system_under_hierarchy 0
-scanned_anon_pages_by_system_under_hierarchy 0
-scanned_file_pages_by_system_under_hierarchy 0
-rotated_pages_by_system_under_hierarchy 0
-rotated_anon_pages_by_system_under_hierarchy 0
-rotated_file_pages_by_system_under_hierarchy 0
-freed_pages_by_system_under_hierarchy 0
-freed_anon_pages_by_system_under_hierarchy 0
-freed_file_pages_by_system_under_hierarchy 0
-elapsed_ns_by_system_under_hierarchy 0
-
 5.3 swappiness
 
 Similar to /proc/sys/vm/swappiness, but affecting a hierarchy of groups only.
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index fb1ed1c..b87068a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -40,16 +40,6 @@ extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct mem_cgroup *mem_cont,
 					int active, int file);
 
-struct memcg_scanrecord {
-	struct mem_cgroup *mem; /* scanend memory cgroup */
-	struct mem_cgroup *root; /* scan target hierarchy root */
-	int context;		/* scanning context (see memcontrol.c) */
-	unsigned long nr_scanned[2]; /* the number of scanned pages */
-	unsigned long nr_rotated[2]; /* the number of rotated pages */
-	unsigned long nr_freed[2]; /* the number of freed pages */
-	unsigned long elapsed; /* nsec of time elapsed while scanning */
-};
-
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 /*
  * All "charge" functions with gfp_mask should use GFP_KERNEL or
@@ -116,8 +106,10 @@ extern void mem_cgroup_end_migration(struct mem_cgroup *memcg,
 /*
  * For memory reclaim.
  */
-int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
-int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
+int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg,
+				    struct zone *zone);
+int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg,
+				    struct zone *zone);
 int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
 unsigned long mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg,
 					int nid, int zid, unsigned int lrumask);
@@ -128,15 +120,6 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page);
 extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 					struct task_struct *p);
 
-extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
-						  gfp_t gfp_mask, bool noswap,
-						  struct memcg_scanrecord *rec);
-extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
-						gfp_t gfp_mask, bool noswap,
-						struct zone *zone,
-						struct memcg_scanrecord *rec,
-						unsigned long *nr_scanned);
-
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern int do_swap_account;
 #endif
@@ -314,13 +297,13 @@ static inline bool mem_cgroup_disabled(void)
 }
 
 static inline int
-mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg)
+mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg, struct zone *zone)
 {
 	return 1;
 }
 
 static inline int
-mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg)
+mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg, struct zone *zone)
 {
 	return 1;
 }
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 3808f10..b156e80 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -249,6 +249,12 @@ static inline void lru_cache_add_file(struct page *page)
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask, nodemask_t *mask);
 extern int __isolate_lru_page(struct page *page, isolate_mode_t mode, int file);
+extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
+						  gfp_t gfp_mask, bool noswap);
+extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
+						gfp_t gfp_mask, bool noswap,
+						struct zone *zone,
+						unsigned long *nr_scanned);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 54b35b3..b76011a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -205,50 +205,6 @@ struct mem_cgroup_eventfd_list {
 static void mem_cgroup_threshold(struct mem_cgroup *memcg);
 static void mem_cgroup_oom_notify(struct mem_cgroup *memcg);
 
-enum {
-	SCAN_BY_LIMIT,
-	SCAN_BY_SYSTEM,
-	NR_SCAN_CONTEXT,
-	SCAN_BY_SHRINK,	/* not recorded now */
-};
-
-enum {
-	SCAN,
-	SCAN_ANON,
-	SCAN_FILE,
-	ROTATE,
-	ROTATE_ANON,
-	ROTATE_FILE,
-	FREED,
-	FREED_ANON,
-	FREED_FILE,
-	ELAPSED,
-	NR_SCANSTATS,
-};
-
-struct scanstat {
-	spinlock_t	lock;
-	unsigned long	stats[NR_SCAN_CONTEXT][NR_SCANSTATS];
-	unsigned long	rootstats[NR_SCAN_CONTEXT][NR_SCANSTATS];
-};
-
-const char *scanstat_string[NR_SCANSTATS] = {
-	"scanned_pages",
-	"scanned_anon_pages",
-	"scanned_file_pages",
-	"rotated_pages",
-	"rotated_anon_pages",
-	"rotated_file_pages",
-	"freed_pages",
-	"freed_anon_pages",
-	"freed_file_pages",
-	"elapsed_ns",
-};
-#define SCANSTAT_WORD_LIMIT	"_by_limit"
-#define SCANSTAT_WORD_SYSTEM	"_by_system"
-#define SCANSTAT_WORD_HIERARCHY	"_under_hierarchy"
-
-
 /*
  * The memory controller data structure. The memory controller controls both
  * page cache and RSS per cgroup. We would eventually like to provide
@@ -314,8 +270,7 @@ struct mem_cgroup {
 
 	/* For oom notifier event fd */
 	struct list_head oom_notify;
-	/* For recording LRU-scan statistics */
-	struct scanstat scanstat;
+
 	/*
 	 * Should we move charges of a task when a task is moved into this
 	 * mem_cgroup ? And what type of charges should we move ?
@@ -1035,6 +990,16 @@ void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
 		return;
 	pc = lookup_page_cgroup(page);
 	VM_BUG_ON(PageCgroupAcctLRU(pc));
+	/*
+	 * putback:				charge:
+	 * SetPageLRU				SetPageCgroupUsed
+	 * smp_mb				smp_mb
+	 * PageCgroupUsed && add to memcg LRU	PageLRU && add to memcg LRU
+	 *
+	 * Ensure that one of the two sides adds the page to the memcg
+	 * LRU during a race.
+	 */
+	smp_mb();
 	if (!PageCgroupUsed(pc))
 		return;
 	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
@@ -1086,7 +1051,16 @@ static void mem_cgroup_lru_add_after_commit(struct page *page)
 	unsigned long flags;
 	struct zone *zone = page_zone(page);
 	struct page_cgroup *pc = lookup_page_cgroup(page);
-
+	/*
+	 * putback:				charge:
+	 * SetPageLRU				SetPageCgroupUsed
+	 * smp_mb				smp_mb
+	 * PageCgroupUsed && add to memcg LRU	PageLRU && add to memcg LRU
+	 *
+	 * Ensure that one of the two sides adds the page to the memcg
+	 * LRU during a race.
+	 */
+	smp_mb();
 	/* taking care of that the page is added to LRU while we commit it */
 	if (likely(!PageLRU(page)))
 		return;
@@ -1146,15 +1120,19 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg)
 	return ret;
 }
 
-static int calc_inactive_ratio(struct mem_cgroup *memcg, unsigned long *present_pages)
+int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg, struct zone *zone)
 {
-	unsigned long active;
+	unsigned long inactive_ratio;
+	int nid = zone_to_nid(zone);
+	int zid = zone_idx(zone);
 	unsigned long inactive;
+	unsigned long active;
 	unsigned long gb;
-	unsigned long inactive_ratio;
 
-	inactive = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_INACTIVE_ANON));
-	active = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_ACTIVE_ANON));
+	inactive = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
+						BIT(LRU_INACTIVE_ANON));
+	active = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
+					      BIT(LRU_ACTIVE_ANON));
 
 	gb = (inactive + active) >> (30 - PAGE_SHIFT);
 	if (gb)
@@ -1162,39 +1140,20 @@ static int calc_inactive_ratio(struct mem_cgroup *memcg, unsigned long *present_
 	else
 		inactive_ratio = 1;
 
-	if (present_pages) {
-		present_pages[0] = inactive;
-		present_pages[1] = active;
-	}
-
-	return inactive_ratio;
+	return inactive * inactive_ratio < active;
 }
 
-int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg)
-{
-	unsigned long active;
-	unsigned long inactive;
-	unsigned long present_pages[2];
-	unsigned long inactive_ratio;
-
-	inactive_ratio = calc_inactive_ratio(memcg, present_pages);
-
-	inactive = present_pages[0];
-	active = present_pages[1];
-
-	if (inactive * inactive_ratio < active)
-		return 1;
-
-	return 0;
-}
-
-int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg)
+int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg, struct zone *zone)
 {
 	unsigned long active;
 	unsigned long inactive;
+	int zid = zone_idx(zone);
+	int nid = zone_to_nid(zone);
 
-	inactive = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_INACTIVE_FILE));
-	active = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_ACTIVE_FILE));
+	inactive = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
+						BIT(LRU_INACTIVE_FILE));
+	active = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
+					      BIT(LRU_ACTIVE_FILE));
 
 	return (active > inactive);
 }
@@ -1679,44 +1638,6 @@ bool mem_cgroup_reclaimable(struct mem_cgroup *memcg, bool noswap)
 }
 #endif
 
-static void __mem_cgroup_record_scanstat(unsigned long *stats,
-			   struct memcg_scanrecord *rec)
-{
-
-	stats[SCAN] += rec->nr_scanned[0] + rec->nr_scanned[1];
-	stats[SCAN_ANON] += rec->nr_scanned[0];
-	stats[SCAN_FILE] += rec->nr_scanned[1];
-
-	stats[ROTATE] += rec->nr_rotated[0] + rec->nr_rotated[1];
-	stats[ROTATE_ANON] += rec->nr_rotated[0];
-	stats[ROTATE_FILE] += rec->nr_rotated[1];
-
-	stats[FREED] += rec->nr_freed[0] + rec->nr_freed[1];
-	stats[FREED_ANON] += rec->nr_freed[0];
-	stats[FREED_FILE] += rec->nr_freed[1];
-
-	stats[ELAPSED] += rec->elapsed;
-}
-
-static void mem_cgroup_record_scanstat(struct memcg_scanrecord *rec)
-{
-	struct mem_cgroup *memcg;
-	int context = rec->context;
-
-	if (context >= NR_SCAN_CONTEXT)
-		return;
-
-	memcg = rec->mem;
-	spin_lock(&memcg->scanstat.lock);
-	__mem_cgroup_record_scanstat(memcg->scanstat.stats[context], rec);
-	spin_unlock(&memcg->scanstat.lock);
-
-	memcg = rec->root;
-	spin_lock(&memcg->scanstat.lock);
-	__mem_cgroup_record_scanstat(memcg->scanstat.rootstats[context], rec);
-	spin_unlock(&memcg->scanstat.lock);
-}
-
 /*
  * Scan the hierarchy if needed to reclaim memory. We remember the last child
  * we reclaimed from, so that we don't end up penalizing one child extensively
@@ -1741,9 +1662,8 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_memcg,
 	bool noswap = reclaim_options & MEM_CGROUP_RECLAIM_NOSWAP;
 	bool shrink = reclaim_options & MEM_CGROUP_RECLAIM_SHRINK;
 	bool check_soft = reclaim_options & MEM_CGROUP_RECLAIM_SOFT;
-	struct memcg_scanrecord rec;
 	unsigned long excess;
-	unsigned long scanned;
+	unsigned long nr_scanned;
 
 	excess = res_counter_soft_limit_excess(&root_memcg->res) >> PAGE_SHIFT;
 
@@ -1751,15 +1671,6 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_memcg,
 	if (!check_soft && !shrink && root_memcg->memsw_is_minimum)
 		noswap = true;
 
-	if (shrink)
-		rec.context = SCAN_BY_SHRINK;
-	else if (check_soft)
-		rec.context = SCAN_BY_SYSTEM;
-	else
-		rec.context = SCAN_BY_LIMIT;
-
-	rec.root = root_memcg;
-
 	while (1) {
 		victim = mem_cgroup_select_victim(root_memcg);
 		if (victim == root_memcg) {
@@ -1800,23 +1711,14 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_memcg,
 			css_put(&victim->css);
 			continue;
 		}
-		rec.mem = victim;
-		rec.nr_scanned[0] = 0;
-		rec.nr_scanned[1] = 0;
-		rec.nr_rotated[0] = 0;
-		rec.nr_rotated[1] = 0;
-		rec.nr_freed[0] = 0;
-		rec.nr_freed[1] = 0;
-		rec.elapsed = 0;
 		/* we use swappiness of local cgroup */
 		if (check_soft) {
 			ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
-				noswap, zone, &rec, &scanned);
-			*total_scanned += scanned;
+				noswap, zone, &nr_scanned);
+			*total_scanned += nr_scanned;
 		} else
 			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
-						noswap, &rec);
-		mem_cgroup_record_scanstat(&rec);
+						noswap);
 		css_put(&victim->css);
 		/*
 		 * At shrinking usage, we can't check we should stop here or
@@ -3853,18 +3755,14 @@ try_to_free:
 	/* try to free all pages in this cgroup */
 	shrink = 1;
 	while (nr_retries && memcg->res.usage > 0) {
-		struct memcg_scanrecord rec;
 		int progress;
 
 		if (signal_pending(current)) {
 			ret = -EINTR;
 			goto out;
 		}
-		rec.context = SCAN_BY_SHRINK;
-		rec.mem = memcg;
-		rec.root = memcg;
 		progress = try_to_free_mem_cgroup_pages(memcg, GFP_KERNEL,
-						false, &rec);
+						false);
 		if (!progress) {
 			nr_retries--;
 			/* maybe some writeback is necessary */
@@ -4293,8 +4191,6 @@ static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
 	}
 
 #ifdef CONFIG_DEBUG_VM
-	cb->fill(cb, "inactive_ratio", calc_inactive_ratio(mem_cont, NULL));
-
 	{
 		int nid, zid;
 		struct mem_cgroup_per_zone *mz;
@@ -4708,57 +4604,6 @@ static int mem_control_numa_stat_open(struct inode *unused, struct file *file)
 }
 #endif /* CONFIG_NUMA */
 
-static int mem_cgroup_vmscan_stat_read(struct cgroup *cgrp,
-				struct cftype *cft,
-				struct cgroup_map_cb *cb)
-{
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
-	char string[64];
-	int i;
-
-	for (i = 0; i < NR_SCANSTATS; i++) {
-		strcpy(string, scanstat_string[i]);
-		strcat(string, SCANSTAT_WORD_LIMIT);
-		cb->fill(cb, string, memcg->scanstat.stats[SCAN_BY_LIMIT][i]);
-	}
-
-	for (i = 0; i < NR_SCANSTATS; i++) {
-		strcpy(string, scanstat_string[i]);
-		strcat(string, SCANSTAT_WORD_SYSTEM);
-		cb->fill(cb, string, memcg->scanstat.stats[SCAN_BY_SYSTEM][i]);
-	}
-
-	for (i = 0; i < NR_SCANSTATS; i++) {
-		strcpy(string, scanstat_string[i]);
-		strcat(string, SCANSTAT_WORD_LIMIT);
-		strcat(string, SCANSTAT_WORD_HIERARCHY);
-		cb->fill(cb,
-			string, memcg->scanstat.rootstats[SCAN_BY_LIMIT][i]);
-	}
-	for (i = 0; i < NR_SCANSTATS; i++) {
-		strcpy(string, scanstat_string[i]);
-		strcat(string, SCANSTAT_WORD_SYSTEM);
-		strcat(string, SCANSTAT_WORD_HIERARCHY);
-		cb->fill(cb,
-			string, memcg->scanstat.rootstats[SCAN_BY_SYSTEM][i]);
-	}
-	return 0;
-}
-
-static int mem_cgroup_reset_vmscan_stat(struct cgroup *cgrp,
-				unsigned int event)
-{
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
-
-	spin_lock(&memcg->scanstat.lock);
-	memset(&memcg->scanstat.stats, 0, sizeof(memcg->scanstat.stats));
-	memset(&memcg->scanstat.rootstats,
-		0, sizeof(memcg->scanstat.rootstats));
-	spin_unlock(&memcg->scanstat.lock);
-	return 0;
-}
-
-
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
@@ -4829,11 +4674,6 @@ static struct cftype mem_cgroup_files[] = {
 		.mode = S_IRUGO,
 	},
 #endif
-	{
-		.name = "vmscan_stat",
-		.read_map = mem_cgroup_vmscan_stat_read,
-		.trigger = mem_cgroup_reset_vmscan_stat,
-	},
 };
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
@@ -5097,7 +4937,6 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	atomic_set(&memcg->refcnt, 1);
 	memcg->move_charge_at_immigrate = 0;
 	mutex_init(&memcg->thresholds_lock);
-	spin_lock_init(&memcg->scanstat.lock);
 	return &memcg->css;
 free_out:
 	__mem_cgroup_free(memcg);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 23256e8..7502726 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -105,7 +105,6 @@ struct scan_control {
 
 	/* Which cgroup do we reclaim from */
 	struct mem_cgroup *mem_cgroup;
-	struct memcg_scanrecord *memcg_record;
 
 	/*
 	 * Nodemask of nodes allowed by the caller. If NULL, all nodes
@@ -1381,8 +1380,6 @@ putback_lru_pages(struct zone *zone, struct scan_control *sc,
 			int file = is_file_lru(lru);
 			int numpages = hpage_nr_pages(page);
 			reclaim_stat->recent_rotated[file] += numpages;
-			if (!scanning_global_lru(sc))
-				sc->memcg_record->nr_rotated[file] += numpages;
 		}
 		if (!pagevec_add(&pvec, page)) {
 			spin_unlock_irq(&zone->lru_lock);
@@ -1426,10 +1423,6 @@ static noinline_for_stack void update_isolated_counts(struct zone *zone,
 
 	reclaim_stat->recent_scanned[0] += *nr_anon;
 	reclaim_stat->recent_scanned[1] += *nr_file;
-	if (!scanning_global_lru(sc)) {
-		sc->memcg_record->nr_scanned[0] += *nr_anon;
-		sc->memcg_record->nr_scanned[1] += *nr_file;
-	}
 }
 
 /*
@@ -1551,9 +1544,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 					priority, &nr_dirty, &nr_writeback);
 	}
 
-	if (!scanning_global_lru(sc))
-		sc->memcg_record->nr_freed[file] += nr_reclaimed;
-
 	local_irq_disable();
 	if (current_is_kswapd())
 		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
@@ -1670,8 +1660,6 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	}
 
 	reclaim_stat->recent_scanned[file] += nr_taken;
-	if (!scanning_global_lru(sc))
-		sc->memcg_record->nr_scanned[file] += nr_taken;
 
 	__count_zone_vm_events(PGREFILL, zone, pgscanned);
 	if (file)
@@ -1723,8 +1711,6 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	 * get_scan_ratio.
 	 */
 	reclaim_stat->recent_rotated[file] += nr_rotated;
-	if (!scanning_global_lru(sc))
-		sc->memcg_record->nr_rotated[file] += nr_rotated;
 
 	move_active_pages_to_lru(zone, &l_active,
 						LRU_ACTIVE + file * LRU_FILE);
@@ -1770,7 +1756,7 @@ static int inactive_anon_is_low(struct zone *zone, struct scan_control *sc)
 	if (scanning_global_lru(sc))
 		low = inactive_anon_is_low_global(zone);
 	else
-		low = mem_cgroup_inactive_anon_is_low(sc->mem_cgroup);
+		low = mem_cgroup_inactive_anon_is_low(sc->mem_cgroup, zone);
 	return low;
 }
 #else
@@ -1813,7 +1799,7 @@ static int inactive_file_is_low(struct zone *zone, struct scan_control *sc)
 	if (scanning_global_lru(sc))
 		low = inactive_file_is_low_global(zone);
 	else
-		low = mem_cgroup_inactive_file_is_low(sc->mem_cgroup);
+		low = mem_cgroup_inactive_file_is_low(sc->mem_cgroup, zone);
 	return low;
 }
 
@@ -2313,10 +2299,9 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 
 unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
-					gfp_t gfp_mask, bool noswap,
-					struct zone *zone,
-					struct memcg_scanrecord *rec,
-					unsigned long *scanned)
+						gfp_t gfp_mask, bool noswap,
+						struct zone *zone,
+						unsigned long *nr_scanned)
 {
 	struct scan_control sc = {
 		.nr_scanned = 0,
@@ -2326,9 +2311,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 		.may_swap = !noswap,
 		.order = 0,
 		.mem_cgroup = mem,
-		.memcg_record = rec,
 	};
-	ktime_t start, end;
 
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
@@ -2337,7 +2320,6 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						      sc.may_writepage,
 						      sc.gfp_mask);
 
-	start = ktime_get();
 	/*
 	 * NOTE: Although we can get the priority field, using it
 	 * here is not a good idea, since it limits the pages we can scan.
@@ -2346,25 +2328,19 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 	 * the priority and make it zero.
 	 */
 	shrink_zone(0, zone, &sc);
-	end = ktime_get();
-
-	if (rec)
-		rec->elapsed += ktime_to_ns(ktime_sub(end, start));
-	*scanned = sc.nr_scanned;
 
 	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
 
+	*nr_scanned = sc.nr_scanned;
 	return sc.nr_reclaimed;
 }
 
 unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 					   gfp_t gfp_mask,
-					   bool noswap,
-					   struct memcg_scanrecord *rec)
+					   bool noswap)
 {
 	struct zonelist *zonelist;
 	unsigned long nr_reclaimed;
-	ktime_t start, end;
 	int nid;
 	struct scan_control sc = {
 		.may_writepage = !laptop_mode,
@@ -2373,7 +2349,6 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.order = 0,
 		.mem_cgroup = mem_cont,
-		.memcg_record = rec,
 		.nodemask = NULL, /* we don't care the placement */
 		.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 				(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK),
@@ -2382,7 +2357,6 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 		.gfp_mask = sc.gfp_mask,
 	};
 
-	start = ktime_get();
 	/*
 	 * Unlike direct reclaim via alloc_pages(), memcg's reclaim doesn't
 	 * take care of from where we get pages. So the node where we start the
@@ -2397,9 +2371,6 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 					    sc.gfp_mask);
 
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc, &shrink);
-	end = ktime_get();
-	if (rec)
-		rec->elapsed += ktime_to_ns(ktime_sub(end, start));
 
 	trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
