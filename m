Date: Mon, 4 Sep 2006 10:19:16 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: NUMA: Add zone_to_nid function
Message-ID: <Pine.LNX.4.64.0609041017380.29018@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: pj@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

There are many places where we need to determine the node of a zone.
Currently we use a difficult to read sequence of pointer dereferencing.
Put that into an inline function and use throughout VM. Maybe
we can find a way to optimize the lookup in the future.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc5-mm1/include/linux/mm.h
===================================================================
--- linux-2.6.18-rc5-mm1.orig/include/linux/mm.h	2006-09-01 10:13:35.890454083 -0700
+++ linux-2.6.18-rc5-mm1/include/linux/mm.h	2006-09-04 09:59:07.377866426 -0700
@@ -504,12 +504,17 @@ static inline struct zone *page_zone(str
 	return zone_table[page_zone_id(page)];
 }
 
+static inline unsigned long zone_to_nid(struct zone *zone)
+{
+	return zone->zone_pgdat->node_id;
+}
+
 static inline unsigned long page_to_nid(struct page *page)
 {
 	if (FLAGS_HAS_NODE)
 		return (page->flags >> NODES_PGSHIFT) & NODES_MASK;
 	else
-		return page_zone(page)->zone_pgdat->node_id;
+		return zone_to_nid(page_zone(page));
 }
 static inline unsigned long page_to_section(struct page *page)
 {
Index: linux-2.6.18-rc5-mm1/mm/hugetlb.c
===================================================================
--- linux-2.6.18-rc5-mm1.orig/mm/hugetlb.c	2006-09-04 09:59:05.149488146 -0700
+++ linux-2.6.18-rc5-mm1/mm/hugetlb.c	2006-09-04 09:59:07.379819431 -0700
@@ -72,7 +72,7 @@ static struct page *dequeue_huge_page(st
 	struct zone **z;
 
 	for (z = zonelist->zones; *z; z++) {
-		nid = (*z)->zone_pgdat->node_id;
+		nid = zone_to_nid(*z);
 		if (cpuset_zone_allowed(*z, GFP_HIGHUSER) &&
 		    !list_empty(&hugepage_freelists[nid]))
 			break;
Index: linux-2.6.18-rc5-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.18-rc5-mm1.orig/mm/mempolicy.c	2006-09-01 10:13:42.879281178 -0700
+++ linux-2.6.18-rc5-mm1/mm/mempolicy.c	2006-09-04 09:59:07.380795933 -0700
@@ -487,7 +487,7 @@ static void get_zonemask(struct mempolic
 	switch (p->policy) {
 	case MPOL_BIND:
 		for (i = 0; p->v.zonelist->zones[i]; i++)
-			node_set(p->v.zonelist->zones[i]->zone_pgdat->node_id,
+			node_set(zone_to_nid(p->v.zonelist->zones[i]),
 				*nodes);
 		break;
 	case MPOL_DEFAULT:
@@ -1145,7 +1145,7 @@ unsigned slab_node(struct mempolicy *pol
 		 * Follow bind policy behavior and start allocation at the
 		 * first node.
 		 */
-		return policy->v.zonelist->zones[0]->zone_pgdat->node_id;
+		return zone_to_nid(policy->v.zonelist->zones[0]);
 
 	case MPOL_PREFERRED:
 		if (policy->v.preferred_node >= 0)
@@ -1649,7 +1649,7 @@ void mpol_rebind_policy(struct mempolicy
 
 		nodes_clear(nodes);
 		for (z = pol->v.zonelist->zones; *z; z++)
-			node_set((*z)->zone_pgdat->node_id, nodes);
+			node_set(zone_to_nid(*z), nodes);
 		nodes_remap(tmp, nodes, *mpolmask, *newmask);
 		nodes = tmp;
 
Index: linux-2.6.18-rc5-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.18-rc5-mm1.orig/mm/page_alloc.c	2006-09-01 10:13:42.906623243 -0700
+++ linux-2.6.18-rc5-mm1/mm/page_alloc.c	2006-09-04 09:59:07.382748938 -0700
@@ -1329,7 +1329,7 @@ unsigned int nr_free_pagecache_pages(voi
 #ifdef CONFIG_NUMA
 static void show_node(struct zone *zone)
 {
-	printk("Node %d ", zone->zone_pgdat->node_id);
+	printk("Node %ld ", zone_to_nid(zone));
 }
 #else
 #define show_node(zone)	do { } while (0)
Index: linux-2.6.18-rc5-mm1/mm/swap_prefetch.c
===================================================================
--- linux-2.6.18-rc5-mm1.orig/mm/swap_prefetch.c	2006-09-01 10:13:42.977907913 -0700
+++ linux-2.6.18-rc5-mm1/mm/swap_prefetch.c	2006-09-04 09:59:07.384701942 -0700
@@ -275,7 +275,7 @@ static void examine_free_limits(void)
 		if (!populated_zone(z))
 			continue;
 
-		ns = &sp_stat.node[z->zone_pgdat->node_id];
+		ns = &sp_stat.node[zone_to_nid(z)];
 		idx = zone_idx(z);
 		ns->lowfree[idx] = z->pages_high * 3;
 		ns->highfree[idx] = ns->lowfree[idx] + z->pages_high;
@@ -333,7 +333,7 @@ static int prefetch_suitable(void)
 		if (!populated_zone(z))
 			continue;
 
-		node = z->zone_pgdat->node_id;
+		node = zone_to_nid(z);
 		ns = &sp_stat.node[node];
 		idx = zone_idx(z);
 
@@ -557,7 +557,7 @@ void __init prepare_swap_prefetch(void)
 		if (!present)
 			continue;
 
-		ns = &sp_stat.node[zone->zone_pgdat->node_id];
+		ns = &sp_stat.node[zone_to_nid(zone)];
 		ns->prefetch_watermark += present / 3 * 2;
 		idx = zone_idx(zone);
 		ns->pointfree[idx] = &ns->highfree[idx];
Index: linux-2.6.18-rc5-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.18-rc5-mm1.orig/mm/vmscan.c	2006-09-01 10:13:43.007202982 -0700
+++ linux-2.6.18-rc5-mm1/mm/vmscan.c	2006-09-04 09:59:07.385678445 -0700
@@ -1669,7 +1669,7 @@ int zone_reclaim(struct zone *zone, gfp_
 	 * over remote processors and spread off node memory allocations
 	 * as wide as possible.
 	 */
-	node_id = zone->zone_pgdat->node_id;
+	node_id = zone_to_nid(zone);
 	mask = node_to_cpumask(node_id);
 	if (!cpus_empty(mask) && node_id != numa_node_id())
 		return 0;
Index: linux-2.6.18-rc5-mm1/kernel/cpuset.c
===================================================================
--- linux-2.6.18-rc5-mm1.orig/kernel/cpuset.c	2006-09-01 10:13:37.438210258 -0700
+++ linux-2.6.18-rc5-mm1/kernel/cpuset.c	2006-09-04 10:02:53.031926261 -0700
@@ -2319,7 +2319,7 @@ int cpuset_zonelist_valid_mems_allowed(s
 	int i;
 
 	for (i = 0; zl->zones[i]; i++) {
-		int nid = zl->zones[i]->zone_pgdat->node_id;
+		int nid = zone_to_nid(zl->zones[i]);
 
 		if (node_isset(nid, current->mems_allowed))
 			return 1;
@@ -2392,7 +2392,7 @@ int __cpuset_zone_allowed(struct zone *z
 
 	if (in_interrupt() || (gfp_mask & __GFP_THISNODE))
 		return 1;
-	node = z->zone_pgdat->node_id;
+	node = zone_to_nid(z);
 	might_sleep_if(!(gfp_mask & __GFP_HARDWALL));
 	if (node_isset(node, current->mems_allowed))
 		return 1;
Index: linux-2.6.18-rc5-mm1/arch/i386/mm/discontig.c
===================================================================
--- linux-2.6.18-rc5-mm1.orig/arch/i386/mm/discontig.c	2006-09-01 10:12:14.475549597 -0700
+++ linux-2.6.18-rc5-mm1/arch/i386/mm/discontig.c	2006-09-04 09:59:07.392513961 -0700
@@ -392,7 +392,7 @@ void __init set_highmem_pages_init(int b
 		zone_end_pfn = zone_start_pfn + zone->spanned_pages;
 
 		printk("Initializing %s for node %d (%08lx:%08lx)\n",
-				zone->name, zone->zone_pgdat->node_id,
+				zone->name, zone_to_nid(zone),
 				zone_start_pfn, zone_end_pfn);
 
 		for (node_pfn = zone_start_pfn; node_pfn < zone_end_pfn; node_pfn++) {
Index: linux-2.6.18-rc5-mm1/arch/parisc/mm/init.c
===================================================================
--- linux-2.6.18-rc5-mm1.orig/arch/parisc/mm/init.c	2006-09-01 10:12:15.717660551 -0700
+++ linux-2.6.18-rc5-mm1/arch/parisc/mm/init.c	2006-09-04 09:59:07.395443468 -0700
@@ -548,7 +548,7 @@ void show_mem(void)
 
 				printk("Zone list for zone %d on node %d: ", j, i);
 				for (k = 0; zl->zones[k] != NULL; k++) 
-					printk("[%d/%s] ", zl->zones[k]->zone_pgdat->node_id, zl->zones[k]->name);
+					printk("[%d/%s] ", zone_to_nid(zl->zones[k]), zl->zones[k]->name);
 				printk("\n");
 			}
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
