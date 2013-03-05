Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 407A16B0009
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 09:59:07 -0500 (EST)
Received: by mail-da0-f50.google.com with SMTP id h15so26285dan.9
        for <linux-mm@kvack.org>; Tue, 05 Mar 2013 06:59:06 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v1 06/33] mm/c6x: use common help functions to free reserved pages
Date: Tue,  5 Mar 2013 22:54:49 +0800
Message-Id: <1362495317-32682-7-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
References: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mark Salter <msalter@redhat.com>, Aurelien Jacquiot <a-jacquiot@ti.com>

Use common help functions to free reserved pages.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Mark Salter <msalter@redhat.com>
Cc: Aurelien Jacquiot <a-jacquiot@ti.com>
---
 arch/c6x/mm/init.c |   30 ++----------------------------
 1 file changed, 2 insertions(+), 28 deletions(-)

diff --git a/arch/c6x/mm/init.c b/arch/c6x/mm/init.c
index 89395f0..a9fcd89 100644
--- a/arch/c6x/mm/init.c
+++ b/arch/c6x/mm/init.c
@@ -77,37 +77,11 @@ void __init mem_init(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void __init free_initrd_mem(unsigned long start, unsigned long end)
 {
-	int pages = 0;
-	for (; start < end; start += PAGE_SIZE) {
-		ClearPageReserved(virt_to_page(start));
-		init_page_count(virt_to_page(start));
-		free_page(start);
-		totalram_pages++;
-		pages++;
-	}
-	printk(KERN_INFO "Freeing initrd memory: %luk freed\n",
-	       (pages * PAGE_SIZE) >> 10);
+	free_reserved_area(start, end, 0, "initrd");
 }
 #endif
 
 void __init free_initmem(void)
 {
-	unsigned long addr;
-
-	/*
-	 * The following code should be cool even if these sections
-	 * are not page aligned.
-	 */
-	addr = PAGE_ALIGN((unsigned long)(__init_begin));
-
-	/* next to check that the page we free is not a partial page */
-	for (; addr + PAGE_SIZE < (unsigned long)(__init_end);
-	     addr += PAGE_SIZE) {
-		ClearPageReserved(virt_to_page(addr));
-		init_page_count(virt_to_page(addr));
-		free_page(addr);
-		totalram_pages++;
-	}
-	printk(KERN_INFO "Freeing unused kernel memory: %dK freed\n",
-	       (int) ((addr - PAGE_ALIGN((long) &__init_begin)) >> 10));
+	free_initmem_default(0);
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
