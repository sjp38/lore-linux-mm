Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 3749A6B00E6
	for <linux-mm@kvack.org>; Wed, 29 May 2013 09:59:19 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w11so5879484pde.9
        for <linux-mm@kvack.org>; Wed, 29 May 2013 06:59:18 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v6, part4 19/41] mm/frv: prepare for removing num_physpages and simplify mem_init()
Date: Wed, 29 May 2013 21:57:37 +0800
Message-Id: <1369835879-23553-20-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1369835879-23553-1-git-send-email-jiang.liu@huawei.com>
References: <1369835879-23553-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: David Howells <dhowells@redhat.com>
Cc: Andi Kleen <ak@linux.intel.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org
---
 arch/frv/kernel/setup.c | 13 +++++++------
 arch/frv/mm/init.c      | 49 ++++++++++++++-----------------------------------
 2 files changed, 21 insertions(+), 41 deletions(-)

diff --git a/arch/frv/kernel/setup.c b/arch/frv/kernel/setup.c
index a513647..f78f8cb 100644
--- a/arch/frv/kernel/setup.c
+++ b/arch/frv/kernel/setup.c
@@ -876,6 +876,7 @@ late_initcall(setup_arch_serial);
 static void __init setup_linux_memory(void)
 {
 	unsigned long bootmap_size, low_top_pfn, kstart, kend, high_mem;
+	unsigned long physpages;
 
 	kstart	= (unsigned long) &__kernel_image_start - PAGE_OFFSET;
 	kend	= (unsigned long) &__kernel_image_end - PAGE_OFFSET;
@@ -893,19 +894,19 @@ static void __init setup_linux_memory(void)
 					 );
 
 	/* pass the memory that the kernel can immediately use over to the bootmem allocator */
-	max_mapnr = num_physpages = (memory_end - memory_start) >> PAGE_SHIFT;
+	max_mapnr = physpages = (memory_end - memory_start) >> PAGE_SHIFT;
 	low_top_pfn = (KERNEL_LOWMEM_END - KERNEL_LOWMEM_START) >> PAGE_SHIFT;
 	high_mem = 0;
 
-	if (num_physpages > low_top_pfn) {
+	if (physpages > low_top_pfn) {
 #ifdef CONFIG_HIGHMEM
-		high_mem = num_physpages - low_top_pfn;
+		high_mem = physpages - low_top_pfn;
 #else
-		max_mapnr = num_physpages = low_top_pfn;
+		max_mapnr = physpages = low_top_pfn;
 #endif
 	}
 	else {
-		low_top_pfn = num_physpages;
+		low_top_pfn = physpages;
 	}
 
 	min_low_pfn = memory_start >> PAGE_SHIFT;
@@ -979,7 +980,7 @@ static void __init setup_uclinux_memory(void)
 	free_bootmem(memory_start, memory_end - memory_start);
 
 	high_memory = (void *) (memory_end & PAGE_MASK);
-	max_mapnr = num_physpages = ((unsigned long) high_memory - PAGE_OFFSET) >> PAGE_SHIFT;
+	max_mapnr = ((unsigned long) high_memory - PAGE_OFFSET) >> PAGE_SHIFT;
 
 	min_low_pfn = memory_start >> PAGE_SHIFT;
 	max_low_pfn = memory_end >> PAGE_SHIFT;
diff --git a/arch/frv/mm/init.c b/arch/frv/mm/init.c
index 3dcc888..88a1597 100644
--- a/arch/frv/mm/init.c
+++ b/arch/frv/mm/init.c
@@ -78,7 +78,7 @@ void __init paging_init(void)
 	memset((void *) empty_zero_page, 0, PAGE_SIZE);
 
 #ifdef CONFIG_HIGHMEM
-	if (num_physpages - num_mappedpages) {
+	if (get_num_physpages() - num_mappedpages) {
 		pgd_t *pge;
 		pud_t *pue;
 		pmd_t *pme;
@@ -96,7 +96,7 @@ void __init paging_init(void)
 	 */
 	zones_size[ZONE_NORMAL]  = max_low_pfn - min_low_pfn;
 #ifdef CONFIG_HIGHMEM
-	zones_size[ZONE_HIGHMEM] = num_physpages - num_mappedpages;
+	zones_size[ZONE_HIGHMEM] = get_num_physpages() - num_mappedpages;
 #endif
 
 	free_area_init(zones_size);
@@ -114,45 +114,24 @@ void __init paging_init(void)
  */
 void __init mem_init(void)
 {
-	unsigned long npages = (memory_end - memory_start) >> PAGE_SHIFT;
-	unsigned long tmp;
-#ifdef CONFIG_MMU
-	unsigned long loop, pfn;
-	int datapages = 0;
-#endif
-	int codek = 0, datak = 0;
+	unsigned long code_size = _etext - _stext;
 
 	/* this will put all low memory onto the freelists */
 	free_all_bootmem();
+#if defined(CONFIG_MMU) && defined(CONFIG_HIGHMEM)
+	{
+		unsigned long pfn;
 
-#ifdef CONFIG_MMU
-	for (loop = 0 ; loop < npages ; loop++)
-		if (PageReserved(&mem_map[loop]))
-			datapages++;
-
-#ifdef CONFIG_HIGHMEM
-	for (pfn = num_physpages - 1; pfn >= num_mappedpages; pfn--)
-		free_highmem_page(&mem_map[pfn]);
-#endif
-
-	codek = ((unsigned long) &_etext - (unsigned long) &_stext) >> 10;
-	datak = datapages << (PAGE_SHIFT - 10);
-
-#else
-	codek = (_etext - _stext) >> 10;
-	datak = 0; //(__bss_stop - _sdata) >> 10;
+		for (pfn = get_num_physpages() - 1;
+		     pfn >= num_mappedpages; pfn--)
+			free_highmem_page(&mem_map[pfn]);
+	}
 #endif
 
-	tmp = nr_free_pages() << PAGE_SHIFT;
-	printk("Memory available: %luKiB/%luKiB RAM, %luKiB/%luKiB ROM (%dKiB kernel code, %dKiB data)\n",
-	       tmp >> 10,
-	       npages << (PAGE_SHIFT - 10),
-	       (rom_length > 0) ? ((rom_length >> 10) - codek) : 0,
-	       rom_length >> 10,
-	       codek,
-	       datak
-	       );
-
+	mem_init_print_info(NULL);
+	if (rom_length > 0 && rom_length >= code_size)
+		printk("Memory available:  %luKiB/%luKiB ROM\n",
+			(rom_length - code_size) >> 10, rom_length >> 10);
 } /* end mem_init() */
 
 /*****************************************************************************/
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
