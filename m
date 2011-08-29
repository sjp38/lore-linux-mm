Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id DB1B2900137
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 11:51:24 -0400 (EDT)
Date: Mon, 29 Aug 2011 17:51:13 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch] Revert "memcg: add memory.vmscan_stat"
Message-ID: <20110829155113.GA21661@redhat.com>
References: <20110722171540.74eb9aa7.kamezawa.hiroyu@jp.fujitsu.com>
 <20110808124333.GA31739@redhat.com>
 <20110809083345.46cbc8de.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110809083345.46cbc8de.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Andrew Brestic <abrestic@google.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 09, 2011 at 08:33:45AM +0900, KAMEZAWA Hiroyuki wrote:
> On Mon, 8 Aug 2011 14:43:33 +0200
> Johannes Weiner <jweiner@redhat.com> wrote:
> 
> > On Fri, Jul 22, 2011 at 05:15:40PM +0900, KAMEZAWA Hiroyuki wrote:
> > > +When under_hierarchy is added in the tail, the number indicates the
> > > +total memcg scan of its children and itself.
> > 
> > In your implementation, statistics are only accounted to the memcg
> > triggering the limit and the respectively scanned memcgs.
> > 
> > Consider the following setup:
> > 
> >         A
> >        / \
> >       B   C
> >      /
> >     D
> > 
> > If D tries to charge but hits the limit of A, then B's hierarchy
> > counters do not reflect the reclaim activity resulting in D.
> > 
> yes, as I expected.

Andrew,

with a flawed design, the author unwilling to fix it, and two NAKs,
can we please revert this before the release?

This only got in silently because KAMEZAWA-san dropped all parties
involed in the discussions around this change from the Cc list of
subsequent submissions.

---
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch] Revert "memcg: add memory.vmscan_stat"

This reverts commit 82f9d486e59f588c7d100865c36510644abda356.

The implementation of per-memcg reclaim statistics violates how memcg
hierarchies usually behave: hierarchically.

The reclaim statistics are accounted to child memcgs and the parent
hitting the limit, but not to hierarchy levels in between.  Usually,
hierarchical statistics are perfectly recursive, with each level
representing the sum of itself and all its children.

Since this exports statistics to userspace, this may lead to confusion
and problems with changing things after the release, so revert it now,
we can try again later.

Conflicts:

	mm/vmscan.c

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
---
 Documentation/cgroups/memory.txt |   85 +------------------
 include/linux/memcontrol.h       |   19 ----
 include/linux/swap.h             |    6 ++
 mm/memcontrol.c                  |  172 ++------------------------------------
 mm/vmscan.c                      |   39 +--------
 5 files changed, 18 insertions(+), 303 deletions(-)

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
index 3b535db..343bd76 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -39,16 +39,6 @@ extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
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
@@ -127,15 +117,6 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page);
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
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 14d6249..c71f84b 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -252,6 +252,12 @@ static inline void lru_cache_add_file(struct page *page)
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask, nodemask_t *mask);
 extern int __isolate_lru_page(struct page *page, int mode, int file);
+extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
+						  gfp_t gfp_mask, bool noswap);
+extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
+						gfp_t gfp_mask, bool noswap,
+						struct zone *zone,
+						unsigned long *nr_scanned);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ebd1e86..3508777 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -204,50 +204,6 @@ struct mem_cgroup_eventfd_list {
 static void mem_cgroup_threshold(struct mem_cgroup *mem);
 static void mem_cgroup_oom_notify(struct mem_cgroup *mem);
 
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
@@ -313,8 +269,7 @@ struct mem_cgroup {
 
 	/* For oom notifier event fd */
 	struct list_head oom_notify;
-	/* For recording LRU-scan statistics */
-	struct scanstat scanstat;
+
 	/*
 	 * Should we move charges of a task when a task is moved into this
 	 * mem_cgroup ? And what type of charges should we move ?
@@ -1678,44 +1633,6 @@ bool mem_cgroup_reclaimable(struct mem_cgroup *mem, bool noswap)
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
-	struct mem_cgroup *mem;
-	int context = rec->context;
-
-	if (context >= NR_SCAN_CONTEXT)
-		return;
-
-	mem = rec->mem;
-	spin_lock(&mem->scanstat.lock);
-	__mem_cgroup_record_scanstat(mem->scanstat.stats[context], rec);
-	spin_unlock(&mem->scanstat.lock);
-
-	mem = rec->root;
-	spin_lock(&mem->scanstat.lock);
-	__mem_cgroup_record_scanstat(mem->scanstat.rootstats[context], rec);
-	spin_unlock(&mem->scanstat.lock);
-}
-
 /*
  * Scan the hierarchy if needed to reclaim memory. We remember the last child
  * we reclaimed from, so that we don't end up penalizing one child extensively
@@ -1740,9 +1657,8 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 	bool noswap = reclaim_options & MEM_CGROUP_RECLAIM_NOSWAP;
 	bool shrink = reclaim_options & MEM_CGROUP_RECLAIM_SHRINK;
 	bool check_soft = reclaim_options & MEM_CGROUP_RECLAIM_SOFT;
-	struct memcg_scanrecord rec;
 	unsigned long excess;
-	unsigned long scanned;
+	unsigned long nr_scanned;
 
 	excess = res_counter_soft_limit_excess(&root_mem->res) >> PAGE_SHIFT;
 
@@ -1750,15 +1666,6 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 	if (!check_soft && !shrink && root_mem->memsw_is_minimum)
 		noswap = true;
 
-	if (shrink)
-		rec.context = SCAN_BY_SHRINK;
-	else if (check_soft)
-		rec.context = SCAN_BY_SYSTEM;
-	else
-		rec.context = SCAN_BY_LIMIT;
-
-	rec.root = root_mem;
-
 	while (1) {
 		victim = mem_cgroup_select_victim(root_mem);
 		if (victim == root_mem) {
@@ -1799,23 +1706,14 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
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
@@ -3854,18 +3752,14 @@ try_to_free:
 	/* try to free all pages in this cgroup */
 	shrink = 1;
 	while (nr_retries && mem->res.usage > 0) {
-		struct memcg_scanrecord rec;
 		int progress;
 
 		if (signal_pending(current)) {
 			ret = -EINTR;
 			goto out;
 		}
-		rec.context = SCAN_BY_SHRINK;
-		rec.mem = mem;
-		rec.root = mem;
 		progress = try_to_free_mem_cgroup_pages(mem, GFP_KERNEL,
-						false, &rec);
+						false);
 		if (!progress) {
 			nr_retries--;
 			/* maybe some writeback is necessary */
@@ -4709,54 +4603,6 @@ static int mem_control_numa_stat_open(struct inode *unused, struct file *file)
 }
 #endif /* CONFIG_NUMA */
 
-static int mem_cgroup_vmscan_stat_read(struct cgroup *cgrp,
-				struct cftype *cft,
-				struct cgroup_map_cb *cb)
-{
-	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
-	char string[64];
-	int i;
-
-	for (i = 0; i < NR_SCANSTATS; i++) {
-		strcpy(string, scanstat_string[i]);
-		strcat(string, SCANSTAT_WORD_LIMIT);
-		cb->fill(cb, string,  mem->scanstat.stats[SCAN_BY_LIMIT][i]);
-	}
-
-	for (i = 0; i < NR_SCANSTATS; i++) {
-		strcpy(string, scanstat_string[i]);
-		strcat(string, SCANSTAT_WORD_SYSTEM);
-		cb->fill(cb, string,  mem->scanstat.stats[SCAN_BY_SYSTEM][i]);
-	}
-
-	for (i = 0; i < NR_SCANSTATS; i++) {
-		strcpy(string, scanstat_string[i]);
-		strcat(string, SCANSTAT_WORD_LIMIT);
-		strcat(string, SCANSTAT_WORD_HIERARCHY);
-		cb->fill(cb, string,  mem->scanstat.rootstats[SCAN_BY_LIMIT][i]);
-	}
-	for (i = 0; i < NR_SCANSTATS; i++) {
-		strcpy(string, scanstat_string[i]);
-		strcat(string, SCANSTAT_WORD_SYSTEM);
-		strcat(string, SCANSTAT_WORD_HIERARCHY);
-		cb->fill(cb, string,  mem->scanstat.rootstats[SCAN_BY_SYSTEM][i]);
-	}
-	return 0;
-}
-
-static int mem_cgroup_reset_vmscan_stat(struct cgroup *cgrp,
-				unsigned int event)
-{
-	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
-
-	spin_lock(&mem->scanstat.lock);
-	memset(&mem->scanstat.stats, 0, sizeof(mem->scanstat.stats));
-	memset(&mem->scanstat.rootstats, 0, sizeof(mem->scanstat.rootstats));
-	spin_unlock(&mem->scanstat.lock);
-	return 0;
-}
-
-
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
@@ -4827,11 +4673,6 @@ static struct cftype mem_cgroup_files[] = {
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
@@ -5095,7 +4936,6 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	atomic_set(&mem->refcnt, 1);
 	mem->move_charge_at_immigrate = 0;
 	mutex_init(&mem->thresholds_lock);
-	spin_lock_init(&mem->scanstat.lock);
 	return &mem->css;
 free_out:
 	__mem_cgroup_free(mem);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 04bb6ae..6588746 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -105,7 +105,6 @@ struct scan_control {
 
 	/* Which cgroup do we reclaim from */
 	struct mem_cgroup *mem_cgroup;
-	struct memcg_scanrecord *memcg_record;
 
 	/*
 	 * Nodemask of nodes allowed by the caller. If NULL, all nodes
@@ -1349,8 +1348,6 @@ putback_lru_pages(struct zone *zone, struct scan_control *sc,
 			int file = is_file_lru(lru);
 			int numpages = hpage_nr_pages(page);
 			reclaim_stat->recent_rotated[file] += numpages;
-			if (!scanning_global_lru(sc))
-				sc->memcg_record->nr_rotated[file] += numpages;
 		}
 		if (!pagevec_add(&pvec, page)) {
 			spin_unlock_irq(&zone->lru_lock);
@@ -1394,10 +1391,6 @@ static noinline_for_stack void update_isolated_counts(struct zone *zone,
 
 	reclaim_stat->recent_scanned[0] += *nr_anon;
 	reclaim_stat->recent_scanned[1] += *nr_file;
-	if (!scanning_global_lru(sc)) {
-		sc->memcg_record->nr_scanned[0] += *nr_anon;
-		sc->memcg_record->nr_scanned[1] += *nr_file;
-	}
 }
 
 /*
@@ -1511,9 +1504,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 		nr_reclaimed += shrink_page_list(&page_list, zone, sc);
 	}
 
-	if (!scanning_global_lru(sc))
-		sc->memcg_record->nr_freed[file] += nr_reclaimed;
-
 	local_irq_disable();
 	if (current_is_kswapd())
 		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
@@ -1613,8 +1603,6 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	}
 
 	reclaim_stat->recent_scanned[file] += nr_taken;
-	if (!scanning_global_lru(sc))
-		sc->memcg_record->nr_scanned[file] += nr_taken;
 
 	__count_zone_vm_events(PGREFILL, zone, pgscanned);
 	if (file)
@@ -1666,8 +1654,6 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	 * get_scan_ratio.
 	 */
 	reclaim_stat->recent_rotated[file] += nr_rotated;
-	if (!scanning_global_lru(sc))
-		sc->memcg_record->nr_rotated[file] += nr_rotated;
 
 	move_active_pages_to_lru(zone, &l_active,
 						LRU_ACTIVE + file * LRU_FILE);
@@ -2253,10 +2239,9 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
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
@@ -2266,9 +2251,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 		.may_swap = !noswap,
 		.order = 0,
 		.mem_cgroup = mem,
-		.memcg_record = rec,
 	};
-	ktime_t start, end;
 
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
@@ -2277,7 +2260,6 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						      sc.may_writepage,
 						      sc.gfp_mask);
 
-	start = ktime_get();
 	/*
 	 * NOTE: Although we can get the priority field, using it
 	 * here is not a good idea, since it limits the pages we can scan.
@@ -2286,25 +2268,19 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
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
@@ -2313,7 +2289,6 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.order = 0,
 		.mem_cgroup = mem_cont,
-		.memcg_record = rec,
 		.nodemask = NULL, /* we don't care the placement */
 		.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 				(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK),
@@ -2322,7 +2297,6 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 		.gfp_mask = sc.gfp_mask,
 	};
 
-	start = ktime_get();
 	/*
 	 * Unlike direct reclaim via alloc_pages(), memcg's reclaim doesn't
 	 * take care of from where we get pages. So the node where we start the
@@ -2337,9 +2311,6 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 					    sc.gfp_mask);
 
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc, &shrink);
-	end = ktime_get();
-	if (rec)
-		rec->elapsed += ktime_to_ns(ktime_sub(end, start));
 
 	trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
 
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
