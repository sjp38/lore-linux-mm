Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id CE7556B0124
	for <linux-mm@kvack.org>; Wed,  8 May 2013 11:57:33 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id up7so1308313pbc.29
        for <linux-mm@kvack.org>; Wed, 08 May 2013 08:57:33 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v5, part4 39/41] mm/x86: prepare for removing num_physpages and simplify mem_init()
Date: Wed,  8 May 2013 23:51:36 +0800
Message-Id: <1368028298-7401-40-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1368028298-7401-1-git-send-email-jiang.liu@huawei.com>
References: <1368028298-7401-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andreas Herrmann <andreas.herrmann3@amd.com>, Tang Chen <tangchen@cn.fujitsu.com>

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
index 5013a48..c587a87 100644
--- a/arch/x86/kernel/cpu/amd.c
+++ b/arch/x86/kernel/cpu/amd.c
@@ -90,7 +90,7 @@ static void __cpuinit init_amd_k5(struct cpuinfo_x86 *c)
 static void __cpuinit init_amd_k6(struct cpuinfo_x86 *c)
 {
 	u32 l, h;
-	int mbytes = num_physpages >> (20-PAGE_SHIFT);
+	int mbytes = get_num_physpages() >> (20-PAGE_SHIFT);
 
 	if (c->x86_model < 6) {
 		/* Based on AMD doc 20734R - June 2000 */
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index c8dbdfd..58f1a8ad 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1041,8 +1041,6 @@ void __init setup_arch(char **cmdline_p)
 	/* max_low_pfn get updated here */
 	find_low_pfn_range();
 #else
-	num_physpages = max_pfn;
-
 	check_x2apic();
 
 	/* How many end-of-memory variables you have, grandma! */
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 9fa46ba..4287f1f 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -660,10 +660,8 @@ void __init initmem_init(void)
 		highstart_pfn = max_low_pfn;
 	printk(KERN_NOTICE "%ldMB HIGHMEM available.\n",
 		pages_to_mb(highend_pfn - highstart_pfn));
-	num_physpages = highend_pfn;
 	high_memory = (void *) __va(highstart_pfn * PAGE_SIZE - 1) + 1;
 #else
-	num_physpages = max_low_pfn;
 	high_memory = (void *) __va(max_low_pfn * PAGE_SIZE - 1) + 1;
 #endif
 
@@ -671,7 +669,7 @@ void __init initmem_init(void)
 	sparse_memory_present_with_active_regions(0);
 
 #ifdef CONFIG_FLATMEM
-	max_mapnr = num_physpages;
+	max_mapnr = IS_ENABLED(CONFIG_HIGHMEM) ? highend_pfn : max_low_pfn;
 #endif
 	__vmalloc_start_set = true;
 
@@ -739,9 +737,6 @@ static void __init test_wp_bit(void)
 
 void __init mem_init(void)
 {
-	int codesize, reservedpages, datasize, initsize;
-	int tmp;
-
 	pci_iommu_alloc();
 
 #ifdef CONFIG_FLATMEM
@@ -761,30 +756,9 @@ void __init mem_init(void)
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
 	after_bootmem = 1;
 
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
index 65116e5..650264b 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1043,9 +1043,6 @@ static void __init register_page_bootmem_info(void)
 
 void __init mem_init(void)
 {
-	long codesize, reservedpages, datasize, initsize;
-	unsigned long absent_pages;
-
 	pci_iommu_alloc();
 
 	/* clear_bss() already clear the empty_zero_page */
@@ -1054,28 +1051,13 @@ void __init mem_init(void)
 
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
index 73a6d73..0342d27 100644
--- a/arch/x86/mm/numa_32.c
+++ b/arch/x86/mm/numa_32.c
@@ -83,10 +83,8 @@ void __init initmem_init(void)
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
