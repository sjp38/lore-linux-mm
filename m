Date: Wed, 10 Nov 2004 16:41:34 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] ignore referenced pages on reclaim when OOM
Message-ID: <20041110184134.GC12867@logos.cnet>
References: <16783.59834.7179.464876@thebsh.namesys.com> <Pine.LNX.4.44.0411081655410.8589-100000@chimarrao.boston.redhat.com> <20041108142837.307029fc.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041108142837.307029fc.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Rik van Riel <riel@redhat.com>, nikita@clusterfs.com, linux-mm@kvack.org, Nick Piggin <piggin@cyberone.com.au>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 08, 2004 at 02:28:37PM -0800, Andrew Morton wrote:
> Rik van Riel <riel@redhat.com> wrote:
> >
> > On Tue, 9 Nov 2004, Nikita Danilov wrote:
> > 
> > >  > Speeds up extreme load performance on Rik's tests.
> > > 
> > > I recently tested quite similar thing, the only dfference being that in
> > > my case references bit started being ignored when scanning priority
> > > reached 2 rather than 0.
> > > 
> > > I found that it _degrades_ performance in the loads when there is a lot
> > > of file system write-back going from tail of the inactive list (like
> > > dirtying huge file through mmap in a loop).
> > 
> > Well yeah, when you reach priority 2, you've only scanned
> > 1/4 of memory.  On the other hand, when you reach priority
> > 0, you've already scanned all pages once - beyond that point
> > the referenced bit really doesn't buy you much any more.
> > 
> 
> But we have to scan active, referenced pages two times to move them onto
> the inactive list.  A bit more, really, because nowadays
> refill_inactive_zone() doesn't even run page_referenced() until it starts
> to reach higher scanning priorities.
> 
> So it could be that we're just not scanning enough.

You know, all_unreclaimable has drawbacks.

Its hard to know whether you have "scanned enough to consider the box OOM 
and trigger OOM killer" when all_unreclaimable avoids the system 
from "scanning enough".

I'm trying to improve the OOM-kill-from-kswapd patch but z->all_unreclaimable 
is currently the bigger "rock on the shoe" - we need some way to detect that
the zones have been scanned enough so to be able to say 
"OK, I have scanned enough and no freeable pages appear, its time 
to trigger the OOM killer".

So z->all_unreclaimable logic and "OOM detection" are conflicting goals.

There must be some way to combine both effectively.

This is my current patch - avoids spurious OOM kills but obviously 
fails to set "worked_dma" - "worked_normal" due to all_unreclaimable logic,  
resulting in livelock when swapspace exhauts. 

Ideas are welcome.


--- vmscan.c.orig	2004-11-09 16:38:04.000000000 -0200
+++ vmscan.c	2004-11-10 18:59:43.098090736 -0200
@@ -878,6 +878,8 @@
 		shrink_zone(zone, sc);
 	}
 }
+
+int task_looping_oom = 0;
  
 /*
  * This is the main entry point to direct page reclaim.
@@ -952,8 +954,8 @@
 		if (sc.nr_scanned && priority < DEF_PRIORITY - 2)
 			blk_congestion_wait(WRITE, HZ/10);
 	}
-	if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY))
-		out_of_memory(gfp_mask);
+        if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY))
+		task_looping_oom = 1;
 out:
 	for (i = 0; zones[i] != 0; i++) {
 		struct zone *zone = zones[i];
@@ -963,6 +965,8 @@
 
 		zone->prev_priority = zone->temp_priority;
 	}
+	if (ret)
+		task_looping_oom = 0;
 	return ret;
 }
 
@@ -997,13 +1001,17 @@
 	int all_zones_ok;
 	int priority;
 	int i;
-	int total_scanned, total_reclaimed;
+	int total_scanned, total_reclaimed, low_reclaimed;
+	int worked_norm, worked_dma;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	struct scan_control sc;
 
+
 loop_again:
 	total_scanned = 0;
 	total_reclaimed = 0;
+	low_reclaimed = 0;
+	worked_norm = worked_dma = 0;
 	sc.gfp_mask = GFP_KERNEL;
 	sc.may_writepage = 0;
 	sc.nr_mapped = read_page_state(nr_mapped);
@@ -1072,6 +1080,17 @@
 			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
 				continue;
 
+			/* if we're scanning dma or normal, and priority 
+			 * reached zero, set "worked_dma" or "worked_norm" 
+			 * accordingly.
+			 */
+			if (i <= 1 && priority == 0) {
+				if (!i) 
+					worked_dma = 1;
+				else
+					worked_norm = 1;
+			}
+
 			if (nr_pages == 0) {	/* Not software suspend */
 				if (!zone_watermark_ok(zone, order,
 						zone->pages_high, end_zone, 0, 0))
@@ -1088,6 +1107,10 @@
 			shrink_slab(sc.nr_scanned, GFP_KERNEL, lru_pages);
 			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
 			total_reclaimed += sc.nr_reclaimed;
+
+			if (i <= 1)
+				low_reclaimed += sc.nr_reclaimed;
+
 			if (zone->all_unreclaimable)
 				continue;
 			if (zone->pages_scanned >= (zone->nr_active +
@@ -1128,6 +1151,29 @@
 
 		zone->prev_priority = zone->temp_priority;
 	}
+
+
+	if (!low_reclaimed && worked_dma && worked_norm && task_looping_oom) {
+
+		printk(KERN_ERR "kswp: pri:%d tot_recl:%d wrkd_dma:%d"
+				"wrkd_norm:%d tsk_loop_oom:%d\n",
+			priority, total_reclaimed, worked_dma, worked_norm, 
+				task_looping_oom);
+
+		/* 
+		 * Only kill if ZONE_NORMAL/ZONE_DMA are both below
+		 * pages_min
+		 */
+		for (i = pgdat->nr_zones - 2; i >= 0; i--) {
+			struct zone *zone = pgdat->node_zones + i;
+
+			if (zone->free_pages > zone->pages_min)
+				return 0;
+		}
+		out_of_memory(GFP_KERNEL);
+		task_looping_oom = 0;
+	}
+
 	if (!all_zones_ok) {
 		cond_resched();
 		goto loop_again;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
