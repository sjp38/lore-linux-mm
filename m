Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 17D376B00FB
	for <linux-mm@kvack.org>; Wed, 29 May 2013 09:59:58 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id q11so8918550pdj.10
        for <linux-mm@kvack.org>; Wed, 29 May 2013 06:59:57 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v6, part4 30/41] mm/PARISC: prepare for removing num_physpages and simplify mem_init()
Date: Wed, 29 May 2013 21:57:48 +0800
Message-Id: <1369835879-23553-31-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1369835879-23553-1-git-send-email-jiang.liu@huawei.com>
References: <1369835879-23553-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Thomas Gleixner <tglx@linutronix.de>, linux-parisc@vger.kernel.org

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: "James E.J. Bottomley" <jejb@parisc-linux.org>
Cc: Helge Deller <deller@gmx.de>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: David Rientjes <rientjes@google.com>
Cc: linux-parisc@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 arch/parisc/mm/init.c | 47 +++--------------------------------------------
 1 file changed, 3 insertions(+), 44 deletions(-)

diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
index 74608f7..3f31102 100644
--- a/arch/parisc/mm/init.c
+++ b/arch/parisc/mm/init.c
@@ -214,7 +214,6 @@ static void __init setup_bootmem(void)
 	mem_limit_func();       /* check for "mem=" argument */
 
 	mem_max = 0;
-	num_physpages = 0;
 	for (i = 0; i < npmem_ranges; i++) {
 		unsigned long rsize;
 
@@ -229,10 +228,8 @@ static void __init setup_bootmem(void)
 				npmem_ranges = i + 1;
 				mem_max = mem_limit;
 			}
-	        num_physpages += pmem_ranges[i].pages;
 			break;
 		}
-	    num_physpages += pmem_ranges[i].pages;
 		mem_max += rsize;
 	}
 
@@ -532,7 +529,7 @@ void free_initmem(void)
 	 * pages are no-longer executable */
 	flush_icache_range(init_begin, init_end);
 	
-	num_physpages += free_initmem_default(-1);
+	free_initmem_default(-1);
 
 	/* set up a new led state on systems shipped LED State panel */
 	pdc_chassis_send_status(PDC_CHASSIS_DIRECT_BCOMPLETE);
@@ -580,8 +577,6 @@ unsigned long pcxl_dma_start __read_mostly;
 
 void __init mem_init(void)
 {
-	int codesize, reservedpages, datasize, initsize;
-
 	/* Do sanity checks on page table constants */
 	BUILD_BUG_ON(PTE_ENTRY_SIZE != sizeof(pte_t));
 	BUILD_BUG_ON(PMD_ENTRY_SIZE != sizeof(pmd_t));
@@ -603,33 +598,6 @@ void __init mem_init(void)
 	}
 #endif
 
-	codesize = (unsigned long)_etext - (unsigned long)_text;
-	datasize = (unsigned long)_edata - (unsigned long)_etext;
-	initsize = (unsigned long)__init_end - (unsigned long)__init_begin;
-
-	reservedpages = 0;
-{
-	unsigned long pfn;
-#ifdef CONFIG_DISCONTIGMEM
-	int i;
-
-	for (i = 0; i < npmem_ranges; i++) {
-		for (pfn = node_start_pfn(i); pfn < node_end_pfn(i); pfn++) {
-			if (PageReserved(pfn_to_page(pfn)))
-				reservedpages++;
-		}
-	}
-#else /* !CONFIG_DISCONTIGMEM */
-	for (pfn = 0; pfn < max_pfn; pfn++) {
-		/*
-		 * Only count reserved RAM pages
-		 */
-		if (PageReserved(pfn_to_page(pfn)))
-			reservedpages++;
-	}
-#endif
-}
-
 #ifdef CONFIG_PA11
 	if (hppa_dma_ops == &pcxl_dma_ops) {
 		pcxl_dma_start = (unsigned long)SET_MAP_OFFSET(MAP_START);
@@ -643,15 +611,7 @@ void __init mem_init(void)
 	parisc_vmalloc_start = SET_MAP_OFFSET(MAP_START);
 #endif
 
-	printk(KERN_INFO "Memory: %luk/%luk available (%dk kernel code, %dk reserved, %dk data, %dk init)\n",
-		nr_free_pages() << (PAGE_SHIFT-10),
-		num_physpages << (PAGE_SHIFT-10),
-		codesize >> 10,
-		reservedpages << (PAGE_SHIFT-10),
-		datasize >> 10,
-		initsize >> 10
-	);
-
+	mem_init_print_info(NULL);
 #ifdef CONFIG_DEBUG_KERNEL /* double-sanity-check paranoia */
 	printk("virtual kernel memory layout:\n"
 	       "    vmalloc : 0x%p - 0x%p   (%4ld MB)\n"
@@ -1101,7 +1061,6 @@ void flush_tlb_all(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	num_physpages += free_reserved_area((void *)start, (void *)end, -1,
-					    "initrd");
+	free_reserved_area((void *)start, (void *)end, -1, "initrd");
 }
 #endif
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
