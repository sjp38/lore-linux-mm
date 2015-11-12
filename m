Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9214C6B0266
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 23:33:16 -0500 (EST)
Received: by ioc74 with SMTP id 74so54346560ioc.2
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 20:33:16 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id q88si15557956ioi.175.2015.11.11.20.32.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 11 Nov 2015 20:33:04 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3 17/17] mm: add knob to tune lazyfreeing
Date: Thu, 12 Nov 2015 13:33:13 +0900
Message-Id: <1447302793-5376-18-git-send-email-minchan@kernel.org>
In-Reply-To: <1447302793-5376-1-git-send-email-minchan@kernel.org>
References: <1447302793-5376-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Minchan Kim <minchan@kernel.org>

MADV_FREEed page's hotness is very arguble.
Someone think it's hot while others are it's cold.

Quote from Shaohua
"
My main concern is the policy how we should treat the FREE pages. Moving it to
inactive lru is definitionly a good start, I'm wondering if it's enough. The
MADV_FREE increases memory pressure and cause unnecessary reclaim because of
the lazy memory free. While MADV_FREE is intended to be a better replacement of
MADV_DONTNEED, MADV_DONTNEED doesn't have the memory pressure issue as it free
memory immediately. So I hope the MADV_FREE doesn't have impact on memory
pressure too. I'm thinking of adding an extra lru list and wartermark for this
to make sure FREE pages can be freed before system wide page reclaim. As you
said, this is arguable, but I hope we can discuss about this issue more.
"

Quote from me
"
It seems the divergence comes from MADV_FREE is *replacement* of MADV_DONTNEED.
But I don't think so. If we could discard MADV_FREEed page *anytime*, I agree
but it's not true because the page would be dirty state when VM want to reclaim.

I'm also against with your's suggestion which let's discard FREEed page before
system wide page reclaim because system would have lots of clean cold page
caches or anonymous pages. In such case, reclaiming of them would be better.
Yeb, it's really workload-dependent so we might need some heuristic which is
normally what we want to avoid.

Having said that, I agree with you we could do better than the deactivation
and frankly speaking, I'm thinking of another LRU list(e.g. tentatively named
"ezreclaim LRU list"). What I have in mind is to age (anon|file|ez)
fairly. IOW, I want to percolate ez-LRU list reclaiming into get_scan_count.
When the MADV_FREE is called, we could move hinted pages from anon-LRU to
ez-LRU and then If VM find to not be able to discard a page in ez-LRU,
it could promote it to acive-anon-LRU which would be very natural aging
concept because it mean someone touches the page recenlty.
With that, I don't want to bias one side and don't want to add some knob for
tuning the heuristic but let's rely on common fair aging scheme of VM.
"

Quote from Johannes
"
thread 1:
Even if we're wrong about the aging of those MADV_FREE pages, their
contents are invalidated; they can be discarded freely, and restoring
them is a mere GFP_ZERO allocation. All other anonymous pages have to
be written to disk, and potentially be read back.

[ Arguably, MADV_FREE pages should even be reclaimed before inactive
  page cache. It's the same cost to discard both types of pages, but
  restoring page cache involves IO. ]

It probably makes sense to stop thinking about them as anonymous pages
entirely at this point when it comes to aging. They're really not. The
LRU lists are split to differentiate access patterns and cost of page
stealing (and restoring). From that angle, MADV_FREE pages really have
nothing in common with in-use anonymous pages, and so they shouldn't
be on the same LRU list.

thread:2
What about them is hot? They contain garbage, you have to write to
them before you can use them. Granted, you might have to refetch
cachelines if you don't do cacheline-aligned populating writes, but
you can do a lot of them before it's more expensive than doing IO.

"

Quote from Daniel
"
thread:1
Keep in mind that this is memory the kernel wouldn't be getting back at
all if the allocator wasn't going out of the way to purge it, and they
aren't going to go out of their way to purge it if it means the kernel
is going to steal the pages when there isn't actually memory pressure.

An allocator would be using MADV_DONTNEED if it didn't expect that the
pages were going to be used against shortly. MADV_FREE indicates that it
has time to inform the kernel that they're unused but they could still
be very hot.

thread:2
It's hot because applications churn through memory via the allocator.

Drop the pages and the application is now churning through page faults
and zeroing rather than simply reusing memory. It's not something that
may happen, it *will* happen. A page in the page cache *may* be reused,
but often won't be, especially when the I/O patterns don't line up well
with the way it works.

The whole point of the feature is not requiring the allocator to have
elaborate mechanisms for aging pages and throttling purging. That ends
up resulting in lots of memory held by userspace where the kernel can't
reclaim it under memory pressure. If it's dropped before page cache, it
isn't going to be able to replace any of that logic in allocators.

The page cache is speculative. Page caching by allocators is not really
speculative. Using MADV_FREE on the pages at all is speculative. The
memory is probably going to be reused fairly soon (unless the process
exits, and then it doesn't matter), but purging will end up reducing
memory usage for the portions that aren't.

It would be a different story for a full unpinning/pinning feature since
that would have other use cases (speculative caches), but this is really
only useful in allocators.
"
You could read all thread from https://lkml.org/lkml/2015/11/4/51

Yeah, with arguble issue and there is no one decision, I think it
means we should provide the knob "lazyfreeness"(I hope someone
give better naming).

It's similar to swapppiness so higher values will discard MADV_FREE
pages agreessively. If memory pressure happens and system works with
DEF_PRIOIRTY(ex, clean cold caches), VM doesn't discard any hinted
pages until the scanning priority is increased.

If memory pressure is higher(ie, the priority is not DEF_PRIORITY),
it scans

	nr_to_reclaim * priority * lazyfreensss(def: 20) / 50

If system has low free memory and file cache, it start to discard
MADV_FREEed pages unconditionally even though user set lazyfreeness to 0.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 Documentation/sysctl/vm.txt | 13 +++++++++
 drivers/base/node.c         |  4 +--
 fs/proc/meminfo.c           |  4 +--
 include/linux/memcontrol.h  |  1 +
 include/linux/mmzone.h      |  9 +++---
 include/linux/swap.h        | 15 ++++++++++
 kernel/sysctl.c             |  9 ++++++
 mm/memcontrol.c             | 32 +++++++++++++++++++++-
 mm/vmscan.c                 | 67 ++++++++++++++++++++++++++++-----------------
 mm/vmstat.c                 |  2 +-
 10 files changed, 121 insertions(+), 35 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index a4482fceacec..c1dc63381f2c 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -56,6 +56,7 @@ files can be found in mm/swap.c.
 - percpu_pagelist_fraction
 - stat_interval
 - swappiness
+- lazyfreeness
 - user_reserve_kbytes
 - vfs_cache_pressure
 - zone_reclaim_mode
@@ -737,6 +738,18 @@ The default value is 60.
 
 ==============================================================
 
+lazyfreeness
+
+This control is used to define how aggressive the kernel will discard
+MADV_FREE hinted pages.  Higher values will increase agressiveness,
+lower values decrease the amount of discarding.  A value of 0 instructs
+the kernel not to initiate discarding until the amount of free and
+file-backed pages is less than the high water mark in a zone.
+
+The default value is 20.
+
+==============================================================
+
 - user_reserve_kbytes
 
 When overcommit_memory is set to 2, "never overcommit" mode, reserve
diff --git a/drivers/base/node.c b/drivers/base/node.c
index f7a1f2107b43..3b0bf1b78b2e 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -69,8 +69,8 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       "Node %d Inactive(anon): %8lu kB\n"
 		       "Node %d Active(file):   %8lu kB\n"
 		       "Node %d Inactive(file): %8lu kB\n"
-		       "Node %d Unevictable:    %8lu kB\n"
 		       "Node %d LazyFree:	%8lu kB\n"
+		       "Node %d Unevictable:    %8lu kB\n"
 		       "Node %d Mlocked:        %8lu kB\n",
 		       nid, K(i.totalram),
 		       nid, K(i.freeram),
@@ -83,8 +83,8 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       nid, K(node_page_state(nid, NR_INACTIVE_ANON)),
 		       nid, K(node_page_state(nid, NR_ACTIVE_FILE)),
 		       nid, K(node_page_state(nid, NR_INACTIVE_FILE)),
-		       nid, K(node_page_state(nid, NR_UNEVICTABLE)),
 		       nid, K(node_page_state(nid, NR_LZFREE)),
+		       nid, K(node_page_state(nid, NR_UNEVICTABLE)),
 		       nid, K(node_page_state(nid, NR_MLOCK)));
 
 #ifdef CONFIG_HIGHMEM
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 3444f7c4e0b6..f47e6a5aa2e5 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -101,8 +101,8 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		"Inactive(anon): %8lu kB\n"
 		"Active(file):   %8lu kB\n"
 		"Inactive(file): %8lu kB\n"
-		"Unevictable:    %8lu kB\n"
 		"LazyFree:	 %8lu kB\n"
+		"Unevictable:    %8lu kB\n"
 		"Mlocked:        %8lu kB\n"
 #ifdef CONFIG_HIGHMEM
 		"HighTotal:      %8lu kB\n"
@@ -159,8 +159,8 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		K(pages[LRU_INACTIVE_ANON]),
 		K(pages[LRU_ACTIVE_FILE]),
 		K(pages[LRU_INACTIVE_FILE]),
-		K(pages[LRU_UNEVICTABLE]),
 		K(pages[LRU_LZFREE]),
+		K(pages[LRU_UNEVICTABLE]),
 		K(global_page_state(NR_MLOCK)),
 #ifdef CONFIG_HIGHMEM
 		K(i.totalhigh),
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 3e3318ddfc0e..5522ff733506 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -210,6 +210,7 @@ struct mem_cgroup {
 	int		under_oom;
 
 	int	swappiness;
+	int	lzfreeness;
 	/* OOM-Killer disable */
 	int		oom_kill_disable;
 
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 1aaa436da0d5..cca514a9701d 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -120,8 +120,8 @@ enum zone_stat_item {
 	NR_ACTIVE_ANON,		/*  "     "     "   "       "         */
 	NR_INACTIVE_FILE,	/*  "     "     "   "       "         */
 	NR_ACTIVE_FILE,		/*  "     "     "   "       "         */
-	NR_UNEVICTABLE,		/*  "     "     "   "       "         */
 	NR_LZFREE,		/*  "     "     "   "       "         */
+	NR_UNEVICTABLE,		/*  "     "     "   "       "         */
 	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
 	NR_ANON_PAGES,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
@@ -179,14 +179,15 @@ enum lru_list {
 	LRU_ACTIVE_ANON = LRU_BASE + LRU_ACTIVE,
 	LRU_INACTIVE_FILE = LRU_BASE + LRU_FILE,
 	LRU_ACTIVE_FILE = LRU_BASE + LRU_FILE + LRU_ACTIVE,
-	LRU_UNEVICTABLE,
 	LRU_LZFREE,
+	LRU_UNEVICTABLE,
 	NR_LRU_LISTS
 };
 
 #define for_each_lru(lru) for (lru = 0; lru < NR_LRU_LISTS; lru++)
-
-#define for_each_evictable_lru(lru) for (lru = 0; lru <= LRU_ACTIVE_FILE; lru++)
+#define for_each_anon_file_lru(lru) \
+		for (lru = 0; lru <= LRU_ACTIVE_FILE; lru++)
+#define for_each_evictable_lru(lru) for (lru = 0; lru <= LRU_LZFREE; lru++)
 
 static inline int is_file_lru(enum lru_list lru)
 {
diff --git a/include/linux/swap.h b/include/linux/swap.h
index f0310eeab3ec..73bcdc9d0e88 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -330,6 +330,7 @@ extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						unsigned long *nr_scanned);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
+extern int vm_lazyfreeness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
 extern unsigned long vm_total_pages;
 
@@ -361,11 +362,25 @@ static inline int mem_cgroup_swappiness(struct mem_cgroup *memcg)
 	return memcg->swappiness;
 }
 
+static inline int mem_cgroup_lzfreeness(struct mem_cgroup *memcg)
+{
+	/* root ? */
+	if (mem_cgroup_disabled() || !memcg->css.parent)
+		return vm_lazyfreeness;
+
+	return memcg->lzfreeness;
+}
+
 #else
 static inline int mem_cgroup_swappiness(struct mem_cgroup *mem)
 {
 	return vm_swappiness;
 }
+
+static inline int mem_cgroup_lzfreeness(struct mem_cgroup *mem)
+{
+	return vm_lazyfreeness;
+}
 #endif
 #ifdef CONFIG_MEMCG_SWAP
 extern void mem_cgroup_swapout(struct page *page, swp_entry_t entry);
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index e69201d8094e..2496b10c08e9 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1268,6 +1268,15 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &zero,
 		.extra2		= &one_hundred,
 	},
+	{
+		.procname	= "lazyfreeness",
+		.data		= &vm_lazyfreeness,
+		.maxlen		= sizeof(vm_lazyfreeness),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &one_hundred,
+	},
 #ifdef CONFIG_HUGETLB_PAGE
 	{
 		.procname	= "nr_hugepages",
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1dc599ce1bcb..5bdbe2a20dc0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -108,8 +108,8 @@ static const char * const mem_cgroup_lru_names[] = {
 	"active_anon",
 	"inactive_file",
 	"active_file",
-	"unevictable",
 	"lazyfree",
+	"unevictable",
 };
 
 #define THRESHOLDS_EVENTS_TARGET 128
@@ -3288,6 +3288,30 @@ static int mem_cgroup_swappiness_write(struct cgroup_subsys_state *css,
 	return 0;
 }
 
+static u64 mem_cgroup_lzfreeness_read(struct cgroup_subsys_state *css,
+				      struct cftype *cft)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+
+	return mem_cgroup_lzfreeness(memcg);
+}
+
+static int mem_cgroup_lzfreeness_write(struct cgroup_subsys_state *css,
+				       struct cftype *cft, u64 val)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+
+	if (val > 100)
+		return -EINVAL;
+
+	if (css->parent)
+		memcg->lzfreeness = val;
+	else
+		vm_lazyfreeness = val;
+
+	return 0;
+}
+
 static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
 {
 	struct mem_cgroup_threshold_ary *t;
@@ -4085,6 +4109,11 @@ static struct cftype mem_cgroup_legacy_files[] = {
 		.write_u64 = mem_cgroup_swappiness_write,
 	},
 	{
+		.name = "lazyfreeness",
+		.read_u64 = mem_cgroup_lzfreeness_read,
+		.write_u64 = mem_cgroup_lzfreeness_write,
+	},
+	{
 		.name = "move_charge_at_immigrate",
 		.read_u64 = mem_cgroup_move_charge_read,
 		.write_u64 = mem_cgroup_move_charge_write,
@@ -4305,6 +4334,7 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	memcg->use_hierarchy = parent->use_hierarchy;
 	memcg->oom_kill_disable = parent->oom_kill_disable;
 	memcg->swappiness = mem_cgroup_swappiness(parent);
+	memcg->lzfreeness = mem_cgroup_lzfreeness(parent);
 
 	if (parent->use_hierarchy) {
 		page_counter_init(&memcg->memory, &parent->memory);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index cd65db9d3004..f1abc8a6ca31 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -141,6 +141,10 @@ struct scan_control {
  */
 int vm_swappiness = 60;
 /*
+ * From 0 .. 100.  Higher means more lazy freeing.
+ */
+int vm_lazyfreeness = 20;
+/*
  * The total number of pages which are beyond the high watermark within all
  * zones.
  */
@@ -2012,10 +2016,11 @@ enum scan_balance {
  *
  * nr[0] = anon inactive pages to scan; nr[1] = anon active pages to scan
  * nr[2] = file inactive pages to scan; nr[3] = file active pages to scan
+ * nr[4] = lazy free pages to scan;
  */
 static void get_scan_count(struct lruvec *lruvec, int swappiness,
-			   struct scan_control *sc, unsigned long *nr,
-			   unsigned long *lru_pages)
+			int lzfreeness, struct scan_control *sc,
+			unsigned long *nr, unsigned long *lru_pages)
 {
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 	u64 fraction[2];
@@ -2023,12 +2028,13 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
 	struct zone *zone = lruvec_zone(lruvec);
 	unsigned long anon_prio, file_prio;
 	enum scan_balance scan_balance;
-	unsigned long anon, file;
+	unsigned long anon, file, lzfree;
 	bool force_scan = false;
 	unsigned long ap, fp;
 	enum lru_list lru;
 	bool some_scanned;
 	int pass;
+	unsigned long scan_lzfree = 0;
 
 	/*
 	 * If the zone or memcg is small, nr[l] can be 0.  This
@@ -2166,7 +2172,7 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
 	/* Only use force_scan on second pass. */
 	for (pass = 0; !some_scanned && pass < 2; pass++) {
 		*lru_pages = 0;
-		for_each_evictable_lru(lru) {
+		for_each_anon_file_lru(lru) {
 			int file = is_file_lru(lru);
 			unsigned long size;
 			unsigned long scan;
@@ -2212,6 +2218,28 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
 			some_scanned |= !!scan;
 		}
 	}
+
+	lzfree = get_lru_size(lruvec, LRU_LZFREE);
+	if (lzfree) {
+		scan_lzfree = sc->nr_to_reclaim *
+				(DEF_PRIORITY - sc->priority);
+		scan_lzfree = div64_u64(scan_lzfree *
+					lzfreeness, 50);
+		if (!scan_lzfree) {
+			unsigned long zonefile, zonefree;
+
+			zonefree = zone_page_state(zone, NR_FREE_PAGES);
+			zonefile = zone_page_state(zone, NR_ACTIVE_FILE) +
+				zone_page_state(zone, NR_INACTIVE_FILE);
+			if (unlikely(zonefile + zonefree <=
+					high_wmark_pages(zone))) {
+				scan_lzfree = get_lru_size(lruvec,
+						LRU_LZFREE) >> sc->priority;
+			}
+		}
+	}
+
+	nr[LRU_LZFREE] = min(scan_lzfree, lzfree);
 }
 
 #ifdef CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH
@@ -2235,23 +2263,22 @@ static inline void init_tlb_ubc(void)
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
 static void shrink_lruvec(struct lruvec *lruvec, int swappiness,
-			  struct scan_control *sc, unsigned long *lru_pages)
+			int lzfreeness, struct scan_control *sc,
+			unsigned long *lru_pages)
 {
 	unsigned long nr[NR_LRU_LISTS];
 	unsigned long targets[NR_LRU_LISTS];
 	unsigned long nr_to_scan;
-	unsigned long nr_to_scan_lzfree;
 	enum lru_list lru;
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
 	struct blk_plug plug;
 	bool scan_adjusted;
 
-	get_scan_count(lruvec, swappiness, sc, nr, lru_pages);
+	get_scan_count(lruvec, swappiness, lzfreeness, sc, nr, lru_pages);
 
 	/* Record the original scan target for proportional adjustments later */
 	memcpy(targets, nr, sizeof(nr));
-	nr_to_scan_lzfree = get_lru_size(lruvec, LRU_LZFREE);
 
 	/*
 	 * Global reclaiming within direct reclaim at DEF_PRIORITY is a normal
@@ -2269,22 +2296,9 @@ static void shrink_lruvec(struct lruvec *lruvec, int swappiness,
 
 	init_tlb_ubc();
 
-	while (nr_to_scan_lzfree) {
-		nr_to_scan = min(nr_to_scan_lzfree, SWAP_CLUSTER_MAX);
-		nr_to_scan_lzfree -= nr_to_scan;
-
-		nr_reclaimed += shrink_inactive_list(nr_to_scan, lruvec,
-						sc, LRU_LZFREE);
-	}
-
-	if (nr_reclaimed >= nr_to_reclaim) {
-		sc->nr_reclaimed += nr_reclaimed;
-		return;
-	}
-
 	blk_start_plug(&plug);
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
-					nr[LRU_INACTIVE_FILE]) {
+		nr[LRU_INACTIVE_FILE] || nr[LRU_LZFREE]) {
 		unsigned long nr_anon, nr_file, percentage;
 		unsigned long nr_scanned;
 
@@ -2466,7 +2480,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 			unsigned long lru_pages;
 			unsigned long scanned;
 			struct lruvec *lruvec;
-			int swappiness;
+			int swappiness, lzfreeness;
 
 			if (mem_cgroup_low(root, memcg)) {
 				if (!sc->may_thrash)
@@ -2476,9 +2490,11 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 
 			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
 			swappiness = mem_cgroup_swappiness(memcg);
+			lzfreeness = mem_cgroup_lzfreeness(memcg);
 			scanned = sc->nr_scanned;
 
-			shrink_lruvec(lruvec, swappiness, sc, &lru_pages);
+			shrink_lruvec(lruvec, swappiness, lzfreeness,
+					sc, &lru_pages);
 			zone_lru_pages += lru_pages;
 
 			if (memcg && is_classzone)
@@ -2944,6 +2960,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
 	};
 	struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
 	int swappiness = mem_cgroup_swappiness(memcg);
+	int lzfreeness = mem_cgroup_lzfreeness(memcg);
 	unsigned long lru_pages;
 
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
@@ -2960,7 +2977,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
 	 * will pick up pages from other mem cgroup's as well. We hack
 	 * the priority and make it zero.
 	 */
-	shrink_lruvec(lruvec, swappiness, &sc, &lru_pages);
+	shrink_lruvec(lruvec, swappiness, lzfreeness, &sc, &lru_pages);
 
 	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index df95d9473bba..43effd0374d9 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -703,8 +703,8 @@ const char * const vmstat_text[] = {
 	"nr_active_anon",
 	"nr_inactive_file",
 	"nr_active_file",
-	"nr_unevictable",
 	"nr_lazyfree",
+	"nr_unevictable",
 	"nr_mlock",
 	"nr_anon_pages",
 	"nr_mapped",
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
