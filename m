Subject: 050 bootmem use NODE_DATA
In-Reply-To: <4173D219.3010706@shadowen.org>
Message-Id: <E1CJYYn-0000Zk-4w@ladymac.shadowen.org>
From: Andy Whitcroft <apw@shadowen.org>
Date: Mon, 18 Oct 2004 15:32:29 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: apw@shadowen.org, lhms-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Convert the default non-node based bootmem routines to use
NODE_DATA(0).  This is semantically and functionally identical in
any non-node configuration as NODE_DATA(x) is defined as below.

#define NODE_DATA(nid)          (&contig_page_data)

For the node cases (CONFIG_NUMA and CONFIG_DISCONTIG_MEM) we can
use these non-node forms where all boot memory is defined on node 0.

Revision: $Rev$

Signed-off-by: Andy Whitcroft <apw@shadowen.org>

diffstat 050-bootmem-use-NODE_DATA
---
 bootmem.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff -upN reference/mm/bootmem.c current/mm/bootmem.c
--- reference/mm/bootmem.c
+++ current/mm/bootmem.c
@@ -343,31 +343,29 @@ unsigned long __init free_all_bootmem_no
 	return(free_all_bootmem_core(pgdat));
 }
 
-#ifndef CONFIG_DISCONTIGMEM
 unsigned long __init init_bootmem (unsigned long start, unsigned long pages)
 {
 	max_low_pfn = pages;
 	min_low_pfn = start;
-	return(init_bootmem_core(&contig_page_data, start, 0, pages));
+	return(init_bootmem_core(NODE_DATA(0), start, 0, pages));
 }
 
 #ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
 void __init reserve_bootmem (unsigned long addr, unsigned long size)
 {
-	reserve_bootmem_core(contig_page_data.bdata, addr, size);
+	reserve_bootmem_core(NODE_DATA(0)->bdata, addr, size);
 }
 #endif /* !CONFIG_HAVE_ARCH_BOOTMEM_NODE */
 
 void __init free_bootmem (unsigned long addr, unsigned long size)
 {
-	free_bootmem_core(contig_page_data.bdata, addr, size);
+	free_bootmem_core(NODE_DATA(0)->bdata, addr, size);
 }
 
 unsigned long __init free_all_bootmem (void)
 {
-	return(free_all_bootmem_core(&contig_page_data));
+	return(free_all_bootmem_core(NODE_DATA(0)));
 }
-#endif /* !CONFIG_DISCONTIGMEM */
 
 void * __init __alloc_bootmem (unsigned long size, unsigned long align, unsigned long goal)
 {
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
