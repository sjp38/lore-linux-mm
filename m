Message-Id: <20061130101921.854798000@chello.nl>>
References: <20061130101451.495412000@chello.nl>>
Date: Thu, 30 Nov 2006 11:14:55 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 4/6] mm: emergency pool and __GFP_EMERGENCY
Content-Disposition: inline; filename=page_alloc-GFP_EMERGENCY.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: netdev@vger.kernel.org, linux-mm@kvack.org
Cc: David Miller <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Introduce __GFP_EMERGENCY and an emergency pool.

__GFP_EMERGENCY will allow the allocation to disregard the watermarks, 
much like PF_MEMALLOC. The emergency pool is separated from the min watermark
because ALLOC_HARDER and ALLOC_HIGH modify the watermark in a relative way
and thus do not ensure a strict minimum.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/gfp.h    |    7 ++++++-
 include/linux/mmzone.h |    3 ++-
 mm/internal.h          |   10 +++++++---
 mm/page_alloc.c        |   48 +++++++++++++++++++++++++++++++++++++++++-------
 mm/vmstat.c            |    6 +++---
 5 files changed, 59 insertions(+), 15 deletions(-)

Index: linux-2.6-git/include/linux/gfp.h
===================================================================
--- linux-2.6-git.orig/include/linux/gfp.h	2006-11-30 10:56:35.000000000 +0100
+++ linux-2.6-git/include/linux/gfp.h	2006-11-30 10:56:43.000000000 +0100
@@ -35,17 +35,21 @@ struct vm_area_struct;
 #define __GFP_HIGH	((__force gfp_t)0x20u)	/* Should access emergency pools? */
 #define __GFP_IO	((__force gfp_t)0x40u)	/* Can start physical IO? */
 #define __GFP_FS	((__force gfp_t)0x80u)	/* Can call down to low-level FS? */
+
 #define __GFP_COLD	((__force gfp_t)0x100u)	/* Cache-cold page required */
 #define __GFP_NOWARN	((__force gfp_t)0x200u)	/* Suppress page allocation failure warning */
 #define __GFP_REPEAT	((__force gfp_t)0x400u)	/* Retry the allocation.  Might fail */
 #define __GFP_NOFAIL	((__force gfp_t)0x800u)	/* Retry for ever.  Cannot fail */
+
 #define __GFP_NORETRY	((__force gfp_t)0x1000u)/* Do not retry.  Might fail */
 #define __GFP_NO_GROW	((__force gfp_t)0x2000u)/* Slab internal usage */
 #define __GFP_COMP	((__force gfp_t)0x4000u)/* Add compound page metadata */
 #define __GFP_ZERO	((__force gfp_t)0x8000u)/* Return zeroed page on success */
+
 #define __GFP_NOMEMALLOC ((__force gfp_t)0x10000u) /* Don't use emergency reserves */
 #define __GFP_HARDWALL   ((__force gfp_t)0x20000u) /* Enforce hardwall cpuset memory allocs */
 #define __GFP_THISNODE	((__force gfp_t)0x40000u)/* No fallback, no policies */
+#define __GFP_EMERGENCY  ((__force gfp_t)0x80000u) /* Use emergency reserves */
 
 #define __GFP_BITS_SHIFT 20	/* Room for 20 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
@@ -54,7 +58,8 @@ struct vm_area_struct;
 #define GFP_LEVEL_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS| \
 			__GFP_COLD|__GFP_NOWARN|__GFP_REPEAT| \
 			__GFP_NOFAIL|__GFP_NORETRY|__GFP_NO_GROW|__GFP_COMP| \
-			__GFP_NOMEMALLOC|__GFP_HARDWALL|__GFP_THISNODE)
+			__GFP_NOMEMALLOC|__GFP_HARDWALL|__GFP_THISNODE| \
+			__GFP_EMERGENCY)
 
 /* This equals 0, but use constants in case they ever change */
 #define GFP_NOWAIT	(GFP_ATOMIC & ~__GFP_HIGH)
Index: linux-2.6-git/include/linux/mmzone.h
===================================================================
--- linux-2.6-git.orig/include/linux/mmzone.h	2006-11-30 10:56:35.000000000 +0100
+++ linux-2.6-git/include/linux/mmzone.h	2006-11-30 10:56:43.000000000 +0100
@@ -156,7 +156,7 @@ enum zone_type {
 struct zone {
 	/* Fields commonly accessed by the page allocator */
 	unsigned long		free_pages;
-	unsigned long		pages_min, pages_low, pages_high;
+	unsigned long		pages_emerg, pages_min, pages_low, pages_high;
 	/*
 	 * We don't know if the memory that we're going to allocate will be freeable
 	 * or/and it will be released eventually, so to avoid totally wasting several
@@ -461,6 +461,7 @@ int sysctl_min_unmapped_ratio_sysctl_han
 			struct file *, void __user *, size_t *, loff_t *);
 int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *, int,
 			struct file *, void __user *, size_t *, loff_t *);
+void adjust_memalloc_reserve(int pages);
 
 #include <linux/topology.h>
 /* Returns the number of the current Node. */
Index: linux-2.6-git/mm/page_alloc.c
===================================================================
--- linux-2.6-git.orig/mm/page_alloc.c	2006-11-30 10:56:43.000000000 +0100
+++ linux-2.6-git/mm/page_alloc.c	2006-11-30 11:00:02.000000000 +0100
@@ -103,6 +103,7 @@ static char *zone_names[MAX_NR_ZONES] = 
 
 static DEFINE_SPINLOCK(min_free_lock);
 int min_free_kbytes = 1024;
+int var_free_kbytes;
 
 unsigned long __meminitdata nr_kernel_pages;
 unsigned long __meminitdata nr_all_pages;
@@ -903,7 +904,8 @@ int zone_watermark_ok(struct zone *z, in
 	if (alloc_flags & ALLOC_HARDER)
 		min -= min / 4;
 
-	if (free_pages <= min + z->lowmem_reserve[classzone_idx])
+	if (free_pages <= min + z->lowmem_reserve[classzone_idx] +
+			z->pages_emerg)
 		return 0;
 	for (o = 0; o < order; o++) {
 		/* At the next order, this order's pages become unavailable */
@@ -1344,9 +1346,9 @@ void show_free_areas(void)
 			"\n",
 			zone->name,
 			K(zone->free_pages),
-			K(zone->pages_min),
-			K(zone->pages_low),
-			K(zone->pages_high),
+			K(zone->pages_emerg + zone->pages_min),
+			K(zone->pages_emerg + zone->pages_low),
+			K(zone->pages_emerg + zone->pages_high),
 			K(zone->nr_active),
 			K(zone->nr_inactive),
 			K(zone->present_pages),
@@ -2757,7 +2759,7 @@ static void calculate_totalreserve_pages
 			}
 
 			/* we treat pages_high as reserved pages. */
-			max += zone->pages_high;
+			max += zone->pages_high + zone->pages_emerg;
 
 			if (max > zone->present_pages)
 				max = zone->present_pages;
@@ -2814,7 +2816,8 @@ static void setup_per_zone_lowmem_reserv
  */
 static void __setup_per_zone_pages_min(void)
 {
-	unsigned long pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
+	unsigned pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
+	unsigned pages_emerg = var_free_kbytes >> (PAGE_SHIFT - 10);
 	unsigned long lowmem_pages = 0;
 	struct zone *zone;
 	unsigned long flags;
@@ -2826,11 +2829,13 @@ static void __setup_per_zone_pages_min(v
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
@@ -2849,12 +2854,14 @@ static void __setup_per_zone_pages_min(v
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
@@ -2875,6 +2882,33 @@ void setup_per_zone_pages_min(void)
 	spin_unlock_irqrestore(&min_free_lock, flags);
 }
 
+/**
+ *	adjust_memalloc_reserve - adjust the memalloc reserve
+ *	@pages: number of pages to add
+ *
+ *	It adds a number of pages to the memalloc reserve; if
+ *	the number was positive it kicks kswapd into action to
+ *	satisfy the higher watermarks.
+ *
+ *	NOTE: there is only a single caller, hence no locking.
+ */
+void adjust_memalloc_reserve(int pages)
+{
+	var_free_kbytes += pages << (PAGE_SHIFT - 10);
+	BUG_ON(var_free_kbytes < 0);
+	setup_per_zone_pages_min();
+	if (pages > 0) {
+		struct zone *zone;
+		for_each_zone(zone)
+			wakeup_kswapd(zone, 0);
+	}
+	if (pages)
+		printk(KERN_DEBUG "Emergency reserve: %d\n",
+				var_free_kbytes);
+}
+
+EXPORT_SYMBOL_GPL(adjust_memalloc_reserve);
+
 /*
  * Initialise min_free_kbytes.
  *
Index: linux-2.6-git/mm/vmstat.c
===================================================================
--- linux-2.6-git.orig/mm/vmstat.c	2006-11-30 10:56:35.000000000 +0100
+++ linux-2.6-git/mm/vmstat.c	2006-11-30 11:00:42.000000000 +0100
@@ -535,9 +535,9 @@ static int zoneinfo_show(struct seq_file
 			   "\n        spanned  %lu"
 			   "\n        present  %lu",
 			   zone->free_pages,
-			   zone->pages_min,
-			   zone->pages_low,
-			   zone->pages_high,
+			   zone->pages_emerg + zone->pages_min,
+			   zone->pages_emerg + zone->pages_low,
+			   zone->pages_emerg + zone->pages_high,
 			   zone->nr_active,
 			   zone->nr_inactive,
 			   zone->pages_scanned,
Index: linux-2.6-git/mm/internal.h
===================================================================
--- linux-2.6-git.orig/mm/internal.h	2006-11-30 10:56:43.000000000 +0100
+++ linux-2.6-git/mm/internal.h	2006-11-30 10:56:43.000000000 +0100
@@ -75,7 +75,9 @@ static int inline gfp_to_alloc_flags(gfp
 		alloc_flags |= ALLOC_HARDER;
 
 	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
-		if (!in_irq() && (p->flags & PF_MEMALLOC))
+		if (gfp_mask & __GFP_EMERGENCY)
+			alloc_flags |= ALLOC_NO_WATERMARKS;
+		else if (!in_irq() && (p->flags & PF_MEMALLOC))
 			alloc_flags |= ALLOC_NO_WATERMARKS;
 		else if (!in_interrupt() &&
 				unlikely(test_thread_flag(TIF_MEMDIE)))
@@ -103,7 +105,7 @@ static inline int alloc_flags_to_rank(in
 	return rank;
 }
 
-static inline int gfp_to_rank(gfp_t gfp_mask)
+static __always_inline int gfp_to_rank(gfp_t gfp_mask)
 {
 	/*
 	 * Although correct this full version takes a ~3% performance
@@ -118,7 +120,9 @@ static inline int gfp_to_rank(gfp_t gfp_
 	 */
 
 	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
-		if (!in_irq() && (current->flags & PF_MEMALLOC))
+		if (gfp_mask & __GFP_EMERGENCY)
+			return 0;
+		else if (!in_irq() && (current->flags & PF_MEMALLOC))
 			return 0;
 		else if (!in_interrupt() &&
 				unlikely(test_thread_flag(TIF_MEMDIE)))

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
