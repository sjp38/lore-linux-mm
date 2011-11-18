Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D48076B0069
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 04:28:14 -0500 (EST)
Received: by faas10 with SMTP id s10so5506228faa.14
        for <linux-mm@kvack.org>; Fri, 18 Nov 2011 01:28:10 -0800 (PST)
Subject: [PATCH] mm: remove struct reclaim_state
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Fri, 18 Nov 2011 13:28:06 +0300
Message-ID: <20111118092806.21688.8662.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org

Memory reclaimer want to know how much pages was reclaimed during shrinking slabs.
Currently there is special struct reclaim_state with single counter and pointer from
task-struct. Let's store counter direcly on task struct and account freed pages
unconditionally. This will reduce stack usage and simplify code in reclaimer and slab.

Logic in do_try_to_free_pages() is slightly changed, but this is ok.
Nobody calls shrink_slab() explicitly before do_try_to_free_pages(),
so there is no extra reclaim progress which we must account into scan-control.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 fs/inode.c            |    3 +--
 include/linux/sched.h |    3 +--
 include/linux/swap.h  |    8 --------
 mm/page_alloc.c       |    4 ----
 mm/slab.c             |    5 ++---
 mm/slob.c             |    5 ++---
 mm/slub.c             |    5 ++---
 mm/vmscan.c           |   24 ++++--------------------
 8 files changed, 12 insertions(+), 45 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 1f6c48d..59b9476 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -692,8 +692,7 @@ void prune_icache_sb(struct super_block *sb, int nr_to_scan)
 	else
 		__count_vm_events(PGINODESTEAL, reap);
 	spin_unlock(&sb->s_inode_lru_lock);
-	if (current->reclaim_state)
-		current->reclaim_state->reclaimed_slab += reap;
+	current->reclaimed_pages += reap;
 
 	dispose_list(&freeable);
 }
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 68daf4f..9721610 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -729,7 +729,6 @@ extern struct user_struct root_user;
 
 
 struct backing_dev_info;
-struct reclaim_state;
 
 #if defined(CONFIG_SCHEDSTATS) || defined(CONFIG_TASK_DELAY_ACCT)
 struct sched_info {
@@ -1465,7 +1464,7 @@ struct task_struct {
 #endif
 
 /* VM state */
-	struct reclaim_state *reclaim_state;
+	unsigned long reclaimed_pages;	/* for slab shrinkers */
 
 	struct backing_dev_info *backing_dev_info;
 
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 1e22e12..769229a 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -103,14 +103,6 @@ typedef struct {
 	unsigned long val;
 } swp_entry_t;
 
-/*
- * current->reclaim_state points to one of these when a task is running
- * memory reclaim
- */
-struct reclaim_state {
-	unsigned long reclaimed_slab;
-};
-
 #ifdef __KERNEL__
 
 struct address_space;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9dd443d..5f6c2b6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1948,7 +1948,6 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	int migratetype, unsigned long *did_some_progress)
 {
 	struct page *page = NULL;
-	struct reclaim_state reclaim_state;
 	bool drained = false;
 
 	cond_resched();
@@ -1957,12 +1956,9 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	cpuset_memory_pressure_bump();
 	current->flags |= PF_MEMALLOC;
 	lockdep_set_current_reclaim_state(gfp_mask);
-	reclaim_state.reclaimed_slab = 0;
-	current->reclaim_state = &reclaim_state;
 
 	*did_some_progress = try_to_free_pages(zonelist, order, gfp_mask, nodemask);
 
-	current->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
 	current->flags &= ~PF_MEMALLOC;
 
diff --git a/mm/slab.c b/mm/slab.c
index 708efe8..65b2eaa 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -88,8 +88,8 @@
 
 #include	<linux/slab.h>
 #include	<linux/mm.h>
+#include	<linux/sched.h> /* current->reclaimed_pages */
 #include	<linux/poison.h>
-#include	<linux/swap.h>
 #include	<linux/cache.h>
 #include	<linux/interrupt.h>
 #include	<linux/init.h>
@@ -1785,8 +1785,7 @@ static void kmem_freepages(struct kmem_cache *cachep, void *addr)
 		__ClearPageSlab(page);
 		page++;
 	}
-	if (current->reclaim_state)
-		current->reclaim_state->reclaimed_slab += nr_freed;
+	current->reclaimed_pages += nr_freed;
 	free_pages((unsigned long)addr, cachep->gfporder);
 }
 
diff --git a/mm/slob.c b/mm/slob.c
index 8105be4..e35fb6a 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -60,7 +60,7 @@
 #include <linux/kernel.h>
 #include <linux/slab.h>
 #include <linux/mm.h>
-#include <linux/swap.h> /* struct reclaim_state */
+#include <linux/sched.h> /* current->reclaimed_pages  */
 #include <linux/cache.h>
 #include <linux/init.h>
 #include <linux/export.h>
@@ -259,8 +259,7 @@ static void *slob_new_pages(gfp_t gfp, int order, int node)
 
 static void slob_free_pages(void *b, int order)
 {
-	if (current->reclaim_state)
-		current->reclaim_state->reclaimed_slab += 1 << order;
+	current->reclaimed_pages += 1 << order;
 	free_pages((unsigned long)b, order);
 }
 
diff --git a/mm/slub.c b/mm/slub.c
index 7d2a996..2f1381d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -10,7 +10,7 @@
  */
 
 #include <linux/mm.h>
-#include <linux/swap.h> /* struct reclaim_state */
+#include <linux/sched.h> /* current->reclaimed_pages  */
 #include <linux/module.h>
 #include <linux/bit_spinlock.h>
 #include <linux/interrupt.h>
@@ -1407,8 +1407,7 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 
 	__ClearPageSlab(page);
 	reset_page_mapcount(page);
-	if (current->reclaim_state)
-		current->reclaim_state->reclaimed_slab += pages;
+	current->reclaimed_pages += pages;
 	__free_pages(page, order);
 }
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a1893c0..58b388f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2215,7 +2215,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 {
 	int priority;
 	unsigned long total_scanned = 0;
-	struct reclaim_state *reclaim_state = current->reclaim_state;
 	struct zoneref *z;
 	struct zone *zone;
 	unsigned long writeback_threshold;
@@ -2247,11 +2246,9 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 				lru_pages += zone_reclaimable_pages(zone);
 			}
 
+			current->reclaimed_pages = 0;
 			shrink_slab(shrink, sc->nr_scanned, lru_pages);
-			if (reclaim_state) {
-				sc->nr_reclaimed += reclaim_state->reclaimed_slab;
-				reclaim_state->reclaimed_slab = 0;
-			}
+			sc->nr_reclaimed += current->reclaimed_pages;
 		}
 		total_scanned += sc->nr_scanned;
 		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
@@ -2523,7 +2520,6 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 	int i;
 	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
 	unsigned long total_scanned;
-	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long nr_soft_reclaimed;
 	unsigned long nr_soft_scanned;
 	struct scan_control sc = {
@@ -2646,9 +2642,9 @@ loop_again:
 					end_zone, 0)) {
 				shrink_zone(priority, zone, &sc);
 
-				reclaim_state->reclaimed_slab = 0;
+				current->reclaimed_pages = 0;
 				nr_slab = shrink_slab(&shrink, sc.nr_scanned, lru_pages);
-				sc.nr_reclaimed += reclaim_state->reclaimed_slab;
+				sc.nr_reclaimed += current->reclaimed_pages;
 				total_scanned += sc.nr_scanned;
 
 				if (nr_slab == 0 && !zone_reclaimable(zone))
@@ -2857,16 +2853,12 @@ static int kswapd(void *p)
 	pg_data_t *pgdat = (pg_data_t*)p;
 	struct task_struct *tsk = current;
 
-	struct reclaim_state reclaim_state = {
-		.reclaimed_slab = 0,
-	};
 	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
 
 	lockdep_set_current_reclaim_state(GFP_KERNEL);
 
 	if (!cpumask_empty(cpumask))
 		set_cpus_allowed_ptr(tsk, cpumask);
-	current->reclaim_state = &reclaim_state;
 
 	/*
 	 * Tell the memory management that we're a "memory allocator",
@@ -3011,7 +3003,6 @@ unsigned long zone_reclaimable_pages(struct zone *zone)
  */
 unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 {
-	struct reclaim_state reclaim_state;
 	struct scan_control sc = {
 		.gfp_mask = GFP_HIGHUSER_MOVABLE,
 		.may_swap = 1,
@@ -3030,12 +3021,9 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 
 	p->flags |= PF_MEMALLOC;
 	lockdep_set_current_reclaim_state(sc.gfp_mask);
-	reclaim_state.reclaimed_slab = 0;
-	p->reclaim_state = &reclaim_state;
 
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc, &shrink);
 
-	p->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
 	p->flags &= ~PF_MEMALLOC;
 
@@ -3196,7 +3184,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	/* Minimum pages needed in order to stay on node */
 	const unsigned long nr_pages = 1 << order;
 	struct task_struct *p = current;
-	struct reclaim_state reclaim_state;
 	int priority;
 	struct scan_control sc = {
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
@@ -3220,8 +3207,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	 */
 	p->flags |= PF_MEMALLOC | PF_SWAPWRITE;
 	lockdep_set_current_reclaim_state(gfp_mask);
-	reclaim_state.reclaimed_slab = 0;
-	p->reclaim_state = &reclaim_state;
 
 	if (zone_pagecache_reclaimable(zone) > zone->min_unmapped_pages) {
 		/*
@@ -3270,7 +3255,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 			sc.nr_reclaimed += nr_slab_pages0 - nr_slab_pages1;
 	}
 
-	p->reclaim_state = NULL;
 	current->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE);
 	lockdep_clear_current_reclaim_state();
 	return sc.nr_reclaimed >= nr_pages;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
