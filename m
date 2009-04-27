Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E0A516B00B8
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 13:00:59 -0400 (EDT)
Date: Mon, 27 Apr 2009 18:00:54 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: [RFC] Replace the watermark-related union in struct zone with a
	watermark[] array
Message-ID: <20090427170054.GE912@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie> <1240408407-21848-19-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.0904221251350.14558@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0904221251350.14558@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: Linux Memory Management List <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Just build and boot-tested. This is to illustrate what the patch looks like
to replace the union with an array and to see if people are happy with
it or think it should look like something else.

==== CUT HERE ====

Patch page-allocator-use-allocation-flags-as-an-index-to-the-zone-watermark
from -mm added a union to struct zone where the watermarks could be
accessed with either zone->pages_* or a pages_mark array. The concern
was that this aliasing caused more confusion that it helped.

This patch replaces the union with a watermark array that is indexed with
WMARK_* defines and updates all sites that talk about zone->pages_*.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
--- 
 Documentation/sysctl/vm.txt |   11 ++++++-----
 Documentation/vm/balance    |   18 +++++++++---------
 arch/m32r/mm/discontig.c    |    6 +++---
 include/linux/mmzone.h      |   16 ++++++++++------
 mm/page_alloc.c             |   41 +++++++++++++++++++++--------------------
 mm/vmscan.c                 |   41 +++++++++++++++++++++++------------------
 mm/vmstat.c                 |    6 +++---
 7 files changed, 75 insertions(+), 64 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 97c4b32..f79e12b 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -231,8 +231,8 @@ These protections are added to score to judge whether this zone should be used
 for page allocation or should be reclaimed.
 
 In this example, if normal pages (index=2) are required to this DMA zone and
-pages_high is used for watermark, the kernel judges this zone should not be
-used because pages_free(1355) is smaller than watermark + protection[2]
+watermark[WMARK_HIGH] is used for watermark, the kernel judges this zone should
+not be used because pages_free(1355) is smaller than watermark + protection[2]
 (4 + 2004 = 2008). If this protection value is 0, this zone would be used for
 normal page requirement. If requirement is DMA zone(index=0), protection[0]
 (=0) is used.
@@ -278,9 +278,10 @@ The default value is 65536.
 min_free_kbytes:
 
 This is used to force the Linux VM to keep a minimum number
-of kilobytes free.  The VM uses this number to compute a pages_min
-value for each lowmem zone in the system.  Each lowmem zone gets
-a number of reserved free pages based proportionally on its size.
+of kilobytes free.  The VM uses this number to compute a
+watermark[WMARK_MIN] value for each lowmem zone in the system.
+Each lowmem zone gets a number of reserved free pages based
+proportionally on its size.
 
 Some minimal amount of memory is needed to satisfy PF_MEMALLOC
 allocations; if you set this to lower than 1024KB, your system will
diff --git a/Documentation/vm/balance b/Documentation/vm/balance
index bd3d31b..c46e68c 100644
--- a/Documentation/vm/balance
+++ b/Documentation/vm/balance
@@ -75,15 +75,15 @@ Page stealing from process memory and shm is done if stealing the page would
 alleviate memory pressure on any zone in the page's node that has fallen below
 its watermark.
 
-pages_min/pages_low/pages_high/low_on_memory/zone_wake_kswapd: These are 
-per-zone fields, used to determine when a zone needs to be balanced. When
-the number of pages falls below pages_min, the hysteric field low_on_memory
-gets set. This stays set till the number of free pages becomes pages_high.
-When low_on_memory is set, page allocation requests will try to free some
-pages in the zone (providing GFP_WAIT is set in the request). Orthogonal
-to this, is the decision to poke kswapd to free some zone pages. That
-decision is not hysteresis based, and is done when the number of free
-pages is below pages_low; in which case zone_wake_kswapd is also set.
+watemark[WMARK_MIN/WMARK_LOW/WMARK_HIGH]/low_on_memory/zone_wake_kswapd: These
+are per-zone fields, used to determine when a zone needs to be balanced. When
+the number of pages falls below watermark[WMARK_MIN], the hysteric field
+low_on_memory gets set. This stays set till the number of free pages becomes
+watermark[WMARK_HIGH]. When low_on_memory is set, page allocation requests will
+try to free some pages in the zone (providing GFP_WAIT is set in the request).
+Orthogonal to this, is the decision to poke kswapd to free some zone pages.
+That decision is not hysteresis based, and is done when the number of free
+pages is below watermark[WMARK_LOW]; in which case zone_wake_kswapd is also set.
 
 
 (Good) Ideas that I have heard:
diff --git a/arch/m32r/mm/discontig.c b/arch/m32r/mm/discontig.c
index 7daf897..b7a78ad 100644
--- a/arch/m32r/mm/discontig.c
+++ b/arch/m32r/mm/discontig.c
@@ -154,9 +154,9 @@ unsigned long __init zone_sizes_init(void)
 	 *  Use all area of internal RAM.
 	 *  see __alloc_pages()
 	 */
-	NODE_DATA(1)->node_zones->pages_min = 0;
-	NODE_DATA(1)->node_zones->pages_low = 0;
-	NODE_DATA(1)->node_zones->pages_high = 0;
+	NODE_DATA(1)->node_zones->watermark[WMARK_MIN] = 0;
+	NODE_DATA(1)->node_zones->watermark[WMARK_LOW] = 0;
+	NODE_DATA(1)->node_zones->watermark[WMARK_HIGH] = 0;
 
 	return holes;
 }
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c1fa208..1ff59fd 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -163,6 +163,13 @@ static inline int is_unevictable_lru(enum lru_list l)
 #endif
 }
 
+enum zone_watermarks {
+	WMARK_MIN,
+	WMARK_LOW,
+	WMARK_HIGH,
+	NR_WMARK
+};
+
 struct per_cpu_pages {
 	int count;		/* number of pages in the list */
 	int high;		/* high watermark, emptying needed */
@@ -275,12 +282,9 @@ struct zone_reclaim_stat {
 
 struct zone {
 	/* Fields commonly accessed by the page allocator */
-	union {
-		struct {
-			unsigned long	pages_min, pages_low, pages_high;
-		};
-		unsigned long pages_mark[3];
-	};
+
+	/* zone watermarks, indexed with WMARK_LOW, WMARK_MIN and WMARK_HIGH */
+	unsigned long watermark[NR_WMARK];
 
 	/*
 	 * We don't know if the memory that we're going to allocate will be freeable
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f5d5a63..5dd2d59 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1172,10 +1172,10 @@ failed:
 	return NULL;
 }
 
-/* The WMARK bits are used as an index zone->pages_mark */
-#define ALLOC_WMARK_MIN		0x00 /* use pages_min watermark */
-#define ALLOC_WMARK_LOW		0x01 /* use pages_low watermark */
-#define ALLOC_WMARK_HIGH	0x02 /* use pages_high watermark */
+/* The ALLOC_WMARK bits are used as an index to zone->watermark */
+#define ALLOC_WMARK_MIN		WMARK_MIN
+#define ALLOC_WMARK_LOW		WMARK_LOW
+#define ALLOC_WMARK_HIGH	WMARK_HIGH
 #define ALLOC_NO_WATERMARKS	0x04 /* don't check watermarks at all */
 
 /* Mask to get the watermark bits */
@@ -1464,9 +1464,10 @@ zonelist_scan:
 			!cpuset_zone_allowed_softwall(zone, gfp_mask))
 				goto try_next_zone;
 
+		BUILD_BUG_ON(ALLOC_NO_WATERMARKS < NR_WMARK);
 		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
 			unsigned long mark;
-			mark = zone->pages_mark[alloc_flags & ALLOC_WMARK_MASK];
+			mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
 			if (!zone_watermark_ok(zone, order, mark,
 				    classzone_idx, alloc_flags)) {
 				if (!zone_reclaim_mode ||
@@ -1987,7 +1988,7 @@ static unsigned int nr_free_zone_pages(int offset)
 
 	for_each_zone_zonelist(zone, z, zonelist, offset) {
 		unsigned long size = zone->present_pages;
-		unsigned long high = zone->pages_high;
+		unsigned long high = zone->watermark[WMARK_HIGH];
 		if (size > high)
 			sum += size - high;
 	}
@@ -2124,9 +2125,9 @@ void show_free_areas(void)
 			"\n",
 			zone->name,
 			K(zone_page_state(zone, NR_FREE_PAGES)),
-			K(zone->pages_min),
-			K(zone->pages_low),
-			K(zone->pages_high),
+			K(zone->watermark[WMARK_MIN]),
+			K(zone->watermark[WMARK_LOW]),
+			K(zone->watermark[WMARK_HIGH]),
 			K(zone_page_state(zone, NR_ACTIVE_ANON)),
 			K(zone_page_state(zone, NR_INACTIVE_ANON)),
 			K(zone_page_state(zone, NR_ACTIVE_FILE)),
@@ -2730,8 +2731,8 @@ static inline unsigned long wait_table_bits(unsigned long size)
 
 /*
  * Mark a number of pageblocks as MIGRATE_RESERVE. The number
- * of blocks reserved is based on zone->pages_min. The memory within the
- * reserve will tend to store contiguous free pages. Setting min_free_kbytes
+ * of blocks reserved is based on zone->watermark[WMARK_MIN]. The memory within
+ * the reserve will tend to store contiguous free pages. Setting min_free_kbytes
  * higher will lead to a bigger reserve which will get freed as contiguous
  * blocks as reclaim kicks in
  */
@@ -2744,7 +2745,7 @@ static void setup_zone_migrate_reserve(struct zone *zone)
 	/* Get the start pfn, end pfn and the number of blocks to reserve */
 	start_pfn = zone->zone_start_pfn;
 	end_pfn = start_pfn + zone->spanned_pages;
-	reserve = roundup(zone->pages_min, pageblock_nr_pages) >>
+	reserve = roundup(zone->watermark[WMARK_MIN], pageblock_nr_pages) >>
 							pageblock_order;
 
 	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
@@ -4400,8 +4401,8 @@ static void calculate_totalreserve_pages(void)
 					max = zone->lowmem_reserve[j];
 			}
 
-			/* we treat pages_high as reserved pages. */
-			max += zone->pages_high;
+			/* we treat WMARK_HIGH as reserved pages. */
+			max += zone->watermark[WMARK_HIGH];
 
 			if (max > zone->present_pages)
 				max = zone->present_pages;
@@ -4481,7 +4482,7 @@ void setup_per_zone_pages_min(void)
 			 * need highmem pages, so cap pages_min to a small
 			 * value here.
 			 *
-			 * The (pages_high-pages_low) and (pages_low-pages_min)
+			 * The WMARK_HIGH-WMARK_LOW and (WMARK_LOW-WMARK_MIN)
 			 * deltas controls asynch page reclaim, and so should
 			 * not be capped for highmem.
 			 */
@@ -4492,17 +4493,17 @@ void setup_per_zone_pages_min(void)
 				min_pages = SWAP_CLUSTER_MAX;
 			if (min_pages > 128)
 				min_pages = 128;
-			zone->pages_min = min_pages;
+			zone->watermark[WMARK_MIN] = min_pages;
 		} else {
 			/*
 			 * If it's a lowmem zone, reserve a number of pages
 			 * proportionate to the zone's size.
 			 */
-			zone->pages_min = tmp;
+			zone->watermark[WMARK_MIN] = tmp;
 		}
 
-		zone->pages_low   = zone->pages_min + (tmp >> 2);
-		zone->pages_high  = zone->pages_min + (tmp >> 1);
+		zone->watermark[WMARK_LOW]  = zone->watermark[WMARK_MIN] + (tmp >> 2);
+		zone->watermark[WMARK_HIGH] = zone->watermark[WMARK_MIN] + (tmp >> 1);
 		setup_zone_migrate_reserve(zone);
 		spin_unlock_irqrestore(&zone->lock, flags);
 	}
@@ -4647,7 +4648,7 @@ int sysctl_min_slab_ratio_sysctl_handler(ctl_table *table, int write,
  *	whenever sysctl_lowmem_reserve_ratio changes.
  *
  * The reserve ratio obviously has absolutely no relation with the
- * pages_min watermarks. The lowmem reserve ratio can only make sense
+ * watermark[WMARK_MIN] watermarks. The lowmem reserve ratio can only make sense
  * if in function of the boot time zone sizes.
  */
 int lowmem_reserve_ratio_sysctl_handler(ctl_table *table, int write,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index cef1801..371447c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1406,7 +1406,7 @@ static void get_scan_ratio(struct zone *zone, struct scan_control *sc,
 		free  = zone_page_state(zone, NR_FREE_PAGES);
 		/* If we have very few page cache pages,
 		   force-scan anon pages. */
-		if (unlikely(file + free <= zone->pages_high)) {
+		if (unlikely(file + free <= zone->watermark[WMARK_HIGH])) {
 			percent[0] = 100;
 			percent[1] = 0;
 			return;
@@ -1538,11 +1538,13 @@ static void shrink_zone(int priority, struct zone *zone,
  * try to reclaim pages from zones which will satisfy the caller's allocation
  * request.
  *
- * We reclaim from a zone even if that zone is over pages_high.  Because:
+ * We reclaim from a zone even if that zone is over watermark[WMARK_HIGH].
+ * Because:
  * a) The caller may be trying to free *extra* pages to satisfy a higher-order
  *    allocation or
- * b) The zones may be over pages_high but they must go *over* pages_high to
- *    satisfy the `incremental min' zone defense algorithm.
+ * b) The zones may be over watermark[WMARK_HIGH] but they must go *over*
+ *    watermark[WMARK_HIGH] to satisfy the `incremental min' zone defense
+ *    algorithm.
  *
  * If a zone is deemed to be full of pinned pages then just give it a light
  * scan then give up on it.
@@ -1748,7 +1750,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 
 /*
  * For kswapd, balance_pgdat() will work across all this node's zones until
- * they are all at pages_high.
+ * they are all at watermark[WMARK_HIGH].
  *
  * Returns the number of pages which were actually freed.
  *
@@ -1761,11 +1763,11 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
  * the zone for when the problem goes away.
  *
  * kswapd scans the zones in the highmem->normal->dma direction.  It skips
- * zones which have free_pages > pages_high, but once a zone is found to have
- * free_pages <= pages_high, we scan that zone and the lower zones regardless
- * of the number of free pages in the lower zones.  This interoperates with
- * the page allocator fallback scheme to ensure that aging of pages is balanced
- * across the zones.
+ * zones which have free_pages > watermark[WMARK_HIGH], but once a zone is
+ * found to have free_pages <= watermarkpWMARK_HIGH], we scan that zone and the
+ * lower zones regardless of the number of free pages in the lower zones. This
+ * interoperates with the page allocator fallback scheme to ensure that aging
+ * of pages is balanced across the zones.
  */
 static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
 {
@@ -1786,7 +1788,8 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
 	};
 	/*
 	 * temp_priority is used to remember the scanning priority at which
-	 * this zone was successfully refilled to free_pages == pages_high.
+	 * this zone was successfully refilled to
+	 * free_pages == watermark[WMARK_HIGH].
 	 */
 	int temp_priority[MAX_NR_ZONES];
 
@@ -1831,8 +1834,8 @@ loop_again:
 				shrink_active_list(SWAP_CLUSTER_MAX, zone,
 							&sc, priority, 0);
 
-			if (!zone_watermark_ok(zone, order, zone->pages_high,
-					       0, 0)) {
+			if (!zone_watermark_ok(zone, order,
+					zone->watermark[WMARK_HIGH], 0, 0)) {
 				end_zone = i;
 				break;
 			}
@@ -1866,8 +1869,9 @@ loop_again:
 					priority != DEF_PRIORITY)
 				continue;
 
-			if (!zone_watermark_ok(zone, order, zone->pages_high,
-					       end_zone, 0))
+			if (!zone_watermark_ok(zone, order,
+					zone->watermark[WMARK_HIGH],
+					end_zone, 0))
 				all_zones_ok = 0;
 			temp_priority[i] = priority;
 			sc.nr_scanned = 0;
@@ -1876,8 +1880,9 @@ loop_again:
 			 * We put equal pressure on every zone, unless one
 			 * zone has way too many pages free already.
 			 */
-			if (!zone_watermark_ok(zone, order, 8*zone->pages_high,
-						end_zone, 0))
+			if (!zone_watermark_ok(zone, order,
+					8*zone->watermark[WMARK_HIGH],
+					end_zone, 0))
 				shrink_zone(priority, zone, &sc);
 			reclaim_state->reclaimed_slab = 0;
 			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
@@ -2043,7 +2048,7 @@ void wakeup_kswapd(struct zone *zone, int order)
 		return;
 
 	pgdat = zone->zone_pgdat;
-	if (zone_watermark_ok(zone, order, zone->pages_low, 0, 0))
+	if (zone_watermark_ok(zone, order, zone->watermark[WMARK_LOW], 0, 0))
 		return;
 	if (pgdat->kswapd_max_order < order)
 		pgdat->kswapd_max_order = order;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 66f6130..17f2abb 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -725,9 +725,9 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		   "\n        spanned  %lu"
 		   "\n        present  %lu",
 		   zone_page_state(zone, NR_FREE_PAGES),
-		   zone->pages_min,
-		   zone->pages_low,
-		   zone->pages_high,
+		   zone->watermark[WMARK_MIN],
+		   zone->watermark[WMARK_LOW],
+		   zone->watermark[WMARK_HIGH],
 		   zone->pages_scanned,
 		   zone->lru[LRU_ACTIVE_ANON].nr_scan,
 		   zone->lru[LRU_INACTIVE_ANON].nr_scan,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
