Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id ABE716B0033
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 17:56:20 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id v2so515144pfa.10
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 14:56:20 -0800 (PST)
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTPS id t9si1618742pgr.88.2017.11.16.14.56.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Nov 2017 14:56:19 -0800 (PST)
From: <miles.chen@mediatek.com>
Subject: [PATCH v4] dma-debug: fix incorrect pfn calculation
Date: Fri, 17 Nov 2017 06:56:12 +0800
Message-ID: <1510872972-23919-1-git-send-email-miles.chen@mediatek.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Robin Murphy <robin.murphy@arm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, wsd_upstream@mediatek.com, linux-mediatek@lists.infradead.org, iommu@lists.linux-foundation.org, Miles Chen <miles.chen@mediatek.com>

From: Miles Chen <miles.chen@mediatek.com>

dma-debug reports the following warning:

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
assume that dma_alloc_coherent() always returns a linear address.  However
it's possible that dma_alloc_coherent() returns a non-linear address.  In
this case, page_to_pfn(virt_to_page(virt)) will return an incorrect pfn.
If the pfn is valid and mapped as a COW page, we will hit the warning when
doing wp_page_copy().

Fix this by calculating pfn for linear and non-linear addresses.

Signed-off-by: Miles Chen <miles.chen@mediatek.com>
---
 lib/dma-debug.c | 20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

diff --git a/lib/dma-debug.c b/lib/dma-debug.c
index ea4cc3d..1b34d21 100644
--- a/lib/dma-debug.c
+++ b/lib/dma-debug.c
@@ -1495,14 +1495,22 @@ void debug_dma_alloc_coherent(struct device *dev, size_t size,
 	if (!entry)
 		return;
 
+	/* handle vmalloc and linear addresses */
+	if (!is_vmalloc_addr(virt) && !virt_to_page(virt))
+		return;
+
 	entry->type      = dma_debug_coherent;
 	entry->dev       = dev;
-	entry->pfn	 = page_to_pfn(virt_to_page(virt));
 	entry->offset	 = offset_in_page(virt);
 	entry->size      = size;
 	entry->dev_addr  = dma_addr;
 	entry->direction = DMA_BIDIRECTIONAL;
 
+	if (is_vmalloc_addr(virt))
+		entry->pfn = vmalloc_to_pfn(virt);
+	else
+		entry->pfn = page_to_pfn(virt_to_page(virt));
+
 	add_dma_entry(entry);
 }
 EXPORT_SYMBOL(debug_dma_alloc_coherent);
@@ -1513,13 +1521,21 @@ void debug_dma_free_coherent(struct device *dev, size_t size,
 	struct dma_debug_entry ref = {
 		.type           = dma_debug_coherent,
 		.dev            = dev,
-		.pfn		= page_to_pfn(virt_to_page(virt)),
 		.offset		= offset_in_page(virt),
 		.dev_addr       = addr,
 		.size           = size,
 		.direction      = DMA_BIDIRECTIONAL,
 	};
 
+	/* handle vmalloc and linear addresses */
+	if (!is_vmalloc_addr(virt) && !virt_to_page(virt))
+		return;
+
+	if (is_vmalloc_addr(virt))
+		ref.pfn = vmalloc_to_pfn(virt);
+	else
+		ref.pfn = page_to_pfn(virt_to_page(virt));
+
 	if (unlikely(dma_debug_disabled()))
 		return;
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
