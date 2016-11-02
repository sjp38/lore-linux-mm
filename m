Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id A9ADB6B02B2
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 13:15:07 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id rt15so9749737pab.5
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 10:15:07 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id t8si4176589pgn.52.2016.11.02.10.15.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Nov 2016 10:15:06 -0700 (PDT)
Subject: [mm PATCH v2 10/26] arch/hexagon: Add option to skip DMA sync as a
 part of mapping
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Wed, 02 Nov 2016 07:14:09 -0400
Message-ID: <20161102111407.79519.26259.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: linux-hexagon@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Richard Kuo <rkuo@codeaurora.org>

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
