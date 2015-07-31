Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id CF7646B0255
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 15:39:11 -0400 (EDT)
Received: by igk11 with SMTP id 11so38724851igk.1
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 12:39:11 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id x1si12303234pdm.181.2015.07.31.12.39.11
        for <linux-mm@kvack.org>;
        Fri, 31 Jul 2015 12:39:11 -0700 (PDT)
From: "Sean O. Stalley" <sean.stalley@intel.com>
Subject: [PATCH v2 2/4] mm: Add dma_pool_zalloc() call to DMA API
Date: Fri, 31 Jul 2015 12:36:42 -0700
Message-Id: <1438371404-3219-3-git-send-email-sean.stalley@intel.com>
In-Reply-To: <1438371404-3219-1-git-send-email-sean.stalley@intel.com>
References: <1438371404-3219-1-git-send-email-sean.stalley@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: corbet@lwn.net, vinod.koul@intel.com, bhelgaas@google.com, Julia.Lawall@lip6.fr, Gilles.Muller@lip6.fr, nicolas.palix@imag.fr, mmarek@suse.cz, akpm@linux-foundation.org
Cc: sean.stalley@intel.com, bigeasy@linutronix.de, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, dmaengine@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, cocci@systeme.lip6.fr

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
