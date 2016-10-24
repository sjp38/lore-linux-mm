Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id CCB3D280250
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 14:05:19 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id yx5so2556996pac.5
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:05:19 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id k15si16657654pga.198.2016.10.24.11.05.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 11:05:19 -0700 (PDT)
Subject: [net-next PATCH RFC 03/26] arch/arc: Add option to skip sync on DMA
 mapping
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Mon, 24 Oct 2016 08:04:42 -0400
Message-ID: <20161024120442.16276.95329.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Vineet Gupta <vgupta@synopsys.com>, linux-snps-arc@lists.infradead.org, davem@davemloft.net, brouer@redhat.com

This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
avoid invoking cache line invalidation if the driver will just handle it
later via a sync_for_cpu or sync_for_device call.

Cc: Vineet Gupta <vgupta@synopsys.com>
Cc: linux-snps-arc@lists.infradead.org
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/arc/mm/dma.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/arc/mm/dma.c b/arch/arc/mm/dma.c
index 20afc65..d0c4b28 100644
--- a/arch/arc/mm/dma.c
+++ b/arch/arc/mm/dma.c
@@ -133,7 +133,8 @@ static dma_addr_t arc_dma_map_page(struct device *dev, struct page *page,
 		unsigned long attrs)
 {
 	phys_addr_t paddr = page_to_phys(page) + offset;
-	_dma_cache_sync(paddr, size, dir);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		_dma_cache_sync(paddr, size, dir);
 	return plat_phys_to_dma(dev, paddr);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
