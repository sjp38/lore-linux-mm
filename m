Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id D520C6B0087
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 21:28:59 -0500 (EST)
Received: by mail-qc0-f176.google.com with SMTP id i8so1500346qcq.21
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 18:28:59 -0800 (PST)
Received: from devils.ext.ti.com (devils.ext.ti.com. [198.47.26.153])
        by mx.google.com with ESMTPS id 4si14275816qeq.93.2013.12.02.18.28.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 18:28:59 -0800 (PST)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH v2 13/23] mm/lib/swiotlb: Use memblock apis for early memory allocations
Date: Mon, 2 Dec 2013 21:27:28 -0500
Message-ID: <1386037658-3161-14-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Santosh Shilimkar <santosh.shilimkar@ti.com>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Switch to memblock interfaces for early memory allocator instead of
bootmem allocator. No functional change in beahvior than what it is
in current code from bootmem users points of view.

Archs already converted to NO_BOOTMEM now directly use memblock
interfaces instead of bootmem wrappers build on top of memblock. And the
archs which still uses bootmem, these new apis just fallback to exiting
bootmem APIs.

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 lib/swiotlb.c |   36 +++++++++++++++++++++---------------
 1 file changed, 21 insertions(+), 15 deletions(-)

diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index e4399fa..6c8712e 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -172,8 +172,9 @@ int __init swiotlb_init_with_tbl(char *tlb, unsigned long nslabs, int verbose)
 	/*
 	 * Get the overflow emergency buffer
 	 */
-	v_overflow_buffer = alloc_bootmem_low_pages_nopanic(
-						PAGE_ALIGN(io_tlb_overflow));
+	v_overflow_buffer = memblock_virt_alloc_align_nopanic(
+						PAGE_ALIGN(io_tlb_overflow),
+						PAGE_SIZE);
 	if (!v_overflow_buffer)
 		return -ENOMEM;
 
@@ -184,11 +185,15 @@ int __init swiotlb_init_with_tbl(char *tlb, unsigned long nslabs, int verbose)
 	 * to find contiguous free memory regions of size up to IO_TLB_SEGSIZE
 	 * between io_tlb_start and io_tlb_end.
 	 */
-	io_tlb_list = alloc_bootmem_pages(PAGE_ALIGN(io_tlb_nslabs * sizeof(int)));
+	io_tlb_list = memblock_virt_alloc_align(
+				PAGE_ALIGN(io_tlb_nslabs * sizeof(int)),
+				PAGE_SIZE);
 	for (i = 0; i < io_tlb_nslabs; i++)
  		io_tlb_list[i] = IO_TLB_SEGSIZE - OFFSET(i, IO_TLB_SEGSIZE);
 	io_tlb_index = 0;
-	io_tlb_orig_addr = alloc_bootmem_pages(PAGE_ALIGN(io_tlb_nslabs * sizeof(phys_addr_t)));
+	io_tlb_orig_addr = memblock_virt_alloc_align(
+				PAGE_ALIGN(io_tlb_nslabs * sizeof(phys_addr_t)),
+				PAGE_SIZE);
 
 	if (verbose)
 		swiotlb_print_info();
@@ -215,13 +220,14 @@ swiotlb_init(int verbose)
 	bytes = io_tlb_nslabs << IO_TLB_SHIFT;
 
 	/* Get IO TLB memory from the low pages */
-	vstart = alloc_bootmem_low_pages_nopanic(PAGE_ALIGN(bytes));
+	vstart = memblock_virt_alloc_align_nopanic(PAGE_ALIGN(bytes),
+						   PAGE_SIZE);
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
@@ -357,14 +363,14 @@ void __init swiotlb_free(void)
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
