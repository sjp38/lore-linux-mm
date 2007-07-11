Date: Wed, 11 Jul 2007 12:04:37 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 11/12] Add N_CPU node state
In-Reply-To: <20070711182252.376540447@sgi.com>
Message-ID: <Pine.LNX.4.64.0707111156460.17503@schroedinger.engr.sgi.com>
References: <20070711182219.234782227@sgi.com> <20070711182252.376540447@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: kxr@sgi.com, linux-mm@kvack.org, Nishanth Aravamudan <nacc@us.ibm.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jul 2007, Christoph Lameter wrote:

> Index: linux-2.6.22-rc6-mm1/mm/migrate.c
> ===================================================================
> --- linux-2.6.22-rc6-mm1.orig/mm/migrate.c	2007-07-11 10:39:28.000000000 -0700
> +++ linux-2.6.22-rc6-mm1/mm/migrate.c	2007-07-11 10:39:38.000000000 -0700
> @@ -963,7 +963,7 @@ asmlinkage long sys_move_pages(pid_t pid
>  				goto out;
>  
>  			err = -ENODEV;
> -			if (!node_memory(node))
> +			if (!node_state(node, N_MEMORY))
>  				goto out;
>  

Papers over the last patch and first patch. Patch w/o those two chunks


Add N_CPU node state

We need the check for a node with cpu in zone reclaim. Zone reclaim will not
allow remote zone reclaim if a node has a cpu.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/nodemask.h |    1 +
 mm/page_alloc.c          |    4 +++-
 mm/vmscan.c              |    4 +---
 3 files changed, 5 insertions(+), 4 deletions(-)

Index: linux-2.6.22-rc6-mm1/include/linux/nodemask.h
===================================================================
--- linux-2.6.22-rc6-mm1.orig/include/linux/nodemask.h	2007-07-11 12:00:29.000000000 -0700
+++ linux-2.6.22-rc6-mm1/include/linux/nodemask.h	2007-07-11 12:01:10.000000000 -0700
@@ -344,6 +344,7 @@ enum node_states {
 	N_POSSIBLE,	/* The node could become online at some point */
 	N_ONLINE,	/* The node is online */
 	N_MEMORY,	/* The node has memory */
+	N_CPU,		/* The node has cpus */
 	NR_NODE_STATES
 };
 
Index: linux-2.6.22-rc6-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/vmscan.c	2007-07-11 12:00:45.000000000 -0700
+++ linux-2.6.22-rc6-mm1/mm/vmscan.c	2007-07-11 12:01:10.000000000 -0700
@@ -1851,7 +1851,6 @@ static int __zone_reclaim(struct zone *z
 
 int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 {
-	cpumask_t mask;
 	int node_id;
 
 	/*
@@ -1888,8 +1887,7 @@ int zone_reclaim(struct zone *zone, gfp_
 	 * as wide as possible.
 	 */
 	node_id = zone_to_nid(zone);
-	mask = node_to_cpumask(node_id);
-	if (!cpus_empty(mask) && node_id != numa_node_id())
+	if (node_state(node_id, N_CPU) && node_id != numa_node_id())
 		return 0;
 	return __zone_reclaim(zone, gfp_mask, order);
 }
Index: linux-2.6.22-rc6-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/page_alloc.c	2007-07-11 12:00:29.000000000 -0700
+++ linux-2.6.22-rc6-mm1/mm/page_alloc.c	2007-07-11 12:01:10.000000000 -0700
@@ -2728,6 +2728,7 @@ static struct per_cpu_pageset boot_pages
 static int __cpuinit process_zones(int cpu)
 {
 	struct zone *zone, *dzone;
+	int node = cpu_to_node(cpu);
 
 	for_each_zone(zone) {
 
@@ -2735,7 +2736,7 @@ static int __cpuinit process_zones(int c
 			continue;
 
 		zone_pcp(zone, cpu) = kmalloc_node(sizeof(struct per_cpu_pageset),
-					 GFP_KERNEL, cpu_to_node(cpu));
+					 GFP_KERNEL, node);
 		if (!zone_pcp(zone, cpu))
 			goto bad;
 
@@ -2746,6 +2747,7 @@ static int __cpuinit process_zones(int c
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
