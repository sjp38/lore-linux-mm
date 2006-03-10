Date: Fri, 10 Mar 2006 12:59:21 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: drain_node_pages: interrupt latency reduction / optimization
Message-ID: <Pine.LNX.4.64.0603101258290.29954@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

1. Only disable interrupts if there is actually something to free

2. Only dirty the pcp cacheline if we actually freed something.

3. Disable interrupts for each single pcp and not for cleaning
  all the pcps in all zones of a node.

drain_node_pages is called every 2 seconds from cache_reap. This
fix should avoid most disabling of interrupts.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2006-03-10 10:34:56.000000000 -0800
+++ linux-2.6/mm/page_alloc.c	2006-03-10 12:55:02.000000000 -0800
@@ -599,7 +599,6 @@ void drain_node_pages(int nodeid)
 	int i, z;
 	unsigned long flags;
 
-	local_irq_save(flags);
 	for (z = 0; z < MAX_NR_ZONES; z++) {
 		struct zone *zone = NODE_DATA(nodeid)->node_zones + z;
 		struct per_cpu_pageset *pset;
@@ -609,11 +608,14 @@ void drain_node_pages(int nodeid)
 			struct per_cpu_pages *pcp;
 
 			pcp = &pset->pcp[i];
-			free_pages_bulk(zone, pcp->count, &pcp->list, 0);
-			pcp->count = 0;
+			if (pcp->count) {
+				local_irq_save(flags);
+				free_pages_bulk(zone, pcp->count, &pcp->list, 0);
+				pcp->count = 0;
+				local_irq_restore(flags);
+			}
 		}
 	}
-	local_irq_restore(flags);
 }
 #endif
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
