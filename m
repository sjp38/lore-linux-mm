Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B51606B0093
	for <linux-mm@kvack.org>; Sat, 11 Dec 2010 04:40:22 -0500 (EST)
From: KyongHo Cho <pullip.cho@samsung.com>
Subject: [RFC,7/7] mm: vcm: Sample driver added
Date: Sat, 11 Dec 2010 18:21:19 +0900
Message-Id: <1292059279-10026-8-git-send-email-pullip.cho@samsung.com>
In-Reply-To: <1292059279-10026-7-git-send-email-pullip.cho@samsung.com>
References: <1292059279-10026-1-git-send-email-pullip.cho@samsung.com>
 <1292059279-10026-2-git-send-email-pullip.cho@samsung.com>
 <1292059279-10026-3-git-send-email-pullip.cho@samsung.com>
 <1292059279-10026-4-git-send-email-pullip.cho@samsung.com>
 <1292059279-10026-5-git-send-email-pullip.cho@samsung.com>
 <1292059279-10026-6-git-send-email-pullip.cho@samsung.com>
 <1292059279-10026-7-git-send-email-pullip.cho@samsung.com>
Sender: owner-linux-mm@kvack.org
To: linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Randy Dunlap <rdunlap@xenotime.net>, Michal Nazarewicz <m.nazarewicz@samsung.com>, InKi Dae <inki.dae@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>
List-ID: <linux-mm.kvack.org>

From: Michal Nazarewicz <m.nazarewicz@samsung.com>

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
