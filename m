Date: Tue, 17 Jan 2006 15:10:05 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [RFC] Additional features for zone reclaim
Message-ID: <Pine.LNX.4.62.0601171507580.28915@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ak@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch adds the ability to shrink the cache if a zone runs out of
memory or to start swapping out pages on a node. The slab shrink
has some issues since it is global and not related to the zone.
One could add support for zone specifications to the shrinker to
make that work. Got a patch halfway done that would modify all
shrinkers to take an additional zone parameters. But is that worth it?

Index: linux-2.6.15-mm4/mm/vmscan.c
===================================================================
--- linux-2.6.15-mm4.orig/mm/vmscan.c	2006-01-17 12:29:38.000000000 -0800
+++ linux-2.6.15-mm4/mm/vmscan.c	2006-01-17 14:40:00.000000000 -0800
@@ -1827,17 +1827,20 @@ module_init(kswapd_init)
  *
  * If non-zero call zone_reclaim when the number of free pages falls below
  * the watermarks.
- *
- * In the future we may add flags to the mode. However, the page allocator
- * should only have to check that zone_reclaim_mode != 0 before calling
- * zone_reclaim().
  */
+
+#define RECLAIM_OFF 0
+#define RECLAIM_ZONE (1<<0)	/* Run shrink_cache on the zone */
+#define RECLAIM_SWAP (2<<0)	/* Shrink_cache with swap out */
+#define RECLAIM_SLAB (3<<0)	/* Do a global slab shrink if the zone is out of memory */
+
 int zone_reclaim_mode __read_mostly;
 
 /*
  * Mininum time between zone reclaim scans
  */
 #define ZONE_RECLAIM_INTERVAL HZ/2
+
 /*
  * Try to free up some pages from this zone through reclaim.
  */
@@ -1849,7 +1852,7 @@ int zone_reclaim(struct zone *zone, gfp_
 	struct scan_control sc = {
 		.gfp_mask	= gfp_mask,
 		.may_writepage	= 0,
-		.may_swap	= 0,
+		.may_swap	= !!(zone_reclaim_mode & RECLAIM_SWAP),
 		.nr_mapped	= read_page_state(nr_mapped),
 		.nr_scanned	= 0,
 		.nr_reclaimed	= 0,
@@ -1877,7 +1880,11 @@ int zone_reclaim(struct zone *zone, gfp_
 	p->flags |= PF_MEMALLOC;
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
-	shrink_zone(zone, &sc);
+
+	if (zone_reclaim_mode & (RECLAIM_ZONE|RECLAIM_SWAP))
+		shrink_zone(zone, &sc);
+	if (sc.nr_reclaimed == 0 && (zone_reclaim_mode & RECLAIM_SLAB))
+		sc.nr_reclaimed = shrink_slab(sc.nr_scanned, gfp_mask, order);
 	p->reclaim_state = NULL;
 	current->flags &= ~PF_MEMALLOC;
 
Index: linux-2.6.15-mm4/Documentation/sysctl/vm.txt
===================================================================
--- linux-2.6.15-mm4.orig/Documentation/sysctl/vm.txt	2006-01-17 12:29:34.000000000 -0800
+++ linux-2.6.15-mm4/Documentation/sysctl/vm.txt	2006-01-17 14:28:25.000000000 -0800
@@ -126,6 +126,15 @@ the high water marks for each per cpu pa
 
 zone_reclaim_mode:
 
+This allows to set more or less agressive forms of reclaiming memory
+when a zone runs out of memory.
+
+This is a ORed together value of
+
+1	= Zone reclaim without swapout
+2	= Zone reclaim with swapping out pages
+4	= Slab reclaim when zone is out of memory
+
 This is set during bootup to 1 if it is determined that pages from
 remote zones will cause a significant performance reduction. The
 page allocator will then reclaim easily reusable pages (those page
@@ -135,6 +144,8 @@ The user can override this setting. It m
 off zone reclaim if the system is used for a file server and all
 of memory should be used for caching files from disk.
 
-It may be beneficial to switch this on if one wants to do zone
-reclaim regardless of the numa distances in the system.
+It may be advisable to set Slab reclaim if the system makes heavy
+use of files and builds up large slab caches and no longer has
+sufficient local memory available. Note that the slab shrink is global
+and may free slab entries on other nodes.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
