Message-ID: <417F55B9.7090306@yahoo.com.au>
Date: Wed, 27 Oct 2004 18:00:57 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH 1/3] keep count of free areas
References: <417F5584.2070400@yahoo.com.au>
In-Reply-To: <417F5584.2070400@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------050506080709000501080509"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------050506080709000501080509
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

1/3

--------------050506080709000501080509
Content-Type: text/x-patch;
 name="vm-free-order-pages.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vm-free-order-pages.patch"



Keep track of the number of free pages of each order in the buddy allocator.

Signed-off-by: Nick Piggin <nickpiggin@yahoo.com.au>


---

 linux-2.6-npiggin/include/linux/mmzone.h |    1 +
 linux-2.6-npiggin/mm/page_alloc.c        |   23 +++++++++--------------
 2 files changed, 10 insertions(+), 14 deletions(-)

diff -puN mm/page_alloc.c~vm-free-order-pages mm/page_alloc.c
--- linux-2.6/mm/page_alloc.c~vm-free-order-pages	2004-10-27 14:27:31.000000000 +1000
+++ linux-2.6-npiggin/mm/page_alloc.c	2004-10-27 16:41:28.000000000 +1000
@@ -209,6 +209,7 @@ static inline void __free_pages_bulk (st
 		BUG_ON(bad_range(zone, buddy1));
 		BUG_ON(bad_range(zone, buddy2));
 		list_del(&buddy1->lru);
+		area->nr_free--;
 		mask <<= 1;
 		order++;
 		area++;
@@ -216,6 +217,7 @@ static inline void __free_pages_bulk (st
 		page_idx &= mask;
 	}
 	list_add(&(base + page_idx)->lru, &area->free_list);
+	area->nr_free++;
 }
 
 static inline void free_pages_check(const char *function, struct page *page)
@@ -317,6 +319,7 @@ expand(struct zone *zone, struct page *p
 		size >>= 1;
 		BUG_ON(bad_range(zone, &page[size]));
 		list_add(&page[size].lru, &area->free_list);
+		area->nr_free++;
 		MARK_USED(index + size, high, area);
 	}
 	return page;
@@ -380,6 +383,7 @@ static struct page *__rmqueue(struct zon
 
 		page = list_entry(area->free_list.next, struct page, lru);
 		list_del(&page->lru);
+		area->nr_free--;
 		index = page - zone->zone_mem_map;
 		if (current_order != MAX_ORDER-1)
 			MARK_USED(index, current_order, area);
@@ -1120,7 +1124,6 @@ void show_free_areas(void)
 	}
 
 	for_each_zone(zone) {
-		struct list_head *elem;
  		unsigned long nr, flags, order, total = 0;
 
 		show_node(zone);
@@ -1132,9 +1135,7 @@ void show_free_areas(void)
 
 		spin_lock_irqsave(&zone->lock, flags);
 		for (order = 0; order < MAX_ORDER; order++) {
-			nr = 0;
-			list_for_each(elem, &zone->free_area[order].free_list)
-				++nr;
+			nr = zone->free_area[order].nr_free;
 			total += nr << order;
 			printk("%lu*%lukB ", nr, K(1UL) << order);
 		}
@@ -1460,6 +1461,7 @@ void zone_init_free_lists(struct pglist_
 		bitmap_size = pages_to_bitmap_size(order, size);
 		zone->free_area[order].map =
 		  (unsigned long *) alloc_bootmem_node(pgdat, bitmap_size);
+		zone->free_area[order].nr_free = 0;
 	}
 }
 
@@ -1647,8 +1649,7 @@ static void frag_stop(struct seq_file *m
 }
 
 /* 
- * This walks the freelist for each zone. Whilst this is slow, I'd rather 
- * be slow here than slow down the fast path by keeping stats - mjbligh
+ * This walks the free areas for each zone.
  */
 static int frag_show(struct seq_file *m, void *arg)
 {
@@ -1664,14 +1665,8 @@ static int frag_show(struct seq_file *m,
 
 		spin_lock_irqsave(&zone->lock, flags);
 		seq_printf(m, "Node %d, zone %8s ", pgdat->node_id, zone->name);
-		for (order = 0; order < MAX_ORDER; ++order) {
-			unsigned long nr_bufs = 0;
-			struct list_head *elem;
-
-			list_for_each(elem, &(zone->free_area[order].free_list))
-				++nr_bufs;
-			seq_printf(m, "%6lu ", nr_bufs);
-		}
+		for (order = 0; order < MAX_ORDER; ++order)
+			seq_printf(m, "%6lu ", zone->free_area[order].nr_free);
 		spin_unlock_irqrestore(&zone->lock, flags);
 		seq_putc(m, '\n');
 	}
diff -puN include/linux/mmzone.h~vm-free-order-pages include/linux/mmzone.h
--- linux-2.6/include/linux/mmzone.h~vm-free-order-pages	2004-10-27 14:27:31.000000000 +1000
+++ linux-2.6-npiggin/include/linux/mmzone.h	2004-10-27 16:41:28.000000000 +1000
@@ -23,6 +23,7 @@
 struct free_area {
 	struct list_head	free_list;
 	unsigned long		*map;
+	unsigned long		nr_free;
 };
 
 struct pglist_data;

_

--------------050506080709000501080509--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
