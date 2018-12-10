Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 21F1F8E0001
	for <linux-mm@kvack.org>; Sun,  9 Dec 2018 20:15:30 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 82so8641389pfs.20
        for <linux-mm@kvack.org>; Sun, 09 Dec 2018 17:15:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n12sor14951329pgs.60.2018.12.09.17.15.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 09 Dec 2018 17:15:28 -0800 (PST)
From: Nicolas Boichat <drinkcat@chromium.org>
Subject: [PATCH v6 2/3] iommu/io-pgtable-arm-v7s: Request DMA32 memory, and improve debugging
Date: Mon, 10 Dec 2018 09:15:03 +0800
Message-Id: <20181210011504.122604-3-drinkcat@chromium.org>
In-Reply-To: <20181210011504.122604-1-drinkcat@chromium.org>
References: <20181210011504.122604-1-drinkcat@chromium.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <joro@8bytes.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com, hch@infradead.org, Matthew Wilcox <willy@infradead.org>, hsinyi@chromium.org, stable@vger.kernel.org

IOMMUs using ARMv7 short-descriptor format require page tables
(level 1 and 2) to be allocated within the first 4GB of RAM, even
on 64-bit systems.

For level 1/2 pages, ensure GFP_DMA32 is used if CONFIG_ZONE_DMA32
is defined (e.g. on arm64 platforms).

For level 2 pages, allocate a slab cache in SLAB_CACHE_DMA32. Note
that we do not explicitly pass GFP_DMA[32] to kmem_cache_zalloc,
as this is not strictly necessary, and would cause a warning
in mm/sl*b.c, as we did not update GFP_SLAB_BUG_MASK.

Also, print an error when the physical address does not fit in
32-bit, to make debugging easier in the future.

Cc: stable@vger.kernel.org
Fixes: ad67f5a6545f ("arm64: replace ZONE_DMA with ZONE_DMA32")
Signed-off-by: Nicolas Boichat <drinkcat@chromium.org>
---

Changes since v2:
 - Commit message

(v3 used the page_frag approach)

Changes since v4:
 - Do not pass ARM_V7S_TABLE_GFP_DMA to kmem_cache_zalloc, as this
   is unnecessary, and would trigger a warning.

Changes since v5:
 - Rename ARM_V7S_TABLE_SLAB_CACHE to ARM_V7S_TABLE_SLAB_FLAGS.

 drivers/iommu/io-pgtable-arm-v7s.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/iommu/io-pgtable-arm-v7s.c b/drivers/iommu/io-pgtable-arm-v7s.c
index 445c3bde04800c..d2fdb192f7610f 100644
--- a/drivers/iommu/io-pgtable-arm-v7s.c
+++ b/drivers/iommu/io-pgtable-arm-v7s.c
@@ -161,6 +161,14 @@
 
 #define ARM_V7S_TCR_PD1			BIT(5)
 
+#ifdef CONFIG_ZONE_DMA32
+#define ARM_V7S_TABLE_GFP_DMA GFP_DMA32
+#define ARM_V7S_TABLE_SLAB_FLAGS SLAB_CACHE_DMA32
+#else
+#define ARM_V7S_TABLE_GFP_DMA GFP_DMA
+#define ARM_V7S_TABLE_SLAB_FLAGS SLAB_CACHE_DMA
+#endif
+
 typedef u32 arm_v7s_iopte;
 
 static bool selftest_running;
@@ -198,13 +206,16 @@ static void *__arm_v7s_alloc_table(int lvl, gfp_t gfp,
 	void *table = NULL;
 
 	if (lvl == 1)
-		table = (void *)__get_dma_pages(__GFP_ZERO, get_order(size));
+		table = (void *)__get_free_pages(
+			__GFP_ZERO | ARM_V7S_TABLE_GFP_DMA, get_order(size));
 	else if (lvl == 2)
-		table = kmem_cache_zalloc(data->l2_tables, gfp | GFP_DMA);
+		table = kmem_cache_zalloc(data->l2_tables, gfp);
 	phys = virt_to_phys(table);
-	if (phys != (arm_v7s_iopte)phys)
+	if (phys != (arm_v7s_iopte)phys) {
 		/* Doesn't fit in PTE */
+		dev_err(dev, "Page table does not fit in PTE: %pa", &phys);
 		goto out_free;
+	}
 	if (table && !(cfg->quirks & IO_PGTABLE_QUIRK_NO_DMA)) {
 		dma = dma_map_single(dev, table, size, DMA_TO_DEVICE);
 		if (dma_mapping_error(dev, dma))
@@ -737,7 +748,7 @@ static struct io_pgtable *arm_v7s_alloc_pgtable(struct io_pgtable_cfg *cfg,
 	data->l2_tables = kmem_cache_create("io-pgtable_armv7s_l2",
 					    ARM_V7S_TABLE_SIZE(2),
 					    ARM_V7S_TABLE_SIZE(2),
-					    SLAB_CACHE_DMA, NULL);
+					    ARM_V7S_TABLE_SLAB_FLAGS, NULL);
 	if (!data->l2_tables)
 		goto out_free_data;
 
-- 
2.20.0.rc2.403.gdbc3b29805-goog
