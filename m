Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 3E7CB6B016A
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 09:57:58 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rq13so2464798pbb.20
        for <linux-mm@kvack.org>; Sat, 06 Apr 2013 06:57:57 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v4, part3 14/15] mm: concentrate modification of totalram_pages into the mm core
Date: Sat,  6 Apr 2013 21:55:08 +0800
Message-Id: <1365256509-29024-15-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1365256509-29024-1-git-send-email-jiang.liu@huawei.com>
References: <1365256509-29024-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Concentrate code to modify totalram_pages into the mm core, so the arch
memory initialized code doesn't need to take care of it. With these
changes applied, only following functions from mm core modify global
variable totalram_pages:
free_bootmem_late(), free_all_bootmem(), free_all_bootmem_node(),
adjust_managed_page_count().

With this patch applied, it will be much more easier for us to keep
totalram_pages and zone->managed_pages in consistence.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 arch/alpha/mm/init.c             |    2 +-
 arch/alpha/mm/numa.c             |    2 +-
 arch/arc/mm/init.c               |    2 +-
 arch/arm/mm/init.c               |    3 +--
 arch/arm64/mm/init.c             |    2 +-
 arch/avr32/mm/init.c             |    2 --
 arch/blackfin/mm/init.c          |    2 +-
 arch/c6x/mm/init.c               |    2 +-
 arch/cris/mm/init.c              |    2 +-
 arch/frv/mm/init.c               |    2 +-
 arch/h8300/mm/init.c             |    2 +-
 arch/hexagon/mm/init.c           |    3 +--
 arch/ia64/mm/init.c              |    2 +-
 arch/m32r/mm/init.c              |    2 +-
 arch/m68k/mm/init.c              |    4 ++--
 arch/metag/mm/init.c             |    5 +----
 arch/microblaze/mm/init.c        |    2 +-
 arch/mips/mm/init.c              |    2 +-
 arch/mips/sgi-ip27/ip27-memory.c |    2 +-
 arch/mn10300/mm/init.c           |    2 +-
 arch/openrisc/mm/init.c          |    2 +-
 arch/parisc/mm/init.c            |    4 ++--
 arch/powerpc/mm/mem.c            |    5 ++---
 arch/s390/mm/init.c              |    2 +-
 arch/score/mm/init.c             |    2 +-
 arch/sh/mm/init.c                |    2 +-
 arch/sparc/mm/init_32.c          |    3 +--
 arch/sparc/mm/init_64.c          |    2 +-
 arch/tile/mm/init.c              |    2 +-
 arch/um/kernel/mem.c             |    2 +-
 arch/unicore32/mm/init.c         |    2 +-
 arch/x86/mm/init_32.c            |    2 +-
 arch/x86/mm/init_64.c            |    2 +-
 arch/xtensa/mm/init.c            |    2 +-
 mm/bootmem.c                     |    9 ++++++++-
 mm/nobootmem.c                   |    7 ++++++-
 36 files changed, 50 insertions(+), 47 deletions(-)

diff --git a/arch/alpha/mm/init.c b/arch/alpha/mm/init.c
index 9930837..ca07a97 100644
--- a/arch/alpha/mm/init.c
+++ b/arch/alpha/mm/init.c
@@ -309,7 +309,7 @@ void __init
 mem_init(void)
 {
 	max_mapnr = num_physpages = max_low_pfn;
-	totalram_pages += free_all_bootmem();
+	free_all_bootmem();
 	high_memory = (void *) __va(max_low_pfn * PAGE_SIZE);
 
 	printk_memory_info();
diff --git a/arch/alpha/mm/numa.c b/arch/alpha/mm/numa.c
index 3388504..857452c 100644
--- a/arch/alpha/mm/numa.c
+++ b/arch/alpha/mm/numa.c
@@ -334,7 +334,7 @@ void __init mem_init(void)
 		/*
 		 * This will free up the bootmem, ie, slot 0 memory
 		 */
-		totalram_pages += free_all_bootmem_node(NODE_DATA(nid));
+		free_all_bootmem_node(NODE_DATA(nid));
 
 		pfn = NODE_DATA(nid)->node_start_pfn;
 		for (i = 0; i < node_spanned_pages(nid); i++, pfn++)
diff --git a/arch/arc/mm/init.c b/arch/arc/mm/init.c
index 4a17736..78d8c31 100644
--- a/arch/arc/mm/init.c
+++ b/arch/arc/mm/init.c
@@ -111,7 +111,7 @@ void __init mem_init(void)
 
 	high_memory = (void *)(CONFIG_LINUX_LINK_BASE + arc_mem_sz);
 
-	totalram_pages = free_all_bootmem();
+	free_all_bootmem();
 
 	/* count all reserved pages [kernel code/data/mem_map..] */
 	reserved_pages = 0;
diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index a2ab290..add4fcb 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -595,8 +595,7 @@ void __init mem_init(void)
 
 	/* this will put all unused low memory onto the freelists */
 	free_unused_memmap(&meminfo);
-
-	totalram_pages += free_all_bootmem();
+	free_all_bootmem();
 
 #ifdef CONFIG_SA1111
 	/* now that our DMA memory is actually so designated, we can free it */
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index b87bdb8..0f2cf5d 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -284,7 +284,7 @@ void __init mem_init(void)
 	free_unused_memmap();
 #endif
 
-	totalram_pages += free_all_bootmem();
+	free_all_bootmem();
 
 	reserved_pages = free_pages = 0;
 
diff --git a/arch/avr32/mm/init.c b/arch/avr32/mm/init.c
index 871f98a..7e8d55a 100644
--- a/arch/avr32/mm/init.c
+++ b/arch/avr32/mm/init.c
@@ -117,8 +117,6 @@ void __init mem_init(void)
 		if (pgdat->node_spanned_pages != 0)
 			node_pages = free_all_bootmem_node(pgdat);
 
-		totalram_pages += node_pages;
-
 		for (i = 0; i < node_pages; i++)
 			if (PageReserved(pgdat->node_mem_map + i))
 				reservedpages++;
diff --git a/arch/blackfin/mm/init.c b/arch/blackfin/mm/init.c
index e64286b..1cc8607 100644
--- a/arch/blackfin/mm/init.c
+++ b/arch/blackfin/mm/init.c
@@ -104,7 +104,7 @@ void __init mem_init(void)
 	printk(KERN_DEBUG "Kernel managed physical pages: %lu\n", num_physpages);
 
 	/* This will put all low memory onto the freelists. */
-	totalram_pages = free_all_bootmem();
+	free_all_bootmem();
 
 	reservedpages = 0;
 	for (tmp = ARCH_PFN_OFFSET; tmp < max_mapnr; tmp++)
diff --git a/arch/c6x/mm/init.c b/arch/c6x/mm/init.c
index ce39b48..2c51474 100644
--- a/arch/c6x/mm/init.c
+++ b/arch/c6x/mm/init.c
@@ -64,7 +64,7 @@ void __init mem_init(void)
 	high_memory = (void *)(memory_end & PAGE_MASK);
 
 	/* this will put all memory onto the freelists */
-	totalram_pages = free_all_bootmem();
+	free_all_bootmem();
 
 	codek = (_etext - _stext) >> 10;
 	datak = (_end - _sdata) >> 10;
diff --git a/arch/cris/mm/init.c b/arch/cris/mm/init.c
index 8fec263..52b8b56 100644
--- a/arch/cris/mm/init.c
+++ b/arch/cris/mm/init.c
@@ -33,7 +33,7 @@ mem_init(void)
 	max_mapnr = num_physpages = max_low_pfn - min_low_pfn;
  
 	/* this will put all memory onto the freelists */
-        totalram_pages = free_all_bootmem();
+        free_all_bootmem();
 
 	reservedpages = 0;
 	for (tmp = 0; tmp < max_mapnr; tmp++) {
diff --git a/arch/frv/mm/init.c b/arch/frv/mm/init.c
index a421948..4215822 100644
--- a/arch/frv/mm/init.c
+++ b/arch/frv/mm/init.c
@@ -123,7 +123,7 @@ void __init mem_init(void)
 	int codek = 0, datak = 0;
 
 	/* this will put all low memory onto the freelists */
-	totalram_pages = free_all_bootmem();
+	free_all_bootmem();
 
 #ifdef CONFIG_MMU
 	for (loop = 0 ; loop < npages ; loop++)
diff --git a/arch/h8300/mm/init.c b/arch/h8300/mm/init.c
index 488e2a3..22fd869 100644
--- a/arch/h8300/mm/init.c
+++ b/arch/h8300/mm/init.c
@@ -140,7 +140,7 @@ void __init mem_init(void)
 	max_mapnr = num_physpages = MAP_NR(high_memory);
 
 	/* this will put all low memory onto the freelists */
-	totalram_pages = free_all_bootmem();
+	free_all_bootmem();
 
 	codek = (_etext - _stext) >> 10;
 	datak = (__bss_stop - _sdata) >> 10;
diff --git a/arch/hexagon/mm/init.c b/arch/hexagon/mm/init.c
index 69ffcfd..c048d06e 100644
--- a/arch/hexagon/mm/init.c
+++ b/arch/hexagon/mm/init.c
@@ -69,8 +69,7 @@ unsigned long long kmap_generation;
  */
 void __init mem_init(void)
 {
-	/*  No idea where this is actually declared.  Seems to evade LXR.  */
-	totalram_pages += free_all_bootmem();
+	free_all_bootmem();
 	num_physpages = bootmem_lastpg;	/*  seriously, what?  */
 
 	printk(KERN_INFO "totalram_pages = %ld\n", totalram_pages);
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 941568a..b5b71e8 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -623,7 +623,7 @@ mem_init (void)
 
 	for_each_online_pgdat(pgdat)
 		if (pgdat->bdata->node_bootmem_map)
-			totalram_pages += free_all_bootmem_node(pgdat);
+			free_all_bootmem_node(pgdat);
 
 	reserved_pages = 0;
 	efi_memmap_walk(count_reserved_pages, &reserved_pages);
diff --git a/arch/m32r/mm/init.c b/arch/m32r/mm/init.c
index 58ea4d6..c421c31 100644
--- a/arch/m32r/mm/init.c
+++ b/arch/m32r/mm/init.c
@@ -158,7 +158,7 @@ void __init mem_init(void)
 
 	/* this will put all low memory onto the freelists */
 	for_each_online_node(nid)
-		totalram_pages += free_all_bootmem_node(NODE_DATA(nid));
+		free_all_bootmem_node(NODE_DATA(nid));
 
 	reservedpages = reservedpages_count() - hole_pages;
 	codesize = (unsigned long) &_etext - (unsigned long)&_text;
diff --git a/arch/m68k/mm/init.c b/arch/m68k/mm/init.c
index 75e1cbf..2485a8c 100644
--- a/arch/m68k/mm/init.c
+++ b/arch/m68k/mm/init.c
@@ -155,11 +155,11 @@ void __init mem_init(void)
 	int i;
 
 	/* this will put all memory onto the freelists */
-	totalram_pages = num_physpages = 0;
+	num_physpages = 0;
 	for_each_online_pgdat(pgdat) {
 		num_physpages += pgdat->node_present_pages;
 
-		totalram_pages += free_all_bootmem_node(pgdat);
+		free_all_bootmem_node(pgdat);
 		for (i = 0; i < pgdat->node_spanned_pages; i++) {
 			struct page *page = pgdat->node_mem_map + i;
 			char *addr = page_to_virt(page);
diff --git a/arch/metag/mm/init.c b/arch/metag/mm/init.c
index 58a36f3..279d701 100644
--- a/arch/metag/mm/init.c
+++ b/arch/metag/mm/init.c
@@ -393,14 +393,11 @@ void __init mem_init(void)
 
 	for_each_online_node(nid) {
 		pg_data_t *pgdat = NODE_DATA(nid);
-		unsigned long node_pages = 0;
 
 		num_physpages += pgdat->node_present_pages;
 
 		if (pgdat->node_spanned_pages)
-			node_pages = free_all_bootmem_node(pgdat);
-
-		totalram_pages += node_pages;
+			free_all_bootmem_node(pgdat);
 	}
 
 	pr_info("Memory: %luk/%luk available\n",
diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
index 53383e4..fb7f248 100644
--- a/arch/microblaze/mm/init.c
+++ b/arch/microblaze/mm/init.c
@@ -252,7 +252,7 @@ void __init mem_init(void)
 	high_memory = (void *)__va(memory_start + lowmem_size - 1);
 
 	/* this will put all memory onto the freelists */
-	totalram_pages += free_all_bootmem();
+	free_all_bootmem();
 
 	for_each_online_pgdat(pgdat) {
 		unsigned long i;
diff --git a/arch/mips/mm/init.c b/arch/mips/mm/init.c
index 3d0346d..de4ff2f 100644
--- a/arch/mips/mm/init.c
+++ b/arch/mips/mm/init.c
@@ -373,7 +373,7 @@ void __init mem_init(void)
 #endif
 	high_memory = (void *) __va(max_low_pfn << PAGE_SHIFT);
 
-	totalram_pages += free_all_bootmem();
+	free_all_bootmem();
 	setup_zero_pages();	/* Setup zeroed pages.  */
 
 	reservedpages = ram = 0;
diff --git a/arch/mips/sgi-ip27/ip27-memory.c b/arch/mips/sgi-ip27/ip27-memory.c
index 5f2bddb..936e617 100644
--- a/arch/mips/sgi-ip27/ip27-memory.c
+++ b/arch/mips/sgi-ip27/ip27-memory.c
@@ -489,7 +489,7 @@ void __init mem_init(void)
 		/*
 		 * This will free up the bootmem, ie, slot 0 memory.
 		 */
-		totalram_pages += free_all_bootmem_node(NODE_DATA(node));
+		free_all_bootmem_node(NODE_DATA(node));
 	}
 
 	setup_zero_pages();	/* This comes from node 0 */
diff --git a/arch/mn10300/mm/init.c b/arch/mn10300/mm/init.c
index 5a8ace6..d7312aa 100644
--- a/arch/mn10300/mm/init.c
+++ b/arch/mn10300/mm/init.c
@@ -114,7 +114,7 @@ void __init mem_init(void)
 	memset(empty_zero_page, 0, PAGE_SIZE);
 
 	/* this will put all low memory onto the freelists */
-	totalram_pages += free_all_bootmem();
+	free_all_bootmem();
 
 	reservedpages = 0;
 	for (tmp = 0; tmp < num_physpages; tmp++)
diff --git a/arch/openrisc/mm/init.c b/arch/openrisc/mm/init.c
index d19950c..da26482 100644
--- a/arch/openrisc/mm/init.c
+++ b/arch/openrisc/mm/init.c
@@ -207,7 +207,7 @@ static int __init free_pages_init(void)
 	int reservedpages, pfn;
 
 	/* this will put all low memory onto the freelists */
-	totalram_pages = free_all_bootmem();
+	free_all_bootmem();
 
 	reservedpages = 0;
 	for (pfn = 0; pfn < max_low_pfn; pfn++) {
diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
index 27f3f88..1fe9d841 100644
--- a/arch/parisc/mm/init.c
+++ b/arch/parisc/mm/init.c
@@ -593,13 +593,13 @@ void __init mem_init(void)
 
 #ifndef CONFIG_DISCONTIGMEM
 	max_mapnr = page_to_pfn(virt_to_page(high_memory - 1)) + 1;
-	totalram_pages += free_all_bootmem();
+	free_all_bootmem();
 #else
 	{
 		int i;
 
 		for (i = 0; i < npmem_ranges; i++)
-			totalram_pages += free_all_bootmem_node(NODE_DATA(i));
+			free_all_bootmem_node(NODE_DATA(i));
 	}
 #endif
 
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 2e912ca..8ddef0a 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -319,13 +319,12 @@ void __init mem_init(void)
         for_each_online_node(nid) {
 		if (NODE_DATA(nid)->node_spanned_pages != 0) {
 			printk("freeing bootmem node %d\n", nid);
-			totalram_pages +=
-				free_all_bootmem_node(NODE_DATA(nid));
+			free_all_bootmem_node(NODE_DATA(nid));
 		}
 	}
 #else
 	max_mapnr = max_pfn;
-	totalram_pages += free_all_bootmem();
+	free_all_bootmem();
 #endif
 	for_each_online_pgdat(pgdat) {
 		for (i = 0; i < pgdat->node_spanned_pages; i++) {
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 275345e..24d52aa 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -142,7 +142,7 @@ void __init mem_init(void)
 	cmma_init();
 
 	/* this will put all low memory onto the freelists */
-	totalram_pages += free_all_bootmem();
+	free_all_bootmem();
 	setup_zero_pages();	/* Setup zeroed pages. */
 
 	reservedpages = 0;
diff --git a/arch/score/mm/init.c b/arch/score/mm/init.c
index 1592aad..579fc4e 100644
--- a/arch/score/mm/init.c
+++ b/arch/score/mm/init.c
@@ -81,7 +81,7 @@ void __init mem_init(void)
 	unsigned long tmp, ram = 0;
 
 	high_memory = (void *) __va(max_low_pfn << PAGE_SHIFT);
-	totalram_pages += free_all_bootmem();
+	free_all_bootmem();
 	setup_zero_page();	/* Setup zeroed pages. */
 	reservedpages = 0;
 
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index 31294f1..aecd913 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -422,7 +422,7 @@ void __init mem_init(void)
 		num_physpages += pgdat->node_present_pages;
 
 		if (pgdat->node_spanned_pages)
-			totalram_pages += free_all_bootmem_node(pgdat);
+			free_all_bootmem_node(pgdat);
 
 
 		node_high_memory = (void *)__va((pgdat->node_start_pfn +
diff --git a/arch/sparc/mm/init_32.c b/arch/sparc/mm/init_32.c
index af472cf..e96afed 100644
--- a/arch/sparc/mm/init_32.c
+++ b/arch/sparc/mm/init_32.c
@@ -323,8 +323,7 @@ void __init mem_init(void)
 
 	max_mapnr = last_valid_pfn - pfn_base;
 	high_memory = __va(max_low_pfn << PAGE_SHIFT);
-
-	totalram_pages = free_all_bootmem();
+	free_all_bootmem();
 
 	for (i = 0; sp_banks[i].num_bytes != 0; i++) {
 		unsigned long start_pfn = sp_banks[i].base_addr >> PAGE_SHIFT;
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 63ddf47..541a3bc 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2055,7 +2055,7 @@ void __init mem_init(void)
 	high_memory = __va(last_valid_pfn << PAGE_SHIFT);
 
 	register_page_bootmem_info();
-	totalram_pages = free_all_bootmem();
+	free_all_bootmem();
 
 	/* We subtract one to account for the mem_map_zero page
 	 * allocated below.
diff --git a/arch/tile/mm/init.c b/arch/tile/mm/init.c
index ccfeb3f..45ce26d 100644
--- a/arch/tile/mm/init.c
+++ b/arch/tile/mm/init.c
@@ -846,7 +846,7 @@ void __init mem_init(void)
 	set_max_mapnr_init();
 
 	/* this will put all bootmem onto the freelists */
-	totalram_pages += free_all_bootmem();
+	free_all_bootmem();
 
 #ifndef CONFIG_64BIT
 	/* count all remaining LOWMEM and give all HIGHMEM to page allocator */
diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
index 1e84189..a7dc6c1 100644
--- a/arch/um/kernel/mem.c
+++ b/arch/um/kernel/mem.c
@@ -65,7 +65,7 @@ void __init mem_init(void)
 	uml_reserved = brk_end;
 
 	/* this will put all low memory onto the freelists */
-	totalram_pages = free_all_bootmem();
+	free_all_bootmem();
 	max_low_pfn = totalram_pages;
 #ifdef CONFIG_HIGHMEM
 	setup_highmem(end_iomem, highmem);
diff --git a/arch/unicore32/mm/init.c b/arch/unicore32/mm/init.c
index 5614b05..119b9e8 100644
--- a/arch/unicore32/mm/init.c
+++ b/arch/unicore32/mm/init.c
@@ -392,7 +392,7 @@ void __init mem_init(void)
 	free_unused_memmap(&meminfo);
 
 	/* this will put all unused low memory onto the freelists */
-	totalram_pages += free_all_bootmem();
+	free_all_bootmem();
 
 	reserved_pages = free_pages = 0;
 
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 3ac7e31..9fa46ba 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -759,7 +759,7 @@ void __init mem_init(void)
 	set_highmem_pages_init();
 
 	/* this will put all low memory onto the freelists */
-	totalram_pages += free_all_bootmem();
+	free_all_bootmem();
 
 	reservedpages = 0;
 	for (tmp = 0; tmp < max_low_pfn; tmp++)
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 6ab46f2..65116e5 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1053,7 +1053,7 @@ void __init mem_init(void)
 	register_page_bootmem_info();
 
 	/* this will put all memory onto the freelists */
-	totalram_pages = free_all_bootmem();
+	free_all_bootmem();
 
 	absent_pages = absent_pages_in_range(0, max_pfn);
 	reservedpages = max_pfn - totalram_pages - absent_pages;
diff --git a/arch/xtensa/mm/init.c b/arch/xtensa/mm/init.c
index 6f70647..dc6e009 100644
--- a/arch/xtensa/mm/init.c
+++ b/arch/xtensa/mm/init.c
@@ -184,7 +184,7 @@ void __init mem_init(void)
 #error HIGHGMEM not implemented in init.c
 #endif
 
-	totalram_pages += free_all_bootmem();
+	free_all_bootmem();
 
 	reservedpages = ram = 0;
 	for (tmp = 0; tmp < max_mapnr; tmp++) {
diff --git a/mm/bootmem.c b/mm/bootmem.c
index 39e6156..a19404b 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -272,9 +272,14 @@ void __init reset_all_zones_managed_pages(void)
  */
 unsigned long __init free_all_bootmem_node(pg_data_t *pgdat)
 {
+	unsigned long pages;
+
 	register_page_bootmem_info_node(pgdat);
 	reset_node_managed_pages(pgdat);
-	return free_all_bootmem_core(pgdat->bdata);
+	pages = free_all_bootmem_core(pgdat->bdata);
+	totalram_pages += pages;
+
+	return pages;
 }
 
 /**
@@ -292,6 +297,8 @@ unsigned long __init free_all_bootmem(void)
 	list_for_each_entry(bdata, &bdata_list, list)
 		total_pages += free_all_bootmem_core(bdata);
 
+	totalram_pages += total_pages;
+
 	return total_pages;
 }
 
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index fa584ff..6b63cd6 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -165,6 +165,8 @@ void __init reset_all_zones_managed_pages(void)
  */
 unsigned long __init free_all_bootmem(void)
 {
+	unsigned long pages;
+
 	reset_all_zones_managed_pages();
 
 	/*
@@ -172,7 +174,10 @@ unsigned long __init free_all_bootmem(void)
 	 *  because in some case like Node0 doesn't have RAM installed
 	 *  low ram will be on Node1
 	 */
-	return free_low_memory_core_early(MAX_NUMNODES);
+	pages = free_low_memory_core_early(MAX_NUMNODES);
+	totalram_pages += pages;
+
+	return pages;
 }
 
 /**
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
