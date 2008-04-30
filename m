Message-Id: <20080430170839.835245774@symbol.fehenstaub.lan>
References: <20080430170521.246745395@symbol.fehenstaub.lan>
Date: Wed, 30 Apr 2008 19:05:24 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [patch 3/4] mm: Normalize internal argument passing of bootmem data
Content-Disposition: inline; filename=mm-normalize-internal-argument-passing-of-bootmem-data.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

All _core functions only need the bootmem data, not the whole node
descriptor.  Adjust the two functions that take the node descriptor
unneededly.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
CC: Ingo Molnar <mingo@elte.hu>
---

Index: linux-2.6/mm/bootmem.c
===================================================================
--- linux-2.6.orig/mm/bootmem.c
+++ linux-2.6/mm/bootmem.c
@@ -87,10 +87,9 @@ static unsigned long __init get_mapsize(
 /*
  * Called once to set up the allocator itself.
  */
-static unsigned long __init init_bootmem_core(pg_data_t *pgdat,
+static unsigned long __init init_bootmem_core(bootmem_data_t *bdata,
 	unsigned long mapstart, unsigned long start, unsigned long end)
 {
-	bootmem_data_t *bdata = pgdat->bdata;
 	unsigned long mapsize;
 
 	bdata->node_bootmem_map = phys_to_virt(PFN_PHYS(mapstart));
@@ -371,11 +370,10 @@ found:
 	return ret;
 }
 
-static unsigned long __init free_all_bootmem_core(pg_data_t *pgdat)
+static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 {
 	struct page *page;
 	unsigned long pfn;
-	bootmem_data_t *bdata = pgdat->bdata;
 	unsigned long i, count;
 	unsigned long idx;
 	unsigned long *map; 
@@ -440,7 +438,7 @@ static unsigned long __init free_all_boo
 unsigned long __init init_bootmem_node(pg_data_t *pgdat, unsigned long freepfn,
 				unsigned long startpfn, unsigned long endpfn)
 {
-	return init_bootmem_core(pgdat, freepfn, startpfn, endpfn);
+	return init_bootmem_core(pgdat->bdata, freepfn, startpfn, endpfn);
 }
 
 void __init reserve_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
@@ -463,14 +461,14 @@ void __init free_bootmem_node(pg_data_t 
 unsigned long __init free_all_bootmem_node(pg_data_t *pgdat)
 {
 	register_page_bootmem_info_node(pgdat);
-	return free_all_bootmem_core(pgdat);
+	return free_all_bootmem_core(pgdat->bdata);
 }
 
 unsigned long __init init_bootmem(unsigned long start, unsigned long pages)
 {
 	max_low_pfn = pages;
 	min_low_pfn = start;
-	return init_bootmem_core(NODE_DATA(0), start, 0, pages);
+	return init_bootmem_core(NODE_DATA(0)->bdata, start, 0, pages);
 }
 
 #ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
@@ -501,7 +499,7 @@ void __init free_bootmem(unsigned long a
 
 unsigned long __init free_all_bootmem(void)
 {
-	return free_all_bootmem_core(NODE_DATA(0));
+	return free_all_bootmem_core(NODE_DATA(0)->bdata);
 }
 
 void * __init __alloc_bootmem_nopanic(unsigned long size, unsigned long align,

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
