Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id DFA6D6B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 21:41:41 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 188so24291872pgb.3
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 18:41:41 -0700 (PDT)
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTPS id l5si6824085pln.434.2017.09.26.18.41.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 18:41:40 -0700 (PDT)
From: <miles.chen@mediatek.com>
Subject: [PATCH v2] dma-debug: fix incorrect pfn calculation
Date: Wed, 27 Sep 2017 09:41:33 +0800
Message-ID: <1506476493-28949-1-git-send-email-miles.chen@mediatek.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, wsd_upstream@mediatek.com, linux-mediatek@lists.infradead.org, iommu@lists.linux-foundation.org, Miles Chen <miles.chen@mediatek.com>

From: Miles Chen <miles.chen@mediatek.com>

dma-debug report the following warning:

[name:panic&]WARNING: CPU: 3 PID: 298 at kernel-4.4/lib/dma-debug.c:604
debug _dma_assert_idle+0x1a8/0x230()
DMA-API: cpu touching an active dma mapped cacheline [cln=0x00000882300]
CPU: 3 PID: 298 Comm: vold Tainted: G        W  O    4.4.22+ #1
Hardware name: MT6739 (DT)
Call trace:
[<ffffff800808acd0>] dump_backtrace+0x0/0x1d4
[<ffffff800808affc>] show_stack+0x14/0x1c
[<ffffff800838019c>] dump_stack+0xa8/0xe0
[<ffffff80080a0594>] warn_slowpath_common+0xf4/0x11c
[<ffffff80080a061c>] warn_slowpath_fmt+0x60/0x80
[<ffffff80083afe24>] debug_dma_assert_idle+0x1a8/0x230
[<ffffff80081dca9c>] wp_page_copy.isra.96+0x118/0x520
[<ffffff80081de114>] do_wp_page+0x4fc/0x534
[<ffffff80081e0a14>] handle_mm_fault+0xd4c/0x1310
[<ffffff8008098798>] do_page_fault+0x1c8/0x394
[<ffffff800808231c>] do_mem_abort+0x50/0xec

I found that debug_dma_alloc_coherent() and debug_dma_free_coherent()
assume that dma_alloc_coherent() always returns a linear address.
However it's possible that dma_alloc_coherent() returns a non-linear
address. So we cannot calculate a pfn by page_to_pfn(virt_to_page(virt)).

Fix this by calculating pfn for linear and non-linear addresses.

Signed-off-by: Miles Chen <miles.chen@mediatek.com>
---
 lib/dma-debug.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/dma-debug.c b/lib/dma-debug.c
index ea4cc3d..381f2ac 100644
--- a/lib/dma-debug.c
+++ b/lib/dma-debug.c
@@ -1497,7 +1497,8 @@ void debug_dma_alloc_coherent(struct device *dev, size_t size,
 
 	entry->type      = dma_debug_coherent;
 	entry->dev       = dev;
-	entry->pfn	 = page_to_pfn(virt_to_page(virt));
+	entry->pfn	 = is_vmalloc_addr(virt) ? vmalloc_to_pfn(virt) :
+						page_to_pfn(virt_to_page(virt)),
 	entry->offset	 = offset_in_page(virt);
 	entry->size      = size;
 	entry->dev_addr  = dma_addr;
@@ -1513,7 +1514,8 @@ void debug_dma_free_coherent(struct device *dev, size_t size,
 	struct dma_debug_entry ref = {
 		.type           = dma_debug_coherent,
 		.dev            = dev,
-		.pfn		= page_to_pfn(virt_to_page(virt)),
+		.pfn		= is_vmalloc_addr(virt) ? vmalloc_to_pfn(virt) :
+						page_to_pfn(virt_to_page(virt)),
 		.offset		= offset_in_page(virt),
 		.dev_addr       = addr,
 		.size           = size,
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
