Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 90B84280264
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 14:07:00 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id xx10so2575215pac.2
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:07:00 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id h65si16628710pfa.198.2016.10.24.11.06.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 11:06:59 -0700 (PDT)
Subject: [net-next PATCH RFC 22/26] dma: Add calls for dma_map_page_attrs
 and dma_unmap_page_attrs
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Mon, 24 Oct 2016 08:06:23 -0400
Message-ID: <20161024120623.16276.82939.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: davem@davemloft.net, brouer@redhat.com

Add support for mapping and unmapping a page with attributes.  The primary
use for this is currently to allow for us to pass the
DMA_ATTR_SKIP_CPU_SYNC attribute when mapping and unmapping a page.  On
some architectures such as ARM the synchronization has significant overhead
and if we are already taking care of the sync_for_cpu and sync_for_device
from the driver there isn't much need to handle this in the map/unmap calls
as well.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 include/linux/dma-mapping.h |   20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 08528af..10c5a17 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -243,29 +243,33 @@ static inline void dma_unmap_sg_attrs(struct device *dev, struct scatterlist *sg
 		ops->unmap_sg(dev, sg, nents, dir, attrs);
 }
 
-static inline dma_addr_t dma_map_page(struct device *dev, struct page *page,
-				      size_t offset, size_t size,
-				      enum dma_data_direction dir)
+static inline dma_addr_t dma_map_page_attrs(struct device *dev,
+					    struct page *page,
+					    size_t offset, size_t size,
+					    enum dma_data_direction dir,
+					    unsigned long attrs)
 {
 	struct dma_map_ops *ops = get_dma_ops(dev);
 	dma_addr_t addr;
 
 	kmemcheck_mark_initialized(page_address(page) + offset, size);
 	BUG_ON(!valid_dma_direction(dir));
-	addr = ops->map_page(dev, page, offset, size, dir, 0);
+	addr = ops->map_page(dev, page, offset, size, dir, attrs);
 	debug_dma_map_page(dev, page, offset, size, dir, addr, false);
 
 	return addr;
 }
 
-static inline void dma_unmap_page(struct device *dev, dma_addr_t addr,
-				  size_t size, enum dma_data_direction dir)
+static inline void dma_unmap_page_attrs(struct device *dev,
+					dma_addr_t addr, size_t size,
+					enum dma_data_direction dir,
+					unsigned long attrs)
 {
 	struct dma_map_ops *ops = get_dma_ops(dev);
 
 	BUG_ON(!valid_dma_direction(dir));
 	if (ops->unmap_page)
-		ops->unmap_page(dev, addr, size, dir, 0);
+		ops->unmap_page(dev, addr, size, dir, attrs);
 	debug_dma_unmap_page(dev, addr, size, dir, false);
 }
 
@@ -385,6 +389,8 @@ static inline void dma_sync_single_range_for_device(struct device *dev,
 #define dma_unmap_single(d, a, s, r) dma_unmap_single_attrs(d, a, s, r, 0)
 #define dma_map_sg(d, s, n, r) dma_map_sg_attrs(d, s, n, r, 0)
 #define dma_unmap_sg(d, s, n, r) dma_unmap_sg_attrs(d, s, n, r, 0)
+#define dma_map_page(d, p, o, s, r) dma_map_page_attrs(d, p, o, s, r, 0)
+#define dma_unmap_page(d, a, s, r) dma_unmap_page_attrs(d, a, s, r, 0)
 
 extern int dma_common_mmap(struct device *dev, struct vm_area_struct *vma,
 			   void *cpu_addr, dma_addr_t dma_addr, size_t size);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
