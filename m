Message-Id: <20070806103659.399233000@chello.nl>
References: <20070806102922.907530000@chello.nl>
Date: Mon, 06 Aug 2007 12:29:31 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 09/10] mm: emergency pool
Content-Disposition: inline; filename=mm-page_alloc-emerg.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

Provide means to reserve a specific amount of pages.

The emergency pool is separated from the min watermark because ALLOC_HARDER
and ALLOC_HIGH modify the watermark in a relative way and thus do not ensure
a strict minimum.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/mmzone.h |    3 +
 mm/page_alloc.c        |   82 +++++++++++++++++++++++++++++++++++++++++++------
 mm/vmstat.c            |    6 +--
 3 files changed, 78 insertions(+), 13 deletions(-)

Index: linux-2.6-2/include/linux/mmzone.h
===================================================================
--- linux-2.6-2.orig/include/linux/mmzone.h
+++ linux-2.6-2/include/linux/mmzone.h
@@ -191,7 +191,7 @@ enum zone_type {
 
 struct zone {
 	/* Fields commonly accessed by the page allocator */
-	unsigned long		pages_min, pages_low, pages_high;
+	unsigned long		pages_emerg, pages_min, pages_low, pages_high;
 	/*
 	 * We don't know if the memory that we're going to allocate will be freeable
 	 * or/and it will be released eventually, so to avoid totally wasting several
@@ -589,6 +589,7 @@ int sysctl_min_unmapped_ratio_sysctl_han
 			struct file *, void __user *, size_t *, loff_t *);
 int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *, int,
 			struct file *, void __user *, size_t *, loff_t *);
+int adjust_memalloc_reserve(int pages);
 
 extern int numa_zonelist_order_handler(struct ctl_table *, int,
 			struct file *, void __user *, size_t *, loff_t *);
Index: linux-2.6-2/mm/page_alloc.c
===================================================================
--- linux-2.6-2.orig/mm/page_alloc.c
+++ linux-2.6-2/mm/page_alloc.c
@@ -103,6 +103,8 @@ static char * const zone_names[MAX_NR_ZO
 
 static DEFINE_SPINLOCK(min_free_lock);
 int min_free_kbytes = 1024;
+static DEFINE_MUTEX(var_free_mutex);
+int var_free_kbytes;
 
 unsigned long __meminitdata nr_kernel_pages;
 unsigned long __meminitdata nr_all_pages;
@@ -1000,7 +1002,7 @@ int zone_watermark_ok(struct zone *z, in
 	if (alloc_flags & ALLOC_HARDER)
 		min -= min / 4;
 
-	if (free_pages <= min + z->lowmem_reserve[classzone_idx])
+	if (free_pages <= min + z->lowmem_reserve[classzone_idx] + z->pages_emerg)
 		return 0;
 	for (o = 0; o < order; o++) {
 		/* At the next order, this order's pages become unavailable */
@@ -1410,8 +1412,8 @@ nofail_alloc:
 nopage:
 	if (!(gfp_mask & __GFP_NOWARN) && printk_ratelimit()) {
 		printk(KERN_WARNING "%s: page allocation failure."
-			" order:%d, mode:0x%x\n",
-			p->comm, order, gfp_mask);
+			" order:%d, mode:0x%x, alloc_flags:0x%x, pflags:0x%x\n",
+			p->comm, order, gfp_mask, alloc_flags, p->flags);
 		dump_stack();
 		show_mem();
 	}
@@ -1625,9 +1627,9 @@ void show_free_areas(void)
 			"\n",
 			zone->name,
 			K(zone_page_state(zone, NR_FREE_PAGES)),
-			K(zone->pages_min),
-			K(zone->pages_low),
-			K(zone->pages_high),
+			K(zone->pages_emerg + zone->pages_min),
+			K(zone->pages_emerg + zone->pages_low),
+			K(zone->pages_emerg + zone->pages_high),
 			K(zone_page_state(zone, NR_ACTIVE)),
 			K(zone_page_state(zone, NR_INACTIVE)),
 			K(zone->present_pages),
@@ -3585,7 +3587,7 @@ static void calculate_totalreserve_pages
 			}
 
 			/* we treat pages_high as reserved pages. */
-			max += zone->pages_high;
+			max += zone->pages_high + zone->pages_emerg;
 
 			if (max > zone->present_pages)
 				max = zone->present_pages;
@@ -3642,7 +3644,8 @@ static void setup_per_zone_lowmem_reserv
  */
 static void __setup_per_zone_pages_min(void)
 {
-	unsigned long pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
+	unsigned pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
+	unsigned pages_emerg = var_free_kbytes >> (PAGE_SHIFT - 10);
 	unsigned long lowmem_pages = 0;
 	struct zone *zone;
 	unsigned long flags;
@@ -3654,11 +3657,13 @@ static void __setup_per_zone_pages_min(v
 	}
 
 	for_each_zone(zone) {
-		u64 tmp;
+		u64 tmp, tmp_emerg;
 
 		spin_lock_irqsave(&zone->lru_lock, flags);
 		tmp = (u64)pages_min * zone->present_pages;
 		do_div(tmp, lowmem_pages);
+		tmp_emerg = (u64)pages_emerg * zone->present_pages;
+		do_div(tmp_emerg, lowmem_pages);
 		if (is_highmem(zone)) {
 			/*
 			 * __GFP_HIGH and PF_MEMALLOC allocations usually don't
@@ -3677,12 +3682,14 @@ static void __setup_per_zone_pages_min(v
 			if (min_pages > 128)
 				min_pages = 128;
 			zone->pages_min = min_pages;
+			zone->pages_emerg = min_pages;
 		} else {
 			/*
 			 * If it's a lowmem zone, reserve a number of pages
 			 * proportionate to the zone's size.
 			 */
 			zone->pages_min = tmp;
+			zone->pages_emerg = tmp_emerg;
 		}
 
 		zone->pages_low   = zone->pages_min + (tmp >> 2);
@@ -3703,6 +3710,63 @@ void setup_per_zone_pages_min(void)
 	spin_unlock_irqrestore(&min_free_lock, flags);
 }
 
+static void __adjust_memalloc_reserve(int pages)
+{
+	var_free_kbytes += pages << (PAGE_SHIFT - 10);
+	BUG_ON(var_free_kbytes < 0);
+	setup_per_zone_pages_min();
+}
+
+static int test_reserve_limits(void)
+{
+	struct zone *zone;
+	int node;
+
+	for_each_zone(zone)
+		wakeup_kswapd(zone, 0);
+
+	for_each_online_node(node) {
+		struct page *page = alloc_pages_node(node, GFP_KERNEL, 0);
+		if (!page)
+			return -ENOMEM;
+
+		__free_page(page);
+	}
+
+	return 0;
+}
+
+/**
+ *	adjust_memalloc_reserve - adjust the memalloc reserve
+ *	@pages: number of pages to add
+ *
+ *	It adds a number of pages to the memalloc reserve; if
+ *	the number was positive it kicks reclaim into action to
+ *	satisfy the higher watermarks.
+ *
+ *	returns -ENOMEM when it failed to satisfy the watermarks.
+ */
+int adjust_memalloc_reserve(int pages)
+{
+	int err = 0;
+
+	mutex_lock(&var_free_mutex);
+	__adjust_memalloc_reserve(pages);
+	if (pages > 0) {
+		err = test_reserve_limits();
+		if (err) {
+			__adjust_memalloc_reserve(-pages);
+			goto unlock;
+		}
+	}
+	printk(KERN_DEBUG "Emergency reserve: %d\n", var_free_kbytes);
+
+unlock:
+	mutex_unlock(&var_free_mutex);
+	return err;
+}
+EXPORT_SYMBOL_GPL(adjust_memalloc_reserve);
+
 /*
  * Initialise min_free_kbytes.
  *
Index: linux-2.6-2/mm/vmstat.c
===================================================================
--- linux-2.6-2.orig/mm/vmstat.c
+++ linux-2.6-2/mm/vmstat.c
@@ -558,9 +558,9 @@ static int zoneinfo_show(struct seq_file
 			   "\n        spanned  %lu"
 			   "\n        present  %lu",
 			   zone_page_state(zone, NR_FREE_PAGES),
-			   zone->pages_min,
-			   zone->pages_low,
-			   zone->pages_high,
+			   zone->pages_emerg + zone->pages_min,
+			   zone->pages_emerg + zone->pages_low,
+			   zone->pages_emerg + zone->pages_high,
 			   zone->pages_scanned,
 			   zone->nr_scan_active, zone->nr_scan_inactive,
 			   zone->spanned_pages,

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
