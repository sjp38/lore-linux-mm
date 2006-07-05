Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k65LQF7J023435
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 5 Jul 2006 17:26:15 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k65LPW9M249658
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Wed, 5 Jul 2006 15:25:32 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k65LQEvg016147
	for <linux-mm@kvack.org>; Wed, 5 Jul 2006 15:26:14 -0600
Subject: [Patch] convert i386 NUMA KVA space to bootmem
From: keith mannthey <kmannth@us.ibm.com>
Reply-To: kmannth@us.ibm.com
Content-Type: multipart/mixed; boundary="=-vMTKZZIeLktl5sJPBQI6"
Date: Wed, 05 Jul 2006 14:26:13 -0700
Message-Id: <1152134773.5799.34.camel@keithlap>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, mbligh@mbligh.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

--=-vMTKZZIeLktl5sJPBQI6
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hello Andrew,
  I posted this patch a while ago but I didn't get any feedback.  I
would like to submit this patch to your tree.  
  
  The patch itself addresses a long standing issue of booting with an
initrd on an i386 numa system.  Currently (and always) the numa kva area
is mapped into low memory by finding the end of low memory and moving
that mark down (thus creating space for the kva).  The issue with this
is that Grub loads initrds into this similar space so when the kernel
check the initrd it finds it outside max_low_pfn and disables it (it
thinks the initrd is not mapped into usable memory) thus initrd enabled
kernels can't boot i386 numa :(

  My solution to the problem just converts the numa kva area to use the
bootmem allocator to save it's area (instead of moving the end of low
memory).  Using bootmem allows the kva area to be mapped into more
diverse addresses (not just the end of low memory) and enables the kva
area to be mapped below the initrd if present. 

  I have tested this patch on numaq(no initrd) and summit(initrd) i386
numa based systems.  It was diffed on 2.6.17-git26 but should apply to
just about any recent kernel. 


Signed-off-by:  Keith Mannthey <kmannth@us.ibm.com>


--=-vMTKZZIeLktl5sJPBQI6
Content-Disposition: attachment; filename=patch-2.6.17-numa-kva-v3
Content-Type: text/x-patch; name=patch-2.6.17-numa-kva-v3; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff -urN linux-2.6.17/arch/i386/kernel/setup.c linux-2.6.17-git24/arch/i386/kernel/setup.c
--- linux-2.6.17/arch/i386/kernel/setup.c	2006-07-04 22:35:20.000000000 -0700
+++ linux-2.6.17-git24/arch/i386/kernel/setup.c	2006-07-04 22:27:31.000000000 -0700
@@ -1203,6 +1203,9 @@
 extern void zone_sizes_init(void);
 #endif /* !CONFIG_NEED_MULTIPLE_NODES */
 
+#ifdef CONFIG_NUMA
+extern void numa_kva_reserve(void);
+#endif
 void __init setup_bootmem_allocator(void)
 {
 	unsigned long bootmap_size;
@@ -1258,7 +1261,9 @@
 	 */
 	find_smp_config();
 #endif
-
+#ifdef CONFIG_NUMA
+	numa_kva_reserve();
+#endif 
 #ifdef CONFIG_BLK_DEV_INITRD
 	if (LOADER_TYPE && INITRD_START) {
 		if (INITRD_START + INITRD_SIZE <= (max_low_pfn << PAGE_SHIFT)) {
diff -urN linux-2.6.17/arch/i386/mm/discontig.c linux-2.6.17-git24/arch/i386/mm/discontig.c
--- linux-2.6.17/arch/i386/mm/discontig.c	2006-07-04 22:35:20.000000000 -0700
+++ linux-2.6.17-git24/arch/i386/mm/discontig.c	2006-07-04 22:27:31.000000000 -0700
@@ -117,7 +117,8 @@
 
 void *node_remap_end_vaddr[MAX_NUMNODES];
 void *node_remap_alloc_vaddr[MAX_NUMNODES];
-
+static unsigned long kva_start_pfn;
+static unsigned long kva_pages;
 /*
  * FLAT - support for basic PC memory model with discontig enabled, essentially
  *        a single node with all available processors in it with a flat
@@ -286,7 +287,6 @@
 {
 	int nid;
 	unsigned long system_start_pfn, system_max_low_pfn;
-	unsigned long reserve_pages;
 
 	/*
 	 * When mapping a NUMA machine we allocate the node_mem_map arrays
@@ -298,14 +298,23 @@
 	find_max_pfn();
 	get_memcfg_numa();
 
-	reserve_pages = calculate_numa_remap_pages();
+	kva_pages = calculate_numa_remap_pages();
 
 	/* partially used pages are not usable - thus round upwards */
 	system_start_pfn = min_low_pfn = PFN_UP(init_pg_tables_end);
 
-	system_max_low_pfn = max_low_pfn = find_max_low_pfn() - reserve_pages;
-	printk("reserve_pages = %ld find_max_low_pfn() ~ %ld\n",
-			reserve_pages, max_low_pfn + reserve_pages);
+	kva_start_pfn = find_max_low_pfn() - kva_pages;
+
+#ifdef CONFIG_BLK_DEV_INITRD
+	/* Numa kva area is below the initrd */
+	if (LOADER_TYPE && INITRD_START) 
+		kva_start_pfn = PFN_DOWN(INITRD_START)  - kva_pages;
+#endif 
+	kva_start_pfn -= kva_start_pfn & (PTRS_PER_PTE-1);
+
+	system_max_low_pfn = max_low_pfn = find_max_low_pfn();
+	printk("kva_start_pfn ~ %ld find_max_low_pfn() ~ %ld\n", 
+		kva_start_pfn, max_low_pfn);
 	printk("max_pfn = %ld\n", max_pfn);
 #ifdef CONFIG_HIGHMEM
 	highstart_pfn = highend_pfn = max_pfn;
@@ -323,7 +332,7 @@
 			(ulong) pfn_to_kaddr(max_low_pfn));
 	for_each_online_node(nid) {
 		node_remap_start_vaddr[nid] = pfn_to_kaddr(
-				highstart_pfn + node_remap_offset[nid]);
+				kva_start_pfn + node_remap_offset[nid]);
 		/* Init the node remap allocator */
 		node_remap_end_vaddr[nid] = node_remap_start_vaddr[nid] +
 			(node_remap_size[nid] * PAGE_SIZE);
@@ -338,7 +347,6 @@
 	}
 	printk("High memory starts at vaddr %08lx\n",
 			(ulong) pfn_to_kaddr(highstart_pfn));
-	vmalloc_earlyreserve = reserve_pages * PAGE_SIZE;
 	for_each_online_node(nid)
 		find_max_pfn_node(nid);
 
@@ -348,6 +356,12 @@
 	return max_low_pfn;
 }
 
+void __init numa_kva_reserve (void) 
+{
+	reserve_bootmem(PFN_PHYS(kva_start_pfn),PFN_PHYS(kva_pages));
+
+}
+
 void __init zone_sizes_init(void)
 {
 	int nid;

--=-vMTKZZIeLktl5sJPBQI6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
