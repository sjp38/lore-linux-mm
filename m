Date: Tue, 6 Mar 2007 13:50:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC} memory unplug patchset prep [8/16] counter for ZONE_MOVABLE
Message-Id: <20070306135058.5ce2ab9d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@skynet.ie, clameter@engr.sgi.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Show #of Movable pages and vmstat.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 fs/proc/proc_misc.c    |    8 ++++++++
 include/linux/kernel.h |    2 ++
 include/linux/vmstat.h |    8 +++++++-
 mm/page_alloc.c        |   28 +++++++++++++++++++++++++++-
 mm/vmstat.c            |    8 +++++++-
 5 files changed, 51 insertions(+), 3 deletions(-)

Index: devel-tree-2.6.20-mm2/mm/page_alloc.c
===================================================================
--- devel-tree-2.6.20-mm2.orig/mm/page_alloc.c
+++ devel-tree-2.6.20-mm2/mm/page_alloc.c
@@ -58,6 +58,7 @@ unsigned long totalram_pages __read_most
 unsigned long totalreserve_pages __read_mostly;
 long nr_swap_pages;
 int percpu_pagelist_fraction;
+unsigned long total_movable_pages __read_mostly;
 
 static void __free_pages_ok(struct page *page, unsigned int order);
 
@@ -1571,6 +1572,20 @@ static unsigned int nr_free_zone_pages(i
 	return sum;
 }
 
+unsigned int nr_free_movable_pages(void)
+{
+	unsigned long nr_pages = 0;
+	struct zone *zone;
+	int nid;
+	if (is_configured_zone(ZONE_MOVABLE)) {
+		/* we want to count *only* pages in movable zone */
+		for_each_online_node(nid) {
+			zone = &(NODE_DATA(nid)->node_zones[ZONE_MOVABLE]);
+			nr_pages += zone_page_state(zone, NR_FREE_PAGES);
+		}
+	}
+	return nr_pages;
+}
 /*
  * Amount of free RAM allocatable within ZONE_DMA and ZONE_NORMAL
  */
@@ -1584,7 +1599,7 @@ unsigned int nr_free_buffer_pages(void)
  */
 unsigned int nr_free_pagecache_pages(void)
 {
-	return nr_free_zone_pages(gfp_zone(GFP_HIGHUSER));
+	return nr_free_zone_pages(gfp_zone(GFP_HIGH_MOVABLE));
 }
 
 /*
@@ -1633,6 +1648,8 @@ void si_meminfo(struct sysinfo *val)
 	val->totalhigh = totalhigh_pages;
 	val->freehigh = nr_free_highpages();
 	val->mem_unit = PAGE_SIZE;
+	val->movable = total_movable_pages;
+	val->free_movable = nr_free_movable_pages();
 }
 
 EXPORT_SYMBOL(si_meminfo);
@@ -1654,6 +1671,13 @@ void si_meminfo_node(struct sysinfo *val
 		val->totalhigh = 0;
 		val->freehigh = 0;
 	}
+	if (is_configured_zone(ZONE_MOVABLE)) {
+		val->movable +=
+			pgdat->node_zones[ZONE_MOVABLE].present_pages;
+		val->free_movable +=
+			zone_page_state(&pgdat->node_zones[ZONE_MOVABLE],
+				NR_FREE_PAGES);
+	}
 	val->mem_unit = PAGE_SIZE;
 }
 #endif
@@ -2779,6 +2803,8 @@ static void __meminit free_area_init_cor
 
 		zone->spanned_pages = size;
 		zone->present_pages = realsize;
+		if (j == ZONE_MOVABLE)
+			total_movable_pages += realsize;
 #ifdef CONFIG_NUMA
 		zone->node = nid;
 		zone->min_unmapped_pages = (realsize*sysctl_min_unmapped_ratio)
Index: devel-tree-2.6.20-mm2/include/linux/kernel.h
===================================================================
--- devel-tree-2.6.20-mm2.orig/include/linux/kernel.h
+++ devel-tree-2.6.20-mm2/include/linux/kernel.h
@@ -329,6 +329,8 @@ struct sysinfo {
 	unsigned short pad;		/* explicit padding for m68k */
 	unsigned long totalhigh;	/* Total high memory size */
 	unsigned long freehigh;		/* Available high memory size */
+	unsigned long movable;		/* pages used only for data */
+	unsigned long free_movable;	/* Avaiable pages in movable */
 	unsigned int mem_unit;		/* Memory unit size in bytes */
 	char _f[20-2*sizeof(long)-sizeof(int)];	/* Padding: libc5 uses this.. */
 };
Index: devel-tree-2.6.20-mm2/fs/proc/proc_misc.c
===================================================================
--- devel-tree-2.6.20-mm2.orig/fs/proc/proc_misc.c
+++ devel-tree-2.6.20-mm2/fs/proc/proc_misc.c
@@ -160,6 +160,10 @@ static int meminfo_read_proc(char *page,
 		"LowTotal:     %8lu kB\n"
 		"LowFree:      %8lu kB\n"
 #endif
+#ifdef CONFIG_ZONE_MOVABLE
+		"MovableTotal: %8lu kB\n"
+		"MovableFree:  %8lu kB\n"
+#endif
 		"SwapTotal:    %8lu kB\n"
 		"SwapFree:     %8lu kB\n"
 		"Dirty:        %8lu kB\n"
@@ -191,6 +195,10 @@ static int meminfo_read_proc(char *page,
 		K(i.totalram-i.totalhigh),
 		K(i.freeram-i.freehigh),
 #endif
+#ifdef CONFIG_ZONE_MOVABLE
+		K(i.movable),
+		K(i.free_movable),
+#endif
 		K(i.totalswap),
 		K(i.freeswap),
 		K(global_page_state(NR_FILE_DIRTY)),
Index: devel-tree-2.6.20-mm2/include/linux/vmstat.h
===================================================================
--- devel-tree-2.6.20-mm2.orig/include/linux/vmstat.h
+++ devel-tree-2.6.20-mm2/include/linux/vmstat.h
@@ -25,7 +25,13 @@
 #define HIGHMEM_ZONE(xx)
 #endif
 
-#define FOR_ALL_ZONES(xx) DMA_ZONE(xx) DMA32_ZONE(xx) xx##_NORMAL HIGHMEM_ZONE(xx)
+#ifdef CONFIG_ZONE_MOVABLE
+#define MOVABLE_ZONE(xx) , xx##_MOVABLE
+#else
+#define MOVABLE_ZONE(xx)
+#endif
+
+#define FOR_ALL_ZONES(xx) DMA_ZONE(xx) DMA32_ZONE(xx) xx##_NORMAL HIGHMEM_ZONE(xx) MOVABLE_ZONE(xx)
 
 enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		FOR_ALL_ZONES(PGALLOC),
Index: devel-tree-2.6.20-mm2/mm/vmstat.c
===================================================================
--- devel-tree-2.6.20-mm2.orig/mm/vmstat.c
+++ devel-tree-2.6.20-mm2/mm/vmstat.c
@@ -426,8 +426,14 @@ const struct seq_operations fragmentatio
 #define TEXT_FOR_HIGHMEM(xx)
 #endif
 
+#ifdef CONFIG_ZONE_MOVABLE
+#define TEXT_FOR_MOVABLE(xx) xx "_movable",
+#else
+#define TXT_FOR_MOVABLE(xx)
+#endif
+
 #define TEXTS_FOR_ZONES(xx) TEXT_FOR_DMA(xx) TEXT_FOR_DMA32(xx) xx "_normal", \
-					TEXT_FOR_HIGHMEM(xx)
+					TEXT_FOR_HIGHMEM(xx) TEXT_FOR_MOVABLE(xx)
 
 static const char * const vmstat_text[] = {
 	/* Zoned VM counters */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
