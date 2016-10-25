Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2B4D86B0298
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 17:39:24 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c84so56265pfb.1
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 14:39:24 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id c17si13724747pgh.177.2016.10.25.14.39.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Oct 2016 14:39:23 -0700 (PDT)
Subject: [net-next PATCH 22/27] arch/xtensa: Add option to skip DMA sync as
 a part of mapping
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Tue, 25 Oct 2016 11:38:45 -0400
Message-ID: <20161025153845.4815.95895.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161025153220.4815.61239.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161025153220.4815.61239.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
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
