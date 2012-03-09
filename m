Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 501236B0044
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 09:54:21 -0500 (EST)
Received: from euspt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M0M00B0XHEH00@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 09 Mar 2012 14:54:17 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M0M0012WHEI66@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 09 Mar 2012 14:54:19 +0000 (GMT)
Date: Fri, 09 Mar 2012 15:53:32 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH] ARM: dma-mapping: fix calculation of iova bitmap size
In-reply-to: <011701ccfc83$78030180$68090480$%szyprowski@samsung.com>
Message-id: <1331304812-10386-1-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <011701ccfc83$78030180$68090480$%szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, KyongHo Cho <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>

Fix calculation of iova address space for IOMMU-aware dma mapping.

Reported-by: Krishna Reddy <vdumpa@nvidia.com>
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
---
 arch/arm/mm/dma-mapping.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index ea5a0ad..f0f600a 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -1601,11 +1601,14 @@ struct dma_iommu_mapping *
 arm_iommu_create_mapping(struct bus_type *bus, dma_addr_t base, size_t size,
 			 int order)
 {
-	unsigned int count = (size >> PAGE_SHIFT) - order;
+	unsigned int count = size >> (PAGE_SHIFT + order);
 	unsigned int bitmap_size = BITS_TO_LONGS(count) * sizeof(long);
 	struct dma_iommu_mapping *mapping;
 	int err = -ENOMEM;
 
+	if (!count)
+		return ERR_PTR(-EINVAL);
+
 	mapping = kzalloc(sizeof(struct dma_iommu_mapping), GFP_KERNEL);
 	if (!mapping)
 		goto err;
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
