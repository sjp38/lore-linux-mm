Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 21B95280264
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 14:06:55 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id gg9so17537211pac.6
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:06:55 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id y64si5124807pfa.6.2016.10.24.11.06.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 11:06:54 -0700 (PDT)
Subject: [net-next PATCH RFC 21/26] arch/xtensa: Add option to skip DMA sync
 as a part of mapping
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Mon, 24 Oct 2016 08:06:17 -0400
Message-ID: <20161024120617.16276.40617.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Max Filippov <jcmvbkbc@gmail.com>, davem@davemloft.net, brouer@redhat.com

This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
avoid invoking cache line invalidation if the driver will just handle it
via a sync_for_cpu or sync_for_device call.

Cc: Max Filippov <jcmvbkbc@gmail.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/xtensa/kernel/pci-dma.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/arch/xtensa/kernel/pci-dma.c b/arch/xtensa/kernel/pci-dma.c
index 1e68806..6a16dec 100644
--- a/arch/xtensa/kernel/pci-dma.c
+++ b/arch/xtensa/kernel/pci-dma.c
@@ -189,7 +189,9 @@ static dma_addr_t xtensa_map_page(struct device *dev, struct page *page,
 {
 	dma_addr_t dma_handle = page_to_phys(page) + offset;
 
-	xtensa_sync_single_for_device(dev, dma_handle, size, dir);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		xtensa_sync_single_for_device(dev, dma_handle, size, dir);
+
 	return dma_handle;
 }
 
@@ -197,7 +199,8 @@ static void xtensa_unmap_page(struct device *dev, dma_addr_t dma_handle,
 			      size_t size, enum dma_data_direction dir,
 			      unsigned long attrs)
 {
-	xtensa_sync_single_for_cpu(dev, dma_handle, size, dir);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		xtensa_sync_single_for_cpu(dev, dma_handle, size, dir);
 }
 
 static int xtensa_map_sg(struct device *dev, struct scatterlist *sg,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
