Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 06E6A6B0093
	for <linux-mm@kvack.org>; Sun, 24 Mar 2013 03:31:09 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id un1so3656194pbc.40
        for <linux-mm@kvack.org>; Sun, 24 Mar 2013 00:31:06 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v2, part4 20/39] mm/m32r: prepare for removing num_physpages and simplify mem_init()
Date: Sun, 24 Mar 2013 15:24:58 +0800
Message-Id: <1364109934-7851-33-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com>
References: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hirokazu Takata <takata@linux-m32r.org>, linux-m32r@ml.linux-m32r.org, linux-m32r-ja@ml.linux-m32r.org

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Hirokazu Takata <takata@linux-m32r.org>
Cc: linux-m32r@ml.linux-m32r.org
Cc: linux-m32r-ja@ml.linux-m32r.org
Cc: linux-kernel@vger.kernel.org
---
 arch/m32r/mm/discontig.c |    6 +-----
 arch/m32r/mm/init.c      |   49 +++++-----------------------------------------
 2 files changed, 6 insertions(+), 49 deletions(-)

diff --git a/arch/m32r/mm/discontig.c b/arch/m32r/mm/discontig.c
index 2c468e8..2719630 100644
--- a/arch/m32r/mm/discontig.c
+++ b/arch/m32r/mm/discontig.c
@@ -129,11 +129,10 @@ unsigned long __init setup_memory(void)
 #define START_PFN(nid)		(NODE_DATA(nid)->bdata->node_min_pfn)
 #define MAX_LOW_PFN(nid)	(NODE_DATA(nid)->bdata->node_low_pfn)
 
-unsigned long __init zone_sizes_init(void)
+void __init zone_sizes_init(void)
 {
 	unsigned long zones_size[MAX_NR_ZONES], zholes_size[MAX_NR_ZONES];
 	unsigned long low, start_pfn;
-	unsigned long holes = 0;
 	int nid, i;
 	mem_prof_t *mp;
 
@@ -147,7 +146,6 @@ unsigned long __init zone_sizes_init(void)
 		low = MAX_LOW_PFN(nid);
 		zones_size[ZONE_DMA] = low - start_pfn;
 		zholes_size[ZONE_DMA] = mp->holes;
-		holes += zholes_size[ZONE_DMA];
 
 		node_set_state(nid, N_NORMAL_MEMORY);
 		free_area_init_node(nid, zones_size, start_pfn, zholes_size);
@@ -161,6 +159,4 @@ unsigned long __init zone_sizes_init(void)
 	NODE_DATA(1)->node_zones->watermark[WMARK_MIN] = 0;
 	NODE_DATA(1)->node_zones->watermark[WMARK_LOW] = 0;
 	NODE_DATA(1)->node_zones->watermark[WMARK_HIGH] = 0;
-
-	return holes;
 }
diff --git a/arch/m32r/mm/init.c b/arch/m32r/mm/init.c
index c421c31..9c94839 100644
--- a/arch/m32r/mm/init.c
+++ b/arch/m32r/mm/init.c
@@ -40,7 +40,6 @@ unsigned long mmu_context_cache_dat;
 #else
 unsigned long mmu_context_cache_dat[NR_CPUS];
 #endif
-static unsigned long hole_pages;
 
 /*
  * function prototype
@@ -57,7 +56,7 @@ void free_initrd_mem(unsigned long, unsigned long);
 #define MAX_LOW_PFN(nid)	(NODE_DATA(nid)->bdata->node_low_pfn)
 
 #ifndef CONFIG_DISCONTIGMEM
-unsigned long __init zone_sizes_init(void)
+void __init zone_sizes_init(void)
 {
 	unsigned long  zones_size[MAX_NR_ZONES] = {0, };
 	unsigned long  max_dma;
@@ -83,11 +82,9 @@ unsigned long __init zone_sizes_init(void)
 #endif /* CONFIG_MMU */
 
 	free_area_init_node(0, zones_size, start_pfn, 0);
-
-	return 0;
 }
 #else	/* CONFIG_DISCONTIGMEM */
-extern unsigned long zone_sizes_init(void);
+extern void zone_sizes_init(void);
 #endif	/* CONFIG_DISCONTIGMEM */
 
 /*======================================================================*
@@ -105,24 +102,7 @@ void __init paging_init(void)
 	for (i = 0 ; i < USER_PTRS_PER_PGD * 2 ; i++)
 		pgd_val(pg_dir[i]) = 0;
 #endif /* CONFIG_MMU */
-	hole_pages = zone_sizes_init();
-}
-
-int __init reservedpages_count(void)
-{
-	int reservedpages, nid, i;
-
-	reservedpages = 0;
-	for_each_online_node(nid) {
-		unsigned long flags;
-		pgdat_resize_lock(NODE_DATA(nid), &flags);
-		for (i = 0 ; i < MAX_LOW_PFN(nid) - START_PFN(nid) ; i++)
-			if (PageReserved(nid_page_nr(nid, i)))
-				reservedpages++;
-		pgdat_resize_unlock(NODE_DATA(nid), &flags);
-	}
-
-	return reservedpages;
+	zone_sizes_init();
 }
 
 /*======================================================================*
@@ -131,20 +111,13 @@ int __init reservedpages_count(void)
  *======================================================================*/
 void __init mem_init(void)
 {
-	int codesize, reservedpages, datasize, initsize;
 	int nid;
 #ifndef CONFIG_MMU
 	extern unsigned long memory_end;
 #endif
 
-	num_physpages = 0;
-	for_each_online_node(nid)
-		num_physpages += MAX_LOW_PFN(nid) - START_PFN(nid) + 1;
-
-	num_physpages -= hole_pages;
-
 #ifndef CONFIG_DISCONTIGMEM
-	max_mapnr = num_physpages;
+	max_mapnr = get_num_physpages();
 #endif	/* CONFIG_DISCONTIGMEM */
 
 #ifdef CONFIG_MMU
@@ -160,19 +133,7 @@ void __init mem_init(void)
 	for_each_online_node(nid)
 		free_all_bootmem_node(NODE_DATA(nid));
 
-	reservedpages = reservedpages_count() - hole_pages;
-	codesize = (unsigned long) &_etext - (unsigned long)&_text;
-	datasize = (unsigned long) &_edata - (unsigned long)&_etext;
-	initsize = (unsigned long) &__init_end - (unsigned long)&__init_begin;
-
-	printk(KERN_INFO "Memory: %luk/%luk available (%dk kernel code, "
-		"%dk reserved, %dk data, %dk init)\n",
-		nr_free_pages() << (PAGE_SHIFT-10),
-		num_physpages << (PAGE_SHIFT-10),
-		codesize >> 10,
-		reservedpages << (PAGE_SHIFT-10),
-		datasize >> 10,
-		initsize >> 10);
+	mem_init_print_info(NULL);
 }
 
 /*======================================================================*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
