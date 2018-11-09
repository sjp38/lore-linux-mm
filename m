Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id DADA76B06B9
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 03:25:11 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id x11-v6so741451pgp.20
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 00:25:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u17-v6sor7312686pgg.80.2018.11.09.00.25.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Nov 2018 00:25:10 -0800 (PST)
From: Nicolas Boichat <drinkcat@chromium.org>
Subject: [PATCH RFC 3/3] iommu/io-pgtable-arm-v7s: Request DMA32 memory, and improve debugging
Date: Fri,  9 Nov 2018 16:24:48 +0800
Message-Id: <20181109082448.150302-4-drinkcat@chromium.org>
In-Reply-To: <20181109082448.150302-1-drinkcat@chromium.org>
References: <20181109082448.150302-1-drinkcat@chromium.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, Joerg Roedel <joro@8bytes.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <alexander.levin@verizon.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com

For level 1 pages, use __get_dma32_pages to make sure physical
memory address is 32-bit.

For level 2 pages, kmem_cache_zalloc with GFP_DMA has been modified
in a previous patch to be allocated in DMA32 zone.

Also, print an error when the physical address does not fit in
32-bit, to make debugging easier in the future.

Fixes: ad67f5a6545f ("arm64: replace ZONE_DMA with ZONE_DMA32")
Signed-off-by: Nicolas Boichat <drinkcat@chromium.org>
---
 drivers/iommu/io-pgtable-arm-v7s.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/iommu/io-pgtable-arm-v7s.c b/drivers/iommu/io-pgtable-arm-v7s.c
index 445c3bde04800c..862fd404de84d8 100644
--- a/drivers/iommu/io-pgtable-arm-v7s.c
+++ b/drivers/iommu/io-pgtable-arm-v7s.c
@@ -198,13 +198,15 @@ static void *__arm_v7s_alloc_table(int lvl, gfp_t gfp,
 	void *table = NULL;
 
 	if (lvl == 1)
-		table = (void *)__get_dma_pages(__GFP_ZERO, get_order(size));
+		table = (void *)__get_dma32_pages(__GFP_ZERO, get_order(size));
 	else if (lvl == 2)
 		table = kmem_cache_zalloc(data->l2_tables, gfp | GFP_DMA);
 	phys = virt_to_phys(table);
-	if (phys != (arm_v7s_iopte)phys)
+	if (phys != (arm_v7s_iopte)phys) {
 		/* Doesn't fit in PTE */
+		dev_err(dev, "Page table does not fit: %pa", &phys);
 		goto out_free;
+	}
 	if (table && !(cfg->quirks & IO_PGTABLE_QUIRK_NO_DMA)) {
 		dma = dma_map_single(dev, table, size, DMA_TO_DEVICE);
 		if (dma_mapping_error(dev, dma))
-- 
2.19.1.930.g4563a0d9d0-goog
