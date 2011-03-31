Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B8EB88D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 20:49:00 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [RFC][PATCH] memcg: isolate pages in memcg lru from global lru
Date: Wed, 30 Mar 2011 17:48:18 -0700
Message-Id: <1301532498-20309-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

In memory controller, we do both targeting reclaim and global reclaim. The
later one walks through the global lru which links all the allocated pages
on the system. It breaks the memory isolation since pages are evicted
regardless of their memcg owners. This patch takes pages off global lru
as long as they are added to per-memcg lru.

Memcg and cgroup together provide the solution of memory isolation where
multiple cgroups run in parallel without interfering with each other. In
vm, memory isolation requires changes in both page allocation and page
reclaim. The current memcg provides good user page accounting, but need
more work on the page reclaim.

In an over-committed machine w/ 32G ram, here is the configuration:

cgroup-A/  -- limit_in_bytes = 20G, soft_limit_in_bytes = 15G
cgroup-B/  -- limit_in_bytes = 20G, soft_limit_in_bytes = 15G

1) limit_in_bytes is the hard_limit where process will be throttled or OOM
killed by going over the limit.
2) memory between soft_limit and limit_in_bytes are best-effort. soft_limit
provides "guarantee" in some sense.

Then, it is easy to generate the following senario where:

cgroup-A/  -- usage_in_bytes = 20G
cgroup-B/  -- usage_in_bytes = 12G

The global memory pressure triggers while cgroup-A keep allocating memory. At
this point, pages belongs to cgroup-B can be evicted from global LRU.

We do have per-memcg targeting reclaim including per-memcg background reclaim
and soft_limit reclaim. Both of them need some improvement, and regardless we
still need this patch since it breaks isolation.

Besides, here is to-do list I have on memcg page reclaim and they are sorted.
a) per-memcg background reclaim. to reclaim pages proactively
b) skipping global lru reclaim if soft_limit reclaim does enough work. this is
both for global background reclaim and global ttfp reclaim.
c) improve the soft_limit reclaim to be efficient.
d) isolate pages in memcg from global list since it breaks memory isolation.

I have some basic test on this patch and more tests definitely are needed:

Functional:
two memcgs under root. cgroup-A is reading 20g file with 2g limit,
cgroup-B is running random stuff with 500m limit. Check the counters for
per-memcg lru and global lru, and they should add-up.

1) total file pages
$ cat /proc/meminfo | grep Cache
Cached:          6032128 kB

2) file lru on global lru
$ cat /proc/vmstat | grep file
nr_inactive_file 0
nr_active_file 963131

3) file lru on root cgroup
$ cat /dev/cgroup/memory.stat | grep file
inactive_file 0
active_file 0

4) file lru on cgroup-A
$ cat /dev/cgroup/A/memory.stat | grep file
inactive_file 2145759232
active_file 0

5) file lru on cgroup-B
$ cat /dev/cgroup/B/memory.stat | grep file
inactive_file 401408
active_file 143360

Performance:
run page fault test(pft) with 16 thread on faulting in 15G anon pages
in 16G cgroup. There is no regression noticed on "flt/cpu/s"

+-------------------------------------------------------------------------+
    N           Min           Max        Median           Avg        Stddev
x  10     16682.962     17344.027     16913.524     16928.812      166.5362
+   9     16455.468     16961.779     16867.569      16802.83     157.43279
No difference proven at 95.0% confidence

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h  |   17 ++++++-----
 include/linux/mm_inline.h   |   24 ++++++++++------
 include/linux/page_cgroup.h |    1 -
 mm/memcontrol.c             |   60 +++++++++++++++++++++---------------------
 mm/page_cgroup.c            |    1 -
 mm/swap.c                   |   12 +++++++-
 mm/vmscan.c                 |   22 +++++++++++----
 7 files changed, 80 insertions(+), 57 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 5a5ce70..587a41e 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -60,11 +60,11 @@ extern void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *ptr);
 
 extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 					gfp_t gfp_mask);
-extern void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru);
-extern void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru);
+extern bool mem_cgroup_add_lru_list(struct page *page, enum lru_list lru);
+extern bool mem_cgroup_del_lru_list(struct page *page, enum lru_list lru);
 extern void mem_cgroup_rotate_reclaimable_page(struct page *page);
 extern void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru);
-extern void mem_cgroup_del_lru(struct page *page);
+extern bool mem_cgroup_del_lru(struct page *page);
 extern void mem_cgroup_move_lists(struct page *page,
 				  enum lru_list from, enum lru_list to);
 
@@ -207,13 +207,14 @@ static inline int mem_cgroup_shmem_charge_fallback(struct page *page,
 	return 0;
 }
 
-static inline void mem_cgroup_add_lru_list(struct page *page, int lru)
+static inline bool mem_cgroup_add_lru_list(struct page *page, int lru)
 {
+	return false;
 }
 
-static inline void mem_cgroup_del_lru_list(struct page *page, int lru)
+static inline bool mem_cgroup_del_lru_list(struct page *page, int lru)
 {
-	return ;
+	return false;
 }
 
 static inline inline void mem_cgroup_rotate_reclaimable_page(struct page *page)
@@ -226,9 +227,9 @@ static inline void mem_cgroup_rotate_lru_list(struct page *page, int lru)
 	return ;
 }
 
-static inline void mem_cgroup_del_lru(struct page *page)
+static inline bool mem_cgroup_del_lru(struct page *page)
 {
-	return ;
+	return false;
 }
 
 static inline void
diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 8f7d247..f55b311 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -25,9 +25,11 @@ static inline void
 __add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list l,
 		       struct list_head *head)
 {
-	list_add(&page->lru, head);
-	__mod_zone_page_state(zone, NR_LRU_BASE + l, hpage_nr_pages(page));
-	mem_cgroup_add_lru_list(page, l);
+	if (mem_cgroup_add_lru_list(page, l) == false) {
+		list_add(&page->lru, head);
+		__mod_zone_page_state(zone, NR_LRU_BASE + l,
+				      hpage_nr_pages(page));
+	}
 }
 
 static inline void
@@ -39,9 +41,11 @@ add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list l)
 static inline void
 del_page_from_lru_list(struct zone *zone, struct page *page, enum lru_list l)
 {
-	list_del(&page->lru);
-	__mod_zone_page_state(zone, NR_LRU_BASE + l, -hpage_nr_pages(page));
-	mem_cgroup_del_lru_list(page, l);
+	if (mem_cgroup_del_lru_list(page, l) == false) {
+		list_del(&page->lru);
+		__mod_zone_page_state(zone, NR_LRU_BASE + l,
+				      -hpage_nr_pages(page));
+	}
 }
 
 /**
@@ -64,7 +68,6 @@ del_page_from_lru(struct zone *zone, struct page *page)
 {
 	enum lru_list l;
 
-	list_del(&page->lru);
 	if (PageUnevictable(page)) {
 		__ClearPageUnevictable(page);
 		l = LRU_UNEVICTABLE;
@@ -75,8 +78,11 @@ del_page_from_lru(struct zone *zone, struct page *page)
 			l += LRU_ACTIVE;
 		}
 	}
-	__mod_zone_page_state(zone, NR_LRU_BASE + l, -hpage_nr_pages(page));
-	mem_cgroup_del_lru_list(page, l);
+	if (mem_cgroup_del_lru_list(page, l) == false) {
+		__mod_zone_page_state(zone, NR_LRU_BASE + l,
+				      -hpage_nr_pages(page));
+		list_del(&page->lru);
+	}
 }
 
 /**
diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index f5de21d..7b2567b 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -31,7 +31,6 @@ enum {
 struct page_cgroup {
 	unsigned long flags;
 	struct mem_cgroup *mem_cgroup;
-	struct list_head lru;		/* per cgroup LRU list */
 };
 
 void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4407dd0..9079e2e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -827,17 +827,17 @@ static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
  * When moving account, the page is not on LRU. It's isolated.
  */
 
-void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
+bool mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
 {
 	struct page_cgroup *pc;
 	struct mem_cgroup_per_zone *mz;
 
 	if (mem_cgroup_disabled())
-		return;
+		return false;
 	pc = lookup_page_cgroup(page);
 	/* can happen while we handle swapcache. */
 	if (!TestClearPageCgroupAcctLRU(pc))
-		return;
+		return false;
 	VM_BUG_ON(!pc->mem_cgroup);
 	/*
 	 * We don't check PCG_USED bit. It's cleared when the "page" is finally
@@ -845,16 +845,16 @@ void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
 	 */
 	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
 	/* huge page split is done under lru_lock. so, we have no races. */
-	MEM_CGROUP_ZSTAT(mz, lru) -= 1 << compound_order(page);
 	if (mem_cgroup_is_root(pc->mem_cgroup))
-		return;
-	VM_BUG_ON(list_empty(&pc->lru));
-	list_del_init(&pc->lru);
+		return false;
+	MEM_CGROUP_ZSTAT(mz, lru) -= 1 << compound_order(page);
+	list_del_init(&page->lru);
+	return true;
 }
 
-void mem_cgroup_del_lru(struct page *page)
+bool mem_cgroup_del_lru(struct page *page)
 {
-	mem_cgroup_del_lru_list(page, page_lru(page));
+	return mem_cgroup_del_lru_list(page, page_lru(page));
 }
 
 /*
@@ -880,7 +880,7 @@ void mem_cgroup_rotate_reclaimable_page(struct page *page)
 	if (mem_cgroup_is_root(pc->mem_cgroup))
 		return;
 	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
-	list_move_tail(&pc->lru, &mz->lists[lru]);
+	list_move(&page->lru, &mz->lists[lru]);
 }
 
 void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)
@@ -900,29 +900,30 @@ void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)
 	if (mem_cgroup_is_root(pc->mem_cgroup))
 		return;
 	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
-	list_move(&pc->lru, &mz->lists[lru]);
+	list_move(&page->lru, &mz->lists[lru]);
 }
 
-void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
+bool mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
 {
 	struct page_cgroup *pc;
 	struct mem_cgroup_per_zone *mz;
 
 	if (mem_cgroup_disabled())
-		return;
+		return false;
 	pc = lookup_page_cgroup(page);
 	VM_BUG_ON(PageCgroupAcctLRU(pc));
 	if (!PageCgroupUsed(pc))
-		return;
+		return false;
 	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
 	smp_rmb();
 	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
 	/* huge page split is done under lru_lock. so, we have no races. */
-	MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page);
 	SetPageCgroupAcctLRU(pc);
 	if (mem_cgroup_is_root(pc->mem_cgroup))
-		return;
-	list_add(&pc->lru, &mz->lists[lru]);
+		return false;
+	MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page);
+	list_add(&page->lru, &mz->lists[lru]);
+	return true;
 }
 
 /*
@@ -1111,11 +1112,11 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					int active, int file)
 {
 	unsigned long nr_taken = 0;
-	struct page *page;
+	struct page *page, *tmp;
 	unsigned long scan;
 	LIST_HEAD(pc_list);
 	struct list_head *src;
-	struct page_cgroup *pc, *tmp;
+	struct page_cgroup *pc;
 	int nid = zone_to_nid(z);
 	int zid = zone_idx(z);
 	struct mem_cgroup_per_zone *mz;
@@ -1127,24 +1128,24 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 	src = &mz->lists[lru];
 
 	scan = 0;
-	list_for_each_entry_safe_reverse(pc, tmp, src, lru) {
+	list_for_each_entry_safe_reverse(page, tmp, src, lru) {
+		pc = lookup_page_cgroup(page);
 		if (scan >= nr_to_scan)
 			break;
 
 		if (unlikely(!PageCgroupUsed(pc)))
 			continue;
-
-		page = lookup_cgroup_page(pc);
-
 		if (unlikely(!PageLRU(page)))
 			continue;
 
+		BUG_ON(!PageCgroupAcctLRU(pc));
+
 		scan++;
 		ret = __isolate_lru_page(page, mode, file);
 		switch (ret) {
 		case 0:
-			list_move(&page->lru, dst);
 			mem_cgroup_del_lru(page);
+			list_add(&page->lru, dst);
 			nr_taken += hpage_nr_pages(page);
 			break;
 		case -EBUSY:
@@ -3386,6 +3387,7 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *mem,
 	struct page_cgroup *pc, *busy;
 	unsigned long flags, loop;
 	struct list_head *list;
+	struct page *page;
 	int ret = 0;
 
 	zone = &NODE_DATA(node)->node_zones[zid];
@@ -3397,25 +3399,23 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *mem,
 	loop += 256;
 	busy = NULL;
 	while (loop--) {
-		struct page *page;
-
 		ret = 0;
 		spin_lock_irqsave(&zone->lru_lock, flags);
 		if (list_empty(list)) {
 			spin_unlock_irqrestore(&zone->lru_lock, flags);
 			break;
 		}
-		pc = list_entry(list->prev, struct page_cgroup, lru);
+		page = list_entry(list->prev, struct page, lru);
+		pc = lookup_page_cgroup(page);
 		if (busy == pc) {
-			list_move(&pc->lru, list);
+			/* XXX what should we do here? */
+			list_move(&page->lru, list);
 			busy = NULL;
 			spin_unlock_irqrestore(&zone->lru_lock, flags);
 			continue;
 		}
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 
-		page = lookup_cgroup_page(pc);
-
 		ret = mem_cgroup_move_parent(page, pc, mem, GFP_KERNEL);
 		if (ret == -ENOMEM)
 			break;
diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 885b2ac..b812bf3 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -16,7 +16,6 @@ static void __meminit init_page_cgroup(struct page_cgroup *pc, unsigned long id)
 	pc->flags = 0;
 	set_page_cgroup_array_id(pc, id);
 	pc->mem_cgroup = NULL;
-	INIT_LIST_HEAD(&pc->lru);
 }
 static unsigned long total_usage;
 
diff --git a/mm/swap.c b/mm/swap.c
index 0a33714..9cb95c5 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -31,6 +31,7 @@
 #include <linux/backing-dev.h>
 #include <linux/memcontrol.h>
 #include <linux/gfp.h>
+#include <linux/page_cgroup.h>
 
 #include "internal.h"
 
@@ -200,10 +201,17 @@ static void pagevec_move_tail(struct pagevec *pvec)
 			spin_lock(&zone->lru_lock);
 		}
 		if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
+			struct page_cgroup *pc;
 			enum lru_list lru = page_lru_base_type(page);
-			list_move_tail(&page->lru, &zone->lru[lru].list);
+
 			mem_cgroup_rotate_reclaimable_page(page);
-			pgmoved++;
+			pc = lookup_page_cgroup(page);
+			smp_rmb();
+			if (!PageCgroupAcctLRU(pc)) {
+				list_move_tail(&page->lru,
+					       &zone->lru[lru].list);
+				pgmoved++;
+			}
 		}
 	}
 	if (zone)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 060e4c1..5e54611 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -41,6 +41,7 @@
 #include <linux/memcontrol.h>
 #include <linux/delayacct.h>
 #include <linux/sysctl.h>
+#include <linux/page_cgroup.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -1042,15 +1043,16 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 		switch (__isolate_lru_page(page, mode, file)) {
 		case 0:
-			list_move(&page->lru, dst);
+			/* verify that it's not on any cgroups */
 			mem_cgroup_del_lru(page);
+			list_move(&page->lru, dst);
 			nr_taken += hpage_nr_pages(page);
 			break;
 
 		case -EBUSY:
 			/* else it is being freed elsewhere */
-			list_move(&page->lru, src);
 			mem_cgroup_rotate_lru_list(page, page_lru(page));
+			list_move(&page->lru, src);
 			continue;
 
 		default:
@@ -1100,8 +1102,9 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 				break;
 
 			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
-				list_move(&cursor_page->lru, dst);
+				/* verify that it's not on any cgroup */
 				mem_cgroup_del_lru(cursor_page);
+				list_move(&cursor_page->lru, dst);
 				nr_taken += hpage_nr_pages(page);
 				nr_lumpy_taken++;
 				if (PageDirty(cursor_page))
@@ -1473,6 +1476,7 @@ static void move_active_pages_to_lru(struct zone *zone,
 	unsigned long pgmoved = 0;
 	struct pagevec pvec;
 	struct page *page;
+	struct page_cgroup *pc;
 
 	pagevec_init(&pvec, 1);
 
@@ -1482,9 +1486,15 @@ static void move_active_pages_to_lru(struct zone *zone,
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 
-		list_move(&page->lru, &zone->lru[lru].list);
-		mem_cgroup_add_lru_list(page, lru);
-		pgmoved += hpage_nr_pages(page);
+		pc = lookup_page_cgroup(page);
+		smp_rmb();
+		if (!PageCgroupAcctLRU(pc)) {
+			list_move(&page->lru, &zone->lru[lru].list);
+			pgmoved += hpage_nr_pages(page);
+		} else {
+			list_del_init(&page->lru);
+			mem_cgroup_add_lru_list(page, lru);
+		}
 
 		if (!pagevec_add(&pvec, page) || list_empty(list)) {
 			spin_unlock_irq(&zone->lru_lock);
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
