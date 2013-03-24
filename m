Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 1727D6B00D4
	for <linux-mm@kvack.org>; Sun, 24 Mar 2013 03:35:00 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id kp14so290106pab.22
        for <linux-mm@kvack.org>; Sun, 24 Mar 2013 00:34:59 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v2, part4 34/39] mm/unicore32: prepare for removing num_physpages and simplify mem_init()
Date: Sun, 24 Mar 2013 15:25:26 +0800
Message-Id: <1364109934-7851-61-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com>
References: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org
---
 arch/unicore32/mm/init.c |   49 ++--------------------------------------------
 1 file changed, 2 insertions(+), 47 deletions(-)

diff --git a/arch/unicore32/mm/init.c b/arch/unicore32/mm/init.c
index 119b9e8..39a967a 100644
--- a/arch/unicore32/mm/init.c
+++ b/arch/unicore32/mm/init.c
@@ -383,10 +383,6 @@ static void __init free_unused_memmap(struct meminfo *mi)
  */
 void __init mem_init(void)
 {
-	unsigned long reserved_pages, free_pages;
-	struct memblock_region *reg;
-	int i;
-
 	max_mapnr   = pfn_to_page(max_pfn + PHYS_PFN_OFFSET) - mem_map;
 
 	free_unused_memmap(&meminfo);
@@ -394,48 +390,7 @@ void __init mem_init(void)
 	/* this will put all unused low memory onto the freelists */
 	free_all_bootmem();
 
-	reserved_pages = free_pages = 0;
-
-	for_each_bank(i, &meminfo) {
-		struct membank *bank = &meminfo.bank[i];
-		unsigned int pfn1, pfn2;
-		struct page *page, *end;
-
-		pfn1 = bank_pfn_start(bank);
-		pfn2 = bank_pfn_end(bank);
-
-		page = pfn_to_page(pfn1);
-		end  = pfn_to_page(pfn2 - 1) + 1;
-
-		do {
-			if (PageReserved(page))
-				reserved_pages++;
-			else if (!page_count(page))
-				free_pages++;
-			page++;
-		} while (page < end);
-	}
-
-	/*
-	 * Since our memory may not be contiguous, calculate the
-	 * real number of pages we have in this system
-	 */
-	printk(KERN_INFO "Memory:");
-	num_physpages = 0;
-	for_each_memblock(memory, reg) {
-		unsigned long pages = memblock_region_memory_end_pfn(reg) -
-			memblock_region_memory_base_pfn(reg);
-		num_physpages += pages;
-		printk(" %ldMB", pages >> (20 - PAGE_SHIFT));
-	}
-	printk(" = %luMB total\n", num_physpages >> (20 - PAGE_SHIFT));
-
-	printk(KERN_NOTICE "Memory: %luk/%luk available, %luk reserved, %luK highmem\n",
-		nr_free_pages() << (PAGE_SHIFT-10),
-		free_pages << (PAGE_SHIFT-10),
-		reserved_pages << (PAGE_SHIFT-10),
-		totalhigh_pages << (PAGE_SHIFT-10));
-
+	mem_init_print_info(NULL);
 	printk(KERN_NOTICE "Virtual kernel memory layout:\n"
 		"    vector  : 0x%08lx - 0x%08lx   (%4ld kB)\n"
 		"    vmalloc : 0x%08lx - 0x%08lx   (%4ld MB)\n"
@@ -464,7 +419,7 @@ void __init mem_init(void)
 	BUILD_BUG_ON(TASK_SIZE				> MODULES_VADDR);
 	BUG_ON(TASK_SIZE				> MODULES_VADDR);
 
-	if (PAGE_SIZE >= 16384 && num_physpages <= 128) {
+	if (PAGE_SIZE >= 16384 && get_num_physpages() <= 128) {
 		/*
 		 * On a machine this small we won't get
 		 * anywhere without overcommit, so turn
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
