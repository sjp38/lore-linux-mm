Date: Mon, 16 Aug 1999 12:04:38 -0400 (EDT)
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [rfc] 2.3.14-1 patch: dma memory pool handling
Message-ID: <Pine.LNX.3.96.990816120200.6635A-100000@mole.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hey all,

the following patch against 2.3.14-1 splits memory pools into different
'types'.  For now that's only dma vs non, but I intend to add support for
unmapped memory to help deal with 4GB machines (no 36 bit paging yet).
Comments?

		-ben

diff -ur clean/2.3.14-1/mm/page_alloc.c lin/mm/page_alloc.c
--- clean/2.3.14-1/mm/page_alloc.c	Mon Aug  9 14:37:05 1999
+++ lin/mm/page_alloc.c	Mon Aug 16 00:37:15 1999
@@ -35,17 +35,19 @@
 #else
 #define NR_MEM_LISTS 10
 #endif
+#define NR_MEM_TYPES 2
 
 /* The start of this MUST match the start of "struct page" */
 struct free_area_struct {
 	struct page *next;
 	struct page *prev;
 	unsigned int * map;
+	unsigned long count;
 };
 
 #define memory_head(x) ((struct page *)(x))
 
-static struct free_area_struct free_area[NR_MEM_LISTS];
+static struct free_area_struct free_area[NR_MEM_TYPES][NR_MEM_LISTS];
 
 static inline void init_mem_queue(struct free_area_struct * head)
 {
@@ -61,6 +63,7 @@
 	entry->next = next;
 	next->prev = entry;
 	head->next = entry;
+	head->count++;
 }
 
 static inline void remove_mem_queue(struct page * entry)
@@ -90,13 +93,17 @@
  */
 spinlock_t page_alloc_lock = SPIN_LOCK_UNLOCKED;
 
-static inline void free_pages_ok(unsigned long map_nr, unsigned long order)
+static inline void free_pages_ok(unsigned long map_nr, unsigned long order, unsigned type)
 {
-	struct free_area_struct *area = free_area + order;
+	struct free_area_struct *area = free_area[type] + order;
 	unsigned long index = map_nr >> (1 + order);
 	unsigned long mask = (~0UL) << order;
 	unsigned long flags;
 
+	if (type >= NR_MEM_LISTS) {
+		printk("free_pages_ok: type invalid: %04x\n", type);
+		BUG();
+	}
 	spin_lock_irqsave(&page_alloc_lock, flags);
 
 #define list(x) (mem_map+(x))
@@ -106,6 +113,7 @@
 	while (mask + (1 << (NR_MEM_LISTS-1))) {
 		if (!test_and_change_bit(index, area->map))
 			break;
+		area->count--;
 		remove_mem_queue(list(map_nr ^ -mask));
 		mask <<= 1;
 		area++;
@@ -119,7 +127,7 @@
 	spin_unlock_irqrestore(&page_alloc_lock, flags);
 }
 
-int __free_page(struct page *page)
+static inline int __free_pages(struct page *page, unsigned long order)
 {
 	if (!PageReserved(page) && put_page_testzero(page)) {
 		if (PageSwapCache(page))
@@ -128,28 +136,23 @@
 			PAGE_BUG(page);
 
 		page->flags &= ~(1 << PG_referenced);
-		free_pages_ok(page - mem_map, 0);
+		free_pages_ok(page - mem_map, order, PageDMA(page) ? 1 : 0);
 		return 1;
 	}
 	return 0;
 }
 
+int __free_page(struct page *page)
+{
+	return __free_pages(page, 0);
+}
+
 int free_pages(unsigned long addr, unsigned long order)
 {
 	unsigned long map_nr = MAP_NR(addr);
 
-	if (map_nr < max_mapnr) {
-		mem_map_t * map = mem_map + map_nr;
-		if (!PageReserved(map) && put_page_testzero(map)) {
-			if (PageSwapCache(map))
-				PAGE_BUG(map);
-			if (PageLocked(map))
-				PAGE_BUG(map);
-			map->flags &= ~(1 << PG_referenced);
-			free_pages_ok(map_nr, order);
-			return 1;
-		}
-	}
+	if (map_nr < max_mapnr)
+		return __free_pages(mem_map + map_nr, order);
 	return 0;
 }
 
@@ -158,25 +161,21 @@
  */
 #define MARK_USED(index, order, area) \
 	change_bit((index) >> (1+(order)), (area)->map)
-#define CAN_DMA(x) (PageDMA(x))
 #define ADDRESS(x) (PAGE_OFFSET + ((x) << PAGE_SHIFT))
-#define RMQUEUE(order, gfp_mask) \
-do { struct free_area_struct * area = free_area+order; \
+#define RMQUEUE(order, type) \
+do { struct free_area_struct * area = free_area[type]+order; \
      unsigned long new_order = order; \
 	do { struct page *prev = memory_head(area), *ret = prev->next; \
-		while (memory_head(area) != ret) { \
-			if (!(gfp_mask & __GFP_DMA) || CAN_DMA(ret)) { \
-				unsigned long map_nr; \
-				(prev->next = ret->next)->prev = prev; \
-				map_nr = ret - mem_map; \
-				MARK_USED(map_nr, new_order, area); \
-				nr_free_pages -= 1 << order; \
-				EXPAND(ret, map_nr, order, new_order, area); \
-				spin_unlock_irqrestore(&page_alloc_lock,flags);\
-				return ADDRESS(map_nr); \
-			} \
-			prev = ret; \
-			ret = ret->next; \
+		if (memory_head(area) != ret) { \
+			unsigned long map_nr; \
+			(prev->next = ret->next)->prev = prev; \
+			map_nr = ret - mem_map; \
+			MARK_USED(map_nr, new_order, area); \
+			nr_free_pages -= 1 << order; \
+			area->count--; \
+			EXPAND(ret, map_nr, order, new_order, area); \
+			spin_unlock_irqrestore(&page_alloc_lock, flags);\
+			return ADDRESS(map_nr); \
 		} \
 		new_order++; area++; \
 	} while (new_order < NR_MEM_LISTS); \
@@ -240,7 +239,14 @@
 	}
 ok_to_allocate:
 	spin_lock_irqsave(&page_alloc_lock, flags);
-	RMQUEUE(order, gfp_mask);
+	if (!(gfp_mask & GFP_DMA))
+		RMQUEUE(order, 0);
+	RMQUEUE(order, 1);
+#if 0
+	do {
+		RMQUEUE(order, type);
+	} while (type-- > GFP_DMA) ;
+#endif
 	spin_unlock_irqrestore(&page_alloc_lock, flags);
 
 	/*
@@ -264,27 +270,27 @@
  */
 void show_free_areas(void)
 {
- 	unsigned long order, flags;
- 	unsigned long total = 0;
+ 	unsigned long order, flags, type;
 
+	/* We want all information to be consistent, so lock it first. */
+	spin_lock_irqsave(&page_alloc_lock, flags);
 	printk("Free pages:      %6dkB\n ( ",nr_free_pages<<(PAGE_SHIFT-10));
 	printk("Free: %d (%d %d %d)\n",
 		nr_free_pages,
 		freepages.min,
 		freepages.low,
 		freepages.high);
-	spin_lock_irqsave(&page_alloc_lock, flags);
- 	for (order=0 ; order < NR_MEM_LISTS; order++) {
-		struct page * tmp;
-		unsigned long nr = 0;
-		for (tmp = free_area[order].next ; tmp != memory_head(free_area+order) ; tmp = tmp->next) {
-			nr ++;
+	for (type = 0; type < NR_MEM_TYPES; type++) {
+ 		unsigned long total = 0;
+		printk("Type %lu: ", type);
+ 		for (order=0 ; order < NR_MEM_LISTS; order++) {
+			unsigned long nr = free_area[type][order].count;
+			total += nr * ((PAGE_SIZE>>10) << order);
+			printk("%lu*%lukB ", nr, (unsigned long)((PAGE_SIZE>>10) << order));
 		}
-		total += nr * ((PAGE_SIZE>>10) << order);
-		printk("%lu*%lukB ", nr, (unsigned long)((PAGE_SIZE>>10) << order));
+		printk("= %lukB)\n", total);
 	}
 	spin_unlock_irqrestore(&page_alloc_lock, flags);
-	printk("= %lukB)\n", total);
 #ifdef SWAP_CACHE_INFO
 	show_swap_cache_info();
 #endif	
@@ -300,9 +306,9 @@
  */
 unsigned long __init free_area_init(unsigned long start_mem, unsigned long end_mem)
 {
-	mem_map_t * p;
 	unsigned long mask = PAGE_MASK;
-	unsigned long i;
+	mem_map_t * p;
+	unsigned long i, j;
 
 	/*
 	 * Select nr of pages we try to keep free for important stuff
@@ -332,15 +338,17 @@
 
 	for (i = 0 ; i < NR_MEM_LISTS ; i++) {
 		unsigned long bitmap_size;
-		init_mem_queue(free_area+i);
 		mask += mask;
 		end_mem = (end_mem + ~mask) & mask;
 		bitmap_size = (end_mem - PAGE_OFFSET) >> (PAGE_SHIFT + i);
 		bitmap_size = (bitmap_size + 7) >> 3;
 		bitmap_size = LONG_ALIGN(bitmap_size);
-		free_area[i].map = (unsigned int *) start_mem;
-		memset((void *) start_mem, 0, bitmap_size);
-		start_mem += bitmap_size;
+		for (j = 0; j < NR_MEM_TYPES; j++) {
+			init_mem_queue(free_area[j]+i);
+			free_area[j][i].map = (unsigned int *) start_mem;
+			memset((void *) start_mem, 0, bitmap_size);
+			start_mem += bitmap_size;
+		}
 	}
 	return start_mem;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
