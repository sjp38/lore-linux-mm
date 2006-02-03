Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
        by fgwmail6.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k137u6Qu023980 for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:56:06 +0900
        (envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s4.gw.fujitsu.co.jp by m1.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k137u5tL023921 for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:56:05 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s4.gw.fujitsu.co.jp (s4 [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C308B1CC00F
	for <linux-mm@kvack.org>; Fri,  3 Feb 2006 16:56:04 +0900 (JST)
Received: from fjm502.ms.jp.fujitsu.com (fjm502.ms.jp.fujitsu.com [10.56.99.74])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D5A571CC14D
	for <linux-mm@kvack.org>; Fri,  3 Feb 2006 16:56:03 +0900 (JST)
Received: from [127.0.0.1] (fjmscan502.ms.jp.fujitsu.com [10.56.99.142])by fjm502.ms.jp.fujitsu.com with ESMTP id k137tEe3008187
	for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:55:15 +0900
Message-ID: <43E30C9E.7010401@jp.fujitsu.com>
Date: Fri, 03 Feb 2006 16:56:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC] peeling off zone from physical memory layout [10/10] memory_hotplug
 fix
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Now, zone resizing is needless.
This patch removes zone_start_pfn, spanned_pages from memory hotplug code.
And zone resizing code is removed too.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitu.com>


Index: hogehoge/include/linux/mmzone.h
===================================================================
--- hogehoge.orig/include/linux/mmzone.h
+++ hogehoge/include/linux/mmzone.h
@@ -28,6 +28,7 @@ struct free_area {
  };

  struct pglist_data;
+struct page;

  /*
   * zone->lock and zone->lru_lock are two of the hottest locks in the kernel.
@@ -129,10 +130,7 @@ struct zone {
  	 * free areas of different sizes
  	 */
  	spinlock_t		lock;
-#ifdef CONFIG_MEMORY_HOTPLUG
-	/* see spanned/present_pages for more description */
-	seqlock_t		span_seqlock;
-#endif
+
  	struct free_area	free_area[MAX_ORDER];


Index: hogehoge/include/linux/memory_hotplug.h
===================================================================
--- hogehoge.orig/include/linux/memory_hotplug.h
+++ hogehoge/include/linux/memory_hotplug.h
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
Index: hogehoge/mm/memory_hotplug.c
===================================================================
--- hogehoge.orig/mm/memory_hotplug.c
+++ hogehoge/mm/memory_hotplug.c
@@ -21,6 +21,7 @@
  #include <linux/memory_hotplug.h>
  #include <linux/highmem.h>
  #include <linux/vmalloc.h>
+#include <linux/memorymap.h>

  #include <asm/tlbflush.h>

@@ -76,23 +77,6 @@ int __add_pages(struct zone *zone, unsig
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
-
  static void grow_pgdat_span(struct pglist_data *pgdat,
  		unsigned long start_pfn, unsigned long end_pfn)
  {
@@ -118,11 +102,12 @@ int online_pages(unsigned long pfn, unsi
  	 * The section can't be removed here because of the
  	 * memory_block->state_sem.
  	 */
+	memory_resize_lock();
  	zone = page_zone(pfn_to_page(pfn));
  	pgdat_resize_lock(zone->zone_pgdat, &flags);
-	grow_zone_span(zone, pfn, pfn + nr_pages);
  	grow_pgdat_span(zone->zone_pgdat, pfn, pfn + nr_pages);
  	pgdat_resize_unlock(zone->zone_pgdat, &flags);
+	memory_resize_unlock();

  	for (i = 0; i < nr_pages; i++) {
  		struct page *page = pfn_to_page(pfn + i);
Index: hogehoge/mm/page_alloc.c
===================================================================
--- hogehoge.orig/mm/page_alloc.c
+++ hogehoge/mm/page_alloc.c
@@ -2042,7 +2042,6 @@ static void __init free_area_init_core(s
  		zone->name = zone_names[j];
  		spin_lock_init(&zone->lock);
  		spin_lock_init(&zone->lru_lock);
-		zone_seqlock_init(zone);
  		zone->zone_pgdat = pgdat;
  		zone->free_pages = 0;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
