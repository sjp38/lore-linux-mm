Date: Mon, 13 Feb 2006 09:54:35 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: Get rid of scan_control
In-Reply-To: <20060211235333.71f48a66.akpm@osdl.org>
Message-ID: <Pine.LNX.4.62.0602130951110.1825@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0602092039230.13184@schroedinger.engr.sgi.com>
 <20060211045355.GA3318@dmt.cnet> <20060211013255.20832152.akpm@osdl.org>
 <20060211014649.7cb3b9e2.akpm@osdl.org> <43EEAC93.3000803@yahoo.com.au>
 <Pine.LNX.4.62.0602111941480.25758@schroedinger.engr.sgi.com>
 <43EEB4DA.6030501@yahoo.com.au> <Pine.LNX.4.62.0602112036350.25872@schroedinger.engr.sgi.com>
 <43EEC136.5060609@yahoo.com.au> <20060211211437.0633dfdb.akpm@osdl.org>
 <20060211213707.0ef39582.akpm@osdl.org> <Pine.LNX.4.62.0602112225190.26166@schroedinger.engr.sgi.com>
 <20060211235333.71f48a66.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: nickpiggin@yahoo.com.au, marcelo.tosatti@cyclades.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 11 Feb 2006, Andrew Morton wrote:

> zone_reclaim() is pretty obscure and could do with some comments.  What's
> it _really_ trying to do, and how does it do it?  What is that timer there
> for and how is it supposed to work?  Why on earth does it set PF_MEMALLOC,
> things like that.
> 
> I'd have thought that looking at the zone's free_pages thingies would give
> a pretty good approximation to "how much memory did shrink_slab() give us".

But that would mean we need to apply the same set of criteria as in 
__alloc_pages(). Its just happening for one allocation and so I thought 
it is not worth dragging all the stuff from __alloc_pages() into vmscan.c.

Here is a cleanup patch with more comments:




zone_reclaim additional comments and cleanup

This patch adds some comments to explain how zone reclaim works.
And it fixes the following issues:

- PF_SWAPWRITE needs to be set for RECLAIM_SWAP to be able to write
  out pages to swap. Currently RECLAIM_SWAP may not do that.

- remove setting sc.nr_reclaimed pages after slab reclaim since the
  slab shrinking code does not use that and the nr_reclaimed pages
  is just right for the intended follow up action.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc3/mm/vmscan.c
===================================================================
--- linux-2.6.16-rc3.orig/mm/vmscan.c	2006-02-12 16:27:25.000000000 -0800
+++ linux-2.6.16-rc3/mm/vmscan.c	2006-02-13 09:45:05.000000000 -0800
@@ -1870,22 +1870,37 @@ int zone_reclaim_interval __read_mostly 
  */
 int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 {
-	int nr_pages;
+	int nr_pages;	/* Minimum pages needed in order to stay on node */
 	struct task_struct *p = current;
 	struct reclaim_state reclaim_state;
 	struct scan_control sc;
 	cpumask_t mask;
 	int node_id;
 
+	/*
+	 * Do not reclaim if there was a recent unsuccessful attempt at
+	 * zone reclaim. In that case we let allocations go off node for
+	 * the zone_reclaim_interval. Otherwise we would scan for each off
+	 * node page allocation.
+	 */
 	if (time_before(jiffies,
 		zone->last_unsuccessful_zone_reclaim + zone_reclaim_interval))
 			return 0;
 
+	/*
+	 * Avoid concurrent zone reclaims, do not reclaim in a zone that
+	 * does not have reclaimable pages and if we should not delay
+	 * the allocation then do not scan.
+	 */
 	if (!(gfp_mask & __GFP_WAIT) ||
 		zone->all_unreclaimable ||
 		atomic_read(&zone->reclaim_in_progress) > 0)
 			return 0;
 
+	/*
+	 * Only reclaim in the zones that are local or in zones
+	 * that are on nodes without processors.
+	 */
 	node_id = zone->zone_pgdat->node_id;
 	mask = node_to_cpumask(node_id);
 	if (!cpus_empty(mask) && node_id != numa_node_id())
@@ -1908,7 +1923,12 @@ int zone_reclaim(struct zone *zone, gfp_
 		sc.swap_cluster_max = SWAP_CLUSTER_MAX;
 
 	cond_resched();
-	p->flags |= PF_MEMALLOC;
+	/*
+	 * We need to be able to allocate from the reserves for RECLAIM_SWAP
+	 * and we also need to be able to write out pages for RECLAIM_WRITE
+	 * and RECLAIM_SWAP.
+	 */
+	p->flags |= PF_MEMALLOC | PF_SWAPWRITE;
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
@@ -1922,23 +1942,29 @@ int zone_reclaim(struct zone *zone, gfp_
 
 	} while (sc.nr_reclaimed < nr_pages && sc.priority > 0);
 
-	if (sc.nr_reclaimed < nr_pages && (zone_reclaim_mode & RECLAIM_SLAB)) {
+	if (sc.nr_reclaimed < nr_pages && (zone_reclaim_mode & RECLAIM_SLAB))
 		/*
 		 * shrink_slab does not currently allow us to determine
-		 * how many pages were freed in the zone. So we just
-		 * shake the slab and then go offnode for a single allocation.
+		 * how many pages were freed in this zone. So we just
+		 * shake the slab a bit and then go off node for this
+		 * particular allocation despite possibly having freed enough
+		 * memory to allocate in this zone. If we freed local memory
+		 * then the next allocations will be local again.
 		 *
 		 * shrink_slab will free memory on all zones and may take
 		 * a long time.
 		 */
 		shrink_slab(sc.nr_scanned, gfp_mask, order);
-		sc.nr_reclaimed = 1;    /* Avoid getting the off node timeout */
-	}
 
 	p->reclaim_state = NULL;
-	current->flags &= ~PF_MEMALLOC;
+	current->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE);
 
 	if (sc.nr_reclaimed == 0)
+		/*
+		 * We were unable to reclaim enough pages to stay on node.
+		 * We now allow off node accesses for a certain time period
+		 * before trying again to reclaim pages from the local zone.
+		 */
 		zone->last_unsuccessful_zone_reclaim = jiffies;
 
 	return sc.nr_reclaimed >= nr_pages;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
