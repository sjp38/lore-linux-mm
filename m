Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id l1K5Ymiu010391
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 20 Feb 2007 14:34:48 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A1E561B801F
	for <linux-mm@kvack.org>; Tue, 20 Feb 2007 14:34:48 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7AC422DC078
	for <linux-mm@kvack.org>; Tue, 20 Feb 2007 14:34:48 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5 [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 55579161C00A
	for <linux-mm@kvack.org>; Tue, 20 Feb 2007 14:34:48 +0900 (JST)
Received: from fjm504.ms.jp.fujitsu.com (fjm504.ms.jp.fujitsu.com [10.56.99.80])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 878D7161C011
	for <linux-mm@kvack.org>; Tue, 20 Feb 2007 14:34:47 +0900 (JST)
Received: from fjmscan503.ms.jp.fujitsu.com (fjmscan503.ms.jp.fujitsu.com [10.56.99.143])by fjm504.ms.jp.fujitsu.com with ESMTP id l1K5Y6Q3021950
	for <linux-mm@kvack.org>; Tue, 20 Feb 2007 14:34:06 +0900
Received: from unknown ([10.124.100.187])
	by fjmscan503.ms.jp.fujitsu.com (8.13.1/8.12.11) with SMTP id l1K5Y2Fl029563
	for <linux-mm@kvack.org>; Tue, 20 Feb 2007 14:34:05 +0900
Date: Tue, 20 Feb 2007 14:34:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] remove zone ifdefs under mm/ [2/2]
Message-Id: <20070220143411.ecc56e24.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070220143010.6caf8cd9.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070220143010.6caf8cd9.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

remove #ifdefs of CONFIG_HIGHMEM/DMA32.(as an example)

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: linux-2.6.20-devel/mm/page_alloc.c
===================================================================
--- linux-2.6.20-devel.orig/mm/page_alloc.c
+++ linux-2.6.20-devel/mm/page_alloc.c
@@ -72,28 +72,11 @@ static void __free_pages_ok(struct page 
  * TBD: should special case ZONE_DMA32 machines here - in those we normally
  * don't need any ZONE_NORMAL reservation
  */
-int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1] = {
-	 256,
-#ifdef CONFIG_ZONE_DMA32
-	 256,
-#endif
-#ifdef CONFIG_HIGHMEM
-	 32
-#endif
-};
+int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1];
 
 EXPORT_SYMBOL(totalram_pages);
 
-static char * const zone_names[MAX_NR_ZONES] = {
-	 "DMA",
-#ifdef CONFIG_ZONE_DMA32
-	 "DMA32",
-#endif
-	 "Normal",
-#ifdef CONFIG_HIGHMEM
-	 "HighMem"
-#endif
-};
+static char * zone_names[ALL_POSSIBLE_ZONES];
 
 int min_free_kbytes = 1024;
 
@@ -132,6 +115,29 @@ static unsigned long __initdata dma_rese
 #endif /* CONFIG_MEMORY_HOTPLUG_RESERVE */
 #endif /* CONFIG_ARCH_POPULATES_NODE_MAP */
 
+static char dma_string[] = "DMA";
+static char normal_string[] = "Normal";
+static char dma32_string[] = "DMA32";
+static char highmem_string[] = "Highmem";
+
+static void __meminit init_zone_variables(void)
+{
+	if (zone_names[ZONE_DMA] == dma_string)
+		return;
+	zone_names[ZONE_DMA] =  dma_string;
+	zone_names[ZONE_DMA32] =  dma32_string;
+	zone_names[ZONE_NORMAL] =  normal_string;
+	zone_names[ZONE_HIGHMEM] = highmem_string;
+	sysctl_lowmem_reserve_ratio[ZONE_NORMAL] = 256;
+	if (is_configured_zone(ZONE_DMA32))
+		sysctl_lowmem_reserve_ratio[ZONE_DMA32] = 256;
+	if (is_configured_zone(ZONE_HIGHMEM))
+		sysctl_lowmem_reserve_ratio[ZONE_HIGHMEM] = 16;
+
+}
+
+
+
 #ifdef CONFIG_DEBUG_VM
 static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
 {
@@ -1530,13 +1536,13 @@ void si_meminfo_node(struct sysinfo *val
 
 	val->totalram = pgdat->node_present_pages;
 	val->freeram = nr_free_pages_pgdat(pgdat);
-#ifdef CONFIG_HIGHMEM
-	val->totalhigh = pgdat->node_zones[ZONE_HIGHMEM].present_pages;
-	val->freehigh = pgdat->node_zones[ZONE_HIGHMEM].free_pages;
-#else
-	val->totalhigh = 0;
-	val->freehigh = 0;
-#endif
+	if (is_configured_zone(ZONE_HIGHMEM)) {
+		val->totalhigh = pgdat->node_zones[ZONE_HIGHMEM].present_pages;
+		val->freehigh = pgdat->node_zones[ZONE_HIGHMEM].free_pages;
+	} else {
+		val->totalhigh = 0;
+		val->freehigh = 0;
+	}
 	val->mem_unit = PAGE_SIZE;
 }
 #endif
@@ -2621,6 +2627,7 @@ static void __meminit free_area_init_cor
 	unsigned long zone_start_pfn = pgdat->node_start_pfn;
 	int ret;
 
+	init_zone_variables();
 	pgdat_resize_init(pgdat);
 	pgdat->nr_zones = 0;
 	init_waitqueue_head(&pgdat->kswapd_wait);
Index: linux-2.6.20-devel/mm/page-writeback.c
===================================================================
--- linux-2.6.20-devel.orig/mm/page-writeback.c
+++ linux-2.6.20-devel/mm/page-writeback.c
@@ -131,12 +131,11 @@ get_dirty_limits(long *pbackground, long
 	unsigned long available_memory = vm_total_pages;
 	struct task_struct *tsk;
 
-#ifdef CONFIG_HIGHMEM
 	/*
 	 * We always exclude high memory from our count.
 	 */
-	available_memory -= totalhigh_pages;
-#endif
+	if (is_configured_zone(ZONE_HIGHMEM))
+		available_memory -= totalhigh_pages;
 
 
 	unmapped_ratio = 100 - ((global_page_state(NR_FILE_MAPPED) +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
