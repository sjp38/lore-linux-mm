Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 05CF38E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 13:25:34 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id 136so2475651itt.6
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 10:25:34 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id i71si4359416itc.81.2019.01.16.10.25.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 16 Jan 2019 10:25:32 -0800 (PST)
From: Logan Gunthorpe <logang@deltatee.com>
Date: Wed, 16 Jan 2019 11:25:23 -0700
Message-Id: <20190116182523.19446-7-logang@deltatee.com>
In-Reply-To: <20190116182523.19446-1-logang@deltatee.com>
References: <20190116182523.19446-1-logang@deltatee.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Subject: [PATCH v25 6/6] ntb: ntb_hw_switchtec: Cleanup 64bit IO defines to use the common header
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-ntb@googlegroups.com, linux-crypto@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andy Shevchenko <andy.shevchenko@gmail.com>, =?UTF-8?q?Horia=20Geant=C4=83?= <horia.geanta@nxp.com>, Logan Gunthorpe <logang@deltatee.com>, Jon Mason <jdmason@kudzu.us>

Clean up the ifdefs which conditionally defined the io{read|write}64
functions in favour of the new common io-64-nonatomic-lo-hi header.

Per a nit from Andy Shevchenko, the include list is also made
alphabetical.

Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
Reviewed-by: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Jon Mason <jdmason@kudzu.us>
---
 drivers/ntb/hw/mscc/ntb_hw_switchtec.c | 36 +++-----------------------
 1 file changed, 4 insertions(+), 32 deletions(-)

diff --git a/drivers/ntb/hw/mscc/ntb_hw_switchtec.c b/drivers/ntb/hw/mscc/ntb_hw_switchtec.c
index f1eaa3c4d46a..f2df2d39c65b 100644
--- a/drivers/ntb/hw/mscc/ntb_hw_switchtec.c
+++ b/drivers/ntb/hw/mscc/ntb_hw_switchtec.c
@@ -13,13 +13,14 @@
  *
  */
 
-#include <linux/switchtec.h>
-#include <linux/module.h>
+#include <linux/interrupt.h>
+#include <linux/io-64-nonatomic-lo-hi.h>
 #include <linux/delay.h>
 #include <linux/kthread.h>
-#include <linux/interrupt.h>
+#include <linux/module.h>
 #include <linux/ntb.h>
 #include <linux/pci.h>
+#include <linux/switchtec.h>
 
 MODULE_DESCRIPTION("Microsemi Switchtec(tm) NTB Driver");
 MODULE_VERSION("0.1");
@@ -36,35 +37,6 @@ module_param(use_lut_mws, bool, 0644);
 MODULE_PARM_DESC(use_lut_mws,
 		 "Enable the use of the LUT based memory windows");
 
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
 #define SWITCHTEC_NTB_MAGIC 0x45CC0001
 #define MAX_MWS     128
 
-- 
2.19.0
