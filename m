Date: Mon, 13 Mar 2000 17:50:50 -0500 (EST)
From: Ben LaHaise <bcrl@redhat.com>
Subject: [patch] first bit of vm balancing fixes for 2.3.52-1
Message-ID: <Pine.LNX.4.21.0003131743410.6254-100000@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

This is the first little bit of a few vm balancing patches I've been
working on.  It does two main things: moves the lru_cache list into the
per-zone structure, and slightly reworks the kswapd wakeup logic so the
zone_wake_kswapd flag is cleared in free_pages_ok.  Moving the lru_cache
list into the zone structure means we can make much better progress when
trying to free a specific type of memory.  Moving the clearing of the
zone_wake_kswapd flag into the free_pages routine stops kswapd from
continuing to swap out ad nausium: my box will discard the entire page
cache when it hits low memory when doing a simple sequential read.  With
this patch in place it hovers around 3MB free as it should.

		-ben

diff -ur 2.3.52-1/include/linux/mmzone.h linux/include/linux/mmzone.h
--- 2.3.52-1/include/linux/mmzone.h	Mon Mar 13 15:16:25 2000
+++ linux/include/linux/mmzone.h	Mon Mar 13 16:08:21 2000
@@ -15,8 +15,8 @@
 #define MAX_ORDER 10
 
 typedef struct free_area_struct {
-	struct list_head free_list;
-	unsigned int * map;
+	struct list_head	free_list;
+	unsigned int		*map;
 } free_area_t;
 
 struct pglist_data;
@@ -25,30 +25,31 @@
 	/*
 	 * Commonly accessed fields:
 	 */
-	spinlock_t lock;
-	unsigned long offset;
-	unsigned long free_pages;
-	char low_on_memory;
-	char zone_wake_kswapd;
-	unsigned long pages_min, pages_low, pages_high;
+	spinlock_t		lock;
+	unsigned long		offset;
+	unsigned long		free_pages;
+	char			low_on_memory;
+	char			zone_wake_kswapd;
+	unsigned long		pages_min, pages_low, pages_high;
+	struct list_head	lru_cache;
 
 	/*
 	 * free areas of different sizes
 	 */
-	free_area_t free_area[MAX_ORDER];
+	free_area_t		free_area[MAX_ORDER];
 
 	/*
 	 * rarely used fields:
 	 */
-	char * name;
-	unsigned long size;
+	char			*name;
+	unsigned long		size;
 	/*
 	 * Discontig memory support fields.
 	 */
-	struct pglist_data *zone_pgdat;
-	unsigned long zone_start_paddr;
-	unsigned long zone_start_mapnr;
-	struct page * zone_mem_map;
+	struct pglist_data	*zone_pgdat;
+	unsigned long		zone_start_paddr;
+	unsigned long		zone_start_mapnr;
+	struct page		*zone_mem_map;
 } zone_t;
 
 #define ZONE_DMA		0
diff -ur 2.3.52-1/include/linux/swap.h linux/include/linux/swap.h
--- 2.3.52-1/include/linux/swap.h	Mon Mar 13 15:16:26 2000
+++ linux/include/linux/swap.h	Mon Mar 13 16:38:31 2000
@@ -67,7 +67,6 @@
 FASTCALL(unsigned int nr_free_buffer_pages(void));
 FASTCALL(unsigned int nr_free_highpages(void));
 extern int nr_lru_pages;
-extern struct list_head lru_cache;
 extern atomic_t nr_async_pages;
 extern struct address_space swapper_space;
 extern atomic_t page_cache_size;
@@ -167,7 +166,7 @@
 #define	lru_cache_add(page)			\
 do {						\
 	spin_lock(&pagemap_lru_lock);		\
-	list_add(&(page)->lru, &lru_cache);	\
+	list_add(&(page)->lru, &page->zone->lru_cache);	\
 	nr_lru_pages++;				\
 	spin_unlock(&pagemap_lru_lock);		\
 } while (0)
diff -ur 2.3.52-1/mm/filemap.c linux/mm/filemap.c
--- 2.3.52-1/mm/filemap.c	Sun Mar 12 18:03:02 2000
+++ linux/mm/filemap.c	Mon Mar 13 16:40:04 2000
@@ -220,15 +220,18 @@
 	struct list_head * page_lru, * dispose;
 	struct page * page;
 
+	if (!zone)
+		BUG();
+
 	count = nr_lru_pages / (priority+1);
 
 	spin_lock(&pagemap_lru_lock);
 
-	while (count > 0 && (page_lru = lru_cache.prev) != &lru_cache) {
+	while (count > 0 && (page_lru = zone->lru_cache.prev) != &zone->lru_cache) {
 		page = list_entry(page_lru, struct page, lru);
 		list_del(page_lru);
 
-		dispose = &lru_cache;
+		dispose = &zone->lru_cache;
 		if (test_and_clear_bit(PG_referenced, &page->flags))
 			/* Roll the page at the top of the lru list,
 			 * we could also be more aggressive putting
@@ -355,8 +358,8 @@
 	nr_lru_pages--;
 
 out:
-	list_splice(&young, &lru_cache);
-	list_splice(&old, lru_cache.prev);
+	list_splice(&young, &zone->lru_cache);
+	list_splice(&old, zone->lru_cache.prev);
 
 	spin_unlock(&pagemap_lru_lock);
 
diff -ur 2.3.52-1/mm/page_alloc.c linux/mm/page_alloc.c
--- 2.3.52-1/mm/page_alloc.c	Fri Mar 10 16:11:22 2000
+++ linux/mm/page_alloc.c	Mon Mar 13 17:17:53 2000
@@ -26,7 +26,6 @@
 
 int nr_swap_pages = 0;
 int nr_lru_pages;
-LIST_HEAD(lru_cache);
 pg_data_t *pgdat_list = (pg_data_t *)0;
 
 static char *zone_names[MAX_NR_ZONES] = { "DMA", "Normal", "HighMem" };
@@ -59,6 +58,19 @@
  */
 #define BAD_RANGE(zone,x) (((zone) != (x)->zone) || (((x)-mem_map) < (zone)->offset) || (((x)-mem_map) >= (zone)->offset+(zone)->size))
 
+static inline unsigned long classfree(zone_t *zone)
+{
+	unsigned long free = 0;
+	zone_t *z = zone->zone_pgdat->node_zones;
+
+	while (z != zone) {
+		free += z->free_pages;
+		z++;
+	}
+	free += zone->free_pages;
+	return(free);
+}
+
 /*
  * Buddy system. Hairy. You really aren't expected to understand this
  *
@@ -135,6 +147,9 @@
 	memlist_add_head(&(base + page_idx)->list, &area->free_list);
 
 	spin_unlock_irqrestore(&zone->lock, flags);
+
+	if (classfree(zone) > zone->pages_high)
+		zone->zone_wake_kswapd = 0;
 }
 
 #define MARK_USED(index, order, area) \
@@ -201,19 +216,6 @@
 	return NULL;
 }
 
-static inline unsigned long classfree(zone_t *zone)
-{
-	unsigned long free = 0;
-	zone_t *z = zone->zone_pgdat->node_zones;
-
-	while (z != zone) {
-		free += z->free_pages;
-		z++;
-	}
-	free += zone->free_pages;
-	return(free);
-}
-
 static inline int zone_balance_memory (zone_t *zone, int gfp_mask)
 {
 	int freed;
@@ -263,21 +265,12 @@
 		{
 			unsigned long free = classfree(z);
 
-			if (free > z->pages_high)
-			{
-				if (z->low_on_memory)
-					z->low_on_memory = 0;
-				z->zone_wake_kswapd = 0;
-			}
-			else
+			if (free <= z->pages_high)
 			{
 				extern wait_queue_head_t kswapd_wait;
 
-				if (free <= z->pages_low) {
-					z->zone_wake_kswapd = 1;
-					wake_up_interruptible(&kswapd_wait);
-				} else
-					z->zone_wake_kswapd = 0;
+				z->zone_wake_kswapd = 1;
+				wake_up_interruptible(&kswapd_wait);
 
 				if (free <= z->pages_min)
 					z->low_on_memory = 1;
@@ -585,6 +578,7 @@
 			unsigned long bitmap_size;
 
 			memlist_init(&zone->free_area[i].free_list);
+			memlist_init(&zone->lru_cache);
 			mask += mask;
 			size = (size + ~mask) & mask;
 			bitmap_size = size >> i;
diff -ur 2.3.52-1/mm/vmscan.c linux/mm/vmscan.c
--- 2.3.52-1/mm/vmscan.c	Mon Feb 28 10:44:22 2000
+++ linux/mm/vmscan.c	Mon Mar 13 17:07:23 2000
@@ -504,8 +504,7 @@
 			while (pgdat) {
 				for (i = 0; i < MAX_NR_ZONES; i++) {
 					zone = pgdat->node_zones + i;
-					if ((!zone->size) || 
-							(!zone->zone_wake_kswapd))
+					if ((!zone->size) || (!zone->zone_wake_kswapd))
 						continue;
 					do_try_to_free_pages(GFP_KSWAPD, zone);
 				}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
