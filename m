Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 16E2B6B02AD
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 13:14:09 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id gg9so9740967pac.6
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 10:14:09 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id a3si4138180pgc.167.2016.11.02.10.14.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 10:14:08 -0700 (PDT)
Subject: [mm PATCH v2 04/26] arch/arc: Add option to skip sync on DMA mapping
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Wed, 02 Nov 2016 07:13:11 -0400
Message-ID: <20161102111308.79519.45058.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Vineet Gupta <vgupta@synopsys.com>, linux-kernel@vger.kernel.org, netdev@vger.kernel.org

This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
avoid invoking cache line invalidation if the driver will just handle it
later via a sync_for_cpu or sync_for_device call.

Acked-by: Vineet Gupta <vgupta@synopsys.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/arc/mm/dma.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/arch/arc/mm/dma.c b/arch/arc/mm/dma.c
index 60aab5a..ea207d2 100644
--- a/arch/arc/mm/dma.c
+++ b/arch/arc/mm/dma.c
@@ -133,7 +133,10 @@ static dma_addr_t arc_dma_map_page(struct device *dev, struct page *page,
 		unsigned long attrs)
 {
 	phys_addr_t paddr = page_to_phys(page) + offset;
-	_dma_cache_sync(paddr, size, dir);
+
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		_dma_cache_sync(paddr, size, dir);
+
 	return plat_phys_to_dma(dev, paddr);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
