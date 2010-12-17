Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5DE936B00A2
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 23:16:43 -0500 (EST)
From: KyongHo Cho <pullip.cho@samsung.com>
Subject: [RFCv2,8/8] mm: vcm: Sample driver added
Date: Fri, 17 Dec 2010 12:56:27 +0900
Message-Id: <1292558187-17348-9-git-send-email-pullip.cho@samsung.com>
In-Reply-To: <1292558187-17348-8-git-send-email-pullip.cho@samsung.com>
References: <1292558187-17348-1-git-send-email-pullip.cho@samsung.com>
 <1292558187-17348-2-git-send-email-pullip.cho@samsung.com>
 <1292558187-17348-3-git-send-email-pullip.cho@samsung.com>
 <1292558187-17348-4-git-send-email-pullip.cho@samsung.com>
 <1292558187-17348-5-git-send-email-pullip.cho@samsung.com>
 <1292558187-17348-6-git-send-email-pullip.cho@samsung.com>
 <1292558187-17348-7-git-send-email-pullip.cho@samsung.com>
 <1292558187-17348-8-git-send-email-pullip.cho@samsung.com>
Sender: owner-linux-mm@kvack.org
To: KyongHo Cho <pullip.cho@samsung.com>
Cc: Kyungmin Park <kyungmin.park@samsung.com>, Kukjin Kim <kgene.kim@samsung.com>, Inho Lee <ilho215.lee@samsung.com>, Inki Dae <inki.dae@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linux-samsung-soc@vger.kernel.org, Michal Nazarewicz <m.nazarewicz@samsung.com>
List-ID: <linux-mm.kvack.org>

This commit adds a sample Virtual Contiguous Memory framework
driver.  It handles no real hardware and is there only for
demonstrating purposes.

* * * THIS COMMIT IS NOT FOR MERGING * * *

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 Documentation/virtual-contiguous-memory.txt |    3 +
 include/linux/vcm-sample.h                  |   30 +++++++
 mm/Kconfig                                  |   13 +++
 mm/Makefile                                 |    1 +
 mm/vcm-sample.c                             |  119 +++++++++++++++++++++++++++
 5 files changed, 166 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/vcm-sample.h
 create mode 100644 mm/vcm-sample.c

diff --git a/Documentation/virtual-contiguous-memory.txt b/Documentation/virtual-contiguous-memory.txt
index 9354c4c..8edd457 100644
--- a/Documentation/virtual-contiguous-memory.txt
+++ b/Documentation/virtual-contiguous-memory.txt
@@ -781,6 +781,9 @@ already there.
 Note that to use the VCM MMU wrapper one needs to select the VCM_MMU
 Kconfig option or otherwise the wrapper won't be available.
 
+There is a sample driver provided which provides a template for real
+drivers.  It can be found in [[file:../mm/vcm-sample.c][mm/vcm-sample.c]] file.
+
 *** Context creation
 
 Similarly to normal drivers, MMU driver needs to provide a context
diff --git a/include/linux/vcm-sample.h b/include/linux/vcm-sample.h
new file mode 100644
index 0000000..86a71ca
--- /dev/null
+++ b/include/linux/vcm-sample.h
@@ -0,0 +1,30 @@
+/*
+ * Virtual Contiguous Memory sample driver header file
+ * Copyright (c) 2010 by Samsung Electronics.
+ * Written by Michal Nazarewicz (m.nazarewicz@samsung.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of the
+ * License or (at your optional) any later version of the license.
+ */
+
+/*
+ * See Documentation/virtual-contiguous-memory.txt for details.
+ */
+
+#ifndef __LINUX_VCM_SAMP_H
+#define __LINUX_VCM_SAMP_H
+
+#include <linux/types.h>
+
+struct vcm;
+
+/**
+ * vcm_samp_create() - creates a VCM context
+ *
+ * ... Documentation goes here ...
+ */
+struct vcm *__must_check vcm_samp_create(/* ... */);
+
+#endif
diff --git a/mm/Kconfig b/mm/Kconfig
index 0f4d893..adb90a8 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -430,6 +430,19 @@ config VCM_CMA
  	  For more information see
  	  <Documentation/virtual-contiguous-memory.txt>.  If unsure, say "n".
 
+config VCM_SAMP
+ 	bool "VCM sample driver"
+ 	depends on VCM
+ 	select VCM_MMU
+ 	help
+ 	  This enables a sample driver for the VCM framework.  This driver
+ 	  does not handle any real harwdare.  It's merely an template of
+ 	  how for real drivers.
+
+ 	  For more information see
+ 	  <Documentation/virtual-contiguous-memory.txt>.  If unsure, say
+ 	  "n".
+
 #
 # UP and nommu archs use km based percpu allocator
 #
diff --git a/mm/Makefile b/mm/Makefile
index 78e1bd5..515c433 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -46,3 +46,4 @@ obj-$(CONFIG_CMA) += cma.o
 obj-$(CONFIG_CMA_BEST_FIT) += cma-best-fit.o
 obj-$(CONFIG_VCM) += vcm.o
 obj-$(CONFIG_VCM_CMA) += vcm-cma.o
+obj-$(CONFIG_VCM_SAMPLE) += vcm-sample.o
diff --git a/mm/vcm-sample.c b/mm/vcm-sample.c
new file mode 100644
index 0000000..27a2ae7
--- /dev/null
+++ b/mm/vcm-sample.c
@@ -0,0 +1,119 @@
+/*
+ * Virtual Contiguous Memory driver template
+ * Copyright (c) 2010 by Samsung Electronics.
+ * Written by Michal Nazarewicz (m.nazarewicz@samsung.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of the
+ * License or (at your optional) any later version of the license.
+ */
+
+/*
+ * This is just a sample code.  It does nothing useful other then
+ * presenting a template for VCM driver.
+ */
+
+/*
+ * See Documentation/virtual-contiguous-memory.txt for details.
+ */
+
+#include <linux/vcm-drv.h>
+
+struct vcm_samp {
+	struct vcm_mmu	mmu;
+	/* ... */
+};
+
+static const unsigned vcm_samp_orders[] = {
+	4 + 20 - PAGES_SHIFT,	/* 16MiB pages */
+	0 + 20 - PAGES_SHIFT,	/*  1MiB pages */
+	6 + 10 - PAGES_SHIFT,	/* 64KiB pages */
+	2 + 10 - PAGES_SHIFT,	/*  4KiB pages */
+};
+
+static int vcm_samp_activate_page(dma_addr_t vaddr, dma_addr_t paddr,
+				  unsigned order, void *priv)
+{
+	struct vcm_samp *samp =
+		container_of((struct vcm *)priv, struct vcm_samp, mmu.vcm);
+
+	/*
+	 * Handle adding a mapping from virtual page at @vaddr to
+	 * physical page ad @paddr.  The page is of order @order which
+	 * means that it's (PAGE_SIZE << @order) bytes.
+	 */
+
+	return -EOPNOTSUPP;
+}
+
+static int vcm_samp_deactivate_page(dma_addr_t vaddr, dma_addr_t paddr,
+				    unsigned order, void *priv)
+{
+	struct vcm_samp *samp =
+		container_of((struct vcm *)priv, struct vcm_samp, mmu.vcm);
+
+	/*
+	 * Handle removing a mapping from virtual page at @vaddr to
+	 * physical page at @paddr.  The page is of order @order which
+	 * means that it's (PAGE_SIZE << @order) bytes.
+	 */
+
+	/* It's best not to fail here */
+	return 0;
+}
+
+static void vcm_samp_cleanup(struct vcm *vcm)
+{
+	struct vcm_samp *samp =
+		container_of(res->vcm, struct vcm_samp, mmu.vcm);
+
+	/* Clean ups ... */
+
+	kfree(samp);
+}
+
+struct vcm *__must_check vcm_samp_create(/* ... */)
+{
+	static const struct vcm_mmu_driver driver = {
+		.order           = vcm_samp_orders,
+		.cleanup         = vcm_samp_cleanup,
+		.activate_page   = vcm_samp_activate_page,
+		.deactivate_page = vcm_samp_deactivate_page,
+	};
+
+	struct vcm_samp *samp;
+	struct vcm *vcm;
+
+	switch (0) {
+	case 0:
+	case PAGE_SHIFT == 12:
+		/*
+		 * If you have a compilation error here it means you
+		 * are compiling for a very strange platfrom where
+		 * PAGE_SHIFT is not 12 (ie. PAGE_SIZE is not 4KiB).
+		 * This driver assumes PAGE_SHIFT is 12.
+		 */
+	};
+
+	samp = kzalloc(sizeof *samp, GFP_KERNEL);
+	if (!samp)
+		return ERR_PTR(-ENOMEM);
+
+	/* ... Set things up ... */
+
+	samp->mmu.driver    = &driver;
+	/* skip first 64K so that zero address will be a NULL pointer */
+	samp->mmu.vcm.start =  (64 << 10);
+	samp->mmu.vcm.size  = -(64 << 10);
+
+	vcm = vcm_mmu_init(&samp->mmu);
+	if (!IS_ERR(vcm))
+		return vcm;
+
+	/* ... Error recovery ... */
+
+	kfree(samp);
+	return vcm;
+}
+EXPORT_SYMBOL_GPL(vcm_samp_create);
-- 
1.6.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
