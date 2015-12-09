Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id D4B006B0255
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 09:54:19 -0500 (EST)
Received: by wmec201 with SMTP id c201so77151337wme.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 06:54:19 -0800 (PST)
Received: from mailapp01.imgtec.com (mailapp01.imgtec.com. [195.59.15.196])
        by mx.google.com with ESMTP id f81si38001631wmh.9.2015.12.09.06.54.18
        for <linux-mm@kvack.org>;
        Wed, 09 Dec 2015 06:54:18 -0800 (PST)
From: Qais Yousef <qais.yousef@imgtec.com>
Subject: [PATCH v2] MIPS: fix DMA contiguous allocation
Date: Wed, 9 Dec 2015 14:54:05 +0000
Message-ID: <1449672845-2196-1-git-send-email-qais.yousef@imgtec.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mips@linux-mips.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, ralf@linux-mips.org, akpm@linux-foundation.org, mgorman@techsingularity.net, Qais Yousef <qais.yousef@imgtec.com>

Recent changes to how GFP_ATOMIC is defined seems to have broken the condition
to use mips_alloc_from_contiguous() in mips_dma_alloc_coherent().

I couldn't bottom out the exact change but I think it's this one

d0164adc89f6 (mm, page_alloc: distinguish between being unable to sleep,
unwilling to sleep and avoiding waking kswapd)

>From what I see GFP_ATOMIC has multiple bits set and the check for !(gfp
& GFP_ATOMIC) isn't enough.

The reason behind this condition is to check whether we can potentially do
a sleeping memory allocation. Use gfpflags_allow_blocking() instead which
should be more robust.

Signed-off-by: Qais Yousef <qais.yousef@imgtec.com>
---
 arch/mips/mm/dma-default.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/mips/mm/dma-default.c b/arch/mips/mm/dma-default.c
index d8117be729a2..730d394ce5f0 100644
--- a/arch/mips/mm/dma-default.c
+++ b/arch/mips/mm/dma-default.c
@@ -145,7 +145,7 @@ static void *mips_dma_alloc_coherent(struct device *dev, size_t size,
 
 	gfp = massage_gfp_flags(dev, gfp);
 
-	if (IS_ENABLED(CONFIG_DMA_CMA) && !(gfp & GFP_ATOMIC))
+	if (IS_ENABLED(CONFIG_DMA_CMA) && gfpflags_allow_blocking(gfp))
 		page = dma_alloc_from_contiguous(dev,
 					count, get_order(size));
 	if (!page)
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
