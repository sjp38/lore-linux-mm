Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3F734600034
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 09:27:21 -0400 (EDT)
From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: [PATCH 08/31] mm: emergency pool
Date: Thu,  1 Oct 2009 19:36:08 +0530
Message-Id: <1254405968-15940-1-git-send-email-sjayaraman@suse.de>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: netdev@vger.kernel.org, Neil Brown <neilb@suse.de>, Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>, Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no, Suresh Jayaraman <sjayaraman@suse.de>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl> 

Provide means to reserve a specific amount of pages.

The emergency pool is separated from the min watermark because ALLOC_HARDER
and ALLOC_HIGH modify the watermark in a relative way and thus do not ensure
a strict minimum.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
---
 include/linux/mmzone.h |    3 +
 mm/page_alloc.c        |   84 +++++++++++++++++++++++++++++++++++++++++++------
 mm/vmstat.c            |    6 +--
 3 files changed, 80 insertions(+), 13 deletions(-)

Index: mmotm/include/linux/mmzone.h
===================================================================
--- mmotm.orig/include/linux/mmzone.h
+++ mmotm/include/linux/mmzone.h
@@ -273,6 +273,7 @@ struct zone_reclaim_stat {
 
 struct zone {
 	/* Fields commonly accessed by the page allocator */
+	unsigned long           pages_emerg;    /* emergency pool */
 
 	/* zone watermarks, access with *_wmark_pages(zone) macros */
 	unsigned long watermark[NR_WMARK];
@@ -757,6 +758,8 @@ int sysctl_min_unmapped_ratio_sysctl_han
 int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *, int,
 			struct file *, void __user *, size_t *, loff_t *);
 
+int adjust_memalloc_reserve(int pages);
+
 extern int numa_zonelist_order_handler(struct ctl_table *, int,
 			struct file *, void __user *, size_t *, loff_t *);
 extern char numa_zonelist_order[];
Index: mmotm/mm/page_alloc.c
===================================================================
--- mmotm.orig/mm/page_alloc.c
+++ mmotm/mm/page_alloc.c
@@ -123,6 +123,8 @@ static char * const zone_names[MAX_NR_ZO
 
 static DEFINE_SPINLOCK(min_free_lock);
 int min_free_kbytes = 1024;
+static DEFINE_MUTEX(var_free_mutex);
+int var_free_kbytes;
 
 unsigned long __meminitdata nr_kernel_pages;
 unsigned long __meminitdata nr_all_pages;
@@ -1302,7 +1304,7 @@ int zone_watermark_ok(struct zone *z, in
 	if (alloc_flags & ALLOC_HARDER)
 		min -= min / 4;
 
-	if (free_pages <= min + z->lowmem_reserve[classzone_idx])
+	if (free_pages <= min+z->lowmem_reserve[classzone_idx]+z->pages_emerg)
 		return 0;
 	for (o = 0; o < order; o++) {
 		/* At the next order, this order's pages become unavailable */
@@ -1726,7 +1728,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, u
 {
 	const gfp_t wait = gfp_mask & __GFP_WAIT;
 	struct page *page = NULL;
-	int alloc_flags;
+	int alloc_flags = 0;
 	unsigned long pages_reclaimed = 0;
 	unsigned long did_some_progress;
 	struct task_struct *p = current;
@@ -1841,8 +1843,8 @@ rebalance:
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
@@ -2158,9 +2160,9 @@ void show_free_areas(void)
 			"\n",
 			zone->name,
 			K(zone_page_state(zone, NR_FREE_PAGES)),
-			K(min_wmark_pages(zone)),
-			K(low_wmark_pages(zone)),
-			K(high_wmark_pages(zone)),
+			K(zone->pages_emerg + min_wmark_pages(zone)),
+			K(zone->pages_emerg + low_wmark_pages(zone)),
+			K(zone->pages_emerg + high_wmark_pages(zone)),
 			K(zone_page_state(zone, NR_ACTIVE_ANON)),
 			K(zone_page_state(zone, NR_INACTIVE_ANON)),
 			K(zone_page_state(zone, NR_ACTIVE_FILE)),
@@ -4388,7 +4390,7 @@ static void calculate_totalreserve_pages
 			}
 
 			/* we treat the high watermark as reserved pages. */
-			max += high_wmark_pages(zone);
+			max += high_wmark_pages(zone) + zone->pages_emerg;
 
 			if (max > zone->present_pages)
 				max = zone->present_pages;
@@ -4446,7 +4448,8 @@ static void setup_per_zone_lowmem_reserv
  */
 static void __setup_per_zone_wmarks(void)
 {
-	unsigned long pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
+	unsigned pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
+	unsigned pages_emerg = var_free_kbytes >> (PAGE_SHIFT - 10);
 	unsigned long lowmem_pages = 0;
 	struct zone *zone;
 	unsigned long flags;
@@ -4458,11 +4461,13 @@ static void __setup_per_zone_wmarks(void
 	}
 
 	for_each_zone(zone) {
-		u64 tmp;
+		u64 tmp, tmp_emerg;
 
 		spin_lock_irqsave(&zone->lock, flags);
 		tmp = (u64)pages_min * zone->present_pages;
 		do_div(tmp, lowmem_pages);
+		tmp_emerg = (u64)pages_emerg * zone->present_pages;
+		do_div(tmp_emerg, lowmem_pages);
 		if (is_highmem(zone)) {
 			/*
 			 * __GFP_HIGH and PF_MEMALLOC allocations usually don't
@@ -4481,12 +4486,14 @@ static void __setup_per_zone_wmarks(void
 			if (min_pages > 128)
 				min_pages = 128;
 			zone->watermark[WMARK_MIN] = min_pages;
+			zone->pages_emerg = 0;
 		} else {
 			/*
 			 * If it's a lowmem zone, reserve a number of pages
 			 * proportionate to the zone's size.
 			 */
 			zone->watermark[WMARK_MIN] = tmp;
+			zone->pages_emerg = tmp_emerg;
 		}
 
 		zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) + (tmp >> 2);
@@ -4551,6 +4558,63 @@ void setup_per_zone_wmarks(void)
 	spin_unlock_irqrestore(&min_free_lock, flags);
 }
 
+static void __adjust_memalloc_reserve(int pages)
+{
+	var_free_kbytes += pages << (PAGE_SHIFT - 10);
+	BUG_ON(var_free_kbytes < 0);
+	setup_per_zone_wmarks();
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
Index: mmotm/mm/vmstat.c
===================================================================
--- mmotm.orig/mm/vmstat.c
+++ mmotm/mm/vmstat.c
@@ -713,9 +713,9 @@ static void zoneinfo_show_print(struct s
 		   "\n        spanned  %lu"
 		   "\n        present  %lu",
 		   zone_page_state(zone, NR_FREE_PAGES),
-		   min_wmark_pages(zone),
-		   low_wmark_pages(zone),
-		   high_wmark_pages(zone),
+		   zone->pages_emerg + min_wmark_pages(zone),
+		   zone->pages_emerg + min_wmark_pages(zone),
+		   zone->pages_emerg + high_wmark_pages(zone),
 		   zone->pages_scanned,
 		   zone->spanned_pages,
 		   zone->present_pages);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
