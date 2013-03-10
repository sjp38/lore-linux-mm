Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id A5E3C6B008C
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 01:33:32 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id md12so2660170pbc.16
        for <linux-mm@kvack.org>; Sat, 09 Mar 2013 22:33:31 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2, part1 27/29] mm/arc: use common help functions to free reserved pages
Date: Sun, 10 Mar 2013 14:27:10 +0800
Message-Id: <1362896833-21104-28-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com>
References: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-snps-arc@vger.kernel.org

Use common help functions to free reserved pages.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Acked-by: Vineet Gupta <vgupta@synopsys.com>
Cc: linux-snps-arc@vger.kernel.org
Cc: linux-kernel@vger.kernel.org (open list)
---
 arch/arc/mm/init.c |   23 ++---------------------
 1 file changed, 2 insertions(+), 21 deletions(-)

diff --git a/arch/arc/mm/init.c b/arch/arc/mm/init.c
index caf797d..727d479 100644
--- a/arch/arc/mm/init.c
+++ b/arch/arc/mm/init.c
@@ -144,37 +144,18 @@ void __init mem_init(void)
 		PAGES_TO_KB(reserved_pages));
 }
 
-static void __init free_init_pages(const char *what, unsigned long begin,
-				   unsigned long end)
-{
-	unsigned long addr;
-
-	pr_info("Freeing %s: %ldk [%lx] to [%lx]\n",
-		what, TO_KB(end - begin), begin, end);
-
-	/* need to check that the page we free is not a partial page */
-	for (addr = begin; addr + PAGE_SIZE <= end; addr += PAGE_SIZE) {
-		ClearPageReserved(virt_to_page(addr));
-		init_page_count(virt_to_page(addr));
-		free_page(addr);
-		totalram_pages++;
-	}
-}
-
 /*
  * free_initmem: Free all the __init memory.
  */
 void __init_refok free_initmem(void)
 {
-	free_init_pages("unused kernel memory",
-			(unsigned long)__init_begin,
-			(unsigned long)__init_end);
+	free_initmem_default(0);
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
 void __init free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_init_pages("initrd memory", start, end);
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
