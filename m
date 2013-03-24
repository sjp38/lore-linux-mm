Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id EA0866B00C4
	for <linux-mm@kvack.org>; Sun, 24 Mar 2013 03:33:53 -0400 (EDT)
Received: by mail-da0-f50.google.com with SMTP id t1so1264754dae.23
        for <linux-mm@kvack.org>; Sun, 24 Mar 2013 00:33:53 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v2, part4 31/39] mm/SH: prepare for removing num_physpages and simplify mem_init()
Date: Sun, 24 Mar 2013 15:25:19 +0800
Message-Id: <1364109934-7851-54-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com>
References: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Paul Mundt <lethal@linux-sh.org>, Tang Chen <tangchen@cn.fujitsu.com>, linux-sh@vger.kernel.org

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Paul Mundt <lethal@linux-sh.org>
Cc: Wen Congyang <wency@cn.fujitsu.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: linux-sh@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 arch/sh/mm/init.c |   25 ++++---------------------
 1 file changed, 4 insertions(+), 21 deletions(-)

diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index aecd913..3826596 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -407,24 +407,18 @@ unsigned int mem_init_done = 0;
 
 void __init mem_init(void)
 {
-	int codesize, datasize, initsize;
-	int nid;
+	pg_data_t *pgdat;
 
 	iommu_init();
 
-	num_physpages = 0;
 	high_memory = NULL;
 
-	for_each_online_node(nid) {
-		pg_data_t *pgdat = NODE_DATA(nid);
+	for_each_online_pgdat(pgdat) {
 		void *node_high_memory;
 
-		num_physpages += pgdat->node_present_pages;
-
 		if (pgdat->node_spanned_pages)
 			free_all_bootmem_node(pgdat);
 
-
 		node_high_memory = (void *)__va((pgdat->node_start_pfn +
 						 pgdat->node_spanned_pages) <<
 						 PAGE_SHIFT);
@@ -441,19 +435,8 @@ void __init mem_init(void)
 
 	vsyscall_init();
 
-	codesize =  (unsigned long) &_etext - (unsigned long) &_text;
-	datasize =  (unsigned long) &_edata - (unsigned long) &_etext;
-	initsize =  (unsigned long) &__init_end - (unsigned long) &__init_begin;
-
-	printk(KERN_INFO "Memory: %luk/%luk available (%dk kernel code, "
-	       "%dk data, %dk init)\n",
-		nr_free_pages() << (PAGE_SHIFT-10),
-		num_physpages << (PAGE_SHIFT-10),
-		codesize >> 10,
-		datasize >> 10,
-		initsize >> 10);
-
-	printk(KERN_INFO "virtual kernel memory layout:\n"
+	mem_init_print_info(NULL);
+	pr_info("virtual kernel memory layout:\n"
 		"    fixmap  : 0x%08lx - 0x%08lx   (%4ld kB)\n"
 #ifdef CONFIG_HIGHMEM
 		"    pkmap   : 0x%08lx - 0x%08lx   (%4ld kB)\n"
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
