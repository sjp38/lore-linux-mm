Date: Tue, 6 Aug 2002 16:11:09 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] for_each_pgdat/for_each_zone
Message-ID: <20020806161109.A2543@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: marcelo@conectiva.com.br
Cc: riel@conectiva.com.br, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

These patches from wli and Rik allow easy traversal of all pgdat's or
zones in the system and cleanup some VM code nicely.  It has been in
-rmap for ages and in 2.5 for a few weeks.

Adopted to mainline by me.


diff -uNr -Xdontdiff -p linux-2.4.20-pre1/include/linux/mmzone.h linux/include/linux/mmzone.h
--- linux-2.4.20-pre1/include/linux/mmzone.h	Tue Aug  6 11:27:18 2002
+++ linux/include/linux/mmzone.h	Tue Aug  6 15:00:46 2002
@@ -158,6 +158,60 @@ extern void free_area_init_core(int nid,
 
 extern pg_data_t contig_page_data;
 
+/**
+ * for_each_pgdat - helper macro to iterate over all nodes
+ * @pgdat - pg_data_t * variable
+ *
+ * Meant to help with common loops of the form
+ * pgdat = pgdat_list;
+ * while(pgdat) {
+ * 	...
+ * 	pgdat = pgdat->node_next;
+ * }
+ */
+#define for_each_pgdat(pgdat) \
+	for (pgdat = pgdat_list; pgdat; pgdat = pgdat->node_next)
+
+
+/*
+ * next_zone - helper magic for for_each_zone()
+ * Thanks to William Lee Irwin III for this piece of ingenuity.
+ */
+static inline zone_t *next_zone(zone_t *zone)
+{
+	pg_data_t *pgdat = zone->zone_pgdat;
+
+	if (zone - pgdat->node_zones < MAX_NR_ZONES - 1)
+		zone++;
+
+	else if (pgdat->node_next) {
+		pgdat = pgdat->node_next;
+		zone = pgdat->node_zones;
+	} else
+		zone = NULL;
+
+	return zone;
+}
+
+/**
+ * for_each_zone - helper macro to iterate over all memory zones
+ * @zone - zone_t * variable
+ *
+ * The user only needs to declare the zone variable, for_each_zone
+ * fills it in. This basically means for_each_zone() is an
+ * easier to read version of this piece of code:
+ *
+ * for(pgdat = pgdat_list; pgdat; pgdat = pgdat->node_next)
+ * 	for(i = 0; i < MAX_NR_ZONES; ++i) {
+ * 		zone_t * z = pgdat->node_zones + i;
+ * 		...
+ * 	}
+ * }
+ */
+#define for_each_zone(zone) \
+	for(zone = pgdat_list->node_zones; zone; zone = next_zone(zone))
+
+
 #ifndef CONFIG_DISCONTIGMEM
 
 #define NODE_DATA(nid)		(&contig_page_data)
diff -uNr -Xdontdiff -p linux-2.4.20-pre1/mm/bootmem.c linux/mm/bootmem.c
--- linux-2.4.20-pre1/mm/bootmem.c	Tue Aug  6 11:29:29 2002
+++ linux/mm/bootmem.c	Tue Aug  6 15:09:19 2002
@@ -324,15 +324,14 @@ unsigned long __init free_all_bootmem (v
 
 void * __init __alloc_bootmem (unsigned long size, unsigned long align, unsigned long goal)
 {
-	pg_data_t *pgdat = pgdat_list;
+	pg_data_t *pgdat;
 	void *ptr;
 
-	while (pgdat) {
+	for_each_pgdat(pgdat)
 		if ((ptr = __alloc_bootmem_core(pgdat->bdata, size,
 						align, goal)))
 			return(ptr);
-		pgdat = pgdat->node_next;
-	}
+
 	/*
 	 * Whoops, we cannot satisfy the allocation request.
 	 */
diff -uNr -Xdontdiff -p linux-2.4.20-pre1/mm/page_alloc.c linux/mm/page_alloc.c
--- linux-2.4.20-pre1/mm/page_alloc.c	Tue Aug  6 11:27:49 2002
+++ linux/mm/page_alloc.c	Tue Aug  6 15:07:05 2002
@@ -456,16 +456,12 @@ void free_pages(unsigned long addr, unsi
  */
 unsigned int nr_free_pages (void)
 {
-	unsigned int sum;
+	unsigned int sum = 0;
 	zone_t *zone;
-	pg_data_t *pgdat = pgdat_list;
 
-	sum = 0;
-	while (pgdat) {
-		for (zone = pgdat->node_zones; zone < pgdat->node_zones + MAX_NR_ZONES; zone++)
-			sum += zone->free_pages;
-		pgdat = pgdat->node_next;
-	}
+	for_each_zone(zone)
+		sum += zone->free_pages;
+
 	return sum;
 }
 
@@ -474,10 +470,10 @@ unsigned int nr_free_pages (void)
  */
 unsigned int nr_free_buffer_pages (void)
 {
-	pg_data_t *pgdat = pgdat_list;
+	pg_data_t *pgdat;
 	unsigned int sum = 0;
 
-	do {
+	for_each_pgdat(pgdat) {
 		zonelist_t *zonelist = pgdat->node_zonelists + (GFP_USER & GFP_ZONEMASK);
 		zone_t **zonep = zonelist->zones;
 		zone_t *zone;
@@ -488,9 +484,7 @@ unsigned int nr_free_buffer_pages (void)
 			if (size > high)
 				sum += size - high;
 		}
-
-		pgdat = pgdat->node_next;
-	} while (pgdat);
+	}
 
 	return sum;
 }
@@ -498,13 +492,12 @@ unsigned int nr_free_buffer_pages (void)
 #if CONFIG_HIGHMEM
 unsigned int nr_free_highpages (void)
 {
-	pg_data_t *pgdat = pgdat_list;
+	pg_data_t *pgdat;
 	unsigned int pages = 0;
 
-	while (pgdat) {
+	for_each_pgdat(pgdat)
 		pages += pgdat->node_zones[ZONE_HIGHMEM].free_pages;
-		pgdat = pgdat->node_next;
-	}
+
 	return pages;
 }
 #endif
diff -uNr -Xdontdiff -p linux-2.4.20-pre1/mm/vmscan.c linux/mm/vmscan.c
--- linux-2.4.20-pre1/mm/vmscan.c	Tue Aug  6 11:28:13 2002
+++ linux/mm/vmscan.c	Tue Aug  6 15:08:56 2002
@@ -649,10 +649,9 @@ static void kswapd_balance(void)
 
 	do {
 		need_more_balance = 0;
-		pgdat = pgdat_list;
-		do
+
+		for_each_pgdat(pgdat)
 			need_more_balance |= kswapd_balance_pgdat(pgdat);
-		while ((pgdat = pgdat->node_next));
 	} while (need_more_balance);
 }
 
@@ -675,12 +674,10 @@ static int kswapd_can_sleep(void)
 {
 	pg_data_t * pgdat;
 
-	pgdat = pgdat_list;
-	do {
-		if (kswapd_can_sleep_pgdat(pgdat))
-			continue;
-		return 0;
-	} while ((pgdat = pgdat->node_next));
+	for_each_pgdat(pgdat) {
+		if (!kswapd_can_sleep_pgdat(pgdat))
+			return 0;
+	}
 
 	return 1;
 }
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
