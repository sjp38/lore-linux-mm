Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id E1E346B006C
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 04:09:46 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id ma3so2675662pbc.11
        for <linux-mm@kvack.org>; Sun, 10 Mar 2013 00:09:46 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2, part2 09/10] mm/um: use free_highmem_page() to free highmem pages into buddy system
Date: Sun, 10 Mar 2013 16:01:09 +0800
Message-Id: <1362902470-25787-10-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362902470-25787-1-git-send-email-jiang.liu@huawei.com>
References: <1362902470-25787-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, user-mode-linux-devel@lists.sourceforge.net

Use helper function free_highmem_page() to free highmem pages into
the buddy system.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Jeff Dike <jdike@addtoit.com>
Cc: Richard Weinberger <richard@nod.at>
Cc: user-mode-linux-devel@lists.sourceforge.net
Cc: linux-kernel@vger.kernel.org
---
 arch/um/kernel/mem.c |   16 +++-------------
 1 file changed, 3 insertions(+), 13 deletions(-)

diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
index d5ac802..9df292b 100644
--- a/arch/um/kernel/mem.c
+++ b/arch/um/kernel/mem.c
@@ -42,17 +42,12 @@ static unsigned long brk_end;
 static void setup_highmem(unsigned long highmem_start,
 			  unsigned long highmem_len)
 {
-	struct page *page;
 	unsigned long highmem_pfn;
 	int i;
 
 	highmem_pfn = __pa(highmem_start) >> PAGE_SHIFT;
-	for (i = 0; i < highmem_len >> PAGE_SHIFT; i++) {
-		page = &mem_map[highmem_pfn + i];
-		ClearPageReserved(page);
-		init_page_count(page);
-		__free_page(page);
-	}
+	for (i = 0; i < highmem_len >> PAGE_SHIFT; i++)
+		free_highmem_page(&mem_map[highmem_pfn + i]);
 }
 #endif
 
@@ -73,18 +68,13 @@ void __init mem_init(void)
 	totalram_pages = free_all_bootmem();
 	max_low_pfn = totalram_pages;
 #ifdef CONFIG_HIGHMEM
-	totalhigh_pages = highmem >> PAGE_SHIFT;
-	totalram_pages += totalhigh_pages;
+	setup_highmem(end_iomem, highmem);
 #endif
 	num_physpages = totalram_pages;
 	max_pfn = totalram_pages;
 	printk(KERN_INFO "Memory: %luk available\n",
 	       nr_free_pages() << (PAGE_SHIFT-10));
 	kmalloc_ok = 1;
-
-#ifdef CONFIG_HIGHMEM
-	setup_highmem(end_iomem, highmem);
-#endif
 }
 
 /*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
