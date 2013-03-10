Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id D17166B0039
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 01:30:27 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id un1so2631185pbc.12
        for <linux-mm@kvack.org>; Sat, 09 Mar 2013 22:30:27 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2, part1 05/29] mm/blackfin: use common help functions to free reserved pages
Date: Sun, 10 Mar 2013 14:26:48 +0800
Message-Id: <1362896833-21104-6-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com>
References: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Frysinger <vapier@gentoo.org>

Use common help functions to free reserved pages.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Mike Frysinger <vapier@gentoo.org>
---
 arch/blackfin/mm/init.c |   22 +++-------------------
 1 file changed, 3 insertions(+), 19 deletions(-)

diff --git a/arch/blackfin/mm/init.c b/arch/blackfin/mm/init.c
index 9cb8553..82d01a7 100644
--- a/arch/blackfin/mm/init.c
+++ b/arch/blackfin/mm/init.c
@@ -103,7 +103,7 @@ void __init mem_init(void)
 	max_mapnr = num_physpages = MAP_NR(high_memory);
 	printk(KERN_DEBUG "Kernel managed physical pages: %lu\n", num_physpages);
 
-	/* This will put all memory onto the freelists. */
+	/* This will put all low memory onto the freelists. */
 	totalram_pages = free_all_bootmem();
 
 	reservedpages = 0;
@@ -129,24 +129,11 @@ void __init mem_init(void)
 		initk, codek, datak, DMA_UNCACHED_REGION >> 10, (reservedpages << (PAGE_SHIFT-10)));
 }
 
-static void __init free_init_pages(const char *what, unsigned long begin, unsigned long end)
-{
-	unsigned long addr;
-	/* next to check that the page we free is not a partial page */
-	for (addr = begin; addr + PAGE_SIZE <= end; addr += PAGE_SIZE) {
-		ClearPageReserved(virt_to_page(addr));
-		init_page_count(virt_to_page(addr));
-		free_page(addr);
-		totalram_pages++;
-	}
-	printk(KERN_INFO "Freeing %s: %ldk freed\n", what, (end - begin) >> 10);
-}
-
 #ifdef CONFIG_BLK_DEV_INITRD
 void __init free_initrd_mem(unsigned long start, unsigned long end)
 {
 #ifndef CONFIG_MPU
-	free_init_pages("initrd memory", start, end);
+	free_reserved_area(start, end, 0, "initrd");
 #endif
 }
 #endif
@@ -154,10 +141,7 @@ void __init free_initrd_mem(unsigned long start, unsigned long end)
 void __init_refok free_initmem(void)
 {
 #if defined CONFIG_RAMKERNEL && !defined CONFIG_MPU
-	free_init_pages("unused kernel memory",
-			(unsigned long)(&__init_begin),
-			(unsigned long)(&__init_end));
-
+	free_initmem_default(0);
 	if (memory_start == (unsigned long)(&__init_end))
 		memory_start = (unsigned long)(&__init_begin);
 #endif
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
