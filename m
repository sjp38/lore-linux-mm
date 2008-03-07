From: Andi Kleen <andi@firstfloor.org>
References: <200803071007.493903088@firstfloor.org>
In-Reply-To: <200803071007.493903088@firstfloor.org>
Subject: [PATCH] [9/13] Remove set_dma_reserve
Message-Id: <20080307090719.AA15E1B419C@basil.firstfloor.org>
Date: Fri,  7 Mar 2008 10:07:19 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

x86 was the only user and that one doesn't use it anymore since it was converted
to mask alloc. So remove it.
Signed-off-by: Andi Kleen <ak@suse.de>

---
 include/linux/mm.h |    1 -
 mm/page_alloc.c    |   24 ------------------------
 2 files changed, 25 deletions(-)

Index: linux/mm/page_alloc.c
===================================================================
--- linux.orig/mm/page_alloc.c
+++ linux/mm/page_alloc.c
@@ -120,7 +120,6 @@ int min_free_kbytes = 1024;
 
 unsigned long __meminitdata nr_kernel_pages;
 unsigned long __meminitdata nr_all_pages;
-static unsigned long __meminitdata dma_reserve;
 
 #ifdef CONFIG_ARCH_POPULATES_NODE_MAP
   /*
@@ -3321,13 +3320,6 @@ static void __paginginit free_area_init_
 				"  %s zone: %lu pages exceeds realsize %lu\n",
 				zone_names[j], memmap_pages, realsize);
 
-		/* Account for reserved pages */
-		if (j == 0 && realsize > dma_reserve) {
-			realsize -= dma_reserve;
-			printk(KERN_DEBUG "  %s zone: %lu pages reserved\n",
-					zone_names[0], dma_reserve);
-		}
-
 		if (!is_highmem_idx(j))
 			nr_kernel_pages += realsize;
 		nr_all_pages += realsize;
@@ -3906,22 +3898,6 @@ early_param("movablecore", cmdline_parse
 
 #endif /* CONFIG_ARCH_POPULATES_NODE_MAP */
 
-/**
- * set_dma_reserve - set the specified number of pages reserved in the first zone
- * @new_dma_reserve: The number of pages to mark reserved
- *
- * The per-cpu batchsize and zone watermarks are determined by present_pages.
- * In the DMA zone, a significant percentage may be consumed by kernel image
- * and other unfreeable allocations which can skew the watermarks badly. This
- * function may optionally be used to account for unfreeable pages in the
- * first zone (e.g., ZONE_DMA). The effect will be lower watermarks and
- * smaller per-cpu batchsize.
- */
-void __init set_dma_reserve(unsigned long new_dma_reserve)
-{
-	dma_reserve = new_dma_reserve;
-}
-
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 static bootmem_data_t contig_bootmem_data;
 struct pglist_data contig_page_data = { .bdata = &contig_bootmem_data };
Index: linux/include/linux/mm.h
===================================================================
--- linux.orig/include/linux/mm.h
+++ linux/include/linux/mm.h
@@ -987,7 +987,6 @@ extern void sparse_memory_present_with_a
 extern int early_pfn_to_nid(unsigned long pfn);
 #endif /* CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID */
 #endif /* CONFIG_ARCH_POPULATES_NODE_MAP */
-extern void set_dma_reserve(unsigned long new_dma_reserve);
 extern void memmap_init_zone(unsigned long, int, unsigned long,
 				unsigned long, enum memmap_context);
 extern void setup_per_zone_pages_min(void);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
