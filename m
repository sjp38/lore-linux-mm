Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 268316B003C
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 01:31:26 -0500 (EST)
Received: by mail-da0-f44.google.com with SMTP id z20so477982dae.17
        for <linux-mm@kvack.org>; Sat, 09 Mar 2013 22:31:25 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2, part1 12/29] mm/m68k: use common help functions to free reserved pages
Date: Sun, 10 Mar 2013 14:26:55 +0800
Message-Id: <1362896833-21104-13-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com>
References: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>

Use common help functions to free reserved pages.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
---
 arch/m68k/mm/init.c |   24 ++----------------------
 1 file changed, 2 insertions(+), 22 deletions(-)

diff --git a/arch/m68k/mm/init.c b/arch/m68k/mm/init.c
index afd8106f..b5c1ab1 100644
--- a/arch/m68k/mm/init.c
+++ b/arch/m68k/mm/init.c
@@ -110,18 +110,7 @@ void __init paging_init(void)
 void free_initmem(void)
 {
 #ifndef CONFIG_MMU_SUN3
-	unsigned long addr;
-
-	addr = (unsigned long) __init_begin;
-	for (; addr < ((unsigned long) __init_end); addr += PAGE_SIZE) {
-		ClearPageReserved(virt_to_page(addr));
-		init_page_count(virt_to_page(addr));
-		free_page(addr);
-		totalram_pages++;
-	}
-	pr_notice("Freeing unused kernel memory: %luk freed (0x%x - 0x%x)\n",
-		(addr - (unsigned long) __init_begin) >> 10,
-		(unsigned int) __init_begin, (unsigned int) __init_end);
+	free_initmem_default(0);
 #endif /* CONFIG_MMU_SUN3 */
 }
 
@@ -213,15 +202,6 @@ void __init mem_init(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	int pages = 0;
-	for (; start < end; start += PAGE_SIZE) {
-		ClearPageReserved(virt_to_page(start));
-		init_page_count(virt_to_page(start));
-		free_page(start);
-		totalram_pages++;
-		pages++;
-	}
-	pr_notice("Freeing initrd memory: %dk freed\n",
-		pages << (PAGE_SHIFT - 10));
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
