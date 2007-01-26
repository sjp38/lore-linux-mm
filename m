Date: Thu, 25 Jan 2007 21:42:19 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070126054219.10564.13523.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070126054153.10564.43218.sendpatchset@schroedinger.engr.sgi.com>
References: <20070126054153.10564.43218.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 5/8] Drop nr_free_pages_pgdat()
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Nikita Danilov <nikita@clusterfs.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

Get rid of nr_free_pages_pgdat()

Function is unnecessary now. We can use the summing features of the ZVCs to
get the values we need.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.20-rc6/arch/ia64/mm/init.c
===================================================================
--- linux-2.6.20-rc6.orig/arch/ia64/mm/init.c	2007-01-25 10:42:21.000000000 -0800
+++ linux-2.6.20-rc6/arch/ia64/mm/init.c	2007-01-25 10:43:05.000000000 -0800
@@ -67,7 +67,7 @@ max_pgt_pages(void)
 #ifndef	CONFIG_NUMA
 	node_free_pages = nr_free_pages();
 #else
-	node_free_pages = nr_free_pages_pgdat(NODE_DATA(numa_node_id()));
+	node_free_pages = node_page_state(numa_node_id(), NR_FREE_PAGES);
 #endif
 	max_pgt_pages = node_free_pages / PGT_FRACTION_OF_NODE_MEM;
 	max_pgt_pages = max(max_pgt_pages, MIN_PGT_PAGES);
Index: linux-2.6.20-rc6/include/linux/swap.h
===================================================================
--- linux-2.6.20-rc6.orig/include/linux/swap.h	2007-01-25 10:41:14.000000000 -0800
+++ linux-2.6.20-rc6/include/linux/swap.h	2007-01-25 10:41:22.000000000 -0800
@@ -170,7 +170,6 @@ extern void swapin_readahead(swp_entry_t
 extern unsigned long totalram_pages;
 extern unsigned long totalreserve_pages;
 extern long nr_swap_pages;
-extern unsigned int nr_free_pages_pgdat(pg_data_t *pgdat);
 extern unsigned int nr_free_buffer_pages(void);
 extern unsigned int nr_free_pagecache_pages(void);
 
Index: linux-2.6.20-rc6/mm/page_alloc.c
===================================================================
--- linux-2.6.20-rc6.orig/mm/page_alloc.c	2007-01-25 10:41:29.000000000 -0800
+++ linux-2.6.20-rc6/mm/page_alloc.c	2007-01-25 10:41:43.000000000 -0800
@@ -1441,13 +1441,6 @@ fastcall void free_pages(unsigned long a
 
 EXPORT_SYMBOL(free_pages);
 
-#ifdef CONFIG_NUMA
-unsigned int nr_free_pages_pgdat(pg_data_t *pgdat)
-{
-	return node_page_state(pgdat->node_id, NR_FREE_PAGES);
-}
-#endif
-
 static unsigned int nr_free_zone_pages(int offset)
 {
 	/* Just pick one node, since fallback list is circular */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
