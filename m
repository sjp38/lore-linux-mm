From: Andi Kleen <andi@firstfloor.org>
References: <200803071007.493903088@firstfloor.org>
In-Reply-To: <200803071007.493903088@firstfloor.org>
Subject: [PATCH] [10/13] Switch the 32bit dma_alloc_coherent functions over to use the maskable allocator
Message-Id: <20080307090720.AEE1B1B419C@basil.firstfloor.org>
Date: Fri,  7 Mar 2008 10:07:20 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Andi Kleen <ak@suse.de>

---
 arch/x86/kernel/pci-dma_32.c |   17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

Index: linux/arch/x86/kernel/pci-dma_32.c
===================================================================
--- linux.orig/arch/x86/kernel/pci-dma_32.c
+++ linux/arch/x86/kernel/pci-dma_32.c
@@ -27,11 +27,12 @@ void *dma_alloc_coherent(struct device *
 {
 	void *ret;
 	struct dma_coherent_mem *mem = dev ? dev->dma_mem : NULL;
-	int order = get_order(size);
+	u64 mask;
 	/* ignore region specifiers */
-	gfp &= ~(__GFP_DMA | __GFP_HIGHMEM);
+	gfp &= ~__GFP_HIGHMEM;
 
 	if (mem) {
+		int order = get_order(size);
 		int page = bitmap_find_free_region(mem->bitmap, mem->size,
 						     order);
 		if (page >= 0) {
@@ -44,10 +45,12 @@ void *dma_alloc_coherent(struct device *
 			return NULL;
 	}
 
-	if (dev == NULL || (dev->coherent_dma_mask < 0xffffffff))
-		gfp |= GFP_DMA;
+	if (dev == NULL)
+		mask = TRAD_DMA_MASK;
+	else
+		mask = dev->coherent_dma_mask;
 
-	ret = (void *)__get_free_pages(gfp, order);
+	ret = get_pages_mask(gfp, size, mask);
 
 	if (ret != NULL) {
 		memset(ret, 0, size);
@@ -61,15 +64,15 @@ void dma_free_coherent(struct device *de
 			 void *vaddr, dma_addr_t dma_handle)
 {
 	struct dma_coherent_mem *mem = dev ? dev->dma_mem : NULL;
-	int order = get_order(size);
 
 	WARN_ON(irqs_disabled());	/* for portability */
 	if (mem && vaddr >= mem->virt_base && vaddr < (mem->virt_base + (mem->size << PAGE_SHIFT))) {
+		int order = get_order(size);
 		int page = (vaddr - mem->virt_base) >> PAGE_SHIFT;
 
 		bitmap_release_region(mem->bitmap, page, order);
 	} else
-		free_pages((unsigned long)vaddr, order);
+		free_pages_mask(vaddr, size);
 }
 EXPORT_SYMBOL(dma_free_coherent);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
