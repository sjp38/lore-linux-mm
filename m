Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 0D3076B0006
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 09:59:41 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id up1so4559923pbc.37
        for <linux-mm@kvack.org>; Tue, 05 Mar 2013 06:59:41 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v1 09/33] mm/h8300: use common help functions to free reserved pages
Date: Tue,  5 Mar 2013 22:54:52 +0800
Message-Id: <1362495317-32682-10-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
References: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>

Use common help functions to free reserved pages.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
---
 arch/h8300/mm/init.c |   28 ++--------------------------
 1 file changed, 2 insertions(+), 26 deletions(-)

diff --git a/arch/h8300/mm/init.c b/arch/h8300/mm/init.c
index 981e250..b84a2e5 100644
--- a/arch/h8300/mm/init.c
+++ b/arch/h8300/mm/init.c
@@ -161,15 +161,7 @@ void __init mem_init(void)
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
-	printk ("Freeing initrd memory: %dk freed\n", pages);
+	free_reserved_area(start, end, 0, "initrd");
 }
 #endif
 
@@ -177,23 +169,7 @@ void
 free_initmem(void)
 {
 #ifdef CONFIG_RAMKERNEL
-	unsigned long addr;
-/*
- *	the following code should be cool even if these sections
- *	are not page aligned.
- */
-	addr = PAGE_ALIGN((unsigned long)(__init_begin));
-	/* next to check that the page we free is not a partial page */
-	for (; addr + PAGE_SIZE < (unsigned long)__init_end; addr +=PAGE_SIZE) {
-		ClearPageReserved(virt_to_page(addr));
-		init_page_count(virt_to_page(addr));
-		free_page(addr);
-		totalram_pages++;
-	}
-	printk(KERN_INFO "Freeing unused kernel memory: %ldk freed (0x%x - 0x%x)\n",
-			(addr - PAGE_ALIGN((long) __init_begin)) >> 10,
-			(int)(PAGE_ALIGN((unsigned long)__init_begin)),
-			(int)(addr - PAGE_SIZE));
+	free_initmem_default(0);
 #endif
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
