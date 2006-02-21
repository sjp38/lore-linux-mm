Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
        by fgwmail6.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k1LBuXUD001087 for <linux-mm@kvack.org>; Tue, 21 Feb 2006 20:56:33 +0900
        (envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s0.gw.fujitsu.co.jp by m4.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k1LBuVHC024606 for <linux-mm@kvack.org>; Tue, 21 Feb 2006 20:56:31 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s0.gw.fujitsu.co.jp (s0 [127.0.0.1])
	by s0.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B19A32D70F
	for <linux-mm@kvack.org>; Tue, 21 Feb 2006 20:56:31 +0900 (JST)
Received: from fjm503.ms.jp.fujitsu.com (fjm503.ms.jp.fujitsu.com [10.56.99.77])
	by s0.gw.fujitsu.co.jp (Postfix) with ESMTP id B0A9A32D706
	for <linux-mm@kvack.org>; Tue, 21 Feb 2006 20:56:30 +0900 (JST)
Received: from [127.0.0.1] (fjmscan503.ms.jp.fujitsu.com [10.56.99.143])by fjm503.ms.jp.fujitsu.com with ESMTP id k1LBu4g7001777
	for <linux-mm@kvack.org>; Tue, 21 Feb 2006 20:56:06 +0900
Message-ID: <43FB003E.9050302@jp.fujitsu.com>
Date: Tue, 21 Feb 2006 20:57:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC][PATCH] bdata and pgdat initialization cleanup [1/5] change
 alloc_bootmem_node arg
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,
After reading node-hot-add patch discussion, I started to rewrite
pgdat initialization codes to share them with node_hot_add codes.

But they look too complicated... so, I'd like to start from making
it clean :) Following patches are just for review before writing tons of each-arch
patches. I'm now testing these on i386.


--  Kame

pgdat initialization is affected by bootmem initialization to some extent.
This increases complexity of bootmem codes.
As a first step, this patch modifies generic bootmem allocator and
pgdat_link. These patches divide bootmem and pgdat.


This patch does

	- define bootmem[MAX_NUMNODES] and BOOTMEM(i)
	  All archs/config can use this. (MAX_NUMNODES=1 when FLATMEM)

	- rewrite bootmem funcs based on bootmem_data_t instead of pg_data_t.

	- pgdat_link initialization is removed. so for_each_pgdat cannot
	  work. this is fixed by the next patch.

	- for_each_pgdat() for bootmem allocater is changed to
           list_for_each_entry(bdata, bdata_list, list).
	  By this, CONFIG_HAVE_ARCH_BOOTMEM_NODE can be removed.
	  (order of bootmem's list should be carefully checked.)
	  i.e if init_bootmem_node(node) is not called, the node is
	  not a target of alloc_bootmem().

Patches for each archs (which has NUMA configs) will follow after patches
for generic codes.

Sigh, this will change  many callers of alloc_bootmem_node().

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: testtree/include/linux/bootmem.h
===================================================================
--- testtree.orig/include/linux/bootmem.h
+++ testtree/include/linux/bootmem.h
@@ -38,8 +38,19 @@ typedef struct bootmem_data {
  	unsigned long last_pos;
  	unsigned long last_success;	/* Previous allocation point.  To speed
  					 * up searching */
+	struct list_head list;
  } bootmem_data_t;

+extern bootmem_data_t bootmem[MAX_NUMNODES];
+
+#ifndef BOOTMEM
+#ifdef CONFIG_NUMA
+#define BOOTMEM(i)	(&bootmem[(i)])
+#else
+#define BOOTMEM(i)	(&bootmem[0])
+#endif
+#endif /* BOOTMEM */
+
  extern unsigned long __init bootmem_bootmap_pages (unsigned long);
  extern unsigned long __init init_bootmem (unsigned long addr, unsigned long memend);
  extern void __init free_bootmem (unsigned long addr, unsigned long size);
@@ -47,11 +58,11 @@ extern void * __init __alloc_bootmem (un
  extern void * __init __alloc_bootmem_low(unsigned long size,
  					 unsigned long align,
  					 unsigned long goal);
-extern void * __init __alloc_bootmem_low_node(pg_data_t *pgdat,
+extern void * __init __alloc_bootmem_low_node(bootmem_data_t *bdata,
  					      unsigned long size,
  					      unsigned long align,
  					      unsigned long goal);
-#ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
+
  extern void __init reserve_bootmem (unsigned long addr, unsigned long size);
  #define alloc_bootmem(x) \
  	__alloc_bootmem((x), SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
@@ -61,21 +72,25 @@ extern void __init reserve_bootmem (unsi
  	__alloc_bootmem((x), PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
  #define alloc_bootmem_low_pages(x) \
  	__alloc_bootmem_low((x), PAGE_SIZE, 0)
-#endif /* !CONFIG_HAVE_ARCH_BOOTMEM_NODE */
+
  extern unsigned long __init free_all_bootmem (void);
-extern void * __init __alloc_bootmem_node (pg_data_t *pgdat, unsigned long size, unsigned long align, unsigned long goal);
-extern unsigned long __init init_bootmem_node (pg_data_t *pgdat, unsigned long freepfn, unsigned long startpfn, unsigned long endpfn);
-extern void __init reserve_bootmem_node (pg_data_t *pgdat, unsigned long physaddr, unsigned long size);
-extern void __init free_bootmem_node (pg_data_t *pgdat, unsigned long addr, unsigned long size);
-extern unsigned long __init free_all_bootmem_node (pg_data_t *pgdat);
-#ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
-#define alloc_bootmem_node(pgdat, x) \
-	__alloc_bootmem_node((pgdat), (x), SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
-#define alloc_bootmem_pages_node(pgdat, x) \
-	__alloc_bootmem_node((pgdat), (x), PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
-#define alloc_bootmem_low_pages_node(pgdat, x) \
-	__alloc_bootmem_low_node((pgdat), (x), PAGE_SIZE, 0)
-#endif /* !CONFIG_HAVE_ARCH_BOOTMEM_NODE */
+extern void * __init __alloc_bootmem_node (bootmem_data_t *bdata,
+              unsigned long size, unsigned long align, unsigned long goal);
+extern unsigned long __init init_bootmem_node (bootmem_data_t *bdata,
+      unsigned long freepfn, unsigned long startpfn, unsigned long endpfn);
+extern void __init reserve_bootmem_node (bootmem_data_t *bdata,
+      unsigned long physaddr, unsigned long size);
+extern void __init free_bootmem_node (bootmem_data_t *bdata,
+      unsigned long addr, unsigned long size);
+extern unsigned long __init free_all_bootmem_node (bootmem_data_t *bdata);
+
+#define alloc_bootmem_node(bdata, x) \
+	__alloc_bootmem_node((bdata), (x), SMP_CACHE_BYTES,\
+                             __pa(MAX_DMA_ADDRESS))
+#define alloc_bootmem_pages_node(bdata, x) \
+	__alloc_bootmem_node((bdata), (x), PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
+#define alloc_bootmem_low_pages_node(bdata, x) \
+	__alloc_bootmem_low_node((bdata), (x), PAGE_SIZE, 0)

  #ifdef CONFIG_HAVE_ARCH_ALLOC_REMAP
  extern void *alloc_remap(int nid, unsigned long size);
Index: testtree/mm/bootmem.c
===================================================================
--- testtree.orig/mm/bootmem.c
+++ testtree/mm/bootmem.c
@@ -33,6 +33,9 @@ EXPORT_SYMBOL(max_pfn);		/* This is expo
  				 * dma_get_required_mask(), which uses
  				 * it, can be an inline function */

+bootmem_data_t bootmem[MAX_NUMNODES] __initdata;
+LIST_HEAD(bdata_list);
+
  #ifdef CONFIG_CRASH_DUMP
  /*
   * If we have booted due to a crash, max_pfn will be a very low value. We need
@@ -56,15 +59,11 @@ unsigned long __init bootmem_bootmap_pag
  /*
   * Called once to set up the allocator itself.
   */
-static unsigned long __init init_bootmem_core (pg_data_t *pgdat,
+static unsigned long __init init_bootmem_core (bootmem_data_t *bdata,
  	unsigned long mapstart, unsigned long start, unsigned long end)
  {
-	bootmem_data_t *bdata = pgdat->bdata;
  	unsigned long mapsize = ((end - start)+7)/8;

-	pgdat->pgdat_next = pgdat_list;
-	pgdat_list = pgdat;
-
  	mapsize = ALIGN(mapsize, sizeof(long));
  	bdata->node_bootmem_map = phys_to_virt(mapstart << PAGE_SHIFT);
  	bdata->node_boot_start = (start << PAGE_SHIFT);
@@ -76,6 +75,9 @@ static unsigned long __init init_bootmem
  	 */
  	memset(bdata->node_bootmem_map, 0xff, mapsize);

+	INIT_LIST_HEAD(&bdata->list);
+	list_add_tail(&bdata->list, &bdata_list);
+
  	return mapsize;
  }

@@ -271,11 +273,10 @@ found:
  	return ret;
  }

-static unsigned long __init free_all_bootmem_core(pg_data_t *pgdat)
+static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
  {
  	struct page *page;
  	unsigned long pfn;
-	bootmem_data_t *bdata = pgdat->bdata;
  	unsigned long i, count, total = 0;
  	unsigned long idx;
  	unsigned long *map;
@@ -337,58 +338,60 @@ static unsigned long __init free_all_boo
  	return total;
  }

-unsigned long __init init_bootmem_node (pg_data_t *pgdat, unsigned long freepfn, unsigned long startpfn, unsigned long endpfn)
+unsigned long __init init_bootmem_node (bootmem_data_t *bdata,
+        unsigned long freepfn, unsigned long startpfn, unsigned long endpfn)
  {
-	return(init_bootmem_core(pgdat, freepfn, startpfn, endpfn));
+	return(init_bootmem_core(bdata, freepfn, startpfn, endpfn));
  }

-void __init reserve_bootmem_node (pg_data_t *pgdat, unsigned long physaddr, unsigned long size)
+void __init reserve_bootmem_node (bootmem_data_t *bdata,
+        unsigned long physaddr, unsigned long size)
  {
-	reserve_bootmem_core(pgdat->bdata, physaddr, size);
+	reserve_bootmem_core(bdata, physaddr, size);
  }

-void __init free_bootmem_node (pg_data_t *pgdat, unsigned long physaddr, unsigned long size)
+void __init free_bootmem_node (bootmem_data_t *bdata,
+        unsigned long physaddr, unsigned long size)
  {
-	free_bootmem_core(pgdat->bdata, physaddr, size);
+	free_bootmem_core(bdata, physaddr, size);
  }

-unsigned long __init free_all_bootmem_node (pg_data_t *pgdat)
+unsigned long __init free_all_bootmem_node (bootmem_data_t *bdata)
  {
-	return(free_all_bootmem_core(pgdat));
+	return(free_all_bootmem_core(bdata));
  }

  unsigned long __init init_bootmem (unsigned long start, unsigned long pages)
  {
  	max_low_pfn = pages;
  	min_low_pfn = start;
-	return(init_bootmem_core(NODE_DATA(0), start, 0, pages));
+	return(init_bootmem_core(BOOTMEM(0), start, 0, pages));
  }

  #ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
  void __init reserve_bootmem (unsigned long addr, unsigned long size)
  {
-	reserve_bootmem_core(NODE_DATA(0)->bdata, addr, size);
+	reserve_bootmem_core(BOOTMEM(0), addr, size);
  }
  #endif /* !CONFIG_HAVE_ARCH_BOOTMEM_NODE */

  void __init free_bootmem (unsigned long addr, unsigned long size)
  {
-	free_bootmem_core(NODE_DATA(0)->bdata, addr, size);
+	free_bootmem_core(BOOTMEM(0), addr, size);
  }

  unsigned long __init free_all_bootmem (void)
  {
-	return(free_all_bootmem_core(NODE_DATA(0)));
+	return(free_all_bootmem_core(BOOTMEM(0)));
  }

  void * __init __alloc_bootmem(unsigned long size, unsigned long align, unsigned long goal)
  {
-	pg_data_t *pgdat = pgdat_list;
+	bootmem_data_t *bdata;
  	void *ptr;

-	for_each_pgdat(pgdat)
-		if ((ptr = __alloc_bootmem_core(pgdat->bdata, size,
-						 align, goal, 0)))
+	list_for_each_entry(bdata, &bdata_list, list)
+		if ((ptr = __alloc_bootmem_core(bdata, size, align, goal, 0)))
  			return(ptr);

  	/*
@@ -400,12 +403,12 @@ void * __init __alloc_bootmem(unsigned l
  }


-void * __init __alloc_bootmem_node(pg_data_t *pgdat, unsigned long size, unsigned long align,
-				   unsigned long goal)
+void * __init __alloc_bootmem_node(bootmem_data_t *bdata,
+	unsigned long size, unsigned long align,unsigned long goal)
  {
  	void *ptr;

-	ptr = __alloc_bootmem_core(pgdat->bdata, size, align, goal, 0);
+	ptr = __alloc_bootmem_core(bdata, size, align, goal, 0);
  	if (ptr)
  		return (ptr);

@@ -414,14 +417,14 @@ void * __init __alloc_bootmem_node(pg_da

  #define LOW32LIMIT 0xffffffff

-void * __init __alloc_bootmem_low(unsigned long size, unsigned long align, unsigned long goal)
+void * __init __alloc_bootmem_low(unsigned long size, unsigned long align,
+			unsigned long goal)
  {
-	pg_data_t *pgdat = pgdat_list;
+	bootmem_data_t *bdata;
  	void *ptr;

-	for_each_pgdat(pgdat)
-		if ((ptr = __alloc_bootmem_core(pgdat->bdata, size,
-						 align, goal, LOW32LIMIT)))
+	list_for_each_entry(bdata, &bdata_list, list)
+		if ((ptr = __alloc_bootmem_core(bdata, size, align, goal, LOW32LIMIT)))
  			return(ptr);

  	/*
@@ -432,8 +435,8 @@ void * __init __alloc_bootmem_low(unsign
  	return NULL;
  }

-void * __init __alloc_bootmem_low_node(pg_data_t *pgdat, unsigned long size,
-				       unsigned long align, unsigned long goal)
+void * __init __alloc_bootmem_low_node(bootmem_data_t *bdata,
+		unsigned long size, unsigned long align, unsigned long goal)
  {
-	return __alloc_bootmem_core(pgdat->bdata, size, align, goal, LOW32LIMIT);
+	return __alloc_bootmem_core(bdata, size, align, goal, LOW32LIMIT);
  }
Index: testtree/mm/page_alloc.c
===================================================================
--- testtree.orig/mm/page_alloc.c
+++ testtree/mm/page_alloc.c
@@ -2225,8 +2225,7 @@ void __init free_area_init_node(int nid,
  }

  #ifndef CONFIG_NEED_MULTIPLE_NODES
-static bootmem_data_t contig_bootmem_data;
-struct pglist_data contig_page_data = { .bdata = &contig_bootmem_data };
+struct pglist_data contig_page_data = { .bdata = BOOTMEM(0)};

  EXPORT_SYMBOL(contig_page_data);
  #endif



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
