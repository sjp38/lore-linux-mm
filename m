Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 715AC6B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 09:24:59 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y29so18205444pff.6
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 06:24:59 -0700 (PDT)
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTPS id f4si5924998plb.202.2017.09.26.06.24.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 06:24:57 -0700 (PDT)
From: <miles.chen@mediatek.com>
Subject: [PATCH] dma-debug: fix incorrect pfn calculation
Date: Tue, 26 Sep 2017 21:24:47 +0800
Message-ID: <1506432287-7214-1-git-send-email-miles.chen@mediatek.com>
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
always use type "dma_debug_coherent" and assume that dma_alloc_coherent()
always returns a linear address.

However if a device returns false on is_device_dma_coherent(),
dma_alloc_coherent() will create another non-cacheable mapping
(also non linear). In this case, page_to_pfn(virt_to_page(virt)) will
return an incorrect pfn. If the pfn is valid and mapped as a COW page,
we will hit the warning when doing wp_page_copy().

Fix this by calculating correct pfn if is_device_dma_coherent()
returns false.

Signed-off-by: Miles Chen <miles.chen@mediatek.com>
---
 lib/dma-debug.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/lib/dma-debug.c b/lib/dma-debug.c
index ea4cc3d..b17e56e 100644
--- a/lib/dma-debug.c
+++ b/lib/dma-debug.c
@@ -47,6 +47,8 @@ enum {
 	dma_debug_sg,
 	dma_debug_coherent,
 	dma_debug_resource,
+	dma_debug_noncoherent,
+	nr_dma_debug_types,
 };
 
 enum map_err_types {
@@ -154,9 +156,9 @@ static inline bool dma_debug_disabled(void)
 	[MAP_ERR_CHECKED] = "dma map error checked",
 };
 
-static const char *type2name[5] = { "single", "page",
+static const char *type2name[nr_dma_debug_types] = { "single", "page",
 				    "scather-gather", "coherent",
-				    "resource" };
+				    "resource", "noncoherent" };
 
 static const char *dir2name[4] = { "DMA_BIDIRECTIONAL", "DMA_TO_DEVICE",
 				   "DMA_FROM_DEVICE", "DMA_NONE" };
@@ -1484,6 +1486,7 @@ void debug_dma_alloc_coherent(struct device *dev, size_t size,
 			      dma_addr_t dma_addr, void *virt)
 {
 	struct dma_debug_entry *entry;
+	bool coherent = is_device_dma_coherent(dev);
 
 	if (unlikely(dma_debug_disabled()))
 		return;
@@ -1495,9 +1498,11 @@ void debug_dma_alloc_coherent(struct device *dev, size_t size,
 	if (!entry)
 		return;
 
-	entry->type      = dma_debug_coherent;
+	entry->type      = coherent ? dma_debug_coherent :
+					dma_debug_noncoherent;
 	entry->dev       = dev;
-	entry->pfn	 = page_to_pfn(virt_to_page(virt));
+	entry->pfn	 = coherent ? page_to_pfn(virt_to_page(virt)) :
+					dma_addr >> PAGE_SHIFT;
 	entry->offset	 = offset_in_page(virt);
 	entry->size      = size;
 	entry->dev_addr  = dma_addr;
@@ -1510,10 +1515,13 @@ void debug_dma_alloc_coherent(struct device *dev, size_t size,
 void debug_dma_free_coherent(struct device *dev, size_t size,
 			 void *virt, dma_addr_t addr)
 {
+	bool coherent = is_device_dma_coherent(dev);
 	struct dma_debug_entry ref = {
-		.type           = dma_debug_coherent,
+		.type           = coherent ? dma_debug_coherent :
+						dma_debug_noncoherent,
 		.dev            = dev,
-		.pfn		= page_to_pfn(virt_to_page(virt)),
+		.pfn		= coherent ? page_to_pfn(virt_to_page(virt)) :
+						addr >> PAGE_SHIFT,
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
