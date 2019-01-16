Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id F40BE8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 13:25:31 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id q207so5303592iod.18
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 10:25:31 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id p24si217196iol.125.2019.01.16.10.25.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 16 Jan 2019 10:25:30 -0800 (PST)
From: Logan Gunthorpe <logang@deltatee.com>
Date: Wed, 16 Jan 2019 11:25:22 -0700
Message-Id: <20190116182523.19446-6-logang@deltatee.com>
In-Reply-To: <20190116182523.19446-1-logang@deltatee.com>
References: <20190116182523.19446-1-logang@deltatee.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Subject: [PATCH v25 5/6] ntb: ntb_hw_intel: use io-64-nonatomic instead of in-driver hacks
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-ntb@googlegroups.com, linux-crypto@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andy Shevchenko <andy.shevchenko@gmail.com>, =?UTF-8?q?Horia=20Geant=C4=83?= <horia.geanta@nxp.com>, Logan Gunthorpe <logang@deltatee.com>

Now that ioread64 and iowrite64 are available in io-64-nonatomic,
we can remove the hack at the top of ntb_hw_intel.c and replace it
with an include.

Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
Reviewed-by: Andy Shevchenko <andy.shevchenko@gmail.com>
Acked-by: Dave Jiang <dave.jiang@intel.com>
Acked-by: Allen Hubbe <Allen.Hubbe@dell.com>
Acked-by: Jon Mason <jdmason@kudzu.us>
---
 drivers/ntb/hw/intel/ntb_hw_intel.h | 30 +----------------------------
 1 file changed, 1 insertion(+), 29 deletions(-)

diff --git a/drivers/ntb/hw/intel/ntb_hw_intel.h b/drivers/ntb/hw/intel/ntb_hw_intel.h
index c49ff8970ce3..e071e28bca3f 100644
--- a/drivers/ntb/hw/intel/ntb_hw_intel.h
+++ b/drivers/ntb/hw/intel/ntb_hw_intel.h
@@ -53,6 +53,7 @@
 
 #include <linux/ntb.h>
 #include <linux/pci.h>
+#include <linux/io-64-nonatomic-lo-hi.h>
 
 /* PCI device IDs */
 #define PCI_DEVICE_ID_INTEL_NTB_B2B_JSF	0x3725
@@ -218,33 +219,4 @@ static inline int pdev_is_gen3(struct pci_dev *pdev)
 	return 0;
 }
 
-#ifndef ioread64
-#ifdef readq
-#define ioread64 readq
-#else
-#define ioread64 _ioread64
-static inline u64 _ioread64(void __iomem *mmio)
-{
-	u64 low, high;
-
-	low = ioread32(mmio);
-	high = ioread32(mmio + sizeof(u32));
-	return low | (high << 32);
-}
-#endif
-#endif
-
-#ifndef iowrite64
-#ifdef writeq
-#define iowrite64 writeq
-#else
-#define iowrite64 _iowrite64
-static inline void _iowrite64(u64 val, void __iomem *mmio)
-{
-	iowrite32(val, mmio);
-	iowrite32(val >> 32, mmio + sizeof(u32));
-}
-#endif
-#endif
-
 #endif
-- 
2.19.0
