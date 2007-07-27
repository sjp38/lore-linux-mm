From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 27 Jul 2007 15:44:27 -0400
Message-Id: <20070727194427.18614.87067.sendpatchset@localhost>
In-Reply-To: <20070727194316.18614.36380.sendpatchset@localhost>
References: <20070727194316.18614.36380.sendpatchset@localhost>
Subject: [PATCH 11/14] Add N_CPU node state
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

[patch 11/14] Add N_CPU node state

We need the check for a node with cpu in zone reclaim. Zone reclaim will not
allow remote zone reclaim if a node has a cpu.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Tested-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
Acked-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Acked-by: Bob Picco <bob.picco@hp.com>

 include/linux/nodemask.h |    1 +
 mm/page_alloc.c          |    4 +++-
 mm/vmscan.c              |    4 +---
 3 files changed, 5 insertions(+), 4 deletions(-)

Index: Linux/include/linux/nodemask.h
===================================================================
--- Linux.orig/include/linux/nodemask.h	2007-07-25 11:36:27.000000000 -0400
+++ Linux/include/linux/nodemask.h	2007-07-25 11:37:48.000000000 -0400
@@ -344,6 +344,7 @@ enum node_states {
 	N_POSSIBLE,	/* The node could become online at some point */
 	N_ONLINE,	/* The node is online */
 	N_MEMORY,	/* The node has memory */
+	N_CPU,		/* The node has cpus */
 	NR_NODE_STATES
 };
 
Index: Linux/mm/vmscan.c
===================================================================
--- Linux.orig/mm/vmscan.c	2007-07-25 11:36:35.000000000 -0400
+++ Linux/mm/vmscan.c	2007-07-25 11:37:48.000000000 -0400
@@ -1836,7 +1836,6 @@ static int __zone_reclaim(struct zone *z
 
 int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 {
-	cpumask_t mask;
 	int node_id;
 
 	/*
@@ -1873,8 +1872,7 @@ int zone_reclaim(struct zone *zone, gfp_
 	 * as wide as possible.
 	 */
 	node_id = zone_to_nid(zone);
-	mask = node_to_cpumask(node_id);
-	if (!cpus_empty(mask) && node_id != numa_node_id())
+	if (node_state(node_id, N_CPU) && node_id != numa_node_id())
 		return 0;
 	return __zone_reclaim(zone, gfp_mask, order);
 }
Index: Linux/mm/page_alloc.c
===================================================================
--- Linux.orig/mm/page_alloc.c	2007-07-25 11:36:27.000000000 -0400
+++ Linux/mm/page_alloc.c	2007-07-25 11:37:48.000000000 -0400
@@ -2723,6 +2723,7 @@ static struct per_cpu_pageset boot_pages
 static int __cpuinit process_zones(int cpu)
 {
 	struct zone *zone, *dzone;
+	int node = cpu_to_node(cpu);
 
 	for_each_zone(zone) {
 
@@ -2730,7 +2731,7 @@ static int __cpuinit process_zones(int c
 			continue;
 
 		zone_pcp(zone, cpu) = kmalloc_node(sizeof(struct per_cpu_pageset),
-					 GFP_KERNEL, cpu_to_node(cpu));
+					 GFP_KERNEL, node);
 		if (!zone_pcp(zone, cpu))
 			goto bad;
 
@@ -2741,6 +2742,7 @@ static int __cpuinit process_zones(int c
 			 	(zone->present_pages / percpu_pagelist_fraction));
 	}
 
+	node_set_state(node, N_CPU);
 	return 0;
 bad:
 	for_each_zone(dzone) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
