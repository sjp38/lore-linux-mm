Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 9ECF06B0095
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 01:33:40 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id md12so2660221pbc.16
        for <linux-mm@kvack.org>; Sat, 09 Mar 2013 22:33:39 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2, part1 28/29] mm/metag: use common help functions to free reserved pages
Date: Sun, 10 Mar 2013 14:27:11 +0800
Message-Id: <1362896833-21104-29-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com>
References: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, James Hogan <james.hogan@imgtec.com>

Use common help functions to free reserved pages.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: James Hogan <james.hogan@imgtec.com>
Cc: linux-kernel@vger.kernel.org
---
 arch/metag/mm/init.c |   21 ++-------------------
 1 file changed, 2 insertions(+), 19 deletions(-)

diff --git a/arch/metag/mm/init.c b/arch/metag/mm/init.c
index 504a398..c6784fb 100644
--- a/arch/metag/mm/init.c
+++ b/arch/metag/mm/init.c
@@ -412,32 +412,15 @@ void __init mem_init(void)
 	return;
 }
 
-static void free_init_pages(char *what, unsigned long begin, unsigned long end)
-{
-	unsigned long addr;
-
-	for (addr = begin; addr < end; addr += PAGE_SIZE) {
-		ClearPageReserved(virt_to_page(addr));
-		init_page_count(virt_to_page(addr));
-		memset((void *)addr, POISON_FREE_INITMEM, PAGE_SIZE);
-		free_page(addr);
-		totalram_pages++;
-	}
-	pr_info("Freeing %s: %luk freed\n", what, (end - begin) >> 10);
-}
-
 void free_initmem(void)
 {
-	free_init_pages("unused kernel memory",
-			(unsigned long)(&__init_begin),
-			(unsigned long)(&__init_end));
+	free_initmem_default(POISON_FREE_INITMEM);
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	end = end & PAGE_MASK;
-	free_init_pages("initrd memory", start, end);
+	free_reserved_area(start, end, POISON_FREE_INITMEM, "initrd");
 }
 #endif
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
