Message-ID: <4257D779.30801@yahoo.com.au>
Date: Sat, 09 Apr 2005 23:24:09 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [patch 2/4] pcp: dynamic lists
References: <4257D74C.3010703@yahoo.com.au>
In-Reply-To: <4257D74C.3010703@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------040706050800020806010101"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------040706050800020806010101
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

2/4

-- 
SUSE Labs, Novell Inc.

--------------040706050800020806010101
Content-Type: text/plain;
 name="pcp-dynamic-lists.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="pcp-dynamic-lists.patch"

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2005-04-09 22:35:44.000000000 +1000
+++ linux-2.6/mm/page_alloc.c	2005-04-09 22:43:58.000000000 +1000
@@ -70,7 +70,7 @@ struct zone *zone_table[1 << (ZONES_SHIF
 EXPORT_SYMBOL(zone_table);
 
 struct zone_pagesets {
-	struct per_cpu_pageset p[TOTAL_ZONES];
+	struct per_cpu_pageset *p[TOTAL_ZONES];
 };
 
 #define this_zone_pagesets()	(&__get_cpu_var(zone_pagesets))
@@ -80,7 +80,7 @@ struct zone_pagesets {
 	(NODEZONE((zone)->zone_pgdat->node_id, zone_idx(zone)))
 
 #define zone_pageset(zp, zone)		\
-	(&zp->p[zone_pagesets_idx(zone)])
+	(zp->p[zone_pagesets_idx(zone)])
 
 /*
  * List of pointers to per_cpu_pagesets for each zone.
@@ -1579,7 +1579,8 @@ void __init build_percpu_pagelists(void)
 				struct per_cpu_pages *pcp;
 			
 				zp = cpu_zone_pagesets(cpu);
-				pageset = &zp->p[NODEZONE(nid, j)];
+				pageset = alloc_bootmem_node(pgdat, sizeof(*pageset));
+				zp->p[NODEZONE(nid, j)] = pageset;
 
 				pcp = &pageset->pcp[0];	/* hot */
 				pcp->count = 0;

--------------040706050800020806010101--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
