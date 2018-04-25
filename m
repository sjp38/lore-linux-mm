Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DD8896B0009
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 01:16:09 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j25so14800559pfh.18
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 22:16:09 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g9si12812810pgo.214.2018.04.24.22.16.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 24 Apr 2018 22:16:08 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 04/13] iommu-helper: move the IOMMU_HELPER config symbol to lib/
Date: Wed, 25 Apr 2018 07:15:30 +0200
Message-Id: <20180425051539.1989-5-hch@lst.de>
In-Reply-To: <20180425051539.1989-1-hch@lst.de>
References: <20180425051539.1989-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, iommu@lists.linux-foundation.org
Cc: sstabellini@kernel.org, x86@kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-mips@linux-mips.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org

This way we have one central definition of it, and user can select it as
needed.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 arch/powerpc/Kconfig | 4 +---
 arch/s390/Kconfig    | 5 ++---
 arch/sparc/Kconfig   | 5 +----
 arch/x86/Kconfig     | 6 ++----
 lib/Kconfig          | 3 +++
 5 files changed, 9 insertions(+), 14 deletions(-)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 43e3c8e4e7f4..7698cf89af9c 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -223,6 +223,7 @@ config PPC
 	select HAVE_SYSCALL_TRACEPOINTS
 	select HAVE_VIRT_CPU_ACCOUNTING
 	select HAVE_IRQ_TIME_ACCOUNTING
+	select IOMMU_HELPER			if PPC64
 	select IRQ_DOMAIN
 	select IRQ_FORCED_THREADING
 	select MODULES_USE_ELF_RELA
@@ -478,9 +479,6 @@ config MPROFILE_KERNEL
 	depends on PPC64 && CPU_LITTLE_ENDIAN
 	def_bool !DISABLE_MPROFILE_KERNEL
 
-config IOMMU_HELPER
-	def_bool PPC64
-
 config SWIOTLB
 	bool "SWIOTLB support"
 	default n
diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index 199ac3e4da1d..60c4ab854182 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -709,7 +709,9 @@ config QDIO
 menuconfig PCI
 	bool "PCI support"
 	select PCI_MSI
+	select IOMMU_HELPER
 	select IOMMU_SUPPORT
+
 	help
 	  Enable PCI support.
 
@@ -733,9 +735,6 @@ config PCI_DOMAINS
 config HAS_IOMEM
 	def_bool PCI
 
-config IOMMU_HELPER
-	def_bool PCI
-
 config NEED_SG_DMA_LENGTH
 	def_bool PCI
 
diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index 8767e45f1b2b..44e0f3cd7988 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -67,6 +67,7 @@ config SPARC64
 	select HAVE_SYSCALL_TRACEPOINTS
 	select HAVE_CONTEXT_TRACKING
 	select HAVE_DEBUG_KMEMLEAK
+	select IOMMU_HELPER
 	select SPARSE_IRQ
 	select RTC_DRV_CMOS
 	select RTC_DRV_BQ4802
@@ -106,10 +107,6 @@ config ARCH_DMA_ADDR_T_64BIT
 	bool
 	default y if ARCH_ATU
 
-config IOMMU_HELPER
-	bool
-	default y if SPARC64
-
 config STACKTRACE_SUPPORT
 	bool
 	default y if SPARC64
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index cb2c7ecc1fea..fe9713539166 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -871,6 +871,7 @@ config DMI
 
 config GART_IOMMU
 	bool "Old AMD GART IOMMU support"
+	select IOMMU_HELPER
 	select SWIOTLB
 	depends on X86_64 && PCI && AMD_NB
 	---help---
@@ -892,6 +893,7 @@ config GART_IOMMU
 
 config CALGARY_IOMMU
 	bool "IBM Calgary IOMMU support"
+	select IOMMU_HELPER
 	select SWIOTLB
 	depends on X86_64 && PCI
 	---help---
@@ -929,10 +931,6 @@ config SWIOTLB
 	  with more than 3 GB of memory.
 	  If unsure, say Y.
 
-config IOMMU_HELPER
-	def_bool y
-	depends on CALGARY_IOMMU || GART_IOMMU
-
 config MAXSMP
 	bool "Enable Maximum number of SMP Processors and NUMA Nodes"
 	depends on X86_64 && SMP && DEBUG_KERNEL
diff --git a/lib/Kconfig b/lib/Kconfig
index 5fe577673b98..2f6908577534 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -429,6 +429,9 @@ config SGL_ALLOC
 	bool
 	default n
 
+config IOMMU_HELPER
+	bool
+
 config DMA_DIRECT_OPS
 	bool
 	depends on HAS_DMA && (!64BIT || ARCH_DMA_ADDR_T_64BIT)
-- 
2.17.0
