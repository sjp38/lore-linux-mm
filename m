Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
        by fgwmail5.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k137s49A030929 for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:54:04 +0900
        (envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s7.gw.fujitsu.co.jp by m1.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k137s4tL022208 for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:54:04 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s7.gw.fujitsu.co.jp (s7 [127.0.0.1])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id E8BF620A472
	for <linux-mm@kvack.org>; Fri,  3 Feb 2006 16:54:03 +0900 (JST)
Received: from fjm505.ms.jp.fujitsu.com (fjm505.ms.jp.fujitsu.com [10.56.99.83])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id 7909C20A4C2
	for <linux-mm@kvack.org>; Fri,  3 Feb 2006 16:54:03 +0900 (JST)
Received: from [127.0.0.1] (fjmscan501.ms.jp.fujitsu.com [10.56.99.141])by fjm505.ms.jp.fujitsu.com with ESMTP id k137rovi010066
	for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:53:51 +0900
Message-ID: <43E30C49.5030302@jp.fujitsu.com>
Date: Fri, 03 Feb 2006 16:54:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC] peeling off zone from physical memory layout [9/10] remove
 zone_start_pfn from page_alloc.c
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This patch removes zone_start_pfn, spanned_pages from mm/page_alloc.c.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


Index: hogehoge/include/linux/mmzone.h
===================================================================
--- hogehoge.orig/include/linux/mmzone.h
+++ hogehoge/include/linux/mmzone.h
@@ -212,20 +212,7 @@ struct zone {
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
Index: hogehoge/mm/page_alloc.c
===================================================================
--- hogehoge.orig/mm/page_alloc.c
+++ hogehoge/mm/page_alloc.c
@@ -89,19 +89,7 @@ unsigned long __initdata nr_all_pages;
  #ifdef CONFIG_DEBUG_VM
  static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
  {
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
+	return page_zone(page) != zone;
  }

  static int page_is_consistent(struct zone *zone, struct page *page)
@@ -649,7 +637,7 @@ void mark_free_pages(struct zone *zone)
  	int order;
  	struct list_head *curr;

-	if (!zone->spanned_pages)
+	if (!populated_zone(zone))
  		return;

  	spin_lock_irqsave(&zone->lock, flags);
@@ -2012,11 +2000,9 @@ static __meminit void init_currently_emp
  	zone_wait_table_init(zone, size);
  	pgdat->nr_zones = zone_idx(zone) + 1;

-	zone->zone_start_pfn = zone_start_pfn;
-
  	memmap_init(size, pgdat->node_id, zone_idx(zone), zone_start_pfn);

-	zone_init_free_lists(pgdat, zone, zone->spanned_pages);
+	zone_init_free_lists(pgdat, zone, size);
  	arch_register_memory_zone(zone, zone_start_pfn, size);
  }

@@ -2052,7 +2038,6 @@ static void __init free_area_init_core(s
  			nr_kernel_pages += realsize;
  		nr_all_pages += realsize;

-		zone->spanned_pages = size;
  		zone->present_pages = realsize;
  		zone->name = zone_names[j];
  		spin_lock_init(&zone->lock);
@@ -2219,7 +2204,6 @@ static int zoneinfo_show(struct seq_file
  			   "\n        active   %lu"
  			   "\n        inactive %lu"
  			   "\n        scanned  %lu (a: %lu i: %lu)"
-			   "\n        spanned  %lu"
  			   "\n        present  %lu",
  			   zone->free_pages,
  			   zone->pages_min,
@@ -2229,7 +2213,6 @@ static int zoneinfo_show(struct seq_file
  			   zone->nr_inactive,
  			   zone->pages_scanned,
  			   zone->nr_scan_active, zone->nr_scan_inactive,
-			   zone->spanned_pages,
  			   zone->present_pages);
  		seq_printf(m,
  			   "\n        protection: (%lu",
@@ -2280,12 +2263,10 @@ static int zoneinfo_show(struct seq_file
  		seq_printf(m,
  			   "\n  all_unreclaimable: %u"
  			   "\n  prev_priority:     %i"
-			   "\n  temp_priority:     %i"
-			   "\n  start_pfn:         %lu",
+			   "\n  temp_priority:     %i",
  			   zone->all_unreclaimable,
  			   zone->prev_priority,
-			   zone->temp_priority,
-			   zone->zone_start_pfn);
+			   zone->temp_priority);
  		spin_unlock_irqrestore(&zone->lock, flags);
  		seq_putc(m, '\n');
  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
