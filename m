Date: Thu, 19 Jan 2006 14:58:23 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [PATCH] zone_reclaim: reclaim on memory only node support
Message-ID: <Pine.LNX.4.62.0601191457090.13102@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Zone reclaim is usually only run on the local node. Headless nodes do not have
any local processors. This patch checks for headless nodes and performs zone
reclaim on them.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc1-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.16-rc1-mm1.orig/mm/vmscan.c	2006-01-19 11:12:31.000000000 -0800
+++ linux-2.6.16-rc1-mm1/mm/vmscan.c	2006-01-19 11:18:37.000000000 -0800
@@ -1842,7 +1842,8 @@ int zone_reclaim(struct zone *zone, gfp_
 			return 0;
 
 	if (!(gfp_mask & __GFP_WAIT) ||
-		zone->zone_pgdat->node_id != numa_node_id() ||
+		(!cpus_empty(node_to_cpumask(zone->zone_pgdat->node_id)) &&
+			 zone->zone_pgdat->node_id != numa_node_id()) ||
 		zone->all_unreclaimable ||
 		atomic_read(&zone->reclaim_in_progress) > 0)
 			return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
