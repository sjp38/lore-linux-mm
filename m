Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 578A76B0009
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 10:02:04 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id ro8so4548323pbb.18
        for <linux-mm@kvack.org>; Tue, 05 Mar 2013 07:02:03 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v1 22/33] mm/SPARC: use common help functions to free reserved pages
Date: Tue,  5 Mar 2013 22:55:05 +0800
Message-Id: <1362495317-32682-23-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
References: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Sam Ravnborg <sam@ravnborg.org>

Use common help functions to free reserved pages.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Sam Ravnborg <sam@ravnborg.org>
---
 arch/sparc/kernel/leon_smp.c |   15 +++------------
 arch/sparc/mm/init_32.c      |   40 ++++++----------------------------------
 arch/sparc/mm/init_64.c      |   25 ++++---------------------
 3 files changed, 13 insertions(+), 67 deletions(-)

diff --git a/arch/sparc/kernel/leon_smp.c b/arch/sparc/kernel/leon_smp.c
index 9b40c9c..6cfc1b0 100644
--- a/arch/sparc/kernel/leon_smp.c
+++ b/arch/sparc/kernel/leon_smp.c
@@ -253,24 +253,15 @@ void __init leon_smp_done(void)
 
 	/* Free unneeded trap tables */
 	if (!cpu_present(1)) {
-		ClearPageReserved(virt_to_page(&trapbase_cpu1));
-		init_page_count(virt_to_page(&trapbase_cpu1));
-		free_page((unsigned long)&trapbase_cpu1);
-		totalram_pages++;
+		free_reserved_page(virt_to_page(&trapbase_cpu1));
 		num_physpages++;
 	}
 	if (!cpu_present(2)) {
-		ClearPageReserved(virt_to_page(&trapbase_cpu2));
-		init_page_count(virt_to_page(&trapbase_cpu2));
-		free_page((unsigned long)&trapbase_cpu2);
-		totalram_pages++;
+		free_reserved_page(virt_to_page(&trapbase_cpu2));
 		num_physpages++;
 	}
 	if (!cpu_present(3)) {
-		ClearPageReserved(virt_to_page(&trapbase_cpu3));
-		init_page_count(virt_to_page(&trapbase_cpu3));
-		free_page((unsigned long)&trapbase_cpu3);
-		totalram_pages++;
+		free_reserved_page(virt_to_page(&trapbase_cpu3));
 		num_physpages++;
 	}
 	/* Ok, they are spinning and ready to go. */
diff --git a/arch/sparc/mm/init_32.c b/arch/sparc/mm/init_32.c
index 48e0c03..2a7b6eb 100644
--- a/arch/sparc/mm/init_32.c
+++ b/arch/sparc/mm/init_32.c
@@ -374,45 +374,17 @@ void __init mem_init(void)
 
 void free_initmem (void)
 {
-	unsigned long addr;
-	unsigned long freed;
-
-	addr = (unsigned long)(&__init_begin);
-	freed = (unsigned long)(&__init_end) - addr;
-	for (; addr < (unsigned long)(&__init_end); addr += PAGE_SIZE) {
-		struct page *p;
-
-		memset((void *)addr, POISON_FREE_INITMEM, PAGE_SIZE);
-		p = virt_to_page(addr);
-
-		ClearPageReserved(p);
-		init_page_count(p);
-		__free_page(p);
-		totalram_pages++;
-		num_physpages++;
-	}
-	printk(KERN_INFO "Freeing unused kernel memory: %ldk freed\n",
-		freed >> 10);
+	num_physpages += free_reserved_area((unsigned long)(&__init_begin),
+					    (unsigned long)(&__init_end),
+					    POISON_FREE_INITMEM,
+					    "unused kernel");
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	if (start < end)
-		printk(KERN_INFO "Freeing initrd memory: %ldk freed\n",
-			(end - start) >> 10);
-	for (; start < end; start += PAGE_SIZE) {
-		struct page *p;
-
-		memset((void *)start, POISON_FREE_INITMEM, PAGE_SIZE);
-		p = virt_to_page(start);
-
-		ClearPageReserved(p);
-		init_page_count(p);
-		__free_page(p);
-		totalram_pages++;
-		num_physpages++;
-	}
+	num_physpages += free_reserved_area(start, end, POISON_FREE_INITMEM,
+					    "initrd");
 }
 #endif
 
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 1588d33..03bfd10 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2060,8 +2060,7 @@ void __init mem_init(void)
 	/* We subtract one to account for the mem_map_zero page
 	 * allocated below.
 	 */
-	totalram_pages -= 1;
-	num_physpages = totalram_pages;
+	num_physpages = totalram_pages - 1;
 
 	/*
 	 * Set up the zero page, mark it reserved, so that page count
@@ -2072,7 +2071,7 @@ void __init mem_init(void)
 		prom_printf("paging_init: Cannot alloc zero page.\n");
 		prom_halt();
 	}
-	SetPageReserved(mem_map_zero);
+	mark_page_reserved(mem_map_zero);
 
 	codepages = (((unsigned long) _etext) - ((unsigned long) _start));
 	codepages = PAGE_ALIGN(codepages) >> PAGE_SHIFT;
@@ -2112,7 +2111,6 @@ void free_initmem(void)
 	initend = (unsigned long)(__init_end) & PAGE_MASK;
 	for (; addr < initend; addr += PAGE_SIZE) {
 		unsigned long page;
-		struct page *p;
 
 		page = (addr +
 			((unsigned long) __va(kern_base)) -
@@ -2120,13 +2118,8 @@ void free_initmem(void)
 		memset((void *)addr, POISON_FREE_INITMEM, PAGE_SIZE);
 
 		if (do_free) {
-			p = virt_to_page(page);
-
-			ClearPageReserved(p);
-			init_page_count(p);
-			__free_page(p);
+			free_reserved_page(virt_to_page(page));
 			num_physpages++;
-			totalram_pages++;
 		}
 	}
 }
@@ -2134,17 +2127,7 @@ void free_initmem(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	if (start < end)
-		printk ("Freeing initrd memory: %ldk freed\n", (end - start) >> 10);
-	for (; start < end; start += PAGE_SIZE) {
-		struct page *p = virt_to_page(start);
-
-		ClearPageReserved(p);
-		init_page_count(p);
-		__free_page(p);
-		num_physpages++;
-		totalram_pages++;
-	}
+	num_physpages += free_reserved_area(start, end, 0, "initrd");
 }
 #endif
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
