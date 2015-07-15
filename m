Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id E9D4E280245
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 17:17:02 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so30316215pac.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 14:17:02 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id uc10si9463457pac.78.2015.07.15.14.17.02
        for <linux-mm@kvack.org>;
        Wed, 15 Jul 2015 14:17:02 -0700 (PDT)
From: "Sean O. Stalley" <sean.stalley@intel.com>
Subject: [PATCH 2/4] mm: Add dma_pool_zalloc() call to DMA API
Date: Wed, 15 Jul 2015 14:14:41 -0700
Message-Id: <1436994883-16563-3-git-send-email-sean.stalley@intel.com>
In-Reply-To: <1436994883-16563-1-git-send-email-sean.stalley@intel.com>
References: <1436994883-16563-1-git-send-email-sean.stalley@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: corbet@lwn.net, vinod.koul@intel.com, bhelgaas@google.com, Julia.Lawall@lip6.fr, Gilles.Muller@lip6.fr, nicolas.palix@imag.fr, mmarek@suse.cz
Cc: sean.stalley@intel.com, akpm@linux-foundation.org, bigeasy@linutronix.de, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, dmaengine@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, cocci@systeme.lip6.fr

Add a wrapper function for dma_pool_alloc() to get zeroed memory.

Signed-off-by: Sean O. Stalley <sean.stalley@intel.com>
---
 Documentation/DMA-API.txt | 7 +++++++
 include/linux/dmapool.h   | 6 ++++++
 2 files changed, 13 insertions(+)

diff --git a/Documentation/DMA-API.txt b/Documentation/DMA-API.txt
index 5208840..988f757 100644
--- a/Documentation/DMA-API.txt
+++ b/Documentation/DMA-API.txt
@@ -104,6 +104,13 @@ crossing restrictions, pass 0 for alloc; passing 4096 says memory allocated
 from this pool must not cross 4KByte boundaries.
 
 
+	void *dma_pool_zalloc(struct dma_pool *pool, gfp_t mem_flags,
+			      dma_addr_t *handle)
+
+Wraps dma_pool_alloc() and also zeroes the returned memory if the
+allocation attempt succeeded.
+
+
 	void *dma_pool_alloc(struct dma_pool *pool, gfp_t gfp_flags,
 			dma_addr_t *dma_handle);
 
diff --git a/include/linux/dmapool.h b/include/linux/dmapool.h
index 022e34f..6d8079b 100644
--- a/include/linux/dmapool.h
+++ b/include/linux/dmapool.h
@@ -22,6 +22,12 @@ void dma_pool_destroy(struct dma_pool *pool);
 void *dma_pool_alloc(struct dma_pool *pool, gfp_t mem_flags,
 		     dma_addr_t *handle);
 
+static inline void *dma_pool_zalloc(struct dma_pool *pool, gfp_t mem_flags,
+				    dma_addr_t *handle)
+{
+	return dma_pool_alloc(pool, mem_flags | __GFP_ZERO, handle);
+}
+
 void dma_pool_free(struct dma_pool *pool, void *vaddr, dma_addr_t addr);
 
 /*
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
