Message-ID: <4257D7B1.2000303@yahoo.com.au>
Date: Sat, 09 Apr 2005 23:25:05 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [patch 4/4] pcp: only local pagesets
References: <4257D74C.3010703@yahoo.com.au> <4257D779.30801@yahoo.com.au> <4257D78F.7020609@yahoo.com.au>
In-Reply-To: <4257D78F.7020609@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------010801030201090502010802"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------010801030201090502010802
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

4/4

-- 
SUSE Labs, Novell Inc.

--------------010801030201090502010802
Content-Type: text/plain;
 name="pcp-only-local-pagesets.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="pcp-only-local-pagesets.patch"

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2005-04-09 22:45:07.000000000 +1000
+++ linux-2.6/mm/page_alloc.c	2005-04-09 23:13:53.000000000 +1000
@@ -1626,14 +1626,24 @@ void __init build_percpu_pagelists(void)
 			init_percpu_pageset(&zone->pageset, batch);
 			for (cpu = 0; cpu < NR_CPUS; cpu++) {
 				struct zone_pagesets *zp;
-				struct per_cpu_pageset *pageset;
+				struct per_cpu_pageset *pageset = NULL;
 			
 				zp = cpu_zone_pagesets(cpu);
-				pageset = alloc_bootmem_node(pgdat, sizeof(*pageset));
-				init_percpu_pageset(pageset, batch);
+				
+				/*
+				 * XXX: this test could be something like
+				 *   if (node_distance <= blah)
+				 * which would allow pagesets on close
+				 * remote nodes as well as the local node.
+				 */
+				if (cpu_to_node(cpu) == nid) {
+					pageset = alloc_bootmem_node(pgdat,
+							sizeof(*pageset));
+					init_percpu_pageset(pageset, batch);
+				}
 				zp->p[NODEZONE(nid, j)] = pageset;
-
 			}
+
 			printk(KERN_DEBUG "  %s zone: %lu pages, LIFO batch:%lu\n",
 					zone_names[j], zone->present_pages, batch);
 		}

--------------010801030201090502010802--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
