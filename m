Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id AA5676B0039
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 10:03:18 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id xa12so4522458pbc.22
        for <linux-mm@kvack.org>; Tue, 05 Mar 2013 07:03:17 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v1 29/33] mm: accurately calculate zone->managed_pages for highmem zones
Date: Tue,  5 Mar 2013 22:55:12 +0800
Message-Id: <1362495317-32682-30-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
References: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Commit "mm: introduce new field "managed_pages" to struct zone" assumes
that all highmem pages will be freed into the buddy system by function
mem_init(). But that's not true, some architectures may reserve some
highmem pages during boot. For example ppc may allocate highmem pages
for giagant HugeTLB pages, and several architectures check PageReserved
flag when freeing highmem pages into the buddy system.

So using the same way to calculate zone->managed_pages for both normal
and highmem zones.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 mm/bootmem.c    |   16 ++++------------
 mm/nobootmem.c  |   14 +++-----------
 mm/page_alloc.c |    1 +
 3 files changed, 8 insertions(+), 23 deletions(-)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index 2b0bcb0..46198d8 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -241,20 +241,12 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 	return count;
 }
 
-static void reset_node_lowmem_managed_pages(pg_data_t *pgdat)
+static inline void reset_node_managed_pages(pg_data_t *pgdat)
 {
 	struct zone *z;
 
-	/*
-	 * In free_area_init_core(), highmem zone's managed_pages is set to
-	 * present_pages, and bootmem allocator doesn't allocate from highmem
-	 * zones. So there's no need to recalculate managed_pages because all
-	 * highmem pages will be managed by the buddy system. Here highmem
-	 * zone also includes highmem movable zone.
-	 */
 	for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
-		if (!is_highmem(z))
-			z->managed_pages = 0;
+		z->managed_pages = 0;
 }
 
 /**
@@ -266,7 +258,7 @@ static void reset_node_lowmem_managed_pages(pg_data_t *pgdat)
 unsigned long __init free_all_bootmem_node(pg_data_t *pgdat)
 {
 	register_page_bootmem_info_node(pgdat);
-	reset_node_lowmem_managed_pages(pgdat);
+	reset_node_managed_pages(pgdat);
 	return free_all_bootmem_core(pgdat->bdata);
 }
 
@@ -282,7 +274,7 @@ unsigned long __init free_all_bootmem(void)
 	struct pglist_data *pgdat;
 
 	for_each_online_pgdat(pgdat)
-		reset_node_lowmem_managed_pages(pgdat);
+		reset_node_managed_pages(pgdat);
 
 	list_for_each_entry(bdata, &bdata_list, list)
 		total_pages += free_all_bootmem_core(bdata);
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 5e07d36..960e80a 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -137,20 +137,12 @@ unsigned long __init free_low_memory_core_early(int nodeid)
 	return count;
 }
 
-static void reset_node_lowmem_managed_pages(pg_data_t *pgdat)
+static inline void reset_node_managed_pages(pg_data_t *pgdat)
 {
 	struct zone *z;
 
-	/*
-	 * In free_area_init_core(), highmem zone's managed_pages is set to
-	 * present_pages, and bootmem allocator doesn't allocate from highmem
-	 * zones. So there's no need to recalculate managed_pages because all
-	 * highmem pages will be managed by the buddy system. Here highmem
-	 * zone also includes highmem movable zone.
-	 */
 	for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
-		if (!is_highmem(z))
-			z->managed_pages = 0;
+		z->managed_pages = 0;
 }
 
 /**
@@ -163,7 +155,7 @@ unsigned long __init free_all_bootmem(void)
 	struct pglist_data *pgdat;
 
 	for_each_online_pgdat(pgdat)
-		reset_node_lowmem_managed_pages(pgdat);
+		reset_node_managed_pages(pgdat);
 
 	/*
 	 * We need to use MAX_NUMNODES instead of NODE_DATA(0)->node_id
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ad2f619..8106aa5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5137,6 +5137,7 @@ unsigned long free_reserved_area(unsigned long start, unsigned long end,
 void free_highmem_page(struct page *page)
 {
 	__free_reserved_page(page);
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
