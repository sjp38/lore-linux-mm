Message-ID: <417F5623.4040005@yahoo.com.au>
Date: Wed, 27 Oct 2004 18:02:43 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH 3/3] teach kswapd about higher order areas
References: <417F5584.2070400@yahoo.com.au> <417F55B9.7090306@yahoo.com.au> <417F5604.3000908@yahoo.com.au>
In-Reply-To: <417F5604.3000908@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------070406050504000607010708"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070406050504000607010708
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

3/3

--------------070406050504000607010708
Content-Type: text/x-patch;
 name="vm-kswapd-heed-order-watermarks.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vm-kswapd-heed-order-watermarks.patch"



Teach kswapd to free memory on behalf of higher order allocators. This could
be important for higher order atomic allocations because they otherwise have
no means to free the memory themselves.

Signed-off-by: Nick Piggin <nickpiggin@yahoo.com.au>


---

 linux-2.6-npiggin/include/linux/mmzone.h |    5 +--
 linux-2.6-npiggin/mm/page_alloc.c        |    3 +
 linux-2.6-npiggin/mm/vmscan.c            |   48 ++++++++++++++++++-------------
 3 files changed, 34 insertions(+), 22 deletions(-)

diff -puN mm/vmscan.c~vm-kswapd-heed-order-watermarks mm/vmscan.c
--- linux-2.6/mm/vmscan.c~vm-kswapd-heed-order-watermarks	2004-10-27 17:57:28.000000000 +1000
+++ linux-2.6-npiggin/mm/vmscan.c	2004-10-27 17:57:28.000000000 +1000
@@ -851,9 +851,6 @@ shrink_caches(struct zone **zones, struc
 	for (i = 0; zones[i] != NULL; i++) {
 		struct zone *zone = zones[i];
 
-		if (zone->present_pages == 0)
-			continue;
-
 		zone->temp_priority = sc->priority;
 		if (zone->prev_priority > sc->priority)
 			zone->prev_priority = sc->priority;
@@ -968,7 +965,7 @@ out:
  * the page allocator fallback scheme to ensure that aging of pages is balanced
  * across the zones.
  */
-static int balance_pgdat(pg_data_t *pgdat, int nr_pages)
+static int balance_pgdat(pg_data_t *pgdat, int nr_pages, int order)
 {
 	int to_free = nr_pages;
 	int all_zones_ok;
@@ -1007,14 +1004,12 @@ loop_again:
 			for (i = pgdat->nr_zones - 1; i >= 0; i--) {
 				struct zone *zone = pgdat->node_zones + i;
 
-				if (zone->present_pages == 0)
-					continue;
-
 				if (zone->all_unreclaimable &&
 						priority != DEF_PRIORITY)
 					continue;
 
-				if (zone->free_pages <= zone->pages_high) {
+				if (!zone_watermark_ok(zone, order,
+						zone->pages_high, 0, 0, 0)) {
 					end_zone = i;
 					goto scan;
 				}
@@ -1042,14 +1037,12 @@ scan:
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
 
-			if (zone->present_pages == 0)
-				continue;
-
 			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
 				continue;
 
 			if (nr_pages == 0) {	/* Not software suspend */
-				if (zone->free_pages <= zone->pages_high)
+				if (!zone_watermark_ok(zone, order,
+						zone->pages_high, end_zone, 0, 0))
 					all_zones_ok = 0;
 			}
 			zone->temp_priority = priority;
@@ -1126,6 +1119,7 @@ out:
  */
 static int kswapd(void *p)
 {
+	unsigned long order;
 	pg_data_t *pgdat = (pg_data_t*)p;
 	struct task_struct *tsk = current;
 	DEFINE_WAIT(wait);
@@ -1154,14 +1148,28 @@ static int kswapd(void *p)
 	 */
 	tsk->flags |= PF_MEMALLOC|PF_KSWAPD;
 
+	order = 0;
 	for ( ; ; ) {
+		unsigned long new_order;
 		if (current->flags & PF_FREEZE)
 			refrigerator(PF_FREEZE);
+
 		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
-		schedule();
+		new_order = pgdat->kswapd_max_order;
+		pgdat->kswapd_max_order = 0;
+		if (order < new_order) {
+			/*
+			 * Don't sleep if someone wants a larger 'order'
+			 * allocation
+			 */
+			order = new_order;
+		} else {
+			schedule();
+			order = pgdat->kswapd_max_order;
+		}
 		finish_wait(&pgdat->kswapd_wait, &wait);
 
-		balance_pgdat(pgdat, 0);
+		balance_pgdat(pgdat, 0, order);
 	}
 	return 0;
 }
@@ -1169,12 +1177,14 @@ static int kswapd(void *p)
 /*
  * A zone is low on free memory, so wake its kswapd task to service it.
  */
-void wakeup_kswapd(struct zone *zone)
+void wakeup_kswapd(struct zone *zone, int order)
 {
-	if (zone->present_pages == 0)
-		return;
-	if (zone->free_pages > zone->pages_low)
+	pg_data_t *pgdat = zone->zone_pgdat;
+
+	if (zone_watermark_ok(zone, order, zone->pages_low, 0, 0, 0))
 		return;
+	if (pgdat->kswapd_max_order < order)
+		pgdat->kswapd_max_order = order;
 	if (!waitqueue_active(&zone->zone_pgdat->kswapd_wait))
 		return;
 	wake_up_interruptible(&zone->zone_pgdat->kswapd_wait);
@@ -1197,7 +1207,7 @@ int shrink_all_memory(int nr_pages)
 	current->reclaim_state = &reclaim_state;
 	for_each_pgdat(pgdat) {
 		int freed;
-		freed = balance_pgdat(pgdat, nr_to_free);
+		freed = balance_pgdat(pgdat, nr_to_free, 0);
 		ret += freed;
 		nr_to_free -= freed;
 		if (nr_to_free <= 0)
diff -puN mm/page_alloc.c~vm-kswapd-heed-order-watermarks mm/page_alloc.c
--- linux-2.6/mm/page_alloc.c~vm-kswapd-heed-order-watermarks	2004-10-27 17:57:28.000000000 +1000
+++ linux-2.6-npiggin/mm/page_alloc.c	2004-10-27 17:57:28.000000000 +1000
@@ -677,7 +677,7 @@ __alloc_pages(unsigned int gfp_mask, uns
 	}
 
 	for (i = 0; (z = zones[i]) != NULL; i++)
-		wakeup_kswapd(z);
+		wakeup_kswapd(z, order);
 
 	/*
 	 * Go through the zonelist again. Let __GFP_HIGH and allocations
@@ -1506,6 +1506,7 @@ static void __init free_area_init_core(s
 
 	pgdat->nr_zones = 0;
 	init_waitqueue_head(&pgdat->kswapd_wait);
+	pgdat->kswapd_max_order = 0;
 	
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		struct zone *zone = pgdat->node_zones + j;
diff -puN include/linux/mmzone.h~vm-kswapd-heed-order-watermarks include/linux/mmzone.h
--- linux-2.6/include/linux/mmzone.h~vm-kswapd-heed-order-watermarks	2004-10-27 17:57:28.000000000 +1000
+++ linux-2.6-npiggin/include/linux/mmzone.h	2004-10-27 17:57:28.000000000 +1000
@@ -263,8 +263,9 @@ typedef struct pglist_data {
 					     range, including holes */
 	int node_id;
 	struct pglist_data *pgdat_next;
-	wait_queue_head_t       kswapd_wait;
+	wait_queue_head_t kswapd_wait;
 	struct task_struct *kswapd;
+	int kswapd_max_order;
 } pg_data_t;
 
 #define node_present_pages(nid)	(NODE_DATA(nid)->node_present_pages)
@@ -278,7 +279,7 @@ void __get_zone_counts(unsigned long *ac
 void get_zone_counts(unsigned long *active, unsigned long *inactive,
 			unsigned long *free);
 void build_all_zonelists(void);
-void wakeup_kswapd(struct zone *zone);
+void wakeup_kswapd(struct zone *zone, int order);
 int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 		int alloc_type, int can_try_harder, int gfp_high);
 

_

--------------070406050504000607010708--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
