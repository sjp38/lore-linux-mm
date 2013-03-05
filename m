Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id E74116B0028
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 10:01:32 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id un15so4523491pbc.24
        for <linux-mm@kvack.org>; Tue, 05 Mar 2013 07:01:32 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v1 19/33] mm/s390: use common help functions to free reserved pages
Date: Tue,  5 Mar 2013 22:55:02 +0800
Message-Id: <1362495317-32682-20-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
References: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

Use common help functions to free reserved pages.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 arch/s390/mm/init.c |   35 ++++++-----------------------------
 1 file changed, 6 insertions(+), 29 deletions(-)

diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 49ce6bb..70bda9e 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -42,11 +42,10 @@ pgd_t swapper_pg_dir[PTRS_PER_PGD] __attribute__((__aligned__(PAGE_SIZE)));
 unsigned long empty_zero_page, zero_page_mask;
 EXPORT_SYMBOL(empty_zero_page);
 
-static unsigned long __init setup_zero_pages(void)
+static void __init setup_zero_pages(void)
 {
 	struct cpuid cpu_id;
 	unsigned int order;
-	unsigned long size;
 	struct page *page;
 	int i;
 
@@ -75,14 +74,11 @@ static unsigned long __init setup_zero_pages(void)
 	page = virt_to_page((void *) empty_zero_page);
 	split_page(page, order);
 	for (i = 1 << order; i > 0; i--) {
-		SetPageReserved(page);
+		mark_page_reserved(page);
 		page++;
 	}
 
-	size = PAGE_SIZE << order;
-	zero_page_mask = (size - 1) & PAGE_MASK;
-
-	return 1UL << order;
+	zero_page_mask = ((PAGE_SIZE << order) - 1) & PAGE_MASK;
 }
 
 /*
@@ -139,7 +135,7 @@ void __init mem_init(void)
 
 	/* this will put all low memory onto the freelists */
 	totalram_pages += free_all_bootmem();
-	totalram_pages -= setup_zero_pages();	/* Setup zeroed pages. */
+	setup_zero_pages();	/* Setup zeroed pages. */
 
 	reservedpages = 0;
 
@@ -158,34 +154,15 @@ void __init mem_init(void)
 	       PFN_ALIGN((unsigned long)&_eshared) - 1);
 }
 
-void free_init_pages(char *what, unsigned long begin, unsigned long end)
-{
-	unsigned long addr = begin;
-
-	if (begin >= end)
-		return;
-	for (; addr < end; addr += PAGE_SIZE) {
-		ClearPageReserved(virt_to_page(addr));
-		init_page_count(virt_to_page(addr));
-		memset((void *)(addr & PAGE_MASK), POISON_FREE_INITMEM,
-		       PAGE_SIZE);
-		free_page(addr);
-		totalram_pages++;
-	}
-	printk(KERN_INFO "Freeing %s: %luk freed\n", what, (end - begin) >> 10);
-}
-
 void free_initmem(void)
 {
-	free_init_pages("unused kernel memory",
-			(unsigned long)&__init_begin,
-			(unsigned long)&__init_end);
+	free_initmem_default(0);
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
 void __init free_initrd_mem(unsigned long start, unsigned long end)
 {
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
