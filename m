Message-ID: <41130FB1.5020001@yahoo.com.au>
Date: Fri, 06 Aug 2004 14:57:21 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH] 1/4: rework alloc_pages
Content-Type: multipart/mixed;
 boundary="------------080300040901090603080103"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------080300040901090603080103
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Here are a few of the more harmless mm patches I have been sitting on
for a while. They've had some testing in my tree (which does get used
by a handful of people).

--------------080300040901090603080103
Content-Type: text/x-patch;
 name="vm-rework-alloc_pages.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vm-rework-alloc_pages.patch"


This reworks alloc_pages a bit.

Previously the ->protection[] logic was broken. It was difficult to follow
and basically didn't use the asynch reclaim watermarks properly.

This one uses ->protection only for lower-zone protection, and gives the
allocator flexibility to add the watermarks as desired.


---

 linux-2.6-npiggin/mm/page_alloc.c |  115 ++++++++++++++++----------------------
 1 files changed, 51 insertions(+), 64 deletions(-)

diff -puN mm/page_alloc.c~vm-rework-alloc_pages mm/page_alloc.c
--- linux-2.6/mm/page_alloc.c~vm-rework-alloc_pages	2004-08-06 14:43:40.000000000 +1000
+++ linux-2.6-npiggin/mm/page_alloc.c	2004-08-06 14:43:40.000000000 +1000
@@ -606,7 +606,7 @@ __alloc_pages(unsigned int gfp_mask, uns
 {
 	const int wait = gfp_mask & __GFP_WAIT;
 	unsigned long min;
-	struct zone **zones;
+	struct zone **zones, *z;
 	struct page *page;
 	struct reclaim_state reclaim_state;
 	struct task_struct *p = current;
@@ -617,72 +617,56 @@ __alloc_pages(unsigned int gfp_mask, uns
 	might_sleep_if(wait);
 
 	zones = zonelist->zones;  /* the list of zones suitable for gfp_mask */
-	if (zones[0] == NULL)     /* no zones in the zonelist */
+
+	if (unlikely(zones[0] == NULL)) {
+		/* Should this ever happen?? */
 		return NULL;
+	}
 
 	alloc_type = zone_idx(zones[0]);
 
 	/* Go through the zonelist once, looking for a zone with enough free */
-	for (i = 0; zones[i] != NULL; i++) {
-		struct zone *z = zones[i];
+	for (i = 0; (z = zones[i]) != NULL; i++) {
+		min = z->pages_low + (1<<order) + z->protection[alloc_type];
 
-		min = (1<<order) + z->protection[alloc_type];
-
-		/*
-		 * We let real-time tasks dip their real-time paws a little
-		 * deeper into reserves.
-		 */
-		if (rt_task(p))
-			min -= z->pages_low >> 1;
+		if (z->free_pages < min)
+			continue;
 
-		if (z->free_pages >= min ||
-				(!wait && z->free_pages >= z->pages_high)) {
-			page = buffered_rmqueue(z, order, gfp_mask);
-			if (page) {
-				zone_statistics(zonelist, z);
-				goto got_pg;
-			}
-		}
+		page = buffered_rmqueue(z, order, gfp_mask);
+		if (page)
+			goto got_pg;
 	}
 
-	/* we're somewhat low on memory, failed to find what we needed */
-	for (i = 0; zones[i] != NULL; i++)
-		wakeup_kswapd(zones[i]);
-
-	/* Go through the zonelist again, taking __GFP_HIGH into account */
-	for (i = 0; zones[i] != NULL; i++) {
-		struct zone *z = zones[i];
-
-		min = (1<<order) + z->protection[alloc_type];
+	for (i = 0; (z = zones[i]) != NULL; i++)
+		wakeup_kswapd(z);
 
+	/*
+	 * Go through the zonelist again. Let __GFP_HIGH and allocations
+	 * coming from realtime tasks to go deeper into reserves
+	 */
+	for (i = 0; (z = zones[i]) != NULL; i++) {
+		min = z->pages_min;
 		if (gfp_mask & __GFP_HIGH)
-			min -= z->pages_low >> 2;
-		if (rt_task(p))
-			min -= z->pages_low >> 1;
+			min -= min>>1;
+		if (unlikely(rt_task(p)) && !in_interrupt())
+			min -= min>>1;
+		min += (1<<order) + z->protection[alloc_type];
 
-		if (z->free_pages >= min ||
-				(!wait && z->free_pages >= z->pages_high)) {
-			page = buffered_rmqueue(z, order, gfp_mask);
-			if (page) {
-				zone_statistics(zonelist, z);
-				goto got_pg;
-			}
-		}
-	}
+		if (z->free_pages < min)
+			continue;
 
-	/* here we're in the low on memory slow path */
+		page = buffered_rmqueue(z, order, gfp_mask);
+		if (page)
+			goto got_pg;
+	}
 
-rebalance:
+	/* This allocation should allow future memory freeing. */
 	if ((p->flags & (PF_MEMALLOC | PF_MEMDIE)) && !in_interrupt()) {
 		/* go through the zonelist yet again, ignoring mins */
-		for (i = 0; zones[i] != NULL; i++) {
-			struct zone *z = zones[i];
-
+		for (i = 0; (z = zones[i]) != NULL; i++) {
 			page = buffered_rmqueue(z, order, gfp_mask);
-			if (page) {
-				zone_statistics(zonelist, z);
+			if (page)
 				goto got_pg;
-			}
 		}
 		goto nopage;
 	}
@@ -691,6 +675,8 @@ rebalance:
 	if (!wait)
 		goto nopage;
 
+rebalance:
+	/* We now go into synchronous reclaim */
 	p->flags |= PF_MEMALLOC;
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
@@ -701,27 +687,28 @@ rebalance:
 	p->flags &= ~PF_MEMALLOC;
 
 	/* go through the zonelist yet one more time */
-	for (i = 0; zones[i] != NULL; i++) {
-		struct zone *z = zones[i];
+	for (i = 0; (z = zones[i]) != NULL; i++) {
+		min = z->pages_min;
+		if (gfp_mask & __GFP_HIGH)
+			min -= min>>2;
+		if (unlikely(rt_task(p)))
+			min -= min>>2;
+		min += (1<<order) + z->protection[alloc_type];
 
-		min = (1UL << order) + z->protection[alloc_type];
+		if (z->free_pages < min)
+			continue;
 
-		if (z->free_pages >= min ||
-				(!wait && z->free_pages >= z->pages_high)) {
-			page = buffered_rmqueue(z, order, gfp_mask);
-			if (page) {
- 				zone_statistics(zonelist, z);
-				goto got_pg;
-			}
-		}
+		page = buffered_rmqueue(z, order, gfp_mask);
+		if (page)
+			goto got_pg;
 	}
 
 	/*
 	 * Don't let big-order allocations loop unless the caller explicitly
 	 * requests that.  Wait for some write requests to complete then retry.
 	 *
-	 * In this implementation, __GFP_REPEAT means __GFP_NOFAIL, but that
-	 * may not be true in other implementations.
+	 * In this implementation, __GFP_REPEAT means __GFP_NOFAIL for order
+	 * <= 3, but that may not be true in other implementations.
 	 */
 	do_retry = 0;
 	if (!(gfp_mask & __GFP_NORETRY)) {
@@ -744,6 +731,7 @@ nopage:
 	}
 	return NULL;
 got_pg:
+	zone_statistics(zonelist, z);
 	kernel_map_pages(page, 1 << order, 1);
 	return page;
 }
@@ -1861,7 +1849,7 @@ static void setup_per_zone_protection(vo
 				 * zero because the lower zones take
 				 * contributions from the higher zones.
 				 */
-				if (j > max_zone || j > i) {
+				if (j > max_zone || j >= i) {
 					zone->protection[i] = 0;
 					continue;
 				}
@@ -1870,7 +1858,6 @@ static void setup_per_zone_protection(vo
 				 */
 				zone->protection[i] = higherzone_val(zone,
 								max_zone, i);
-				zone->protection[i] += zone->pages_low;
 			}
 		}
 	}

_

--------------080300040901090603080103--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
