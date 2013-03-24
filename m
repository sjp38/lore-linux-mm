Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 701A56B0069
	for <linux-mm@kvack.org>; Sun, 24 Mar 2013 03:29:25 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rp2so3677338pbb.34
        for <linux-mm@kvack.org>; Sun, 24 Mar 2013 00:29:24 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v2, part4 13/39] mm/blackfin: prepare for removing num_physpages and simplify mem_init()
Date: Sun, 24 Mar 2013 15:24:44 +0800
Message-Id: <1364109934-7851-19-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com>
References: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Frysinger <vapier@gentoo.org>, Bob Liu <lliubbo@gmail.com>, uclinux-dist-devel@blackfin.uclinux.org

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Mike Frysinger <vapier@gentoo.org>
Cc: Bob Liu <lliubbo@gmail.com>
Cc: uclinux-dist-devel@blackfin.uclinux.org
Cc: linux-kernel@vger.kernel.org
---
 arch/blackfin/mm/init.c |   38 ++++++--------------------------------
 1 file changed, 6 insertions(+), 32 deletions(-)

diff --git a/arch/blackfin/mm/init.c b/arch/blackfin/mm/init.c
index 1cc8607..e4b6e11 100644
--- a/arch/blackfin/mm/init.c
+++ b/arch/blackfin/mm/init.c
@@ -90,43 +90,17 @@ asmlinkage void __init init_pda(void)
 
 void __init mem_init(void)
 {
-	unsigned int codek = 0, datak = 0, initk = 0;
-	unsigned int reservedpages = 0, freepages = 0;
-	unsigned long tmp;
-	unsigned long start_mem = memory_start;
-	unsigned long end_mem = memory_end;
+	char buf[64];
 
-	end_mem &= PAGE_MASK;
-	high_memory = (void *)end_mem;
-
-	start_mem = PAGE_ALIGN(start_mem);
-	max_mapnr = num_physpages = MAP_NR(high_memory);
-	printk(KERN_DEBUG "Kernel managed physical pages: %lu\n", num_physpages);
+	high_memory = (void *)(memory_end & PAGE_MASK);
+	max_mapnr = MAP_NR(high_memory);
+	printk(KERN_DEBUG "Kernel managed physical pages: %lu\n", max_mapnr);
 
 	/* This will put all low memory onto the freelists. */
 	free_all_bootmem();
 
-	reservedpages = 0;
-	for (tmp = ARCH_PFN_OFFSET; tmp < max_mapnr; tmp++)
-		if (PageReserved(pfn_to_page(tmp)))
-			reservedpages++;
-	freepages =  max_mapnr - ARCH_PFN_OFFSET - reservedpages;
-
-	/* do not count in kernel image between _rambase and _ramstart */
-	reservedpages -= (_ramstart - _rambase) >> PAGE_SHIFT;
-#if (defined(CONFIG_BFIN_EXTMEM_ICACHEABLE) && ANOMALY_05000263)
-	reservedpages += (_ramend - memory_end - DMA_UNCACHED_REGION) >> PAGE_SHIFT;
-#endif
-
-	codek = (_etext - _stext) >> 10;
-	initk = (__init_end - __init_begin) >> 10;
-	datak = ((_ramstart - _rambase) >> 10) - codek - initk;
-
-	printk(KERN_INFO
-	     "Memory available: %luk/%luk RAM, "
-		"(%uk init code, %uk kernel code, %uk data, %uk dma, %uk reserved)\n",
-		(unsigned long) freepages << (PAGE_SHIFT-10), (_ramend - CONFIG_PHY_RAM_BASE_ADDRESS) >> 10,
-		initk, codek, datak, DMA_UNCACHED_REGION >> 10, (reservedpages << (PAGE_SHIFT-10)));
+	snprintf(buf, sizeof(buf) - 1, "%uK DMA", DMA_UNCACHED_REGION >> 10);
+	mem_init_print_info(buf);
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
