Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 6922E6B0007
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 09:58:40 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id ro8so4547999pbb.32
        for <linux-mm@kvack.org>; Tue, 05 Mar 2013 06:58:39 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v1 04/33] mm/avr32: use common help functions to free reserved pages
Date: Tue,  5 Mar 2013 22:54:47 +0800
Message-Id: <1362495317-32682-5-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
References: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Haavard Skinnemoen <hskinnemoen@gmail.com>, Hans-Christian Egtvedt <egtvedt@samfundet.no>

Use common help functions to free reserved pages.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Haavard Skinnemoen <hskinnemoen@gmail.com>
Cc: Hans-Christian Egtvedt <egtvedt@samfundet.no>
---
 arch/avr32/mm/init.c |   24 ++----------------------
 1 file changed, 2 insertions(+), 22 deletions(-)

diff --git a/arch/avr32/mm/init.c b/arch/avr32/mm/init.c
index 2798c2d..e66e840 100644
--- a/arch/avr32/mm/init.c
+++ b/arch/avr32/mm/init.c
@@ -146,34 +146,14 @@ void __init mem_init(void)
 		initsize >> 10);
 }
 
-static inline void free_area(unsigned long addr, unsigned long end, char *s)
-{
-	unsigned int size = (end - addr) >> 10;
-
-	for (; addr < end; addr += PAGE_SIZE) {
-		struct page *page = virt_to_page(addr);
-		ClearPageReserved(page);
-		init_page_count(page);
-		free_page(addr);
-		totalram_pages++;
-	}
-
-	if (size && s)
-		printk(KERN_INFO "Freeing %s memory: %dK (%lx - %lx)\n",
-		       s, size, end - (size << 10), end);
-}
-
 void free_initmem(void)
 {
-	free_area((unsigned long)__init_begin, (unsigned long)__init_end,
-		  "init");
+	free_initmem_default(0);
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
-
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_area(start, end, "initrd");
+	free_reserved_area(start, end, 0, "initrd");
 }
-
 #endif
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
