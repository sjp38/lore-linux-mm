Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id iAHLIiJT211854
	for <linux-mm@kvack.org>; Wed, 17 Nov 2004 16:18:45 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iAHLIeQC154706
	for <linux-mm@kvack.org>; Wed, 17 Nov 2004 14:18:44 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id iAHLId9P026135
	for <linux-mm@kvack.org>; Wed, 17 Nov 2004 14:18:39 -0700
Subject: [patch 1/2] kill off highmem_start_page
From: Dave Hansen <haveblue@us.ibm.com>
Date: Wed, 17 Nov 2004 13:18:36 -0800
Message-Id: <E1CUXCI-0006US-00@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: george@mvista.com, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

People love to do comparisons with highmem_start_page.  However, 
where CONFIG_HIGHMEM=y and there is no actual highmem, there's
no real page at *highmem_start_page.

That's usually not a problem, but CONFIG_NONLINEAR is a bit more
strict and catches the bogus address tranlations.  

There are about a gillion different ways to find out of a
'struct page' is highmem or not.  Why not just check page_flags?
Just use PageHighMem() wherever there used to be a 
highmem_start_page comparison.  Then, kill off highmem_start_page.

This removes more code than it adds, and gets rid of some nasty 
#ifdefs in .c files.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 memhotplug-dave/arch/frv/mm/highmem.c       |    4 ++--
 memhotplug-dave/arch/frv/mm/init.c          |    5 -----
 memhotplug-dave/arch/i386/mm/discontig.c    |    5 -----
 memhotplug-dave/arch/i386/mm/highmem.c      |    6 +++---
 memhotplug-dave/arch/i386/mm/init.c         |    1 -
 memhotplug-dave/arch/i386/mm/pageattr.c     |    5 +----
 memhotplug-dave/arch/mips/mm/highmem.c      |    6 +++---
 memhotplug-dave/arch/mips/mm/init.c         |    1 -
 memhotplug-dave/arch/ppc/mm/init.c          |    1 -
 memhotplug-dave/arch/sparc/mm/highmem.c     |    2 +-
 memhotplug-dave/arch/sparc/mm/init.c        |    2 --
 memhotplug-dave/arch/um/kernel/mem.c        |    5 -----
 memhotplug-dave/include/asm-ppc/highmem.h   |    6 +++---
 memhotplug-dave/include/asm-sparc/highmem.h |    4 ++--
 memhotplug-dave/include/linux/highmem.h     |    2 --
 memhotplug-dave/mm/memory.c                 |    2 --
 memhotplug-dave/net/core/dev.c              |    2 +-
 17 files changed, 16 insertions(+), 43 deletions(-)

diff -puN arch/i386/lib/kgdb_serial.c~A1-no-highmem_start_page arch/i386/lib/kgdb_serial.c
diff -puN arch/i386/mm/discontig.c~A1-no-highmem_start_page arch/i386/mm/discontig.c
--- memhotplug/arch/i386/mm/discontig.c~A1-no-highmem_start_page	2004-11-17 13:02:58.000000000 -0800
+++ memhotplug-dave/arch/i386/mm/discontig.c	2004-11-17 13:02:58.000000000 -0800
@@ -464,11 +464,6 @@ void __init set_highmem_pages_init(int b
 void __init set_max_mapnr_init(void)
 {
 #ifdef CONFIG_HIGHMEM
-	struct zone *high0 = &NODE_DATA(0)->node_zones[ZONE_HIGHMEM];
-	if (high0->spanned_pages > 0)
-	      	highmem_start_page = high0->zone_mem_map;
-	else
-		highmem_start_page = pfn_to_page(max_low_pfn - 1) + 1;
 	num_physpages = highend_pfn;
 #else
 	num_physpages = max_low_pfn;
diff -puN arch/mips/mm/highmem.c~A1-no-highmem_start_page arch/mips/mm/highmem.c
--- memhotplug/arch/mips/mm/highmem.c~A1-no-highmem_start_page	2004-11-17 13:02:58.000000000 -0800
+++ memhotplug-dave/arch/mips/mm/highmem.c	2004-11-17 13:02:58.000000000 -0800
@@ -8,7 +8,7 @@ void *__kmap(struct page *page)
 	void *addr;
 
 	might_sleep();
-	if (page < highmem_start_page)
+	if (!PageHighMem(page))
 		return page_address(page);
 	addr = kmap_high(page);
 	flush_tlb_one((unsigned long)addr);
@@ -20,7 +20,7 @@ void __kunmap(struct page *page)
 {
 	if (in_interrupt())
 		BUG();
-	if (page < highmem_start_page)
+	if (!PageHighMem(page))
 		return;
 	kunmap_high(page);
 }
@@ -41,7 +41,7 @@ void *__kmap_atomic(struct page *page, e
 
 	/* even !CONFIG_PREEMPT needs this, for in_atomic in do_page_fault */
 	inc_preempt_count();
-	if (page < highmem_start_page)
+	if (!PageHighMem(page))
 		return page_address(page);
 
 	idx = type + KM_TYPE_NR*smp_processor_id();
diff -puN arch/um/kernel/mem.c~A1-no-highmem_start_page arch/um/kernel/mem.c
--- memhotplug/arch/um/kernel/mem.c~A1-no-highmem_start_page	2004-11-17 13:02:58.000000000 -0800
+++ memhotplug-dave/arch/um/kernel/mem.c	2004-11-17 13:02:58.000000000 -0800
@@ -49,8 +49,6 @@ static void setup_highmem(unsigned long 
 	unsigned long highmem_pfn;
 	int i;
 
-	highmem_start_page = virt_to_page(highmem_start);
-
 	highmem_pfn = __pa(highmem_start) >> PAGE_SHIFT;
 	for(i = 0; i < highmem_len >> PAGE_SHIFT; i++){
 		page = &mem_map[highmem_pfn + i];
@@ -67,9 +65,6 @@ void mem_init(void)
 	unsigned long start;
 
 	max_low_pfn = (high_physmem - uml_physmem) >> PAGE_SHIFT;
-#ifdef CONFIG_HIGHMEM
-	highmem_start_page = phys_page(__pa(high_physmem));
-#endif
 
         /* clear the zero-page */
         memset((void *) empty_zero_page, 0, PAGE_SIZE);
diff -puN include/asm-sparc/highmem.h~A1-no-highmem_start_page include/asm-sparc/highmem.h
--- memhotplug/include/asm-sparc/highmem.h~A1-no-highmem_start_page	2004-11-17 13:02:58.000000000 -0800
+++ memhotplug-dave/include/asm-sparc/highmem.h	2004-11-17 13:02:58.000000000 -0800
@@ -57,7 +57,7 @@ extern void kunmap_high(struct page *pag
 static inline void *kmap(struct page *page)
 {
 	BUG_ON(in_interrupt());
-	if (page < highmem_start_page)
+	if (!PageHighMem(page))
 		return page_address(page);
 	return kmap_high(page);
 }
@@ -65,7 +65,7 @@ static inline void *kmap(struct page *pa
 static inline void kunmap(struct page *page)
 {
 	BUG_ON(in_interrupt());
-	if (page < highmem_start_page)
+	if (!PageHighMem(page))
 		return;
 	kunmap_high(page);
 }
diff -puN include/linux/highmem.h~A1-no-highmem_start_page include/linux/highmem.h
--- memhotplug/include/linux/highmem.h~A1-no-highmem_start_page	2004-11-17 13:02:58.000000000 -0800
+++ memhotplug-dave/include/linux/highmem.h	2004-11-17 13:02:58.000000000 -0800
@@ -9,8 +9,6 @@
 
 #ifdef CONFIG_HIGHMEM
 
-extern struct page *highmem_start_page;
-
 #include <asm/highmem.h>
 
 /* declarations for linux/mm/highmem.c */
diff -puN net/core/dev.c~A1-no-highmem_start_page net/core/dev.c
--- memhotplug/net/core/dev.c~A1-no-highmem_start_page	2004-11-17 13:02:58.000000000 -0800
+++ memhotplug-dave/net/core/dev.c	2004-11-17 13:02:58.000000000 -0800
@@ -1119,7 +1119,7 @@ static inline int illegal_highdma(struct
 		return 0;
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-		if (skb_shinfo(skb)->frags[i].page >= highmem_start_page)
+		if (PageHighMem(skb_shinfo(skb)->frags[i].page))
 			return 1;
 
 	return 0;
diff -puN arch/sparc/mm/highmem.c~A1-no-highmem_start_page arch/sparc/mm/highmem.c
--- memhotplug/arch/sparc/mm/highmem.c~A1-no-highmem_start_page	2004-11-17 13:02:58.000000000 -0800
+++ memhotplug-dave/arch/sparc/mm/highmem.c	2004-11-17 13:02:58.000000000 -0800
@@ -36,7 +36,7 @@ void *kmap_atomic(struct page *page, enu
 
 	/* even !CONFIG_PREEMPT needs this, for in_atomic in do_page_fault */
 	inc_preempt_count();
-	if (page < highmem_start_page)
+	if (!PageHighMem(page))
 		return page_address(page);
 
 	idx = type + KM_TYPE_NR*smp_processor_id();
diff -puN arch/sparc/mm/init.c~A1-no-highmem_start_page arch/sparc/mm/init.c
--- memhotplug/arch/sparc/mm/init.c~A1-no-highmem_start_page	2004-11-17 13:02:58.000000000 -0800
+++ memhotplug-dave/arch/sparc/mm/init.c	2004-11-17 13:02:58.000000000 -0800
@@ -402,8 +402,6 @@ void __init mem_init(void)
 	int reservedpages = 0;
 	int i;
 
-	highmem_start_page = pfn_to_page(highstart_pfn);
-
 	if (PKMAP_BASE+LAST_PKMAP*PAGE_SIZE >= FIXADDR_START) {
 		prom_printf("BUG: fixmap and pkmap areas overlap\n");
 		prom_printf("pkbase: 0x%lx pkend: 0x%lx fixstart 0x%lx\n",
diff -puN arch/ppc/mm/init.c~A1-no-highmem_start_page arch/ppc/mm/init.c
--- memhotplug/arch/ppc/mm/init.c~A1-no-highmem_start_page	2004-11-17 13:02:58.000000000 -0800
+++ memhotplug-dave/arch/ppc/mm/init.c	2004-11-17 13:02:58.000000000 -0800
@@ -419,7 +419,6 @@ void __init mem_init(void)
 	unsigned long highmem_mapnr;
 
 	highmem_mapnr = total_lowmem >> PAGE_SHIFT;
-	highmem_start_page = mem_map + highmem_mapnr;
 #endif /* CONFIG_HIGHMEM */
 	max_mapnr = total_memory >> PAGE_SHIFT;
 
diff -puN arch/i386/mm/pageattr.c~A1-no-highmem_start_page arch/i386/mm/pageattr.c
--- memhotplug/arch/i386/mm/pageattr.c~A1-no-highmem_start_page	2004-11-17 13:02:58.000000000 -0800
+++ memhotplug-dave/arch/i386/mm/pageattr.c	2004-11-17 13:02:58.000000000 -0800
@@ -105,10 +105,7 @@ __change_page_attr(struct page *page, pg
 	unsigned long address;
 	struct page *kpte_page;
 
-#ifdef CONFIG_HIGHMEM
-	if (page >= highmem_start_page) 
-		BUG(); 
-#endif
+	BUG_ON(PageHighMem(page));
 	address = (unsigned long)page_address(page);
 
 	kpte = lookup_address(address);
diff -puN arch/i386/mm/highmem.c~A1-no-highmem_start_page arch/i386/mm/highmem.c
--- memhotplug/arch/i386/mm/highmem.c~A1-no-highmem_start_page	2004-11-17 13:02:58.000000000 -0800
+++ memhotplug-dave/arch/i386/mm/highmem.c	2004-11-17 13:02:58.000000000 -0800
@@ -3,7 +3,7 @@
 void *kmap(struct page *page)
 {
 	might_sleep();
-	if (page < highmem_start_page)
+	if (!PageHighMem(page))
 		return page_address(page);
 	return kmap_high(page);
 }
@@ -12,7 +12,7 @@ void kunmap(struct page *page)
 {
 	if (in_interrupt())
 		BUG();
-	if (page < highmem_start_page)
+	if (!PageHighMem(page))
 		return;
 	kunmap_high(page);
 }
@@ -32,7 +32,7 @@ char *kmap_atomic(struct page *page, enu
 
 	/* even !CONFIG_PREEMPT needs this, for in_atomic in do_page_fault */
 	inc_preempt_count();
-	if (page < highmem_start_page)
+	if (!PageHighMem(page))
 		return page_address(page);
 
 	idx = type + KM_TYPE_NR*smp_processor_id();
diff -puN arch/mips/mm/init.c~A1-no-highmem_start_page arch/mips/mm/init.c
--- memhotplug/arch/mips/mm/init.c~A1-no-highmem_start_page	2004-11-17 13:02:58.000000000 -0800
+++ memhotplug-dave/arch/mips/mm/init.c	2004-11-17 13:02:58.000000000 -0800
@@ -204,7 +204,6 @@ void __init mem_init(void)
 	unsigned long tmp, ram;
 
 #ifdef CONFIG_HIGHMEM
-	highmem_start_page = mem_map + highstart_pfn;
 #ifdef CONFIG_DISCONTIGMEM
 #error "CONFIG_HIGHMEM and CONFIG_DISCONTIGMEM dont work together yet"
 #endif
diff -puN include/asm-ppc/highmem.h~A1-no-highmem_start_page include/asm-ppc/highmem.h
--- memhotplug/include/asm-ppc/highmem.h~A1-no-highmem_start_page	2004-11-17 13:02:58.000000000 -0800
+++ memhotplug-dave/include/asm-ppc/highmem.h	2004-11-17 13:02:58.000000000 -0800
@@ -56,7 +56,7 @@ extern void kunmap_high(struct page *pag
 static inline void *kmap(struct page *page)
 {
 	might_sleep();
-	if (page < highmem_start_page)
+	if (!PageHighMem(page))
 		return page_address(page);
 	return kmap_high(page);
 }
@@ -64,7 +64,7 @@ static inline void *kmap(struct page *pa
 static inline void kunmap(struct page *page)
 {
 	BUG_ON(in_interrupt());
-	if (page < highmem_start_page)
+	if (!PageHighMem(page))
 		return;
 	kunmap_high(page);
 }
@@ -82,7 +82,7 @@ static inline void *kmap_atomic(struct p
 
 	/* even !CONFIG_PREEMPT needs this, for in_atomic in do_page_fault */
 	inc_preempt_count();
-	if (page < highmem_start_page)
+	if (!PageHighMem(page))
 		return page_address(page);
 
 	idx = type + KM_TYPE_NR*smp_processor_id();
diff -puN mm/memory.c~A1-no-highmem_start_page mm/memory.c
--- memhotplug/mm/memory.c~A1-no-highmem_start_page	2004-11-17 13:02:58.000000000 -0800
+++ memhotplug-dave/mm/memory.c	2004-11-17 13:02:58.000000000 -0800
@@ -77,11 +77,9 @@ unsigned long num_physpages;
  * and ZONE_HIGHMEM.
  */
 void * high_memory;
-struct page *highmem_start_page;
 unsigned long vmalloc_earlyreserve;
 
 EXPORT_SYMBOL(num_physpages);
-EXPORT_SYMBOL(highmem_start_page);
 EXPORT_SYMBOL(high_memory);
 EXPORT_SYMBOL(vmalloc_earlyreserve);
 
diff -puN arch/i386/mm/init.c~A1-no-highmem_start_page arch/i386/mm/init.c
--- memhotplug/arch/i386/mm/init.c~A1-no-highmem_start_page	2004-11-17 13:02:58.000000000 -0800
+++ memhotplug-dave/arch/i386/mm/init.c	2004-11-17 13:02:58.000000000 -0800
@@ -568,7 +568,6 @@ void __init test_wp_bit(void)
 static void __init set_max_mapnr_init(void)
 {
 #ifdef CONFIG_HIGHMEM
-	highmem_start_page = pfn_to_page(highstart_pfn);
 	max_mapnr = num_physpages = highend_pfn;
 #else
 	max_mapnr = num_physpages = max_low_pfn;
diff -puN arch/frv/mm/highmem.c~A1-no-highmem_start_page arch/frv/mm/highmem.c
--- memhotplug/arch/frv/mm/highmem.c~A1-no-highmem_start_page	2004-11-17 13:02:58.000000000 -0800
+++ memhotplug-dave/arch/frv/mm/highmem.c	2004-11-17 13:04:24.000000000 -0800
@@ -13,7 +13,7 @@
 void *kmap(struct page *page)
 {
 	might_sleep();
-	if (page < highmem_start_page)
+	if (!PageHighMem(page))
 		return page_address(page);
 	return kmap_high(page);
 }
@@ -22,7 +22,7 @@ void kunmap(struct page *page)
 {
 	if (in_interrupt())
 		BUG();
-	if (page < highmem_start_page)
+	if (!PageHighMem(page))
 		return;
 	kunmap_high(page);
 }
diff -puN arch/frv/mm/init.c~A1-no-highmem_start_page arch/frv/mm/init.c
--- memhotplug/arch/frv/mm/init.c~A1-no-highmem_start_page	2004-11-17 13:02:58.000000000 -0800
+++ memhotplug-dave/arch/frv/mm/init.c	2004-11-17 13:04:36.000000000 -0800
@@ -134,11 +134,6 @@ void __init paging_init(void)
 	free_area_init(zones_size);
 
 #ifdef CONFIG_MMU
-	/* high memory (if present) starts after the last mapped page
-	 * - this is used by kmap()
-	 */
-	highmem_start_page = mem_map + num_mappedpages;
-
 	/* initialise init's MMU context */
 	init_new_context(&init_task, &init_mm);
 #endif
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
