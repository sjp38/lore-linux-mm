Message-Id: <20070814143302.954893066@sgi.com>
References: <20070814142103.204771292@sgi.com>
Date: Tue, 14 Aug 2007 07:21:04 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 1/3] Allow reclaim via __GFP_NOMEMALLOC reclaim
Content-Disposition: inline; filename=vmscan_nomemalloc
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Make try_to_free_pages() not perform any allocations if __GFP_NOMEMALLOC
is set.

We can avoid allocations by not writing pages out or swapping. So on entry
to try_to_free_pages() we check for __GFP_NOMEMALLOC. If it is set
then sc.may_writepage and sc.mayswap are switched off and we short
circuit the writeout handling.

The throttling of VM writeout is also bypassed since there is no
writeout occurring.

It is likely difficult to make sure that the slab shrinkers do
not perform any allocations. So we simply do not shrink slabs.

The type of pages that can be reclaimed by a call to try_to_free_pages()
with the __GFP_NOMEMALLOC parameter is:

- Unmapped clean page cache pages.
- Mapped clean pages

Signed-off-by: Christoph Lameter <clameter@sgi.com>


---
 mm/vmscan.c |   25 ++++++++++++++++++++++---
 1 file changed, 22 insertions(+), 3 deletions(-)

Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2007-08-13 23:43:45.000000000 -0700
+++ linux-2.6/mm/vmscan.c	2007-08-13 23:51:05.000000000 -0700
@@ -161,6 +161,13 @@ unsigned long shrink_slab(unsigned long 
 	if (scanned == 0)
 		scanned = SWAP_CLUSTER_MAX;
 
+	/*
+	 * Not sure if we can keep this clean of allocs.
+	 * Better leave it off for now
+	 */
+	if (gfp_mask & __GFP_NOMEMALLOC)
+		return 1;
+
 	if (!down_read_trylock(&shrinker_rwsem))
 		return 1;	/* Assume we'll be able to shrink next time */
 
@@ -1053,7 +1060,8 @@ static unsigned long shrink_zone(int pri
 		}
 	}
 
-	throttle_vm_writeout(sc->gfp_mask);
+	if (!(sc->gfp_mask & __GFP_NOMEMALLOC))
+		throttle_vm_writeout(sc->gfp_mask);
 
 	atomic_dec(&zone->reclaim_in_progress);
 	return nr_reclaimed;
@@ -1115,6 +1123,9 @@ static unsigned long shrink_zones(int pr
  * hope that some of these pages can be written.  But if the allocating task
  * holds filesystem locks which prevent writeout this might not work, and the
  * allocation attempt will fail.
+ *
+ * The __GFP_NOMEMALLOC flag has a special role. If it is set then no memory
+ * allocations or writeout will occur.
  */
 unsigned long try_to_free_pages(struct zone **zones, int order, gfp_t gfp_mask)
 {
@@ -1127,15 +1138,17 @@ unsigned long try_to_free_pages(struct z
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
 
+	if (!(gfp_mask & __GFP_NOMEMALLOC)) {
+		sc.may_writepage = !laptop_mode;
+		sc.may_swap = 1;
+	}
 	for (i = 0; zones[i] != NULL; i++) {
 		struct zone *zone = zones[i];
 
@@ -1162,6 +1175,9 @@ unsigned long try_to_free_pages(struct z
 			goto out;
 		}
 
+		if (!(gfp_mask & __GFP_NOMEMALLOC))
+			continue;
+
 		/*
 		 * Try to write back as many pages as we just scanned.  This
 		 * tends to cause slow streaming writers to write data to the

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
