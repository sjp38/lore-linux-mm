Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 018406B0069
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 18:44:55 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 8/9] mm: thrash detection-based file cache sizing
Date: Tue,  6 Aug 2013 18:44:09 -0400
Message-Id: <1375829050-12654-9-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1375829050-12654-1-git-send-email-hannes@cmpxchg.org>
References: <1375829050-12654-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

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

To accomplish this, a per-zone counter is increased every time a page
is evicted and a snapshot of that counter is stored as shadow entry in
the page's now empty page cache radix tree slot.  Upon refault of that
page, the difference between the current value of that counter and the
shadow entry value is called the refault distance.  It tells how many
pages have been evicted from the zone since that page's eviction,
which is how many page slots are missing from the zone's inactive list
for this page to get accessed twice while in memory.  If the number of
missing slots is less than or equal to the number of active pages,
increasing the inactive list at the cost of the active list would give
this thrashing set a chance to establish itself:

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

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/mmzone.h  |   6 ++
 include/linux/pagemap.h |   2 +
 include/linux/swap.h    |   5 ++
 mm/Makefile             |   2 +-
 mm/filemap.c            |   3 +
 mm/swap.c               |   2 +
 mm/vmscan.c             |  62 +++++++++++---
 mm/vmstat.c             |   3 +
 mm/workingset.c         | 213 ++++++++++++++++++++++++++++++++++++++++++++++++
 9 files changed, 284 insertions(+), 14 deletions(-)
 create mode 100644 mm/workingset.c

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 0c41d59..e75fc92 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -141,6 +141,9 @@ enum zone_stat_item {
 	NUMA_LOCAL,		/* allocation from local node */
 	NUMA_OTHER,		/* allocation from other node */
 #endif
+	WORKINGSET_STALE,
+	WORKINGSET_BALANCE,
+	WORKINGSET_BALANCE_FORCE,
 	NR_ANON_TRANSPARENT_HUGEPAGES,
 	NR_FREE_CMA_PAGES,
 	NR_VM_ZONE_STAT_ITEMS };
@@ -393,6 +396,9 @@ struct zone {
 	spinlock_t		lru_lock;
 	struct lruvec		lruvec;
 
+	atomic_long_t		workingset_time;
+	long			shrink_active;
+
 	unsigned long		pages_scanned;	   /* since last reclaim */
 	unsigned long		flags;		   /* zone flags, see below */
 
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 4b24236..c6beed2 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -232,6 +232,8 @@ extern struct page *__page_cache_alloc(gfp_t gfp, struct page *shadow);
 #else
 static inline struct page *__page_cache_alloc(gfp_t gfp, struct page *shadow)
 {
+	if (shadow)
+		workingset_refault(shadow);
 	return alloc_pages(gfp, 0);
 }
 #endif
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 24db914..441845d 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -260,6 +260,11 @@ struct swap_list_t {
 	int next;	/* swapfile to be used next */
 };
 
+/* linux/mm/workingset.c */
+void *workingset_eviction(struct address_space *mapping, struct page *page);
+void workingset_refault(void *shadow);
+void workingset_activation(struct page *page);
+
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
 extern unsigned long totalreserve_pages;
diff --git a/mm/Makefile b/mm/Makefile
index cd0abd8..f740427 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -17,7 +17,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 			   util.o mmzone.o vmstat.o backing-dev.o \
 			   mm_init.o mmu_context.o percpu.o slab_common.o \
 			   compaction.o balloon_compaction.o \
-			   interval_tree.o list_lru.o $(mmu-y)
+			   interval_tree.o list_lru.o workingset.o $(mmu-y)
 
 obj-y += init-mm.o
 
diff --git a/mm/filemap.c b/mm/filemap.c
index d3e5578..ab4351e 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -543,6 +543,9 @@ struct page *__page_cache_alloc(gfp_t gfp, struct page *shadow)
 	int n;
 	struct page *page;
 
+	if (shadow)
+		workingset_refault(shadow);
+
 	if (cpuset_do_page_mem_spread()) {
 		unsigned int cpuset_mems_cookie;
 		do {
diff --git a/mm/swap.c b/mm/swap.c
index bf448cf..f90a331 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -482,6 +482,8 @@ void mark_page_accessed(struct page *page)
 		else
 			__lru_cache_activate_page(page);
 		ClearPageReferenced(page);
+		if (page_is_file_cache(page))
+			workingset_activation(page);
 	} else if (!PageReferenced(page)) {
 		SetPageReferenced(page);
 	}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index dd5f67c..27a36f6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -496,7 +496,8 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
  * Same as remove_mapping, but if the page is removed from the mapping, it
  * gets returned with a refcount of 0.
  */
-static int __remove_mapping(struct address_space *mapping, struct page *page)
+static int __remove_mapping(struct address_space *mapping, struct page *page,
+			    bool reclaimed)
 {
 	BUG_ON(!PageLocked(page));
 	BUG_ON(mapping != page_mapping(page));
@@ -542,10 +543,13 @@ static int __remove_mapping(struct address_space *mapping, struct page *page)
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
 
@@ -568,7 +572,7 @@ cannot_free:
  */
 int remove_mapping(struct address_space *mapping, struct page *page)
 {
-	if (__remove_mapping(mapping, page)) {
+	if (__remove_mapping(mapping, page, false)) {
 		/*
 		 * Unfreezing the refcount with 1 rather than 2 effectively
 		 * drops the pagecache ref for us without requiring another
@@ -1038,7 +1042,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
-		if (!mapping || !__remove_mapping(mapping, page))
+		if (!mapping || !__remove_mapping(mapping, page, true))
 			goto keep_locked;
 
 		/*
@@ -1746,32 +1750,64 @@ static inline int inactive_anon_is_low(struct lruvec *lruvec)
 /**
  * inactive_file_is_low - check if file pages need to be deactivated
  * @lruvec: LRU vector to check
+ * @nr_to_scan: number of active pages to scan
+ * @sc: scan parameters
  *
  * When the system is doing streaming IO, memory pressure here
  * ensures that active file pages get deactivated, until more
  * than half of the file pages are on the inactive list.
  *
- * Once we get to that situation, protect the system's working
- * set from being evicted by disabling active file page aging.
+ * Once we get to that situation, protect the system's working set
+ * from being evicted by disabling active file page aging, until
+ * thrashing on the inactive list suggests that a new working set is
+ * trying to form.
  *
  * This uses a different ratio than the anonymous pages, because
  * the page cache uses a use-once replacement algorithm.
  */
-static int inactive_file_is_low(struct lruvec *lruvec)
+static int inactive_file_is_low(struct lruvec *lruvec,
+				unsigned long nr_to_scan,
+				struct scan_control *sc)
 {
+	struct zone *zone = lruvec_zone(lruvec);
 	unsigned long inactive;
 	unsigned long active;
 
+	if (global_reclaim(sc)) {
+		if (zone->shrink_active > 0) {
+			if (nr_to_scan) {
+				inc_zone_state(zone, WORKINGSET_BALANCE);
+				zone->shrink_active -= nr_to_scan;
+			}
+			return true;
+		}
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
+		if (global_reclaim(sc) && nr_to_scan)
+			inc_zone_state(zone, WORKINGSET_BALANCE_FORCE);
+		return true;
+	}
+	return false;
 }
 
-static int inactive_list_is_low(struct lruvec *lruvec, enum lru_list lru)
+static int inactive_list_is_low(struct lruvec *lruvec, enum lru_list lru,
+				unsigned long nr_to_scan,
+				struct scan_control *sc)
 {
 	if (is_file_lru(lru))
-		return inactive_file_is_low(lruvec);
+		return inactive_file_is_low(lruvec, nr_to_scan, sc);
 	else
 		return inactive_anon_is_low(lruvec);
 }
@@ -1780,7 +1816,7 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 				 struct lruvec *lruvec, struct scan_control *sc)
 {
 	if (is_active_lru(lru)) {
-		if (inactive_list_is_low(lruvec, lru))
+		if (inactive_list_is_low(lruvec, lru, nr_to_scan, sc))
 			shrink_active_list(nr_to_scan, lruvec, sc, lru);
 		return 0;
 	}
@@ -1891,7 +1927,7 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 	 * There is enough inactive page cache, do not reclaim
 	 * anything from the anonymous working set right now.
 	 */
-	if (!inactive_file_is_low(lruvec)) {
+	if (!inactive_file_is_low(lruvec, 0, sc)) {
 		scan_balance = SCAN_FILE;
 		goto out;
 	}
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 87228c5..2b14f7a 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -738,6 +738,9 @@ const char * const vmstat_text[] = {
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
index 0000000..65714d2
--- /dev/null
+++ b/mm/workingset.c
@@ -0,0 +1,213 @@
+/*
+ * Workingset detection
+ *
+ * Copyright (C) 2013 Red Hat, Inc., Johannes Weiner
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
+static void *pack_shadow(unsigned long time, struct zone *zone)
+{
+	time = (time << NODES_SHIFT) | zone_to_nid(zone);
+	time = (time << ZONES_SHIFT) | zone_idx(zone);
+	time = (time << RADIX_TREE_EXCEPTIONAL_SHIFT);
+
+	return (void *)(time | RADIX_TREE_EXCEPTIONAL_ENTRY);
+}
+
+static void unpack_shadow(void *shadow,
+			  struct zone **zone,
+			  unsigned long *distance)
+{
+	unsigned long entry = (unsigned long)shadow;
+	unsigned long time_of_eviction;
+	unsigned long mask;
+	unsigned long now;
+	int zid, nid;
+
+	entry >>= RADIX_TREE_EXCEPTIONAL_SHIFT;
+	zid = entry & ((1UL << ZONES_SHIFT) - 1);
+	entry >>= ZONES_SHIFT;
+	nid = entry & ((1UL << NODES_SHIFT) - 1);
+	entry >>= NODES_SHIFT;
+	time_of_eviction = entry;
+
+	*zone = NODE_DATA(nid)->node_zones + zid;
+
+	now = atomic_long_read(&(*zone)->workingset_time);
+	mask = ~0UL >> (RADIX_TREE_EXCEPTIONAL_SHIFT +
+			ZONES_SHIFT + NODES_SHIFT);
+
+	*distance = (now - time_of_eviction) & mask;
+}
+
+/**
+ * workingset_eviction - note the eviction of a page from memory
+ * @mapping: address space the page was backing
+ * @page: the page being evicted
+ *
+ * Returns a shadow entry to be stored in @mapping->page_tree in place
+ * of the evicted @page so that a later refault can be detected.  Or
+ * %NULL when the eviction should not be remembered.
+ */
+void *workingset_eviction(struct address_space *mapping, struct page *page)
+{
+	struct zone *zone = page_zone(page);
+	unsigned long time;
+
+	time = atomic_long_inc_return(&zone->workingset_time);
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
+	return pack_shadow(time, zone);
+}
+
+/**
+ * workingset_refault - note the refault of a previously evicted page
+ * @shadow: shadow entry of the evicted page
+ *
+ * Calculates and evaluates the refault distance of the previously
+ * evicted page in the context of the zone it was allocated in.
+ *
+ * This primes page reclaim to rebalance the zone's file lists if
+ * necessary, so it must be called before a page frame for the
+ * refaulting page is allocated.
+ */
+void workingset_refault(void *shadow)
+{
+	unsigned long refault_distance;
+	unsigned long zone_active;
+	unsigned long zone_free;
+	struct zone *zone;
+
+	unpack_shadow(shadow, &zone, &refault_distance);
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
+	 * Protected pages should be challenged when the refault
+	 * distance indicates that thrashing could be stopped by
+	 * increasing the inactive list at the cost of the active
+	 * list.
+	 */
+	zone_active = zone_page_state(zone, NR_ACTIVE_FILE);
+	if (refault_distance > zone_active)
+		return;
+
+	inc_zone_state(zone, WORKINGSET_STALE);
+	zone->shrink_active++;
+}
+EXPORT_SYMBOL(workingset_refault);
+
+/**
+ * workingset_activation - note a page activation
+ * @page: page that is being activated
+ */
+void workingset_activation(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+	/*
+	 * The lists are rebalanced when the inactive list is observed
+	 * to be too small for activations.  An activation means that
+	 * the inactive list is now big enough again for at least one
+	 * page, so back off further deactivation.
+	 */
+	atomic_long_inc(&zone->workingset_time);
+	if (zone->shrink_active > 0)
+		zone->shrink_active--;
+}
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
