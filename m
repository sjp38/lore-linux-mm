Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 44D886B0036
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 12:46:10 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so156228pab.1
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 09:46:09 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id rc5si30759454pbc.60.2014.09.16.09.46.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Sep 2014 09:46:08 -0700 (PDT)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [mmotm][PATCH] common: dma-mapping: Store page array in vm_struct
Date: Tue, 16 Sep 2014 09:45:54 -0700
Message-Id: <1410885954-24260-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Laura Abbott <lauraa@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Mitchel Humpherys <mitchelh@codeaurora.org>

Commit 54329ac (common: dma-mapping: introduce common remapping functions)
factored out common code for remapping arrays of pages. The code before
the refactor relied on setting area->pages with the array of mapped
pages for easy access later. The refactor dropped this, breaking
parts of the ARM DMA API. Fix this by setting the page array in the same
place.

Reported-by: Mitchel Humpherys <mitchelh@codeaurora.org>
Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
---
 drivers/base/dma-mapping.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/base/dma-mapping.c b/drivers/base/dma-mapping.c
index 3a6af66..9e8bbdd 100644
--- a/drivers/base/dma-mapping.c
+++ b/drivers/base/dma-mapping.c
@@ -285,6 +285,8 @@ void *dma_common_pages_remap(struct page **pages, size_t size,
 	if (!area)
 		return NULL;
 
+	area->pages = pages;
+
 	if (map_vm_area(area, prot, pages)) {
 		vunmap(area->addr);
 		return NULL;
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
