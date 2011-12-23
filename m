Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id DFC1F6B005C
	for <linux-mm@kvack.org>; Fri, 23 Dec 2011 07:28:01 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LWN00MJSPAN6940@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 23 Dec 2011 12:27:59 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LWN006Z2PAMCM@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 23 Dec 2011 12:27:59 +0000 (GMT)
Date: Fri, 23 Dec 2011 13:27:24 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 05/14] IA64: adapt for dma_map_ops changes
In-reply-to: <1324643253-3024-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1324643253-3024-6-git-send-email-m.szyprowski@samsung.com>
References: <1324643253-3024-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Stephen Rothwell <sfr@canb.auug.org.au>, microblaze-uclinux@itee.uq.edu.au, linux-arch@vger.kernel.org, x86@kernel.org, linux-sh@vger.kernel.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, discuss@x86-64.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Jonathan Corbet <corbet@lwn.net>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>

From: Andrzej Pietrasiewicz <andrzej.p@samsung.com>

Adapt core IA64 architecture code for dma_map_ops changes: replace
alloc/free_coherent with generic alloc/free methods.

Signed-off-by: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/ia64/hp/common/sba_iommu.c     |   11 ++++++-----
 arch/ia64/include/asm/dma-mapping.h |   18 ++++++++++++------
 arch/ia64/kernel/pci-swiotlb.c      |    9 +++++----
 arch/ia64/sn/pci/pci_dma.c          |    9 +++++----
 4 files changed, 28 insertions(+), 19 deletions(-)

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index f5f4ef1..e5eb9c4 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -1130,7 +1130,8 @@ void sba_unmap_single_attrs(struct device *dev, dma_addr_t iova, size_t size,
  * See Documentation/DMA-API-HOWTO.txt
  */
 static void *
-sba_alloc_coherent (struct device *dev, size_t size, dma_addr_t *dma_handle, gfp_t flags)
+sba_alloc_coherent(struct device *dev, size_t size, dma_addr_t *dma_handle,
+		   gfp_t flags, struct dma_attrs *attrs)
 {
 	struct ioc *ioc;
 	void *addr;
@@ -1192,8 +1193,8 @@ sba_alloc_coherent (struct device *dev, size_t size, dma_addr_t *dma_handle, gfp
  *
  * See Documentation/DMA-API-HOWTO.txt
  */
-static void sba_free_coherent (struct device *dev, size_t size, void *vaddr,
-			       dma_addr_t dma_handle)
+static void sba_free_coherent(struct device *dev, size_t size, void *vaddr,
+			      dma_addr_t dma_handle, struct dma_attrs *attrs)
 {
 	sba_unmap_single_attrs(dev, dma_handle, size, 0, NULL);
 	free_pages((unsigned long) vaddr, get_order(size));
@@ -2213,8 +2214,8 @@ sba_page_override(char *str)
 __setup("sbapagesize=",sba_page_override);
 
 struct dma_map_ops sba_dma_ops = {
-	.alloc_coherent		= sba_alloc_coherent,
-	.free_coherent		= sba_free_coherent,
+	.alloc			= sba_alloc_coherent,
+	.free			= sba_free_coherent,
 	.map_page		= sba_map_page,
 	.unmap_page		= sba_unmap_page,
 	.map_sg			= sba_map_sg_attrs,
diff --git a/arch/ia64/include/asm/dma-mapping.h b/arch/ia64/include/asm/dma-mapping.h
index 4336d08..4f5e814 100644
--- a/arch/ia64/include/asm/dma-mapping.h
+++ b/arch/ia64/include/asm/dma-mapping.h
@@ -23,23 +23,29 @@ extern void machvec_dma_sync_single(struct device *, dma_addr_t, size_t,
 extern void machvec_dma_sync_sg(struct device *, struct scatterlist *, int,
 				enum dma_data_direction);
 
-static inline void *dma_alloc_coherent(struct device *dev, size_t size,
-				       dma_addr_t *daddr, gfp_t gfp)
+#define dma_alloc_coherent(d,s,h,f)	dma_alloc_attrs(d,s,h,f,NULL)
+
+static inline void *dma_alloc_attrs(struct device *dev, size_t size,
+				    dma_addr_t *daddr, gfp_t gfp,
+				    struct dma_attrs *attrs)
 {
 	struct dma_map_ops *ops = platform_dma_get_ops(dev);
 	void *caddr;
 
-	caddr = ops->alloc_coherent(dev, size, daddr, gfp);
+	caddr = ops->alloc(dev, size, daddr, gfp, attrs);
 	debug_dma_alloc_coherent(dev, size, *daddr, caddr);
 	return caddr;
 }
 
-static inline void dma_free_coherent(struct device *dev, size_t size,
-				     void *caddr, dma_addr_t daddr)
+#define dma_free_coherent(d,s,c,h) dma_free_attrs(d,s,c,h,NULL)
+
+static inline void dma_free_attrs(struct device *dev, size_t size,
+				  void *caddr, dma_addr_t daddr,
+				  struct dma_attrs *attrs)
 {
 	struct dma_map_ops *ops = platform_dma_get_ops(dev);
 	debug_dma_free_coherent(dev, size, caddr, daddr);
-	ops->free_coherent(dev, size, caddr, daddr);
+	ops->free(dev, size, caddr, daddr, attrs);
 }
 
 #define dma_alloc_noncoherent(d, s, h, f) dma_alloc_coherent(d, s, h, f)
diff --git a/arch/ia64/kernel/pci-swiotlb.c b/arch/ia64/kernel/pci-swiotlb.c
index d9485d9..cc034c2 100644
--- a/arch/ia64/kernel/pci-swiotlb.c
+++ b/arch/ia64/kernel/pci-swiotlb.c
@@ -15,16 +15,17 @@ int swiotlb __read_mostly;
 EXPORT_SYMBOL(swiotlb);
 
 static void *ia64_swiotlb_alloc_coherent(struct device *dev, size_t size,
-					 dma_addr_t *dma_handle, gfp_t gfp)
+					 dma_addr_t *dma_handle, gfp_t gfp,
+					 struct dma_attrs *attrs)
 {
 	if (dev->coherent_dma_mask != DMA_BIT_MASK(64))
 		gfp |= GFP_DMA;
-	return swiotlb_alloc_coherent(dev, size, dma_handle, gfp);
+	return swiotlb_alloc_coherent(dev, size, dma_handle, gfp, attrs);
 }
 
 struct dma_map_ops swiotlb_dma_ops = {
-	.alloc_coherent = ia64_swiotlb_alloc_coherent,
-	.free_coherent = swiotlb_free_coherent,
+	.alloc = ia64_swiotlb_alloc_coherent,
+	.free = swiotlb_free_coherent,
 	.map_page = swiotlb_map_page,
 	.unmap_page = swiotlb_unmap_page,
 	.map_sg = swiotlb_map_sg_attrs,
diff --git a/arch/ia64/sn/pci/pci_dma.c b/arch/ia64/sn/pci/pci_dma.c
index a9d310d..3290d6e 100644
--- a/arch/ia64/sn/pci/pci_dma.c
+++ b/arch/ia64/sn/pci/pci_dma.c
@@ -76,7 +76,8 @@ EXPORT_SYMBOL(sn_dma_set_mask);
  * more information.
  */
 static void *sn_dma_alloc_coherent(struct device *dev, size_t size,
-				   dma_addr_t * dma_handle, gfp_t flags)
+				   dma_addr_t * dma_handle, gfp_t flags,
+				   struct dma_attrs *attrs)
 {
 	void *cpuaddr;
 	unsigned long phys_addr;
@@ -137,7 +138,7 @@ static void *sn_dma_alloc_coherent(struct device *dev, size_t size,
  * any associated IOMMU mappings.
  */
 static void sn_dma_free_coherent(struct device *dev, size_t size, void *cpu_addr,
-				 dma_addr_t dma_handle)
+				 dma_addr_t dma_handle, struct dma_attrs *attrs)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
 	struct sn_pcibus_provider *provider = SN_PCIDEV_BUSPROVIDER(pdev);
@@ -466,8 +467,8 @@ int sn_pci_legacy_write(struct pci_bus *bus, u16 port, u32 val, u8 size)
 }
 
 static struct dma_map_ops sn_dma_ops = {
-	.alloc_coherent		= sn_dma_alloc_coherent,
-	.free_coherent		= sn_dma_free_coherent,
+	.alloc			= sn_dma_alloc_coherent,
+	.free			= sn_dma_free_coherent,
 	.map_page		= sn_dma_map_page,
 	.unmap_page		= sn_dma_unmap_page,
 	.map_sg			= sn_dma_map_sg,
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
