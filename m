Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DA3F96B026F
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 05:00:14 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id f84so9357460pfj.0
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 02:00:14 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0067.outbound.protection.outlook.com. [104.47.34.67])
        by mx.google.com with ESMTPS id b85si687553pfj.584.2017.09.21.02.00.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 21 Sep 2017 02:00:13 -0700 (PDT)
From: Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>
Subject: [PATCH 2/4] numa, iommu/io-pgtable-arm: Use NUMA aware memory allocation for smmu translation tables
Date: Thu, 21 Sep 2017 14:29:20 +0530
Message-Id: <20170921085922.11659-3-ganapatrao.kulkarni@cavium.com>
In-Reply-To: <20170921085922.11659-1-ganapatrao.kulkarni@cavium.com>
References: <20170921085922.11659-1-ganapatrao.kulkarni@cavium.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Will.Deacon@arm.com, robin.murphy@arm.com, lorenzo.pieralisi@arm.com, hanjun.guo@linaro.org, joro@8bytes.org, vbabka@suse.cz, akpm@linux-foundation.org, mhocko@suse.com, Tomasz.Nowicki@cavium.com, Robert.Richter@cavium.com, jnair@caviumnetworks.com, gklkml16@gmail.com

function __arm_lpae_alloc_pages is used to allcoated memory for smmu
translation tables. updating function to allocate memory/pages
from the proximity domain of SMMU device.

Signed-off-by: Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>
---
 drivers/iommu/io-pgtable-arm.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/iommu/io-pgtable-arm.c b/drivers/iommu/io-pgtable-arm.c
index e8018a3..f6d01f6 100644
--- a/drivers/iommu/io-pgtable-arm.c
+++ b/drivers/iommu/io-pgtable-arm.c
@@ -215,8 +215,10 @@ static void *__arm_lpae_alloc_pages(size_t size, gfp_t gfp,
 {
 	struct device *dev = cfg->iommu_dev;
 	dma_addr_t dma;
-	void *pages = alloc_pages_exact(size, gfp | __GFP_ZERO);
+	void *pages;
 
+	pages = alloc_pages_exact_nid(dev_to_node(dev), size,
+			gfp | __GFP_ZERO);
 	if (!pages)
 		return NULL;
 
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
