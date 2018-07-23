Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id B64B96B0008
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 01:57:15 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id 22-v6so16719631oix.0
        for <linux-mm@kvack.org>; Sun, 22 Jul 2018 22:57:15 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w204-v6si5861420oig.179.2018.07.22.22.57.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Jul 2018 22:57:14 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6N5rw1W053865
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 01:57:14 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2kd8d39qw0-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 01:57:13 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 23 Jul 2018 06:57:12 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 3/4] ia64: use mem_data to detect nodes' minimal and maximal PFNs
Date: Mon, 23 Jul 2018 08:56:57 +0300
In-Reply-To: <1532325418-22617-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1532325418-22617-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1532325418-22617-4-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

When EFI memory map is traversed to determine the extents of each node, the
minimal and maximal PFNs are stored in the bootmem_data structures. The
same information ls later stored in the mem_data array of 'struct
early_node_data'.

Switch to using mem_data from the very beginning.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 arch/ia64/mm/discontig.c | 60 +++++++++++-------------------------------------
 1 file changed, 14 insertions(+), 46 deletions(-)

diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 6148ea8..8e99d8e 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -57,33 +57,31 @@ pg_data_t *pgdat_list[MAX_NUMNODES];
 	     (((node)*PERCPU_PAGE_SIZE) & (MAX_NODE_ALIGN_OFFSET - 1)))
 
 /**
- * build_node_maps - callback to setup bootmem structs for each node
+ * build_node_maps - callback to setup mem_data structs for each node
  * @start: physical start of range
  * @len: length of range
  * @node: node where this range resides
  *
- * We allocate a struct bootmem_data for each piece of memory that we wish to
+ * Detect extents of each piece of memory that we wish to
  * treat as a virtually contiguous block (i.e. each node). Each such block
  * must start on an %IA64_GRANULE_SIZE boundary, so we round the address down
  * if necessary.  Any non-existent pages will simply be part of the virtual
- * memmap.  We also update min_low_pfn and max_low_pfn here as we receive
- * memory ranges from the caller.
+ * memmap.
  */
 static int __init build_node_maps(unsigned long start, unsigned long len,
 				  int node)
 {
 	unsigned long spfn, epfn, end = start + len;
-	struct bootmem_data *bdp = &bootmem_node_data[node];
 
 	epfn = GRANULEROUNDUP(end) >> PAGE_SHIFT;
 	spfn = GRANULEROUNDDOWN(start) >> PAGE_SHIFT;
 
-	if (!bdp->node_low_pfn) {
-		bdp->node_min_pfn = spfn;
-		bdp->node_low_pfn = epfn;
+	if (!mem_data[node].min_pfn) {
+		mem_data[node].min_pfn = spfn;
+		mem_data[node].max_pfn = epfn;
 	} else {
-		bdp->node_min_pfn = min(spfn, bdp->node_min_pfn);
-		bdp->node_low_pfn = max(epfn, bdp->node_low_pfn);
+		mem_data[node].min_pfn = min(spfn, mem_data[node].min_pfn);
+		mem_data[node].max_pfn = max(epfn, mem_data[node].max_pfn);
 	}
 
 	return 0;
@@ -323,19 +321,18 @@ static int __init find_pernode_space(unsigned long start, unsigned long len,
 {
 	unsigned long spfn, epfn;
 	unsigned long pernodesize = 0, pernode, pages, mapsize;
-	struct bootmem_data *bdp = &bootmem_node_data[node];
 
 	spfn = start >> PAGE_SHIFT;
 	epfn = (start + len) >> PAGE_SHIFT;
 
-	pages = bdp->node_low_pfn - bdp->node_min_pfn;
+	pages = mem_data[node].max_pfn - mem_data[node].min_pfn;
 	mapsize = bootmem_bootmap_pages(pages) << PAGE_SHIFT;
 
 	/*
 	 * Make sure this memory falls within this node's usable memory
 	 * since we may have thrown some away in build_maps().
 	 */
-	if (spfn < bdp->node_min_pfn || epfn > bdp->node_low_pfn)
+	if (spfn < mem_data[node].min_pfn || epfn > mem_data[node].max_pfn)
 		return 0;
 
 	/* Don't setup this node's local space twice... */
@@ -397,7 +394,7 @@ static void __init reserve_pernode_space(void)
 		bdp = pdp->bdata;
 
 		/* First the bootmem_map itself */
-		pages = bdp->node_low_pfn - bdp->node_min_pfn;
+		pages = mem_data[node].max_pfn - mem_data[node].min_pfn;
 		size = bootmem_bootmap_pages(pages) << PAGE_SHIFT;
 		base = __pa(bdp->node_bootmem_map);
 		reserve_bootmem_node(pdp, base, size, BOOTMEM_DEFAULT);
@@ -541,10 +538,8 @@ void __init find_memory(void)
 	efi_memmap_walk(find_max_min_low_pfn, NULL);
 
 	for_each_online_node(node)
-		if (bootmem_node_data[node].node_low_pfn) {
+		if (mem_data[node].min_pfn)
 			node_clear(node, memory_less_mask);
-			mem_data[node].min_pfn = ~0UL;
-		}
 
 	efi_memmap_walk(filter_memory, register_active_ranges);
 
@@ -568,8 +563,8 @@ void __init find_memory(void)
 
 		init_bootmem_node(pgdat_list[node],
 				  map>>PAGE_SHIFT,
-				  bdp->node_min_pfn,
-				  bdp->node_low_pfn);
+				  mem_data[node].min_pfn,
+				  mem_data[node].max_pfn);
 	}
 
 	efi_memmap_walk(filter_rsvd_memory, free_node_bootmem);
@@ -652,31 +647,6 @@ void call_pernode_memory(unsigned long start, unsigned long len, void *arg)
 }
 
 /**
- * count_node_pages - callback to build per-node memory info structures
- * @start: physical start of range
- * @len: length of range
- * @node: node where this range resides
- *
- * Each node has it's own number of physical pages, DMAable pages, start, and
- * end page frame number.  This routine will be called by call_pernode_memory()
- * for each piece of usable memory and will setup these values for each node.
- * Very similar to build_maps().
- */
-static __init int count_node_pages(unsigned long start, unsigned long len, int node)
-{
-	unsigned long end = start + len;
-
-	start = GRANULEROUNDDOWN(start);
-	end = GRANULEROUNDUP(end);
-	mem_data[node].max_pfn = max(mem_data[node].max_pfn,
-				     end >> PAGE_SHIFT);
-	mem_data[node].min_pfn = min(mem_data[node].min_pfn,
-				     start >> PAGE_SHIFT);
-
-	return 0;
-}
-
-/**
  * paging_init - setup page tables
  *
  * paging_init() sets up the page tables for each node of the system and frees
@@ -692,8 +662,6 @@ void __init paging_init(void)
 
 	max_dma = virt_to_phys((void *) MAX_DMA_ADDRESS) >> PAGE_SHIFT;
 
-	efi_memmap_walk(filter_rsvd_memory, count_node_pages);
-
 	sparse_memory_present_with_active_regions(MAX_NUMNODES);
 	sparse_init();
 
-- 
2.7.4
