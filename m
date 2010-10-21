Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AA8795F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 14:00:41 -0400 (EDT)
Date: Thu, 21 Oct 2010 13:00:37 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: shrinkers: Add node to indicate where to target shrinking
In-Reply-To: <alpine.DEB.2.00.1010211255570.24115@router.home>
Message-ID: <alpine.DEB.2.00.1010211259360.24115@router.home>
References: <alpine.DEB.2.00.1010211255570.24115@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

Add a field node to struct shrinker that can be used to indicate on which
node the reclaim should occur. The node field also can be set to NUMA_NO_NODE
in which case a reclaim pass over all nodes is desired.

NUMA_NO_NODE will be used for direct reclaim since reclaim is not specific
there (Some issues are still left since we are not respecting boundaries of
memory policies and cpusets).

A node will be supplied for kswap and zone reclaim invocations of zone reclaim.
It is also possible then for the shrinker invocation from mm/memory-failure.c
to indicate the node for which caches need to be shrunk.

After this patch it is possible to make shrinkers node aware by checking
the node field of struct shrinker. If a shrinker does not support per node
reclaim then it can still do global reclaim.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 fs/drop_caches.c    |    3 ++-
 include/linux/mm.h  |    3 ++-
 mm/memory-failure.c |    3 ++-
 mm/vmscan.c         |   23 +++++++++--------------
 4 files changed, 15 insertions(+), 17 deletions(-)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h	2010-10-21 12:46:48.000000000 -0500
+++ linux-2.6/include/linux/mm.h	2010-10-21 12:50:31.000000000 -0500
@@ -1012,6 +1012,7 @@ static inline void sync_mm_rss(struct ta
 struct shrinker {
 	int (*shrink)(struct shrinker *, int nr_to_scan, gfp_t gfp_mask);
 	int seeks;	/* seeks to recreate an obj */
+	int node;	/* Node or NUMA_NO_NODE if global */

 	/* These are for internal use */
 	struct list_head list;
@@ -1444,7 +1445,7 @@ int in_gate_area_no_task(unsigned long a
 int drop_caches_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
 unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
-			unsigned long lru_pages);
+			unsigned long lru_pages, int node);

 #ifndef CONFIG_MMU
 #define randomize_va_space 0
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2010-10-21 12:50:21.000000000 -0500
+++ linux-2.6/mm/vmscan.c	2010-10-21 12:50:31.000000000 -0500
@@ -202,7 +202,7 @@ EXPORT_SYMBOL(unregister_shrinker);
  * Returns the number of slab objects which we shrunk.
  */
 unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
-			unsigned long lru_pages)
+			unsigned long lru_pages, int node)
 {
 	struct shrinker *shrinker;
 	unsigned long ret = 0;
@@ -218,6 +218,7 @@ unsigned long shrink_slab(unsigned long
 		unsigned long total_scan;
 		unsigned long max_pass;

+		shrinker->node = node;
 		max_pass = (*shrinker->shrink)(shrinker, 0, gfp_mask);
 		delta = (4 * scanned) / shrinker->seeks;
 		delta *= max_pass;
@@ -1912,7 +1913,8 @@ static unsigned long do_try_to_free_page
 				lru_pages += zone_reclaimable_pages(zone);
 			}

-			shrink_slab(sc->nr_scanned, sc->gfp_mask, lru_pages);
+			shrink_slab(sc->nr_scanned, sc->gfp_mask,
+					lru_pages, NUMA_NO_NODE);
 			if (reclaim_state) {
 				sc->nr_reclaimed += reclaim_state->reclaimed_slab;
 				reclaim_state->reclaimed_slab = 0;
@@ -2222,7 +2224,7 @@ loop_again:
 			if (zone_idx(zone) == ZONE_NORMAL) {
 				reclaim_state->reclaimed_slab = 0;
 				nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
-							lru_pages);
+						lru_pages, zone_to_nid(zone));
 				sc.nr_reclaimed += reclaim_state->reclaimed_slab;
 				total_scanned += sc.nr_scanned;
 			} else
@@ -2705,21 +2707,14 @@ static int __zone_reclaim(struct zone *z
 	nr_slab_pages0 = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
 	if (nr_slab_pages0 > zone->min_slab_pages &&
 					zone_idx(zone) == ZONE_NORMAL) {
-		/*
-		 * shrink_slab() does not currently allow us to determine how
-		 * many pages were freed in this zone. So we take the current
-		 * number of slab pages and shake the slab until it is reduced
-		 * by the same nr_pages that we used for reclaiming unmapped
-		 * pages.
-		 *
-		 * Note that shrink_slab will free memory on all zones and may
-		 * take a long time.
-		 */
+
+
 		for (;;) {
 			unsigned long lru_pages = zone_reclaimable_pages(zone);

 			/* No reclaimable slab or very low memory pressure */
-			if (!shrink_slab(sc.nr_scanned, gfp_mask, lru_pages))
+			if (!shrink_slab(sc.nr_scanned, gfp_mask,
+					lru_pages, zone_to_nid(zone)))
 				break;

 			/* Freed enough memory */
Index: linux-2.6/fs/drop_caches.c
===================================================================
--- linux-2.6.orig/fs/drop_caches.c	2010-10-21 12:46:48.000000000 -0500
+++ linux-2.6/fs/drop_caches.c	2010-10-21 12:50:31.000000000 -0500
@@ -38,7 +38,8 @@ static void drop_slab(void)
 	int nr_objects;

 	do {
-		nr_objects = shrink_slab(1000, GFP_KERNEL, 1000);
+		nr_objects = shrink_slab(1000, GFP_KERNEL,
+					1000, NUMA_NO_NODE);
 	} while (nr_objects > 10);
 }

Index: linux-2.6/mm/memory-failure.c
===================================================================
--- linux-2.6.orig/mm/memory-failure.c	2010-10-21 12:46:48.000000000 -0500
+++ linux-2.6/mm/memory-failure.c	2010-10-21 12:50:31.000000000 -0500
@@ -234,7 +234,8 @@ void shake_page(struct page *p, int acce
 	if (access) {
 		int nr;
 		do {
-			nr = shrink_slab(1000, GFP_KERNEL, 1000);
+			nr = shrink_slab(1000, GFP_KERNEL,
+					1000, page_to_nid(p));
 			if (page_count(p) == 1)
 				break;
 		} while (nr > 10);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
