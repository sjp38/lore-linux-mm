Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id F41EE6B0070
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 01:32:12 -0500 (EST)
Received: by mail-da0-f48.google.com with SMTP id w4so472637dam.21
        for <linux-mm@kvack.org>; Sat, 09 Mar 2013 22:32:12 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2, part1 17/29] mm/parisc: use common help functions to free reserved pages
Date: Sun, 10 Mar 2013 14:27:00 +0800
Message-Id: <1362896833-21104-18-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com>
References: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>

Use common help functions to free reserved pages.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: "James E.J. Bottomley" <jejb@parisc-linux.org>
Cc: Helge Deller <deller@gmx.de>
---
 arch/parisc/mm/init.c |   23 ++---------------------
 1 file changed, 2 insertions(+), 21 deletions(-)

diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
index 3ac462d..de2159a 100644
--- a/arch/parisc/mm/init.c
+++ b/arch/parisc/mm/init.c
@@ -505,7 +505,6 @@ static void __init map_pages(unsigned long start_vaddr,
 
 void free_initmem(void)
 {
-	unsigned long addr;
 	unsigned long init_begin = (unsigned long)__init_begin;
 	unsigned long init_end = (unsigned long)__init_end;
 
@@ -533,19 +532,10 @@ void free_initmem(void)
 	 * pages are no-longer executable */
 	flush_icache_range(init_begin, init_end);
 	
-	for (addr = init_begin; addr < init_end; addr += PAGE_SIZE) {
-		ClearPageReserved(virt_to_page(addr));
-		init_page_count(virt_to_page(addr));
-		free_page(addr);
-		num_physpages++;
-		totalram_pages++;
-	}
+	num_physpages += free_initmem_default(0);
 
 	/* set up a new led state on systems shipped LED State panel */
 	pdc_chassis_send_status(PDC_CHASSIS_DIRECT_BCOMPLETE);
-	
-	printk(KERN_INFO "Freeing unused kernel memory: %luk freed\n",
-		(init_end - init_begin) >> 10);
 }
 
 
@@ -1107,15 +1097,6 @@ void flush_tlb_all(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	if (start >= end)
-		return;
-	printk(KERN_INFO "Freeing initrd memory: %ldk freed\n", (end - start) >> 10);
-	for (; start < end; start += PAGE_SIZE) {
-		ClearPageReserved(virt_to_page(start));
-		init_page_count(virt_to_page(start));
-		free_page(start);
-		num_physpages++;
-		totalram_pages++;
-	}
+	num_physpages += free_reserved_area(start, end, 0, "initrd");
 }
 #endif
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
