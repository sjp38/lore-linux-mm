Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f52.google.com (mail-bk0-f52.google.com [209.85.214.52])
	by kanga.kvack.org (Postfix) with ESMTP id ACA836B003A
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 13:12:03 -0500 (EST)
Received: by mail-bk0-f52.google.com with SMTP id d7so236649bkh.39
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 10:12:03 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id oj10si4473876bkb.86.2014.01.10.10.12.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 Jan 2014 10:12:02 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 7/9] mm: thrash detection-based file cache sizing
Date: Fri, 10 Jan 2014 13:10:41 -0500
Message-Id: <1389377443-11755-8-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1389377443-11755-1-git-send-email-hannes@cmpxchg.org>
References: <1389377443-11755-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

The VM maintains cached filesystem pages on two types of lists.  One
list holds the pages recently faulted into the cache, the other list
holds pages that have been referenced repeatedly on that first list.
The idea is to prefer reclaiming young pages over those that have
shown to benefit from caching in the past.  We call the recently used
list "inactive list" and the frequently used list "active list".

Currently, the VM aims for a 1:1 ratio between the lists, which is the
"perfect" trade-off between the ability to *protect* frequently used
pages and the ability to *detect* frequently used pages.  This means
that working set changes bigger than half of cache memory go
undetected and thrash indefinitely, whereas working sets bigger than
half of cache memory are unprotected against used-once streams that
don't even need caching.

Historically, every reclaim scan of the inactive list also took a
smaller number of pages from the tail of the active list and moved
them to the head of the inactive list.  This model gave established
working sets more gracetime in the face of temporary use-once streams,
but ultimately was not significantly better than a FIFO policy and
still thrashed cache based on eviction speed, rather than actual
demand for cache.

This patch solves one half of the problem by decoupling the ability to
detect working set changes from the inactive list size.  By
maintaining a history of recently evicted file pages it can detect
frequently used pages with an arbitrarily small inactive list size,
and subsequently apply pressure on the active list based on actual
demand for cache, not just overall eviction speed.

Every zone maintains a counter that tracks inactive list aging speed.
When a page is evicted, a snapshot of this counter is stored in the
now-empty page cache radix tree slot.  On refault, the minimum access
distance of the page can be assessed, to evaluate whether the page
should be part of the active list or not.

This fixes the VM's blindness towards working set changes in excess of
the inactive list.  And it's the foundation to further improve the
protection ability and reduce the minimum inactive list size of 50%.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/mmzone.h |   5 +
 include/linux/swap.h   |   5 +
 mm/Makefile            |   2 +-
 mm/filemap.c           |  61 ++++++++----
 mm/swap.c              |   2 +
 mm/vmscan.c            |  24 ++++-
 mm/vmstat.c            |   2 +
 mm/workingset.c        | 253 +++++++++++++++++++++++++++++++++++++++++++++++++
 8 files changed, 331 insertions(+), 23 deletions(-)
 create mode 100644 mm/workingset.c

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index bd791e452ad7..118ba9f51e86 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -142,6 +142,8 @@ enum zone_stat_item {
 	NUMA_LOCAL,		/* allocation from local node */
 	NUMA_OTHER,		/* allocation from other node */
 #endif
+	WORKINGSET_REFAULT,
+	WORKINGSET_ACTIVATE,
 	NR_ANON_TRANSPARENT_HUGEPAGES,
 	NR_FREE_CMA_PAGES,
 	NR_VM_ZONE_STAT_ITEMS };
@@ -392,6 +394,9 @@ struct zone {
 	spinlock_t		lru_lock;
 	struct lruvec		lruvec;
 
+	/* Evictions & activations on the inactive file list */
+	atomic_long_t		inactive_age;
+
 	unsigned long		pages_scanned;	   /* since last reclaim */
 	unsigned long		flags;		   /* zone flags, see below */
 
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 46ba0c6c219f..b83cf61403ed 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -260,6 +260,11 @@ struct swap_list_t {
 	int next;	/* swapfile to be used next */
 };
 
+/* linux/mm/workingset.c */
+void *workingset_eviction(struct address_space *mapping, struct page *page);
+bool workingset_refault(void *shadow);
+void workingset_activation(struct page *page);
+
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
 extern unsigned long totalreserve_pages;
diff --git a/mm/Makefile b/mm/Makefile
index 305d10acd081..b30aeb86abd6 100644
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
index d02db5801dda..65a374c0df4f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -469,7 +469,7 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 EXPORT_SYMBOL_GPL(replace_page_cache_page);
 
 static int page_cache_tree_insert(struct address_space *mapping,
-				  struct page *page)
+				  struct page *page, void **shadowp)
 {
 	void **slot;
 	int error;
@@ -484,6 +484,8 @@ static int page_cache_tree_insert(struct address_space *mapping,
 		radix_tree_replace_slot(slot, page);
 		mapping->nrshadows--;
 		mapping->nrpages++;
+		if (shadowp)
+			*shadowp = p;
 		return 0;
 	}
 	error = radix_tree_insert(&mapping->page_tree, page->index, page);
@@ -492,18 +494,10 @@ static int page_cache_tree_insert(struct address_space *mapping,
 	return error;
 }
 
-/**
- * add_to_page_cache_locked - add a locked page to the pagecache
- * @page:	page to add
- * @mapping:	the page's address_space
- * @offset:	page index
- * @gfp_mask:	page allocation mode
- *
- * This function is used to add a page to the pagecache. It must be locked.
- * This function does not add the page to the LRU.  The caller must do that.
- */
-int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
-		pgoff_t offset, gfp_t gfp_mask)
+static int __add_to_page_cache_locked(struct page *page,
+				      struct address_space *mapping,
+				      pgoff_t offset, gfp_t gfp_mask,
+				      void **shadowp)
 {
 	int error;
 
@@ -526,7 +520,7 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 	page->index = offset;
 
 	spin_lock_irq(&mapping->tree_lock);
-	error = page_cache_tree_insert(mapping, page);
+	error = page_cache_tree_insert(mapping, page, shadowp);
 	radix_tree_preload_end();
 	if (unlikely(error))
 		goto err_insert;
@@ -542,16 +536,49 @@ err_insert:
 	page_cache_release(page);
 	return error;
 }
+
+/**
+ * add_to_page_cache_locked - add a locked page to the pagecache
+ * @page:	page to add
+ * @mapping:	the page's address_space
+ * @offset:	page index
+ * @gfp_mask:	page allocation mode
+ *
+ * This function is used to add a page to the pagecache. It must be locked.
+ * This function does not add the page to the LRU.  The caller must do that.
+ */
+int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
+		pgoff_t offset, gfp_t gfp_mask)
+{
+	return __add_to_page_cache_locked(page, mapping, offset,
+					  gfp_mask, NULL);
+}
 EXPORT_SYMBOL(add_to_page_cache_locked);
 
 int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 				pgoff_t offset, gfp_t gfp_mask)
 {
+	void *shadow = NULL;
 	int ret;
 
-	ret = add_to_page_cache(page, mapping, offset, gfp_mask);
-	if (ret == 0)
-		lru_cache_add_file(page);
+	__set_page_locked(page);
+	ret = __add_to_page_cache_locked(page, mapping, offset,
+					 gfp_mask, &shadow);
+	if (unlikely(ret))
+		__clear_page_locked(page);
+	else {
+		/*
+		 * The page might have been evicted from cache only
+		 * recently, in which case it should be activated like
+		 * any other repeatedly accessed page.
+		 */
+		if (shadow && workingset_refault(shadow)) {
+			SetPageActive(page);
+			workingset_activation(page);
+		} else
+			ClearPageActive(page);
+		lru_cache_add(page);
+	}
 	return ret;
 }
 EXPORT_SYMBOL_GPL(add_to_page_cache_lru);
diff --git a/mm/swap.c b/mm/swap.c
index f624e5b4b724..ece5c49d6364 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -519,6 +519,8 @@ void mark_page_accessed(struct page *page)
 		else
 			__lru_cache_activate_page(page);
 		ClearPageReferenced(page);
+		if (page_is_file_cache(page))
+			workingset_activation(page);
 	} else if (!PageReferenced(page)) {
 		SetPageReferenced(page);
 	}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b954b31602cf..0d3c3d7f8c1b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -505,7 +505,8 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
  * Same as remove_mapping, but if the page is removed from the mapping, it
  * gets returned with a refcount of 0.
  */
-static int __remove_mapping(struct address_space *mapping, struct page *page)
+static int __remove_mapping(struct address_space *mapping, struct page *page,
+			    bool reclaimed)
 {
 	BUG_ON(!PageLocked(page));
 	BUG_ON(mapping != page_mapping(page));
@@ -551,10 +552,23 @@ static int __remove_mapping(struct address_space *mapping, struct page *page)
 		swapcache_free(swap, page);
 	} else {
 		void (*freepage)(struct page *);
+		void *shadow = NULL;
 
 		freepage = mapping->a_ops->freepage;
-
-		__delete_from_page_cache(page, NULL);
+		/*
+		 * Remember a shadow entry for reclaimed file cache in
+		 * order to detect refaults, thus thrashing, later on.
+		 *
+		 * But don't store shadows in an address space that is
+		 * already exiting.  This is not just an optizimation,
+		 * inode reclaim needs to empty out the radix tree or
+		 * the nodes are lost.  Don't plant shadows behind its
+		 * back.
+		 */
+		if (reclaimed && page_is_file_cache(page) &&
+		    !mapping_exiting(mapping))
+			shadow = workingset_eviction(mapping, page);
+		__delete_from_page_cache(page, shadow);
 		spin_unlock_irq(&mapping->tree_lock);
 		mem_cgroup_uncharge_cache_page(page);
 
@@ -577,7 +591,7 @@ cannot_free:
  */
 int remove_mapping(struct address_space *mapping, struct page *page)
 {
-	if (__remove_mapping(mapping, page)) {
+	if (__remove_mapping(mapping, page, false)) {
 		/*
 		 * Unfreezing the refcount with 1 rather than 2 effectively
 		 * drops the pagecache ref for us without requiring another
@@ -1047,7 +1061,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
-		if (!mapping || !__remove_mapping(mapping, page))
+		if (!mapping || !__remove_mapping(mapping, page, true))
 			goto keep_locked;
 
 		/*
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 9bb314577911..3ac830d1b533 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -770,6 +770,8 @@ const char * const vmstat_text[] = {
 	"numa_local",
 	"numa_other",
 #endif
+	"workingset_refault",
+	"workingset_activate",
 	"nr_anon_transparent_hugepages",
 	"nr_free_cma",
 	"nr_dirty_threshold",
diff --git a/mm/workingset.c b/mm/workingset.c
new file mode 100644
index 000000000000..8a6c7cff4923
--- /dev/null
+++ b/mm/workingset.c
@@ -0,0 +1,253 @@
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
+ * active list grows too big.
+ *
+ *   fault ------------------------+
+ *                                 |
+ *              +--------------+   |            +-------------+
+ *   reclaim <- |   inactive   | <-+-- demotion |    active   | <--+
+ *              +--------------+                +-------------+    |
+ *                     |                                           |
+ *                     +-------------- promotion ------------------+
+ *
+ *
+ *		Access frequency and refault distance
+ *
+ * A workload is thrashing when its pages are frequently used but they
+ * are evicted from the inactive list every time before another access
+ * would have promoted them to the active list.
+ *
+ * In cases where the average access distance between thrashing pages
+ * is bigger than the size of memory there is nothing that can be
+ * done - the thrashing set could never fit into memory under any
+ * circumstance.
+ *
+ * However, the average access distance could be bigger than the
+ * inactive list, yet smaller than the size of memory.  In this case,
+ * the set could fit into memory if it weren't for the currently
+ * active pages - which may be used more, hopefully less frequently:
+ *
+ *      +-memory available to cache-+
+ *      |                           |
+ *      +-inactive------+-active----+
+ *  a b | c d e f g h i | J K L M N |
+ *      +---------------+-----------+
+ *
+ * It is prohibitively expensive to accurately track access frequency
+ * of pages.  But a reasonable approximation can be made to measure
+ * thrashing on the inactive list, after which refaulting pages can be
+ * activated optimistically to compete with the existing active pages.
+ *
+ * Approximating inactive page access frequency - Observations:
+ *
+ * 1. When a page is accessed for the first time, it is added to the
+ *    head of the inactive list, slides every existing inactive page
+ *    towards the tail by one slot, and pushes the current tail page
+ *    out of memory.
+ *
+ * 2. When a page is accessed for the second time, it is promoted to
+ *    the active list, shrinking the inactive list by one slot.  This
+ *    also slides all inactive pages that were faulted into the cache
+ *    more recently than the activated page towards the tail of the
+ *    inactive list.
+ *
+ * Thus:
+ *
+ * 1. The sum of evictions and activations between any two points in
+ *    time indicate the minimum number of inactive pages accessed in
+ *    between.
+ *
+ * 2. Moving one inactive page N page slots towards the tail of the
+ *    list requires at least N inactive page accesses.
+ *
+ * Combining these:
+ *
+ * 1. When a page is finally evicted from memory, the number of
+ *    inactive pages accessed while the page was in cache is at least
+ *    the number of page slots on the inactive list.
+ *
+ * 2. In addition, measuring the sum of evictions and activations (E)
+ *    at the time of a page's eviction, and comparing it to another
+ *    reading (R) at the time the page faults back into memory tells
+ *    the minimum number of accesses while the page was not cached.
+ *    This is called the refault distance.
+ *
+ * Because the first access of the page was the fault and the second
+ * access the refault, we combine the in-cache distance with the
+ * out-of-cache distance to get the complete minimum access distance
+ * of this page:
+ *
+ *      NR_inactive + (R - E)
+ *
+ * And knowing the minimum access distance of a page, we can easily
+ * tell if the page would be able to stay in cache assuming all page
+ * slots in the cache were available:
+ *
+ *   NR_inactive + (R - E) <= NR_inactive + NR_active
+ *
+ * which can be further simplified to
+ *
+ *   (R - E) <= NR_active
+ *
+ * Put into words, the refault distance (out-of-cache) can be seen as
+ * a deficit in inactive list space (in-cache).  If the inactive list
+ * had (R - E) more page slots, the page would not have been evicted
+ * in between accesses, but activated instead.  And on a full system,
+ * the only thing eating into inactive list space is active pages.
+ *
+ *
+ *		Activating refaulting pages
+ *
+ * All that is known about the active list is that the pages have been
+ * accessed more than once in the past.  This means that at any given
+ * time there is actually a good chance that pages on the active list
+ * are no longer in active use.
+ *
+ * So when a refault distance of (R - E) is observed and there are at
+ * least (R - E) active pages, the refaulting page is activated
+ * optimistically in the hope that (R - E) active pages are actually
+ * used less frequently than the refaulting page - or even not used at
+ * all anymore.
+ *
+ * If this is wrong and demotion kicks in, the pages which are truly
+ * used more frequently will be reactivated while the less frequently
+ * used once will be evicted from memory.
+ *
+ * But if this is right, the stale pages will be pushed out of memory
+ * and the used pages get to stay in cache.
+ *
+ *
+ *		Implementation
+ *
+ * For each zone's file LRU lists, a counter for inactive evictions
+ * and activations is maintained (zone->inactive_age).
+ *
+ * On eviction, a snapshot of this counter (along with some bits to
+ * identify the zone) is stored in the now empty page cache radix tree
+ * slot of the evicted page.  This is called a shadow entry.
+ *
+ * On cache misses for which there are shadow entries, an eligible
+ * refault distance will immediately activate the refaulting page.
+ */
+
+static void *pack_shadow(unsigned long eviction, struct zone *zone)
+{
+	eviction = (eviction << NODES_SHIFT) | zone_to_nid(zone);
+	eviction = (eviction << ZONES_SHIFT) | zone_idx(zone);
+	eviction = (eviction << RADIX_TREE_EXCEPTIONAL_SHIFT);
+
+	return (void *)(eviction | RADIX_TREE_EXCEPTIONAL_ENTRY);
+}
+
+static void unpack_shadow(void *shadow,
+			  struct zone **zone,
+			  unsigned long *distance)
+{
+	unsigned long entry = (unsigned long)shadow;
+	unsigned long eviction;
+	unsigned long refault;
+	unsigned long mask;
+	int zid, nid;
+
+	entry >>= RADIX_TREE_EXCEPTIONAL_SHIFT;
+	zid = entry & ((1UL << ZONES_SHIFT) - 1);
+	entry >>= ZONES_SHIFT;
+	nid = entry & ((1UL << NODES_SHIFT) - 1);
+	entry >>= NODES_SHIFT;
+	eviction = entry;
+
+	*zone = NODE_DATA(nid)->node_zones + zid;
+
+	refault = atomic_long_read(&(*zone)->inactive_age);
+	mask = ~0UL >> (NODES_SHIFT + ZONES_SHIFT +
+			RADIX_TREE_EXCEPTIONAL_SHIFT);
+	/*
+	 * The unsigned subtraction here gives an accurate distance
+	 * across inactive_age overflows in most cases.
+	 *
+	 * There is a special case: usually, shadow entries have a
+	 * short lifetime and are either refaulted or reclaimed along
+	 * with the inode before they get too old.  But it is not
+	 * impossible for the inactive_age to lap a shadow entry in
+	 * the field, which can then can result in a false small
+	 * refault distance, leading to a false activation should this
+	 * old entry actually refault again.  However, earlier kernels
+	 * used to deactivate unconditionally with *every* reclaim
+	 * invocation for the longest time, so the occasional
+	 * inappropriate activation leading to pressure on the active
+	 * list is not a problem.
+	 */
+	*distance = (refault - eviction) & mask;
+}
+
+/**
+ * workingset_eviction - note the eviction of a page from memory
+ * @mapping: address space the page was backing
+ * @page: the page being evicted
+ *
+ * Returns a shadow entry to be stored in @mapping->page_tree in place
+ * of the evicted @page so that a later refault can be detected.
+ */
+void *workingset_eviction(struct address_space *mapping, struct page *page)
+{
+	struct zone *zone = page_zone(page);
+	unsigned long eviction;
+
+	eviction = atomic_long_inc_return(&zone->inactive_age);
+	return pack_shadow(eviction, zone);
+}
+
+/**
+ * workingset_refault - evaluate the refault of a previously evicted page
+ * @shadow: shadow entry of the evicted page
+ *
+ * Calculates and evaluates the refault distance of the previously
+ * evicted page in the context of the zone it was allocated in.
+ *
+ * Returns %true if the page should be activated, %false otherwise.
+ */
+bool workingset_refault(void *shadow)
+{
+	unsigned long refault_distance;
+	struct zone *zone;
+
+	unpack_shadow(shadow, &zone, &refault_distance);
+	inc_zone_state(zone, WORKINGSET_REFAULT);
+
+	if (refault_distance <= zone_page_state(zone, NR_ACTIVE_FILE)) {
+		inc_zone_state(zone, WORKINGSET_ACTIVATE);
+		return true;
+	}
+	return false;
+}
+
+/**
+ * workingset_activation - note a page activation
+ * @page: page that is being activated
+ */
+void workingset_activation(struct page *page)
+{
+	atomic_long_inc(&page_zone(page)->inactive_age);
+}
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
