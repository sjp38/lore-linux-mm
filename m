Date: Thu, 23 Aug 2007 13:53:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] Reclaim if PF_MEMALLOC and no memory available V1
Message-ID: <Pine.LNX.4.64.0708231348030.18337@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@suse.de>, ak@suse.de, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

If we exhaust the reserves in the page allocator when PF_MEMALLOC is set
then no longer give up but call into reclaim with PF_MEMALLOC set.

This is in essence a recursive call back into page reclaim with another
page flag (__GFP_NOMEMALLOC) set. The recursion is bounded since potential
allocations with __GFP_NOMEMALLOC set will not enter that branch again.

Allocation under PF_MEMALLOC will no longer run out outmemory if there 
memory that is reclaimable without additional memory
allocations.

In order to make allocation-less reclaim working we need to avoid writing
pages out or swapping. So on entry to try_to_free_pages() we check for
__GFP_NOMEMALLOC. If it is set then sc.may_writepage and sc.mayswap are
switched off and we short circuit the writeout throttling.

The types of pages that can be reclaimed by a call to try_to_free_pages()
with the __GFP_NOMEMALLOC parameter are:

- Unmapped clean page cache pages.
- Mapped clean pages
- slab shrinking

We print a warning if we get into the special reclaim mode because
this means that the reserves are too low.

Changes
RFC->v1
- Allow slab shrinking in recursive reclaim (is protected by a
  semaphore and already had to deal with allocs failing under
  PF_MEMALLOC)
- Add printk to show that recursive reclaim is being used.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/vmscan.c |   25 ++++++++++++++++++++++---
 1 file changed, 22 insertions(+), 3 deletions(-)

Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2007-08-23 13:28:32.000000000 -0700
+++ linux-2.6/mm/vmscan.c	2007-08-23 13:32:42.000000000 -0700
@@ -1106,7 +1106,8 @@ static unsigned long shrink_zone(int pri
 		}
 	}
 
-	throttle_vm_writeout(sc->gfp_mask);
+	if (!(sc->gfp_mask & __GFP_NOMEMALLOC))
+		throttle_vm_writeout(sc->gfp_mask);
 
 	atomic_dec(&zone->reclaim_in_progress);
 	return nr_reclaimed;
@@ -1168,6 +1169,9 @@ static unsigned long shrink_zones(int pr
  * hope that some of these pages can be written.  But if the allocating task
  * holds filesystem locks which prevent writeout this might not work, and the
  * allocation attempt will fail.
+ *
+ * The __GFP_NOMEMALLOC flag has a special role. If it is set then no memory
+ * allocations or writeout will occur.
  */
 unsigned long try_to_free_pages(struct zone **zones, int order, gfp_t gfp_mask)
 {
@@ -1180,15 +1184,21 @@ unsigned long try_to_free_pages(struct z
 	int i;
 	struct scan_control sc = {
 		.gfp_mask = gfp_mask,
-		.may_writepage = !laptop_mode,
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
-		.may_swap = 1,
 		.swappiness = vm_swappiness,
 		.order = order,
 	};
 
 	count_vm_event(ALLOCSTALL);
 
+	if (gfp_mask & __GFP_NOMEMALLOC) {
+		if (printk_ratelimited())
+			printk(KERN_WARNING "Entering recursive reclaim due "
+					"to depleted memory reserves\n");
+	} else {
+		sc.may_writepage = !laptop_mode;
+		sc.may_swap = 1;
+	}
 	for (i = 0; zones[i] != NULL; i++) {
 		struct zone *zone = zones[i];
 
@@ -1215,6 +1225,9 @@ unsigned long try_to_free_pages(struct z
 			goto out;
 		}
 
+		if (!(gfp_mask & __GFP_NOMEMALLOC))
+			continue;
+
 		/*
 		 * Try to write back as many pages as we just scanned.  This
 		 * tends to cause slow streaming writers to write data to the
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2007-08-23 13:34:50.000000000 -0700
+++ linux-2.6/mm/page_alloc.c	2007-08-23 13:36:59.000000000 -0700
@@ -1319,6 +1319,20 @@ nofail_alloc:
 				zonelist, ALLOC_NO_WATERMARKS);
 			if (page)
 				goto got_pg;
+			/*
+			 * No memory is available at all.
+			 *
+			 * However, if we are already in reclaim then the
+			 * reclaim_state etc is already setup. Simply call
+			 * try_to_get_free_pages() with PF_MEMALLOC which
+			 * will reclaim without the need to allocate more
+			 * memory.
+			 */
+			if (p->flags & PF_MEMALLOC && wait &&
+				try_to_free_pages(zonelist->zones, order,
+						gfp_mask | __GFP_NOMEMALLOC))
+				goto restart;
+
 			if (gfp_mask & __GFP_NOFAIL) {
 				congestion_wait(WRITE, HZ/50);
 				goto nofail_alloc;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
