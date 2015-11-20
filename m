Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id C12986B0262
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 03:03:16 -0500 (EST)
Received: by pacej9 with SMTP id ej9so109229510pac.2
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 00:03:16 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id r134si384904pfr.18.2015.11.20.00.02.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 20 Nov 2015 00:03:00 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v4 16/16] mm: add knob to tune lazyfreeing
Date: Fri, 20 Nov 2015 17:02:48 +0900
Message-Id: <1448006568-16031-17-git-send-email-minchan@kernel.org>
In-Reply-To: <1448006568-16031-1-git-send-email-minchan@kernel.org>
References: <1448006568-16031-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Andy Lutomirski <luto@amacapital.net>, Minchan Kim <minchan@kernel.org>

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
pages agreessively.
In this implementation, lazyfreeness starts from 100 which is max
of swappiness(ie, if you see 40 of /proc/sys/vm/lazyfreeness,
it means 100 + 40). Therefore, lazyfree LRU list always has more
reclaiming pressure than anonymous LRU but same with filecache
pressure when we consider default values(ie, 60 swappiness,
40 lazyfreeness). If user want to reclaim lazyfree LRU first to
prevent other LRU reclaiming, he could set lazyfreeness to above 80
which is double of default lazyfreeness.

There is one exception case. If system has low free memory and
file cache, it start to discard MADV_FREEed pages unconditionally
even though user set lazyfreeness to 0. It's same logic with
swappiness to prevent thrashing.

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 Documentation/sysctl/vm.txt |  13 +++++
 drivers/base/node.c         |   4 +-
 fs/proc/meminfo.c           |   4 +-
 include/linux/memcontrol.h  |   1 +
 include/linux/mmzone.h      |  19 +++++--
 include/linux/swap.h        |  15 +++++
 kernel/sysctl.c             |   9 +++
 mm/memcontrol.c             |  32 ++++++++++-
 mm/vmscan.c                 | 131 +++++++++++++++++++++++++-------------------
 mm/vmstat.c                 |   2 +-
 10 files changed, 162 insertions(+), 68 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index a4482fceacec..e3bcf115cf03 100644
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
+The default value is 40.
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
index 1aaa436da0d5..210184b2dd18 100644
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
@@ -179,20 +179,29 @@ enum lru_list {
 	LRU_ACTIVE_ANON = LRU_BASE + LRU_ACTIVE,
 	LRU_INACTIVE_FILE = LRU_BASE + LRU_FILE,
 	LRU_ACTIVE_FILE = LRU_BASE + LRU_FILE + LRU_ACTIVE,
-	LRU_UNEVICTABLE,
 	LRU_LZFREE,
+	LRU_UNEVICTABLE,
 	NR_LRU_LISTS
 };
 
 #define for_each_lru(lru) for (lru = 0; lru < NR_LRU_LISTS; lru++)
+#define for_each_evictable_lru(lru) for (lru = 0; lru <= LRU_LZFREE; lru++)
 
-#define for_each_evictable_lru(lru) for (lru = 0; lru <= LRU_ACTIVE_FILE; lru++)
-
-static inline int is_file_lru(enum lru_list lru)
+static inline bool is_file_lru(enum lru_list lru)
 {
 	return (lru == LRU_INACTIVE_FILE || lru == LRU_ACTIVE_FILE);
 }
 
+static inline bool is_anon_lru(enum lru_list lru)
+{
+	return (lru == LRU_INACTIVE_ANON || lru == LRU_ACTIVE_ANON);
+}
+
+static inline bool is_lazyfree_lru(enum lru_list lru)
+{
+	return (lru == LRU_LZFREE);
+}
+
 static inline int is_active_lru(enum lru_list lru)
 {
 	return (lru == LRU_ACTIVE_ANON || lru == LRU_ACTIVE_FILE);
diff --git a/include/linux/swap.h b/include/linux/swap.h
index c484339b46b6..252b478a2579 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -331,6 +331,7 @@ extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						unsigned long *nr_scanned);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
+extern int vm_lazyfreeness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
 extern unsigned long vm_total_pages;
 
@@ -362,11 +363,25 @@ static inline int mem_cgroup_swappiness(struct mem_cgroup *memcg)
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
index d9dfd034b963..325b49cedee8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -141,6 +141,10 @@ struct scan_control {
  */
 int vm_swappiness = 60;
 /*
+ * From 0 .. 100.  Higher means more lazy freeing.
+ */
+int vm_lazyfreeness = 40;
+/*
  * The total number of pages which are beyond the high watermark within all
  * zones.
  */
@@ -1989,10 +1993,11 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 }
 
 enum scan_balance {
-	SCAN_EQUAL,
-	SCAN_FRACT,
-	SCAN_ANON,
-	SCAN_FILE,
+	SCAN_EQUAL = (1 << 0),
+	SCAN_FRACT = (1 << 1),
+	SCAN_ANON = (1 << 2),
+	SCAN_FILE = (1 << 3),
+	SCAN_LZFREE = (1 << 4),
 };
 
 /*
@@ -2003,20 +2008,21 @@ enum scan_balance {
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
-	u64 fraction[2];
+	u64 fraction[3];
 	u64 denominator = 0;	/* gcc */
 	struct zone *zone = lruvec_zone(lruvec);
-	unsigned long anon_prio, file_prio;
-	enum scan_balance scan_balance;
-	unsigned long anon, file;
+	unsigned long anon_prio, file_prio, lzfree_prio;
+	enum scan_balance scan_balance = 0;
+	unsigned long anon, file, lzfree;
 	bool force_scan = false;
-	unsigned long ap, fp;
+	unsigned long ap, fp, lp;
 	enum lru_list lru;
 	bool some_scanned;
 	int pass;
@@ -2040,9 +2046,19 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
 	if (!global_reclaim(sc))
 		force_scan = true;
 
+	/*
+	 * If we have lazyfree pages and lzfreeness is enough high,
+	 * scan only lazyfree LRU to prevent to reclaim other pages
+	 * until lazyfree LRU list is empty.
+	 */
+	if (get_lru_size(lruvec, LRU_LZFREE) && lzfreeness >= 80) {
+		scan_balance = SCAN_LZFREE;
+		goto out;
+	}
+
 	/* If we have no swap space, do not bother scanning anon pages. */
 	if (!sc->may_swap || (get_nr_swap_pages() <= 0)) {
-		scan_balance = SCAN_FILE;
+		scan_balance = SCAN_FILE|SCAN_LZFREE;
 		goto out;
 	}
 
@@ -2054,7 +2070,7 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
 	 * too expensive.
 	 */
 	if (!global_reclaim(sc) && !swappiness) {
-		scan_balance = SCAN_FILE;
+		scan_balance = SCAN_FILE|SCAN_LZFREE;
 		goto out;
 	}
 
@@ -2086,7 +2102,7 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
 			   zone_page_state(zone, NR_INACTIVE_FILE);
 
 		if (unlikely(zonefile + zonefree <= high_wmark_pages(zone))) {
-			scan_balance = SCAN_ANON;
+			scan_balance = SCAN_ANON|SCAN_LZFREE;
 			goto out;
 		}
 	}
@@ -2096,7 +2112,7 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
 	 * anything from the anonymous working set right now.
 	 */
 	if (!inactive_file_is_low(lruvec)) {
-		scan_balance = SCAN_FILE;
+		scan_balance = SCAN_FILE|SCAN_LZFREE;
 		goto out;
 	}
 
@@ -2108,6 +2124,7 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
 	 */
 	anon_prio = swappiness;
 	file_prio = 200 - anon_prio;
+	lzfree_prio = 100 + lzfreeness;
 
 	/*
 	 * OK, so we have swap space and a fair amount of page cache
@@ -2125,6 +2142,7 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
 		get_lru_size(lruvec, LRU_INACTIVE_ANON);
 	file  = get_lru_size(lruvec, LRU_ACTIVE_FILE) +
 		get_lru_size(lruvec, LRU_INACTIVE_FILE);
+	lzfree = get_lru_size(lruvec, LRU_LZFREE);
 
 	spin_lock_irq(&zone->lru_lock);
 	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
@@ -2137,6 +2155,11 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
 		reclaim_stat->recent_rotated[1] /= 2;
 	}
 
+	if (unlikely(reclaim_stat->recent_scanned[2] > lzfree / 4)) {
+		reclaim_stat->recent_scanned[2] /= 2;
+		reclaim_stat->recent_rotated[2] /= 2;
+	}
+
 	/*
 	 * The amount of pressure on anon vs file pages is inversely
 	 * proportional to the fraction of recently scanned pages on
@@ -2147,13 +2170,18 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
 
 	fp = file_prio * (reclaim_stat->recent_scanned[1] + 1);
 	fp /= reclaim_stat->recent_rotated[1] + 1;
+
+	lp = lzfree_prio * (reclaim_stat->recent_scanned[2] + 1);
+	lp /= reclaim_stat->recent_rotated[2] + 1;
 	spin_unlock_irq(&zone->lru_lock);
 
 	fraction[0] = ap;
 	fraction[1] = fp;
-	denominator = ap + fp + 1;
+	fraction[2] = lp;
+	denominator = ap + fp + lp + 1;
 out:
 	some_scanned = false;
+
 	/* Only use force_scan on second pass. */
 	for (pass = 0; !some_scanned && pass < 2; pass++) {
 		*lru_pages = 0;
@@ -2168,34 +2196,34 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
 			if (!scan && pass && force_scan)
 				scan = min(size, SWAP_CLUSTER_MAX);
 
-			switch (scan_balance) {
-			case SCAN_EQUAL:
-				/* Scan lists relative to size */
-				break;
-			case SCAN_FRACT:
+			if (scan_balance & SCAN_FRACT) {
 				/*
 				 * Scan types proportional to swappiness and
 				 * their relative recent reclaim efficiency.
 				 */
 				scan = div64_u64(scan * fraction[file],
 							denominator);
-				break;
-			case SCAN_FILE:
-			case SCAN_ANON:
-				/* Scan one type exclusively */
-				if ((scan_balance == SCAN_FILE) != file) {
-					size = 0;
-					scan = 0;
-				}
-				break;
-			default:
-				/* Look ma, no brain */
-				BUG();
+				goto scan;
 			}
 
+			/* Scan lists relative to size */
+			if (scan_balance & SCAN_EQUAL)
+				goto scan;
+
+			if (scan_balance & SCAN_FILE && is_file_lru(lru))
+				goto scan;
+
+			if (scan_balance & SCAN_ANON && is_anon_lru(lru))
+				goto scan;
+
+			if (scan_balance & SCAN_LZFREE &&
+						is_lazyfree_lru(lru))
+				goto scan;
+
+			continue;
+scan:
 			*lru_pages += size;
 			nr[lru] = scan;
-
 			/*
 			 * Skip the second pass and don't force_scan,
 			 * if we found something to scan.
@@ -2226,23 +2254,22 @@ static inline void init_tlb_ubc(void)
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
 static void shrink_lruvec(struct lruvec *lruvec, int swappiness,
-			  struct scan_control *sc, unsigned long *lru_pages)
+			int lzfreeness, struct scan_control *sc,
+			unsigned long *lru_pages)
 {
-	unsigned long nr[NR_LRU_LISTS];
-	unsigned long targets[NR_LRU_LISTS];
+	unsigned long nr[NR_LRU_LISTS] = {0,};
+	unsigned long targets[NR_LRU_LISTS] = {0,};
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
@@ -2260,22 +2287,9 @@ static void shrink_lruvec(struct lruvec *lruvec, int swappiness,
 
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
 
@@ -2457,7 +2471,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 			unsigned long lru_pages;
 			unsigned long scanned;
 			struct lruvec *lruvec;
-			int swappiness;
+			int swappiness, lzfreeness;
 
 			if (mem_cgroup_low(root, memcg)) {
 				if (!sc->may_thrash)
@@ -2467,9 +2481,11 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 
 			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
 			swappiness = mem_cgroup_swappiness(memcg);
+			lzfreeness = mem_cgroup_lzfreeness(memcg);
 			scanned = sc->nr_scanned;
 
-			shrink_lruvec(lruvec, swappiness, sc, &lru_pages);
+			shrink_lruvec(lruvec, swappiness, lzfreeness,
+					sc, &lru_pages);
 			zone_lru_pages += lru_pages;
 
 			if (memcg && is_classzone)
@@ -2935,6 +2951,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
 	};
 	struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
 	int swappiness = mem_cgroup_swappiness(memcg);
+	int lzfreeness = mem_cgroup_lzfreeness(memcg);
 	unsigned long lru_pages;
 
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
@@ -2951,7 +2968,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
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
