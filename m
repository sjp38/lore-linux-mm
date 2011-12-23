Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 9402D6B0070
	for <linux-mm@kvack.org>; Fri, 23 Dec 2011 07:28:03 -0500 (EST)
Received: from euspt2 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LWN007L3PAMRU@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 23 Dec 2011 12:27:59 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LWN009AHPAL85@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 23 Dec 2011 12:27:58 +0000 (GMT)
Date: Fri, 23 Dec 2011 13:27:23 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 04/14] PowerPC: adapt for dma_map_ops changes
In-reply-to: <1324643253-3024-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1324643253-3024-5-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1324643253-3024-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Stephen Rothwell <sfr@canb.auug.org.au>, microblaze-uclinux@itee.uq.edu.au, linux-arch@vger.kernel.org, x86@kernel.org, linux-sh@vger.kernel.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, discuss@x86-64.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Jonathan Corbet <corbet@lwn.net>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>

From: Andrzej Pietrasiewicz <andrzej.p@samsung.com>

Adapt core PowerPC architecture code for dma_map_ops changes: replace
alloc/free_coherent with generic alloc/free methods.

Signed-off-by: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/powerpc/include/asm/dma-mapping.h  |   24 ++++++++++++++++--------
 arch/powerpc/kernel/dma-iommu.c         |   10 ++++++----
 arch/powerpc/kernel/dma-swiotlb.c       |    4 ++--
 arch/powerpc/kernel/dma.c               |   10 ++++++----
 arch/powerpc/kernel/ibmebus.c           |   10 ++++++----
 arch/powerpc/platforms/cell/iommu.c     |   16 +++++++++-------
 arch/powerpc/platforms/ps3/system-bus.c |   13 +++++++------
 7 files changed, 52 insertions(+), 35 deletions(-)

diff --git a/arch/powerpc/include/asm/dma-mapping.h b/arch/powerpc/include/asm/dma-mapping.h
index dd70fac..62678e3 100644
--- a/arch/powerpc/include/asm/dma-mapping.h
+++ b/arch/powerpc/include/asm/dma-mapping.h
@@ -22,9 +22,11 @@
 
 /* Some dma direct funcs must be visible for use in other dma_ops */
 extern void *dma_direct_alloc_coherent(struct device *dev, size_t size,
-				       dma_addr_t *dma_handle, gfp_t flag);
+				       dma_addr_t *dma_handle, gfp_t flag,
+				       struct dma_attrs *attrs);
 extern void dma_direct_free_coherent(struct device *dev, size_t size,
-				     void *vaddr, dma_addr_t dma_handle);
+				     void *vaddr, dma_addr_t dma_handle,
+				     struct dma_attrs *attrs);
 
 
 #ifdef CONFIG_NOT_COHERENT_CACHE
@@ -130,23 +132,29 @@ static inline int dma_supported(struct device *dev, u64 mask)
 
 extern int dma_set_mask(struct device *dev, u64 dma_mask);
 
-static inline void *dma_alloc_coherent(struct device *dev, size_t size,
-				       dma_addr_t *dma_handle, gfp_t flag)
+#define dma_alloc_coherent(d,s,h,f)	dma_alloc_attrs(d,s,h,f,NULL)
+
+static inline void *dma_alloc_attrs(struct device *dev, size_t size,
+				    dma_addr_t *dma_handle, gfp_t flag,
+				    struct dma_attrs *attrs)
 {
 	struct dma_map_ops *dma_ops = get_dma_ops(dev);
 	void *cpu_addr;
 
 	BUG_ON(!dma_ops);
 
-	cpu_addr = dma_ops->alloc_coherent(dev, size, dma_handle, flag);
+	cpu_addr = dma_ops->alloc(dev, size, dma_handle, flag, attrs);
 
 	debug_dma_alloc_coherent(dev, size, *dma_handle, cpu_addr);
 
 	return cpu_addr;
 }
 
-static inline void dma_free_coherent(struct device *dev, size_t size,
-				     void *cpu_addr, dma_addr_t dma_handle)
+#define dma_free_coherent(d,s,c,h) dma_free_attrs(d,s,c,h,NULL)
+
+static inline void dma_free_attrs(struct device *dev, size_t size,
+				  void *cpu_addr, dma_addr_t dma_handle,
+				  struct dma_attrs *attrs)
 {
 	struct dma_map_ops *dma_ops = get_dma_ops(dev);
 
@@ -154,7 +162,7 @@ static inline void dma_free_coherent(struct device *dev, size_t size,
 
 	debug_dma_free_coherent(dev, size, cpu_addr, dma_handle);
 
-	dma_ops->free_coherent(dev, size, cpu_addr, dma_handle);
+	dma_ops->free(dev, size, cpu_addr, dma_handle, attrs);
 }
 
 static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
diff --git a/arch/powerpc/kernel/dma-iommu.c b/arch/powerpc/kernel/dma-iommu.c
index 3f6464b..bcfdcd2 100644
--- a/arch/powerpc/kernel/dma-iommu.c
+++ b/arch/powerpc/kernel/dma-iommu.c
@@ -17,7 +17,8 @@
  * to the dma address (mapping) of the first page.
  */
 static void *dma_iommu_alloc_coherent(struct device *dev, size_t size,
-				      dma_addr_t *dma_handle, gfp_t flag)
+				      dma_addr_t *dma_handle, gfp_t flag,
+				      struct dma_attrs *attrs)
 {
 	return iommu_alloc_coherent(dev, get_iommu_table_base(dev), size,
 				    dma_handle, dev->coherent_dma_mask, flag,
@@ -25,7 +26,8 @@ static void *dma_iommu_alloc_coherent(struct device *dev, size_t size,
 }
 
 static void dma_iommu_free_coherent(struct device *dev, size_t size,
-				    void *vaddr, dma_addr_t dma_handle)
+				    void *vaddr, dma_addr_t dma_handle,
+				    struct dma_attrs *attrs)
 {
 	iommu_free_coherent(get_iommu_table_base(dev), size, vaddr, dma_handle);
 }
@@ -105,8 +107,8 @@ static u64 dma_iommu_get_required_mask(struct device *dev)
 }
 
 struct dma_map_ops dma_iommu_ops = {
-	.alloc_coherent		= dma_iommu_alloc_coherent,
-	.free_coherent		= dma_iommu_free_coherent,
+	.alloc			= dma_iommu_alloc_coherent,
+	.free			= dma_iommu_free_coherent,
 	.map_sg			= dma_iommu_map_sg,
 	.unmap_sg		= dma_iommu_unmap_sg,
 	.dma_supported		= dma_iommu_dma_supported,
diff --git a/arch/powerpc/kernel/dma-swiotlb.c b/arch/powerpc/kernel/dma-swiotlb.c
index 1ebc918..4ab88da 100644
--- a/arch/powerpc/kernel/dma-swiotlb.c
+++ b/arch/powerpc/kernel/dma-swiotlb.c
@@ -47,8 +47,8 @@ static u64 swiotlb_powerpc_get_required(struct device *dev)
  * for everything else.
  */
 struct dma_map_ops swiotlb_dma_ops = {
-	.alloc_coherent = dma_direct_alloc_coherent,
-	.free_coherent = dma_direct_free_coherent,
+	.alloc = dma_direct_alloc_coherent,
+	.free = dma_direct_free_coherent,
 	.map_sg = swiotlb_map_sg_attrs,
 	.unmap_sg = swiotlb_unmap_sg_attrs,
 	.dma_supported = swiotlb_dma_supported,
diff --git a/arch/powerpc/kernel/dma.c b/arch/powerpc/kernel/dma.c
index 7d0233c..b1ec983 100644
--- a/arch/powerpc/kernel/dma.c
+++ b/arch/powerpc/kernel/dma.c
@@ -26,7 +26,8 @@
 
 
 void *dma_direct_alloc_coherent(struct device *dev, size_t size,
-				dma_addr_t *dma_handle, gfp_t flag)
+				dma_addr_t *dma_handle, gfp_t flag,
+				struct dma_attrs *attrs)
 {
 	void *ret;
 #ifdef CONFIG_NOT_COHERENT_CACHE
@@ -54,7 +55,8 @@ void *dma_direct_alloc_coherent(struct device *dev, size_t size,
 }
 
 void dma_direct_free_coherent(struct device *dev, size_t size,
-			      void *vaddr, dma_addr_t dma_handle)
+			      void *vaddr, dma_addr_t dma_handle,
+			      struct dma_attrs *attrs)
 {
 #ifdef CONFIG_NOT_COHERENT_CACHE
 	__dma_free_coherent(size, vaddr);
@@ -150,8 +152,8 @@ static inline void dma_direct_sync_single(struct device *dev,
 #endif
 
 struct dma_map_ops dma_direct_ops = {
-	.alloc_coherent			= dma_direct_alloc_coherent,
-	.free_coherent			= dma_direct_free_coherent,
+	.alloc				= dma_direct_alloc_coherent,
+	.free				= dma_direct_free_coherent,
 	.map_sg				= dma_direct_map_sg,
 	.unmap_sg			= dma_direct_unmap_sg,
 	.dma_supported			= dma_direct_dma_supported,
diff --git a/arch/powerpc/kernel/ibmebus.c b/arch/powerpc/kernel/ibmebus.c
index d39ae60..716d918 100644
--- a/arch/powerpc/kernel/ibmebus.c
+++ b/arch/powerpc/kernel/ibmebus.c
@@ -65,7 +65,8 @@ static struct of_device_id __initdata ibmebus_matches[] = {
 static void *ibmebus_alloc_coherent(struct device *dev,
 				    size_t size,
 				    dma_addr_t *dma_handle,
-				    gfp_t flag)
+				    gfp_t flag,
+				    struct dma_attrs *attrs)
 {
 	void *mem;
 
@@ -77,7 +78,8 @@ static void *ibmebus_alloc_coherent(struct device *dev,
 
 static void ibmebus_free_coherent(struct device *dev,
 				  size_t size, void *vaddr,
-				  dma_addr_t dma_handle)
+				  dma_addr_t dma_handle,
+				  struct dma_attrs *attrs)
 {
 	kfree(vaddr);
 }
@@ -136,8 +138,8 @@ static u64 ibmebus_dma_get_required_mask(struct device *dev)
 }
 
 static struct dma_map_ops ibmebus_dma_ops = {
-	.alloc_coherent     = ibmebus_alloc_coherent,
-	.free_coherent      = ibmebus_free_coherent,
+	.alloc              = ibmebus_alloc_coherent,
+	.free               = ibmebus_free_coherent,
 	.map_sg             = ibmebus_map_sg,
 	.unmap_sg           = ibmebus_unmap_sg,
 	.dma_supported      = ibmebus_dma_supported,
diff --git a/arch/powerpc/platforms/cell/iommu.c b/arch/powerpc/platforms/cell/iommu.c
index 592c3d5..471c955 100644
--- a/arch/powerpc/platforms/cell/iommu.c
+++ b/arch/powerpc/platforms/cell/iommu.c
@@ -564,7 +564,8 @@ static struct iommu_table *cell_get_iommu_table(struct device *dev)
 /* A coherent allocation implies strong ordering */
 
 static void *dma_fixed_alloc_coherent(struct device *dev, size_t size,
-				      dma_addr_t *dma_handle, gfp_t flag)
+				      dma_addr_t *dma_handle, gfp_t flag,
+				      struct dma_attrs *attrs)
 {
 	if (iommu_fixed_is_weak)
 		return iommu_alloc_coherent(dev, cell_get_iommu_table(dev),
@@ -572,18 +573,19 @@ static void *dma_fixed_alloc_coherent(struct device *dev, size_t size,
 					    device_to_mask(dev), flag,
 					    dev_to_node(dev));
 	else
-		return dma_direct_ops.alloc_coherent(dev, size, dma_handle,
-						     flag);
+		return dma_direct_ops.alloc(dev, size, dma_handle, flag,
+					    attrs);
 }
 
 static void dma_fixed_free_coherent(struct device *dev, size_t size,
-				    void *vaddr, dma_addr_t dma_handle)
+				    void *vaddr, dma_addr_t dma_handle,
+				    struct dma_attrs *attrs)
 {
 	if (iommu_fixed_is_weak)
 		iommu_free_coherent(cell_get_iommu_table(dev), size, vaddr,
 				    dma_handle);
 	else
-		dma_direct_ops.free_coherent(dev, size, vaddr, dma_handle);
+		dma_direct_ops.free(dev, size, vaddr, dma_handle, attrs);
 }
 
 static dma_addr_t dma_fixed_map_page(struct device *dev, struct page *page,
@@ -642,8 +644,8 @@ static int dma_fixed_dma_supported(struct device *dev, u64 mask)
 static int dma_set_mask_and_switch(struct device *dev, u64 dma_mask);
 
 struct dma_map_ops dma_iommu_fixed_ops = {
-	.alloc_coherent = dma_fixed_alloc_coherent,
-	.free_coherent  = dma_fixed_free_coherent,
+	.alloc          = dma_fixed_alloc_coherent,
+	.free           = dma_fixed_free_coherent,
 	.map_sg         = dma_fixed_map_sg,
 	.unmap_sg       = dma_fixed_unmap_sg,
 	.dma_supported  = dma_fixed_dma_supported,
diff --git a/arch/powerpc/platforms/ps3/system-bus.c b/arch/powerpc/platforms/ps3/system-bus.c
index 880eb9c..5606fe3 100644
--- a/arch/powerpc/platforms/ps3/system-bus.c
+++ b/arch/powerpc/platforms/ps3/system-bus.c
@@ -515,7 +515,8 @@ core_initcall(ps3_system_bus_init);
  * to the dma address (mapping) of the first page.
  */
 static void * ps3_alloc_coherent(struct device *_dev, size_t size,
-				      dma_addr_t *dma_handle, gfp_t flag)
+				 dma_addr_t *dma_handle, gfp_t flag,
+				 struct dma_attrs *attrs)
 {
 	int result;
 	struct ps3_system_bus_device *dev = ps3_dev_to_system_bus_dev(_dev);
@@ -552,7 +553,7 @@ clean_none:
 }
 
 static void ps3_free_coherent(struct device *_dev, size_t size, void *vaddr,
-	dma_addr_t dma_handle)
+			      dma_addr_t dma_handle, struct dma_attrs *attrs)
 {
 	struct ps3_system_bus_device *dev = ps3_dev_to_system_bus_dev(_dev);
 
@@ -701,8 +702,8 @@ static u64 ps3_dma_get_required_mask(struct device *_dev)
 }
 
 static struct dma_map_ops ps3_sb_dma_ops = {
-	.alloc_coherent = ps3_alloc_coherent,
-	.free_coherent = ps3_free_coherent,
+	.alloc = ps3_alloc_coherent,
+	.free = ps3_free_coherent,
 	.map_sg = ps3_sb_map_sg,
 	.unmap_sg = ps3_sb_unmap_sg,
 	.dma_supported = ps3_dma_supported,
@@ -712,8 +713,8 @@ static struct dma_map_ops ps3_sb_dma_ops = {
 };
 
 static struct dma_map_ops ps3_ioc0_dma_ops = {
-	.alloc_coherent = ps3_alloc_coherent,
-	.free_coherent = ps3_free_coherent,
+	.alloc = ps3_alloc_coherent,
+	.free = ps3_free_coherent,
 	.map_sg = ps3_ioc0_map_sg,
 	.unmap_sg = ps3_ioc0_unmap_sg,
 	.dma_supported = ps3_dma_supported,
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
