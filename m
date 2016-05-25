Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id BE7B16B0262
	for <linux-mm@kvack.org>; Wed, 25 May 2016 00:29:52 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id yu3so58600514obb.3
        for <linux-mm@kvack.org>; Tue, 24 May 2016 21:29:52 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id 17si8160944igh.17.2016.05.24.21.29.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 May 2016 21:29:51 -0700 (PDT)
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0O7P0293YTTFVH50@mailout4.samsung.com> for linux-mm@kvack.org;
 Wed, 25 May 2016 13:29:39 +0900 (KST)
From: Jaewon Kim <jaewon31.kim@samsung.com>
Subject: [RESEND][PATCH] drivers: of: of_reserved_mem: fixup the CMA alignment
 not to affect dma-coherent
Date: Wed, 25 May 2016 13:29:50 +0900
Message-id: <1464150590-2703-1-git-send-email-jaewon31.kim@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robh+dt@kernel.org
Cc: r64343@freescale.com, m.szyprowski@samsung.com, grant.likely@linaro.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jaewon31.kim@gmail.com, Jaewon <jaewon31.kim@samsung.com>

From: Jaewon <jaewon31.kim@samsung.com>

There was an alignment mismatch issue for CMA and it was fixed by
commit 1cc8e3458b51 ("drivers: of: of_reserved_mem: fixup the alignment with CMA setup").
However the way of the commit considers not only dma-contiguous(CMA) but also
dma-coherent which has no that requirement.

This patch checks more to distinguish dma-contiguous(CMA) from dma-coherent.

Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
---
 drivers/of/of_reserved_mem.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/of/of_reserved_mem.c b/drivers/of/of_reserved_mem.c
index ed01c01..45b873e 100644
--- a/drivers/of/of_reserved_mem.c
+++ b/drivers/of/of_reserved_mem.c
@@ -127,7 +127,10 @@ static int __init __reserved_mem_alloc_size(unsigned long node,
 	}
 
 	/* Need adjust the alignment to satisfy the CMA requirement */
-	if (IS_ENABLED(CONFIG_CMA) && of_flat_dt_is_compatible(node, "shared-dma-pool"))
+	if (IS_ENABLED(CONFIG_CMA)
+	    && of_flat_dt_is_compatible(node, "shared-dma-pool")
+	    && of_get_flat_dt_prop(node, "reusable", NULL)
+	    && !of_get_flat_dt_prop(node, "no-map", NULL)) {
 		align = max(align, (phys_addr_t)PAGE_SIZE << max(MAX_ORDER - 1, pageblock_order));
 
 	prop = of_get_flat_dt_prop(node, "alloc-ranges", &len);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
