Received: from m7.gw.fujitsu.co.jp ([10.0.50.77])
        by fgwmail5.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k1N8wWcE005897 for <linux-mm@kvack.org>; Thu, 23 Feb 2006 17:58:32 +0900
        (envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s5.gw.fujitsu.co.jp by m7.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k1N8wVWg002807 for <linux-mm@kvack.org>; Thu, 23 Feb 2006 17:58:31 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s5.gw.fujitsu.co.jp (s5 [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8AEF61B8057
	for <linux-mm@kvack.org>; Thu, 23 Feb 2006 17:58:31 +0900 (JST)
Received: from fjm506.ms.jp.fujitsu.com (fjm506.ms.jp.fujitsu.com [10.56.99.86])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CA511B8051
	for <linux-mm@kvack.org>; Thu, 23 Feb 2006 17:58:31 +0900 (JST)
Received: from aworks (fjmscan502.ms.jp.fujitsu.com [10.56.99.142])by fjm506.ms.jp.fujitsu.com with SMTP id k1N8wDxe014744
	for <linux-mm@kvack.org>; Thu, 23 Feb 2006 17:58:14 +0900
Date: Thu, 23 Feb 2006 17:58:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] memory-layout-free zones (for review) [2/3]  remvoe
 zone_start_pfn/spanned_pages
Message-Id: <20060223175819.3fbb21fe.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This patch removes zone_start_pfn/zone_spanned_pages from zone struct.
(and also removes seqlock for zone resizing)

By this definion of zone will change
from : a contiguous range of pages to be used in the same manner.
to   : a group of pages to be used in the same manner.

zone will become a pure page_allocator. memory layout is managed by
pgdat.

This change has benefit for memory-hotplug and maybe other works.
We can define a zone which is free from memory layout, like ZONE_EASYRCLM,
ZONE_EMERGENCY(currently maneged by mempool) etc..witout inconsistency.

for_each_page_in_zone() uses zone's memory layout information, but this
patch doesn't include fixes for it. It will be fixed by following patch.


Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: node-hot-add2/include/linux/mmzone.h
===================================================================
--- node-hot-add2.orig/include/linux/mmzone.h
+++ node-hot-add2/include/linux/mmzone.h
@@ -141,10 +141,6 @@ struct zone {
 	 * free areas of different sizes
 	 */
 	spinlock_t		lock;
-#ifdef CONFIG_MEMORY_HOTPLUG
-	/* see spanned/present_pages for more description */
-	seqlock_t		span_seqlock;
-#endif
 	struct free_area	free_area[MAX_ORDER];
 
 
@@ -226,20 +222,7 @@ struct zone {
 	 * Discontig memory support fields.
 	 */
 	struct pglist_data	*zone_pgdat;
-	/* zone_start_pfn == zone_start_paddr >> PAGE_SHIFT */
-	unsigned long		zone_start_pfn;
 
-	/*
-	 * zone_start_pfn, spanned_pages and present_pages are all
-	 * protected by span_seqlock.  It is a seqlock because it has
-	 * to be read outside of zone->lock, and it is done in the main
-	 * allocator path.  But, it is written quite infrequently.
-	 *
-	 * The lock is declared along with zone->lock because it is
-	 * frequently read in proximity to zone->lock.  It's good to
-	 * give them a chance of being in the same cacheline.
-	 */
-	unsigned long		spanned_pages;	/* total size, including holes */
 	unsigned long		present_pages;	/* amount of memory (excluding holes) */
 
 	/*
Index: node-hot-add2/arch/powerpc/mm/mem.c
===================================================================
--- node-hot-add2.orig/arch/powerpc/mm/mem.c
+++ node-hot-add2/arch/powerpc/mm/mem.c
@@ -143,7 +143,7 @@ int __devinit add_memory(u64 start, u64 
 int __devinit remove_memory(u64 start, u64 size)
 {
 	struct zone *zone;
-	unsigned long start_pfn, end_pfn, nr_pages;
+	unsigned long offset, start_pfn, end_pfn, nr_pages;
 
 	start_pfn = start >> PAGE_SHIFT;
 	nr_pages = size >> PAGE_SHIFT;
@@ -163,8 +163,9 @@ int __devinit remove_memory(u64 start, u
 	 * not handling removing memory ranges that
 	 * overlap multiple zones yet
 	 */
-	if (end_pfn > (zone->zone_start_pfn + zone->spanned_pages))
-		goto overlap;
+	for (offset = 0; offset < nr_pages; offset++)
+		if (page_zone(pfn_to_page(start_pfn + offset)) != zone)
+			goto overlap;
 
 	/* make sure it is NOT in RMO */
 	if ((start < lmb.rmo_size) || ((start+size) < lmb.rmo_size)) {
Index: node-hot-add2/mm/page_alloc.c
===================================================================
--- node-hot-add2.orig/mm/page_alloc.c
+++ node-hot-add2/mm/page_alloc.c
@@ -85,23 +85,6 @@ unsigned long __initdata nr_kernel_pages
 unsigned long __initdata nr_all_pages;
 
 #ifdef CONFIG_DEBUG_VM
-static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
-{
-	int ret = 0;
-	unsigned seq;
-	unsigned long pfn = page_to_pfn(page);
-
-	do {
-		seq = zone_span_seqbegin(zone);
-		if (pfn >= zone->zone_start_pfn + zone->spanned_pages)
-			ret = 1;
-		else if (pfn < zone->zone_start_pfn)
-			ret = 1;
-	} while (zone_span_seqretry(zone, seq));
-
-	return ret;
-}
-
 static int page_is_consistent(struct zone *zone, struct page *page)
 {
 #ifdef CONFIG_HOLES_IN_ZONE
@@ -118,8 +101,6 @@ static int page_is_consistent(struct zon
  */
 static int bad_range(struct zone *zone, struct page *page)
 {
-	if (page_outside_zone_boundaries(zone, page))
-		return 1;
 	if (!page_is_consistent(zone, page))
 		return 1;
 
@@ -675,7 +656,7 @@ void mark_free_pages(struct zone *zone)
 	int order;
 	struct list_head *curr;
 
-	if (!zone->spanned_pages)
+	if (populated_zone(zone))
 		return;
 
 	spin_lock_irqsave(&zone->lock, flags);
@@ -2117,11 +2098,9 @@ static __meminit void init_currently_emp
 	zone_wait_table_init(zone, size);
 	pgdat->nr_zones = zone_idx(zone) + 1;
 
-	zone->zone_start_pfn = zone_start_pfn;
-
 	memmap_init(size, pgdat->node_id, zone_idx(zone), zone_start_pfn);
 
-	zone_init_free_lists(pgdat, zone, zone->spanned_pages);
+	zone_init_free_lists(pgdat, zone, size);
 }
 
 /*
@@ -2154,12 +2133,10 @@ static void __init free_area_init_core(s
 			nr_kernel_pages += realsize;
 		nr_all_pages += realsize;
 
-		zone->spanned_pages = size;
 		zone->present_pages = realsize;
 		zone->name = zone_names[j];
 		spin_lock_init(&zone->lock);
 		spin_lock_init(&zone->lru_lock);
-		zone_seqlock_init(zone);
 		zone->zone_pgdat = pgdat;
 		zone->free_pages = 0;
 
@@ -2322,7 +2299,6 @@ static int zoneinfo_show(struct seq_file
 			   "\n        active   %lu"
 			   "\n        inactive %lu"
 			   "\n        scanned  %lu (a: %lu i: %lu)"
-			   "\n        spanned  %lu"
 			   "\n        present  %lu",
 			   zone->free_pages,
 			   zone->pages_min,
@@ -2332,7 +2308,6 @@ static int zoneinfo_show(struct seq_file
 			   zone->nr_inactive,
 			   zone->pages_scanned,
 			   zone->nr_scan_active, zone->nr_scan_inactive,
-			   zone->spanned_pages,
 			   zone->present_pages);
 		seq_printf(m,
 			   "\n        protection: (%lu",
@@ -2384,11 +2359,9 @@ static int zoneinfo_show(struct seq_file
 			   "\n  all_unreclaimable: %u"
 			   "\n  prev_priority:     %i"
 			   "\n  temp_priority:     %i"
-			   "\n  start_pfn:         %lu",
 			   zone->all_unreclaimable,
 			   zone->prev_priority,
-			   zone->temp_priority,
-			   zone->zone_start_pfn);
+			   zone->temp_priority);
 		spin_unlock_irqrestore(&zone->lock, flags);
 		seq_putc(m, '\n');
 	}
Index: node-hot-add2/mm/memory_hotplug.c
===================================================================
--- node-hot-add2.orig/mm/memory_hotplug.c
+++ node-hot-add2/mm/memory_hotplug.c
@@ -76,22 +76,6 @@ int __add_pages(struct zone *zone, unsig
 	return err;
 }
 
-static void grow_zone_span(struct zone *zone,
-		unsigned long start_pfn, unsigned long end_pfn)
-{
-	unsigned long old_zone_end_pfn;
-
-	zone_span_writelock(zone);
-
-	old_zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
-	if (start_pfn < zone->zone_start_pfn)
-		zone->zone_start_pfn = start_pfn;
-
-	if (end_pfn > old_zone_end_pfn)
-		zone->spanned_pages = end_pfn - zone->zone_start_pfn;
-
-	zone_span_writeunlock(zone);
-}
 
 static void grow_pgdat_span(struct pglist_data *pgdat,
 		unsigned long start_pfn, unsigned long end_pfn)
@@ -120,7 +104,6 @@ int online_pages(unsigned long pfn, unsi
 	 */
 	zone = page_zone(pfn_to_page(pfn));
 	pgdat_resize_lock(zone->zone_pgdat, &flags);
-	grow_zone_span(zone, pfn, pfn + nr_pages);
 	grow_pgdat_span(zone->zone_pgdat, pfn, pfn + nr_pages);
 	pgdat_resize_unlock(zone->zone_pgdat, &flags);
 
Index: node-hot-add2/include/linux/memory_hotplug.h
===================================================================
--- node-hot-add2.orig/include/linux/memory_hotplug.h
+++ node-hot-add2/include/linux/memory_hotplug.h
@@ -25,29 +25,6 @@ void pgdat_resize_init(struct pglist_dat
 {
 	spin_lock_init(&pgdat->node_size_lock);
 }
-/*
- * Zone resizing functions
- */
-static inline unsigned zone_span_seqbegin(struct zone *zone)
-{
-	return read_seqbegin(&zone->span_seqlock);
-}
-static inline int zone_span_seqretry(struct zone *zone, unsigned iv)
-{
-	return read_seqretry(&zone->span_seqlock, iv);
-}
-static inline void zone_span_writelock(struct zone *zone)
-{
-	write_seqlock(&zone->span_seqlock);
-}
-static inline void zone_span_writeunlock(struct zone *zone)
-{
-	write_sequnlock(&zone->span_seqlock);
-}
-static inline void zone_seqlock_init(struct zone *zone)
-{
-	seqlock_init(&zone->span_seqlock);
-}
 extern int zone_grow_free_lists(struct zone *zone, unsigned long new_nr_pages);
 extern int zone_grow_waitqueues(struct zone *zone, unsigned long nr_pages);
 extern int add_one_highpage(struct page *page, int pfn, int bad_ppro);
@@ -69,17 +46,6 @@ static inline void pgdat_resize_lock(str
 static inline void pgdat_resize_unlock(struct pglist_data *p, unsigned long *f) {}
 static inline void pgdat_resize_init(struct pglist_data *pgdat) {}
 
-static inline unsigned zone_span_seqbegin(struct zone *zone)
-{
-	return 0;
-}
-static inline int zone_span_seqretry(struct zone *zone, unsigned iv)
-{
-	return 0;
-}
-static inline void zone_span_writelock(struct zone *zone) {}
-static inline void zone_span_writeunlock(struct zone *zone) {}
-static inline void zone_seqlock_init(struct zone *zone) {}
 
 static inline int mhp_notimplemented(const char *func)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
