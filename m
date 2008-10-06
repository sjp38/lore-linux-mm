Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m96LhfuF018250
	for <linux-mm@kvack.org>; Mon, 6 Oct 2008 17:43:41 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m96Lhf6f249076
	for <linux-mm@kvack.org>; Mon, 6 Oct 2008 17:43:41 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m96LhfNr005514
	for <linux-mm@kvack.org>; Mon, 6 Oct 2008 17:43:41 -0400
Message-ID: <48EA86B8.7010405@linux.vnet.ibm.com>
Date: Mon, 06 Oct 2008 16:44:24 -0500
From: Jon Tollefson <kniht@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH v2] properly reserve in bootmem the lmb reserved regions that
 cross NUMA nodes
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linuxppc-dev <linuxppc-dev@ozlabs.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Adam Litke <agl@us.ibm.com>, Kumar Gala <galak@kernel.crashing.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>
List-ID: <linux-mm.kvack.org>

If there are multiple reserved memory blocks via lmb_reserve() that are
contiguous addresses and on different NUMA nodes we are losing track of which 
address ranges to reserve in bootmem on which node.  I discovered this 
when I only recently got to try 16GB huge pages on a system with more 
then 2 nodes.

When scanning the device tree in early boot we call lmb_reserve() with 
the addresses of the 16G pages that we find so that the memory doesn't 
get used for something else.  For example the addresses for the pages 
could be 4000000000, 4400000000, 4800000000, 4C00000000, etc - 8 pages, 
one on each of eight nodes.  In the lmb after all the pages have been 
reserved it will look something like the following:

lmb_dump_all:
    memory.cnt            = 0x2
    memory.size           = 0x3e80000000
    memory.region[0x0].base       = 0x0
                      .size     = 0x1e80000000
    memory.region[0x1].base       = 0x4000000000
                      .size     = 0x2000000000
    reserved.cnt          = 0x5
    reserved.size         = 0x3e80000000
    reserved.region[0x0].base       = 0x0
                      .size     = 0x7b5000
    reserved.region[0x1].base       = 0x2a00000
                      .size     = 0x78c000
    reserved.region[0x2].base       = 0x328c000
                      .size     = 0x43000
    reserved.region[0x3].base       = 0xf4e8000
                      .size     = 0xb18000
    reserved.region[0x4].base       = 0x4000000000
                      .size     = 0x2000000000


The reserved.region[0x4] contains the 16G pages.  In 
arch/powerpc/mm/num.c: do_init_bootmem() we loop through each of the 
node numbers looking for the reserved regions that belong to the 
particular node.  It is not able to identify region 0x4 as being a part 
of each of the 8 nodes.  It is assuming that a reserved region is only
on a single node.

This patch takes out the reserved region loop from inside
the loop that goes over each node.  It looks up the active region containing
the start of the reserved region.  If it extends past that active region then
it adjusts the size and gets the next active region containing it.


Signed-off-by: Jon Tollefson <kniht@linux.vnet.ibm.com>
---

Changes:
    -style changes as suggested by Adam Litke


Please consider for 2.6.28.


 arch/powerpc/mm/numa.c |   63 ++++++++++++++++++++++++++++---------------------
 include/linux/mm.h     |    2 +
 mm/page_alloc.c        |   19 ++++++++++++++
 3 files changed, 57 insertions(+), 27 deletions(-)


diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index d9a1813..9a3b0c9 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -837,36 +837,45 @@ void __init do_init_bootmem(void)
 				  start_pfn, end_pfn);
 
 		free_bootmem_with_active_regions(nid, end_pfn);
+	}
 
-		/* Mark reserved regions on this node */
-		for (i = 0; i < lmb.reserved.cnt; i++) {
-			unsigned long physbase = lmb.reserved.region[i].base;
-			unsigned long size = lmb.reserved.region[i].size;
-			unsigned long start_paddr = start_pfn << PAGE_SHIFT;
-			unsigned long end_paddr = end_pfn << PAGE_SHIFT;
-
-			if (early_pfn_to_nid(physbase >> PAGE_SHIFT) != nid &&
-			    early_pfn_to_nid((physbase+size-1) >> PAGE_SHIFT) != nid)
-				continue;
-
-			if (physbase < end_paddr &&
-			    (physbase+size) > start_paddr) {
-				/* overlaps */
-				if (physbase < start_paddr) {
-					size -= start_paddr - physbase;
-					physbase = start_paddr;
-				}
-
-				if (size > end_paddr - physbase)
-					size = end_paddr - physbase;
-
-				dbg("reserve_bootmem %lx %lx\n", physbase,
-				    size);
-				reserve_bootmem_node(NODE_DATA(nid), physbase,
-						     size, BOOTMEM_DEFAULT);
-			}
+	/* Mark reserved regions */
+	for (i = 0; i < lmb.reserved.cnt; i++) {
+		unsigned long physbase = lmb.reserved.region[i].base;
+		unsigned long size = lmb.reserved.region[i].size;
+		unsigned long start_pfn = physbase >> PAGE_SHIFT;
+		unsigned long end_pfn = ((physbase + size - 1) >> PAGE_SHIFT);
+		struct node_active_region *node_ar;
+
+		node_ar = get_node_active_region(start_pfn);
+		while (start_pfn < end_pfn && node_ar != NULL) {
+			/*
+			 * if reserved region extends past active region
+			 * then trim size to active region
+			 */
+			if (end_pfn >= node_ar->end_pfn)
+				size = (node_ar->end_pfn << PAGE_SHIFT)
+					- (start_pfn << PAGE_SHIFT);
+			dbg("reserve_bootmem %lx %lx nid=%d\n", physbase, size,
+				node_ar->nid);
+			reserve_bootmem_node(NODE_DATA(node_ar->nid), physbase,
+						size, BOOTMEM_DEFAULT);
+			/*
+			 * if reserved region extends past the active region
+			 * then get next active region that contains
+			 *        this reserved region
+			 */
+			if (end_pfn >= node_ar->end_pfn) {
+				start_pfn = node_ar->end_pfn;
+				physbase = start_pfn << PAGE_SHIFT;
+				node_ar = get_node_active_region(start_pfn);
+			} else
+				break;
 		}
 
+	}
+
+	for_each_online_node(nid) {
 		sparse_memory_present_with_active_regions(nid);
 	}
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 72a15dc..d186a7e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1020,6 +1020,8 @@ extern void push_node_boundaries(unsigned int nid, unsigned long start_pfn,
 extern void remove_all_active_ranges(void);
 extern unsigned long absent_pages_in_range(unsigned long start_pfn,
 						unsigned long end_pfn);
+struct node_active_region *get_node_active_region(
+						unsigned long start_pfn);
 extern void get_pfn_range_for_nid(unsigned int nid,
 			unsigned long *start_pfn, unsigned long *end_pfn);
 extern unsigned long find_min_pfn_with_active_regions(void);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 27b8681..fbbb759 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3074,6 +3074,25 @@ static void __meminit account_node_boundary(unsigned int nid,
 		unsigned long *start_pfn, unsigned long *end_pfn) {}
 #endif
 
+/**
+ * get_node_active_region - Return active region containing start_pfn
+ * @start_pfn The page to return the region for.
+ *
+ * It will return NULL if active region is not found.
+ */
+struct node_active_region *
+__meminit get_node_active_region(unsigned long start_pfn)
+{
+	int i;
+	for (i = 0; i < nr_nodemap_entries; i++) {
+		unsigned long node_start_pfn = early_node_map[i].start_pfn;
+		unsigned long node_end_pfn = early_node_map[i].end_pfn;
+
+		if (node_start_pfn <= start_pfn && node_end_pfn > start_pfn)
+			return &early_node_map[i];
+	}
+	return NULL;
+}
 
 /**
  * get_pfn_range_for_nid - Return the start and end page frames for a node



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
