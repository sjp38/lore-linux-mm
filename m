Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 2B3CF6B007B
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 01:32:45 -0500 (EST)
Received: by mail-da0-f53.google.com with SMTP id n34so328260dal.26
        for <linux-mm@kvack.org>; Sat, 09 Mar 2013 22:32:44 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2, part1 21/29] mm/SH: use common help functions to free reserved pages
Date: Sun, 10 Mar 2013 14:27:04 +0800
Message-Id: <1362896833-21104-22-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com>
References: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Use common help functions to free reserved pages.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Acked-by: Paul Mundt <lethal@linux-sh.org>
---
 arch/sh/mm/init.c |   26 +++-----------------------
 1 file changed, 3 insertions(+), 23 deletions(-)

diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index 1057940..20f9ead 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -417,15 +417,13 @@ void __init mem_init(void)
 
 	for_each_online_node(nid) {
 		pg_data_t *pgdat = NODE_DATA(nid);
-		unsigned long node_pages = 0;
 		void *node_high_memory;
 
 		num_physpages += pgdat->node_present_pages;
 
 		if (pgdat->node_spanned_pages)
-			node_pages = free_all_bootmem_node(pgdat);
+			totalram_pages += free_all_bootmem_node(pgdat);
 
-		totalram_pages += node_pages;
 
 		node_high_memory = (void *)__va((pgdat->node_start_pfn +
 						 pgdat->node_spanned_pages) <<
@@ -501,31 +499,13 @@ void __init mem_init(void)
 
 void free_initmem(void)
 {
-	unsigned long addr;
-
-	addr = (unsigned long)(&__init_begin);
-	for (; addr < (unsigned long)(&__init_end); addr += PAGE_SIZE) {
-		ClearPageReserved(virt_to_page(addr));
-		init_page_count(virt_to_page(addr));
-		free_page(addr);
-		totalram_pages++;
-	}
-	printk("Freeing unused kernel memory: %ldk freed\n",
-	       ((unsigned long)&__init_end -
-	        (unsigned long)&__init_begin) >> 10);
+	free_initmem_default(0);
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	unsigned long p;
-	for (p = start; p < end; p += PAGE_SIZE) {
-		ClearPageReserved(virt_to_page(p));
-		init_page_count(virt_to_page(p));
-		free_page(p);
-		totalram_pages++;
-	}
-	printk("Freeing initrd memory: %ldk freed\n", (end - start) >> 10);
+	free_reserved_area(start, end, 0, "initrd");
 }
 #endif
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
