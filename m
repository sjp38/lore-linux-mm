Received: from westrelay03.boulder.ibm.com (westrelay03.boulder.ibm.com [9.17.194.24])
	by e21.nc.us.ibm.com (8.12.2/8.12.2) with ESMTP id g6OJFeRY069780
	for <linux-mm@kvack.org>; Wed, 24 Jul 2002 15:15:40 -0400
Received: from gateway1.beaverton.ibm.com (gateway1.beaverton.ibm.com [138.95.180.2])
	by westrelay03.boulder.ibm.com (8.12.3/NCO/VER6.3) with ESMTP id g6OJFdGt103164
	for <linux-mm@kvack.org>; Wed, 24 Jul 2002 13:15:39 -0600
Received: from flay (mbligh@dyn9-47-17-70.beaverton.ibm.com [9.47.17.70])
	by gateway1.beaverton.ibm.com (8.11.6/8.11.6) with ESMTP id g6OJCQK14011
	for <linux-mm@kvack.org>; Wed, 24 Jul 2002 12:12:26 -0700
Date: Wed, 24 Jul 2002 12:14:22 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: [CFT] dispose of _alloc_pages
Message-ID: <27130000.1027538062@flay>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a forward port from Andrea's tree of the killing of _alloc_pages
(I think it originally came from SGI?). It inverts the loop of
"foreach(node) { foreach(zone) }" into "foreach(zone) { foreach(node) }"
which seems to make much more sense, and it cleans up a lot of code
in the process.

I've touch tested it on my machine, but without NUMA support as yet.
If anyone else could / would test it on a different type of NUMA machine,
that'd be most helpful. It's against 2.5.25 to avoid the current stability
problems we're having with the bleeding edge stuff, but should be dead
easy to move forward if you can use 2.5.27.

I need to test this more before submitting it. Comments?

M.

diff -urN virgin-2.5.25/arch/sparc64/mm/init.c 2.5.25-A01-numa-mm/arch/sparc64/mm/init.c
--- virgin-2.5.25/arch/sparc64/mm/init.c	Fri Jul  5 16:42:21 2002
+++ 2.5.25-A01-numa-mm/arch/sparc64/mm/init.c	Wed Jul 24 12:05:12 2002
@@ -1708,7 +1708,7 @@
 	 * Set up the zero page, mark it reserved, so that page count
 	 * is not manipulated when freeing the page from user ptes.
 	 */
-	mem_map_zero = _alloc_pages(GFP_KERNEL, 0);
+	mem_map_zero = alloc_pages(GFP_KERNEL, 0);
 	if (mem_map_zero == NULL) {
 		prom_printf("paging_init: Cannot alloc zero page.\n");
 		prom_halt();
diff -urN virgin-2.5.25/include/asm-alpha/max_numnodes.h 2.5.25-A01-numa-mm/include/asm-alpha/max_numnodes.h
--- virgin-2.5.25/include/asm-alpha/max_numnodes.h	Wed Dec 31 16:00:00 1969
+++ 2.5.25-A01-numa-mm/include/asm-alpha/max_numnodes.h	Wed Jul 24 12:05:12 2002
@@ -0,0 +1,13 @@
+#ifndef _ASM_MAX_NUMNODES_H
+#define _ASM_MAX_NUMNODES_H
+
+#include <linux/config.h>
+
+#ifdef CONFIG_ALPHA_WILDFIRE
+#include <asm/core_wildfire.h>
+#define MAX_NUMNODES		WILDFIRE_MAX_QBB
+#else
+#define MAX_NUMNODES		1
+#endif
+
+#endif
diff -urN virgin-2.5.25/include/asm-alpha/mmzone.h 2.5.25-A01-numa-mm/include/asm-alpha/mmzone.h
--- virgin-2.5.25/include/asm-alpha/mmzone.h	Fri Jul  5 16:42:21 2002
+++ 2.5.25-A01-numa-mm/include/asm-alpha/mmzone.h	Wed Jul 24 12:05:12 2002
@@ -37,11 +37,9 @@
 #ifdef CONFIG_ALPHA_WILDFIRE
 # define ALPHA_PA_TO_NID(pa)	((pa) >> 36)	/* 16 nodes max due 43bit kseg */
 #define NODE_MAX_MEM_SIZE	(64L * 1024L * 1024L * 1024L) /* 64 GB */
-#define MAX_NUMNODES		WILDFIRE_MAX_QBB
 #else
 # define ALPHA_PA_TO_NID(pa)	(0)
 #define NODE_MAX_MEM_SIZE	(~0UL)
-#define MAX_NUMNODES		1
 #endif
 
 #define PHYSADDR_TO_NID(pa)		ALPHA_PA_TO_NID(pa)
@@ -63,8 +61,6 @@
 }
 #endif
 
-#ifdef CONFIG_DISCONTIGMEM
-
 /*
  * Following are macros that each numa implmentation must define.
  */
@@ -121,7 +117,5 @@
 
 #define numa_node_id()	cputonode(smp_processor_id())
 #endif /* CONFIG_NUMA */
-
-#endif /* CONFIG_DISCONTIGMEM */
 
 #endif /* _ASM_MMZONE_H_ */
diff -urN virgin-2.5.25/include/linux/gfp.h 2.5.25-A01-numa-mm/include/linux/gfp.h
--- virgin-2.5.25/include/linux/gfp.h	Fri Jul  5 16:42:19 2002
+++ 2.5.25-A01-numa-mm/include/linux/gfp.h	Wed Jul 24 12:05:12 2002
@@ -39,7 +39,6 @@
  * can allocate highmem pages, the *get*page*() variants return
  * virtual kernel addresses to the allocated page(s).
  */
-extern struct page * FASTCALL(_alloc_pages(unsigned int gfp_mask, unsigned int order));
 extern struct page * FASTCALL(__alloc_pages(unsigned int gfp_mask, unsigned int order, zonelist_t *zonelist));
 extern struct page * alloc_pages_node(int nid, unsigned int gfp_mask, unsigned int order);
 
@@ -50,7 +49,13 @@
 	 */
 	if (order >= MAX_ORDER)
 		return NULL;
-	return _alloc_pages(gfp_mask, order);
+	/*
+	 * we get the zone list from the current node and the gfp_mask.
+	 * This zone list contains a maximum of MAXNODES*MAX_NR_ZONES zones.
+	 */
+	return __alloc_pages(gfp_mask, order,
+			NODE_DATA(numa_node_id())->node_zonelists + 
+			(gfp_mask & GFP_ZONEMASK));
 }
 
 #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
diff -urN virgin-2.5.25/include/linux/mmzone.h 2.5.25-A01-numa-mm/include/linux/mmzone.h
--- virgin-2.5.25/include/linux/mmzone.h	Fri Jul  5 16:42:02 2002
+++ 2.5.25-A01-numa-mm/include/linux/mmzone.h	Wed Jul 24 12:06:52 2002
@@ -107,8 +107,18 @@
  * so despite the zonelist table being relatively big, the cache
  * footprint of this construct is very small.
  */
+#ifndef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_MULTIQUAD        /* can have multiple nodes without discontig */
+#define MAX_NUMNODES 16
+#else
+#define MAX_NUMNODES 1
+#endif
+#else
+#include <asm/max_numnodes.h>
+#endif /* !CONFIG_DISCONTIGMEM */
+
 typedef struct zonelist_struct {
-	zone_t * zones [MAX_NR_ZONES+1]; // NULL delimited
+	zone_t * zones [MAX_NUMNODES * MAX_NR_ZONES+1]; // NULL delimited
 } zonelist_t;
 
 #define GFP_ZONEMASK	0x0f
@@ -160,6 +170,7 @@
 extern void free_area_init_core(int nid, pg_data_t *pgdat, struct page **gmap,
   unsigned long *zones_size, unsigned long paddr, unsigned long *zholes_size,
   struct page *pmap);
+extern void build_all_zonelists(void);
 
 extern pg_data_t contig_page_data;
 
diff -urN virgin-2.5.25/init/main.c 2.5.25-A01-numa-mm/init/main.c
--- virgin-2.5.25/init/main.c	Fri Jul  5 16:42:14 2002
+++ 2.5.25-A01-numa-mm/init/main.c	Wed Jul 24 12:05:12 2002
@@ -342,6 +342,7 @@
 	lock_kernel();
 	printk(linux_banner);
 	setup_arch(&command_line);
+	build_all_zonelists();
 	setup_per_cpu_areas();
 	printk("Kernel command line: %s\n", saved_command_line);
 	parse_options(command_line);
diff -urN virgin-2.5.25/kernel/ksyms.c 2.5.25-A01-numa-mm/kernel/ksyms.c
--- virgin-2.5.25/kernel/ksyms.c	Fri Jul  5 16:42:02 2002
+++ 2.5.25-A01-numa-mm/kernel/ksyms.c	Wed Jul 24 12:05:12 2002
@@ -90,7 +90,6 @@
 EXPORT_SYMBOL(exit_mm);
 
 /* internal kernel memory management */
-EXPORT_SYMBOL(_alloc_pages);
 EXPORT_SYMBOL(__alloc_pages);
 EXPORT_SYMBOL(alloc_pages_node);
 EXPORT_SYMBOL(__get_free_pages);
@@ -112,7 +111,10 @@
 EXPORT_SYMBOL(vmalloc);
 EXPORT_SYMBOL(vmalloc_32);
 EXPORT_SYMBOL(vmalloc_to_page);
+#ifndef CONFIG_DISCONTIGMEM
+EXPORT_SYMBOL(contig_page_data);
 EXPORT_SYMBOL(mem_map);
+#endif
 EXPORT_SYMBOL(remap_page_range);
 EXPORT_SYMBOL(max_mapnr);
 EXPORT_SYMBOL(high_memory);
diff -urN virgin-2.5.25/mm/numa.c 2.5.25-A01-numa-mm/mm/numa.c
--- virgin-2.5.25/mm/numa.c	Fri Jul  5 16:42:20 2002
+++ 2.5.25-A01-numa-mm/mm/numa.c	Wed Jul 24 12:05:12 2002
@@ -82,49 +82,4 @@
 	memset(pgdat->valid_addr_bitmap, 0, size);
 }
 
-static struct page * alloc_pages_pgdat(pg_data_t *pgdat, unsigned int gfp_mask,
-	unsigned int order)
-{
-	return __alloc_pages(gfp_mask, order, pgdat->node_zonelists + (gfp_mask & GFP_ZONEMASK));
-}
-
-/*
- * This can be refined. Currently, tries to do round robin, instead
- * should do concentratic circle search, starting from current node.
- */
-struct page * _alloc_pages(unsigned int gfp_mask, unsigned int order)
-{
-	struct page *ret = 0;
-	pg_data_t *start, *temp;
-#ifndef CONFIG_NUMA
-	unsigned long flags;
-	static pg_data_t *next = 0;
-#endif
-
-	if (order >= MAX_ORDER)
-		return NULL;
-#ifdef CONFIG_NUMA
-	temp = NODE_DATA(numa_node_id());
-#else
-	spin_lock_irqsave(&node_lock, flags);
-	if (!next) next = pgdat_list;
-	temp = next;
-	next = next->node_next;
-	spin_unlock_irqrestore(&node_lock, flags);
-#endif
-	start = temp;
-	while (temp) {
-		if ((ret = alloc_pages_pgdat(temp, gfp_mask, order)))
-			return(ret);
-		temp = temp->node_next;
-	}
-	temp = pgdat_list;
-	while (temp != start) {
-		if ((ret = alloc_pages_pgdat(temp, gfp_mask, order)))
-			return(ret);
-		temp = temp->node_next;
-	}
-	return(0);
-}
-
 #endif /* CONFIG_DISCONTIGMEM */
diff -urN virgin-2.5.25/mm/page_alloc.c 2.5.25-A01-numa-mm/mm/page_alloc.c
--- virgin-2.5.25/mm/page_alloc.c	Fri Jul  5 16:42:03 2002
+++ 2.5.25-A01-numa-mm/mm/page_alloc.c	Wed Jul 24 12:05:12 2002
@@ -252,14 +252,6 @@
 }
 #endif /* CONFIG_SOFTWARE_SUSPEND */
 
-#ifndef CONFIG_DISCONTIGMEM
-struct page *_alloc_pages(unsigned int gfp_mask, unsigned int order)
-{
-	return __alloc_pages(gfp_mask, order,
-		contig_page_data.node_zonelists+(gfp_mask & GFP_ZONEMASK));
-}
-#endif
-
 static /* inline */ struct page *
 balance_classzone(zone_t * classzone, unsigned int gfp_mask,
 			unsigned int order, int * freed)
@@ -670,13 +662,41 @@
 /*
  * Builds allocation fallback zone lists.
  */
-static inline void build_zonelists(pg_data_t *pgdat)
+static int __init build_zonelists_node(pg_data_t *pgdat, zonelist_t *zonelist, int j, int k)
+{
+	switch (k) {
+		zone_t *zone;
+	default:
+		BUG();
+	case ZONE_HIGHMEM:
+		zone = pgdat->node_zones + ZONE_HIGHMEM;
+		if (zone->size) {
+#ifndef CONFIG_HIGHMEM
+			BUG();
+#endif
+			zonelist->zones[j++] = zone;
+		}
+	case ZONE_NORMAL:
+		zone = pgdat->node_zones + ZONE_NORMAL;
+		if (zone->size)
+			zonelist->zones[j++] = zone;
+	case ZONE_DMA:
+		zone = pgdat->node_zones + ZONE_DMA;
+		if (zone->size)
+			zonelist->zones[j++] = zone;
+	}
+
+	return j;
+}
+
+static void __init build_zonelists(pg_data_t *pgdat)
 {
-	int i, j, k;
+	int i, j, k, node, local_node;
 
+	local_node = pgdat->node_id;
+	printk("Building zonelist for node : %d\n", local_node);
 	for (i = 0; i <= GFP_ZONEMASK; i++) {
 		zonelist_t *zonelist;
-		zone_t *zone;
 
 		zonelist = pgdat->node_zonelists + i;
 		memset(zonelist, 0, sizeof(*zonelist));
@@ -688,33 +708,32 @@
 		if (i & __GFP_DMA)
 			k = ZONE_DMA;
 
-		switch (k) {
-			default:
-				BUG();
-			/*
-			 * fallthrough:
-			 */
-			case ZONE_HIGHMEM:
-				zone = pgdat->node_zones + ZONE_HIGHMEM;
-				if (zone->size) {
-#ifndef CONFIG_HIGHMEM
-					BUG();
-#endif
-					zonelist->zones[j++] = zone;
-				}
-			case ZONE_NORMAL:
-				zone = pgdat->node_zones + ZONE_NORMAL;
-				if (zone->size)
-					zonelist->zones[j++] = zone;
-			case ZONE_DMA:
-				zone = pgdat->node_zones + ZONE_DMA;
-				if (zone->size)
-					zonelist->zones[j++] = zone;
-		}
+ 		j = build_zonelists_node(pgdat, zonelist, j, k);
+ 		/*
+ 		 * Now we build the zonelist so that it contains the zones
+ 		 * of all the other nodes.
+ 		 * We don't want to pressure a particular node, so when
+ 		 * building the zones for node N, we make sure that the
+ 		 * zones coming right after the local ones are those from
+ 		 * node N+1 (modulo N)
+ 		 */
+ 		for (node = local_node + 1; node < numnodes; node++)
+ 			j = build_zonelists_node(NODE_DATA(node), zonelist, j, k);
+ 		for (node = 0; node < local_node; node++)
+ 			j = build_zonelists_node(NODE_DATA(node), zonelist, j, k);
+ 
 		zonelist->zones[j++] = NULL;
 	} 
 }
 
+void __init build_all_zonelists(void)
+{
+	int i;
+
+	for(i = 0 ; i < numnodes ; i++)
+		build_zonelists(NODE_DATA(i));
+}
+
 /*
  * Helper functions to size the waitqueue hash table.
  * Essentially these want to choose hash table sizes sufficiently
@@ -915,7 +934,6 @@
 			  (unsigned long *) alloc_bootmem_node(pgdat, bitmap_size);
 		}
 	}
-	build_zonelists(pgdat);
 }
 
 void __init free_area_init(unsigned long *zones_size)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
