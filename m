Subject: Re: [PATCH] Fix find_next_best_node (Re: [BUG] 2.6.23-rc3-mm1
	Kernel panic - not syncing: DMA: Memory would be corrupted)
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0708240957010.20501@schroedinger.engr.sgi.com>
References: <617E1C2C70743745A92448908E030B2A023EB020@scsmsx411.amr.corp.intel.com>
	 <20070823142133.9359a1ce.akpm@linux-foundation.org>
	 <20070824153945.3C75.Y-GOTO@jp.fujitsu.com>
	 <20070824145233.GA26374@skynet.ie> <1187970572.5869.10.camel@localhost>
	 <Pine.LNX.4.64.0708240957010.20501@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 24 Aug 2007 14:03:05 -0400
Message-Id: <1187978585.5869.34.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@skynet.ie>, Yasunori Goto <y-goto@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, "Luck, Tony" <tony.luck@intel.com>, Jeremy Higdon <jeremy@sgi.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2007-08-24 at 10:00 -0700, Christoph Lameter wrote:
> On Fri, 24 Aug 2007, Lee Schermerhorn wrote:
> 
> > I reworked that patch and posted the update on 16aug which does not have
> > this problem:
> > 
> > http://marc.info/?l=linux-mm&m=118729871101418&w=4
> > 
> > This should replace
> > memoryless-nodes-fixup-uses-of-node_online_map-in-generic-code.patch
> > in -mm.
> 
> Could you post a diff to rc3-mm1 of that patch?

Sure.  Here it is.  This looks nicer to me than explicitly skipping
unpopulated nodes in find_next_best_node()--as I tried to do, but
botched it :-(.  I didn't notice that because I'd moved on to v2 before
testing with any significant load.  Even when I was running with v1 with
botched zonelists, I apparently had sufficient memory on each node that
I never had to fallback.

I also didn't notice that Andrew had added v1 instead of v2 to the mm
tree.  Will pay more attention in the future, I promise.

Lee
---------------------------
PATCH Diffs between "Fix generic usage of node_online_map" V1 & V2

Against 2.6.23-rc3-mm1

V1 -> V2:
+ moved population of N_HIGH_MEMORY node state mask to
  free_area_init_nodes(), as this is called before we
  build zonelists.  So, we can use this mask in 
  find_next_best_node.  Still need to keep the duplicate
  code in early_calculate_totalpages() for zone movable
  setup.

mm/page_alloc.c:find_next_best_node()

	visit only nodes with memory [N_HIGH_MEMORY mask]
	looking for next best node for fallback zonelists.

mm/page_alloc.c:find_zone_movable_pfns_for_nodes()

	spread kernelcore over nodes with memory.

	This required calling early_calculate_totalpages()
	unconditionally, and populating N_HIGH_MEMORY node
	state therein from nodes in the early_node_map[].
	This duplicates the code in free_area_init_nodes(), but
	I don't want to depend on this copy if ZONE_MOVABLE 
	might go away, taking early_calculate_totalpages()
	with it.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/page_alloc.c |   48 ++++++++++++++++++++----------------------------
 1 file changed, 20 insertions(+), 28 deletions(-)

Index: Linux/mm/page_alloc.c
===================================================================
--- Linux.orig/mm/page_alloc.c	2007-08-24 13:20:28.000000000 -0400
+++ Linux/mm/page_alloc.c	2007-08-24 13:25:20.000000000 -0400
@@ -2127,18 +2127,10 @@ static int find_next_best_node(int node,
 		return node;
 	}
 
-	for_each_online_node(n) {
+	for_each_node_state(n, N_HIGH_MEMORY) {
 		pg_data_t *pgdat = NODE_DATA(n);
 		cpumask_t tmp;
 
-		/*
-		 * skip nodes w/o memory.
-		 * Note:  N_HIGH_MEMORY state not guaranteed to be
-		 *        populated yet.
-		 */
-		if (pgdat->node_present_pages)
-			continue;
-
 		/* Don't want a node to appear more than once */
 		if (node_isset(n, *used_node_mask))
 			continue;
@@ -2433,20 +2425,6 @@ static void build_zonelist_cache(pg_data
 
 #endif	/* CONFIG_NUMA */
 
-/* Any regular memory on that node ? */
-static void check_for_regular_memory(pg_data_t *pgdat)
-{
-#ifdef CONFIG_HIGHMEM
-	enum zone_type zone_type;
-
-	for (zone_type = 0; zone_type <= ZONE_NORMAL; zone_type++) {
-		struct zone *zone = &pgdat->node_zones[zone_type];
-		if (zone->present_pages)
-			node_set_state(zone_to_nid(zone), N_NORMAL_MEMORY);
-	}
-#endif
-}
-
 /* return values int ....just for stop_machine_run() */
 static int __build_all_zonelists(void *dummy)
 {
@@ -2457,11 +2435,6 @@ static int __build_all_zonelists(void *d
 
 		build_zonelists(pgdat);
 		build_zonelist_cache(pgdat);
-
-		/* Any memory on that node */
-		if (pgdat->node_present_pages)
-			node_set_state(nid, N_HIGH_MEMORY);
-		check_for_regular_memory(pgdat);
 	}
 	return 0;
 }
@@ -3919,6 +3892,20 @@ restart:
 			roundup(zone_movable_pfn[nid], MAX_ORDER_NR_PAGES);
 }
 
+/* Any regular memory on that node ? */
+static void check_for_regular_memory(pg_data_t *pgdat)
+{
+#ifdef CONFIG_HIGHMEM
+	enum zone_type zone_type;
+
+	for (zone_type = 0; zone_type <= ZONE_NORMAL; zone_type++) {
+		struct zone *zone = &pgdat->node_zones[zone_type];
+		if (zone->present_pages)
+			node_set_state(zone_to_nid(zone), N_NORMAL_MEMORY);
+	}
+#endif
+}
+
 /**
  * free_area_init_nodes - Initialise all pg_data_t and zone data
  * @max_zone_pfn: an array of max PFNs for each zone
@@ -3996,6 +3983,11 @@ void __init free_area_init_nodes(unsigne
 		pg_data_t *pgdat = NODE_DATA(nid);
 		free_area_init_node(nid, pgdat, NULL,
 				find_min_pfn_for_node(nid), NULL);
+
+		/* Any memory on that node */
+		if (pgdat->node_present_pages)
+			node_set_state(nid, N_HIGH_MEMORY);
+		check_for_regular_memory(pgdat);
 	}
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
