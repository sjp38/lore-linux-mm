From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20051021095723.14409.44846.sendpatchset@skynet.csn.ul.ie>
In-Reply-To: <20051021095658.14409.26527.sendpatchset@skynet.csn.ul.ie>
References: <20051021095658.14409.26527.sendpatchset@skynet.csn.ul.ie>
Subject: [PATCH 5/8] Fragmentation Avoidance V18: 005_fallback
Date: Fri, 21 Oct 2005 10:57:24 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, lhms-devel@lists.sourceforge.net
Cc: Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

This patch implements fallback logic. In the event there is no 2^(MAX_ORDER-1)
blocks of pages left, this will help the system decide what list to use. The
highlights of the patch are;

o Define a RCLM_FALLBACK type for fallbacks
o Use a percentage of each zone for fallbacks. When a reserved pool of pages
  is depleted, it will try and use RCLM_FALLBACK before using anything else.
  This greatly reduces the amount of fallbacks causing fragmentation without
  needing complex balancing algorithms
o Add a fallback_reserve that records how much of the zone is currently used
  for allocations falling back to RCLM_FALLBACK
o Adds a fallback_allocs[] array that determines the order of freelists are
  used for each allocation type

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Mike Kravetz <kravetz@us.ibm.com>
Signed-off-by: Joel Schopp <jschopp@austin.ibm.com>
diff -rup -X /usr/src/patchset-0.5/bin//dontdiff linux-2.6.14-rc4-mm1-004_markfree/include/linux/mmzone.h linux-2.6.14-rc4-mm1-005_fallback/include/linux/mmzone.h
--- linux-2.6.14-rc4-mm1-004_markfree/include/linux/mmzone.h	2005-10-19 22:10:51.000000000 +0100
+++ linux-2.6.14-rc4-mm1-005_fallback/include/linux/mmzone.h	2005-10-19 22:12:22.000000000 +0100
@@ -30,7 +30,8 @@
 #define RCLM_NORCLM   0
 #define RCLM_EASY     1
 #define RCLM_KERN     2
-#define RCLM_TYPES    3
+#define RCLM_FALLBACK 3
+#define RCLM_TYPES    4
 #define BITS_PER_RCLM_TYPE 2
 
 #define for_each_rclmtype_order(type, order) \
@@ -170,6 +171,9 @@ struct zone {
 
 	struct free_area	free_area_lists[RCLM_TYPES][MAX_ORDER];
 
+	/* Number of pages currently used for RCLM_FALLBACK */
+	unsigned long		fallback_reserve;
+
 	ZONE_PADDING(_pad1_)
 
 	/* Fields commonly accessed by the page reclaim scanner */
@@ -292,6 +296,17 @@ struct zonelist {
 	struct zone *zones[MAX_NUMNODES * MAX_NR_ZONES + 1]; // NULL delimited
 };
 
+static inline void inc_reserve_count(struct zone *zone, int type)
+{
+	if (type == RCLM_FALLBACK)
+		zone->fallback_reserve += PAGES_PER_MAXORDER;
+}
+
+static inline void dec_reserve_count(struct zone *zone, int type)
+{
+	if (type == RCLM_FALLBACK && zone->fallback_reserve)
+		zone->fallback_reserve -= PAGES_PER_MAXORDER;
+}
 
 /*
  * The pg_data_t structure is used in machines with CONFIG_DISCONTIGMEM
diff -rup -X /usr/src/patchset-0.5/bin//dontdiff linux-2.6.14-rc4-mm1-004_markfree/mm/page_alloc.c linux-2.6.14-rc4-mm1-005_fallback/mm/page_alloc.c
--- linux-2.6.14-rc4-mm1-004_markfree/mm/page_alloc.c	2005-10-19 22:11:37.000000000 +0100
+++ linux-2.6.14-rc4-mm1-005_fallback/mm/page_alloc.c	2005-10-19 22:12:22.000000000 +0100
@@ -54,6 +54,22 @@ unsigned long totalhigh_pages __read_mos
 long nr_swap_pages;
 
 /*
+ * fallback_allocs contains the fallback types for low memory conditions
+ * where the preferred alloction type if not available.
+ */
+int fallback_allocs[RCLM_TYPES-1][RCLM_TYPES+1] = {
+	{RCLM_NORCLM,	RCLM_FALLBACK, RCLM_KERN,   RCLM_EASY, RCLM_TYPES},
+	{RCLM_EASY,     RCLM_FALLBACK, RCLM_NORCLM, RCLM_KERN, RCLM_TYPES},
+	{RCLM_KERN,     RCLM_FALLBACK, RCLM_NORCLM, RCLM_EASY, RCLM_TYPES}
+};
+
+/* Returns 1 if the needed percentage of the zone is reserved for fallbacks */
+static inline int min_fallback_reserved(struct zone *zone)
+{
+	return zone->fallback_reserve >= zone->present_pages >> 3;
+}
+
+/*
  * results with 256, 32 in the lowmem_reserve sysctl:
  *	1G machine -> (16M dma, 800M-16M normal, 1G-800M high)
  *	1G machine -> (16M dma, 784M normal, 224M high)
@@ -623,7 +639,12 @@ struct page *steal_maxorder_block(struct
 	page = list_entry(area->free_list.next, struct page, lru);
 	area->nr_free--;
 
+	if (!min_fallback_reserved(zone))
+		alloctype = RCLM_FALLBACK;
+
 	set_pageblock_type(zone, page, alloctype);
+	dec_reserve_count(zone, i);
+	inc_reserve_count(zone, alloctype);
 
 	return page;
 }
@@ -638,6 +659,78 @@ remove_page(struct zone *zone, struct pa
 	return expand(zone, page, order, current_order, area);
 }
 
+/*
+ * If we are falling back, and the allocation is KERNNORCLM,
+ * then reserve any buddies for the KERNNORCLM pool. These
+ * allocations fragment the worst so this helps keep them
+ * in the one place
+ */
+static inline struct free_area *
+fallback_buddy_reserve(int start_alloctype, struct zone *zone,
+			unsigned int current_order, struct page *page,
+			struct free_area *area)
+{
+	if (start_alloctype != RCLM_NORCLM)
+		return area;
+
+	area = &zone->free_area_lists[RCLM_NORCLM][current_order];
+
+	/* Reserve the whole block if this is a large split */
+	if (current_order >= MAX_ORDER / 3) {
+		int reserve_type = RCLM_NORCLM;
+		if (!min_fallback_reserved(zone))
+			reserve_type = RCLM_FALLBACK;
+
+		dec_reserve_count(zone, get_pageblock_type(zone,page));
+		set_pageblock_type(zone, page, reserve_type);
+		inc_reserve_count(zone, reserve_type);
+	}
+	return area;
+}
+
+static struct page *
+fallback_alloc(int alloctype, struct zone *zone, unsigned int order)
+{
+	int *fallback_list;
+	int start_alloctype = alloctype;
+	struct free_area *area;
+	unsigned int current_order;
+	struct page *page;
+	int i;
+
+	/* Ok, pick the fallback order based on the type */
+	BUG_ON(alloctype >= RCLM_TYPES);
+	fallback_list = fallback_allocs[alloctype];
+
+	/*
+	 * Here, the alloc type lists has been depleted as well as the global
+	 * pool, so fallback. When falling back, the largest possible block
+	 * will be taken to keep the fallbacks clustered if possible
+	 */
+	for (i = 0; fallback_list[i] != RCLM_TYPES; i++) {
+		alloctype = fallback_list[i];
+
+		/* Find a block to allocate */
+		area = &zone->free_area_lists[alloctype][MAX_ORDER-1];
+		for (current_order = MAX_ORDER - 1; current_order > order;
+				current_order--, area--) {
+			if (list_empty(&area->free_list))
+				continue;
+
+			page = list_entry(area->free_list.next,
+						struct page, lru);
+			area->nr_free--;
+			area = fallback_buddy_reserve(start_alloctype, zone,
+					current_order, page, area);
+			return remove_page(zone, page, order,
+					current_order, area);
+
+		}
+	}
+
+	return NULL;
+}
+
 /* 
  * Do the hard work of removing an element from the buddy allocator.
  * Call me with the zone->lock already held.
@@ -664,7 +757,8 @@ static struct page *__rmqueue(struct zon
 	if (page != NULL)
 		return remove_page(zone, page, order, MAX_ORDER-1, area);
 
-	return NULL;
+	/* Try falling back */
+	return fallback_alloc(alloctype, zone, order);
 }
 
 /* 
@@ -2277,6 +2371,7 @@ static void __init free_area_init_core(s
 		zone_seqlock_init(zone);
 		zone->zone_pgdat = pgdat;
 		zone->free_pages = 0;
+		zone->fallback_reserve = 0;
 
 		zone->temp_priority = zone->prev_priority = DEF_PRIORITY;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
