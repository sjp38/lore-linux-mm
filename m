Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4FD786B0024
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 13:04:52 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id j18so6824551pgv.18
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 10:04:52 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d20-v6si12398524plr.206.2018.04.23.10.04.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 23 Apr 2018 10:04:50 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 03/12] iommu-helper: mark iommu_is_span_boundary as inline
Date: Mon, 23 Apr 2018 19:04:10 +0200
Message-Id: <20180423170419.20330-4-hch@lst.de>
In-Reply-To: <20180423170419.20330-1-hch@lst.de>
References: <20180423170419.20330-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, iommu@lists.linux-foundation.org
Cc: x86@kernel.org, linux-block@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-mips@linux-mips.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org

This avoids selecting IOMMU_HELPER just for this function.  And we only
use it once or twice in normal builds so this often even is a size
reduction.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/alpha/Kconfig              |  3 ---
 arch/arm/Kconfig                |  3 ---
 arch/arm64/Kconfig              |  3 ---
 arch/ia64/Kconfig               |  3 ---
 arch/mips/cavium-octeon/Kconfig |  4 ----
 arch/mips/loongson64/Kconfig    |  4 ----
 arch/mips/netlogic/Kconfig      |  3 ---
 arch/powerpc/Kconfig            |  1 -
 arch/unicore32/mm/Kconfig       |  3 ---
 arch/x86/Kconfig                |  2 +-
 drivers/parisc/Kconfig          |  5 -----
 include/linux/iommu-helper.h    | 13 ++++++++++---
 lib/iommu-helper.c              | 12 +-----------
 13 files changed, 12 insertions(+), 47 deletions(-)

diff --git a/arch/alpha/Kconfig b/arch/alpha/Kconfig
index b2022885ced8..3ff735a722af 100644
--- a/arch/alpha/Kconfig
+++ b/arch/alpha/Kconfig
@@ -345,9 +345,6 @@ config PCI_DOMAINS
 config PCI_SYSCALL
 	def_bool PCI
 
-config IOMMU_HELPER
-	def_bool PCI
-
 config ALPHA_NONAME
 	bool
 	depends on ALPHA_BOOK1 || ALPHA_NONAME_CH
diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index a7f8e7f4b88f..2f79222c5c02 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -1781,9 +1781,6 @@ config SECCOMP
 config SWIOTLB
 	def_bool y
 
-config IOMMU_HELPER
-	def_bool SWIOTLB
-
 config PARAVIRT
 	bool "Enable paravirtualization code"
 	help
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index eb2cf4938f6d..fbef5d3de83f 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -252,9 +252,6 @@ config SMP
 config SWIOTLB
 	def_bool y
 
-config IOMMU_HELPER
-	def_bool SWIOTLB
-
 config KERNEL_MODE_NEON
 	def_bool y
 
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index bbe12a038d21..862c5160c09d 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -613,6 +613,3 @@ source "security/Kconfig"
 source "crypto/Kconfig"
 
 source "lib/Kconfig"
-
-config IOMMU_HELPER
-	def_bool (IA64_HP_ZX1 || IA64_HP_ZX1_SWIOTLB || IA64_GENERIC || SWIOTLB)
diff --git a/arch/mips/cavium-octeon/Kconfig b/arch/mips/cavium-octeon/Kconfig
index b5eee1a57d6c..647ed158ac98 100644
--- a/arch/mips/cavium-octeon/Kconfig
+++ b/arch/mips/cavium-octeon/Kconfig
@@ -67,16 +67,12 @@ config CAVIUM_OCTEON_LOCK_L2_MEMCPY
 	help
 	  Lock the kernel's implementation of memcpy() into L2.
 
-config IOMMU_HELPER
-	bool
-
 config NEED_SG_DMA_LENGTH
 	bool
 
 config SWIOTLB
 	def_bool y
 	select DMA_DIRECT_OPS
-	select IOMMU_HELPER
 	select NEED_SG_DMA_LENGTH
 
 config OCTEON_ILM
diff --git a/arch/mips/loongson64/Kconfig b/arch/mips/loongson64/Kconfig
index 72af0c183969..5efb2e63878e 100644
--- a/arch/mips/loongson64/Kconfig
+++ b/arch/mips/loongson64/Kconfig
@@ -130,9 +130,6 @@ config LOONGSON_UART_BASE
 	default y
 	depends on EARLY_PRINTK || SERIAL_8250
 
-config IOMMU_HELPER
-	bool
-
 config NEED_SG_DMA_LENGTH
 	bool
 
@@ -141,7 +138,6 @@ config SWIOTLB
 	default y
 	depends on CPU_LOONGSON3
 	select DMA_DIRECT_OPS
-	select IOMMU_HELPER
 	select NEED_SG_DMA_LENGTH
 	select NEED_DMA_MAP_STATE
 
diff --git a/arch/mips/netlogic/Kconfig b/arch/mips/netlogic/Kconfig
index 7fcfc7fe9f14..5c5ee0e05a17 100644
--- a/arch/mips/netlogic/Kconfig
+++ b/arch/mips/netlogic/Kconfig
@@ -83,9 +83,6 @@ endif
 config NLM_COMMON
 	bool
 
-config IOMMU_HELPER
-	bool
-
 config NEED_SG_DMA_LENGTH
 	bool
 
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index c32a181a7cbb..43e3c8e4e7f4 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -484,7 +484,6 @@ config IOMMU_HELPER
 config SWIOTLB
 	bool "SWIOTLB support"
 	default n
-	select IOMMU_HELPER
 	---help---
 	  Support for IO bounce buffering for systems without an IOMMU.
 	  This allows us to DMA to the full physical address space on
diff --git a/arch/unicore32/mm/Kconfig b/arch/unicore32/mm/Kconfig
index e9154a59d561..3f105e00c432 100644
--- a/arch/unicore32/mm/Kconfig
+++ b/arch/unicore32/mm/Kconfig
@@ -44,9 +44,6 @@ config SWIOTLB
 	def_bool y
 	select DMA_DIRECT_OPS
 
-config IOMMU_HELPER
-	def_bool SWIOTLB
-
 config NEED_SG_DMA_LENGTH
 	def_bool SWIOTLB
 
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 00fcf81f2c56..cb2c7ecc1fea 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -931,7 +931,7 @@ config SWIOTLB
 
 config IOMMU_HELPER
 	def_bool y
-	depends on CALGARY_IOMMU || GART_IOMMU || SWIOTLB || AMD_IOMMU
+	depends on CALGARY_IOMMU || GART_IOMMU
 
 config MAXSMP
 	bool "Enable Maximum number of SMP Processors and NUMA Nodes"
diff --git a/drivers/parisc/Kconfig b/drivers/parisc/Kconfig
index 3a102a84d637..5a48b5606110 100644
--- a/drivers/parisc/Kconfig
+++ b/drivers/parisc/Kconfig
@@ -103,11 +103,6 @@ config IOMMU_SBA
 	depends on PCI_LBA
 	default PCI_LBA
 
-config IOMMU_HELPER
-	bool
-	depends on IOMMU_SBA || IOMMU_CCIO
-	default y
-
 source "drivers/pcmcia/Kconfig"
 
 endmenu
diff --git a/include/linux/iommu-helper.h b/include/linux/iommu-helper.h
index cb9a9248c8c0..70d01edcbf8b 100644
--- a/include/linux/iommu-helper.h
+++ b/include/linux/iommu-helper.h
@@ -2,6 +2,7 @@
 #ifndef _LINUX_IOMMU_HELPER_H
 #define _LINUX_IOMMU_HELPER_H
 
+#include <linux/bug.h>
 #include <linux/kernel.h>
 
 static inline unsigned long iommu_device_max_index(unsigned long size,
@@ -14,9 +15,15 @@ static inline unsigned long iommu_device_max_index(unsigned long size,
 		return size;
 }
 
-extern int iommu_is_span_boundary(unsigned int index, unsigned int nr,
-				  unsigned long shift,
-				  unsigned long boundary_size);
+static inline int iommu_is_span_boundary(unsigned int index, unsigned int nr,
+		unsigned long shift, unsigned long boundary_size)
+{
+	BUG_ON(!is_power_of_2(boundary_size));
+
+	shift = (shift + index) & (boundary_size - 1);
+	return shift + nr > boundary_size;
+}
+
 extern unsigned long iommu_area_alloc(unsigned long *map, unsigned long size,
 				      unsigned long start, unsigned int nr,
 				      unsigned long shift,
diff --git a/lib/iommu-helper.c b/lib/iommu-helper.c
index ded1703e7e64..92a9f243c0e2 100644
--- a/lib/iommu-helper.c
+++ b/lib/iommu-helper.c
@@ -4,17 +4,7 @@
  */
 
 #include <linux/bitmap.h>
-#include <linux/bug.h>
-
-int iommu_is_span_boundary(unsigned int index, unsigned int nr,
-			   unsigned long shift,
-			   unsigned long boundary_size)
-{
-	BUG_ON(!is_power_of_2(boundary_size));
-
-	shift = (shift + index) & (boundary_size - 1);
-	return shift + nr > boundary_size;
-}
+#include <linux/iommu-helper.h>
 
 unsigned long iommu_area_alloc(unsigned long *map, unsigned long size,
 			       unsigned long start, unsigned int nr,
-- 
2.17.0
