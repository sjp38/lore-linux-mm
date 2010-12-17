Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 72CE56B009E
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 23:16:42 -0500 (EST)
From: KyongHo Cho <pullip.cho@samsung.com>
Subject: [RFCv2,7/8] mm: vcm: vcm-cma: VCM CMA driver added
Date: Fri, 17 Dec 2010 12:56:26 +0900
Message-Id: <1292558187-17348-8-git-send-email-pullip.cho@samsung.com>
In-Reply-To: <1292558187-17348-7-git-send-email-pullip.cho@samsung.com>
References: <1292558187-17348-1-git-send-email-pullip.cho@samsung.com>
 <1292558187-17348-2-git-send-email-pullip.cho@samsung.com>
 <1292558187-17348-3-git-send-email-pullip.cho@samsung.com>
 <1292558187-17348-4-git-send-email-pullip.cho@samsung.com>
 <1292558187-17348-5-git-send-email-pullip.cho@samsung.com>
 <1292558187-17348-6-git-send-email-pullip.cho@samsung.com>
 <1292558187-17348-7-git-send-email-pullip.cho@samsung.com>
Sender: owner-linux-mm@kvack.org
To: KyongHo Cho <pullip.cho@samsung.com>
Cc: Kyungmin Park <kyungmin.park@samsung.com>, Kukjin Kim <kgene.kim@samsung.com>, Inho Lee <ilho215.lee@samsung.com>, Inki Dae <inki.dae@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linux-samsung-soc@vger.kernel.org, Michal Nazarewicz <m.nazarewicz@samsung.com>
List-ID: <linux-mm.kvack.org>

From: Michal Nazarewicz <m.nazarewicz@samsung.com>

This commit adds a VCM driver that instead of using real
hardware MMU emulates one and uses CMA for allocating
contiguous memory chunks.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 Documentation/virtual-contiguous-memory.txt |   12 +++-
 include/linux/vcm-cma.h                     |   38 ++++++++++
 mm/Kconfig                                  |   14 ++++
 mm/Makefile                                 |    1 +
 mm/vcm-cma.c                                |   99 +++++++++++++++++++++++++++
 5 files changed, 163 insertions(+), 1 deletions(-)
 create mode 100644 include/linux/vcm-cma.h
 create mode 100644 mm/vcm-cma.c

diff --git a/Documentation/virtual-contiguous-memory.txt b/Documentation/virtual-contiguous-memory.txt
index 070685b..46edaee 100644
--- a/Documentation/virtual-contiguous-memory.txt
+++ b/Documentation/virtual-contiguous-memory.txt
@@ -552,7 +552,17 @@ well:
 If one uses vcm_unbind() then vcm_bind() on the same reservation,
 physical memory pair should also work.
 
-There are no One-to-One drivers at this time.
+*** VCM CMA
+
+VCM CMA driver is a One-to-One driver which uses CMA (see
+[[file:contiguous-memory.txt][contiguous-memory.txt]]) to allocate physically contiguous memory.  VCM
+CMA context is created by calling:
+
+	struct vcm *__must_check
+	vcm_cma_create(const char *regions, dma_addr_t alignment);
+
+Its first argument is the list of regions that CMA should try to
+allocate memory from.  The second argument is required alignment.
 
 * Writing a VCM driver
 
diff --git a/include/linux/vcm-cma.h b/include/linux/vcm-cma.h
new file mode 100644
index 0000000..57c2cc9
--- /dev/null
+++ b/include/linux/vcm-cma.h
@@ -0,0 +1,38 @@
+/*
+ * Virtual Contiguous Memory driver for CMA header
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
+#ifndef __LINUX_VCM_CMA_H
+#define __LINUX_VCM_CMA_H
+
+#include <linux/types.h>
+
+struct vcm;
+
+/**
+ * vcm_cma_create() - creates a VCM context that fakes a hardware MMU
+ * @ctx:	the cma context that is defined by the machine's implementation.
+ *		from.
+ * @alignment:	required alignment of allocations.
+ *
+ * This creates VCM context that can be used on platforms with no
+ * hardware MMU or for devices that aro conected to the bus directly.
+ * Because it does not represent real MMU it has some limitations:
+ * basically, vcm_alloc(), vcm_reserve() and vcm_bind() are likely to
+ * fail so vcm_make_binding() should be used instead.
+ */
+struct vcm *__must_check
+vcm_cma_create(struct cma *ctx, unsigned long alignment);
+
+#endif
diff --git a/mm/Kconfig b/mm/Kconfig
index 53328d2..5cd25e7 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -390,6 +390,20 @@ config VCM_O2O
 	  it if you are going to build external modules that will use this
 	  functionality.
 
+config VCM_CMA
+	bool "VCM CMA driver"
+	depends on VCM && CMA
+	select VCM_O2O
+	help
+	  This enables VCM driver that instead of using a real hardware
+	  MMU fakes one and uses a direct mapping.  It provides a subset
+	  of functionalities of a real MMU but if drivers limits their
+	  use of VCM to only supported operations they can work on
+	  both systems with and without MMU with no changes.
+
+	  For more information see
+	  <Documentation/virtual-contiguous-memory.txt>.  If unsure, say "n".
+
 #
 # UP and nommu archs use km based percpu allocator
 #
diff --git a/mm/Makefile b/mm/Makefile
index b96a6cb..6663fc2 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -44,3 +44,4 @@ obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
 obj-$(CONFIG_CMA) += cma.o
 obj-$(CONFIG_VCM) += vcm.o
+obj-$(CONFIG_VCM_CMA) += vcm-cma.o
diff --git a/mm/vcm-cma.c b/mm/vcm-cma.c
new file mode 100644
index 0000000..dcdc751
--- /dev/null
+++ b/mm/vcm-cma.c
@@ -0,0 +1,99 @@
+/*
+ * Virtual Contiguous Memory driver for CMA
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
+#include <linux/vcm-drv.h>
+#include <linux/cma.h>
+#include <linux/module.h>
+#include <linux/err.h>
+#include <linux/errno.h>
+#include <linux/slab.h>
+
+struct vcm_cma {
+	struct vcm_o2o	o2o;
+	struct cma	*ctx;
+	unsigned long	alignment;
+};
+
+struct vcm_cma_phys {
+	struct cm		*chunk;
+	struct vcm_phys		phys;
+};
+
+static void vcm_cma_free(struct vcm_phys *_phys)
+{
+	struct vcm_cma_phys *phys =
+		container_of(_phys, struct vcm_cma_phys, phys);
+	cm_unpin(phys->chunk);
+	cm_free(phys->chunk);
+	kfree(phys);
+}
+
+static struct vcm_phys *
+vcm_cma_phys(struct vcm *vcm, resource_size_t size, unsigned flags)
+{
+	struct vcm_cma *cma = container_of(vcm, struct vcm_cma, o2o.vcm);
+	struct vcm_cma_phys *phys;
+	struct cm *chunk;
+
+	phys = kmalloc(sizeof *phys + sizeof *phys->phys.parts, GFP_KERNEL);
+	if (!phys)
+		return ERR_PTR(-ENOMEM);
+
+	chunk = cm_alloc(cma->ctx, size, cma->alignment);
+	if (IS_ERR(chunk)) {
+		kfree(phys);
+		return ERR_CAST(chunk);
+	}
+
+	phys->chunk = chunk;
+	phys->phys.count = 1;
+	phys->phys.free = vcm_cma_free;
+	phys->phys.parts->start = cm_pin(chunk);
+	phys->phys.parts->size  = size;
+	return &phys->phys;
+}
+
+struct vcm *__must_check
+vcm_cma_create(struct cma *ctx, unsigned long alignment)
+{
+	static const struct vcm_o2o_driver driver = {
+		.phys	= vcm_cma_phys,
+	};
+
+	struct vcm_cma *cma;
+	struct vcm *vcm;
+
+	if (alignment & (alignment - 1))
+		return ERR_PTR(-EINVAL);
+
+	cma = kmalloc(sizeof *cma, GFP_KERNEL);
+	if (!cma)
+		return ERR_PTR(-ENOMEM);
+
+	cma->o2o.driver    = &driver;
+	/* dummy size and start address!
+	 * to be accepted by vcm_init()
+	 * vcm_cma does not use these members.
+	 */
+	cma->o2o.vcm.start = 0;
+	cma->o2o.vcm.size  = PAGE_SIZE;
+	cma->ctx	   = ctx;
+	cma->alignment     = alignment;
+	vcm = vcm_o2o_init(&cma->o2o);
+	if (IS_ERR(vcm))
+		kfree(cma);
+	return vcm;
+}
+EXPORT_SYMBOL_GPL(vcm_cma_create);
-- 
1.6.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
