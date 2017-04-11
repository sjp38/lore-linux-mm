Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 16ECD6B03A5
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 23:18:08 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id r129so133230165pgr.18
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 20:18:08 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id q63si15438977pgq.183.2017.04.10.20.18.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 20:18:07 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id 81so28019862pgh.3
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 20:18:07 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v7 7/7] ARM: CMA: avoid re-mapping CMA region if CONFIG_HIGHMEM
Date: Tue, 11 Apr 2017 12:17:20 +0900
Message-Id: <1491880640-9944-8-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

CMA region is now managed by the separate zone, ZONE_CMA, to
fix many MM related problems. In this implementation, it is
possible that ZONE_CMA contains two CMA regions that are
on the both, lowmem and highmem, respectively. To handle this case
properly, ZONE_CMA is considered as highmem.

In dma_contiguous_remap(), mapping for CMA region on lowmem is cleared
and remapped for DMA, but, in the new CMA implementation, remap isn't
needed since the region is considered as highmem. And, remap should not be
allowed since it would cause cache problems. So, this patch disables it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 arch/arm/mm/dma-mapping.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 475811f..377053a 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -506,7 +506,12 @@ void __init dma_contiguous_remap(void)
 		flush_tlb_kernel_range(__phys_to_virt(start),
 				       __phys_to_virt(end));
 
-		iotable_init(&map, 1);
+		/*
+		 * For highmem system, all the memory in CMA region will be
+		 * considered as highmem, therefore, re-mapping isn't required.
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
