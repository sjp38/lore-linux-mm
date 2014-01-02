Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id D9D526B003D
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 02:13:18 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id rq2so14096373pbb.16
        for <linux-mm@kvack.org>; Wed, 01 Jan 2014 23:13:18 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ll1si23308157pab.57.2014.01.01.23.13.16
        for <linux-mm@kvack.org>;
        Wed, 01 Jan 2014 23:13:17 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v10 09/16] vrange: Add core shrinking logic for swapless system
Date: Thu,  2 Jan 2014 16:12:17 +0900
Message-Id: <1388646744-15608-10-git-send-email-minchan@kernel.org>
In-Reply-To: <1388646744-15608-1-git-send-email-minchan@kernel.org>
References: <1388646744-15608-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, John Stultz <john.stultz@linaro.org>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>, Minchan Kim <minchan@kernel.org>

This patch adds the core volatile range shrinking logic needed to
allow volatile range purging to function on swapless systems
because current VM doesn't age anonymous pages in case of swapless
system.

Hook shrinking volatile pages logic into VM's reclaim path directly,
where is shrink_list which is called by kswapd and direct reclaim
everytime.

The issue I'd like to solve is that I'd like to keep volatile pages
if system are full of streaming cache pages so reclaim preference
is following as.

	used-once stream -> volatile pages -> working set

For detecting used-once stream pages, I uses simple logic(ie,
DEF_PRIORITY - 2) which is used many place in reclaim path to
detect reclaim pressure but need more testing and we might need
tune konb for that.

Anyway, with it, we can reclaim volatile pages regardless of swap
if memory pressure is tight so that we could avoid out of memory kill
and heavy I/O for swapping out.

This patch does not wire in the specific range purging logic,
but that will be added in the following patches.

Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
[jstultz: Renamed some functions and minor cleanups]
Signed-off-by: John Stultz <john.stultz@linaro.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/swap.h         |   41 +++++++++++
 include/linux/vrange.h       |   10 +++
 include/linux/vrange_types.h |    2 +
 mm/vmscan.c                  |   47 ++-----------
 mm/vrange.c                  |  159 ++++++++++++++++++++++++++++++++++++++++--
 5 files changed, 212 insertions(+), 47 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 39b3d4c6aec9..197a7799b59c 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -13,6 +13,47 @@
 #include <linux/page-flags.h>
 #include <asm/page.h>
 
+struct scan_control {
+	/* Incremented by the number of inactive pages that were scanned */
+	unsigned long nr_scanned;
+
+	/* Number of pages freed so far during a call to shrink_zones() */
+	unsigned long nr_reclaimed;
+
+	/* How many pages shrink_list() should reclaim */
+	unsigned long nr_to_reclaim;
+
+	unsigned long hibernation_mode;
+
+	/* This context's GFP mask */
+	gfp_t gfp_mask;
+
+	int may_writepage;
+
+	/* Can mapped pages be reclaimed? */
+	int may_unmap;
+
+	/* Can pages be swapped as part of reclaim? */
+	int may_swap;
+
+	int order;
+
+	/* Scan (total_size >> priority) pages at once */
+	int priority;
+
+	/*
+	 * The memory cgroup that hit its limit and as a result is the
+	 * primary target of this reclaim invocation.
+	 */
+	struct mem_cgroup *target_mem_cgroup;
+
+	/*
+	 * Nodemask of nodes allowed by the caller. If NULL, all nodes
+	 * are scanned.
+	 */
+	nodemask_t	*nodemask;
+};
+
 struct notifier_block;
 
 struct bio;
diff --git a/include/linux/vrange.h b/include/linux/vrange.h
index d9ce2ec53a34..eba155a0263c 100644
--- a/include/linux/vrange.h
+++ b/include/linux/vrange.h
@@ -12,6 +12,8 @@
 #define vrange_entry(ptr) \
 	container_of(ptr, struct vrange, node.rb)
 
+struct scan_control;
+
 #ifdef CONFIG_MMU
 
 static inline swp_entry_t make_vrange_entry(void)
@@ -57,6 +59,8 @@ int discard_vpage(struct page *page);
 bool vrange_addr_volatile(struct vm_area_struct *vma, unsigned long addr);
 extern bool vrange_addr_purged(struct vm_area_struct *vma,
 				unsigned long address);
+extern unsigned long shrink_vrange(enum lru_list lru, struct lruvec *lruvec,
+					struct scan_control *sc);
 #else
 
 static inline void vrange_root_init(struct vrange_root *vroot,
@@ -75,5 +79,11 @@ static inline bool vrange_addr_volatile(struct vm_area_struct *vma,
 static inline int discard_vpage(struct page *page) { return 0 };
 static inline bool vrange_addr_purged(struct vm_area_struct *vma,
 				unsigned long address);
+static inline unsigned long shrink_vrange(enum lru_list lru,
+		struct lruvec *lruvec, 	struct scan_control *sc)
+{
+	return 0;
+}
+
 #endif
 #endif /* _LINIUX_VRANGE_H */
diff --git a/include/linux/vrange_types.h b/include/linux/vrange_types.h
index 0d48b423dae2..d7d451cd50b6 100644
--- a/include/linux/vrange_types.h
+++ b/include/linux/vrange_types.h
@@ -20,6 +20,8 @@ struct vrange {
 	struct interval_tree_node node;
 	struct vrange_root *owner;
 	int purged;
+	struct list_head lru;
+	atomic_t refcount;
 };
 #endif
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 630723812ce3..d8f45af1ab84 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -56,47 +56,6 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/vmscan.h>
 
-struct scan_control {
-	/* Incremented by the number of inactive pages that were scanned */
-	unsigned long nr_scanned;
-
-	/* Number of pages freed so far during a call to shrink_zones() */
-	unsigned long nr_reclaimed;
-
-	/* How many pages shrink_list() should reclaim */
-	unsigned long nr_to_reclaim;
-
-	unsigned long hibernation_mode;
-
-	/* This context's GFP mask */
-	gfp_t gfp_mask;
-
-	int may_writepage;
-
-	/* Can mapped pages be reclaimed? */
-	int may_unmap;
-
-	/* Can pages be swapped as part of reclaim? */
-	int may_swap;
-
-	int order;
-
-	/* Scan (total_size >> priority) pages at once */
-	int priority;
-
-	/*
-	 * The memory cgroup that hit its limit and as a result is the
-	 * primary target of this reclaim invocation.
-	 */
-	struct mem_cgroup *target_mem_cgroup;
-
-	/*
-	 * Nodemask of nodes allowed by the caller. If NULL, all nodes
-	 * are scanned.
-	 */
-	nodemask_t	*nodemask;
-};
-
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
 
 #ifdef ARCH_HAS_PREFETCH
@@ -1806,6 +1765,12 @@ static int inactive_list_is_low(struct lruvec *lruvec, enum lru_list lru)
 static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 				 struct lruvec *lruvec, struct scan_control *sc)
 {
+	unsigned long nr_reclaimed;
+
+	nr_reclaimed = shrink_vrange(lru, lruvec, sc);
+	if (nr_reclaimed >= sc->nr_to_reclaim)
+		return nr_reclaimed;
+
 	if (is_active_lru(lru)) {
 		if (inactive_list_is_low(lruvec, lru))
 			shrink_active_list(nr_to_scan, lruvec, sc, lru);
diff --git a/mm/vrange.c b/mm/vrange.c
index f86ed33434d8..4a52b7a05f9a 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -10,13 +10,25 @@
 #include <linux/rmap.h>
 #include <linux/hugetlb.h>
 #include "internal.h"
-#include <linux/swap.h>
 #include <linux/mmu_notifier.h>
 
 static struct kmem_cache *vrange_cachep;
 
+static struct vrange_list {
+	struct list_head list;
+	spinlock_t lock;
+} vrange_list;
+
+static inline unsigned long vrange_size(struct vrange *range)
+{
+	return range->node.last + 1 - range->node.start;
+}
+
 static int __init vrange_init(void)
 {
+	INIT_LIST_HEAD(&vrange_list.list);
+	spin_lock_init(&vrange_list.lock);
+
 	vrange_cachep = KMEM_CACHE(vrange, SLAB_PANIC);
 	return 0;
 }
@@ -27,21 +39,65 @@ static struct vrange *__vrange_alloc(gfp_t flags)
 	struct vrange *vrange = kmem_cache_alloc(vrange_cachep, flags);
 	if (!vrange)
 		return vrange;
+
 	vrange->owner = NULL;
 	vrange->purged = 0;
+	INIT_LIST_HEAD(&vrange->lru);
+	atomic_set(&vrange->refcount, 1);
+
 	return vrange;
 }
 
 static void __vrange_free(struct vrange *range)
 {
 	WARN_ON(range->owner);
+	WARN_ON(atomic_read(&range->refcount) != 0);
+	WARN_ON(!list_empty(&range->lru));
+
 	kmem_cache_free(vrange_cachep, range);
 }
 
+static inline void __vrange_lru_add(struct vrange *range)
+{
+	spin_lock(&vrange_list.lock);
+	WARN_ON(!list_empty(&range->lru));
+	list_add(&range->lru, &vrange_list.list);
+	spin_unlock(&vrange_list.lock);
+}
+
+static inline void __vrange_lru_del(struct vrange *range)
+{
+	spin_lock(&vrange_list.lock);
+	if (!list_empty(&range->lru)) {
+		list_del_init(&range->lru);
+		WARN_ON(range->owner);
+	}
+	spin_unlock(&vrange_list.lock);
+}
+
 static void __vrange_add(struct vrange *range, struct vrange_root *vroot)
 {
 	range->owner = vroot;
 	interval_tree_insert(&range->node, &vroot->v_rb);
+
+	WARN_ON(atomic_read(&range->refcount) <= 0);
+	__vrange_lru_add(range);
+}
+
+static inline int __vrange_get(struct vrange *vrange)
+{
+	if (!atomic_inc_not_zero(&vrange->refcount))
+		return 0;
+
+	return 1;
+}
+
+static inline void __vrange_put(struct vrange *range)
+{
+	if (atomic_dec_and_test(&range->refcount)) {
+		__vrange_lru_del(range);
+		__vrange_free(range);
+	}
 }
 
 static void __vrange_remove(struct vrange *range)
@@ -66,6 +122,7 @@ static inline void __vrange_resize(struct vrange *range,
 	bool purged = range->purged;
 
 	__vrange_remove(range);
+	__vrange_lru_del(range);
 	__vrange_set(range, start_idx, end_idx, purged);
 	__vrange_add(range, vroot);
 }
@@ -102,7 +159,7 @@ static int vrange_add(struct vrange_root *vroot,
 		range = vrange_from_node(node);
 		/* old range covers new range fully */
 		if (node->start <= start_idx && node->last >= end_idx) {
-			__vrange_free(new_range);
+			__vrange_put(new_range);
 			goto out;
 		}
 
@@ -111,7 +168,7 @@ static int vrange_add(struct vrange_root *vroot,
 		purged |= range->purged;
 
 		__vrange_remove(range);
-		__vrange_free(range);
+		__vrange_put(range);
 
 		node = next;
 	}
@@ -152,7 +209,7 @@ static int vrange_remove(struct vrange_root *vroot,
 		if (start_idx <= node->start && end_idx >= node->last) {
 			/* argumented range covers the range fully */
 			__vrange_remove(range);
-			__vrange_free(range);
+			__vrange_put(range);
 		} else if (node->start >= start_idx) {
 			/*
 			 * Argumented range covers over the left of the
@@ -183,7 +240,7 @@ static int vrange_remove(struct vrange_root *vroot,
 	vrange_unlock(vroot);
 
 	if (!used_new)
-		__vrange_free(new_range);
+		__vrange_put(new_range);
 
 	return 0;
 }
@@ -206,7 +263,7 @@ void vrange_root_cleanup(struct vrange_root *vroot)
 	while ((node = rb_first(&vroot->v_rb))) {
 		range = vrange_entry(node);
 		__vrange_remove(range);
-		__vrange_free(range);
+		__vrange_put(range);
 	}
 	vrange_unlock(vroot);
 }
@@ -605,3 +662,93 @@ int discard_vpage(struct page *page)
 
 	return 1;
 }
+
+static struct vrange *vrange_isolate(void)
+{
+	struct vrange *vrange = NULL;
+	spin_lock(&vrange_list.lock);
+	while (!list_empty(&vrange_list.list)) {
+		vrange = list_entry(vrange_list.list.prev,
+				struct vrange, lru);
+		list_del_init(&vrange->lru);
+		/* vrange is going to destroy */
+		if (__vrange_get(vrange))
+			break;
+
+		vrange = NULL;
+	}
+
+	spin_unlock(&vrange_list.lock);
+	return vrange;
+}
+
+static int discard_vrange(struct vrange *vrange, unsigned long *nr_discard)
+{
+	return 0;
+}
+
+#define VRANGE_SCAN_THRESHOLD	(4 << 20)
+
+unsigned long shrink_vrange(enum lru_list lru, struct lruvec *lruvec,
+		struct scan_control *sc)
+{
+	int retry = 10;
+	struct vrange *range;
+	unsigned long nr_to_reclaim, total_reclaimed = 0;
+	unsigned long long scan_threshold = VRANGE_SCAN_THRESHOLD;
+
+	if (!(sc->gfp_mask & __GFP_IO))
+		return 0;
+	/*
+	 * In current implementation, VM discard volatile pages by
+	 * following preference.
+	 *
+	 * stream pages -> volatile pages -> anon pages
+	 *
+	 * If we have trouble(ie, DEF_PRIORITY - 2) with reclaiming cache
+	 * pages, it means remained cache pages is likely being working set
+	 * so it would be better to discard volatile pages rather than
+	 * evicting working set.
+	 */
+	if (lru != LRU_INACTIVE_ANON && lru != LRU_ACTIVE_ANON &&
+			sc->priority >= DEF_PRIORITY - 2)
+		return 0;
+
+	nr_to_reclaim = sc->nr_to_reclaim;
+
+	while (nr_to_reclaim > 0 && scan_threshold > 0 && retry) {
+		unsigned long nr_reclaimed = 0;
+		int ret;
+
+		range = vrange_isolate();
+		/* If there is no more vrange, stop */
+		if (!range)
+			return total_reclaimed;
+
+		/* range is removing */
+		if (!range->owner) {
+			__vrange_put(range);
+			continue;
+		}
+
+		ret = discard_vrange(range, &nr_reclaimed);
+		scan_threshold -= vrange_size(range);
+
+		/* If it's EAGAIN, retry it after a little */
+		if (ret == -EAGAIN) {
+			retry--;
+			__vrange_lru_add(range);
+			__vrange_put(range);
+			continue;
+		}
+
+		__vrange_put(range);
+		retry = 10;
+
+		total_reclaimed += nr_reclaimed;
+		if (total_reclaimed >= nr_to_reclaim)
+			break;
+	}
+
+	return total_reclaimed;
+}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
