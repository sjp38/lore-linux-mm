Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 019E88D0015
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 18:40:15 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp05.in.ibm.com (8.14.4/8.13.1) with ESMTP id o9SMe9RD029229
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 04:10:09 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o9SMe8Ip3031122
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 04:10:08 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o9SMe8Cm025901
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 09:40:08 +1100
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Fri, 29 Oct 2010 04:10:08 +0530
Message-Id: <20101028224008.32626.69769.sendpatchset@localhost.localdomain>
In-Reply-To: <20101028224002.32626.13015.sendpatchset@localhost.localdomain>
References: <20101028224002.32626.13015.sendpatchset@localhost.localdomain>
Subject: [RFC][PATCH 1/3] Linux/Guest unmapped page cache control
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, qemu-devel@nongnu.org
List-ID: <linux-mm.kvack.org>

Selectively control Unmapped Page Cache (nospam version)

From: Balbir Singh <balbir@linux.vnet.ibm.com>

This patch implements unmapped page cache control via preferred
page cache reclaim. The current patch hooks into kswapd and reclaims
page cache if the user has requested for unmapped page control.
This is useful in the following scenario

- In a virtualized environment with cache=writethrough, we see
  double caching - (one in the host and one in the guest). As
  we try to scale guests, cache usage across the system grows.
  The goal of this patch is to reclaim page cache when Linux is running
  as a guest and get the host to hold the page cache and manage it.
  There might be temporary duplication, but in the long run, memory
  in the guests would be used for mapped pages.
- The option is controlled via a boot option and the administrator
  can selectively turn it on, on a need to use basis.

A lot of the code is borrowed from zone_reclaim_mode logic for
__zone_reclaim(). One might argue that the with ballooning and
KSM this feature is not very useful, but even with ballooning,
we need extra logic to balloon multiple VM machines and it is hard
to figure out the correct amount of memory to balloon. With these
patches applied, each guest has a sufficient amount of free memory
available, that can be easily seen and reclaimed by the balloon driver.
The additional memory in the guest can be reused for additional
applications or used to start additional guests/balance memory in
the host.

KSM currently does not de-duplicate host and guest page cache. The goal
of this patch is to help automatically balance unmapped page cache when
instructed to do so.

There are some magic numbers in use in the code, UNMAPPED_PAGE_RATIO
and the number of pages to reclaim when unmapped_page_control argument
is supplied. These numbers were chosen to avoid aggressiveness in
reaping page cache ever so frequently, at the same time providing control.

The sysctl for min_unmapped_ratio provides further control from
within the guest on the amount of unmapped pages to reclaim.

Host Usage without boot parameter (memory in KB)
----------------------------
MemFree Cached Time
19900   292912 137
17540   296196 139
17900   296124 141
19356   296660 141

Host usage:  (memory in KB)

RSS     Cache   mapped  swap
2788664 781884  3780    359536

Guest Usage with boot parameter (memory in KB)
-------------------------
Memfree Cached   Time
244824  74828   144
237840  81764   143
235880  83044   138
239312  80092   148

Host usage: (memory in KB)

RSS     Cache   mapped  swap
2700184 958012  334848  398412

TODOS
-----
1. Balance slab cache as well

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 include/linux/mmzone.h |    2 -
 include/linux/swap.h   |    3 +
 mm/page_alloc.c        |    9 ++-
 mm/vmscan.c            |  162 ++++++++++++++++++++++++++++++++++++------------
 4 files changed, 132 insertions(+), 44 deletions(-)


diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 3984c4e..a591a7a 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -300,12 +300,12 @@ struct zone {
 	 */
 	unsigned long		lowmem_reserve[MAX_NR_ZONES];
 
+	unsigned long		min_unmapped_pages;
 #ifdef CONFIG_NUMA
 	int node;
 	/*
 	 * zone reclaim becomes active if more unmapped pages exist.
 	 */
-	unsigned long		min_unmapped_pages;
 	unsigned long		min_slab_pages;
 #endif
 	struct per_cpu_pageset __percpu *pageset;
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 7cdd633..5d29097 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -251,10 +251,11 @@ extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
 extern long vm_total_pages;
+extern bool should_balance_unmapped_pages(struct zone *zone);
 
+extern int sysctl_min_unmapped_ratio;
 #ifdef CONFIG_NUMA
 extern int zone_reclaim_mode;
-extern int sysctl_min_unmapped_ratio;
 extern int sysctl_min_slab_ratio;
 extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
 #else
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f12ad18..d8fe29f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1642,6 +1642,9 @@ zonelist_scan:
 			unsigned long mark;
 			int ret;
 
+			if (should_balance_unmapped_pages(zone))
+				wakeup_kswapd(zone, order);
+
 			mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
 			if (zone_watermark_ok(zone, order, mark,
 				    classzone_idx, alloc_flags))
@@ -4101,10 +4104,10 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 
 		zone->spanned_pages = size;
 		zone->present_pages = realsize;
-#ifdef CONFIG_NUMA
-		zone->node = nid;
 		zone->min_unmapped_pages = (realsize*sysctl_min_unmapped_ratio)
 						/ 100;
+#ifdef CONFIG_NUMA
+		zone->node = nid;
 		zone->min_slab_pages = (realsize * sysctl_min_slab_ratio) / 100;
 #endif
 		zone->name = zone_names[j];
@@ -5012,7 +5015,6 @@ int min_free_kbytes_sysctl_handler(ctl_table *table, int write,
 	return 0;
 }
 
-#ifdef CONFIG_NUMA
 int sysctl_min_unmapped_ratio_sysctl_handler(ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
@@ -5029,6 +5031,7 @@ int sysctl_min_unmapped_ratio_sysctl_handler(ctl_table *table, int write,
 	return 0;
 }
 
+#ifdef CONFIG_NUMA
 int sysctl_min_slab_ratio_sysctl_handler(ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c5dfabf..02346ad 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -139,6 +139,18 @@ static DECLARE_RWSEM(shrinker_rwsem);
 #define scanning_global_lru(sc)	(1)
 #endif
 
+static int unmapped_page_control __read_mostly;
+
+static int __init unmapped_page_control_parm(char *str)
+{
+	unmapped_page_control = 1;
+	/*
+	 * XXX: Should we tweak swappiness here?
+	 */
+	return 1;
+}
+__setup("unmapped_page_control", unmapped_page_control_parm);
+
 static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
 						  struct scan_control *sc)
 {
@@ -2091,6 +2103,102 @@ static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
 }
 
 /*
+ * Percentage of pages in a zone that must be unmapped for zone_reclaim to
+ * occur.
+ */
+int sysctl_min_unmapped_ratio = 1;
+/*
+ * Priority for ZONE_RECLAIM. This determines the fraction of pages
+ * of a node considered for each zone_reclaim. 4 scans 1/16th of
+ * a zone.
+ */
+#define ZONE_RECLAIM_PRIORITY 4
+
+
+#define RECLAIM_OFF 0
+#define RECLAIM_ZONE (1<<0)	/* Run shrink_inactive_list on the zone */
+#define RECLAIM_WRITE (1<<1)	/* Writeout pages during reclaim */
+#define RECLAIM_SWAP (1<<2)	/* Swap pages out during reclaim */
+
+static inline unsigned long zone_unmapped_file_pages(struct zone *zone)
+{
+	unsigned long file_mapped = zone_page_state(zone, NR_FILE_MAPPED);
+	unsigned long file_lru = zone_page_state(zone, NR_INACTIVE_FILE) +
+		zone_page_state(zone, NR_ACTIVE_FILE);
+
+	/*
+	 * It's possible for there to be more file mapped pages than
+	 * accounted for by the pages on the file LRU lists because
+	 * tmpfs pages accounted for as ANON can also be FILE_MAPPED
+	 */
+	return (file_lru > file_mapped) ? (file_lru - file_mapped) : 0;
+}
+
+/*
+ * Helper function to reclaim unmapped pages, we might add something
+ * similar to this for slab cache as well. Currently this function
+ * is shared with __zone_reclaim()
+ */
+static inline void
+zone_reclaim_unmapped_pages(struct zone *zone, struct scan_control *sc,
+				unsigned long nr_pages)
+{
+	int priority;
+	/*
+	 * Free memory by calling shrink zone with increasing
+	 * priorities until we have enough memory freed.
+	 */
+	priority = ZONE_RECLAIM_PRIORITY;
+	do {
+		shrink_zone(priority, zone, sc);
+		priority--;
+	} while (priority >= 0 && sc->nr_reclaimed < nr_pages);
+}
+
+/*
+ * Routine to balance unmapped pages, inspired from the code under
+ * CONFIG_NUMA that does unmapped page and slab page control by keeping
+ * min_unmapped_pages in the zone. We currently reclaim just unmapped
+ * pages, slab control will come in soon, at which point this routine
+ * should be called balance cached pages
+ */
+static unsigned long balance_unmapped_pages(int priority, struct zone *zone,
+						struct scan_control *sc)
+{
+	if (unmapped_page_control &&
+		(zone_unmapped_file_pages(zone) > zone->min_unmapped_pages)) {
+		struct scan_control nsc;
+		unsigned long nr_pages;
+
+		nsc = *sc;
+
+		nsc.swappiness = 0;
+		nsc.may_writepage = 0;
+		nsc.may_unmap = 0;
+		nsc.nr_reclaimed = 0;
+
+		nr_pages = zone_unmapped_file_pages(zone) -
+				zone->min_unmapped_pages;
+		/* Magically try to reclaim eighth the unmapped cache pages */
+		nr_pages >>= 3;
+
+		zone_reclaim_unmapped_pages(zone, &nsc, nr_pages);
+		return nsc.nr_reclaimed;
+	}
+	return 0;
+}
+
+#define UNMAPPED_PAGE_RATIO 16
+bool should_balance_unmapped_pages(struct zone *zone)
+{
+	if (unmapped_page_control &&
+		(zone_unmapped_file_pages(zone) >
+			UNMAPPED_PAGE_RATIO * zone->min_unmapped_pages))
+		return true;
+	return false;
+}
+
+/*
  * For kswapd, balance_pgdat() will work across all this node's zones until
  * they are all at high_wmark_pages(zone).
  *
@@ -2169,6 +2277,12 @@ loop_again:
 				shrink_active_list(SWAP_CLUSTER_MAX, zone,
 							&sc, priority, 0);
 
+			/*
+			 * We do unmapped page balancing once here and once
+			 * below, so that we don't lose out
+			 */
+			balance_unmapped_pages(priority, zone, &sc);
+
 			if (!zone_watermark_ok(zone, order,
 					high_wmark_pages(zone), 0, 0)) {
 				end_zone = i;
@@ -2206,6 +2320,12 @@ loop_again:
 			sc.nr_scanned = 0;
 
 			/*
+			 * Balance unmapped pages upfront, this should be
+			 * really cheap
+			 */
+			balance_unmapped_pages(priority, zone, &sc);
+
+			/*
 			 * Call soft limit reclaim before calling shrink_zone.
 			 * For now we ignore the return value
 			 */
@@ -2418,7 +2538,8 @@ void wakeup_kswapd(struct zone *zone, int order)
 		return;
 
 	pgdat = zone->zone_pgdat;
-	if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0, 0))
+	if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0, 0) &&
+		!should_balance_unmapped_pages(zone))
 		return;
 	if (pgdat->kswapd_max_order < order)
 		pgdat->kswapd_max_order = order;
@@ -2585,44 +2706,12 @@ module_init(kswapd_init)
  */
 int zone_reclaim_mode __read_mostly;
 
-#define RECLAIM_OFF 0
-#define RECLAIM_ZONE (1<<0)	/* Run shrink_inactive_list on the zone */
-#define RECLAIM_WRITE (1<<1)	/* Writeout pages during reclaim */
-#define RECLAIM_SWAP (1<<2)	/* Swap pages out during reclaim */
-
-/*
- * Priority for ZONE_RECLAIM. This determines the fraction of pages
- * of a node considered for each zone_reclaim. 4 scans 1/16th of
- * a zone.
- */
-#define ZONE_RECLAIM_PRIORITY 4
-
-/*
- * Percentage of pages in a zone that must be unmapped for zone_reclaim to
- * occur.
- */
-int sysctl_min_unmapped_ratio = 1;
-
 /*
  * If the number of slab pages in a zone grows beyond this percentage then
  * slab reclaim needs to occur.
  */
 int sysctl_min_slab_ratio = 5;
 
-static inline unsigned long zone_unmapped_file_pages(struct zone *zone)
-{
-	unsigned long file_mapped = zone_page_state(zone, NR_FILE_MAPPED);
-	unsigned long file_lru = zone_page_state(zone, NR_INACTIVE_FILE) +
-		zone_page_state(zone, NR_ACTIVE_FILE);
-
-	/*
-	 * It's possible for there to be more file mapped pages than
-	 * accounted for by the pages on the file LRU lists because
-	 * tmpfs pages accounted for as ANON can also be FILE_MAPPED
-	 */
-	return (file_lru > file_mapped) ? (file_lru - file_mapped) : 0;
-}
-
 /* Work out how many page cache pages we can reclaim in this reclaim_mode */
 static long zone_pagecache_reclaimable(struct zone *zone)
 {
@@ -2660,7 +2749,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	const unsigned long nr_pages = 1 << order;
 	struct task_struct *p = current;
 	struct reclaim_state reclaim_state;
-	int priority;
 	struct scan_control sc = {
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
 		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
@@ -2689,11 +2777,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		 * Free memory by calling shrink zone with increasing
 		 * priorities until we have enough memory freed.
 		 */
-		priority = ZONE_RECLAIM_PRIORITY;
-		do {
-			shrink_zone(priority, zone, &sc);
-			priority--;
-		} while (priority >= 0 && sc.nr_reclaimed < nr_pages);
+		zone_reclaim_unmapped_pages(zone, &sc, nr_pages);
 	}
 
 	nr_slab_pages0 = zone_page_state(zone, NR_SLAB_RECLAIMABLE);

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
