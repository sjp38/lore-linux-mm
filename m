Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f45.google.com (mail-lf0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 772CD6B0009
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 03:12:14 -0500 (EST)
Received: by mail-lf0-f45.google.com with SMTP id l143so48797993lfe.2
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 00:12:14 -0800 (PST)
Received: from bes.se.axis.com (bes.se.axis.com. [195.60.68.10])
        by mx.google.com with ESMTP id tm8si6035997lbb.126.2016.02.19.00.12.12
        for <linux-mm@kvack.org>;
        Fri, 19 Feb 2016 00:12:12 -0800 (PST)
From: Rabin Vincent <rabin.vincent@axis.com>
Subject: [PATCH 2/2] ARM: dma-mapping: fix alloc/free for coherent + CMA + gfp=0
Date: Fri, 19 Feb 2016 09:12:04 +0100
Message-Id: <1455869524-13874-2-git-send-email-rabin.vincent@axis.com>
In-Reply-To: <1455869524-13874-1-git-send-email-rabin.vincent@axis.com>
References: <1455869524-13874-1-git-send-email-rabin.vincent@axis.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@arm.linux.org.uk
Cc: mina86@mina86.com, akpm@linux-foundation.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rabin Vincent <rabinv@axis.com>

Given a device which uses arm_coherent_dma_ops and on which
dev_get_cma_area(dev) returns non-NULL, the following usage of the DMA
API with gfp=0 results in a memory leak and memory corruption.

 p = dma_alloc_coherent(dev, sz, &dma, 0);
 if (p)
 	dma_free_coherent(dev, sz, p, dma);

The memory leak is because the alloc allocates using
__alloc_simple_buffer() but the free attempts
dma_release_from_contiguous(), which does not do free anything since the
page is not in the CMA area.

The memory corruption is because the free calls __dma_remap() on a page
which is backed by only first level page tables.  The
apply_to_page_range() + __dma_update_pte() loop ends up interpreting the
section mapping as the address to a second level page table and writing
the new PTE to memory which is not used by page tables.

We don't have access to the GFP flags used for allocation in the free
function, so fix it by using the new in_cma() function to determine if a
buffer was allocated with CMA, similar to how we check for
__in_atomic_pool().

Fixes: 21caf3a7 ("ARM: 8398/1: arm DMA: Fix allocation from CMA for coherent DMA")
Signed-off-by: Rabin Vincent <rabin.vincent@axis.com>
---
 arch/arm/mm/dma-mapping.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 0eca381..a4592c7 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -749,16 +749,16 @@ static void __arm_dma_free(struct device *dev, size_t size, void *cpu_addr,
 		__dma_free_buffer(page, size);
 	} else if (!is_coherent && __free_from_pool(cpu_addr, size)) {
 		return;
-	} else if (!dev_get_cma_area(dev)) {
-		if (want_vaddr && !is_coherent)
-			__dma_free_remap(cpu_addr, size);
-		__dma_free_buffer(page, size);
-	} else {
+	} else if (in_cma(dev_get_cma_area(dev), page, size >> PAGE_SHIFT)) {
 		/*
 		 * Non-atomic allocations cannot be freed with IRQs disabled
 		 */
 		WARN_ON(irqs_disabled());
 		__free_from_contiguous(dev, page, cpu_addr, size, want_vaddr);
+	} else {
+		if (want_vaddr && !is_coherent)
+			__dma_free_remap(cpu_addr, size);
+		__dma_free_buffer(page, size);
 	}
 }
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
