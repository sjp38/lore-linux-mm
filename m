Date: Fri, 15 Sep 2006 10:37:49 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] Add NUMA_BUILD definition in kernel.h to avoid #ifdef
 CONFIG_NUMA
In-Reply-To: <20060914220011.2be9100a.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0609151037010.8198@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
 <20060914220011.2be9100a.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The NUMA_BUILD constant is always available and will be set to 1
on NUMA_BUILDs. That way checks valid only under CONFIG_NUMA can
easily be done without #ifdef CONFIG_NUMA

F.e.

if (NUMA_BUILD && <numa_condition>) {
...
}

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc6-mm2/include/linux/kernel.h
===================================================================
--- linux-2.6.18-rc6-mm2.orig/include/linux/kernel.h	2006-09-13 20:00:38.000000000 -0500
+++ linux-2.6.18-rc6-mm2/include/linux/kernel.h	2006-09-15 12:19:55.293331280 -0500
@@ -352,4 +352,11 @@ struct sysinfo {
 /* Trap pasters of __FUNCTION__ at compile-time */
 #define __FUNCTION__ (__func__)
 
+/* This helps us to avoid #ifdef CONFIG_NUMA */
+#ifdef CONFIG_NUMA
+#define NUMA_BUILD 1
+#else
+#define NUMA_BUILD 0
+#endif
+
 #endif
Index: linux-2.6.18-rc6-mm2/mm/page_alloc.c
===================================================================
--- linux-2.6.18-rc6-mm2.orig/mm/page_alloc.c	2006-09-15 12:17:47.000000000 -0500
+++ linux-2.6.18-rc6-mm2/mm/page_alloc.c	2006-09-15 12:27:01.079243677 -0500
@@ -957,7 +957,7 @@ get_page_from_freelist(gfp_t gfp_mask, u
 	 */
 	do {
 		zone = *z;
-		if (unlikely((gfp_mask & __GFP_THISNODE) &&
+		if (unlikely(NUMA_BUILD && (gfp_mask & __GFP_THISNODE) &&
 			zone->zone_pgdat != zonelist->zones[0]->zone_pgdat))
 				break;
 		if ((alloc_flags & ALLOC_CPUSET) &&
@@ -1330,14 +1330,12 @@ unsigned int nr_free_pagecache_pages(voi
 {
 	return nr_free_zone_pages(gfp_zone(GFP_HIGHUSER));
 }
-#ifdef CONFIG_NUMA
-static void show_node(struct zone *zone)
+
+static inline void show_node(struct zone *zone)
 {
-	printk("Node %ld ", zone_to_nid(zone));
+	if (NUMA_BUILD)
+		printk("Node %ld ", zone_to_nid(zone));
 }
-#else
-#define show_node(zone)	do { } while (0)
-#endif
 
 /*
  * The node's effective length of inactive_list(s).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
