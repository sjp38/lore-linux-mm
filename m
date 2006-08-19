Date: Fri, 18 Aug 2006 20:33:18 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] Do not check unpopulated zones for draining and counter
 updates
Message-ID: <Pine.LNX.4.64.0608182032180.3024@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

If a zone is unpopulated then we do not need to check for pages
that are to be drained and also not for vm counters that may need to be
updated.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc4/mm/page_alloc.c
===================================================================
--- linux-2.6.18-rc4.orig/mm/page_alloc.c	2006-08-18 16:14:47.704697028 -0700
+++ linux-2.6.18-rc4/mm/page_alloc.c	2006-08-18 16:14:48.554253927 -0700
@@ -617,7 +617,7 @@ static int rmqueue_bulk(struct zone *zon
 #ifdef CONFIG_NUMA
 /*
  * Called from the slab reaper to drain pagesets on a particular node that
- * belong to the currently executing processor.
+ * belongs to the currently executing processor.
  * Note that this function must be called with the thread pinned to
  * a single processor.
  */
@@ -630,6 +630,9 @@ void drain_node_pages(int nodeid)
 		struct zone *zone = NODE_DATA(nodeid)->node_zones + z;
 		struct per_cpu_pageset *pset;
 
+		if (!populated_zone(zone))
+			continue;
+
 		pset = zone_pcp(zone, smp_processor_id());
 		for (i = 0; i < ARRAY_SIZE(pset->pcp); i++) {
 			struct per_cpu_pages *pcp;
Index: linux-2.6.18-rc4/mm/vmstat.c
===================================================================
--- linux-2.6.18-rc4.orig/mm/vmstat.c	2006-08-06 11:20:11.000000000 -0700
+++ linux-2.6.18-rc4/mm/vmstat.c	2006-08-18 16:33:43.280046497 -0700
@@ -268,6 +268,9 @@ void refresh_cpu_vm_stats(int cpu)
 	for_each_zone(zone) {
 		struct per_cpu_pageset *pcp;
 
+		if (!populated_zone(zone))
+			continue;
+
 		pcp = zone_pcp(zone, cpu);
 
 		for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
