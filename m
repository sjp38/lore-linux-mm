Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j1LM3V0D647872
	for <linux-mm@kvack.org>; Mon, 21 Feb 2005 17:03:32 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j1LM3VSi167770
	for <linux-mm@kvack.org>; Mon, 21 Feb 2005 15:03:31 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j1LM3VVY031908
	for <linux-mm@kvack.org>; Mon, 21 Feb 2005 15:03:31 -0700
Subject: Re: [RFC] [Patch] For booting a i386 numa system with no memory in
	a node
From: keith <kmannth@us.ibm.com>
In-Reply-To: <1109018361.21720.3.camel@localhost>
References: <1106881119.2040.122.camel@cog.beaverton.ibm.com>
	 <1106882150.2040.126.camel@cog.beaverton.ibm.com>
	 <1106937253.27125.6.camel@knk>  <1106938993.14330.65.camel@localhost>
	 <1106941547.27125.25.camel@knk>  <1106942832.17936.3.camel@arrakis>
	 <1108611260.9817.1227.camel@knk>  <1108654782.19395.9.camel@localhost>
	 <1108664637.9817.1259.camel@knk>  <1108666091.19395.29.camel@localhost>
	 <1108671423.9817.1266.camel@knk>  <421510E9.3000901@us.ibm.com>
	 <1108677113.32193.8.camel@localhost> <42152690.4030508@us.ibm.com>
	 <9230000.1108666127@flay>  <1108686742.6482.51.camel@localhost>
	 <1109017040.9817.1638.camel@knk>  <1109018361.21720.3.camel@localhost>
Content-Type: multipart/mixed; boundary="=-f0Wkd92f+spAQinj8Xe9"
Message-Id: <1109023409.9817.1667.camel@knk>
Mime-Version: 1.0
Date: Mon, 21 Feb 2005 14:03:30 -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, "Martin J. Bligh" <mbligh@aracnet.com>, matt dobson <colpatch@us.ibm.com>, john stultz <johnstul@us.ibm.com>, Andy Whitcroft <andyw@uk.ibm.com>
List-ID: <linux-mm.kvack.org>

--=-f0Wkd92f+spAQinj8Xe9
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2005-02-21 at 12:39, Dave Hansen wrote:
> On Mon, 2005-02-21 at 12:17 -0800, keith wrote:
> >   Attach is a patch that allows a i386 numa based system to boot without
> > memory in a node.  It deals with the assumption that all nodes have
> > memory.  
> 
> The diff is backwards :)
Opps!  See new attached patch :)

> 
> > -                       if (node_memory_chunk[j].start_pfn >= max_pfn)
> > {
> > -                               printk ("Ignoring chunk of memory
> > reported in the SRAT (could be hot-add zone?)\n");
> > -                               continue;
> > -                       }
> 
> Could you print out the memory ranges, or sizes here?  Also, please add
> a KERN_* level to it.  We might not want this unless the user has booted
> with "debug".
Done.

> 
> > +               if (node_has_online_mem(nid)){
> > +                       if (start > low) {
> 
> Instead of indenting another level, can you just put a continue in the
> loop?  I think it makes it much easier to read.  

I cannot put a continue here.  I know it makes ugly code worse but we
have to call free area_init_node in all cases.   


Keith Mannthey
LTC xSeries

--=-f0Wkd92f+spAQinj8Xe9
Content-Disposition: attachment; filename=patch-2.6.11-rc4-fix_nomem_on_node-v2
Content-Type: text/x-patch; name=patch-2.6.11-rc4-fix_nomem_on_node-v2; charset=
Content-Transfer-Encoding: 7bit

diff -urN linux-2.6.11-rc4.orig/arch/i386/kernel/srat.c linux-2.6.11-rc4-fix7/arch/i386/kernel/srat.c
--- linux-2.6.11-rc4.orig/arch/i386/kernel/srat.c	2005-02-16 17:23:52.000000000 -0800
+++ linux-2.6.11-rc4-fix7/arch/i386/kernel/srat.c	2005-02-21 13:56:28.000000000 -0800
@@ -273,6 +273,17 @@
 		int been_here_before = 0;
 
 		for (j = 0; j < num_memory_chunks; j++){
+			/*
+			 *Only add present memroy to node_end/start_pfn 
+			 *There is no guarantee from the srat that the memory 
+			 *is present at boot time. 
+			 */
+			if (node_memory_chunk[j].start_pfn >= max_pfn) {
+				printk (KERN_INFO "Ignoring chunk of memory reported in the SRAT (could be hot-add zone?)\n");
+				printk (KERN_INFO "chunk is reported from pfn %04x to %04x\n",
+					node_memory_chunk[j].start_pfn, node_memory_chunk[j].end_pfn);
+				continue;
+			}
 			if (node_memory_chunk[j].nid == nid) {
 				if (been_here_before == 0) {
 					node_start_pfn[nid] = node_memory_chunk[j].start_pfn;
diff -urN linux-2.6.11-rc4.orig/arch/i386/mm/discontig.c linux-2.6.11-rc4-fix7/arch/i386/mm/discontig.c
--- linux-2.6.11-rc4.orig/arch/i386/mm/discontig.c	2005-02-16 17:23:52.000000000 -0800
+++ linux-2.6.11-rc4-fix7/arch/i386/mm/discontig.c	2005-02-21 11:40:28.000000000 -0800
@@ -128,7 +128,7 @@
  */
 static void __init allocate_pgdat(int nid)
 {
-	if (nid)
+	if (nid && node_has_online_mem(nid))
 		NODE_DATA(nid) = (pg_data_t *)node_remap_start_vaddr[nid];
 	else {
 		NODE_DATA(nid) = (pg_data_t *)(__va(min_low_pfn << PAGE_SHIFT));
@@ -204,8 +204,10 @@
 		if (nid == 0)
 			continue;
 		/* calculate the size of the mem_map needed in bytes */
-		size = (node_end_pfn[nid] - node_start_pfn[nid] + 1) 
-			* sizeof(struct page) + sizeof(pg_data_t);
+		size = node_end_pfn[nid] - node_start_pfn[nid];
+		if (size)
+			size = (size + 1) * sizeof(struct page) + sizeof(pg_data_t);
+		
 		/* convert size to large (pmd size) pages, rounding up */
 		size = (size + LARGE_PAGE_BYTES - 1) / LARGE_PAGE_BYTES;
 		/* now the roundup is correct, convert to PAGE_SIZE pages */
@@ -242,6 +244,7 @@
 	unsigned long bootmap_size, system_start_pfn, system_max_low_pfn;
 	unsigned long reserve_pages, pfn;
 
+	find_max_pfn();
 	/*
 	 * When mapping a NUMA machine we allocate the node_mem_map arrays
 	 * from node local memory.  They are then mapped directly into KVA
@@ -270,7 +273,6 @@
 	/* partially used pages are not usable - thus round upwards */
 	system_start_pfn = min_low_pfn = PFN_UP(init_pg_tables_end);
 
-	find_max_pfn();
 	system_max_low_pfn = max_low_pfn = find_max_low_pfn() - reserve_pages;
 	printk("reserve_pages = %ld find_max_low_pfn() ~ %ld\n",
 			reserve_pages, max_low_pfn + reserve_pages);
@@ -399,24 +401,27 @@
 
 		max_dma = virt_to_phys((char *)MAX_DMA_ADDRESS) >> PAGE_SHIFT;
 
-		if (start > low) {
+		if (node_has_online_mem(nid)){
+			if (start > low) {
 #ifdef CONFIG_HIGHMEM
-			BUG_ON(start > high);
-			zones_size[ZONE_HIGHMEM] = high - start;
+				BUG_ON(start > high);
+				zones_size[ZONE_HIGHMEM] = high - start;
 #endif
-		} else {
-			if (low < max_dma)
-				zones_size[ZONE_DMA] = low;
-			else {
-				BUG_ON(max_dma > low);
-				BUG_ON(low > high);
-				zones_size[ZONE_DMA] = max_dma;
-				zones_size[ZONE_NORMAL] = low - max_dma;
+			} else {
+				if (low < max_dma)
+					zones_size[ZONE_DMA] = low;
+				else {
+					BUG_ON(max_dma > low);
+					BUG_ON(low > high);
+					zones_size[ZONE_DMA] = max_dma;
+					zones_size[ZONE_NORMAL] = low - max_dma;
 #ifdef CONFIG_HIGHMEM
-				zones_size[ZONE_HIGHMEM] = high - low;
-#endif
+					zones_size[ZONE_HIGHMEM] = high - low;
+#endif	
+				}
 			}
 		}
+		
 		zholes_size = get_zholes_size(nid);
 		/*
 		 * We let the lmem_map for node 0 be allocated from the
diff -urN linux-2.6.11-rc4.orig/include/asm-i386/topology.h linux-2.6.11-rc4-fix7/include/asm-i386/topology.h
--- linux-2.6.11-rc4.orig/include/asm-i386/topology.h	2005-02-16 17:23:58.000000000 -0800
+++ linux-2.6.11-rc4-fix7/include/asm-i386/topology.h	2005-02-21 11:32:10.000000000 -0800
@@ -88,6 +88,16 @@
 	.nr_balance_failed	= 0,			\
 }
 
+extern unsigned long node_start_pfn[];
+extern unsigned long node_end_pfn[];
+
+#define node_has_online_mem(nid) !(node_start_pfn[nid] == node_end_pfn[nid])                 
+/*                                                                            
+inline int __node_has_online_mem(int nid) {
+        return !(node_start_pfn[nid]== node_end_pfn[nid]);
+}
+*/
+
 #else /* !CONFIG_NUMA */
 /*
  * Other i386 platforms should define their own version of the 
diff -urN linux-2.6.11-rc4.orig/include/linux/topology.h linux-2.6.11-rc4-fix7/include/linux/topology.h
--- linux-2.6.11-rc4.orig/include/linux/topology.h	2005-02-16 17:23:58.000000000 -0800
+++ linux-2.6.11-rc4-fix7/include/linux/topology.h	2005-02-21 11:32:10.000000000 -0800
@@ -31,9 +31,12 @@
 #include <linux/bitops.h>
 #include <linux/mmzone.h>
 #include <linux/smp.h>
-
 #include <asm/topology.h>
 
+#ifndef node_has_online_mem
+#define node_has_online_mem(nid) (1)
+#endif
+
 #ifndef nr_cpus_node
 #define nr_cpus_node(node)							\
 	({									\

--=-f0Wkd92f+spAQinj8Xe9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
