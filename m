Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9C97D6B02B0
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 13:14:34 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id rf5so9808393pab.3
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 10:14:34 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id l184si4061499pfc.285.2016.11.02.10.14.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 10:14:33 -0700 (PDT)
Subject: [mm PATCH v2 07/26] arch/blackfin: Add option to skip sync on DMA
 map
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Wed, 02 Nov 2016 07:13:37 -0400
Message-ID: <20161102111334.79519.36391.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Steven Miao <realmz6@gmail.com>

The use of DMA_ATTR_SKIP_CPU_SYNC was not consistent across all of the DMA
APIs in the arch/arm folder.  This change is meant to correct that so that
we get consistent behavior.

Cc: Steven Miao <realmz6@gmail.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/blackfin/kernel/dma-mapping.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/arch/blackfin/kernel/dma-mapping.c b/arch/blackfin/kernel/dma-mapping.c
index 53fbbb6..a27a74a 100644
--- a/arch/blackfin/kernel/dma-mapping.c
+++ b/arch/blackfin/kernel/dma-mapping.c
@@ -118,6 +118,10 @@ static int bfin_dma_map_sg(struct device *dev, struct scatterlist *sg_list,
 
 	for_each_sg(sg_list, sg, nents, i) {
 		sg->dma_address = (dma_addr_t) sg_virt(sg);
+
+		if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
+			continue;
+
 		__dma_sync(sg_dma_address(sg), sg_dma_len(sg), direction);
 	}
 
@@ -143,7 +147,9 @@ static dma_addr_t bfin_dma_map_page(struct device *dev, struct page *page,
 {
 	dma_addr_t handle = (dma_addr_t)(page_address(page) + offset);
 
-	_dma_sync(handle, size, dir);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		_dma_sync(handle, size, dir);
+
 	return handle;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
