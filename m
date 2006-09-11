Received: from internal-mail-relay1.corp.sgi.com (internal-mail-relay1.corp.sgi.com [198.149.32.52])
	by omx2.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k8C14xbG011614
	for <linux-mm@kvack.org>; Mon, 11 Sep 2006 18:04:59 -0700
Date: Mon, 11 Sep 2006 15:30:17 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060911223017.5032.38195.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060911223001.5032.24593.sendpatchset@schroedinger.engr.sgi.com>
References: <20060911223001.5032.24593.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 3/6] Optional ZONE_DMA in the VM
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Make ZONE_DMA optional in core code.

- ifdef definitions for ZONE_DMA and related code following
  the example for ZONE_DMA32 and ZONE_HIGHMEM.

- Without ZONE_DMA, ZONE_HIGHMEM and ZONE_DMA32 we get to a
  ZONES_SHIFT of 0.

- Modify the VM statistics to work correctly without a DMA
  zone.

- Modify slab to not create DMA slabs if there is no
  ZONE_DMA.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc6-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.18-rc6-mm1.orig/include/linux/mmzone.h	2006-09-11 16:44:16.000000000 -0500
+++ linux-2.6.18-rc6-mm1/include/linux/mmzone.h	2006-09-11 16:45:01.863158377 -0500
@@ -90,6 +90,7 @@
 #endif
 
 enum zone_type {
+#ifdef CONFIG_ZONE_DMA
 	/*
 	 * ZONE_DMA is used when there are devices that are not able
 	 * to do DMA to all of addressable memory (ZONE_NORMAL). Then we
@@ -110,6 +111,7 @@
 	 * 			<16M.
 	 */
 	ZONE_DMA,
+#endif
 #ifdef CONFIG_ZONE_DMA32
 	/*
 	 * x86_64 needs two ZONE_DMAs because it supports devices that are
@@ -147,7 +149,11 @@
  */
 
 #if !defined(CONFIG_ZONE_DMA32) && !defined(CONFIG_HIGHMEM)
+#if !defined(CONFIG_ZONE_DMA)
+#define ZONES_SHIFT 0
+#else
 #define ZONES_SHIFT 1
+#endif
 #else
 #define ZONES_SHIFT 2
 #endif
@@ -447,7 +453,11 @@
 
 static inline int is_dma(struct zone *zone)
 {
+#ifdef CONFIG_ZONE_DMA
 	return zone == zone->zone_pgdat->node_zones + ZONE_DMA;
+#else
+	return 0;
+#endif
 }
 
 /* These two functions are used to setup the per zone pages min values */
Index: linux-2.6.18-rc6-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.18-rc6-mm1.orig/mm/page_alloc.c	2006-09-11 16:44:51.000000000 -0500
+++ linux-2.6.18-rc6-mm1/mm/page_alloc.c	2006-09-11 16:45:01.883667932 -0500
@@ -71,7 +71,9 @@
  * don't need any ZONE_NORMAL reservation
  */
 int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1] = {
+#ifdef CONFIG_ZONE_DMA
 	 256,
+#endif
 #ifdef CONFIG_ZONE_DMA32
 	 256,
 #endif
@@ -90,7 +92,9 @@
 EXPORT_SYMBOL(zone_table);
 
 static char *zone_names[MAX_NR_ZONES] = {
+#ifdef CONFIG_ZONE_DMA
 	 "DMA",
+#endif
 #ifdef CONFIG_ZONE_DMA32
 	 "DMA32",
 #endif
Index: linux-2.6.18-rc6-mm1/include/linux/gfp.h
===================================================================
--- linux-2.6.18-rc6-mm1.orig/include/linux/gfp.h	2006-09-11 16:44:16.000000000 -0500
+++ linux-2.6.18-rc6-mm1/include/linux/gfp.h	2006-09-11 16:45:01.902224197 -0500
@@ -80,8 +80,10 @@
 
 static inline enum zone_type gfp_zone(gfp_t flags)
 {
+#ifdef CONFIG_ZONE_DMA
 	if (flags & __GFP_DMA)
 		return ZONE_DMA;
+#endif
 #ifdef CONFIG_ZONE_DMA32
 	if (flags & __GFP_DMA32)
 		return ZONE_DMA32;
Index: linux-2.6.18-rc6-mm1/mm/slab.c
===================================================================
--- linux-2.6.18-rc6-mm1.orig/mm/slab.c	2006-09-11 16:44:16.000000000 -0500
+++ linux-2.6.18-rc6-mm1/mm/slab.c	2006-09-11 16:45:01.919803815 -0500
@@ -1441,13 +1443,14 @@
 					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
 					NULL, NULL);
 		}
-
+#ifdef CONFIG_ZONE_DMA
 		sizes->cs_dmacachep = kmem_cache_create(names->name_dma,
 					sizes->cs_size,
 					ARCH_KMALLOC_MINALIGN,
 					ARCH_KMALLOC_FLAGS|SLAB_CACHE_DMA|
 						SLAB_PANIC,
 					NULL, NULL);
+#endif
 		sizes++;
 		names++;
 	}
@@ -2275,8 +2278,10 @@
 	cachep->slab_size = slab_size;
 	cachep->flags = flags;
 	cachep->gfpflags = 0;
+#ifdef CONFIG_ZONE_DMA
 	if (flags & SLAB_CACHE_DMA)
 		cachep->gfpflags |= GFP_DMA;
+#endif
 	cachep->buffer_size = size;
 
 	if (flags & CFLGS_OFF_SLAB) {
Index: linux-2.6.18-rc6-mm1/include/linux/slab.h
===================================================================
--- linux-2.6.18-rc6-mm1.orig/include/linux/slab.h	2006-09-11 16:44:16.000000000 -0500
+++ linux-2.6.18-rc6-mm1/include/linux/slab.h	2006-09-11 16:45:01.931523561 -0500
@@ -72,7 +72,11 @@
 struct cache_sizes {
 	size_t		 cs_size;
 	kmem_cache_t	*cs_cachep;
+#ifdef CONFIG_ZONE_DMA
 	kmem_cache_t	*cs_dmacachep;
+#else
+#define cs_dmacachep cs_cachep
+#endif
 };
 extern struct cache_sizes malloc_sizes[];
 
Index: linux-2.6.18-rc6-mm1/mm/vmstat.c
===================================================================
--- linux-2.6.18-rc6-mm1.orig/mm/vmstat.c	2006-09-11 16:44:16.000000000 -0500
+++ linux-2.6.18-rc6-mm1/mm/vmstat.c	2006-09-11 16:45:01.940313371 -0500
@@ -437,6 +437,12 @@
 	.show	= frag_show,
 };
 
+#ifdef CONFIG_ZONE_DMA
+#define TEXT_FOR_DMA(xx) xx "_dma",
+#else
+#define TEXT_FOR_DMA(xx)
+#endif
+
 #ifdef CONFIG_ZONE_DMA32
 #define TEXT_FOR_DMA32(xx) xx "_dma32",
 #else
@@ -449,7 +455,7 @@
 #define TEXT_FOR_HIGHMEM(xx)
 #endif
 
-#define TEXTS_FOR_ZONES(xx) xx "_dma", TEXT_FOR_DMA32(xx) xx "_normal", \
+#define TEXTS_FOR_ZONES(xx) TEXT_FOR_DMA(xx) TEXT_FOR_DMA32(xx) xx "_normal", \
 					TEXT_FOR_HIGHMEM(xx)
 
 static char *vmstat_text[] = {
Index: linux-2.6.18-rc6-mm1/include/linux/vmstat.h
===================================================================
--- linux-2.6.18-rc6-mm1.orig/include/linux/vmstat.h	2006-09-11 16:44:16.000000000 -0500
+++ linux-2.6.18-rc6-mm1/include/linux/vmstat.h	2006-09-11 16:45:01.949103180 -0500
@@ -17,6 +17,12 @@
  * generated will simply be the increment of a global address.
  */
 
+#ifdef CONFIG_ZONE_DMA
+#define DMA_ZONE(xx) xx##_DMA,
+#else
+#define DMA_ZONE(xx)
+#endif
+
 #ifdef CONFIG_ZONE_DMA32
 #define DMA32_ZONE(xx) xx##_DMA32,
 #else
@@ -29,7 +35,7 @@
 #define HIGHMEM_ZONE(xx)
 #endif
 
-#define FOR_ALL_ZONES(xx) xx##_DMA, DMA32_ZONE(xx) xx##_NORMAL HIGHMEM_ZONE(xx)
+#define FOR_ALL_ZONES(xx) DMA_ZONE(xx) DMA32_ZONE(xx) xx##_NORMAL HIGHMEM_ZONE(xx)
 
 enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		FOR_ALL_ZONES(PGALLOC),
@@ -88,7 +94,8 @@
 #endif /* CONFIG_VM_EVENT_COUNTERS */
 
 #define __count_zone_vm_events(item, zone, delta) \
-			__count_vm_events(item##_DMA + zone_idx(zone), delta)
+		__count_vm_events(item##_NORMAL - ZONE_NORMAL + \
+		zone_idx(zone), delta)
 
 /*
  * Zone based page accounting with per cpu differentials.
@@ -135,14 +142,16 @@
 	struct zone *zones = NODE_DATA(node)->node_zones;
 
 	return
+#ifdef CONFIG_ZONE_DMA
+		zone_page_state(&zones[ZONE_DMA], item) +
+#endif
 #ifdef CONFIG_ZONE_DMA32
 		zone_page_state(&zones[ZONE_DMA32], item) +
 #endif
-		zone_page_state(&zones[ZONE_NORMAL], item) +
 #ifdef CONFIG_HIGHMEM
 		zone_page_state(&zones[ZONE_HIGHMEM], item) +
 #endif
-		zone_page_state(&zones[ZONE_DMA], item);
+		zone_page_state(&zones[ZONE_NORMAL], item);
 }
 
 extern void zone_statistics(struct zonelist *, struct zone *);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
