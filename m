Date: Mon, 22 Jul 2002 11:40:48 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: alloc_pages_bulk
Message-ID: <1615040000.1027363248@flay>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Bill Irwin <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Below is a first cut at a bulk page allocator. This has no testing whatsoever,
not even being compiled ... I just want to get some feedback on the approach,
so if I get slapped, I'm less far down the path that I have to back out of.
The __alloc_pages cleanup is also tacked on the end because I'm lazy at
creating diff trees - sorry ;-)

Comments, opinions, abuse?

M.

diff -urN virgin-2.5.25/include/linux/gfp.h 2.5.25-A04-alloc_pages_bulk/include/linux/gfp.h
--- virgin-2.5.25/include/linux/gfp.h	Fri Jul  5 16:42:19 2002
+++ 2.5.25-A04-alloc_pages_bulk/include/linux/gfp.h	Mon Jul 22 11:27:49 2002
@@ -45,12 +45,23 @@
 
 static inline struct page * alloc_pages(unsigned int gfp_mask, unsigned int order)
 {
+	struct page *page;
 	/*
 	 * Gets optimized away by the compiler.
 	 */
 	if (order >= MAX_ORDER)
 		return NULL;
-	return _alloc_pages(gfp_mask, order);
+	return _alloc_pages(gfp_mask, order, 1, &page);
+}
+
+static inline struct page * alloc_pages_bulk(unsigned int gfp_mask, unsigned int order, unsigned long count, struct page **pages)
+{
+	/*
+	 * Gets optimized away by the compiler.
+	 */
+	if (order >= MAX_ORDER)
+		return NULL;
+	return _alloc_pages(gfp_mask, order, count, pages);
 }
 
 #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
diff -urN virgin-2.5.25/mm/numa.c 2.5.25-A04-alloc_pages_bulk/mm/numa.c
--- virgin-2.5.25/mm/numa.c	Fri Jul  5 16:42:20 2002
+++ 2.5.25-A04-alloc_pages_bulk/mm/numa.c	Mon Jul 22 11:14:53 2002
@@ -31,32 +31,29 @@
 
 #endif /* !CONFIG_DISCONTIGMEM */
 
-struct page * alloc_pages_node(int nid, unsigned int gfp_mask, unsigned int order)
+struct page * alloc_pages_node(int nid, unsigned int gfp_mask, 
+		unsigned int order)
 {
-#ifdef CONFIG_NUMA
-	return __alloc_pages(gfp_mask, order, NODE_DATA(nid)->node_zonelists + (gfp_mask & GFP_ZONEMASK));
-#else
-	return alloc_pages(gfp_mask, order);
-#endif
+	struct page *page;
+
+	return __alloc_pages(gfp_mask, order, 
+		NODE_DATA(nid)->node_zonelists + (gfp_mask & GFP_ZONEMASK)
+		1, &page);
 }
 
 #ifdef CONFIG_DISCONTIGMEM
 
 #define LONG_ALIGN(x) (((x)+(sizeof(long))-1)&~((sizeof(long))-1))
 
-static spinlock_t node_lock = SPIN_LOCK_UNLOCKED;
-
 void show_free_areas_node(pg_data_t *pgdat)
 {
 	unsigned long flags;
 
-	spin_lock_irqsave(&node_lock, flags);
 	show_free_areas_core(pgdat);
-	spin_unlock_irqrestore(&node_lock, flags);
 }
 
 /*
- * Nodes can be initialized parallely, in no particular order.
+ * Nodes can be initialized in parallel, in no particular order.
  */
 void __init free_area_init_node(int nid, pg_data_t *pgdat, struct page *pmap,
 	unsigned long *zones_size, unsigned long zone_start_paddr, 
@@ -82,49 +79,69 @@
 	memset(pgdat->valid_addr_bitmap, 0, size);
 }
 
-static struct page * alloc_pages_pgdat(pg_data_t *pgdat, unsigned int gfp_mask,
-	unsigned int order)
+/* 
+ * Walk the global list of pg_data_t's starting at specified start point 
+ */
+static inline unsigned long _alloc_pages_pgdat_walk(pg_data_t *start,
+		unsigned int gfp_mask, unsigned int order, 
+		unsigned long count, struct page **pages)
 {
-	return __alloc_pages(gfp_mask, order, pgdat->node_zonelists + (gfp_mask & GFP_ZONEMASK));
+	unsigned long page_count = 0;
+	pg_data_t *pgdat = start;
+	
+	/* walk the second part of the list from start to the list tail */
+	for (pgdat = start; pgdat != NULL; pgdat = pgdat->node_next) {
+		if ((page_count = __alloc_pages(pgdat, gfp_mask, order, 
+						pgdat->node_zonelists + 
+						(gfp_mask & GFP_ZONEMASK)
+						count, pages)))
+			return(page_count);
+	}
+	/* walk the first part of the list from the list head to start */
+	for (pgdat = pgdat_list; pgdat != start; pgdat = pgdat->node_next) {
+		if ((page_count = __alloc_pages(pgdat, gfp_mask, order, 
+						pgdat->node_zonelists + 
+						(gfp_mask & GFP_ZONEMASK)
+						count, pages)))
+			return(page_count);
+	}
+	return(0);
 }
 
+#ifdef CONFIG_NUMA
+
 /*
  * This can be refined. Currently, tries to do round robin, instead
  * should do concentratic circle search, starting from current node.
  */
-struct page * _alloc_pages(unsigned int gfp_mask, unsigned int order)
+unsigned long _alloc_pages(unsigned int gfp_mask, unsigned int order,
+		unsigned long count, struct page **pages)
+{
+	/* start at the current node, then do round robin */	
+	return _alloc_pages_pgdat_walk(NODE_DATA(numa_node_id()), 
+		gfp_mask, order, count, pages);
+}
+
+#else /* !CONFIG_NUMA */
+
+unsigned long _alloc_pages(unsigned int gfp_mask, unsigned int order,
+		unsigned long count, struct page **pages)
 {
-	struct page *ret = 0;
-	pg_data_t *start, *temp;
-#ifndef CONFIG_NUMA
 	unsigned long flags;
 	static pg_data_t *next = 0;
-#endif
+	pgdat_t *temp;
 
-	if (order >= MAX_ORDER)
-		return NULL;
-#ifdef CONFIG_NUMA
-	temp = NODE_DATA(numa_node_id());
-#else
-	spin_lock_irqsave(&node_lock, flags);
+	/* 
+	 * As the next ptr is static, it saves position between calls
+	 * and we round robin between memory segments to balance pressure
+	 */
 	if (!next) next = pgdat_list;
 	temp = next;
 	next = next->node_next;
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
+
+	return _alloc_pages_pgdat_walk(temp, gfp_mask, order, count, pages);
 }
+
+#endif /* CONFIG_NUMA */
 
 #endif /* CONFIG_DISCONTIGMEM */
diff -urN virgin-2.5.25/mm/page_alloc.c 2.5.25-A04-alloc_pages_bulk/mm/page_alloc.c
--- virgin-2.5.25/mm/page_alloc.c	Fri Jul  5 16:42:03 2002
+++ 2.5.25-A04-alloc_pages_bulk/mm/page_alloc.c	Mon Jul 22 11:15:00 2002
@@ -187,16 +187,13 @@
 	set_page_count(page, 1);
 }
 
-static FASTCALL(struct page * rmqueue(zone_t *zone, unsigned int order));
-static struct page * rmqueue(zone_t *zone, unsigned int order)
+static inline struct page * __rmqueue(zone_t *zone, unsigned int order)
 {
 	free_area_t * area = zone->free_area + order;
 	unsigned int curr_order = order;
 	struct list_head *head, *curr;
-	unsigned long flags;
 	struct page *page;
 
-	spin_lock_irqsave(&zone->lock, flags);
 	do {
 		head = &area->free_list;
 		curr = head->next;
@@ -213,21 +210,40 @@
 			zone->free_pages -= 1UL << order;
 
 			page = expand(zone, page, index, order, curr_order, area);
-			spin_unlock_irqrestore(&zone->lock, flags);
-
-			if (bad_range(zone, page))
-				BUG();
-			prep_new_page(page);
 			return page;	
 		}
 		curr_order++;
 		area++;
 	} while (curr_order < MAX_ORDER);
-	spin_unlock_irqrestore(&zone->lock, flags);
 
 	return NULL;
 }
 
+static FASTCALL(unsigned long rmqueue(zone_t *zone, unsigned int order, 
+			unsigned long count, struct page *pages[]));
+static unsigned long rmqueue(zone_t *zone, unsigned int order, 
+		unsigned long count, struct page **pages)
+{
+	unsigned long flags;
+	int i, allocated = 0;
+
+	spin_lock_irqsave(&zone->lock, flags);
+	for (i = 0; i < count; ++i) {
+		pages[i] = __rmqueue(zone, order);
+		if (pages[i] == NULL)
+			break;
+		++allocated;
+	}
+	spin_unlock_irqrestore(&zone->lock, flags);
+	
+	for (i = 0; i < allocated; ++i) {
+		if (bad_range(zone, pages[i]))
+			BUG();
+		prep_new_page(pages[i]);
+	}
+	return allocated;	
+}
+
 #ifdef CONFIG_SOFTWARE_SUSPEND
 int is_head_of_free_region(struct page *page)
 {
@@ -253,10 +269,12 @@
 #endif /* CONFIG_SOFTWARE_SUSPEND */
 
 #ifndef CONFIG_DISCONTIGMEM
-struct page *_alloc_pages(unsigned int gfp_mask, unsigned int order)
+unsigned long _alloc_pages(unsigned int gfp_mask, unsigned int order,
+		unsigned long count, struct page **pages)
 {
 	return __alloc_pages(gfp_mask, order,
-		contig_page_data.node_zonelists+(gfp_mask & GFP_ZONEMASK));
+		contig_page_data.node_zonelists+(gfp_mask & GFP_ZONEMASK)
+		count, pages);
 }
 #endif
 
@@ -316,26 +334,27 @@
 /*
  * This is the 'heart' of the zoned buddy allocator:
  */
-struct page * __alloc_pages(unsigned int gfp_mask, unsigned int order, zonelist_t *zonelist)
+unsigned long __alloc_pages(unsigned int gfp_mask, unsigned int order, zonelist_t *zonelist, unsigned long count, struct page **pages)
 {
 	unsigned long min;
-	zone_t **zone, * classzone;
+	zone_t **zones, * classzone;
 	struct page * page;
-	int freed;
+	int freed, i;
 
-	zone = zonelist->zones;
-	classzone = *zone;
-	if (classzone == NULL)
+	zones = zonelist->zones;  /* the list of zones suitable for gfp_mask */
+	classzone = zones[0]; 
+	if (classzone == NULL)    /* no zones in the zonelist */
 		return NULL;
-	min = 1UL << order;
-	for (;;) {
-		zone_t *z = *(zone++);
-		if (!z)
-			break;
 
+	/* Go through the zonelist once, looking for a zone with enough free */
+	min = count << order;
+	for (i = 0; zones[i] != NULL; i++) {
+		zone_t *z = *zones[i];
+
+		/* the incremental min is allegedly to discourage fallback */
 		min += z->pages_low;
 		if (z->free_pages > min) {
-			page = rmqueue(z, order);
+			page = rmqueue(z, order, count, pages);
 			if (page)
 				return page;
 		}
@@ -343,23 +362,22 @@
 
 	classzone->need_balance = 1;
 	mb();
+	/* we're somewhat low on memory, failed to find what we needed */
 	if (waitqueue_active(&kswapd_wait))
 		wake_up_interruptible(&kswapd_wait);
 
-	zone = zonelist->zones;
-	min = 1UL << order;
-	for (;;) {
+	/* Go through the zonelist again, taking __GFP_HIGH into account */
+	min = count << order;
+	for (i = 0; zones[i] != NULL; i++) {
 		unsigned long local_min;
-		zone_t *z = *(zone++);
-		if (!z)
-			break;
+		zone_t *z = *zones[i];
 
 		local_min = z->pages_min;
 		if (gfp_mask & __GFP_HIGH)
 			local_min >>= 2;
 		min += local_min;
 		if (z->free_pages > min) {
-			page = rmqueue(z, order);
+			page = rmqueue(z, order, count, pages);
 			if (page)
 				return page;
 		}
@@ -369,13 +387,11 @@
 
 rebalance:
 	if (current->flags & (PF_MEMALLOC | PF_MEMDIE)) {
-		zone = zonelist->zones;
-		for (;;) {
-			zone_t *z = *(zone++);
-			if (!z)
-				break;
+		/* go through the zonelist yet again, ignoring mins */
+		for (i = 0; zones[i] != NULL; i++) {
+			zone_t *z = *zones[i];
 
-			page = rmqueue(z, order);
+			page = rmqueue(z, order, count, pages);
 			if (page)
 				return page;
 		}
@@ -396,16 +412,14 @@
 	if (page)
 		return page;
 
-	zone = zonelist->zones;
-	min = 1UL << order;
-	for (;;) {
-		zone_t *z = *(zone++);
-		if (!z)
-			break;
+	/* go through the zonelist yet one more time */
+	min = count << order;
+	for (i = 0; zones[i] != NULL; i++) {
+		zone_t *z = *zones[i];
 
 		min += z->pages_min;
 		if (z->free_pages > min) {
-			page = rmqueue(z, order);
+			page = rmqueue(z, order, count, pages);
 			if (page)
 				return page;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
