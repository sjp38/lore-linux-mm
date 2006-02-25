Date: Sat, 25 Feb 2006 15:07:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] for_each_online_pgdat (take2)  [2/5]  for_each_bootmem
Message-Id: <20060225150749.99ad7d3b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

This patch adds list_head to bootmem_data_t and make bootmems use it.
bootmem list is sorted by node_boot_start.

Only nodes against which init_bootmem() is called are linked to the list.
(i386 allocates bootmem only from one node(0) not from all online nodes.)

A summary:
 1. for_each_online_pgdat() traverses all *online* nodes.
 2. alloc_bootmem() allocates memory only from initialized-for-bootmem nodes.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: linux-2.6.16-rc4-mm2/include/linux/bootmem.h
===================================================================
--- linux-2.6.16-rc4-mm2.orig/include/linux/bootmem.h
+++ linux-2.6.16-rc4-mm2/include/linux/bootmem.h
@@ -38,6 +38,7 @@ typedef struct bootmem_data {
 	unsigned long last_pos;
 	unsigned long last_success;	/* Previous allocation point.  To speed
 					 * up searching */
+	struct list_head list;
 } bootmem_data_t;
 
 extern unsigned long __init bootmem_bootmap_pages (unsigned long);
Index: linux-2.6.16-rc4-mm2/mm/bootmem.c
===================================================================
--- linux-2.6.16-rc4-mm2.orig/mm/bootmem.c
+++ linux-2.6.16-rc4-mm2/mm/bootmem.c
@@ -33,6 +33,7 @@ EXPORT_SYMBOL(max_pfn);		/* This is expo
 				 * dma_get_required_mask(), which uses
 				 * it, can be an inline function */
 
+LIST_HEAD(bdata_list);
 #ifdef CONFIG_CRASH_DUMP
 /*
  * If we have booted due to a crash, max_pfn will be a very low value. We need
@@ -52,6 +53,27 @@ unsigned long __init bootmem_bootmap_pag
 
 	return mapsize;
 }
+/*
+ * link bdata in order
+ */
+static void link_bootmem(bootmem_data_t *bdata)
+{
+	bootmem_data_t *ent;
+	if (list_empty(&bdata_list)) {
+		list_add(&bdata->list, &bdata_list);
+		return;
+	}
+	/* insert in order */
+	list_for_each_entry(ent, &bdata_list, list) {
+		if (ent->node_boot_start < ent->node_boot_start) {
+			list_add_tail(&bdata->list, &ent->list);
+			return;
+		}
+	}
+	list_add_tail(&bdata->list, &bdata_list);
+	return;
+}
+
 
 /*
  * Called once to set up the allocator itself.
@@ -62,13 +84,11 @@ static unsigned long __init init_bootmem
 	bootmem_data_t *bdata = pgdat->bdata;
 	unsigned long mapsize = ((end - start)+7)/8;
 
-	pgdat->pgdat_next = pgdat_list;
-	pgdat_list = pgdat;
-
 	mapsize = ALIGN(mapsize, sizeof(long));
 	bdata->node_bootmem_map = phys_to_virt(mapstart << PAGE_SHIFT);
 	bdata->node_boot_start = (start << PAGE_SHIFT);
 	bdata->node_low_pfn = end;
+	link_bootmem(bdata);
 
 	/*
 	 * Initially all pages are reserved - setup_arch() has to
@@ -383,12 +403,11 @@ unsigned long __init free_all_bootmem (v
 
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
@@ -416,11 +435,11 @@ void * __init __alloc_bootmem_node(pg_da
 
 void * __init __alloc_bootmem_low(unsigned long size, unsigned long align, unsigned long goal)
 {
-	pg_data_t *pgdat = pgdat_list;
+	bootmem_data_t *bdata;
 	void *ptr;
 
-	for_each_pgdat(pgdat)
-		if ((ptr = __alloc_bootmem_core(pgdat->bdata, size,
+	list_for_each_entry(bdata, &bdata_list, list)
+		if ((ptr = __alloc_bootmem_core(bdata, size,
 						 align, goal, LOW32LIMIT)))
 			return(ptr);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
