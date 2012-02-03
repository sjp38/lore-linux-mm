Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id BB1506B13F7
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 07:19:14 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LYT0046CGVRV450@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 03 Feb 2012 12:19:04 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LYT009NGGVRVF@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 03 Feb 2012 12:19:03 +0000 (GMT)
Date: Fri, 03 Feb 2012 13:18:56 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 13/15] X86: integrate CMA with DMA-mapping subsystem
In-reply-to: <1328271538-14502-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1328271538-14502-14-git-send-email-m.szyprowski@samsung.com>
References: <1328271538-14502-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, Rob Clark <rob.clark@linaro.org>, Ohad Ben-Cohen <ohad@wizery.com>

This patch adds support for CMA to dma-mapping subsystem for x86
architecture that uses common pci-dma/pci-nommu implementation. This
allows to test CMA on KVM/QEMU and a lot of common x86 boxes.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
CC: Michal Nazarewicz <mina86@mina86.com>
Acked-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/x86/Kconfig                      |    1 +
 arch/x86/include/asm/dma-contiguous.h |   13 +++++++++++++
 arch/x86/include/asm/dma-mapping.h    |    4 ++++
 arch/x86/kernel/pci-dma.c             |   18 ++++++++++++++++--
 arch/x86/kernel/pci-nommu.c           |    8 +-------
 arch/x86/kernel/setup.c               |    2 ++
 6 files changed, 37 insertions(+), 9 deletions(-)
 create mode 100644 arch/x86/include/asm/dma-contiguous.h

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 5bed94e..de6e069 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -31,6 +31,7 @@ config X86
 	select ARCH_WANT_OPTIONAL_GPIOLIB
 	select ARCH_WANT_FRAME_POINTERS
 	select HAVE_DMA_ATTRS
+	select HAVE_DMA_CONTIGUOUS if !SWIOTLB
 	select HAVE_KRETPROBES
 	select HAVE_OPTPROBES
 	select HAVE_FTRACE_MCOUNT_RECORD
diff --git a/arch/x86/include/asm/dma-contiguous.h b/arch/x86/include/asm/dma-contiguous.h
new file mode 100644
index 0000000..8fb117d
--- /dev/null
+++ b/arch/x86/include/asm/dma-contiguous.h
@@ -0,0 +1,13 @@
+#ifndef ASMX86_DMA_CONTIGUOUS_H
+#define ASMX86_DMA_CONTIGUOUS_H
+
+#ifdef __KERNEL__
+
+#include <linux/device.h>
+#include <linux/dma-contiguous.h>
+#include <asm-generic/dma-contiguous.h>
+
+static inline void dma_contiguous_early_fixup(phys_addr_t base, unsigned long size) { }
+
+#endif
+#endif
diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
index ed3065f..90ac6f0 100644
--- a/arch/x86/include/asm/dma-mapping.h
+++ b/arch/x86/include/asm/dma-mapping.h
@@ -13,6 +13,7 @@
 #include <asm/io.h>
 #include <asm/swiotlb.h>
 #include <asm-generic/dma-coherent.h>
+#include <linux/dma-contiguous.h>
 
 #ifdef CONFIG_ISA
 # define ISA_DMA_BIT_MASK DMA_BIT_MASK(24)
@@ -61,6 +62,9 @@ extern int dma_set_mask(struct device *dev, u64 mask);
 extern void *dma_generic_alloc_coherent(struct device *dev, size_t size,
 					dma_addr_t *dma_addr, gfp_t flag);
 
+extern void dma_generic_free_coherent(struct device *dev, size_t size,
+				      void *vaddr, dma_addr_t dma_addr);
+
 static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 {
 	if (!dev->dma_mask)
diff --git a/arch/x86/kernel/pci-dma.c b/arch/x86/kernel/pci-dma.c
index 1c4d769..d3c3723 100644
--- a/arch/x86/kernel/pci-dma.c
+++ b/arch/x86/kernel/pci-dma.c
@@ -99,14 +99,18 @@ void *dma_generic_alloc_coherent(struct device *dev, size_t size,
 				 dma_addr_t *dma_addr, gfp_t flag)
 {
 	unsigned long dma_mask;
-	struct page *page;
+	struct page *page = NULL;
+	unsigned int count = PAGE_ALIGN(size) >> PAGE_SHIFT;
 	dma_addr_t addr;
 
 	dma_mask = dma_alloc_coherent_mask(dev, flag);
 
 	flag |= __GFP_ZERO;
 again:
-	page = alloc_pages_node(dev_to_node(dev), flag, get_order(size));
+	if (!(flag & GFP_ATOMIC))
+		page = dma_alloc_from_contiguous(dev, count, get_order(size));
+	if (!page)
+		page = alloc_pages_node(dev_to_node(dev), flag, get_order(size));
 	if (!page)
 		return NULL;
 
@@ -126,6 +130,16 @@ again:
 	return page_address(page);
 }
 
+void dma_generic_free_coherent(struct device *dev, size_t size, void *vaddr,
+			       dma_addr_t dma_addr)
+{
+	unsigned int count = PAGE_ALIGN(size) >> PAGE_SHIFT;
+	struct page *page = virt_to_page(vaddr);
+
+	if (!dma_release_from_contiguous(dev, page, count))
+		free_pages((unsigned long)vaddr, get_order(size));
+}
+
 /*
  * See <Documentation/x86/x86_64/boot-options.txt> for the iommu kernel
  * parameter documentation.
diff --git a/arch/x86/kernel/pci-nommu.c b/arch/x86/kernel/pci-nommu.c
index 3af4af8..656566f 100644
--- a/arch/x86/kernel/pci-nommu.c
+++ b/arch/x86/kernel/pci-nommu.c
@@ -74,12 +74,6 @@ static int nommu_map_sg(struct device *hwdev, struct scatterlist *sg,
 	return nents;
 }
 
-static void nommu_free_coherent(struct device *dev, size_t size, void *vaddr,
-				dma_addr_t dma_addr)
-{
-	free_pages((unsigned long)vaddr, get_order(size));
-}
-
 static void nommu_sync_single_for_device(struct device *dev,
 			dma_addr_t addr, size_t size,
 			enum dma_data_direction dir)
@@ -97,7 +91,7 @@ static void nommu_sync_sg_for_device(struct device *dev,
 
 struct dma_map_ops nommu_dma_ops = {
 	.alloc_coherent		= dma_generic_alloc_coherent,
-	.free_coherent		= nommu_free_coherent,
+	.free_coherent		= dma_generic_free_coherent,
 	.map_sg			= nommu_map_sg,
 	.map_page		= nommu_map_page,
 	.sync_single_for_device = nommu_sync_single_for_device,
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index d7d5099..be6795f 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -50,6 +50,7 @@
 #include <asm/pci-direct.h>
 #include <linux/init_ohci1394_dma.h>
 #include <linux/kvm_para.h>
+#include <linux/dma-contiguous.h>
 
 #include <linux/errno.h>
 #include <linux/kernel.h>
@@ -938,6 +939,7 @@ void __init setup_arch(char **cmdline_p)
 	}
 #endif
 	memblock.current_limit = get_max_mapped();
+	dma_contiguous_reserve(0);
 
 	/*
 	 * NOTE: On x86-32, only from this point on, fixmaps are ready for use.
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
