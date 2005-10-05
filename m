From: Magnus Damm <magnus@valinux.co.jp>
Message-Id: <20051005083515.4305.16399.sendpatchset@cherry.local>
Subject: [PATCH] i386: nid_zone_sizes_init() update
Date: Wed,  5 Oct 2005 17:35:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Magnus Damm <magnus@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

Broken out nid_zone_sizes_init() change from i386 NUMA emulation code.

Signed-off-by: Magnus Damm <magnus@valinux.co.jp>
---

Applies on top of linux-2.6.14-rc2-git8-mhp1

--- from-0053/arch/i386/kernel/setup.c
+++ to-work/arch/i386/kernel/setup.c	2005-10-04 15:18:54.000000000 +0900
@@ -1215,31 +1215,24 @@ static inline unsigned long max_hardware
 {
 	return virt_to_phys((char *)MAX_DMA_ADDRESS) >> PAGE_SHIFT;
 }
-static inline unsigned long  nid_size_pages(int nid)
-{
-	return node_end_pfn[nid] - node_start_pfn[nid];
-}
-static inline int nid_starts_in_highmem(int nid)
-{
-	return node_start_pfn[nid] >= max_low_pfn;
-}
 
 void __init nid_zone_sizes_init(int nid)
 {
 	unsigned long zones_size[MAX_NR_ZONES] = {0, 0, 0};
-	unsigned long max_dma;
+	unsigned long max_dma = min(max_hardware_dma_pfn(), max_low_pfn);
 	unsigned long start = node_start_pfn[nid];
 	unsigned long end = node_end_pfn[nid];
 
 	if (node_has_online_mem(nid)){
-		if (nid_starts_in_highmem(nid)) {
-			zones_size[ZONE_HIGHMEM] = nid_size_pages(nid);
-		} else {
-			max_dma = min(max_hardware_dma_pfn(), max_low_pfn);
-			zones_size[ZONE_DMA] = max_dma;
-			zones_size[ZONE_NORMAL] = max_low_pfn - max_dma;
-			zones_size[ZONE_HIGHMEM] = end - max_low_pfn;
+		if (start < max_dma) {
+			zones_size[ZONE_DMA] = min(end, max_dma) - start;
+		}
+		if (start < max_low_pfn && max_dma < end) {
+			zones_size[ZONE_NORMAL] = min(end, max_low_pfn) - max(start, max_dma);
 		}
+		if (max_low_pfn <= end) {
+			zones_size[ZONE_HIGHMEM] = end - max(start, max_low_pfn);
+               }
 	}
 
 	free_area_init_node(nid, NODE_DATA(nid), zones_size, start,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
