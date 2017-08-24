Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 42DC66B04BA
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 02:37:00 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id z193so8505868pgd.7
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 23:37:00 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id q1si2277386pga.789.2017.08.23.23.36.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 23:36:59 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id u9so2561900pgn.5
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 23:36:59 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 3/3] ARM: CMA: avoid double mapping to the CMA area if CONFIG_HIGHMEM = y
Date: Thu, 24 Aug 2017 15:36:33 +0900
Message-Id: <1503556593-10720-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1503556593-10720-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1503556593-10720-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

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
 arch/arm/mm/dma-mapping.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index fcf1473..38f0fde 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -513,7 +513,13 @@ void __init dma_contiguous_remap(void)
 		flush_tlb_kernel_range(__phys_to_virt(start),
 				       __phys_to_virt(end));
 
-		iotable_init(&map, 1);
+		/*
+		 * For highmem system, all the memory in CMA region will be
+		 * considered as highmem even if it's physical address belong
+		 * to lowmem. Therefore, re-mapping isn't required.
+		 */
+		if (!IS_ENABLED(CONFIG_HIGHMEM))
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
