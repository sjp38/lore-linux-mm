Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B4EBE6B009F
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 23:16:41 -0500 (EST)
From: KyongHo Cho <pullip.cho@samsung.com>
Subject: [RFCv2,6/8] mm: vcm: VCM One-to-One wrapper added
Date: Fri, 17 Dec 2010 12:56:25 +0900
Message-Id: <1292558187-17348-7-git-send-email-pullip.cho@samsung.com>
In-Reply-To: <1292558187-17348-6-git-send-email-pullip.cho@samsung.com>
References: <1292558187-17348-1-git-send-email-pullip.cho@samsung.com>
 <1292558187-17348-2-git-send-email-pullip.cho@samsung.com>
 <1292558187-17348-3-git-send-email-pullip.cho@samsung.com>
 <1292558187-17348-4-git-send-email-pullip.cho@samsung.com>
 <1292558187-17348-5-git-send-email-pullip.cho@samsung.com>
 <1292558187-17348-6-git-send-email-pullip.cho@samsung.com>
Sender: owner-linux-mm@kvack.org
To: KyongHo Cho <pullip.cho@samsung.com>
Cc: Kyungmin Park <kyungmin.park@samsung.com>, Kukjin Kim <kgene.kim@samsung.com>, Inho Lee <ilho215.lee@samsung.com>, Inki Dae <inki.dae@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linux-samsung-soc@vger.kernel.org, Michal Nazarewicz <m.nazarewicz@samsung.com>
List-ID: <linux-mm.kvack.org>

From: Michal Nazarewicz <m.nazarewicz@samsung.com>

This commits adds a VCM One-to-One wrapper which is meant to be
a helper code for creating VCM drivers for "fake" MMUs, ie.
situation where there is no real hardware MMU and memory
must be contiguous physically and mapped directly to "virtual"
address space.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 Documentation/virtual-contiguous-memory.txt |   33 ++++++++++
 include/linux/vcm-drv.h                     |   41 ++++++++++++
 mm/Kconfig                                  |   10 +++
 mm/vcm.c                                    |   90 +++++++++++++++++++++++++++
 4 files changed, 174 insertions(+), 0 deletions(-)

diff --git a/Documentation/virtual-contiguous-memory.txt b/Documentation/virtual-contiguous-memory.txt
index 9036abe..070685b 100644
--- a/Documentation/virtual-contiguous-memory.txt
+++ b/Documentation/virtual-contiguous-memory.txt
@@ -883,6 +883,39 @@ rather then the whole mapping.  It basically incorporates call to the
 vcm_phys_walk() function so driver does not need to call it
 explicitly.
 
+** Writing a one-to-one VCM driver
+
+Similarly to a wrapper for a real hardware MMU a wrapper for
+one-to-one VCM contexts has been created.  It implements all of the
+houskeeping operations and leaves only contiguous memory management
+(that is allocating and freeing contiguous regions) to the VCM O2O
+driver.
+
+As with other drivers, one-to-one driver needs to provide a context
+creation function.  It needs to allocate space for vcm_o2o structure
+and initialise its vcm.start, vcm.end and driver fields.  Calling
+vcm_o2o_init() will fill the other fields and validate entered values:
+
+	struct vcm *__must_check vcm_o2o_init(struct vcm_o2o *o2o);
+
+There are the following two operations used by the wrapper:
+
+	void (*cleanup)(struct vcm *vcm);
+	struct vcm_phys *(*phys)(struct vcm *vcm, resource_size_t size,
+				 unsigned flags);
+
+The cleanup operation cleans the context and frees all resources.  If
+not provided, kfree() is used.
+
+The phys operation is used in the same way as the core driver's phys
+operation.  The only difference is that it must return a physically
+contiguous memory block -- ie. returned structure must have only one
+part.  On error, the operation must return an error-pointer.  It is
+required.
+
+Note that to use the VCM one-to-one wrapper one needs to select the
+VCM_O2O Kconfig option or otherwise the wrapper won't be available.
+
 * Epilogue
 
 The initial version of the VCM framework was written by Zach Pfeffer
diff --git a/include/linux/vcm-drv.h b/include/linux/vcm-drv.h
index 98d065b..d7d97de 100644
--- a/include/linux/vcm-drv.h
+++ b/include/linux/vcm-drv.h
@@ -194,6 +194,47 @@ struct vcm *__must_check vcm_mmu_init(struct vcm_mmu *mmu);
 
 #endif
 
+#ifdef CONFIG_VCM_O2O
+
+/**
+ * struct vcm_o2o_driver - VCM One-to-One driver
+ * @cleanup:	cleans up the VCM context; if not specified. kfree() is used.
+ * @phys:	allocates a physical contiguous memory block; this is used in
+ *		the same way &struct vcm_driver's phys is used expect it must
+ *		provide a contiguous block (ie. exactly one part); required.
+ */
+struct vcm_o2o_driver {
+	void (*cleanup)(struct vcm *vcm);
+	struct vcm_phys *(*phys)(struct vcm *vcm, resource_size_t size,
+				 unsigned flags);
+};
+
+/**
+ * struct vcm_o2o - VCM One-to-One context
+ * @vcm:	VCM context.
+ * @driver:	VCM One-to-One driver's operations.
+ */
+struct vcm_o2o {
+	struct vcm			vcm;
+	const struct vcm_o2o_driver	*driver;
+};
+
+/**
+ * vcm_o2o_init() - initialises a VCM context for a one-to-one context.
+ * @o2o:	the vcm_o2o context to initialise.
+ *
+ * This function initialises the vcm_o2o structure created by a O2O
+ * driver when setting things up.  It sets up all fields of the
+ * structure expect for @o2o->vcm.start, @o2o->vcm.size and
+ * @o2o->driver which are validated by this function.  If they have
+ * invalid value function produces warning and returns an
+ * error-pointer.  On any other error, an error-pointer is returned as
+ * well.  If everything is fine, address of @o2o->vcm is returned.
+ */
+struct vcm *__must_check vcm_o2o_init(struct vcm_o2o *o2o);
+
+#endif
+
 #ifdef CONFIG_VCM_PHYS
 
 /**
diff --git a/mm/Kconfig b/mm/Kconfig
index e91499d..53328d2 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -380,6 +380,16 @@ config VCM_MMU
  	  will be automatically selected.  You select it if you are going to
  	  build external modules that will use this functionality.
 
+config VCM_O2O
+	bool "VCM O2O wrapper"
+	depends on VCM && MODULES
+	help
+	  This enables the VCM one-to-one wrapper which helps creating VCM
+	  drivers for devices without IO MMUs.  If a VCM driver is built that
+	  requires this option, it will be automatically selected.  You select
+	  it if you are going to build external modules that will use this
+	  functionality.
+
 #
 # UP and nommu archs use km based percpu allocator
 #
diff --git a/mm/vcm.c b/mm/vcm.c
index 0d74e95..312540a 100644
--- a/mm/vcm.c
+++ b/mm/vcm.c
@@ -648,6 +648,96 @@ EXPORT_SYMBOL_GPL(vcm_mmu_init);
 #endif
 
 
+/**************************** One-to-One wrapper ****************************/
+
+#ifdef CONFIG_VCM_O2O
+
+static void vcm_o2o_cleanup(struct vcm *vcm)
+{
+	struct vcm_o2o *o2o = container_of(vcm, struct vcm_o2o, vcm);
+	if (o2o->driver->cleanup)
+		o2o->driver->cleanup(vcm);
+	else
+		kfree(o2o);
+}
+
+static struct vcm_phys *
+vcm_o2o_phys(struct vcm *vcm, resource_size_t size, unsigned flags)
+{
+	struct vcm_o2o *o2o = container_of(vcm, struct vcm_o2o, vcm);
+	struct vcm_phys *phys;
+
+	phys = o2o->driver->phys(vcm, size, flags);
+	if (!IS_ERR(phys) &&
+	    WARN_ON(!phys->free || !phys->parts->size ||
+		    phys->parts->size < size ||
+		    ((phys->parts->start | phys->parts->size) &
+		     ~PAGE_MASK))) {
+		if (phys->free)
+			phys->free(phys);
+		return ERR_PTR(-EINVAL);
+	}
+
+	return phys;
+}
+
+static struct vcm_res *
+vcm_o2o_map(struct vcm *vcm, struct vcm_phys *phys, unsigned flags)
+{
+	struct vcm_res *res;
+
+	if (phys->count != 1)
+		return ERR_PTR(-EOPNOTSUPP);
+
+	if (!phys->parts->size
+	 || ((phys->parts->start | phys->parts->size) & ~PAGE_MASK))
+		return ERR_PTR(-EINVAL);
+
+	res = kmalloc(sizeof *res, GFP_KERNEL);
+	if (!res)
+		return ERR_PTR(-ENOMEM);
+
+	res->start    = phys->parts->start;
+	res->res_size = phys->parts->size;
+	return res;
+}
+
+static int vcm_o2o_bind(struct vcm_res *res, struct vcm_phys *phys)
+{
+	if (phys->count != 1)
+		return -EOPNOTSUPP;
+
+	if (!phys->parts->size
+	 || ((phys->parts->start | phys->parts->size) & ~PAGE_MASK))
+		return -EINVAL;
+
+	if (res->start != phys->parts->start)
+		return -EOPNOTSUPP;
+
+	return 0;
+}
+
+struct vcm *__must_check vcm_o2o_init(struct vcm_o2o *o2o)
+{
+	static const struct vcm_driver driver = {
+		.cleanup	= vcm_o2o_cleanup,
+		.phys		= vcm_o2o_phys,
+		.map		= vcm_o2o_map,
+		.bind		= vcm_o2o_bind,
+		.unreserve	= (void (*)(struct vcm_res *))kfree,
+	};
+
+	if (WARN_ON(!o2o || !o2o->driver || !o2o->driver->phys))
+		return ERR_PTR(-EINVAL);
+
+	o2o->vcm.driver = &driver;
+	return vcm_init(&o2o->vcm);
+}
+EXPORT_SYMBOL_GPL(vcm_o2o_init);
+
+#endif
+
+
 /************************ Physical memory management ************************/
 
 #ifdef CONFIG_VCM_PHYS
-- 
1.6.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
