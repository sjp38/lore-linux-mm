Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id BB9986B02BF
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 13:16:16 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id gg9so9763533pac.6
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 10:16:16 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id b21si4151259pgh.146.2016.11.02.10.16.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Nov 2016 10:16:16 -0700 (PDT)
Subject: [mm PATCH v2 18/26] arch/powerpc: Add option to skip DMA sync as a
 part of mapping
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Wed, 02 Nov 2016 07:15:18 -0400
Message-ID: <20161102111513.79519.65315.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
avoid invoking cache line invalidation if the driver will just handle it
via a sync_for_cpu or sync_for_device call.

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/powerpc/kernel/dma.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/kernel/dma.c b/arch/powerpc/kernel/dma.c
index e64a601..6877e3f 100644
--- a/arch/powerpc/kernel/dma.c
+++ b/arch/powerpc/kernel/dma.c
@@ -203,6 +203,10 @@ static int dma_direct_map_sg(struct device *dev, struct scatterlist *sgl,
 	for_each_sg(sgl, sg, nents, i) {
 		sg->dma_address = sg_phys(sg) + get_dma_offset(dev);
 		sg->dma_length = sg->length;
+
+		if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
+			continue;
+
 		__dma_sync_page(sg_page(sg), sg->offset, sg->length, direction);
 	}
 
@@ -235,7 +239,10 @@ static inline dma_addr_t dma_direct_map_page(struct device *dev,
 					     unsigned long attrs)
 {
 	BUG_ON(dir == DMA_NONE);
-	__dma_sync_page(page, offset, size, dir);
+
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		__dma_sync_page(page, offset, size, dir);
+
 	return page_to_phys(page) + offset + get_dma_offset(dev);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
