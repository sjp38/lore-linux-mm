Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 505256B00EE
	for <linux-mm@kvack.org>; Sun, 24 Mar 2013 03:42:47 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id q10so2110791pdj.40
        for <linux-mm@kvack.org>; Sun, 24 Mar 2013 00:42:46 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v2, part4 36/39] mm/x86: prepare for removing num_physpages and simplify mem_init()
Date: Sun, 24 Mar 2013 15:40:36 +0800
Message-Id: <1364110839-8172-3-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1364110839-8172-1-git-send-email-jiang.liu@huawei.com>
References: <1364110839-8172-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andreas Herrmann <andreas.herrmann3@amd.com>, Tang Chen <tangchen@cn.fujitsu.com>

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Cc: Andreas Herrmann <andreas.herrmann3@amd.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>
Cc: Jianguo Wu <wujianguo@huawei.com>
Cc: linux-kernel@vger.kernel.org
---
 arch/x86/kernel/cpu/amd.c |    2 +-
 arch/x86/kernel/setup.c   |    2 --
 arch/x86/mm/init_32.c     |   30 ++----------------------------
 arch/x86/mm/init_64.c     |   20 +-------------------
 arch/x86/mm/numa_32.c     |    2 --
 5 files changed, 4 insertions(+), 52 deletions(-)

diff --git a/arch/x86/kernel/cpu/amd.c b/arch/x86/kernel/cpu/amd.c
index 15239ff..3465db2 100644
--- a/arch/x86/kernel/cpu/amd.c
+++ b/arch/x86/kernel/cpu/amd.c
@@ -91,7 +91,7 @@ static void __cpuinit init_amd_k5(struct cpuinfo_x86 *c)
 static void __cpuinit init_amd_k6(struct cpuinfo_x86 *c)
 {
 	u32 l, h;
-	int mbytes = num_physpages >> (20-PAGE_SHIFT);
+	int mbytes = get_num_physpages() >> (20-PAGE_SHIFT);
 
 	if (c->x86_model < 6) {
 		/* Based on AMD doc 20734R - June 2000 */
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 342b1a7..5e5e26e 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -934,8 +934,6 @@ void __init setup_arch(char **cmdline_p)
 	/* max_low_pfn get updated here */
 	find_low_pfn_range();
 #else
-	num_physpages = max_pfn;
-
 	check_x2apic();
 
 	/* How many end-of-memory variables you have, grandma! */
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 857032c..62e8920 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -634,10 +634,8 @@ void __init initmem_init(void)
 		highstart_pfn = max_low_pfn;
 	printk(KERN_NOTICE "%ldMB HIGHMEM available.\n",
 		pages_to_mb(highend_pfn - highstart_pfn));
-	num_physpages = highend_pfn;
 	high_memory = (void *) __va(highstart_pfn * PAGE_SIZE - 1) + 1;
 #else
-	num_physpages = max_low_pfn;
 	high_memory = (void *) __va(max_low_pfn * PAGE_SIZE - 1) + 1;
 #endif
 
@@ -645,7 +643,7 @@ void __init initmem_init(void)
 	sparse_memory_present_with_active_regions(0);
 
 #ifdef CONFIG_FLATMEM
-	max_mapnr = num_physpages;
+	max_mapnr = IS_ENABLED(CONFIG_HIGHMEM) ? highend_pfn : max_low_pfn;
 #endif
 	__vmalloc_start_set = true;
 
@@ -715,9 +713,6 @@ static void __init test_wp_bit(void)
 
 void __init mem_init(void)
 {
-	int codesize, reservedpages, datasize, initsize;
-	int tmp;
-
 	pci_iommu_alloc();
 
 #ifdef CONFIG_FLATMEM
@@ -737,28 +732,7 @@ void __init mem_init(void)
 	/* this will put all low memory onto the freelists */
 	free_all_bootmem();
 
-	reservedpages = 0;
-	for (tmp = 0; tmp < max_low_pfn; tmp++)
-		/*
-		 * Only count reserved RAM pages:
-		 */
-		if (page_is_ram(tmp) && PageReserved(pfn_to_page(tmp)))
-			reservedpages++;
-
-	codesize =  (unsigned long) &_etext - (unsigned long) &_text;
-	datasize =  (unsigned long) &_edata - (unsigned long) &_etext;
-	initsize =  (unsigned long) &__init_end - (unsigned long) &__init_begin;
-
-	printk(KERN_INFO "Memory: %luk/%luk available (%dk kernel code, "
-			"%dk reserved, %dk data, %dk init, %ldk highmem)\n",
-		nr_free_pages() << (PAGE_SHIFT-10),
-		num_physpages << (PAGE_SHIFT-10),
-		codesize >> 10,
-		reservedpages << (PAGE_SHIFT-10),
-		datasize >> 10,
-		initsize >> 10,
-		totalhigh_pages << (PAGE_SHIFT-10));
-
+	mem_init_print_info(NULL);
 	printk(KERN_INFO "virtual kernel memory layout:\n"
 		"    fixmap  : 0x%08lx - 0x%08lx   (%4ld kB)\n"
 #ifdef CONFIG_HIGHMEM
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index f524138..a1c1db1 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1029,9 +1029,6 @@ static void __init register_page_bootmem_info(void)
 
 void __init mem_init(void)
 {
-	long codesize, reservedpages, datasize, initsize;
-	unsigned long absent_pages;
-
 	pci_iommu_alloc();
 
 	/* clear_bss() already clear the empty_zero_page */
@@ -1040,28 +1037,13 @@ void __init mem_init(void)
 
 	/* this will put all memory onto the freelists */
 	free_all_bootmem();
-
-	absent_pages = absent_pages_in_range(0, max_pfn);
-	reservedpages = max_pfn - totalram_pages - absent_pages;
 	after_bootmem = 1;
 
-	codesize =  (unsigned long) &_etext - (unsigned long) &_text;
-	datasize =  (unsigned long) &_edata - (unsigned long) &_etext;
-	initsize =  (unsigned long) &__init_end - (unsigned long) &__init_begin;
-
 	/* Register memory areas for /proc/kcore */
 	kclist_add(&kcore_vsyscall, (void *)VSYSCALL_START,
 			 VSYSCALL_END - VSYSCALL_START, KCORE_OTHER);
 
-	printk(KERN_INFO "Memory: %luk/%luk available (%ldk kernel code, "
-			 "%ldk absent, %ldk reserved, %ldk data, %ldk init)\n",
-		nr_free_pages() << (PAGE_SHIFT-10),
-		max_pfn << (PAGE_SHIFT-10),
-		codesize >> 10,
-		absent_pages << (PAGE_SHIFT-10),
-		reservedpages << (PAGE_SHIFT-10),
-		datasize >> 10,
-		initsize >> 10);
+	mem_init_print_info(NULL);
 }
 
 #ifdef CONFIG_DEBUG_RODATA
diff --git a/arch/x86/mm/numa_32.c b/arch/x86/mm/numa_32.c
index 534255a..dc32528 100644
--- a/arch/x86/mm/numa_32.c
+++ b/arch/x86/mm/numa_32.c
@@ -244,10 +244,8 @@ void __init initmem_init(void)
 		highstart_pfn = max_low_pfn;
 	printk(KERN_NOTICE "%ldMB HIGHMEM available.\n",
 	       pages_to_mb(highend_pfn - highstart_pfn));
-	num_physpages = highend_pfn;
 	high_memory = (void *) __va(highstart_pfn * PAGE_SIZE - 1) + 1;
 #else
-	num_physpages = max_low_pfn;
 	high_memory = (void *) __va(max_low_pfn * PAGE_SIZE - 1) + 1;
 #endif
 	printk(KERN_NOTICE "%ldMB LOWMEM available.\n",
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
