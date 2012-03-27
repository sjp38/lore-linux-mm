Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 16FEB6B00F5
	for <linux-mm@kvack.org>; Tue, 27 Mar 2012 09:43:32 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt2 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M1J00EXKQ42PD60@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 27 Mar 2012 14:43:15 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M1J0022UQ491V@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 27 Mar 2012 14:43:22 +0100 (BST)
Date: Tue, 27 Mar 2012 15:42:39 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv2 05/14] SPARC: adapt for dma_map_ops changes
In-reply-to: <1332855768-32583-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1332855768-32583-6-git-send-email-m.szyprowski@samsung.com>
References: <1332855768-32583-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Stephen Rothwell <sfr@canb.auug.org.au>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, microblaze-uclinux@itee.uq.edu.au, linux-arch@vger.kernel.org, x86@kernel.org, linux-sh@vger.kernel.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, discuss@x86-64.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Jonathan Corbet <corbet@lwn.net>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Kevin Cernekee <cernekee@gmail.com>, Dezhong Diao <dediao@cisco.com>, Richard Kuo <rkuo@codeaurora.org>, "David S. Miller" <davem@davemloft.net>, Michal Simek <monstr@monstr.eu>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Paul Mundt <lethal@linux-sh.org>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

From: Andrzej Pietrasiewicz <andrzej.p@samsung.com>

Adapt core SPARC architecture code for dma_map_ops changes: replace
alloc/free_coherent with generic alloc/free methods.

Signed-off-by: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
Acked-by: Kyungmin Park <kyungmin.park@samsung.com>
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Reviewed-by: Arnd Bergmann <arnd@arndb.de>
Acked-by: David S. Miller <davem@davemloft.net>
---
 arch/sparc/include/asm/dma-mapping.h |   18 ++++++++++++------
 arch/sparc/kernel/iommu.c            |   10 ++++++----
 arch/sparc/kernel/ioport.c           |   18 ++++++++++--------
 arch/sparc/kernel/pci_sun4v.c        |    9 +++++----
 4 files changed, 33 insertions(+), 22 deletions(-)

diff --git a/arch/sparc/include/asm/dma-mapping.h b/arch/sparc/include/asm/dma-mapping.h
index 8c0e4f7..48a7c65 100644
--- a/arch/sparc/include/asm/dma-mapping.h
+++ b/arch/sparc/include/asm/dma-mapping.h
@@ -26,24 +26,30 @@ static inline struct dma_map_ops *get_dma_ops(struct device *dev)
 
 #include <asm-generic/dma-mapping-common.h>
 
-static inline void *dma_alloc_coherent(struct device *dev, size_t size,
-				       dma_addr_t *dma_handle, gfp_t flag)
+#define dma_alloc_coherent(d,s,h,f)	dma_alloc_attrs(d,s,h,f,NULL)
+
+static inline void *dma_alloc_attrs(struct device *dev, size_t size,
+				    dma_addr_t *dma_handle, gfp_t flag,
+				    struct dma_attrs *attrs)
 {
 	struct dma_map_ops *ops = get_dma_ops(dev);
 	void *cpu_addr;
 
-	cpu_addr = ops->alloc_coherent(dev, size, dma_handle, flag);
+	cpu_addr = ops->alloc(dev, size, dma_handle, flag, attrs);
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
 	struct dma_map_ops *ops = get_dma_ops(dev);
 
 	debug_dma_free_coherent(dev, size, cpu_addr, dma_handle);
-	ops->free_coherent(dev, size, cpu_addr, dma_handle);
+	ops->free(dev, size, cpu_addr, dma_handle, attrs);
 }
 
 static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
diff --git a/arch/sparc/kernel/iommu.c b/arch/sparc/kernel/iommu.c
index 4643d68..070ed14 100644
--- a/arch/sparc/kernel/iommu.c
+++ b/arch/sparc/kernel/iommu.c
@@ -280,7 +280,8 @@ static inline void iommu_free_ctx(struct iommu *iommu, int ctx)
 }
 
 static void *dma_4u_alloc_coherent(struct device *dev, size_t size,
-				   dma_addr_t *dma_addrp, gfp_t gfp)
+				   dma_addr_t *dma_addrp, gfp_t gfp,
+				   struct dma_attrs *attrs)
 {
 	unsigned long flags, order, first_page;
 	struct iommu *iommu;
@@ -330,7 +331,8 @@ static void *dma_4u_alloc_coherent(struct device *dev, size_t size,
 }
 
 static void dma_4u_free_coherent(struct device *dev, size_t size,
-				 void *cpu, dma_addr_t dvma)
+				 void *cpu, dma_addr_t dvma,
+				 struct dma_attrs *attrs)
 {
 	struct iommu *iommu;
 	unsigned long flags, order, npages;
@@ -825,8 +827,8 @@ static void dma_4u_sync_sg_for_cpu(struct device *dev,
 }
 
 static struct dma_map_ops sun4u_dma_ops = {
-	.alloc_coherent		= dma_4u_alloc_coherent,
-	.free_coherent		= dma_4u_free_coherent,
+	.alloc			= dma_4u_alloc_coherent,
+	.free			= dma_4u_free_coherent,
 	.map_page		= dma_4u_map_page,
 	.unmap_page		= dma_4u_unmap_page,
 	.map_sg			= dma_4u_map_sg,
diff --git a/arch/sparc/kernel/ioport.c b/arch/sparc/kernel/ioport.c
index d0479e2..21bd739 100644
--- a/arch/sparc/kernel/ioport.c
+++ b/arch/sparc/kernel/ioport.c
@@ -261,7 +261,8 @@ EXPORT_SYMBOL(sbus_set_sbus64);
  * CPU may access them without any explicit flushing.
  */
 static void *sbus_alloc_coherent(struct device *dev, size_t len,
-				 dma_addr_t *dma_addrp, gfp_t gfp)
+				 dma_addr_t *dma_addrp, gfp_t gfp,
+				 struct dma_attrs *attrs)
 {
 	struct platform_device *op = to_platform_device(dev);
 	unsigned long len_total = PAGE_ALIGN(len);
@@ -315,7 +316,7 @@ err_nopages:
 }
 
 static void sbus_free_coherent(struct device *dev, size_t n, void *p,
-			       dma_addr_t ba)
+			       dma_addr_t ba, struct dma_attrs *attrs)
 {
 	struct resource *res;
 	struct page *pgv;
@@ -407,8 +408,8 @@ static void sbus_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
 }
 
 struct dma_map_ops sbus_dma_ops = {
-	.alloc_coherent		= sbus_alloc_coherent,
-	.free_coherent		= sbus_free_coherent,
+	.alloc			= sbus_alloc_coherent,
+	.free			= sbus_free_coherent,
 	.map_page		= sbus_map_page,
 	.unmap_page		= sbus_unmap_page,
 	.map_sg			= sbus_map_sg,
@@ -436,7 +437,8 @@ arch_initcall(sparc_register_ioport);
  * hwdev should be valid struct pci_dev pointer for PCI devices.
  */
 static void *pci32_alloc_coherent(struct device *dev, size_t len,
-				  dma_addr_t *pba, gfp_t gfp)
+				  dma_addr_t *pba, gfp_t gfp,
+				  struct dma_attrs *attrs)
 {
 	unsigned long len_total = PAGE_ALIGN(len);
 	void *va;
@@ -489,7 +491,7 @@ err_nopages:
  * past this call are illegal.
  */
 static void pci32_free_coherent(struct device *dev, size_t n, void *p,
-				dma_addr_t ba)
+				dma_addr_t ba, struct dma_attrs *attrs)
 {
 	struct resource *res;
 
@@ -645,8 +647,8 @@ static void pci32_sync_sg_for_device(struct device *device, struct scatterlist *
 }
 
 struct dma_map_ops pci32_dma_ops = {
-	.alloc_coherent		= pci32_alloc_coherent,
-	.free_coherent		= pci32_free_coherent,
+	.alloc			= pci32_alloc_coherent,
+	.free			= pci32_free_coherent,
 	.map_page		= pci32_map_page,
 	.unmap_page		= pci32_unmap_page,
 	.map_sg			= pci32_map_sg,
diff --git a/arch/sparc/kernel/pci_sun4v.c b/arch/sparc/kernel/pci_sun4v.c
index af5755d..7661e84 100644
--- a/arch/sparc/kernel/pci_sun4v.c
+++ b/arch/sparc/kernel/pci_sun4v.c
@@ -128,7 +128,8 @@ static inline long iommu_batch_end(void)
 }
 
 static void *dma_4v_alloc_coherent(struct device *dev, size_t size,
-				   dma_addr_t *dma_addrp, gfp_t gfp)
+				   dma_addr_t *dma_addrp, gfp_t gfp,
+				   struct dma_attrs *attrs)
 {
 	unsigned long flags, order, first_page, npages, n;
 	struct iommu *iommu;
@@ -198,7 +199,7 @@ range_alloc_fail:
 }
 
 static void dma_4v_free_coherent(struct device *dev, size_t size, void *cpu,
-				 dma_addr_t dvma)
+				 dma_addr_t dvma, struct dma_attrs *attrs)
 {
 	struct pci_pbm_info *pbm;
 	struct iommu *iommu;
@@ -527,8 +528,8 @@ static void dma_4v_unmap_sg(struct device *dev, struct scatterlist *sglist,
 }
 
 static struct dma_map_ops sun4v_dma_ops = {
-	.alloc_coherent			= dma_4v_alloc_coherent,
-	.free_coherent			= dma_4v_free_coherent,
+	.alloc				= dma_4v_alloc_coherent,
+	.free				= dma_4v_free_coherent,
 	.map_page			= dma_4v_map_page,
 	.unmap_page			= dma_4v_unmap_page,
 	.map_sg				= dma_4v_map_sg,
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
