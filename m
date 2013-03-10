Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 2BD836B0005
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 01:31:43 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id xa12so2649604pbc.36
        for <linux-mm@kvack.org>; Sat, 09 Mar 2013 22:31:42 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2, part1 14/29] mm/MIPS: use common help functions to free reserved pages
Date: Sun, 10 Mar 2013 14:26:57 +0800
Message-Id: <1362896833-21104-15-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com>
References: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>

Use common help functions to free reserved pages.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Ralf Baechle <ralf@linux-mips.org>
---
 arch/mips/mm/init.c              |   31 +++++++++----------------------
 arch/mips/sgi-ip27/ip27-memory.c |    4 ++--
 2 files changed, 11 insertions(+), 24 deletions(-)

diff --git a/arch/mips/mm/init.c b/arch/mips/mm/init.c
index 6792925..60f7c61 100644
--- a/arch/mips/mm/init.c
+++ b/arch/mips/mm/init.c
@@ -77,10 +77,9 @@ EXPORT_SYMBOL_GPL(empty_zero_page);
 /*
  * Not static inline because used by IP27 special magic initialization code
  */
-unsigned long setup_zero_pages(void)
+void setup_zero_pages(void)
 {
-	unsigned int order;
-	unsigned long size;
+	unsigned int order, i;
 	struct page *page;
 
 	if (cpu_has_vce)
@@ -94,15 +93,10 @@ unsigned long setup_zero_pages(void)
 
 	page = virt_to_page((void *)empty_zero_page);
 	split_page(page, order);
-	while (page < virt_to_page((void *)(empty_zero_page + (PAGE_SIZE << order)))) {
-		SetPageReserved(page);
-		page++;
-	}
-
-	size = PAGE_SIZE << order;
-	zero_page_mask = (size - 1) & PAGE_MASK;
+	for (i = 0; i < (1 << order); i++, page++)
+		mark_page_reserved(page);
 
-	return 1UL << order;
+	zero_page_mask = ((PAGE_SIZE << order) - 1) & PAGE_MASK;
 }
 
 #ifdef CONFIG_MIPS_MT_SMTC
@@ -380,7 +374,7 @@ void __init mem_init(void)
 	high_memory = (void *) __va(max_low_pfn << PAGE_SHIFT);
 
 	totalram_pages += free_all_bootmem();
-	totalram_pages -= setup_zero_pages();	/* Setup zeroed pages.	*/
+	setup_zero_pages();	/* Setup zeroed pages.  */
 
 	reservedpages = ram = 0;
 	for (tmp = 0; tmp < max_low_pfn; tmp++)
@@ -440,11 +434,8 @@ void free_init_pages(const char *what, unsigned long begin, unsigned long end)
 		struct page *page = pfn_to_page(pfn);
 		void *addr = phys_to_virt(PFN_PHYS(pfn));
 
-		ClearPageReserved(page);
-		init_page_count(page);
 		memset(addr, POISON_FREE_INITMEM, PAGE_SIZE);
-		__free_page(page);
-		totalram_pages++;
+		free_reserved_page(page);
 	}
 	printk(KERN_INFO "Freeing %s: %ldk freed\n", what, (end - begin) >> 10);
 }
@@ -452,18 +443,14 @@ void free_init_pages(const char *what, unsigned long begin, unsigned long end)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_init_pages("initrd memory",
-			virt_to_phys((void *)start),
-			virt_to_phys((void *)end));
+	free_reserved_area(start, end, POISON_FREE_INITMEM, "initrd");
 }
 #endif
 
 void __init_refok free_initmem(void)
 {
 	prom_free_prom_memory();
-	free_init_pages("unused kernel memory",
-			__pa_symbol(&__init_begin),
-			__pa_symbol(&__init_end));
+	free_initmem_default(POISON_FREE_INITMEM);
 }
 
 #ifndef CONFIG_MIPS_PGD_C0_CONTEXT
diff --git a/arch/mips/sgi-ip27/ip27-memory.c b/arch/mips/sgi-ip27/ip27-memory.c
index 3505d08..5f2bddb 100644
--- a/arch/mips/sgi-ip27/ip27-memory.c
+++ b/arch/mips/sgi-ip27/ip27-memory.c
@@ -457,7 +457,7 @@ void __init prom_free_prom_memory(void)
 	/* We got nothing to free here ...  */
 }
 
-extern unsigned long setup_zero_pages(void);
+extern void setup_zero_pages(void);
 
 void __init paging_init(void)
 {
@@ -492,7 +492,7 @@ void __init mem_init(void)
 		totalram_pages += free_all_bootmem_node(NODE_DATA(node));
 	}
 
-	totalram_pages -= setup_zero_pages();	/* This comes from node 0 */
+	setup_zero_pages();	/* This comes from node 0 */
 
 	codesize =  (unsigned long) &_etext - (unsigned long) &_text;
 	datasize =  (unsigned long) &_edata - (unsigned long) &_etext;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
