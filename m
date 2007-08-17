From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070817201708.14792.65454.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070817201647.14792.2690.sendpatchset@skynet.skynet.ie>
References: <20070817201647.14792.2690.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 1/6] Use zonelists instead of zones when direct reclaiming pages
Date: Fri, 17 Aug 2007 21:17:08 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee.Schermerhorn@hp.com, ak@suse.de, clameter@sgi.com
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The allocator deals with zonelists which indicate the order in which zones
should be targeted for an allocation. Similarly, direct reclaim of pages
iterates over an array of zones. For consistency, this patch converts direct
reclaim to use a zonelist. No functionality is changed by this patch. This
simplifies zonelist iterators in the next patch.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Christoph Lameter <clameter@sgi.com>
---

 include/linux/swap.h |    2 +-
 mm/page_alloc.c      |    2 +-
 mm/vmscan.c          |    9 ++++++---
 3 files changed, 8 insertions(+), 5 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-clean/include/linux/swap.h linux-2.6.23-rc3-005_freepages_zonelist/include/linux/swap.h
--- linux-2.6.23-rc3-clean/include/linux/swap.h	2007-08-13 05:25:24.000000000 +0100
+++ linux-2.6.23-rc3-005_freepages_zonelist/include/linux/swap.h	2007-08-17 16:35:48.000000000 +0100
@@ -188,7 +188,7 @@ extern int rotate_reclaimable_page(struc
 extern void swap_setup(void);
 
 /* linux/mm/vmscan.c */
-extern unsigned long try_to_free_pages(struct zone **zones, int order,
+extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-clean/mm/page_alloc.c linux-2.6.23-rc3-005_freepages_zonelist/mm/page_alloc.c
--- linux-2.6.23-rc3-clean/mm/page_alloc.c	2007-08-13 05:25:24.000000000 +0100
+++ linux-2.6.23-rc3-005_freepages_zonelist/mm/page_alloc.c	2007-08-17 16:35:48.000000000 +0100
@@ -1326,7 +1326,7 @@ nofail_alloc:
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	did_some_progress = try_to_free_pages(zonelist->zones, order, gfp_mask);
+	did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
 
 	p->reclaim_state = NULL;
 	p->flags &= ~PF_MEMALLOC;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-clean/mm/vmscan.c linux-2.6.23-rc3-005_freepages_zonelist/mm/vmscan.c
--- linux-2.6.23-rc3-clean/mm/vmscan.c	2007-08-13 05:25:24.000000000 +0100
+++ linux-2.6.23-rc3-005_freepages_zonelist/mm/vmscan.c	2007-08-17 16:35:48.000000000 +0100
@@ -1075,10 +1075,11 @@ static unsigned long shrink_zone(int pri
  * If a zone is deemed to be full of pinned pages then just give it a light
  * scan then give up on it.
  */
-static unsigned long shrink_zones(int priority, struct zone **zones,
+static unsigned long shrink_zones(int priority, struct zonelist *zonelist,
 					struct scan_control *sc)
 {
 	unsigned long nr_reclaimed = 0;
+	struct zones **zones = zonelist->zones;
 	int i;
 
 	sc->all_unreclaimable = 1;
@@ -1116,7 +1117,8 @@ static unsigned long shrink_zones(int pr
  * holds filesystem locks which prevent writeout this might not work, and the
  * allocation attempt will fail.
  */
-unsigned long try_to_free_pages(struct zone **zones, int order, gfp_t gfp_mask)
+unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
+								gfp_t gfp_mask)
 {
 	int priority;
 	int ret = 0;
@@ -1124,6 +1126,7 @@ unsigned long try_to_free_pages(struct z
 	unsigned long nr_reclaimed = 0;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long lru_pages = 0;
+	struct zone **zones = zonelist->zones;
 	int i;
 	struct scan_control sc = {
 		.gfp_mask = gfp_mask,
@@ -1150,7 +1153,7 @@ unsigned long try_to_free_pages(struct z
 		sc.nr_scanned = 0;
 		if (!priority)
 			disable_swap_token();
-		nr_reclaimed += shrink_zones(priority, zones, &sc);
+		nr_reclaimed += shrink_zones(priority, zonelist, &sc);
 		shrink_slab(sc.nr_scanned, gfp_mask, lru_pages);
 		if (reclaim_state) {
 			nr_reclaimed += reclaim_state->reclaimed_slab;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
