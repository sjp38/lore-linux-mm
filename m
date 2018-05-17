Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3275C6B0520
	for <linux-mm@kvack.org>; Thu, 17 May 2018 13:36:32 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id w7-v6so3102155pfd.9
        for <linux-mm@kvack.org>; Thu, 17 May 2018 10:36:32 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id 70-v6si5860450pfu.274.2018.05.17.10.36.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 10:36:31 -0700 (PDT)
From: Sinan Kaya <okaya@codeaurora.org>
Subject: [PATCH] mm/dmapool: localize page allocations
Date: Thu, 17 May 2018 13:36:19 -0400
Message-Id: <1526578581-7658-1-git-send-email-okaya@codeaurora.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, timur@codeaurora.org
Cc: linux-arm-msm@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Sinan Kaya <okaya@codeaurora.org>, open list <linux-kernel@vger.kernel.org>

Try to keep the pool closer to the device's NUMA node by changing kmalloc()
to kmalloc_node() and devres_alloc() to devres_alloc_node().

Signed-off-by: Sinan Kaya <okaya@codeaurora.org>
---
 mm/dmapool.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/dmapool.c b/mm/dmapool.c
index 4d90a64..023f3d9 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -223,7 +223,7 @@ static struct dma_page *pool_alloc_page(struct dma_pool *pool, gfp_t mem_flags)
 {
 	struct dma_page *page;
 
-	page = kmalloc(sizeof(*page), mem_flags);
+	page = kmalloc_node(sizeof(*page), mem_flags, dev_to_node(pool->dev));
 	if (!page)
 		return NULL;
 	page->vaddr = dma_alloc_coherent(pool->dev, pool->allocation,
@@ -504,7 +504,8 @@ struct dma_pool *dmam_pool_create(const char *name, struct device *dev,
 {
 	struct dma_pool **ptr, *pool;
 
-	ptr = devres_alloc(dmam_pool_release, sizeof(*ptr), GFP_KERNEL);
+	ptr = devres_alloc_node(dmam_pool_release, sizeof(*ptr), GFP_KERNEL,
+				dev_to_node(dev));
 	if (!ptr)
 		return NULL;
 
-- 
2.7.4
