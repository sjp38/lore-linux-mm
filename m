Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j1LKHM0D651860
	for <linux-mm@kvack.org>; Mon, 21 Feb 2005 15:17:23 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j1LKHM8D144648
	for <linux-mm@kvack.org>; Mon, 21 Feb 2005 13:17:22 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j1LKHLLv017149
	for <linux-mm@kvack.org>; Mon, 21 Feb 2005 13:17:22 -0700
Subject: [RFC] [Patch] For booting a i386 numa system with no memory in a
	node
From: keith <kmannth@us.ibm.com>
In-Reply-To: <1108686742.6482.51.camel@localhost>
References: <1106881119.2040.122.camel@cog.beaverton.ibm.com>
	 <1106882150.2040.126.camel@cog.beaverton.ibm.com>
	 <1106937253.27125.6.camel@knk>  <1106938993.14330.65.camel@localhost>
	 <1106941547.27125.25.camel@knk>  <1106942832.17936.3.camel@arrakis>
	 <1108611260.9817.1227.camel@knk>  <1108654782.19395.9.camel@localhost>
	 <1108664637.9817.1259.camel@knk>  <1108666091.19395.29.camel@localhost>
	 <1108671423.9817.1266.camel@knk>  <421510E9.3000901@us.ibm.com>
	 <1108677113.32193.8.camel@localhost> <42152690.4030508@us.ibm.com>
	 <9230000.1108666127@flay>  <1108686742.6482.51.camel@localhost>
Content-Type: multipart/mixed; boundary="=-xpvqF6pjZHOh/l/REXbz"
Message-Id: <1109017040.9817.1638.camel@knk>
Mime-Version: 1.0
Date: Mon, 21 Feb 2005 12:17:20 -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, matt dobson <colpatch@us.ibm.com>, john stultz <johnstul@us.ibm.com>, Andy Whitcroft <andyw@uk.ibm.com>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

--=-xpvqF6pjZHOh/l/REXbz
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

  Attach is a patch that allows a i386 numa based system to boot without
memory in a node.  It deals with the assumption that all nodes have
memory.  
  
  In a summit based system (IBM x440/x445) is is possible to configure a
box with no memory is a node.  While this is not an ideal performance
setup it is a valid configuration for the box and the kernel should be
able to deal with it.  

 This "memory free node" must not be node 0.  Node 0 must still contain
memory (there are tons of hard coded 0's in the mm code so I am steering
around this for now).

  The assumption that all nodes have memory is not always true.  I have
introduced a simple node_has_online_mem functionality in the topology
code.  This check is based on 
node_start_pfn[nid] == node_end_pfn[nid] 
and as such the node_start/end_pfn must only contain physically present
memory.  

 I presented a patch a while ago that allowed non-present memory
reported from the srat to be ignored at the numa KVA level.  This patch
takes that a set further.  Ignore the memory above max_pfn altogether.  

  This main issues this patch address is fixing the numa_kva code as it
was built without this no-memory node in mind.

  It was tested with 2.6.11-rc4 on a 8-way x445 (summit) with no memory
in the 2nd node.  It supports both a physically empty and  SRAT based
hot-add empty zones just fine.  

Thanks,
  Keith Mannthey
  LTC xSeries   

--=-xpvqF6pjZHOh/l/REXbz
Content-Disposition: attachment; filename=patch-2.6.11-rc4-fix_nomem_on_node-v1
Content-Type: text/x-patch; name=patch-2.6.11-rc4-fix_nomem_on_node-v1; charset=
Content-Transfer-Encoding: 7bit

diff -urN linux-2.6.11-rc4-fix7/arch/i386/kernel/srat.c linux-2.6.11-rc4.orig/arch/i386/kernel/srat.c
--- linux-2.6.11-rc4-fix7/arch/i386/kernel/srat.c	2005-02-21 11:39:59.000000000 -0800
+++ linux-2.6.11-rc4.orig/arch/i386/kernel/srat.c	2005-02-16 17:23:52.000000000 -0800
@@ -273,14 +273,6 @@
 		int been_here_before = 0;
 
 		for (j = 0; j < num_memory_chunks; j++){
-			/*
-			 *Only add present memroy to node_end/start_pfn 
-			 *There is no guarantee from the srat that the memory is present
-			 */
-			if (node_memory_chunk[j].start_pfn >= max_pfn) {
-				printk ("Ignoring chunk of memory reported in the SRAT (could be hot-add zone?)\n");
-				continue;
-			}
 			if (node_memory_chunk[j].nid == nid) {
 				if (been_here_before == 0) {
 					node_start_pfn[nid] = node_memory_chunk[j].start_pfn;
diff -urN linux-2.6.11-rc4-fix7/arch/i386/mm/discontig.c linux-2.6.11-rc4.orig/arch/i386/mm/discontig.c
--- linux-2.6.11-rc4-fix7/arch/i386/mm/discontig.c	2005-02-21 11:40:28.000000000 -0800
+++ linux-2.6.11-rc4.orig/arch/i386/mm/discontig.c	2005-02-16 17:23:52.000000000 -0800
@@ -128,7 +128,7 @@
  */
 static void __init allocate_pgdat(int nid)
 {
-	if (nid && node_has_online_mem(nid))
+	if (nid)
 		NODE_DATA(nid) = (pg_data_t *)node_remap_start_vaddr[nid];
 	else {
 		NODE_DATA(nid) = (pg_data_t *)(__va(min_low_pfn << PAGE_SHIFT));
@@ -204,10 +204,8 @@
 		if (nid == 0)
 			continue;
 		/* calculate the size of the mem_map needed in bytes */
-		size = node_end_pfn[nid] - node_start_pfn[nid];
-		if (size)
-			size = (size + 1) * sizeof(struct page) + sizeof(pg_data_t);
-		
+		size = (node_end_pfn[nid] - node_start_pfn[nid] + 1) 
+			* sizeof(struct page) + sizeof(pg_data_t);
 		/* convert size to large (pmd size) pages, rounding up */
 		size = (size + LARGE_PAGE_BYTES - 1) / LARGE_PAGE_BYTES;
 		/* now the roundup is correct, convert to PAGE_SIZE pages */
@@ -244,7 +242,6 @@
 	unsigned long bootmap_size, system_start_pfn, system_max_low_pfn;
 	unsigned long reserve_pages, pfn;
 
-	find_max_pfn();
 	/*
 	 * When mapping a NUMA machine we allocate the node_mem_map arrays
 	 * from node local memory.  They are then mapped directly into KVA
@@ -273,6 +270,7 @@
 	/* partially used pages are not usable - thus round upwards */
 	system_start_pfn = min_low_pfn = PFN_UP(init_pg_tables_end);
 
+	find_max_pfn();
 	system_max_low_pfn = max_low_pfn = find_max_low_pfn() - reserve_pages;
 	printk("reserve_pages = %ld find_max_low_pfn() ~ %ld\n",
 			reserve_pages, max_low_pfn + reserve_pages);
@@ -401,27 +399,24 @@
 
 		max_dma = virt_to_phys((char *)MAX_DMA_ADDRESS) >> PAGE_SHIFT;
 
-		if (node_has_online_mem(nid)){
-			if (start > low) {
+		if (start > low) {
 #ifdef CONFIG_HIGHMEM
-				BUG_ON(start > high);
-				zones_size[ZONE_HIGHMEM] = high - start;
+			BUG_ON(start > high);
+			zones_size[ZONE_HIGHMEM] = high - start;
 #endif
-			} else {
-				if (low < max_dma)
-					zones_size[ZONE_DMA] = low;
-				else {
-					BUG_ON(max_dma > low);
-					BUG_ON(low > high);
-					zones_size[ZONE_DMA] = max_dma;
-					zones_size[ZONE_NORMAL] = low - max_dma;
+		} else {
+			if (low < max_dma)
+				zones_size[ZONE_DMA] = low;
+			else {
+				BUG_ON(max_dma > low);
+				BUG_ON(low > high);
+				zones_size[ZONE_DMA] = max_dma;
+				zones_size[ZONE_NORMAL] = low - max_dma;
 #ifdef CONFIG_HIGHMEM
-					zones_size[ZONE_HIGHMEM] = high - low;
-#endif	
-				}
+				zones_size[ZONE_HIGHMEM] = high - low;
+#endif
 			}
 		}
-		
 		zholes_size = get_zholes_size(nid);
 		/*
 		 * We let the lmem_map for node 0 be allocated from the
diff -urN linux-2.6.11-rc4-fix7/include/asm-i386/topology.h linux-2.6.11-rc4.orig/include/asm-i386/topology.h
--- linux-2.6.11-rc4-fix7/include/asm-i386/topology.h	2005-02-21 11:32:10.000000000 -0800
+++ linux-2.6.11-rc4.orig/include/asm-i386/topology.h	2005-02-16 17:23:58.000000000 -0800
@@ -88,16 +88,6 @@
 	.nr_balance_failed	= 0,			\
 }
 
-extern unsigned long node_start_pfn[];
-extern unsigned long node_end_pfn[];
-
-#define node_has_online_mem(nid) !(node_start_pfn[nid] == node_end_pfn[nid])                 
-/*                                                                            
-inline int __node_has_online_mem(int nid) {
-        return !(node_start_pfn[nid]== node_end_pfn[nid]);
-}
-*/
-
 #else /* !CONFIG_NUMA */
 /*
  * Other i386 platforms should define their own version of the 
diff -urN linux-2.6.11-rc4-fix7/include/linux/topology.h linux-2.6.11-rc4.orig/include/linux/topology.h
--- linux-2.6.11-rc4-fix7/include/linux/topology.h	2005-02-21 11:32:10.000000000 -0800
+++ linux-2.6.11-rc4.orig/include/linux/topology.h	2005-02-16 17:23:58.000000000 -0800
@@ -31,11 +31,8 @@
 #include <linux/bitops.h>
 #include <linux/mmzone.h>
 #include <linux/smp.h>
-#include <asm/topology.h>
 
-#ifndef node_has_online_mem
-#define node_has_online_mem(nid) (1)
-#endif
+#include <asm/topology.h>
 
 #ifndef nr_cpus_node
 #define nr_cpus_node(node)							\

--=-xpvqF6pjZHOh/l/REXbz--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
