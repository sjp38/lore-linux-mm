Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 94E2E6B025F
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 08:29:54 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id 20so111740087wmh.1
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 05:29:54 -0700 (PDT)
Received: from mail.free-electrons.com (down.free-electrons.com. [37.187.137.238])
        by mx.google.com with ESMTP id p5si7308408wmd.62.2016.03.31.05.29.49
        for <linux-mm@kvack.org>;
        Thu, 31 Mar 2016 05:29:49 -0700 (PDT)
From: Boris Brezillon <boris.brezillon@free-electrons.com>
Subject: [PATCH 3/4] spi: use sg_alloc_table_from_buf()
Date: Thu, 31 Mar 2016 14:29:43 +0200
Message-Id: <1459427384-21374-4-git-send-email-boris.brezillon@free-electrons.com>
In-Reply-To: <1459427384-21374-1-git-send-email-boris.brezillon@free-electrons.com>
References: <1459427384-21374-1-git-send-email-boris.brezillon@free-electrons.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, linux-mtd@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Dave Gordon <david.s.gordon@intel.com>
Cc: Mark Brown <broonie@kernel.org>, linux-spi@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Vinod Koul <vinod.koul@intel.com>, Dan Williams <dan.j.williams@intel.com>, dmaengine@vger.kernel.org, Mauro Carvalho Chehab <m.chehab@samsung.com>, Hans Verkuil <hans.verkuil@cisco.com>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, linux-media@vger.kernel.org, Boris Brezillon <boris.brezillon@free-electrons.com>, Richard Weinberger <richard@nod.at>, Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, linux-crypto@vger.kernel.org, Vignesh R <vigneshr@ti.com>, linux-mm@kvack.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org

Replace custom implementation of sg_alloc_table_from_buf() by a call to
sg_alloc_table_from_buf().

Signed-off-by: Boris Brezillon <boris.brezillon@free-electrons.com>
---
 drivers/spi/spi.c | 45 +++++----------------------------------------
 1 file changed, 5 insertions(+), 40 deletions(-)

diff --git a/drivers/spi/spi.c b/drivers/spi/spi.c
index de2f2f9..eed461d 100644
--- a/drivers/spi/spi.c
+++ b/drivers/spi/spi.c
@@ -705,49 +705,14 @@ static int spi_map_buf(struct spi_master *master, struct device *dev,
 		       struct sg_table *sgt, void *buf, size_t len,
 		       enum dma_data_direction dir)
 {
-	const bool vmalloced_buf = is_vmalloc_addr(buf);
-	unsigned int max_seg_size = dma_get_max_seg_size(dev);
-	int desc_len;
-	int sgs;
-	struct page *vm_page;
-	void *sg_buf;
-	size_t min;
-	int i, ret;
-
-	if (vmalloced_buf) {
-		desc_len = min_t(int, max_seg_size, PAGE_SIZE);
-		sgs = DIV_ROUND_UP(len + offset_in_page(buf), desc_len);
-	} else {
-		desc_len = min_t(int, max_seg_size, master->max_dma_len);
-		sgs = DIV_ROUND_UP(len, desc_len);
-	}
+	struct sg_constraints constraints = { };
+	int ret;
 
-	ret = sg_alloc_table(sgt, sgs, GFP_KERNEL);
-	if (ret != 0)
+	constraints.max_segment_size = dma_get_max_seg_size(dev);
+	ret = sg_alloc_table_from_buf(sgt, buf, len, &constraints, GFP_KERNEL);
+	if (ret)
 		return ret;
 
-	for (i = 0; i < sgs; i++) {
-
-		if (vmalloced_buf) {
-			min = min_t(size_t,
-				    len, desc_len - offset_in_page(buf));
-			vm_page = vmalloc_to_page(buf);
-			if (!vm_page) {
-				sg_free_table(sgt);
-				return -ENOMEM;
-			}
-			sg_set_page(&sgt->sgl[i], vm_page,
-				    min, offset_in_page(buf));
-		} else {
-			min = min_t(size_t, len, desc_len);
-			sg_buf = buf;
-			sg_set_buf(&sgt->sgl[i], sg_buf, min);
-		}
-
-		buf += min;
-		len -= min;
-	}
-
 	ret = dma_map_sg(dev, sgt->sgl, sgt->nents, dir);
 	if (!ret)
 		ret = -ENOMEM;
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
