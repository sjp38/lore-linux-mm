Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 822486B002F
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 13:19:45 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt2 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LT9006AAUSU2P80@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 18 Oct 2011 18:19:42 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LT900MYLUSTUV@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 18 Oct 2011 18:19:42 +0100 (BST)
Date: Tue, 18 Oct 2011 19:19:20 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 3/8] ARM: dma-mapping: implement dma sg methods on top of any
 generic dma ops
In-reply-to: <1318958365-19120-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1318958365-19120-4-git-send-email-m.szyprowski@samsung.com>
References: <1318958365-19120-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>

This patch converts all dma_sg methods to be generic (independent of the
current DMA mapping implementation for ARM architecture). All dma sg
operations are now implemented on top of respective
dma_map_page/dma_sync_single_for* operations from dma_map_ops structure.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/arm/mm/dma-mapping.c |   35 +++++++++++++++--------------------
 1 files changed, 15 insertions(+), 20 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 31692dc..4b0f084 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -856,12 +856,13 @@ EXPORT_SYMBOL(___dma_page_dev_to_cpu);
 int arm_dma_map_sg(struct device *dev, struct scatterlist *sg, int nents,
 		enum dma_data_direction dir, struct dma_attrs *attrs)
 {
+	struct dma_map_ops *ops = get_dma_ops(dev);
 	struct scatterlist *s;
 	int i, j;
 
 	for_each_sg(sg, s, nents, i) {
-		s->dma_address = __dma_map_page(dev, sg_page(s), s->offset,
-						s->length, dir);
+		s->dma_address = ops->map_page(dev, sg_page(s), s->offset,
+						s->length, dir, attrs);
 		if (dma_mapping_error(dev, s->dma_address))
 			goto bad_mapping;
 	}
@@ -869,7 +870,7 @@ int arm_dma_map_sg(struct device *dev, struct scatterlist *sg, int nents,
 
  bad_mapping:
 	for_each_sg(sg, s, i, j)
-		__dma_unmap_page(dev, sg_dma_address(s), sg_dma_len(s), dir);
+		ops->unmap_page(dev, sg_dma_address(s), sg_dma_len(s), dir, attrs);
 	return 0;
 }
 
@@ -886,11 +887,13 @@ int arm_dma_map_sg(struct device *dev, struct scatterlist *sg, int nents,
 void arm_dma_unmap_sg(struct device *dev, struct scatterlist *sg, int nents,
 		enum dma_data_direction dir, struct dma_attrs *attrs)
 {
+	struct dma_map_ops *ops = get_dma_ops(dev);
 	struct scatterlist *s;
+
 	int i;
 
 	for_each_sg(sg, s, nents, i)
-		__dma_unmap_page(dev, sg_dma_address(s), sg_dma_len(s), dir);
+		ops->unmap_page(dev, sg_dma_address(s), sg_dma_len(s), dir, attrs);
 }
 
 /**
@@ -903,17 +906,13 @@ void arm_dma_unmap_sg(struct device *dev, struct scatterlist *sg, int nents,
 void arm_dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
 			int nents, enum dma_data_direction dir)
 {
+	struct dma_map_ops *ops = get_dma_ops(dev);
 	struct scatterlist *s;
 	int i;
 
-	for_each_sg(sg, s, nents, i) {
-		if (!dmabounce_sync_for_cpu(dev, sg_dma_address(s),
-					    sg_dma_len(s), dir))
-			continue;
-
-		__dma_page_dev_to_cpu(sg_page(s), s->offset,
-				      s->length, dir);
-	}
+	for_each_sg(sg, s, nents, i)
+		ops->sync_single_for_cpu(dev, sg_dma_address(s), s->length,
+					 dir);
 }
 
 /**
@@ -926,17 +925,13 @@ void arm_dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
 void arm_dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
 			int nents, enum dma_data_direction dir)
 {
+	struct dma_map_ops *ops = get_dma_ops(dev);
 	struct scatterlist *s;
 	int i;
 
-	for_each_sg(sg, s, nents, i) {
-		if (!dmabounce_sync_for_device(dev, sg_dma_address(s),
-					sg_dma_len(s), dir))
-			continue;
-
-		__dma_page_cpu_to_dev(sg_page(s), s->offset,
-				      s->length, dir);
-	}
+	for_each_sg(sg, s, nents, i)
+		ops->sync_single_for_device(dev, sg_dma_address(s), s->length,
+					    dir);
 }
 
 /*
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
