Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 886546B0254
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 15:39:11 -0400 (EDT)
Received: by igbpg9 with SMTP id pg9so23476425igb.0
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 12:39:11 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id x1si12303234pdm.181.2015.07.31.12.39.10
        for <linux-mm@kvack.org>;
        Fri, 31 Jul 2015 12:39:10 -0700 (PDT)
From: "Sean O. Stalley" <sean.stalley@intel.com>
Subject: [PATCH v2 1/4] mm: Add support for __GFP_ZERO flag to dma_pool_alloc()
Date: Fri, 31 Jul 2015 12:36:41 -0700
Message-Id: <1438371404-3219-2-git-send-email-sean.stalley@intel.com>
In-Reply-To: <1438371404-3219-1-git-send-email-sean.stalley@intel.com>
References: <1438371404-3219-1-git-send-email-sean.stalley@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: corbet@lwn.net, vinod.koul@intel.com, bhelgaas@google.com, Julia.Lawall@lip6.fr, Gilles.Muller@lip6.fr, nicolas.palix@imag.fr, mmarek@suse.cz, akpm@linux-foundation.org
Cc: sean.stalley@intel.com, bigeasy@linutronix.de, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, dmaengine@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, cocci@systeme.lip6.fr

Currently the __GFP_ZERO flag is ignored by dma_pool_alloc().
Make dma_pool_alloc() zero the memory if this flag is set.

Signed-off-by: Sean O. Stalley <sean.stalley@intel.com>
---
 mm/dmapool.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/dmapool.c b/mm/dmapool.c
index fd5fe43..bd49386 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -334,7 +334,7 @@ void *dma_pool_alloc(struct dma_pool *pool, gfp_t mem_flags,
 	/* pool_alloc_page() might sleep, so temporarily drop &pool->lock */
 	spin_unlock_irqrestore(&pool->lock, flags);
 
-	page = pool_alloc_page(pool, mem_flags);
+	page = pool_alloc_page(pool, mem_flags & (~__GFP_ZERO));
 	if (!page)
 		return NULL;
 
@@ -372,9 +372,14 @@ void *dma_pool_alloc(struct dma_pool *pool, gfp_t mem_flags,
 			break;
 		}
 	}
-	memset(retval, POOL_POISON_ALLOCATED, pool->size);
+	if (!(mem_flags & __GFP_ZERO))
+		memset(retval, POOL_POISON_ALLOCATED, pool->size);
 #endif
 	spin_unlock_irqrestore(&pool->lock, flags);
+
+	if (mem_flags & __GFP_ZERO)
+		memset(retval, 0, pool->size);
+
 	return retval;
 }
 EXPORT_SYMBOL(dma_pool_alloc);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
