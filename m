Date: Thu, 20 Apr 2000 15:43:23 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: [rtf] [patch] 2.3.99-pre6-3 overly swappy
Message-ID: <Pine.LNX.4.21.0004201538200.8445-100000@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

The balance between swap and shrink_mmap was upset by the recent per-zone
changes: kswapd wakeups now call swap_out 3 times as much as before,
resulting in increased page faults and swap out activity, especially
under heavy io.  This patch seems to help quite a bit -- can other people
give this a try?

		-ben

diff -ur 2.3.99-pre6-3/mm/vmscan.c linux-test/mm/vmscan.c
--- 2.3.99-pre6-3/mm/vmscan.c	Wed Apr 12 14:39:50 2000
+++ linux-test/mm/vmscan.c	Thu Apr 20 15:12:17 2000
@@ -408,7 +408,7 @@
  * cluster them so that we get good swap-out behaviour. See
  * the "free_memory()" macro for details.
  */
-static int do_try_to_free_pages(unsigned int gfp_mask, zone_t *zone)
+static int do_try_to_free_pages(unsigned int gfp_mask, zone_t *zone, int do_swap)
 {
 	int priority;
 	int count = SWAP_CLUSTER_MAX;
@@ -423,6 +423,8 @@
 				goto done;
 		}
 
+		if (!do_swap)
+			continue;
 
 		/* Try to get rid of some shared memory pages.. */
 		if (gfp_mask & __GFP_IO) {
@@ -507,7 +509,7 @@
 					schedule();
 				if ((!zone->size) || (!zone->zone_wake_kswapd))
 					continue;
-				do_try_to_free_pages(GFP_KSWAPD, zone);
+				do_try_to_free_pages(GFP_KSWAPD, zone, i == (MAX_NR_ZONES - 1));
 			}
 			pgdat = pgdat->node_next;
 		}
@@ -538,7 +540,7 @@
 
 	if (gfp_mask & __GFP_WAIT) {
 		current->flags |= PF_MEMALLOC;
-		retval = do_try_to_free_pages(gfp_mask, zone);
+		retval = do_try_to_free_pages(gfp_mask, zone, 1);
 		current->flags &= ~PF_MEMALLOC;
 	}
 	return retval;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
