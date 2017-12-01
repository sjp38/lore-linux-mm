Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BBA1B6B025E
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 02:53:32 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id d4so6003133pgv.4
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 23:53:32 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o22sor1805293pgc.183.2017.11.30.23.53.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 Nov 2017 23:53:31 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH v2 3/3] ARM: CMA: avoid double mapping to the CMA area if CONFIG_HIGHMEM = y
Date: Fri,  1 Dec 2017 16:53:06 +0900
Message-Id: <1512114786-5085-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1512114786-5085-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1512114786-5085-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tony Lindgren <tony@atomide.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

CMA area is now managed by the separate zone, ZONE_MOVABLE,
to fix many MM related problems. In this implementation, if
CONFIG_HIGHMEM = y, then ZONE_MOVABLE is considered as HIGHMEM and
the memory of the CMA area is also considered as HIGHMEM.
That means that they are considered as the page without direct mapping.
However, CMA area could be in a lowmem and the memory could have
direct mapping.

In ARM, when establishing a new mapping for DMA, direct mapping should
be cleared since two mapping with different cache policy could cause
unknown problem. With this patch, PageHighmem() for the CMA memory
located in lowmem returns true so that the function for DMA mapping
cannot notice whether it needs to clear direct mapping or not, correctly.
To handle this situation, this patch always clears direct mapping
for such CMA memory.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 arch/arm/mm/dma-mapping.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index ada8eb2..8c398fe 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -466,6 +466,12 @@ void __init dma_contiguous_early_fixup(phys_addr_t base, unsigned long size)
 void __init dma_contiguous_remap(void)
 {
 	int i;
+
+	if (!dma_mmu_remap_num)
+		return;
+
+	/* call flush_cache_all() since CMA area would be large enough */
+	flush_cache_all();
 	for (i = 0; i < dma_mmu_remap_num; i++) {
 		phys_addr_t start = dma_mmu_remap[i].base;
 		phys_addr_t end = start + dma_mmu_remap[i].size;
@@ -498,7 +504,15 @@ void __init dma_contiguous_remap(void)
 		flush_tlb_kernel_range(__phys_to_virt(start),
 				       __phys_to_virt(end));
 
-		iotable_init(&map, 1);
+		/*
+		 * All the memory in CMA region will be on ZONE_MOVABLE.
+		 * If that zone is considered as highmem, the memory in CMA
+		 * region is also considered as highmem even if it's
+		 * physical address belong to lowmem. In this case,
+		 * re-mapping isn't required.
+		 */
+		if (!is_highmem_idx(ZONE_MOVABLE))
+			iotable_init(&map, 1);
 	}
 }
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
