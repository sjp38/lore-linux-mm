Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5823F6B06A2
	for <linux-mm@kvack.org>; Fri, 11 May 2018 15:09:13 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id j75-v6so3497615oib.5
        for <linux-mm@kvack.org>; Fri, 11 May 2018 12:09:13 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w90-v6si1338351ota.147.2018.05.11.12.09.12
        for <linux-mm@kvack.org>;
        Fri, 11 May 2018 12:09:12 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: [PATCH v2 18/40] iommu/io-pgtable-arm: Factor out ARM LPAE register defines
Date: Fri, 11 May 2018 20:06:19 +0100
Message-Id: <20180511190641.23008-19-jean-philippe.brucker@arm.com>
In-Reply-To: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com

For SVA, we'll need to extract CPU page table information and mirror it in
the substream setup. Move relevant defines to a common header.

Fix TCR_SZ_MASK while we're at it.

Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
---
 MAINTAINERS                    |  3 +-
 drivers/iommu/io-pgtable-arm.c | 49 +-----------------------------
 drivers/iommu/io-pgtable-arm.h | 54 ++++++++++++++++++++++++++++++++++
 3 files changed, 56 insertions(+), 50 deletions(-)
 create mode 100644 drivers/iommu/io-pgtable-arm.h

diff --git a/MAINTAINERS b/MAINTAINERS
index df6e9bb2559a..9b996a94e460 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1114,8 +1114,7 @@ L:	linux-arm-kernel@lists.infradead.org (moderated for non-subscribers)
 S:	Maintained
 F:	drivers/iommu/arm-smmu.c
 F:	drivers/iommu/arm-smmu-v3.c
-F:	drivers/iommu/io-pgtable-arm.c
-F:	drivers/iommu/io-pgtable-arm-v7s.c
+F:	drivers/iommu/io-pgtable-arm*
 
 ARM SUB-ARCHITECTURES
 L:	linux-arm-kernel@lists.infradead.org (moderated for non-subscribers)
diff --git a/drivers/iommu/io-pgtable-arm.c b/drivers/iommu/io-pgtable-arm.c
index 39c2a056da21..fe851eae9057 100644
--- a/drivers/iommu/io-pgtable-arm.c
+++ b/drivers/iommu/io-pgtable-arm.c
@@ -32,6 +32,7 @@
 #include <asm/barrier.h>
 
 #include "io-pgtable.h"
+#include "io-pgtable-arm.h"
 
 #define ARM_LPAE_MAX_ADDR_BITS		52
 #define ARM_LPAE_S2_MAX_CONCAT_PAGES	16
@@ -121,54 +122,6 @@
 #define ARM_LPAE_PTE_MEMATTR_DEV	(((arm_lpae_iopte)0x1) << 2)
 
 /* Register bits */
-#define ARM_32_LPAE_TCR_EAE		(1 << 31)
-#define ARM_64_LPAE_S2_TCR_RES1		(1 << 31)
-
-#define ARM_LPAE_TCR_EPD1		(1 << 23)
-
-#define ARM_LPAE_TCR_TG0_4K		(0 << 14)
-#define ARM_LPAE_TCR_TG0_64K		(1 << 14)
-#define ARM_LPAE_TCR_TG0_16K		(2 << 14)
-
-#define ARM_LPAE_TCR_SH0_SHIFT		12
-#define ARM_LPAE_TCR_SH0_MASK		0x3
-#define ARM_LPAE_TCR_SH_NS		0
-#define ARM_LPAE_TCR_SH_OS		2
-#define ARM_LPAE_TCR_SH_IS		3
-
-#define ARM_LPAE_TCR_ORGN0_SHIFT	10
-#define ARM_LPAE_TCR_IRGN0_SHIFT	8
-#define ARM_LPAE_TCR_RGN_MASK		0x3
-#define ARM_LPAE_TCR_RGN_NC		0
-#define ARM_LPAE_TCR_RGN_WBWA		1
-#define ARM_LPAE_TCR_RGN_WT		2
-#define ARM_LPAE_TCR_RGN_WB		3
-
-#define ARM_LPAE_TCR_SL0_SHIFT		6
-#define ARM_LPAE_TCR_SL0_MASK		0x3
-
-#define ARM_LPAE_TCR_T0SZ_SHIFT		0
-#define ARM_LPAE_TCR_SZ_MASK		0xf
-
-#define ARM_LPAE_TCR_PS_SHIFT		16
-#define ARM_LPAE_TCR_PS_MASK		0x7
-
-#define ARM_LPAE_TCR_IPS_SHIFT		32
-#define ARM_LPAE_TCR_IPS_MASK		0x7
-
-#define ARM_LPAE_TCR_PS_32_BIT		0x0ULL
-#define ARM_LPAE_TCR_PS_36_BIT		0x1ULL
-#define ARM_LPAE_TCR_PS_40_BIT		0x2ULL
-#define ARM_LPAE_TCR_PS_42_BIT		0x3ULL
-#define ARM_LPAE_TCR_PS_44_BIT		0x4ULL
-#define ARM_LPAE_TCR_PS_48_BIT		0x5ULL
-#define ARM_LPAE_TCR_PS_52_BIT		0x6ULL
-
-#define ARM_LPAE_MAIR_ATTR_SHIFT(n)	((n) << 3)
-#define ARM_LPAE_MAIR_ATTR_MASK		0xff
-#define ARM_LPAE_MAIR_ATTR_DEVICE	0x04
-#define ARM_LPAE_MAIR_ATTR_NC		0x44
-#define ARM_LPAE_MAIR_ATTR_WBRWA	0xff
 #define ARM_LPAE_MAIR_ATTR_IDX_NC	0
 #define ARM_LPAE_MAIR_ATTR_IDX_CACHE	1
 #define ARM_LPAE_MAIR_ATTR_IDX_DEV	2
diff --git a/drivers/iommu/io-pgtable-arm.h b/drivers/iommu/io-pgtable-arm.h
new file mode 100644
index 000000000000..e35ba4666214
--- /dev/null
+++ b/drivers/iommu/io-pgtable-arm.h
@@ -0,0 +1,54 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef __IO_PGTABLE_ARM_H
+#define __IO_PGTABLE_ARM_H
+
+#define ARM_32_LPAE_TCR_EAE		(1 << 31)
+#define ARM_64_LPAE_S2_TCR_RES1		(1 << 31)
+
+#define ARM_LPAE_TCR_EPD1		(1 << 23)
+
+#define ARM_LPAE_TCR_TG0_4K		(0 << 14)
+#define ARM_LPAE_TCR_TG0_64K		(1 << 14)
+#define ARM_LPAE_TCR_TG0_16K		(2 << 14)
+
+#define ARM_LPAE_TCR_SH0_SHIFT		12
+#define ARM_LPAE_TCR_SH0_MASK		0x3
+#define ARM_LPAE_TCR_SH_NS		0
+#define ARM_LPAE_TCR_SH_OS		2
+#define ARM_LPAE_TCR_SH_IS		3
+
+#define ARM_LPAE_TCR_ORGN0_SHIFT	10
+#define ARM_LPAE_TCR_IRGN0_SHIFT	8
+#define ARM_LPAE_TCR_RGN_MASK		0x3
+#define ARM_LPAE_TCR_RGN_NC		0
+#define ARM_LPAE_TCR_RGN_WBWA		1
+#define ARM_LPAE_TCR_RGN_WT		2
+#define ARM_LPAE_TCR_RGN_WB		3
+
+#define ARM_LPAE_TCR_SL0_SHIFT		6
+#define ARM_LPAE_TCR_SL0_MASK		0x3
+
+#define ARM_LPAE_TCR_T0SZ_SHIFT		0
+#define ARM_LPAE_TCR_SZ_MASK		0x3f
+
+#define ARM_LPAE_TCR_PS_SHIFT		16
+#define ARM_LPAE_TCR_PS_MASK		0x7
+
+#define ARM_LPAE_TCR_IPS_SHIFT		32
+#define ARM_LPAE_TCR_IPS_MASK		0x7
+
+#define ARM_LPAE_TCR_PS_32_BIT		0x0ULL
+#define ARM_LPAE_TCR_PS_36_BIT		0x1ULL
+#define ARM_LPAE_TCR_PS_40_BIT		0x2ULL
+#define ARM_LPAE_TCR_PS_42_BIT		0x3ULL
+#define ARM_LPAE_TCR_PS_44_BIT		0x4ULL
+#define ARM_LPAE_TCR_PS_48_BIT		0x5ULL
+#define ARM_LPAE_TCR_PS_52_BIT		0x6ULL
+
+#define ARM_LPAE_MAIR_ATTR_SHIFT(n)	((n) << 3)
+#define ARM_LPAE_MAIR_ATTR_MASK		0xff
+#define ARM_LPAE_MAIR_ATTR_DEVICE	0x04
+#define ARM_LPAE_MAIR_ATTR_NC		0x44
+#define ARM_LPAE_MAIR_ATTR_WBRWA	0xff
+
+#endif /* __IO_PGTABLE_ARM_H */
-- 
2.17.0
