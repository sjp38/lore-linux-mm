Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id A1AD66B003C
	for <linux-mm@kvack.org>; Thu, 30 May 2013 14:04:55 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 09/10] mm: thrash detection-based file cache sizing
Date: Thu, 30 May 2013 14:04:05 -0400
Message-Id: <1369937046-27666-10-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1369937046-27666-1-git-send-email-hannes@cmpxchg.org>
References: <1369937046-27666-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, metin d <metdos@yahoo.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

The VM maintains cached filesystem pages on two types of lists.  One
list holds the pages recently faulted into the cache, the other list
holds pages that have been referenced repeatedly on that first list.
The idea is to prefer reclaiming young pages over those that have
shown to benefit from caching in the past.  We call the recently used
list "inactive list" and the frequently used list "active list".

The tricky part of this model is finding the right balance between
them.  A big inactive list may not leave enough room for the active
list to protect all the frequently used pages.  A big active list may
not leave enough room for the inactive list for a new set of
frequently used pages, "working set", to establish itself because the
young pages get pushed out of memory before having a chance to get
promoted.

Historically, every reclaim scan of the inactive list also took a
smaller number of pages from the tail of the active list and moved
them to the head of the inactive list.  This model gave established
working sets more gracetime in the face of temporary use once streams,
but was not satisfactory when use once streaming persisted over longer
periods of time and the established working set was temporarily
suspended, like a nightly backup evicting all the interactive user
program data.

Subsequently, the rules were changed to only age active pages when
they exceeded the amount of inactive pages, i.e. leave the working set
alone as long as the other half of memory is easy to reclaim use once
pages.  This works well until working set transitions exceed the size
of half of memory and the average access distance between the pages of
the new working set is bigger than the inactive list.  The VM will
mistake the thrashing new working set for use once streaming, while
the unused old working set pages are stuck on the active list.

This patch solves this problem by maintaining a history of recently
evicted file pages, which in turn allows the VM to tell used-once page
streams from thrashing file cache.

To accomplish this, a global counter is increased every time a page is
evicted and a snapshot of that counter is stored as shadow entry in
the page's now empty page cache radix tree slot.  Upon refault of that
page, the difference between the current value of that counter and the
shadow entry value is called the refault distance.  It tells how many
pages have been evicted since this page's eviction, which is how many
page slots are missing from the inactive list for this page to get
accessed twice while in memory.  If the number of missing slots is
less than or equal to the number of active pages, increasing the
inactive list at the cost of the active list would give this thrashing
set a chance to establish itself:

eviction counter = 4
                        evicted      inactive           active
 Page cache data:       [ a b c d ]  [ e f g h i j k ]  [ l m n ]
  Shadow entries:         0 1 2 3
Refault distance:         4 3 2 1

When c is faulted back into memory, it is noted that two more page
slots on the inactive list could have prevented the refault.  Thus,
the active list needs to be challenged for those two page slots as it
is possible that c is used more frequently than l, m, n.  However, c
might also be used much less frequent than the active pages and so 1)
pages can not be directly reclaimed from the tail of the active list
and b) refaulting pages can not be directly activated.  Instead,
active pages are moved from the tail of the active list to the head of
the inactive list and placed directly next to the refaulting pages.
This way, they both have the same time on the inactive list to prove
which page is actually used more frequently without incurring
unnecessary major faults or diluting the active page set in case the
previously active page is in fact the more frequently used one.

On multi-node systems, workloads with different page access
frequencies may execute concurrently on separate nodes.  On refault,
the page allocator walks the list of allowed zones to allocate a page
frame for the refaulting page.  For each zone, a local refault
distance is calculated that is proportional to the zone's recent share
of global evictions.  This local distance is then compared to the
local number of active pages, so the decision to rebalance the lists
is made on an individual per-zone basis.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/mmzone.h |   6 ++
 include/linux/swap.h   |   8 +-
 mm/Makefile            |   2 +-
 mm/memcontrol.c        |   3 +
 mm/mmzone.c            |   1 +
 mm/page_alloc.c        |   9 +-
 mm/swap.c              |   2 +
 mm/vmscan.c            |  45 +++++++---
 mm/vmstat.c            |   3 +
 mm/workingset.c        | 233 +++++++++++++++++++++++++++++++++++++++++++++++++
 10 files changed, 293 insertions(+), 19 deletions(-)
 create mode 100644 mm/workingset.c

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 370a35f..505bd80 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -16,6 +16,7 @@
 #include <linux/nodemask.h>
 #include <linux/pageblock-flags.h>
 #include <linux/page-flags-layout.h>
+#include <linux/proportions.h>
 #include <linux/atomic.h>
 #include <asm/page.h>
 
@@ -141,6 +142,9 @@ enum zone_stat_item {
 	NUMA_LOCAL,		/* allocation from local node */
 	NUMA_OTHER,		/* allocation from other node */
 #endif
+	WORKINGSET_STALE,
+	WORKINGSET_BALANCE,
+	WORKINGSET_BALANCE_FORCE,
 	NR_ANON_TRANSPARENT_HUGEPAGES,
 	NR_FREE_CMA_PAGES,
 	NR_VM_ZONE_STAT_ITEMS };
@@ -202,6 +206,8 @@ struct zone_reclaim_stat {
 struct lruvec {
 	struct list_head lists[NR_LRU_LISTS];
 	struct zone_reclaim_stat reclaim_stat;
+	struct prop_local_percpu evictions;
+	long shrink_active;
 #ifdef CONFIG_MEMCG
 	struct zone *zone;
 #endif
diff --git a/include/linux/swap.h b/include/linux/swap.h
index ffa323a..c3d5237 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -222,10 +222,10 @@ struct swap_list_t {
 };
 
 /* linux/mm/workingset.c */
-static inline unsigned long workingset_refault_distance(struct page *page)
-{
-	return ~0UL;
-}
+void *workingset_eviction(struct address_space *mapping, struct page *page);
+unsigned long workingset_refault_distance(struct page *page);
+void workingset_zone_balance(struct zone *zone, unsigned long refault_distance);
+void workingset_activation(struct page *page);
 
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
diff --git a/mm/Makefile b/mm/Makefile
index 3a46287..b5a7416 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -17,7 +17,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 			   util.o mmzone.o vmstat.o backing-dev.o \
 			   mm_init.o mmu_context.o percpu.o slab_common.o \
 			   compaction.o balloon_compaction.o \
-			   interval_tree.o $(mmu-y)
+			   interval_tree.o workingset.o $(mmu-y)
 
 obj-y += init-mm.o
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2b55222..cc3026a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1221,6 +1221,9 @@ struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
 		goto out;
 	}
 
+	if (!memcg)
+		memcg = root_mem_cgroup;
+
 	mz = mem_cgroup_zoneinfo(memcg, zone_to_nid(zone), zone_idx(zone));
 	lruvec = &mz->lruvec;
 out:
diff --git a/mm/mmzone.c b/mm/mmzone.c
index 2ac0afb..3d71a01 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -95,6 +95,7 @@ void lruvec_init(struct lruvec *lruvec)
 
 	for_each_lru(lru)
 		INIT_LIST_HEAD(&lruvec->lists[lru]);
+	prop_local_init_percpu(&lruvec->evictions);
 }
 
 #if defined(CONFIG_NUMA_BALANCING) && !defined(LAST_NID_NOT_IN_PAGE_FLAGS)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 92b4c01..9fd11c3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1893,9 +1893,12 @@ zonelist_scan:
 		 * will require awareness of zones in the
 		 * dirty-throttling and the flusher threads.
 		 */
-		if ((alloc_flags & ALLOC_WMARK_LOW) &&
-		    (gfp_mask & __GFP_WRITE) && !zone_dirty_ok(zone))
-			goto this_zone_full;
+		if (alloc_flags & ALLOC_WMARK_LOW) {
+			if (refault_distance)
+				workingset_zone_balance(zone, refault_distance);
+			if ((gfp_mask & __GFP_WRITE) && !zone_dirty_ok(zone))
+				goto this_zone_full;
+		}
 
 		/*
 		 * XXX: Ensure similar zone aging speeds by
diff --git a/mm/swap.c b/mm/swap.c
index 37bfe2d..af394c1 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -440,6 +440,8 @@ void mark_page_accessed(struct page *page)
 			PageReferenced(page) && PageLRU(page)) {
 		activate_page(page);
 		ClearPageReferenced(page);
+		if (page_is_file_cache(page))
+			workingset_activation(page);
 	} else if (!PageReferenced(page)) {
 		SetPageReferenced(page);
 	}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index ff0d92f..ef5b73a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -449,7 +449,8 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
  * Same as remove_mapping, but if the page is removed from the mapping, it
  * gets returned with a refcount of 0.
  */
-static int __remove_mapping(struct address_space *mapping, struct page *page)
+static int __remove_mapping(struct address_space *mapping, struct page *page,
+			    bool reclaimed)
 {
 	BUG_ON(!PageLocked(page));
 	BUG_ON(mapping != page_mapping(page));
@@ -495,10 +496,13 @@ static int __remove_mapping(struct address_space *mapping, struct page *page)
 		swapcache_free(swap, page);
 	} else {
 		void (*freepage)(struct page *);
+		void *shadow = NULL;
 
 		freepage = mapping->a_ops->freepage;
 
-		__delete_from_page_cache(page, NULL);
+		if (reclaimed && page_is_file_cache(page))
+			shadow = workingset_eviction(mapping, page);
+		__delete_from_page_cache(page, shadow);
 		spin_unlock_irq(&mapping->tree_lock);
 		mem_cgroup_uncharge_cache_page(page);
 
@@ -521,7 +525,7 @@ cannot_free:
  */
 int remove_mapping(struct address_space *mapping, struct page *page)
 {
-	if (__remove_mapping(mapping, page)) {
+	if (__remove_mapping(mapping, page, false)) {
 		/*
 		 * Unfreezing the refcount with 1 rather than 2 effectively
 		 * drops the pagecache ref for us without requiring another
@@ -903,7 +907,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
-		if (!mapping || !__remove_mapping(mapping, page))
+		if (!mapping || !__remove_mapping(mapping, page, true))
 			goto keep_locked;
 
 		/*
@@ -1593,21 +1597,40 @@ static inline int inactive_anon_is_low(struct lruvec *lruvec)
  * This uses a different ratio than the anonymous pages, because
  * the page cache uses a use-once replacement algorithm.
  */
-static int inactive_file_is_low(struct lruvec *lruvec)
+static int inactive_file_is_low(struct lruvec *lruvec, unsigned long nr_to_scan)
 {
 	unsigned long inactive;
 	unsigned long active;
 
+	if (lruvec->shrink_active > 0) {
+		inc_zone_state(lruvec_zone(lruvec), WORKINGSET_BALANCE);
+		lruvec->shrink_active -= nr_to_scan;
+		return true;
+	}
+	/*
+	 * Make sure there is always a reasonable amount of inactive
+	 * file pages around to keep the zone reclaimable.
+	 *
+	 * We could do better than requiring half of memory, but we
+	 * need a big safety buffer until we are smarter about
+	 * dirty/writeback pages and file readahead windows.
+	 * Otherwise, we can end up with all pages on the inactive
+	 * list being dirty, or trash readahead pages before use.
+	 */
 	inactive = get_lru_size(lruvec, LRU_INACTIVE_FILE);
 	active = get_lru_size(lruvec, LRU_ACTIVE_FILE);
-
-	return active > inactive;
+	if (active > inactive) {
+		inc_zone_state(lruvec_zone(lruvec), WORKINGSET_BALANCE_FORCE);
+		return true;
+	}
+	return false;
 }
 
-static int inactive_list_is_low(struct lruvec *lruvec, enum lru_list lru)
+static int inactive_list_is_low(struct lruvec *lruvec, enum lru_list lru,
+				unsigned long nr_to_scan)
 {
 	if (is_file_lru(lru))
-		return inactive_file_is_low(lruvec);
+		return inactive_file_is_low(lruvec, nr_to_scan);
 	else
 		return inactive_anon_is_low(lruvec);
 }
@@ -1616,7 +1639,7 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 				 struct lruvec *lruvec, struct scan_control *sc)
 {
 	if (is_active_lru(lru)) {
-		if (inactive_list_is_low(lruvec, lru))
+		if (inactive_list_is_low(lruvec, lru, nr_to_scan))
 			shrink_active_list(nr_to_scan, lruvec, sc, lru);
 		return 0;
 	}
@@ -1727,7 +1750,7 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 	 * There is enough inactive page cache, do not reclaim
 	 * anything from the anonymous working set right now.
 	 */
-	if (!inactive_file_is_low(lruvec)) {
+	if (!inactive_file_is_low(lruvec, 0)) {
 		scan_balance = SCAN_FILE;
 		goto out;
 	}
diff --git a/mm/vmstat.c b/mm/vmstat.c
index e1d8ed1..17c19b0 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -735,6 +735,9 @@ const char * const vmstat_text[] = {
 	"numa_local",
 	"numa_other",
 #endif
+	"workingset_stale",
+	"workingset_balance",
+	"workingset_balance_force",
 	"nr_anon_transparent_hugepages",
 	"nr_free_cma",
 	"nr_dirty_threshold",
diff --git a/mm/workingset.c b/mm/workingset.c
new file mode 100644
index 0000000..7986aa4
--- /dev/null
+++ b/mm/workingset.c
@@ -0,0 +1,233 @@
+/*
+ * Workingset detection
+ *
+ * Copyright (C) 2012 Red Hat, Inc., Johannes Weiner
+ */
+
+#include <linux/memcontrol.h>
+#include <linux/writeback.h>
+#include <linux/pagemap.h>
+#include <linux/atomic.h>
+#include <linux/module.h>
+#include <linux/swap.h>
+#include <linux/fs.h>
+#include <linux/mm.h>
+
+/*
+ *		Double CLOCK lists
+ *
+ * Per zone, two clock lists are maintained for file pages: the
+ * inactive and the active list.  Freshly faulted pages start out at
+ * the head of the inactive list and page reclaim scans pages from the
+ * tail.  Pages that are accessed multiple times on the inactive list
+ * are promoted to the active list, to protect them from reclaim,
+ * whereas active pages are demoted to the inactive list when the
+ * inactive list requires more space to detect repeatedly accessed
+ * pages in the current workload and prevent them from thrashing:
+ *
+ *   fault -----------------------+
+ *                                |
+ *              +-------------+   |            +-------------+
+ *   reclaim <- | inactive    | <-+-- demotion | active      | <--+
+ *              +-------------+                +-------------+    |
+ *                       |                                        |
+ *                       +----------- promotion ------------------+
+ *
+ *
+ *		Access frequency and refault distance
+ *
+ * A workload is thrashing when the distances between the first and
+ * second access of pages that are frequently used is bigger than the
+ * current inactive clock list size, as the pages get reclaimed before
+ * the second access would have promoted them instead:
+ *
+ *    Access #: 1 2 3 4 5 6 7 8 9
+ *     Page ID: x y b c d e f x y
+ *                  | inactive  |
+ *
+ * To prevent this workload from thrashing, a bigger inactive list is
+ * required.  And the only way the inactive list can grow on a full
+ * zone is by taking away space from the corresponding active list.
+ *
+ *      +-inactive--+-active------+
+ *  x y | b c d e f | G H I J K L |
+ *      +-----------+-------------+
+ *
+ * Not every refault should lead to growing the inactive list at the
+ * cost of the active list, however: if the access distances are
+ * bigger than available memory overall, there is little point in
+ * challenging the protected pages on the active list, as those
+ * refaulting pages will not fit completely into memory.
+ *
+ * It is prohibitively expensive to track the access frequency of
+ * in-core pages, but it is possible to track their refault distance,
+ * which is the number of page slots shrunk from the inactive list
+ * between a page's eviction and subsequent refault.  This indicates
+ * how many page slots are missing on the inactive list in order to
+ * prevent future thrashing of that page.  Thus, instead of comparing
+ * access frequency to total available memory, one can compare the
+ * refault distance to the inactive list's potential for growth: the
+ * size of the active list.
+ *
+ *
+ *		Rebalancing the lists
+ *
+ * Shrinking the active list has to be done carefully because the
+ * pages on it may have vastly different access frequencies compared
+ * to the pages on the inactive list.  Thus, pages are not reclaimed
+ * directly from the tail of the active list, but instead moved to the
+ * head of the inactive list.  This way, they are competing directly
+ * with the pages that challenged their protected status.  If they are
+ * unused, they will eventually be reclaimed, but if they are indeed
+ * used more frequently than the challenging inactive pages, they will
+ * be reactivated.  This allows the existing protected set to be
+ * challenged without incurring major faults in case of a mistake.
+ */
+
+/*
+ * Monotonic workingset clock for non-resident pages.
+ *
+ * The refault distance of a page is the number of ticks that occurred
+ * between that page's eviction and subsequent refault.
+ *
+ * Every page slot that is taken away from the inactive list is one
+ * more slot the inactive list would have to grow again in order to
+ * hold the current non-resident pages in memory as well.
+ *
+ * As the refault distance needs to reflect the space missing on the
+ * inactive list, the workingset time is advanced every time the
+ * inactive list is shrunk.  This means eviction, but also activation.
+ */
+static atomic_long_t workingset_time;
+
+/*
+ * Workingset clock snapshots are stored in the page cache radix tree
+ * as exceptional entries (shadows).
+ */
+#define EV_SHIFT	RADIX_TREE_EXCEPTIONAL_SHIFT
+#define EV_MASK		(~0UL >> EV_SHIFT)
+
+/*
+ * Per-zone proportional eviction counter to keep track of recent zone
+ * eviction speed and be able to calculate per-zone refault distances.
+ */
+static struct prop_descriptor global_evictions;
+
+void *workingset_eviction(struct address_space *mapping, struct page *page)
+{
+	struct lruvec *lruvec;
+	unsigned long time;
+
+	time = atomic_long_inc_return(&workingset_time);
+
+	lruvec = mem_cgroup_zone_lruvec(page_zone(page), NULL);
+	prop_inc_percpu(&global_evictions, &lruvec->evictions);
+
+	/*
+	 * Don't store shadows in an inode that is being reclaimed.
+	 * This is not just an optizimation, inode reclaim needs to
+	 * empty out the radix tree or the nodes are lost, so don't
+	 * plant shadows behind its back.
+	 */
+	if (mapping_exiting(mapping))
+		return NULL;
+
+	return (void *)((time << EV_SHIFT) | RADIX_TREE_EXCEPTIONAL_ENTRY);
+}
+
+unsigned long workingset_refault_distance(struct page *page)
+{
+	unsigned long time_of_eviction;
+	unsigned long now;
+
+	if (!page)
+		return ~0UL;
+
+	BUG_ON(!radix_tree_exceptional_entry(page));
+	time_of_eviction = (unsigned long)page >> EV_SHIFT;
+	now = atomic_long_read(&workingset_time);
+	return (now - time_of_eviction) & EV_MASK;
+}
+EXPORT_SYMBOL(workingset_refault_distance);
+
+void workingset_zone_balance(struct zone *zone, unsigned long refault_distance)
+{
+	struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, NULL);
+	unsigned long zone_active;
+	unsigned long zone_free;
+	unsigned long missing;
+	long denominator;
+	long numerator;
+
+	/*
+	 * The dirty balance reserve is a generous estimation of the
+	 * zone's memory reserve that is not available to page cache.
+	 * If the zone has more free pages than that, it means that
+	 * there are pages ready to allocate without reclaiming from
+	 * the zone at all, let alone putting pressure on its active
+	 * pages.
+	 */
+	zone_free = zone_page_state(zone, NR_FREE_PAGES);
+	if (zone_free > zone->dirty_balance_reserve)
+		return;
+
+	/*
+	 * Pages with a refault distance bigger than available memory
+	 * won't fit in memory no matter what, leave the active pages
+	 * alone.  This also makes sure the multiplication below does
+	 * not overflow.
+	 */
+	if (refault_distance > global_dirtyable_memory())
+		return;
+
+	/*
+	 * Translate the global refault distance using the zone's
+	 * share of global evictions, to make it comparable to the
+	 * zone's number of active and free pages.
+	 */
+	prop_fraction_percpu(&global_evictions, &lruvec->evictions,
+			     &numerator, &denominator);
+	missing = refault_distance * numerator;
+	do_div(missing, denominator);
+
+	/*
+	 * Protected pages should be challenged when the refault
+	 * distance indicates that thrashing could be stopped by
+	 * increasing the inactive list at the cost of the active
+	 * list.
+	 */
+	zone_active = zone_page_state(zone, NR_ACTIVE_FILE);
+	if (missing > zone_active)
+		return;
+
+	inc_zone_state(zone, WORKINGSET_STALE);
+	lruvec->shrink_active++;
+}
+
+void workingset_activation(struct page *page)
+{
+	struct lruvec *lruvec;
+
+	atomic_long_inc(&workingset_time);
+
+	/*
+	 * The lists are rebalanced when the inactive list is observed
+	 * to be too small for activations.  An activation means that
+	 * the inactive list is now big enough again for at least one
+	 * page, so back off further deactivation.
+	 */
+	lruvec = mem_cgroup_zone_lruvec(page_zone(page), NULL);
+	if (lruvec->shrink_active > 0)
+		lruvec->shrink_active--;
+}
+
+static int __init workingset_init(void)
+{
+	int shift;
+
+	/* XXX: adapt shift during memory hotplug */
+	shift = ilog2(global_dirtyable_memory() - 1);
+	prop_descriptor_init(&global_evictions, shift);
+	return 0;
+}
+module_init(workingset_init);
-- 
1.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
