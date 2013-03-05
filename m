Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 05ECE6B000C
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 09:59:25 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id rp2so4550034pbb.34
        for <linux-mm@kvack.org>; Tue, 05 Mar 2013 06:59:25 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v1 08/33] mm/FRV: use common help functions to free reserved pages
Date: Tue,  5 Mar 2013 22:54:51 +0800
Message-Id: <1362495317-32682-9-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
References: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>

Use common help functions to free reserved pages.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: David Howells <dhowells@redhat.com>
---
 arch/frv/mm/init.c |   32 +++-----------------------------
 1 file changed, 3 insertions(+), 29 deletions(-)

diff --git a/arch/frv/mm/init.c b/arch/frv/mm/init.c
index 92e97b0..0a86dcb 100644
--- a/arch/frv/mm/init.c
+++ b/arch/frv/mm/init.c
@@ -132,11 +132,7 @@ void __init mem_init(void)
 
 #ifdef CONFIG_HIGHMEM
 	for (pfn = num_physpages - 1; pfn >= num_mappedpages; pfn--) {
-		struct page *page = &mem_map[pfn];
-
-		ClearPageReserved(page);
-		init_page_count(page);
-		__free_page(page);
+		__free_reserved_page(&mem_map[pfn]);
 		totalram_pages++;
 	}
 #endif
@@ -168,21 +164,7 @@ void __init mem_init(void)
 void free_initmem(void)
 {
 #if defined(CONFIG_RAMKERNEL) && !defined(CONFIG_PROTECT_KERNEL)
-	unsigned long start, end, addr;
-
-	start = PAGE_ALIGN((unsigned long) &__init_begin);	/* round up */
-	end   = ((unsigned long) &__init_end) & PAGE_MASK;	/* round down */
-
-	/* next to check that the page we free is not a partial page */
-	for (addr = start; addr < end; addr += PAGE_SIZE) {
-		ClearPageReserved(virt_to_page(addr));
-		init_page_count(virt_to_page(addr));
-		free_page(addr);
-		totalram_pages++;
-	}
-
-	printk("Freeing unused kernel memory: %ldKiB freed (0x%lx - 0x%lx)\n",
-	       (end - start) >> 10, start, end);
+	free_initmem_default(0);
 #endif
 } /* end free_initmem() */
 
@@ -193,14 +175,6 @@ void free_initmem(void)
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
-	printk("Freeing initrd memory: %dKiB freed\n", (pages * PAGE_SIZE) >> 10);
+	free_reserved_area(start, end, 0, "initrd");
 } /* end free_initrd_mem() */
 #endif
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
