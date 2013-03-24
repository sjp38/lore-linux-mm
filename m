Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id A28686B0096
	for <linux-mm@kvack.org>; Sun, 24 Mar 2013 03:31:35 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id 3so2137528pdj.0
        for <linux-mm@kvack.org>; Sun, 24 Mar 2013 00:31:34 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v2, part4 22/39] mm/microblaze: prepare for removing num_physpages and simplify mem_init()
Date: Sun, 24 Mar 2013 15:25:02 +0800
Message-Id: <1364109934-7851-37-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com>
References: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Simek <monstr@monstr.eu>, microblaze-uclinux@itee.uq.edu.au

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Michal Simek <monstr@monstr.eu>
Cc: microblaze-uclinux@itee.uq.edu.au
Cc: linux-kernel@vger.kernel.org
---
 arch/microblaze/mm/init.c |   51 ++++++---------------------------------------
 1 file changed, 6 insertions(+), 45 deletions(-)

diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
index 3a434fd..0545ecd 100644
--- a/arch/microblaze/mm/init.c
+++ b/arch/microblaze/mm/init.c
@@ -71,24 +71,17 @@ static void __init highmem_init(void)
 	kmap_prot = PAGE_KERNEL;
 }
 
-static unsigned long highmem_setup(void)
+static void highmem_setup(void)
 {
 	unsigned long pfn;
-	unsigned long reservedpages = 0;
 
 	for (pfn = max_low_pfn; pfn < max_pfn; ++pfn) {
 		struct page *page = pfn_to_page(pfn);
 
 		/* FIXME not sure about */
-		if (memblock_is_reserved(pfn << PAGE_SHIFT))
-			continue;
-		free_highmem_page(page);
-		reservedpages++;
+		if (!memblock_is_reserved(pfn << PAGE_SHIFT))
+			free_highmem_page(page);
 	}
-	printk(KERN_INFO "High memory: %luk\n",
-					totalhigh_pages << (PAGE_SHIFT-10));
-
-	return reservedpages;
 }
 #endif /* CONFIG_HIGHMEM */
 
@@ -167,13 +160,12 @@ void __init setup_memory(void)
 	 * min_low_pfn - the first page (mm/bootmem.c - node_boot_start)
 	 * max_low_pfn
 	 * max_mapnr - the first unused page (mm/bootmem.c - node_low_pfn)
-	 * num_physpages - number of all pages
 	 */
 
 	/* memory start is from the kernel end (aligned) to higher addr */
 	min_low_pfn = memory_start >> PAGE_SHIFT; /* minimum for allocation */
 	/* RAM is assumed contiguous */
-	num_physpages = max_mapnr = memory_size >> PAGE_SHIFT;
+	max_mapnr = memory_size >> PAGE_SHIFT;
 	max_low_pfn = ((u64)memory_start + (u64)lowmem_size) >> PAGE_SHIFT;
 	max_pfn = ((u64)memory_start + (u64)memory_size) >> PAGE_SHIFT;
 
@@ -246,46 +238,15 @@ void free_initmem(void)
 
 void __init mem_init(void)
 {
-	pg_data_t *pgdat;
-	unsigned long reservedpages = 0, codesize, initsize, datasize, bsssize;
-
 	high_memory = (void *)__va(memory_start + lowmem_size - 1);
 
 	/* this will put all memory onto the freelists */
 	free_all_bootmem();
-
-	for_each_online_pgdat(pgdat) {
-		unsigned long i;
-		struct page *page;
-
-		for (i = 0; i < pgdat->node_spanned_pages; i++) {
-			if (!pfn_valid(pgdat->node_start_pfn + i))
-				continue;
-			page = pgdat_page_nr(pgdat, i);
-			if (PageReserved(page))
-				reservedpages++;
-		}
-	}
-
 #ifdef CONFIG_HIGHMEM
-	reservedpages -= highmem_setup();
+	highmem_setup();
 #endif
 
-	codesize = (unsigned long)&_sdata - (unsigned long)&_stext;
-	datasize = (unsigned long)&_edata - (unsigned long)&_sdata;
-	initsize = (unsigned long)&__init_end - (unsigned long)&__init_begin;
-	bsssize = (unsigned long)&__bss_stop - (unsigned long)&__bss_start;
-
-	pr_info("Memory: %luk/%luk available (%luk kernel code, "
-		"%luk reserved, %luk data, %luk bss, %luk init)\n",
-		nr_free_pages() << (PAGE_SHIFT-10),
-		num_physpages << (PAGE_SHIFT-10),
-		codesize >> 10,
-		reservedpages << (PAGE_SHIFT-10),
-		datasize >> 10,
-		bsssize >> 10,
-		initsize >> 10);
-
+	mem_init_print_info(str);
 #ifdef CONFIG_MMU
 	pr_info("Kernel virtual memory layout:\n");
 	pr_info("  * 0x%08lx..0x%08lx  : fixmap\n", FIXADDR_START, FIXADDR_TOP);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
