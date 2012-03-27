Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 8793B6B00EA
	for <linux-mm@kvack.org>; Tue, 27 Mar 2012 09:43:26 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M1J00LXVQ41KR60@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 27 Mar 2012 14:43:13 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M1J008D9Q49GS@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 27 Mar 2012 14:43:23 +0100 (BST)
Date: Tue, 27 Mar 2012 15:42:36 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv2 02/14] X86 & IA64: adapt for dma_map_ops changes
In-reply-to: <1332855768-32583-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1332855768-32583-3-git-send-email-m.szyprowski@samsung.com>
References: <1332855768-32583-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Stephen Rothwell <sfr@canb.auug.org.au>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, microblaze-uclinux@itee.uq.edu.au, linux-arch@vger.kernel.org, x86@kernel.org, linux-sh@vger.kernel.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, discuss@x86-64.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Jonathan Corbet <corbet@lwn.net>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Kevin Cernekee <cernekee@gmail.com>, Dezhong Diao <dediao@cisco.com>, Richard Kuo <rkuo@codeaurora.org>, "David S. Miller" <davem@davemloft.net>, Michal Simek <monstr@monstr.eu>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Paul Mundt <lethal@linux-sh.org>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

From: Andrzej Pietrasiewicz <andrzej.p@samsung.com>

Adapt core x86 and IA64 architecture code for dma_map_ops changes: replace
alloc/free_coherent with generic alloc/free methods.

Signed-off-by: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
Acked-by: Kyungmin Park <kyungmin.park@samsung.com>
[removed swiotlb related changes and replaced it with wrappers,
 merged with IA64 patch to avoid inter-patch dependences in intel-iommu code]
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Reviewed-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/ia64/hp/common/sba_iommu.c     |   11 ++++++-----
 arch/ia64/include/asm/dma-mapping.h |   18 ++++++++++++------
 arch/ia64/kernel/pci-swiotlb.c      |   14 +++++++++++---
 arch/ia64/sn/pci/pci_dma.c          |    9 +++++----
 arch/x86/include/asm/dma-mapping.h  |   26 ++++++++++++++++----------
 arch/x86/kernel/amd_gart_64.c       |   11 ++++++-----
 arch/x86/kernel/pci-calgary_64.c    |    9 +++++----
 arch/x86/kernel/pci-dma.c           |    3 ++-
 arch/x86/kernel/pci-nommu.c         |    6 +++---
 arch/x86/kernel/pci-swiotlb.c       |   17 +++++++++++++----
 arch/x86/xen/pci-swiotlb-xen.c      |    4 ++--
 drivers/iommu/amd_iommu.c           |   10 ++++++----
 drivers/iommu/intel-iommu.c         |    9 +++++----
 drivers/xen/swiotlb-xen.c           |    5 +++--
 include/xen/swiotlb-xen.h           |    6 ++++--
 15 files changed, 99 insertions(+), 59 deletions(-)

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
index d9485d9..939260a 100644
--- a/arch/ia64/kernel/pci-swiotlb.c
+++ b/arch/ia64/kernel/pci-swiotlb.c
@@ -15,16 +15,24 @@ int swiotlb __read_mostly;
 EXPORT_SYMBOL(swiotlb);
 
 static void *ia64_swiotlb_alloc_coherent(struct device *dev, size_t size,
-					 dma_addr_t *dma_handle, gfp_t gfp)
+					 dma_addr_t *dma_handle, gfp_t gfp,
+					 struct dma_attrs *attrs)
 {
 	if (dev->coherent_dma_mask != DMA_BIT_MASK(64))
 		gfp |= GFP_DMA;
 	return swiotlb_alloc_coherent(dev, size, dma_handle, gfp);
 }
 
+static void ia64_swiotlb_free_coherent(struct device *dev, size_t size,
+				       void *vaddr, dma_addr_t dma_addr,
+				       struct dma_attrs *attrs)
+{
+	swiotlb_free_coherent(dev, size, vaddr, dma_addr);
+}
+
 struct dma_map_ops swiotlb_dma_ops = {
-	.alloc_coherent = ia64_swiotlb_alloc_coherent,
-	.free_coherent = swiotlb_free_coherent,
+	.alloc = ia64_swiotlb_alloc_coherent,
+	.free = ia64_swiotlb_free_coherent,
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
diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
index ed3065f..4b4331d 100644
--- a/arch/x86/include/asm/dma-mapping.h
+++ b/arch/x86/include/asm/dma-mapping.h
@@ -59,7 +59,8 @@ extern int dma_supported(struct device *hwdev, u64 mask);
 extern int dma_set_mask(struct device *dev, u64 mask);
 
 extern void *dma_generic_alloc_coherent(struct device *dev, size_t size,
-					dma_addr_t *dma_addr, gfp_t flag);
+					dma_addr_t *dma_addr, gfp_t flag,
+					struct dma_attrs *attrs);
 
 static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 {
@@ -111,9 +112,11 @@ static inline gfp_t dma_alloc_coherent_gfp_flags(struct device *dev, gfp_t gfp)
        return gfp;
 }
 
+#define dma_alloc_coherent(d,s,h,f)	dma_alloc_attrs(d,s,h,f,NULL)
+
 static inline void *
-dma_alloc_coherent(struct device *dev, size_t size, dma_addr_t *dma_handle,
-		gfp_t gfp)
+dma_alloc_attrs(struct device *dev, size_t size, dma_addr_t *dma_handle,
+		gfp_t gfp, struct dma_attrs *attrs)
 {
 	struct dma_map_ops *ops = get_dma_ops(dev);
 	void *memory;
@@ -129,18 +132,21 @@ dma_alloc_coherent(struct device *dev, size_t size, dma_addr_t *dma_handle,
 	if (!is_device_dma_capable(dev))
 		return NULL;
 
-	if (!ops->alloc_coherent)
+	if (!ops->alloc)
 		return NULL;
 
-	memory = ops->alloc_coherent(dev, size, dma_handle,
-				     dma_alloc_coherent_gfp_flags(dev, gfp));
+	memory = ops->alloc(dev, size, dma_handle,
+			    dma_alloc_coherent_gfp_flags(dev, gfp), attrs);
 	debug_dma_alloc_coherent(dev, size, *dma_handle, memory);
 
 	return memory;
 }
 
-static inline void dma_free_coherent(struct device *dev, size_t size,
-				     void *vaddr, dma_addr_t bus)
+#define dma_free_coherent(d,s,c,h) dma_free_attrs(d,s,c,h,NULL)
+
+static inline void dma_free_attrs(struct device *dev, size_t size,
+				  void *vaddr, dma_addr_t bus,
+				  struct dma_attrs *attrs)
 {
 	struct dma_map_ops *ops = get_dma_ops(dev);
 
@@ -150,8 +156,8 @@ static inline void dma_free_coherent(struct device *dev, size_t size,
 		return;
 
 	debug_dma_free_coherent(dev, size, vaddr, bus);
-	if (ops->free_coherent)
-		ops->free_coherent(dev, size, vaddr, bus);
+	if (ops->free)
+		ops->free(dev, size, vaddr, bus, attrs);
 }
 
 #endif
diff --git a/arch/x86/kernel/amd_gart_64.c b/arch/x86/kernel/amd_gart_64.c
index b1e7c7f..e663112 100644
--- a/arch/x86/kernel/amd_gart_64.c
+++ b/arch/x86/kernel/amd_gart_64.c
@@ -477,7 +477,7 @@ error:
 /* allocate and map a coherent mapping */
 static void *
 gart_alloc_coherent(struct device *dev, size_t size, dma_addr_t *dma_addr,
-		    gfp_t flag)
+		    gfp_t flag, struct dma_attrs *attrs)
 {
 	dma_addr_t paddr;
 	unsigned long align_mask;
@@ -500,7 +500,8 @@ gart_alloc_coherent(struct device *dev, size_t size, dma_addr_t *dma_addr,
 		}
 		__free_pages(page, get_order(size));
 	} else
-		return dma_generic_alloc_coherent(dev, size, dma_addr, flag);
+		return dma_generic_alloc_coherent(dev, size, dma_addr, flag,
+						  attrs);
 
 	return NULL;
 }
@@ -508,7 +509,7 @@ gart_alloc_coherent(struct device *dev, size_t size, dma_addr_t *dma_addr,
 /* free a coherent mapping */
 static void
 gart_free_coherent(struct device *dev, size_t size, void *vaddr,
-		   dma_addr_t dma_addr)
+		   dma_addr_t dma_addr, struct dma_attrs *attrs)
 {
 	gart_unmap_page(dev, dma_addr, size, DMA_BIDIRECTIONAL, NULL);
 	free_pages((unsigned long)vaddr, get_order(size));
@@ -700,8 +701,8 @@ static struct dma_map_ops gart_dma_ops = {
 	.unmap_sg			= gart_unmap_sg,
 	.map_page			= gart_map_page,
 	.unmap_page			= gart_unmap_page,
-	.alloc_coherent			= gart_alloc_coherent,
-	.free_coherent			= gart_free_coherent,
+	.alloc				= gart_alloc_coherent,
+	.free				= gart_free_coherent,
 	.mapping_error			= gart_mapping_error,
 };
 
diff --git a/arch/x86/kernel/pci-calgary_64.c b/arch/x86/kernel/pci-calgary_64.c
index 726494b..07b587c 100644
--- a/arch/x86/kernel/pci-calgary_64.c
+++ b/arch/x86/kernel/pci-calgary_64.c
@@ -431,7 +431,7 @@ static void calgary_unmap_page(struct device *dev, dma_addr_t dma_addr,
 }
 
 static void* calgary_alloc_coherent(struct device *dev, size_t size,
-	dma_addr_t *dma_handle, gfp_t flag)
+	dma_addr_t *dma_handle, gfp_t flag, struct dma_attrs *attrs)
 {
 	void *ret = NULL;
 	dma_addr_t mapping;
@@ -464,7 +464,8 @@ error:
 }
 
 static void calgary_free_coherent(struct device *dev, size_t size,
-				  void *vaddr, dma_addr_t dma_handle)
+				  void *vaddr, dma_addr_t dma_handle,
+				  struct dma_attrs *attrs)
 {
 	unsigned int npages;
 	struct iommu_table *tbl = find_iommu_table(dev);
@@ -477,8 +478,8 @@ static void calgary_free_coherent(struct device *dev, size_t size,
 }
 
 static struct dma_map_ops calgary_dma_ops = {
-	.alloc_coherent = calgary_alloc_coherent,
-	.free_coherent = calgary_free_coherent,
+	.alloc = calgary_alloc_coherent,
+	.free = calgary_free_coherent,
 	.map_sg = calgary_map_sg,
 	.unmap_sg = calgary_unmap_sg,
 	.map_page = calgary_map_page,
diff --git a/arch/x86/kernel/pci-dma.c b/arch/x86/kernel/pci-dma.c
index 1c4d769..75e1cc1 100644
--- a/arch/x86/kernel/pci-dma.c
+++ b/arch/x86/kernel/pci-dma.c
@@ -96,7 +96,8 @@ void __init pci_iommu_alloc(void)
 	}
 }
 void *dma_generic_alloc_coherent(struct device *dev, size_t size,
-				 dma_addr_t *dma_addr, gfp_t flag)
+				 dma_addr_t *dma_addr, gfp_t flag,
+				 struct dma_attrs *attrs)
 {
 	unsigned long dma_mask;
 	struct page *page;
diff --git a/arch/x86/kernel/pci-nommu.c b/arch/x86/kernel/pci-nommu.c
index 3af4af8..f960506 100644
--- a/arch/x86/kernel/pci-nommu.c
+++ b/arch/x86/kernel/pci-nommu.c
@@ -75,7 +75,7 @@ static int nommu_map_sg(struct device *hwdev, struct scatterlist *sg,
 }
 
 static void nommu_free_coherent(struct device *dev, size_t size, void *vaddr,
-				dma_addr_t dma_addr)
+				dma_addr_t dma_addr, struct dma_attrs *attrs)
 {
 	free_pages((unsigned long)vaddr, get_order(size));
 }
@@ -96,8 +96,8 @@ static void nommu_sync_sg_for_device(struct device *dev,
 }
 
 struct dma_map_ops nommu_dma_ops = {
-	.alloc_coherent		= dma_generic_alloc_coherent,
-	.free_coherent		= nommu_free_coherent,
+	.alloc			= dma_generic_alloc_coherent,
+	.free			= nommu_free_coherent,
 	.map_sg			= nommu_map_sg,
 	.map_page		= nommu_map_page,
 	.sync_single_for_device = nommu_sync_single_for_device,
diff --git a/arch/x86/kernel/pci-swiotlb.c b/arch/x86/kernel/pci-swiotlb.c
index 8f972cb..6c483ba 100644
--- a/arch/x86/kernel/pci-swiotlb.c
+++ b/arch/x86/kernel/pci-swiotlb.c
@@ -15,21 +15,30 @@
 int swiotlb __read_mostly;
 
 static void *x86_swiotlb_alloc_coherent(struct device *hwdev, size_t size,
-					dma_addr_t *dma_handle, gfp_t flags)
+					dma_addr_t *dma_handle, gfp_t flags,
+					struct dma_attrs *attrs)
 {
 	void *vaddr;
 
-	vaddr = dma_generic_alloc_coherent(hwdev, size, dma_handle, flags);
+	vaddr = dma_generic_alloc_coherent(hwdev, size, dma_handle, flags,
+					   attrs);
 	if (vaddr)
 		return vaddr;
 
 	return swiotlb_alloc_coherent(hwdev, size, dma_handle, flags);
 }
 
+static void x86_swiotlb_free_coherent(struct device *dev, size_t size,
+				      void *vaddr, dma_addr_t dma_addr,
+				      struct dma_attrs *attrs)
+{
+	swiotlb_free_coherent(dev, size, vaddr, dma_addr);
+}
+
 static struct dma_map_ops swiotlb_dma_ops = {
 	.mapping_error = swiotlb_dma_mapping_error,
-	.alloc_coherent = x86_swiotlb_alloc_coherent,
-	.free_coherent = swiotlb_free_coherent,
+	.alloc = x86_swiotlb_alloc_coherent,
+	.free = x86_swiotlb_free_coherent,
 	.sync_single_for_cpu = swiotlb_sync_single_for_cpu,
 	.sync_single_for_device = swiotlb_sync_single_for_device,
 	.sync_sg_for_cpu = swiotlb_sync_sg_for_cpu,
diff --git a/arch/x86/xen/pci-swiotlb-xen.c b/arch/x86/xen/pci-swiotlb-xen.c
index b480d42..967633a 100644
--- a/arch/x86/xen/pci-swiotlb-xen.c
+++ b/arch/x86/xen/pci-swiotlb-xen.c
@@ -12,8 +12,8 @@ int xen_swiotlb __read_mostly;
 
 static struct dma_map_ops xen_swiotlb_dma_ops = {
 	.mapping_error = xen_swiotlb_dma_mapping_error,
-	.alloc_coherent = xen_swiotlb_alloc_coherent,
-	.free_coherent = xen_swiotlb_free_coherent,
+	.alloc = xen_swiotlb_alloc_coherent,
+	.free = xen_swiotlb_free_coherent,
 	.sync_single_for_cpu = xen_swiotlb_sync_single_for_cpu,
 	.sync_single_for_device = xen_swiotlb_sync_single_for_device,
 	.sync_sg_for_cpu = xen_swiotlb_sync_sg_for_cpu,
diff --git a/drivers/iommu/amd_iommu.c b/drivers/iommu/amd_iommu.c
index f75e060..daa333f 100644
--- a/drivers/iommu/amd_iommu.c
+++ b/drivers/iommu/amd_iommu.c
@@ -2707,7 +2707,8 @@ static void unmap_sg(struct device *dev, struct scatterlist *sglist,
  * The exported alloc_coherent function for dma_ops.
  */
 static void *alloc_coherent(struct device *dev, size_t size,
-			    dma_addr_t *dma_addr, gfp_t flag)
+			    dma_addr_t *dma_addr, gfp_t flag,
+			    struct dma_attrs *attrs)
 {
 	unsigned long flags;
 	void *virt_addr;
@@ -2765,7 +2766,8 @@ out_free:
  * The exported free_coherent function for dma_ops.
  */
 static void free_coherent(struct device *dev, size_t size,
-			  void *virt_addr, dma_addr_t dma_addr)
+			  void *virt_addr, dma_addr_t dma_addr,
+			  struct dma_attrs *attrs)
 {
 	unsigned long flags;
 	struct protection_domain *domain;
@@ -2846,8 +2848,8 @@ static void prealloc_protection_domains(void)
 }
 
 static struct dma_map_ops amd_iommu_dma_ops = {
-	.alloc_coherent = alloc_coherent,
-	.free_coherent = free_coherent,
+	.alloc = alloc_coherent,
+	.free = free_coherent,
 	.map_page = map_page,
 	.unmap_page = unmap_page,
 	.map_sg = map_sg,
diff --git a/drivers/iommu/intel-iommu.c b/drivers/iommu/intel-iommu.c
index c9c6053..e39bfdc 100644
--- a/drivers/iommu/intel-iommu.c
+++ b/drivers/iommu/intel-iommu.c
@@ -2938,7 +2938,8 @@ static void intel_unmap_page(struct device *dev, dma_addr_t dev_addr,
 }
 
 static void *intel_alloc_coherent(struct device *hwdev, size_t size,
-				  dma_addr_t *dma_handle, gfp_t flags)
+				  dma_addr_t *dma_handle, gfp_t flags,
+				  struct dma_attrs *attrs)
 {
 	void *vaddr;
 	int order;
@@ -2970,7 +2971,7 @@ static void *intel_alloc_coherent(struct device *hwdev, size_t size,
 }
 
 static void intel_free_coherent(struct device *hwdev, size_t size, void *vaddr,
-				dma_addr_t dma_handle)
+				dma_addr_t dma_handle, struct dma_attrs *attrs)
 {
 	int order;
 
@@ -3115,8 +3116,8 @@ static int intel_mapping_error(struct device *dev, dma_addr_t dma_addr)
 }
 
 struct dma_map_ops intel_dma_ops = {
-	.alloc_coherent = intel_alloc_coherent,
-	.free_coherent = intel_free_coherent,
+	.alloc = intel_alloc_coherent,
+	.free = intel_free_coherent,
 	.map_sg = intel_map_sg,
 	.unmap_sg = intel_unmap_sg,
 	.map_page = intel_map_page,
diff --git a/drivers/xen/swiotlb-xen.c b/drivers/xen/swiotlb-xen.c
index 19e6a20..1afb4fb 100644
--- a/drivers/xen/swiotlb-xen.c
+++ b/drivers/xen/swiotlb-xen.c
@@ -204,7 +204,8 @@ error:
 
 void *
 xen_swiotlb_alloc_coherent(struct device *hwdev, size_t size,
-			   dma_addr_t *dma_handle, gfp_t flags)
+			   dma_addr_t *dma_handle, gfp_t flags,
+			   struct dma_attrs *attrs)
 {
 	void *ret;
 	int order = get_order(size);
@@ -253,7 +254,7 @@ EXPORT_SYMBOL_GPL(xen_swiotlb_alloc_coherent);
 
 void
 xen_swiotlb_free_coherent(struct device *hwdev, size_t size, void *vaddr,
-			  dma_addr_t dev_addr)
+			  dma_addr_t dev_addr, struct dma_attrs *attrs)
 {
 	int order = get_order(size);
 	phys_addr_t phys;
diff --git a/include/xen/swiotlb-xen.h b/include/xen/swiotlb-xen.h
index 2ea2fdc..4f4d449 100644
--- a/include/xen/swiotlb-xen.h
+++ b/include/xen/swiotlb-xen.h
@@ -7,11 +7,13 @@ extern void xen_swiotlb_init(int verbose);
 
 extern void
 *xen_swiotlb_alloc_coherent(struct device *hwdev, size_t size,
-			    dma_addr_t *dma_handle, gfp_t flags);
+			    dma_addr_t *dma_handle, gfp_t flags,
+			    struct dma_attrs *attrs);
 
 extern void
 xen_swiotlb_free_coherent(struct device *hwdev, size_t size,
-			  void *vaddr, dma_addr_t dma_handle);
+			  void *vaddr, dma_addr_t dma_handle,
+			  struct dma_attrs *attrs);
 
 extern dma_addr_t xen_swiotlb_map_page(struct device *dev, struct page *page,
 				       unsigned long offset, size_t size,
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
