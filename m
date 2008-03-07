From: Andi Kleen <andi@firstfloor.org>
References: <200803071007.493903088@firstfloor.org>
In-Reply-To: <200803071007.493903088@firstfloor.org>
Subject: [PATCH] [11/13] Switch x86-64 dma_alloc_coherent over to the maskable allocator
Message-Id: <20080307090721.B2DA41B419C@basil.firstfloor.org>
Date: Fri,  7 Mar 2008 10:07:21 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Andi Kleen <ak@suse.de>

---
 arch/x86/kernel/pci-dma_64.c |   49 +++++++++++++------------------------------
 1 file changed, 15 insertions(+), 34 deletions(-)

Index: linux/arch/x86/kernel/pci-dma_64.c
===================================================================
--- linux.orig/arch/x86/kernel/pci-dma_64.c
+++ linux/arch/x86/kernel/pci-dma_64.c
@@ -47,11 +47,16 @@ struct device fallback_dev = {
 
 /* Allocate DMA memory on node near device */
 noinline static void *
-dma_alloc_pages(struct device *dev, gfp_t gfp, unsigned order)
+dma_alloc_pages(struct device *dev, gfp_t gfp, unsigned size,
+		unsigned long dma_mask)
 {
 	struct page *page;
 	int node;
 
+	/* For small masks use DMA allocator without node affinity */
+	if (dma_mask < DMA_32BIT_MASK)
+		return get_pages_mask(gfp, size, dma_mask);
+
 	node = dev_to_node(dev);
 	if (node == -1)
 		node = numa_node_id();
@@ -59,7 +64,8 @@ dma_alloc_pages(struct device *dev, gfp_
 	if (node < first_node(node_online_map))
 		node = first_node(node_online_map);
 
-	page = alloc_pages_node(node, gfp, order);
+	page = alloc_pages_node(node, gfp, get_order(size));
+
 	return page ? page_address(page) : NULL;
 }
 
@@ -91,15 +97,10 @@ dma_alloc_coherent(struct device *dev, s
 	   uses the normal dma_mask for alloc_coherent. */
 	dma_mask &= *dev->dma_mask;
 
-	/* Why <=? Even when the mask is smaller than 4GB it is often
-	   larger than 16MB and in this case we have a chance of
-	   finding fitting memory in the next higher zone first. If
-	   not retry with true GFP_DMA. -AK */
 	if (dma_mask <= DMA_32BIT_MASK)
 		gfp |= GFP_DMA32;
 
- again:
-	memory = dma_alloc_pages(dev, gfp, get_order(size));
+	memory = dma_alloc_pages(dev, gfp, size, dma_mask);
 	if (memory == NULL)
 		return NULL;
 
@@ -108,25 +109,10 @@ dma_alloc_coherent(struct device *dev, s
 		bus = virt_to_bus(memory);
 	        high = (bus + size) >= dma_mask;
 		mmu = high;
-		if (force_iommu && !(gfp & GFP_DMA))
+		if (force_iommu)
 			mmu = 1;
 		else if (high) {
-			free_pages((unsigned long)memory,
-				   get_order(size));
-
-			/* Don't use the 16MB ZONE_DMA unless absolutely
-			   needed. It's better to use remapping first. */
-			if (dma_mask < DMA_32BIT_MASK && !(gfp & GFP_DMA)) {
-				gfp = (gfp & ~GFP_DMA32) | GFP_DMA;
-				goto again;
-			}
-
-			/* Let low level make its own zone decisions */
-			gfp &= ~(GFP_DMA32|GFP_DMA);
-
-			if (dma_ops->alloc_coherent)
-				return dma_ops->alloc_coherent(dev, size,
-							   dma_handle, gfp);
+			free_pages_mask(memory, size);
 			return NULL;
 		}
 
@@ -137,12 +123,6 @@ dma_alloc_coherent(struct device *dev, s
 		}
 	}
 
-	if (dma_ops->alloc_coherent) {
-		free_pages((unsigned long)memory, get_order(size));
-		gfp &= ~(GFP_DMA|GFP_DMA32);
-		return dma_ops->alloc_coherent(dev, size, dma_handle, gfp);
-	}
-
 	if (dma_ops->map_simple) {
 		*dma_handle = dma_ops->map_simple(dev, memory,
 					      size,
@@ -153,7 +133,7 @@ dma_alloc_coherent(struct device *dev, s
 
 	if (panic_on_overflow)
 		panic("dma_alloc_coherent: IOMMU overflow by %lu bytes\n",size);
-	free_pages((unsigned long)memory, get_order(size));
+	free_pages_mask(memory, size);
 	return NULL;
 }
 EXPORT_SYMBOL(dma_alloc_coherent);
@@ -166,9 +146,10 @@ void dma_free_coherent(struct device *de
 			 void *vaddr, dma_addr_t bus)
 {
 	WARN_ON(irqs_disabled());	/* for portability */
+	/* RED-PEN swiotlb does unnecessary copy here */
 	if (dma_ops->unmap_single)
 		dma_ops->unmap_single(dev, bus, size, 0);
-	free_pages((unsigned long)vaddr, get_order(size));
+	free_pages_mask(vaddr, size);
 }
 EXPORT_SYMBOL(dma_free_coherent);
 
@@ -191,7 +172,7 @@ int dma_supported(struct device *dev, u6
 
 	/* Copied from i386. Doesn't make much sense, because it will
 	   only work for pci_alloc_coherent.
-	   The caller just has to use GFP_DMA in this case. */
+	   The caller just has to use *_mask allocations in this case. */
         if (mask < DMA_24BIT_MASK)
                 return 0;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
