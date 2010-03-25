Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5F2986B01AE
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 18:33:23 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [10.3.21.11])
	by smtp-out.google.com with ESMTP id o2PMXGhH008108
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 15:33:17 -0700
Received: from pxi36 (pxi36.prod.google.com [10.243.27.36])
	by hpaq11.eem.corp.google.com with ESMTP id o2PMXCfK006422
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 23:33:15 +0100
Received: by pxi36 with SMTP id 36so3670485pxi.21
        for <linux-mm@kvack.org>; Thu, 25 Mar 2010 15:33:12 -0700 (PDT)
Date: Thu, 25 Mar 2010 15:33:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm: default to node zonelist ordering when nodes have only
 lowmem
Message-ID: <alpine.DEB.2.00.1003251532150.7950@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

There are two types of zonelist ordering methodologies:

 - node order, preferring allocations on a node to stay local to and

 - zone order, preferring allocations come from a higher zone to avoid
   allocating in lowmem zones even though they may not be local.

The ordering technique used by the kernel is configurable on the command
line, but also has some logic to determine what the default should be.

This logic currently lacks knowledge of systems where a node may only
have lowmem.  For such systems, it is necessary to use node order so that
GFP_KERNEL allocations may be satisfied by nodes consisting of only
lowmem.

If zone order is used, GFP_KERNEL allocations to such nodes are actually
allocated on a node with local affinity that includes ZONE_NORMAL.

This change defaults to node zonelist ordering if any node lacks
ZONE_NORMAL.

To force zone order, append 'numa_zonelist_order=zone' to the kernel
command line.

Cc: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2582,7 +2582,7 @@ static int default_zonelist_order(void)
          * ZONE_DMA and ZONE_DMA32 can be very small area in the sytem.
 	 * If they are really small and used heavily, the system can fall
 	 * into OOM very easily.
-	 * This function detect ZONE_DMA/DMA32 size and confgigures zone order.
+	 * This function detect ZONE_DMA/DMA32 size and configures zone order.
 	 */
 	/* Is there ZONE_NORMAL ? (ex. ppc has only DMA zone..) */
 	low_kmem_size = 0;
@@ -2594,6 +2594,15 @@ static int default_zonelist_order(void)
 				if (zone_type < ZONE_NORMAL)
 					low_kmem_size += z->present_pages;
 				total_size += z->present_pages;
+			} else if (zone_type == ZONE_NORMAL) {
+				/*
+				 * If any node has only lowmem, then node order
+				 * is preferred to allow kernel allocations
+				 * locally; otherwise, they can easily infringe
+				 * on other nodes when there is an abundance of
+				 * lowmem available to allocate from.
+				 */
+				return ZONELIST_ORDER_NODE;
 			}
 		}
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
