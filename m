Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 8FE136B00E9
	for <linux-mm@kvack.org>; Tue,  1 May 2012 04:43:23 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 5/5] mm: refault distance-based file cache sizing
Date: Tue,  1 May 2012 10:41:53 +0200
Message-Id: <1335861713-4573-6-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1335861713-4573-1-git-send-email-hannes@cmpxchg.org>
References: <1335861713-4573-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

To protect frequently used page cache (workingset) from bursts of less
frequently used or one-shot cache, page cache pages are managed on two
linked lists.  The inactive list is where all cache starts out on
fault and ends on reclaim.  Pages that get accessed another time while
on the inactive list get promoted to the active list to protect them
from reclaim.

Right now we have two main problems.

One stems from numa allocation decisions and how the page allocator
and kswapd interact.  The both of them can enter into a perfect loop
where kswapd reclaims from the preferred zone of a task, allowing the
task to continuously allocate from that zone.  Or, the node distance
can lead to the allocator to do direct zone reclaim to stay in the
preferred zone.  This may be good for locality, but the task has only
the inactive space of that one zone to get its memory activated.
Forcing the allocator to spread out to lower zones in the right
situation makes the difference between continuous IO to serve the
workingset, or taking the numa cost but serving fully from memory.

The other issue is that with the two lists alone, we can never detect
when a new set of data with equal access frequency should be cached if
the size of it is bigger than total/allowed memory minus the active
set.  Currently we have the perfect compromise given those
constraints: the active list is not allowed to grow bigger than the
inactive list.  This means that we can protect cache from reclaim only
up to half of memory, and don't recognize workingset changes that are
bigger than half of memory.

This patch tries to solve both problems by adding and making use of a
new metric, the refault distance.

Whenever a file page leaves the inactive list, be it through reclaim
or activation, a global counter is increased, called the "workingset
time".  When a page is evicted from memory, a snapshot of the current
workingset time is remembered, so that when the page is refaulted
later, it can be figured out for how long the page has been out of
memory.  This is called the refault distance.

The observation then is this: if a page is refaulted after N ticks of
working set time, the eviction could have been avoided if the active
list had been N pages smaller and this space available to the inactive
list instead.

We don't have recent usage information for pages on the active list,
so we can not explicitely compare the refaulting page to the least
frequently used active page.  Instead, for each refault with a
distance smaller than the size of the active list, we deactivate an
active page.  This way, both the refaulted page and the freshly
deactivated page get placed next to each other on the head of the
inactive list and both have equal chance to get activated.  Whichever
wins is probably the more frequently used page.

To ensure the spreading of pages across available/allowed zones when
necessary, a per-zone floating proportion of evictions in the system
is maintained, which allows translating the global refault distance of
a page into a distance proportional to the zone's own eviction speed.
When a refaulting page is allocated, for each zone considered in the
first zonelist walk of the allocator, the per-zone distance is
compared to the zone's number of active and free pages.  If the
distance is bigger, the allocator moves to the next zone, to see if
its less utilized (less evictions -> smaller distance, potentially
stale active pages, or even free pages) and thus, unlike the preferred
zone, has the potential to hold the page in memory.  This way,
non-refault allocations and those that would fit into the preferred
zone stay local, but if we see a chance to keep these pages in memory
long-term by spreading them out, we try to use all the space we can
get and sacrifice locality to save disk IO.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/mmzone.h |    7 ++
 include/linux/swap.h   |    9 ++-
 mm/Makefile            |    1 +
 mm/memcontrol.c        |    3 +
 mm/page_alloc.c        |    7 ++
 mm/swap.c              |    2 +
 mm/vmscan.c            |   80 +++++++++++++---------
 mm/vmstat.c            |    4 +
 mm/workingset.c        |  174 ++++++++++++++++++++++++++++++++++++++++++++++++
 9 files changed, 249 insertions(+), 38 deletions(-)
 create mode 100644 mm/workingset.c

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 650ba2f..a4da472 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -15,6 +15,7 @@
 #include <linux/seqlock.h>
 #include <linux/nodemask.h>
 #include <linux/pageblock-flags.h>
+#include <linux/proportions.h>
 #include <generated/bounds.h>
 #include <linux/atomic.h>
 #include <asm/page.h>
@@ -115,6 +116,10 @@ enum zone_stat_item {
 	NUMA_LOCAL,		/* allocation from local node */
 	NUMA_OTHER,		/* allocation from other node */
 #endif
+	WORKINGSET_SKIP,
+	WORKINGSET_ALLOC,
+	WORKINGSET_STALE,
+	WORKINGSET_STALE_FORCE,
 	NR_ANON_TRANSPARENT_HUGEPAGES,
 	NR_VM_ZONE_STAT_ITEMS };
 
@@ -161,6 +166,7 @@ static inline int is_unevictable_lru(enum lru_list lru)
 
 struct lruvec {
 	struct list_head lists[NR_LRU_LISTS];
+	long shrink_active;
 };
 
 /* Mask used at gathering information at once (see memcontrol.c) */
@@ -372,6 +378,7 @@ struct zone {
 	/* Fields commonly accessed by the page reclaim scanner */
 	spinlock_t		lru_lock;
 	struct lruvec		lruvec;
+	struct prop_local_percpu evictions;
 
 	struct zone_reclaim_stat reclaim_stat;
 
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 03d327f..cf304ed 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -205,10 +205,11 @@ struct swap_list_t {
 #define vm_swap_full() (nr_swap_pages*2 < total_swap_pages)
 
 /* linux/mm/workingset.c */
-static inline unsigned long workingset_refault_distance(struct page *page)
-{
-	return 0;
-}
+void *workingset_eviction(struct page *);
+void workingset_activation(struct page *);
+unsigned long workingset_refault_distance(struct page *);
+bool workingset_zone_alloc(struct zone *, unsigned long,
+			   unsigned long *, unsigned long *);
 
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
diff --git a/mm/Makefile b/mm/Makefile
index 50ec00e..bd09137 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -13,6 +13,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 			   readahead.o swap.o truncate.o vmscan.o shmem.o \
 			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
 			   page_isolation.o mm_init.o mmu_context.o percpu.o \
+			   workingset.o \
 			   $(mmu-y)
 obj-y += init-mm.o
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 58a08fc..10dc07c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1020,6 +1020,9 @@ struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
 	if (mem_cgroup_disabled())
 		return &zone->lruvec;
 
+	if (!memcg)
+		memcg = root_mem_cgroup;
+
 	mz = mem_cgroup_zoneinfo(memcg, zone_to_nid(zone), zone_idx(zone));
 	return &mz->lruvec;
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a13ded1..a6544c9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1711,9 +1711,11 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
+	unsigned long distance, active;
 
 	classzone_idx = zone_idx(preferred_zone);
 zonelist_scan:
+	distance = active = 0;
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
 	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
@@ -1726,6 +1728,11 @@ zonelist_scan:
 		if ((alloc_flags & ALLOC_CPUSET) &&
 			!cpuset_zone_allowed_softwall(zone, gfp_mask))
 				continue;
+		if ((alloc_flags & ALLOC_WMARK_LOW) &&
+		    current->refault_distance &&
+		    !workingset_zone_alloc(zone, current->refault_distance,
+					   &distance, &active))
+			continue;
 		/*
 		 * When allocating a page cache page for writing, we
 		 * want to get it from a zone that is within its dirty
diff --git a/mm/swap.c b/mm/swap.c
index cc5ce81..3029b40 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -365,6 +365,8 @@ void mark_page_accessed(struct page *page)
 			PageReferenced(page) && PageLRU(page)) {
 		activate_page(page);
 		ClearPageReferenced(page);
+		if (page_is_file_cache(page))
+			workingset_activation(page);
 	} else if (!PageReferenced(page)) {
 		SetPageReferenced(page);
 	}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 44d81f5..a01d123 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -536,7 +536,8 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
  * Same as remove_mapping, but if the page is removed from the mapping, it
  * gets returned with a refcount of 0.
  */
-static int __remove_mapping(struct address_space *mapping, struct page *page)
+static int __remove_mapping(struct address_space *mapping, struct page *page,
+			    bool reclaimed)
 {
 	BUG_ON(!PageLocked(page));
 	BUG_ON(mapping != page_mapping(page));
@@ -582,10 +583,13 @@ static int __remove_mapping(struct address_space *mapping, struct page *page)
 		swapcache_free(swap, page);
 	} else {
 		void (*freepage)(struct page *);
+		void *shadow = NULL;
 
 		freepage = mapping->a_ops->freepage;
-
-		__delete_from_page_cache(page, NULL);
+		
+		if (reclaimed && page_is_file_cache(page))
+			shadow = workingset_eviction(page);
+		__delete_from_page_cache(page, shadow);
 		spin_unlock_irq(&mapping->tree_lock);
 		mem_cgroup_uncharge_cache_page(page);
 
@@ -608,7 +612,7 @@ cannot_free:
  */
 int remove_mapping(struct address_space *mapping, struct page *page)
 {
-	if (__remove_mapping(mapping, page)) {
+	if (__remove_mapping(mapping, page, false)) {
 		/*
 		 * Unfreezing the refcount with 1 rather than 2 effectively
 		 * drops the pagecache ref for us without requiring another
@@ -968,7 +972,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
-		if (!mapping || !__remove_mapping(mapping, page))
+		if (!mapping || !__remove_mapping(mapping, page, true))
 			goto keep_locked;
 
 		/*
@@ -1824,43 +1828,51 @@ static inline int inactive_anon_is_low(struct mem_cgroup_zone *mz)
 }
 #endif
 
-static int inactive_file_is_low_global(struct zone *zone)
+static int inactive_file_is_low(unsigned long nr_to_scan,
+				struct mem_cgroup_zone *mz,
+				struct scan_control *sc)
 {
-	unsigned long active, inactive;
-
-	active = zone_page_state(zone, NR_ACTIVE_FILE);
-	inactive = zone_page_state(zone, NR_INACTIVE_FILE);
-
-	return (active > inactive);
-}
+	unsigned long inactive_ratio;
+	unsigned long inactive;
+	struct lruvec *lruvec;
+	unsigned long active;
+	unsigned long gb;
 
-/**
- * inactive_file_is_low - check if file pages need to be deactivated
- * @mz: memory cgroup and zone to check
- *
- * When the system is doing streaming IO, memory pressure here
- * ensures that active file pages get deactivated, until more
- * than half of the file pages are on the inactive list.
- *
- * Once we get to that situation, protect the system's working
- * set from being evicted by disabling active file page aging.
- *
- * This uses a different ratio than the anonymous pages, because
- * the page cache uses a use-once replacement algorithm.
- */
-static int inactive_file_is_low(struct mem_cgroup_zone *mz)
-{
-	if (!scanning_global_lru(mz))
+	if (!global_reclaim(sc)) /* XXX: integrate hard limit reclaim */
 		return mem_cgroup_inactive_file_is_low(mz->mem_cgroup,
 						       mz->zone);
 
-	return inactive_file_is_low_global(mz->zone);
+	lruvec = mem_cgroup_zone_lruvec(mz->zone, sc->target_mem_cgroup);
+	if (lruvec->shrink_active > 0) {
+		inc_zone_state(mz->zone, WORKINGSET_STALE);
+		lruvec->shrink_active -= nr_to_scan;
+		return true;
+	}
+	/*
+	 * Make sure there is always a reasonable amount of inactive
+	 * file pages around to keep the zone reclaimable.
+	 */
+	inactive = zone_nr_lru_pages(mz, LRU_INACTIVE_FILE);
+	active = zone_nr_lru_pages(mz, LRU_ACTIVE_FILE);
+	gb = (inactive + active) >> (30 - PAGE_SHIFT);
+	if (gb)
+		inactive_ratio = int_sqrt(10 * gb);
+	else
+		inactive_ratio = 1;
+	if (inactive * inactive_ratio < active) {
+		inc_zone_state(mz->zone, WORKINGSET_STALE_FORCE);
+		return true;
+	}
+	return false;
 }
 
-static int inactive_list_is_low(struct mem_cgroup_zone *mz, int file)
+static int inactive_list_is_low(unsigned long nr_to_scan,
+				struct mem_cgroup_zone *mz,
+				struct scan_control *sc,
+				int file)
 {
 	if (file)
-		return inactive_file_is_low(mz);
+		return inactive_file_is_low(nr_to_scan, mz, sc);
 	else
 		return inactive_anon_is_low(mz);
 }
@@ -1872,7 +1884,7 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 	int file = is_file_lru(lru);
 
 	if (is_active_lru(lru)) {
-		if (inactive_list_is_low(mz, file))
+		if (inactive_list_is_low(nr_to_scan, mz, sc, file))
 			shrink_active_list(nr_to_scan, mz, sc, priority, file);
 		return 0;
 	}
diff --git a/mm/vmstat.c b/mm/vmstat.c
index f600557..28f4b90 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -718,6 +718,10 @@ const char * const vmstat_text[] = {
 	"numa_local",
 	"numa_other",
 #endif
+	"workingset_skip",
+	"workingset_alloc",
+	"workingset_stale",
+	"workingset_stale_force",
 	"nr_anon_transparent_hugepages",
 	"nr_dirty_threshold",
 	"nr_dirty_background_threshold",
diff --git a/mm/workingset.c b/mm/workingset.c
new file mode 100644
index 0000000..2fc9ac6
--- /dev/null
+++ b/mm/workingset.c
@@ -0,0 +1,174 @@
+/*
+ * Workingset detection
+ *
+ * Copyright (C) 2012 Red Hat, Inc., Johannes Weiner
+ */
+
+#include <linux/memcontrol.h>
+#include <linux/pagemap.h>
+#include <linux/atomic.h>
+#include <linux/module.h>
+#include <linux/swap.h>
+#include <linux/fs.h>
+#include <linux/mm.h>
+
+/*
+ * Monotonic workingset clock for non-resident pages.  Each page
+ * leaving the inactive list (eviction or activation) is one tick.
+ *
+ * The refault distance of a page that is the number of ticks that
+ * occurred between eviction and refault.
+ *
+ * If the inactive list had been bigger by the refault distance in
+ * pages, the refault would not have happened.  Or put differently, if
+ * the distance is smaller than the number of active file pages, an
+ * active page needs to be deactivated so that both pages get an equal
+ * chance for activation when there is not enough memory for both.
+ */
+static atomic_t workingset_time;
+
+/*
+ * Per-zone proportional eviction counter to keep track of recent zone
+ * eviction speed and be able to calculate per-zone refault distances.
+ */
+static struct prop_descriptor global_evictions;
+
+/*
+ * Workingset time snapshots are stored in the page cache radix tree
+ * as exceptional entries.
+ */
+#define EV_SHIFT	RADIX_TREE_EXCEPTIONAL_SHIFT
+#define EV_MASK		(~0UL >> EV_SHIFT)
+
+void *workingset_eviction(struct page *page)
+{
+	unsigned long time;
+
+	prop_inc_percpu(&global_evictions, &page_zone(page)->evictions);
+	time = (unsigned int)atomic_inc_return(&workingset_time);
+
+	return (void *)((time << EV_SHIFT) | RADIX_TREE_EXCEPTIONAL_ENTRY);
+}
+
+void workingset_activation(struct page *page)
+{
+	struct lruvec *lruvec;
+	/*
+	 * Refault distance is compared to the number of active pages,
+	 * but pages activated after the eviction were hardly the
+	 * reason for memory shortness back then.  Advancing the clock
+	 * on activation compensates for them, so that we compare to
+	 * the number of active pages at time of eviction.
+	 */
+	atomic_inc(&workingset_time);
+	/*
+	 * Furthermore, activations mean that the inactive list is big
+	 * enough and that a new workingset is being adapted already.
+	 * Deactivation is no longer necessary; even harmful.
+	 */
+	lruvec = mem_cgroup_zone_lruvec(page_zone(page), NULL);
+	if (lruvec->shrink_active > 0)
+		lruvec->shrink_active--;
+}
+
+unsigned long workingset_refault_distance(struct page *page)
+{
+	unsigned long time_of_eviction;
+	unsigned long now;
+
+	if (!page)
+		return 0;
+
+	BUG_ON(!radix_tree_exceptional_entry(page));
+
+	time_of_eviction = (unsigned long)page >> EV_SHIFT;
+	now = (unsigned int)atomic_read(&workingset_time) & EV_MASK;
+
+	return (now - time_of_eviction) & EV_MASK;
+}
+EXPORT_SYMBOL(workingset_refault_distance);
+
+bool workingset_zone_alloc(struct zone *zone, unsigned long refault_distance,
+			   unsigned long *pdistance, unsigned long *pactive)
+{
+	unsigned long zone_active;
+	unsigned long zone_free;
+	unsigned long missing;
+	long denominator;
+	long numerator;
+
+	/*
+	 * Don't put refaulting pages into zones that are already
+	 * heavily reclaimed and don't have the potential to hold all
+	 * the workingset.  Instead go for zones where the zone-local
+	 * distance is smaller than the potential inactive list space.
+	 * This can be either because there has not been much reclaim
+	 * recently (small distance), because the zone is not actually
+	 * full (free pages), or because there are just genuinely a
+	 * lot of active pages that may be used less frequently than
+	 * the refaulting page.  Either way, use this potential to
+	 * hold the refaulting page long-term instead of beating on
+	 * already thrashing higher zones.
+	 */
+	prop_fraction_percpu(&global_evictions, &zone->evictions,
+			     &numerator, &denominator);
+	missing = refault_distance * numerator;
+	do_div(missing, denominator);
+	*pdistance += missing;
+
+	zone_active = zone_page_state(zone, NR_ACTIVE_FILE);
+	*pactive += zone_active;
+
+	/*
+	 * Lower zones may not even be full, and free pages are
+	 * potential inactive space, too.  But the dirty reserve is
+	 * not available to page cache due to lowmem reserves and the
+	 * kswapd watermark.  Don't include it.
+	 */
+	zone_free = zone_page_state(zone, NR_FREE_PAGES);
+	if (zone_free > zone->dirty_balance_reserve)
+		zone_free -= zone->dirty_balance_reserve;
+	else
+		zone_free = 0;
+
+	if (missing >= zone_active + zone_free) {
+		inc_zone_state(zone, WORKINGSET_SKIP);
+		return false;
+	}
+
+	inc_zone_state(zone, WORKINGSET_ALLOC);
+
+	/*
+	 * Okay, placement in this zone makes sense, but don't start
+	 * actually deactivating pages until all allowed zones are
+	 * under equalized pressure, or risk throwing out active pages
+	 * from a barely used zone even when the refaulting data set
+	 * is bigger than the available memory.  To prevent that, look
+	 * at the cumulative distance and active pages of all zones
+	 * already visited, which normalizes the distance for the case
+	 * when higher zones are thrashing and we just started putting
+	 * pages in the lower ones.
+	 */
+	if (*pdistance < *pactive) {
+		struct lruvec *lruvec;
+
+		lruvec = mem_cgroup_zone_lruvec(zone, NULL);
+		lruvec->shrink_active++;
+	}
+	return true;
+}
+
+static int __init workingset_init(void)
+{
+	extern unsigned long global_dirtyable_memory(void);
+	struct zone *zone;
+	int shift;
+
+	shift = ilog2(global_dirtyable_memory() - 1);
+	prop_descriptor_init(&global_evictions, shift);
+	for_each_zone(zone)
+		prop_local_init_percpu(&zone->evictions);
+	return 0;
+}
+
+module_init(workingset_init);
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
