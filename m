Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id A03A16B027F
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 17:38:20 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fn5so7235623pab.3
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 14:38:20 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id h6si14000242pgn.301.2016.10.25.14.38.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Oct 2016 14:38:19 -0700 (PDT)
Subject: [net-next PATCH 10/27] arch/hexagon: Add option to skip DMA sync as
 a part of mapping
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Tue, 25 Oct 2016 11:37:41 -0400
Message-ID: <20161025153741.4815.68818.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161025153220.4815.61239.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161025153220.4815.61239.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: linux-hexagon@vger.kernel.org, brouer@redhat.com, davem@davemloft.net, Richard Kuo <rkuo@codeaurora.org>

This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
avoid invoking cache line invalidation if the driver will just handle it
later via a sync_for_cpu or sync_for_device call.

Cc: Richard Kuo <rkuo@codeaurora.org>
Cc: linux-hexagon@vger.kernel.org
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/hexagon/kernel/dma.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/arch/hexagon/kernel/dma.c b/arch/hexagon/kernel/dma.c
index b901778..dbc4f10 100644
--- a/arch/hexagon/kernel/dma.c
+++ b/arch/hexagon/kernel/dma.c
@@ -119,6 +119,9 @@ static int hexagon_map_sg(struct device *hwdev, struct scatterlist *sg,
 
 		s->dma_length = s->length;
 
+		if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
+			continue;
+
 		flush_dcache_range(dma_addr_to_virt(s->dma_address),
 				   dma_addr_to_virt(s->dma_address + s->length));
 	}
@@ -180,7 +183,8 @@ static dma_addr_t hexagon_map_page(struct device *dev, struct page *page,
 	if (!check_addr("map_single", dev, bus, size))
 		return bad_dma_address;
 
-	dma_sync(dma_addr_to_virt(bus), size, dir);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		dma_sync(dma_addr_to_virt(bus), size, dir);
 
 	return bus;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
