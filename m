Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id EB9296B027D
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 17:38:14 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id r13so12035272pag.1
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 14:38:14 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id e1si19059580paf.193.2016.10.25.14.38.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 14:38:14 -0700 (PDT)
Subject: [net-next PATCH 09/27] arch/frv: Add option to skip sync on DMA map
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Tue, 25 Oct 2016 11:37:36 -0400
Message-ID: <20161025153736.4815.49992.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161025153220.4815.61239.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161025153220.4815.61239.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: davem@davemloft.net, brouer@redhat.com

The use of DMA_ATTR_SKIP_CPU_SYNC was not consistent across all of the DMA
APIs in the arch/arm folder.  This change is meant to correct that so that
we get consistent behavior.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/frv/mb93090-mb00/pci-dma-nommu.c |   14 ++++++++++----
 arch/frv/mb93090-mb00/pci-dma.c       |    9 +++++++--
 2 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/arch/frv/mb93090-mb00/pci-dma-nommu.c b/arch/frv/mb93090-mb00/pci-dma-nommu.c
index 90f2e4c..1876881 100644
--- a/arch/frv/mb93090-mb00/pci-dma-nommu.c
+++ b/arch/frv/mb93090-mb00/pci-dma-nommu.c
@@ -109,16 +109,19 @@ static int frv_dma_map_sg(struct device *dev, struct scatterlist *sglist,
 		int nents, enum dma_data_direction direction,
 		unsigned long attrs)
 {
-	int i;
 	struct scatterlist *sg;
+	int i;
+
+	BUG_ON(direction == DMA_NONE);
+
+	if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
+		return nents;
 
 	for_each_sg(sglist, sg, nents, i) {
 		frv_cache_wback_inv(sg_dma_address(sg),
 				    sg_dma_address(sg) + sg_dma_len(sg));
 	}
 
-	BUG_ON(direction == DMA_NONE);
-
 	return nents;
 }
 
@@ -127,7 +130,10 @@ static dma_addr_t frv_dma_map_page(struct device *dev, struct page *page,
 		enum dma_data_direction direction, unsigned long attrs)
 {
 	BUG_ON(direction == DMA_NONE);
-	flush_dcache_page(page);
+
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		flush_dcache_page(page);
+
 	return (dma_addr_t) page_to_phys(page) + offset;
 }
 
diff --git a/arch/frv/mb93090-mb00/pci-dma.c b/arch/frv/mb93090-mb00/pci-dma.c
index f585745..dba7df9 100644
--- a/arch/frv/mb93090-mb00/pci-dma.c
+++ b/arch/frv/mb93090-mb00/pci-dma.c
@@ -40,13 +40,16 @@ static int frv_dma_map_sg(struct device *dev, struct scatterlist *sglist,
 		int nents, enum dma_data_direction direction,
 		unsigned long attrs)
 {
+	struct scatterlist *sg;
 	unsigned long dampr2;
 	void *vaddr;
 	int i;
-	struct scatterlist *sg;
 
 	BUG_ON(direction == DMA_NONE);
 
+	if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
+		return nents;
+
 	dampr2 = __get_DAMPR(2);
 
 	for_each_sg(sglist, sg, nents, i) {
@@ -70,7 +73,9 @@ static dma_addr_t frv_dma_map_page(struct device *dev, struct page *page,
 		unsigned long offset, size_t size,
 		enum dma_data_direction direction, unsigned long attrs)
 {
-	flush_dcache_page(page);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		flush_dcache_page(page);
+
 	return (dma_addr_t) page_to_phys(page) + offset;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
