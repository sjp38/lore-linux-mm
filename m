Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1B07728025B
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 12:36:09 -0500 (EST)
Received: by mail-pa0-f72.google.com with SMTP id bi5so69893566pad.0
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 09:36:09 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id o9si5957296pgc.284.2016.11.10.09.36.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Nov 2016 09:36:08 -0800 (PST)
Subject: [mm PATCH v3 08/23] arch/m68k: Add option to skip DMA sync as a
 part of mapping
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Thu, 10 Nov 2016 06:34:57 -0500
Message-ID: <20161110113457.76501.77603.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: netdev@vger.kernel.org, linux-m68k@lists.linux-m68k.org, Geert Uytterhoeven <geert@linux-m68k.org>, linux-kernel@vger.kernel.org

This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
avoid invoking cache line invalidation if the driver will just handle it
later via a sync_for_cpu or sync_for_device call.

Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: linux-m68k@lists.linux-m68k.org
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/m68k/kernel/dma.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/arch/m68k/kernel/dma.c b/arch/m68k/kernel/dma.c
index 8cf97cb..0707006 100644
--- a/arch/m68k/kernel/dma.c
+++ b/arch/m68k/kernel/dma.c
@@ -134,7 +134,9 @@ static dma_addr_t m68k_dma_map_page(struct device *dev, struct page *page,
 {
 	dma_addr_t handle = page_to_phys(page) + offset;
 
-	dma_sync_single_for_device(dev, handle, size, dir);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		dma_sync_single_for_device(dev, handle, size, dir);
+
 	return handle;
 }
 
@@ -146,6 +148,10 @@ static int m68k_dma_map_sg(struct device *dev, struct scatterlist *sglist,
 
 	for_each_sg(sglist, sg, nents, i) {
 		sg->dma_address = sg_phys(sg);
+
+		if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
+			continue;
+
 		dma_sync_single_for_device(dev, sg->dma_address, sg->length,
 					   dir);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
