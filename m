Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8A5E06B004D
	for <linux-mm@kvack.org>; Sat, 21 Feb 2009 08:36:18 -0500 (EST)
Received: by ug-out-1314.google.com with SMTP id 29so114233ugc.19
        for <linux-mm@kvack.org>; Sat, 21 Feb 2009 05:36:17 -0800 (PST)
From: Vegard Nossum <vegard.nossum@gmail.com>
Subject: [PATCH] kmemcheck: add hooks for page- and sg-dma-mappings
Date: Sat, 21 Feb 2009 14:36:03 +0100
Message-Id: <1235223364-2097-4-git-send-email-vegard.nossum@gmail.com>
In-Reply-To: <1235223364-2097-1-git-send-email-vegard.nossum@gmail.com>
References: <1235223364-2097-1-git-send-email-vegard.nossum@gmail.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

This is needed for page allocator support to prevent false positives
when accessing pages which are dma-mapped.

Signed-off-by: Vegard Nossum <vegard.nossum@gmail.com>
---
 arch/x86/include/asm/dma-mapping.h |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
index 830bb0e..713a002 100644
--- a/arch/x86/include/asm/dma-mapping.h
+++ b/arch/x86/include/asm/dma-mapping.h
@@ -117,7 +117,12 @@ dma_map_sg(struct device *hwdev, struct scatterlist *sg,
 {
 	struct dma_mapping_ops *ops = get_dma_ops(hwdev);
 
+	struct scatterlist *s;
+	int i;
+
 	BUG_ON(!valid_dma_direction(direction));
+	for_each_sg(sg, s, nents, i)
+		kmemcheck_mark_initialized(sg_virt(s), s->length);
 	return ops->map_sg(hwdev, sg, nents, direction);
 }
 
@@ -215,6 +220,7 @@ static inline dma_addr_t dma_map_page(struct device *dev, struct page *page,
 	struct dma_mapping_ops *ops = get_dma_ops(dev);
 
 	BUG_ON(!valid_dma_direction(direction));
+	kmemcheck_mark_initialized(page_address(page) + offset, size);
 	return ops->map_single(dev, page_to_phys(page) + offset,
 			       size, direction);
 }
-- 
1.6.0.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
