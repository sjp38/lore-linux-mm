From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070808161524.32320.87008.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070808161504.32320.79576.sendpatchset@skynet.skynet.ie>
References: <20070808161504.32320.79576.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 1/3] Use zonelists instead of zones when direct reclaiming pages
Date: Wed,  8 Aug 2007 17:15:24 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee.Schermerhorn@hp.com, pj@sgi.com, ak@suse.de, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
Cc: Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The allocator deals with zonelists which indicate the order in which zones
should be targeted for an allocation. Similarly, direct reclaim of pages
iterates over an array of zones. For consistency, this patch converts direct
reclaim to use a zonelist. No functionality is changed by this patch. This
simplifies zonelist iterators in the next patch.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 include/linux/swap.h |    2 +-
 mm/page_alloc.c      |    2 +-
 mm/vmscan.c          |    4 +++-
 3 files changed, 5 insertions(+), 3 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc1-mm2-clean/include/linux/swap.h linux-2.6.23-rc1-mm2-005_freepages_zonelist/include/linux/swap.h
--- linux-2.6.23-rc1-mm2-clean/include/linux/swap.h	2007-08-07 14:45:11.000000000 +0100
+++ linux-2.6.23-rc1-mm2-005_freepages_zonelist/include/linux/swap.h	2007-08-08 11:35:00.000000000 +0100
@@ -189,7 +189,7 @@ extern int rotate_reclaimable_page(struc
 extern void swap_setup(void);
 
 /* linux/mm/vmscan.c */
-extern unsigned long try_to_free_pages(struct zone **zones, int order,
+extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc1-mm2-clean/mm/page_alloc.c linux-2.6.23-rc1-mm2-005_freepages_zonelist/mm/page_alloc.c
--- linux-2.6.23-rc1-mm2-clean/mm/page_alloc.c	2007-08-07 14:45:11.000000000 +0100
+++ linux-2.6.23-rc1-mm2-005_freepages_zonelist/mm/page_alloc.c	2007-08-08 11:35:00.000000000 +0100
@@ -1644,7 +1644,7 @@ nofail_alloc:
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	did_some_progress = try_to_free_pages(zonelist->zones, order, gfp_mask);
+	did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
 
 	p->reclaim_state = NULL;
 	p->flags &= ~PF_MEMALLOC;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc1-mm2-clean/mm/vmscan.c linux-2.6.23-rc1-mm2-005_freepages_zonelist/mm/vmscan.c
--- linux-2.6.23-rc1-mm2-clean/mm/vmscan.c	2007-08-07 14:45:11.000000000 +0100
+++ linux-2.6.23-rc1-mm2-005_freepages_zonelist/mm/vmscan.c	2007-08-08 11:35:00.000000000 +0100
@@ -1127,7 +1127,8 @@ static unsigned long shrink_zones(int pr
  * holds filesystem locks which prevent writeout this might not work, and the
  * allocation attempt will fail.
  */
-unsigned long try_to_free_pages(struct zone **zones, int order, gfp_t gfp_mask)
+unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
+								gfp_t gfp_mask)
 {
 	int priority;
 	int ret = 0;
@@ -1135,6 +1136,7 @@ unsigned long try_to_free_pages(struct z
 	unsigned long nr_reclaimed = 0;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long lru_pages = 0;
+	struct zone **zones = zonelist->zones;
 	int i;
 	struct scan_control sc = {
 		.gfp_mask = gfp_mask,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
