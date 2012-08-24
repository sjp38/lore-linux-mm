Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 03FE36B0044
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 03:20:37 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (mailout1.samsung.com [203.254.224.24])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M99000SF0E3D3N0@mailout1.samsung.com> for
 linux-mm@kvack.org; Fri, 24 Aug 2012 16:20:36 +0900 (KST)
Received: from mcdsrvbld02.digital.local ([106.116.37.23])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M99006LS0E37510@mmp2.samsung.com> for linux-mm@kvack.org;
 Fri, 24 Aug 2012 16:20:36 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH] mm: cma: fix alignment requirements for contiguous regions
Date: Fri, 24 Aug 2012 09:20:10 +0200
Message-id: <1345792810-5152-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>

Contiguous Memory Allocator requires each of its regions to be aligned
in such a way that it is possible to change migration type for all
pageblocks holding it and then isolate page of largest possible order from
the buddy allocator (which is MAX_ORDER-1). This patch relaxes alignment
requirements by one order, because MAX_ORDER alignment is not really
needed.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
CC: Michal Nazarewicz <mina86@mina86.com>
---
 drivers/base/dma-contiguous.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
index 78efb03..34d94c7 100644
--- a/drivers/base/dma-contiguous.c
+++ b/drivers/base/dma-contiguous.c
@@ -250,7 +250,7 @@ int __init dma_declare_contiguous(struct device *dev, unsigned long size,
 		return -EINVAL;
 
 	/* Sanitise input arguments */
-	alignment = PAGE_SIZE << max(MAX_ORDER, pageblock_order);
+	alignment = PAGE_SIZE << max(MAX_ORDER - 1, pageblock_order);
 	base = ALIGN(base, alignment);
 	size = ALIGN(size, alignment);
 	limit &= ~(alignment - 1);
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
