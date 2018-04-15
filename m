Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 152326B000A
	for <linux-mm@kvack.org>; Sun, 15 Apr 2018 11:00:01 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id j6so227948pgn.7
        for <linux-mm@kvack.org>; Sun, 15 Apr 2018 08:00:01 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h12-v6si9649149pls.305.2018.04.15.07.59.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 15 Apr 2018 07:59:59 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 01/12] iommu-common: move to arch/sparc
Date: Sun, 15 Apr 2018 16:59:36 +0200
Message-Id: <20180415145947.1248-2-hch@lst.de>
In-Reply-To: <20180415145947.1248-1-hch@lst.de>
References: <20180415145947.1248-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, iommu@lists.linux-foundation.org
Cc: x86@kernel.org, linux-block@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-ide@vger.kernel.org, linux-mips@linux-mips.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org

This code is only used by sparc, and all new iommu drivers should use the
drivers/iommu/ framework.  Also remove the unused exports.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 {include/linux => arch/sparc/include/asm}/iommu-common.h | 0
 arch/sparc/include/asm/iommu_64.h                        | 2 +-
 arch/sparc/kernel/Makefile                               | 2 +-
 {lib => arch/sparc/kernel}/iommu-common.c                | 5 +----
 arch/sparc/kernel/iommu.c                                | 2 +-
 arch/sparc/kernel/ldc.c                                  | 2 +-
 arch/sparc/kernel/pci_sun4v.c                            | 2 +-
 lib/Makefile                                             | 2 +-
 8 files changed, 7 insertions(+), 10 deletions(-)
 rename {include/linux => arch/sparc/include/asm}/iommu-common.h (100%)
 rename {lib => arch/sparc/kernel}/iommu-common.c (98%)

diff --git a/include/linux/iommu-common.h b/arch/sparc/include/asm/iommu-common.h
similarity index 100%
rename from include/linux/iommu-common.h
rename to arch/sparc/include/asm/iommu-common.h
diff --git a/arch/sparc/include/asm/iommu_64.h b/arch/sparc/include/asm/iommu_64.h
index 9ed6b54caa4b..0ef6dedf747e 100644
--- a/arch/sparc/include/asm/iommu_64.h
+++ b/arch/sparc/include/asm/iommu_64.h
@@ -17,7 +17,7 @@
 #define IOPTE_WRITE   0x0000000000000002UL
 
 #define IOMMU_NUM_CTXS	4096
-#include <linux/iommu-common.h>
+#include <asm/iommu-common.h>
 
 struct iommu_arena {
 	unsigned long	*map;
diff --git a/arch/sparc/kernel/Makefile b/arch/sparc/kernel/Makefile
index 76cb57750dda..a284662b0e4c 100644
--- a/arch/sparc/kernel/Makefile
+++ b/arch/sparc/kernel/Makefile
@@ -59,7 +59,7 @@ obj-$(CONFIG_SPARC32)   += leon_pmc.o
 
 obj-$(CONFIG_SPARC64)   += reboot.o
 obj-$(CONFIG_SPARC64)   += sysfs.o
-obj-$(CONFIG_SPARC64)   += iommu.o
+obj-$(CONFIG_SPARC64)   += iommu.o iommu-common.o
 obj-$(CONFIG_SPARC64)   += central.o
 obj-$(CONFIG_SPARC64)   += starfire.o
 obj-$(CONFIG_SPARC64)   += power.o
diff --git a/lib/iommu-common.c b/arch/sparc/kernel/iommu-common.c
similarity index 98%
rename from lib/iommu-common.c
rename to arch/sparc/kernel/iommu-common.c
index 55b00de106b5..59cb16691322 100644
--- a/lib/iommu-common.c
+++ b/arch/sparc/kernel/iommu-common.c
@@ -8,9 +8,9 @@
 #include <linux/bitmap.h>
 #include <linux/bug.h>
 #include <linux/iommu-helper.h>
-#include <linux/iommu-common.h>
 #include <linux/dma-mapping.h>
 #include <linux/hash.h>
+#include <asm/iommu-common.h>
 
 static unsigned long iommu_large_alloc = 15;
 
@@ -93,7 +93,6 @@ void iommu_tbl_pool_init(struct iommu_map_table *iommu,
 	p->hint = p->start;
 	p->end = num_entries;
 }
-EXPORT_SYMBOL(iommu_tbl_pool_init);
 
 unsigned long iommu_tbl_range_alloc(struct device *dev,
 				struct iommu_map_table *iommu,
@@ -224,7 +223,6 @@ unsigned long iommu_tbl_range_alloc(struct device *dev,
 
 	return n;
 }
-EXPORT_SYMBOL(iommu_tbl_range_alloc);
 
 static struct iommu_pool *get_pool(struct iommu_map_table *tbl,
 				   unsigned long entry)
@@ -264,4 +262,3 @@ void iommu_tbl_range_free(struct iommu_map_table *iommu, u64 dma_addr,
 	bitmap_clear(iommu->map, entry, npages);
 	spin_unlock_irqrestore(&(pool->lock), flags);
 }
-EXPORT_SYMBOL(iommu_tbl_range_free);
diff --git a/arch/sparc/kernel/iommu.c b/arch/sparc/kernel/iommu.c
index b08dc3416f06..40d008b0bd3e 100644
--- a/arch/sparc/kernel/iommu.c
+++ b/arch/sparc/kernel/iommu.c
@@ -14,7 +14,7 @@
 #include <linux/errno.h>
 #include <linux/iommu-helper.h>
 #include <linux/bitmap.h>
-#include <linux/iommu-common.h>
+#include <asm/iommu-common.h>
 
 #ifdef CONFIG_PCI
 #include <linux/pci.h>
diff --git a/arch/sparc/kernel/ldc.c b/arch/sparc/kernel/ldc.c
index 86b625f9d8dc..c0fa3ef6cf01 100644
--- a/arch/sparc/kernel/ldc.c
+++ b/arch/sparc/kernel/ldc.c
@@ -16,7 +16,7 @@
 #include <linux/list.h>
 #include <linux/init.h>
 #include <linux/bitmap.h>
-#include <linux/iommu-common.h>
+#include <asm/iommu-common.h>
 
 #include <asm/hypervisor.h>
 #include <asm/iommu.h>
diff --git a/arch/sparc/kernel/pci_sun4v.c b/arch/sparc/kernel/pci_sun4v.c
index 249367228c33..565d9ac883d0 100644
--- a/arch/sparc/kernel/pci_sun4v.c
+++ b/arch/sparc/kernel/pci_sun4v.c
@@ -16,7 +16,7 @@
 #include <linux/export.h>
 #include <linux/log2.h>
 #include <linux/of_device.h>
-#include <linux/iommu-common.h>
+#include <asm/iommu-common.h>
 
 #include <asm/iommu.h>
 #include <asm/irq.h>
diff --git a/lib/Makefile b/lib/Makefile
index ce20696d5a92..94203b5eecd4 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -147,7 +147,7 @@ obj-$(CONFIG_AUDIT_GENERIC) += audit.o
 obj-$(CONFIG_AUDIT_COMPAT_GENERIC) += compat_audit.o
 
 obj-$(CONFIG_SWIOTLB) += swiotlb.o
-obj-$(CONFIG_IOMMU_HELPER) += iommu-helper.o iommu-common.o
+obj-$(CONFIG_IOMMU_HELPER) += iommu-helper.o
 obj-$(CONFIG_FAULT_INJECTION) += fault-inject.o
 obj-$(CONFIG_NOTIFIER_ERROR_INJECTION) += notifier-error-inject.o
 obj-$(CONFIG_PM_NOTIFIER_ERROR_INJECT) += pm-notifier-error-inject.o
-- 
2.17.0
