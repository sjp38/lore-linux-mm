Received: from m7.gw.fujitsu.co.jp ([10.0.50.77])
        by fgwmail6.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k1LC9Fiu015414 for <linux-mm@kvack.org>; Tue, 21 Feb 2006 21:09:15 +0900
        (envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s7.gw.fujitsu.co.jp by m7.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k1LC9EWg009764 for <linux-mm@kvack.org>; Tue, 21 Feb 2006 21:09:14 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s7.gw.fujitsu.co.jp (s7 [127.0.0.1])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id ADA542C8102
	for <linux-mm@kvack.org>; Tue, 21 Feb 2006 21:09:14 +0900 (JST)
Received: from fjm504.ms.jp.fujitsu.com (fjm504.ms.jp.fujitsu.com [10.56.99.80])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id 691AA2C80FF
	for <linux-mm@kvack.org>; Tue, 21 Feb 2006 21:09:14 +0900 (JST)
Received: from [127.0.0.1] (fjmscan501.ms.jp.fujitsu.com [10.56.99.141])by fjm504.ms.jp.fujitsu.com with ESMTP id k1LC8WRF015725
	for <linux-mm@kvack.org>; Tue, 21 Feb 2006 21:08:33 +0900
Message-ID: <43FB0329.3070105@jp.fujitsu.com>
Date: Tue, 21 Feb 2006 21:10:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC][PATCH] bdata and pgdat initialization cleanup [5/5]  i386 changes
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

i386 changes.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyyu@jp.fujitsu.com>
Index: testtree/arch/i386/mm/discontig.c
===================================================================
--- testtree.orig/arch/i386/mm/discontig.c
+++ testtree/arch/i386/mm/discontig.c
@@ -39,7 +39,6 @@

  struct pglist_data *node_data[MAX_NUMNODES] __read_mostly;
  EXPORT_SYMBOL(node_data);
-bootmem_data_t node0_bdata;

  /*
   * numa interface - we expect the numa architecture specfic code to have
@@ -343,7 +342,6 @@ unsigned long __init setup_memory(void)
  		find_max_pfn_node(nid);

  	memset(NODE_DATA(0), 0, sizeof(struct pglist_data));
-	NODE_DATA(0)->bdata = &node0_bdata;
  	setup_bootmem_allocator();
  	return max_low_pfn;
  }
@@ -352,17 +350,6 @@ void __init zone_sizes_init(void)
  {
  	int nid;

-	/*
-	 * Insert nodes into pgdat_list backward so they appear in order.
-	 * Clobber node 0's links and NULL out pgdat_list before starting.
-	 */
-	pgdat_list = NULL;
-	for (nid = MAX_NUMNODES - 1; nid >= 0; nid--) {
-		if (!node_online(nid))
-			continue;
-		NODE_DATA(nid)->pgdat_next = pgdat_list;
-		pgdat_list = NODE_DATA(nid);
-	}

  	for_each_online_node(nid) {
  		unsigned long zones_size[MAX_NR_ZONES] = {0, 0, 0};
Index: testtree/include/asm-i386/mmzone.h
===================================================================
--- testtree.orig/include/asm-i386/mmzone.h
+++ testtree/include/asm-i386/mmzone.h
@@ -99,28 +99,7 @@ static inline int pfn_valid(int pfn)

  #endif /* CONFIG_DISCONTIGMEM */

-#ifdef CONFIG_NEED_MULTIPLE_NODES
-
-/*
- * Following are macros that are specific to this numa platform.
- */
-#define reserve_bootmem(addr, size) \
-	reserve_bootmem_node(NODE_DATA(0), (addr), (size))
-#define alloc_bootmem(x) \
-	__alloc_bootmem_node(NODE_DATA(0), (x), SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
-#define alloc_bootmem_low(x) \
-	__alloc_bootmem_node(NODE_DATA(0), (x), SMP_CACHE_BYTES, 0)
-#define alloc_bootmem_pages(x) \
-	__alloc_bootmem_node(NODE_DATA(0), (x), PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
-#define alloc_bootmem_low_pages(x) \
-	__alloc_bootmem_node(NODE_DATA(0), (x), PAGE_SIZE, 0)
-#define alloc_bootmem_node(ignore, x) \
-	__alloc_bootmem_node(NODE_DATA(0), (x), SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
-#define alloc_bootmem_pages_node(ignore, x) \
-	__alloc_bootmem_node(NODE_DATA(0), (x), PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
-#define alloc_bootmem_low_pages_node(ignore, x) \
-	__alloc_bootmem_node(NODE_DATA(0), (x), PAGE_SIZE, 0)
-
-#endif /* CONFIG_NEED_MULTIPLE_NODES */
+/* always allocate bootmem from node0 */
+#define BOOTMEM(nid)	&bootmem[0]

  #endif /* _ASM_MMZONE_H_ */
Index: testtree/arch/i386/Kconfig
===================================================================
--- testtree.orig/arch/i386/Kconfig
+++ testtree/arch/i386/Kconfig
@@ -533,11 +533,6 @@ comment "NUMA (NUMA-Q) requires SMP, 64G
  comment "NUMA (Summit) requires SMP, 64GB highmem support, ACPI"
  	depends on X86_SUMMIT && (!HIGHMEM64G || !ACPI)

-config HAVE_ARCH_BOOTMEM_NODE
-	bool
-	depends on NUMA
-	default y
-
  config ARCH_HAVE_MEMORY_PRESENT
  	bool
  	depends on DISCONTIGMEM

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
