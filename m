Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 078196B0085
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 01:33:07 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id ro8so2637069pbb.32
        for <linux-mm@kvack.org>; Sat, 09 Mar 2013 22:33:07 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2, part1 24/29] mm/unicore32: use common help functions to free reserved pages
Date: Sun, 10 Mar 2013 14:27:07 +0800
Message-Id: <1362896833-21104-25-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com>
References: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>

Use common help functions to free reserved pages.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>
---
 arch/unicore32/mm/init.c |   28 +++-------------------------
 1 file changed, 3 insertions(+), 25 deletions(-)

diff --git a/arch/unicore32/mm/init.c b/arch/unicore32/mm/init.c
index de186bd..c5817b0 100644
--- a/arch/unicore32/mm/init.c
+++ b/arch/unicore32/mm/init.c
@@ -313,24 +313,6 @@ void __init bootmem_init(void)
 	max_pfn = max_high - PHYS_PFN_OFFSET;
 }
 
-static inline int free_area(unsigned long pfn, unsigned long end, char *s)
-{
-	unsigned int pages = 0, size = (end - pfn) << (PAGE_SHIFT - 10);
-
-	for (; pfn < end; pfn++) {
-		struct page *page = pfn_to_page(pfn);
-		ClearPageReserved(page);
-		init_page_count(page);
-		__free_page(page);
-		pages++;
-	}
-
-	if (size && s)
-		printk(KERN_INFO "Freeing %s memory: %dK\n", s, size);
-
-	return pages;
-}
-
 static inline void
 free_memmap(unsigned long start_pfn, unsigned long end_pfn)
 {
@@ -404,9 +386,9 @@ void __init mem_init(void)
 
 	max_mapnr   = pfn_to_page(max_pfn + PHYS_PFN_OFFSET) - mem_map;
 
-	/* this will put all unused low memory onto the freelists */
 	free_unused_memmap(&meminfo);
 
+	/* this will put all unused low memory onto the freelists */
 	totalram_pages += free_all_bootmem();
 
 	reserved_pages = free_pages = 0;
@@ -491,9 +473,7 @@ void __init mem_init(void)
 
 void free_initmem(void)
 {
-	totalram_pages += free_area(__phys_to_pfn(__pa(__init_begin)),
-				    __phys_to_pfn(__pa(__init_end)),
-				    "init");
+	free_initmem_default(0);
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
@@ -503,9 +483,7 @@ static int keep_initrd;
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
 	if (!keep_initrd)
-		totalram_pages += free_area(__phys_to_pfn(__pa(start)),
-					    __phys_to_pfn(__pa(end)),
-					    "initrd");
+		free_reserved_area(start, end, 0, "initrd");
 }
 
 static int __init keepinitrd_setup(char *__unused)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
