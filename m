Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id EDBEF6B0055
	for <linux-mm@kvack.org>; Sat, 12 Oct 2013 17:59:39 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so5835018pdj.18
        for <linux-mm@kvack.org>; Sat, 12 Oct 2013 14:59:39 -0700 (PDT)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [RFC 13/23] mm/lib: Use memblock apis for early memory allocations
Date: Sat, 12 Oct 2013 17:58:56 -0400
Message-ID: <1381615146-20342-14-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1381615146-20342-1-git-send-email-santosh.shilimkar@ti.com>
References: <1381615146-20342-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, yinghai@kernel.org
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, grygorii.strashko@ti.com, Santosh Shilimkar <santosh.shilimkar@ti.com>, Andrew Morton <akpm@linux-foundation.org>

Switch to memblock interfaces for early memory allocator

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>

Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 lib/swiotlb.c |   30 ++++++++++++++++--------------
 1 file changed, 16 insertions(+), 14 deletions(-)

diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index 4e8686c..504de6d 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -169,7 +169,7 @@ int __init swiotlb_init_with_tbl(char *tlb, unsigned long nslabs, int verbose)
 	/*
 	 * Get the overflow emergency buffer
 	 */
-	v_overflow_buffer = alloc_bootmem_low_pages_nopanic(
+	v_overflow_buffer = memblock_early_alloc_pages_nopanic(
 						PAGE_ALIGN(io_tlb_overflow));
 	if (!v_overflow_buffer)
 		return -ENOMEM;
@@ -181,11 +181,13 @@ int __init swiotlb_init_with_tbl(char *tlb, unsigned long nslabs, int verbose)
 	 * to find contiguous free memory regions of size up to IO_TLB_SEGSIZE
 	 * between io_tlb_start and io_tlb_end.
 	 */
-	io_tlb_list = alloc_bootmem_pages(PAGE_ALIGN(io_tlb_nslabs * sizeof(int)));
+	io_tlb_list = memblock_early_alloc_pages(
+				PAGE_ALIGN(io_tlb_nslabs * sizeof(int)));
 	for (i = 0; i < io_tlb_nslabs; i++)
  		io_tlb_list[i] = IO_TLB_SEGSIZE - OFFSET(i, IO_TLB_SEGSIZE);
 	io_tlb_index = 0;
-	io_tlb_orig_addr = alloc_bootmem_pages(PAGE_ALIGN(io_tlb_nslabs * sizeof(phys_addr_t)));
+	io_tlb_orig_addr = memblock_early_alloc_pages(
+				PAGE_ALIGN(io_tlb_nslabs * sizeof(phys_addr_t)));
 
 	if (verbose)
 		swiotlb_print_info();
@@ -212,13 +214,13 @@ swiotlb_init(int verbose)
 	bytes = io_tlb_nslabs << IO_TLB_SHIFT;
 
 	/* Get IO TLB memory from the low pages */
-	vstart = alloc_bootmem_low_pages_nopanic(PAGE_ALIGN(bytes));
+	vstart = memblock_early_alloc_pages_nopanic(PAGE_ALIGN(bytes));
 	if (vstart && !swiotlb_init_with_tbl(vstart, io_tlb_nslabs, verbose))
 		return;
 
 	if (io_tlb_start)
-		free_bootmem(io_tlb_start,
-				 PAGE_ALIGN(io_tlb_nslabs << IO_TLB_SHIFT));
+		memblock_free_early(io_tlb_start,
+				    PAGE_ALIGN(io_tlb_nslabs << IO_TLB_SHIFT));
 	pr_warn("Cannot allocate SWIOTLB buffer");
 	no_iotlb_memory = true;
 }
@@ -354,14 +356,14 @@ void __init swiotlb_free(void)
 		free_pages((unsigned long)phys_to_virt(io_tlb_start),
 			   get_order(io_tlb_nslabs << IO_TLB_SHIFT));
 	} else {
-		free_bootmem_late(io_tlb_overflow_buffer,
-				  PAGE_ALIGN(io_tlb_overflow));
-		free_bootmem_late(__pa(io_tlb_orig_addr),
-				  PAGE_ALIGN(io_tlb_nslabs * sizeof(phys_addr_t)));
-		free_bootmem_late(__pa(io_tlb_list),
-				  PAGE_ALIGN(io_tlb_nslabs * sizeof(int)));
-		free_bootmem_late(io_tlb_start,
-				  PAGE_ALIGN(io_tlb_nslabs << IO_TLB_SHIFT));
+		memblock_free_late(io_tlb_overflow_buffer,
+				   PAGE_ALIGN(io_tlb_overflow));
+		memblock_free_late(__pa(io_tlb_orig_addr),
+				   PAGE_ALIGN(io_tlb_nslabs * sizeof(phys_addr_t)));
+		memblock_free_late(__pa(io_tlb_list),
+				   PAGE_ALIGN(io_tlb_nslabs * sizeof(int)));
+		memblock_free_late(io_tlb_start,
+				   PAGE_ALIGN(io_tlb_nslabs << IO_TLB_SHIFT));
 	}
 	io_tlb_nslabs = 0;
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
