From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] 6/4  -ac to newer rmap
Message-Id: <20021113145002Z80405-18062+18@imladris.surriel.com>
Date: Wed, 13 Nov 2002 12:50:02 -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Arjan van de Ven <arjanv@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch brings mm/page_alloc.c from -ac up to date with that in -rmap.
The -rmap patch has a corresponding patch to bring -rmap up to date with -ac.

(ObWork: my patches are sponsored by Conectiva, Inc)

--- linux-2.4.19/mm/page_alloc.c	2002-11-13 09:22:16.000000000 -0200
+++ linux-2.4-rmap/mm/page_alloc.c	2002-11-13 12:24:51.000000000 -0200
@@ -31,11 +31,7 @@
 int nr_inactive_clean_pages;
 pg_data_t *pgdat_list;
 
-/*
- * The zone_table array is used to look up the address of the
- * struct zone corresponding to a given zone number (ZONE_DMA,
- * ZONE_NORMAL, or ZONE_HIGHMEM).
- */
+/* Used to look up the address of the struct zone encoded in page->zone */
 zone_t *zone_table[MAX_NR_ZONES*MAX_NR_NODES];
 EXPORT_SYMBOL(zone_table);
 
@@ -51,17 +47,15 @@
  */
 #define BAD_RANGE(zone, page)						\
 (									\
-	(((page) - mem_map) >= ((zone)->zone_start_mapnr+(zone)->size)) \
+	(((page) - mem_map) >= ((zone)->zone_start_mapnr+(zone)->size))	\
 	|| (((page) - mem_map) < (zone)->zone_start_mapnr)		\
 	|| ((zone) != page_zone(page))					\
 )
 
 /*
  * Freeing function for a buddy system allocator.
- * Contrary to prior comments, this is *NOT* hairy, and there
- * is no reason for anyone not to understand it.
  *
- * The concept of a buddy system is to maintain direct-mapped tables
+ * The concept of a buddy system is to maintain direct-mapped table
  * (containing bit values) for memory blocks of various "orders".
  * The bottom level table contains the map for the smallest allocatable
  * units of memory (here, pages), and each level above it describes
@@ -113,8 +107,6 @@
 	}
 	if (!VALID_PAGE(page))
 		BUG();
-	if (PageSwapCache(page))
-		BUG();
 	if (PageLocked(page))
 		BUG();
 	if (PageActive(page))
@@ -167,7 +159,7 @@
 		/*
 		 * Move the buddy up one level.
 		 * This code is taking advantage of the identity:
-		 *	-mask = 1+~mask
+		 * 	-mask = 1+~mask
 		 */
 		buddy1 = base + (page_idx ^ -mask);
 		buddy2 = base + page_idx;
@@ -392,6 +384,8 @@
 	 * any data we would want to cache.
 	 */
 	zone = zonelist->zones;
+	if (!*zone)
+		return NULL;
 	min = 1UL << order;
 	for (;;) {
 		zone_t *z = *(zone++);
@@ -958,12 +952,8 @@
 			continue;
 
 		/*
-		 * The per-page waitqueue mechanism requires hash tables
-		 * whose buckets are waitqueues. These hash tables are
-		 * per-zone, and dynamically sized according to the size
-		 * of the zone so as to maintain a good ratio of waiters
-		 * to hash table buckets. Right here we just allocate
-		 * and initialize them for later use (in filemap.c)
+		 * The per-page waitqueue mechanism uses hashed waitqueues
+		 * per zone.
 		 */
 		zone->wait_table_size = wait_table_size(size);
 		zone->wait_table_shift =
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
