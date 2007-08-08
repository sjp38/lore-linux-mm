Date: Wed, 8 Aug 2007 10:13:05 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 04/10] mm: slub: add knowledge of reserve pages
In-Reply-To: <20070808014435.GG30556@waste.org>
Message-ID: <Pine.LNX.4.64.0708081004290.12652@schroedinger.engr.sgi.com>
References: <20070806102922.907530000@chello.nl> <20070806103658.603735000@chello.nl>
 <Pine.LNX.4.64.0708071702560.4941@schroedinger.engr.sgi.com>
 <20070808014435.GG30556@waste.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 7 Aug 2007, Matt Mackall wrote:

>  > If you are in an atomic context and bound to a cpu then a per cpu slab is 
> > assigned to you and no one else can take object aways from that process 
> > since nothing else can run on the cpu.
> 
> Servicing I/O over the network requires an allocation to send a buffer
> and an allocation to later receive the acknowledgement. We can't free
> our send buffer (or the memory it's supposed to clean) until the
> relevant ack is received. We have to hold our reserves privately
> throughout, even if an interrupt that wants to do GFP_ATOMIC
> allocation shows up in-between.

If you can take an interrupt then you can move to a different allocation 
context. This means reclaim could free up more pages if we tell reclaim 
not to allocate any memory.
 
> > If you are not in an atomic context and are preemptable or can switch 
> > allocation context then you can create another context in which reclaim 
> > could be run to remove some clean pages and get you more memory. Again no 
> > need for the patch.
> 
> By the point that this patch is relevant, there are already no clean
> pages. The only way to free up more memory is via I/O.

That is never true. The dirty ratio limit limits the number of dirty pages 
in memory. There is always a large percentage of memory that is kept 
clean. Pages that are file backed and clean can be freed without any 
additional memory allocation. This is true for the executable code that 
you must have to execute any instructions. We could guarantee that the 
number of pages reclaimable without memory allocs stays above certain 
limits by checking VM counters.

I think there are two ways to address this in a simpler way:

1. Allow recursive calls into reclaim. If we are in a PF_MEMALLOC context 
then we can still scan lru lists and free up memory of clean pages. Idea 
patch follows.

2. Make pageout figure out if the write action requires actual I/O 
submission. If so then the submission will *not* immediately free memory 
and we have to wait for I/O to complete. In that case do not immediately
initiate I/O (which would not free up memory and its bad to initiate 
I/O when we have not enough free memory) but put all those pages on a 
pageout list. When reclaim has reclaimed enough memory then go through the 
pageout list and trigger I/O. That can be done without PF_MEMALLOC so that 
additional reclaim could be triggered as needed. Maybe we can just get rid 
of PF_MEMALLOC and some of the contorted code around it?




Recursive reclaim concept patch:

---
 include/linux/swap.h |    2 ++
 mm/page_alloc.c      |   11 +++++++++++
 mm/vmscan.c          |   27 +++++++++++++++++++++++++++
 3 files changed, 40 insertions(+)

Index: linux-2.6/include/linux/swap.h
===================================================================
--- linux-2.6.orig/include/linux/swap.h	2007-08-08 04:31:06.000000000 -0700
+++ linux-2.6/include/linux/swap.h	2007-08-08 04:31:28.000000000 -0700
@@ -190,6 +190,8 @@ extern void swap_setup(void);
 /* linux/mm/vmscan.c */
 extern unsigned long try_to_free_pages(struct zone **zones, int order,
 					gfp_t gfp_mask);
+extern unsigned long emergency_free_pages(struct zone **zones, int order,
+					gfp_t gfp_mask);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2007-08-08 04:17:33.000000000 -0700
+++ linux-2.6/mm/page_alloc.c	2007-08-08 04:39:26.000000000 -0700
@@ -1306,6 +1306,17 @@ nofail_alloc:
 				zonelist, ALLOC_NO_WATERMARKS);
 			if (page)
 				goto got_pg;
+
+			/*
+			 * We cannot go into full synchrononous reclaim
+			 * but we can still scan for easily reclaimable
+			 * pages.
+			 */
+			if (p->flags & PF_MEMALLOC &&
+				emergency_free_pages(zonelist->zones, order,
+								gfp_mask))
+				goto nofail_alloc;
+
 			if (gfp_mask & __GFP_NOFAIL) {
 				congestion_wait(WRITE, HZ/50);
 				goto nofail_alloc;
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2007-08-08 04:21:14.000000000 -0700
+++ linux-2.6/mm/vmscan.c	2007-08-08 04:42:24.000000000 -0700
@@ -1204,6 +1204,33 @@ out:
 }
 
 /*
+ * Emergency reclaim. We are alreedy in the vm write out path
+ * and we have exhausted all memory. We have to free memory without
+ * any additional allocations. So no writes and no swap. Get
+ * as bare bones as we can.
+ */
+unsigned long emergency_free_pages(struct zone **zones, int order, gfp_t gfp_mask)
+{
+	int priority;
+	unsigned long nr_reclaimed = 0;
+	struct scan_control sc = {
+		.gfp_mask = gfp_mask,
+		.swap_cluster_max = SWAP_CLUSTER_MAX,
+		.order = order,
+	};
+
+	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
+		sc.nr_scanned = 0;
+		nr_reclaimed += shrink_zones(priority, zones, &sc);
+		if (nr_reclaimed >= sc.swap_cluster_max)
+			return 1;
+	}
+
+	/* top priority shrink_caches still had more to do? don't OOM, then */
+	return sc.all_unreclaimable;
+}
+
+/*
  * For kswapd, balance_pgdat() will work across all this node's zones until
  * they are all at pages_high.
  *



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
