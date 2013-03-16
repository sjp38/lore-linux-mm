Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id EBC6E6B004D
	for <linux-mm@kvack.org>; Sat, 16 Mar 2013 13:04:17 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id wz12so5128909pbc.17
        for <linux-mm@kvack.org>; Sat, 16 Mar 2013 10:04:17 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2, part3 07/12] mm: accurately calculate zone->managed_pages for highmem zones
Date: Sun, 17 Mar 2013 01:03:28 +0800
Message-Id: <1363453413-8139-8-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1363453413-8139-1-git-send-email-jiang.liu@huawei.com>
References: <1363453413-8139-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Tejun Heo <tj@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Yinghai Lu <yinghai@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>

Commit "mm: introduce new field 'managed_pages' to struct zone" assumes
that all highmem pages will be freed into the buddy system by function
mem_init(). But that's not always true, some architectures may reserve
some highmem pages during boot. For example PPC may allocate highmem
pages for giagant HugeTLB pages, and several architectures have code to
check PageReserved flag to exclude highmem pages allocated during boot
when freeing highmem pages into the buddy system.

So do the same thing for highmem zones as normal zones, which is to:
1) reset all zones' managed_pages to zero in mem_init()
2) recalculate managed_pages for each zone when freeing pages into the
   buddy system.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Cc: Tejun Heo <tj@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>
Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---
 arch/x86/mm/highmem_32.c |    6 ++++++
 include/linux/bootmem.h  |    1 +
 mm/bootmem.c             |   32 ++++++++++++++++++--------------
 mm/nobootmem.c           |   32 +++++++++++++++++---------------
 mm/page_alloc.c          |    1 +
 5 files changed, 43 insertions(+), 29 deletions(-)

diff --git a/arch/x86/mm/highmem_32.c b/arch/x86/mm/highmem_32.c
index 252b8f5..4500142 100644
--- a/arch/x86/mm/highmem_32.c
+++ b/arch/x86/mm/highmem_32.c
@@ -1,6 +1,7 @@
 #include <linux/highmem.h>
 #include <linux/module.h>
 #include <linux/swap.h> /* for totalram_pages */
+#include <linux/bootmem.h>
 
 void *kmap(struct page *page)
 {
@@ -121,6 +122,11 @@ void __init set_highmem_pages_init(void)
 	struct zone *zone;
 	int nid;
 
+	/*
+	 * Explicitly reset zone->managed_pages because set_highmem_pages_init()
+	 * is invoked before free_all_bootmem()
+	 */
+	reset_all_zones_managed_pages();
 	for_each_zone(zone) {
 		unsigned long zone_start_pfn, zone_end_pfn;
 
diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index 190ff06..b0806c9 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -47,6 +47,7 @@ extern unsigned long init_bootmem(unsigned long addr, unsigned long memend);
 extern unsigned long free_low_memory_core_early(int nodeid);
 extern unsigned long free_all_bootmem_node(pg_data_t *pgdat);
 extern unsigned long free_all_bootmem(void);
+extern void reset_all_zones_managed_pages(void);
 
 extern void free_bootmem_node(pg_data_t *pgdat,
 			      unsigned long addr,
diff --git a/mm/bootmem.c b/mm/bootmem.c
index b93376c..7f71b31 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -241,20 +241,26 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 	return count;
 }
 
-static void reset_node_lowmem_managed_pages(pg_data_t *pgdat)
+static int reset_managed_pages_done __initdata;
+
+static inline void __init reset_node_managed_pages(pg_data_t *pgdat)
 {
 	struct zone *z;
 
-	/*
-	 * In free_area_init_core(), highmem zone's managed_pages is set to
-	 * present_pages, and bootmem allocator doesn't allocate from highmem
-	 * zones. So there's no need to recalculate managed_pages because all
-	 * highmem pages will be managed by the buddy system. Here highmem
-	 * zone also includes highmem movable zone.
-	 */
+	if (reset_managed_pages_done)
+		return;
+
 	for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
-		if (!is_highmem(z))
-			z->managed_pages = 0;
+		z->managed_pages = 0;
+}
+
+void __init reset_all_zones_managed_pages(void)
+{
+	struct pglist_data *pgdat;
+
+	for_each_online_pgdat(pgdat)
+		reset_node_managed_pages(pgdat);
+	reset_managed_pages_done = 1;
 }
 
 /**
@@ -266,7 +272,7 @@ static void reset_node_lowmem_managed_pages(pg_data_t *pgdat)
 unsigned long __init free_all_bootmem_node(pg_data_t *pgdat)
 {
 	register_page_bootmem_info_node(pgdat);
-	reset_node_lowmem_managed_pages(pgdat);
+	reset_node_managed_pages(pgdat);
 	return free_all_bootmem_core(pgdat->bdata);
 }
 
@@ -279,10 +285,8 @@ unsigned long __init free_all_bootmem(void)
 {
 	unsigned long total_pages = 0;
 	bootmem_data_t *bdata;
-	struct pglist_data *pgdat;
 
-	for_each_online_pgdat(pgdat)
-		reset_node_lowmem_managed_pages(pgdat);
+	reset_all_zones_managed_pages();
 
 	list_for_each_entry(bdata, &bdata_list, list)
 		total_pages += free_all_bootmem_core(bdata);
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index b8294fc..3db0f67 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -137,20 +137,25 @@ unsigned long __init free_low_memory_core_early(int nodeid)
 	return count;
 }
 
-static void reset_node_lowmem_managed_pages(pg_data_t *pgdat)
+static int reset_managed_pages_done __initdata;
+
+static inline void __init reset_node_managed_pages(pg_data_t *pgdat)
 {
 	struct zone *z;
 
-	/*
-	 * In free_area_init_core(), highmem zone's managed_pages is set to
-	 * present_pages, and bootmem allocator doesn't allocate from highmem
-	 * zones. So there's no need to recalculate managed_pages because all
-	 * highmem pages will be managed by the buddy system. Here highmem
-	 * zone also includes highmem movable zone.
-	 */
+	if (reset_managed_pages_done)
+		return;
 	for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
-		if (!is_highmem(z))
-			z->managed_pages = 0;
+		z->managed_pages = 0;
+}
+
+void __init reset_all_zones_managed_pages(void)
+{
+	struct pglist_data *pgdat;
+
+	for_each_online_pgdat(pgdat)
+		reset_node_managed_pages(pgdat);
+	reset_managed_pages_done = 1;
 }
 
 /**
@@ -162,7 +167,7 @@ static void reset_node_lowmem_managed_pages(pg_data_t *pgdat)
 unsigned long __init free_all_bootmem_node(pg_data_t *pgdat)
 {
 	register_page_bootmem_info_node(pgdat);
-	reset_node_lowmem_managed_pages(pgdat);
+	reset_node_managed_pages(pgdat);
 
 	/* free_low_memory_core_early(MAX_NUMNODES) will be called later */
 	return 0;
@@ -175,10 +180,7 @@ unsigned long __init free_all_bootmem_node(pg_data_t *pgdat)
  */
 unsigned long __init free_all_bootmem(void)
 {
-	struct pglist_data *pgdat;
-
-	for_each_online_pgdat(pgdat)
-		reset_node_lowmem_managed_pages(pgdat);
+	reset_all_zones_managed_pages();
 
 	/*
 	 * We need to use MAX_NUMNODES instead of NODE_DATA(0)->node_id
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8c7b366..23bb4d7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5147,6 +5147,7 @@ void free_highmem_page(struct page *page)
 {
 	__free_reserved_page(page);
 	totalram_pages++;
+	page_zone(page)->managed_pages++;
 	totalhigh_pages++;
 }
 #endif
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
