Date: Thu, 10 Apr 2003 12:30:14 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] architecture hooks for mem_map initialization
Message-ID: <20030410123014.A17956@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@zip.com.au
Cc: davidm@napali.hpl.hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is from the IA64 tree, with minor cleanups from me.

Split out initialization of pgdat->node_mem_map into a separate function
and allow architectures to override it.  This is needed for HP IA64
machines that have a virtually mapped memory map to support big
memory holes without having to use discontigmem.

(memmap_init_zone is non-static to allow the IA64 code to use it -
 I did that instead of passing it's address into the arch hook as
 it is done currently in the IA64 tree)


--- 1.115/include/linux/mm.h	Tue Apr  8 05:03:24 2003
+++ edited/include/linux/mm.h	Thu Apr 10 07:53:31 2003
@@ -486,6 +486,8 @@
 extern void free_area_init_node(int nid, pg_data_t *pgdat, struct page *pmap,
 	unsigned long * zones_size, unsigned long zone_start_pfn, 
 	unsigned long *zholes_size);
+extern void memmap_init_zone(struct page *, unsigned long, int,
+	unsigned long, unsigned long);
 extern void mem_init(void);
 extern void show_mem(void);
 extern void si_meminfo(struct sysinfo * val);
--- 1.151/mm/page_alloc.c	Wed Apr  9 04:01:28 2003
+++ edited/mm/page_alloc.c	Thu Apr 10 07:53:23 2003
@@ -1142,6 +1142,35 @@
 }
 
 /*
+ * Initially all pages are reserved - free ones are freed
+ * up by free_all_bootmem() once the early boot process is
+ * done. Non-atomic initialization, single-pass.
+ */
+void __init memmap_init_zone(struct page *start, unsigned long size, int nid,
+		unsigned long zone, unsigned long start_pfn)
+{
+	struct page *page;
+
+	for (page = start; page < (start + size); page++) {
+		set_page_zone(page, nid * MAX_NR_ZONES + zone);
+		set_page_count(page, 0);
+		SetPageReserved(page);
+		INIT_LIST_HEAD(&page->list);
+#ifdef WANT_PAGE_VIRTUAL
+		/* The shift won't overflow because ZONE_NORMAL is below 4G. */
+		if (zone != ZONE_HIGHMEM)
+			set_page_address(page, __va(start_pfn << PAGE_SHIFT));
+#endif
+		start_pfn++;
+	}
+}
+
+#ifndef __HAVE_ARCH_MEMMAP_INIT
+#define memmap_init(start, size, nid, zone, start_pfn) \
+	memmap_init_zone((start), (size), (nid), (zone), (start_pfn))
+#endif
+
+/*
  * Set up the zone data structures:
  *   - mark all pages reserved
  *   - mark all memory queues empty
@@ -1151,7 +1180,6 @@
 		unsigned long *zones_size, unsigned long *zholes_size)
 {
 	unsigned long i, j;
-	unsigned long local_offset;
 	const unsigned long zone_required_alignment = 1UL << (MAX_ORDER-1);
 	int cpu, nid = pgdat->node_id;
 	struct page *lmem_map = pgdat->node_mem_map;
@@ -1160,7 +1188,6 @@
 	pgdat->nr_zones = 0;
 	init_waitqueue_head(&pgdat->kswapd_wait);
 	
-	local_offset = 0;                /* offset within lmem_map */
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		struct zone *zone = pgdat->node_zones + j;
 		unsigned long mask;
@@ -1246,36 +1273,17 @@
 		zone->pages_low = mask*2;
 		zone->pages_high = mask*3;
 
-		zone->zone_mem_map = lmem_map + local_offset;
+		zone->zone_mem_map = lmem_map;
 		zone->zone_start_pfn = zone_start_pfn;
 
 		if ((zone_start_pfn) & (zone_required_alignment-1))
 			printk("BUG: wrong zone alignment, it will crash\n");
 
-		/*
-		 * Initially all pages are reserved - free ones are freed
-		 * up by free_all_bootmem() once the early boot process is
-		 * done. Non-atomic initialization, single-pass.
-		 */
-		for (i = 0; i < size; i++) {
-			struct page *page = lmem_map + local_offset + i;
-			set_page_zone(page, nid * MAX_NR_ZONES + j);
-			set_page_count(page, 0);
-			SetPageReserved(page);
-			INIT_LIST_HEAD(&page->list);
-#ifdef WANT_PAGE_VIRTUAL
-			if (j != ZONE_HIGHMEM)
-				/*
-				 * The shift left won't overflow because the
-				 * ZONE_NORMAL is below 4G.
-				 */
-				set_page_address(page,
-					__va(zone_start_pfn << PAGE_SHIFT));
-#endif
-			zone_start_pfn++;
-		}
+		memmap_init(lmem_map, size, nid, j, zone_start_pfn);
+
+		zone_start_pfn += size;
+		lmem_map += size;
 
-		local_offset += size;
 		for (i = 0; ; i++) {
 			unsigned long bitmap_size;
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
