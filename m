Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9477C6B00A3
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 23:16:44 -0500 (EST)
From: KyongHo Cho <pullip.cho@samsung.com>
Subject: [RFCv2,5/8] mm: vcm: VCM MMU wrapper added
Date: Fri, 17 Dec 2010 12:56:24 +0900
Message-Id: <1292558187-17348-6-git-send-email-pullip.cho@samsung.com>
In-Reply-To: <1292558187-17348-5-git-send-email-pullip.cho@samsung.com>
References: <1292558187-17348-1-git-send-email-pullip.cho@samsung.com>
 <1292558187-17348-2-git-send-email-pullip.cho@samsung.com>
 <1292558187-17348-3-git-send-email-pullip.cho@samsung.com>
 <1292558187-17348-4-git-send-email-pullip.cho@samsung.com>
 <1292558187-17348-5-git-send-email-pullip.cho@samsung.com>
Sender: owner-linux-mm@kvack.org
To: KyongHo Cho <pullip.cho@samsung.com>
Cc: Kyungmin Park <kyungmin.park@samsung.com>, Kukjin Kim <kgene.kim@samsung.com>, Inho Lee <ilho215.lee@samsung.com>, Inki Dae <inki.dae@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linux-samsung-soc@vger.kernel.org, Michal Nazarewicz <m.nazarewicz@samsung.com>
List-ID: <linux-mm.kvack.org>

From: Michal Nazarewicz <m.nazarewicz@samsung.com>

This commits adds a VCM MMU wrapper which is meant to be a helper
code for creating VCM drivers for real hardware MMUs.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 Documentation/virtual-contiguous-memory.txt |   80 ++++++++++
 include/linux/vcm-drv.h                     |   80 ++++++++++
 mm/Kconfig                                  |   11 ++
 mm/vcm.c                                    |  219 +++++++++++++++++++++++++++
 4 files changed, 390 insertions(+), 0 deletions(-)

diff --git a/Documentation/virtual-contiguous-memory.txt b/Documentation/virtual-contiguous-memory.txt
index c830b69..9036abe 100644
--- a/Documentation/virtual-contiguous-memory.txt
+++ b/Documentation/virtual-contiguous-memory.txt
@@ -803,6 +803,86 @@ When to release the ownership of a reservation:
 It is not required as well unable to remove the reservation explicitly. The
 last call to vcm_unreserve() will cause the reservation to be removed.
 
+** Writing a hardware MMU driver
+
+It may be undesirable to implement all of the operations that are
+required to create a usable driver.  In case of hardware MMUs a helper
+wrapper driver has been created to make writing real drivers as simple
+as possible.
+
+The wrapper implements most of the functionality of the driver leaving
+only implementation of the actual talking to the hardware MMU in hands
+of programmer.  Reservations managements as general housekeeping is
+already there.
+
+Note that to use the VCM MMU wrapper one needs to select the VCM_MMU
+Kconfig option or otherwise the wrapper won't be available.
+
+*** Context creation
+
+Similarly to normal drivers, MMU driver needs to provide a context
+creation function.  Such a function must provide a vcm_mmu object and
+initialise vcm.start, vcm.size and driver fields of the structure.
+When this is done, vcm_mmu_init() should be called which will
+initialise the rest of the fields and validate entered values:
+
+	struct vcm *__must_check vcm_mmu_init(struct vcm_mmu *mmu);
+
+This is, in fact, very similar to the way standard driver is created.
+
+*** Orders
+
+One of the fields of the vcm_mmu_driver structure is orders.  This is
+an array of orders of pages supported by the hardware MMU.  It must be
+sorted from largest to smallest and zero terminated.
+
+The order is the logarithm with the base two of the size of supported
+page size divided by PAGE_SIZE.  For instance, { 8, 4, 0 } means that
+MMU supports 1MiB, 64KiB and 4KiB pages.
+
+*** Operations
+
+The three operations that MMU wrapper driver uses are:
+
+	void (*cleanup)(struct vcm *vcm);
+
+	int (*activate)(struct vcm_res *res, struct vcm_phys *phys);
+	void (*deactivate)(struct vcm_res *res, struct vcm_phys *phys);
+
+	int (*activate_page)(dma_addr_t vaddr, dma_addr_t paddr,
+			     unsigned order, void *vcm),
+	int (*deactivate_page)(dma_addr_t vaddr, dma_addr_t paddr,
+			       unsigned order, void *vcm),
+
+The first one frees all resources allocated by the context creation
+function (including the structure itself).  If this operation is not
+given, kfree() will be called on vcm_mmu structure.
+
+The activate and deactivate operations are required and they are used
+to update mappings in the MMU.  Whenever binding is activated or
+deactivated the respective operation is called.
+
+To divide mapping into physical pages, vcm_phys_walk() function can be
+used:
+
+	int vcm_phys_walk(dma_addr_t vaddr, const struct vcm_phys *phys,
+			  const unsigned char *orders,
+			  int (*callback)(dma_addr_t vaddr, dma_addr_t paddr,
+					  unsigned order, void *priv),
+			  int (*recovery)(dma_addr_t vaddr, dma_addr_t paddr,
+					  unsigned order, void *priv),
+			  void *priv);
+
+It start from given virtual address and tries to divide allocated
+physical memory to as few pages as possible where order of each page
+is one of the orders specified by orders argument.
+
+It may be easier to implement activate_page and deactivate_page
+operations instead thought.  They are called on each individual page
+rather then the whole mapping.  It basically incorporates call to the
+vcm_phys_walk() function so driver does not need to call it
+explicitly.
+
 * Epilogue
 
 The initial version of the VCM framework was written by Zach Pfeffer
diff --git a/include/linux/vcm-drv.h b/include/linux/vcm-drv.h
index 536b051..98d065b 100644
--- a/include/linux/vcm-drv.h
+++ b/include/linux/vcm-drv.h
@@ -114,6 +114,86 @@ struct vcm_phys {
  */
 struct vcm *__must_check vcm_init(struct vcm *vcm);
 
+#ifdef CONFIG_VCM_MMU
+
+struct vcm_mmu;
+
+/**
+ * struct vcm_mmu_driver - a driver used for real MMUs.
+ * @orders:	array of orders of pages supported by the MMU sorted from
+ *		the largest to the smallest.  The last element is always
+ *		zero (which means 4K page).
+ * @cleanup:	Function called when the VCM context is destroyed;
+ *		optional, if not provided, kfree() is used.
+ * @activate:	callback function for activating a single mapping; it's
+ *		role is to set up the MMU so that reserved address space
+ *		donated by res will point to physical memory donated by
+ *		phys; called under spinlock with IRQs disabled - cannot
+ *		sleep; required unless @activate_page and @deactivate_page
+ *		are both provided
+ * @deactivate:	this reverses the effect of @activate; called under spinlock
+ *		with IRQs disabled - cannot sleep; required unless
+ *		@deactivate_page is provided.
+ * @activate_page:	callback function for activating a single page; it is
+ *			ignored if @activate is provided; it's given a single
+ *			page such that its order (given as third argument) is
+ *			one of the supported orders specified in @orders;
+ *			called under spinlock with IRQs disabled - cannot
+ *			sleep; required unless @activate is provided.
+ * @deactivate_page:	this reverses the effect of the @activate_page
+ *			callback; called under spinlock with IRQs disabled
+ *			- cannot sleep; required unless @activate and
+ *			@deactivate are both provided.
+ */
+struct vcm_mmu_driver {
+	const unsigned char	*orders;
+
+	void (*cleanup)(struct vcm *vcm);
+	int (*activate)(struct vcm_res *res, struct vcm_phys *phys);
+	void (*deactivate)(struct vcm_res *res, struct vcm_phys *phys);
+	int (*activate_page)(dma_addr_t vaddr, dma_addr_t paddr,
+			     unsigned order, void *vcm);
+	int (*deactivate_page)(dma_addr_t vaddr, dma_addr_t paddr,
+			       unsigned order, void *vcm);
+};
+
+/**
+ * struct vcm_mmu - VCM MMU context
+ * @vcm:	VCM context.
+ * @driver:	VCM MMU driver's operations.
+ * @pool:	virtual address space allocator; internal.
+ * @bound_res:	list of bound reservations; internal.
+ * @lock:	protects @bound_res and calls to activate/deactivate
+ *		operations; internal.
+ * @activated:	whether VCM context has been activated; internal.
+ */
+struct vcm_mmu {
+	struct vcm			vcm;
+	const struct vcm_mmu_driver	*driver;
+	/* internal */
+	struct gen_pool			*pool;
+	struct list_head		bound_res;
+	/* Protects operations on bound_res list. */
+	spinlock_t			lock;
+	int				activated;
+};
+
+/**
+ * vcm_mmu_init() - initialises a VCM context for a real MMU.
+ * @mmu:	the vcm_mmu context to initialise.
+ *
+ * This function initialises the vcm_mmu structure created by a MMU
+ * driver when setting things up.  It sets up all fields of the
+ * structure expect for @mmu->vcm.start, @mmu.vcm->size and
+ * @mmu->driver which are validated by this function.  If they have
+ * invalid value function produces warning and returns an
+ * error-pointer.  On any other error, an error-pointer is returned as
+ * well.  If everything is fine, address of @mmu->vcm is returned.
+ */
+struct vcm *__must_check vcm_mmu_init(struct vcm_mmu *mmu);
+
+#endif
+
 #ifdef CONFIG_VCM_PHYS
 
 /**
diff --git a/mm/Kconfig b/mm/Kconfig
index 00d975e..e91499d 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -369,6 +369,17 @@ config VCM_PHYS
 	  will be automatically selected.  You select it if you are going to
 	  build external modules that will use this functionality.
 
+config VCM_MMU
+ 	bool "VCM MMU wrapper"
+ 	depends on VCM && MODULES
+ 	select VCM_PHYS
+ 	select GENERIC_ALLOCATOR
+ 	help
+ 	  This enables the VCM MMU wrapper which helps creating VCM drivers
+ 	  for IO MMUs.  If a VCM driver is built that requires this option, it
+ 	  will be automatically selected.  You select it if you are going to
+ 	  build external modules that will use this functionality.
+
 #
 # UP and nommu archs use km based percpu allocator
 #
diff --git a/mm/vcm.c b/mm/vcm.c
index cd9f4ee..0d74e95 100644
--- a/mm/vcm.c
+++ b/mm/vcm.c
@@ -19,6 +19,8 @@
 #include <linux/vmalloc.h>
 #include <linux/err.h>
 #include <linux/slab.h>
+#include <linux/genalloc.h>
+
 
 /******************************** Devices API *******************************/
 
@@ -429,6 +431,223 @@ struct vcm *__must_check vcm_init(struct vcm *vcm)
 EXPORT_SYMBOL_GPL(vcm_init);
 
 
+/*************************** Hardware MMU wrapper ***************************/
+
+#ifdef CONFIG_VCM_MMU
+
+struct vcm_mmu_res {
+	struct vcm_res			res;
+	struct list_head		bound;
+};
+
+static void vcm_mmu_cleanup(struct vcm *vcm)
+{
+	struct vcm_mmu *mmu = container_of(vcm, struct vcm_mmu, vcm);
+	WARN_ON(spin_is_locked(&mmu->lock) || !list_empty(&mmu->bound_res));
+	gen_pool_destroy(mmu->pool);
+	if (mmu->driver->cleanup)
+		mmu->driver->cleanup(vcm);
+	else
+		kfree(mmu);
+}
+
+static struct vcm_res *
+vcm_mmu_res(struct vcm *vcm, resource_size_t size, unsigned flags)
+{
+	struct vcm_mmu *mmu = container_of(vcm, struct vcm_mmu, vcm);
+	const unsigned char *orders;
+	struct vcm_mmu_res *res;
+	dma_addr_t addr;
+	unsigned order;
+
+	res = kzalloc(sizeof *res, GFP_KERNEL);
+	if (!res)
+		return ERR_PTR(-ENOMEM);
+
+	order = ffs(size) - PAGE_SHIFT - 1;
+	for (orders = mmu->driver->orders; *orders > order; ++orders)
+		/* nop */;
+	order = *orders + PAGE_SHIFT;
+
+	addr = gen_pool_alloc_aligned(mmu->pool, size, order);
+	if (!addr) {
+		kfree(res);
+		return ERR_PTR(-ENOSPC);
+	}
+
+	INIT_LIST_HEAD(&res->bound);
+	res->res.start = addr;
+	res->res.res_size = size;
+
+	return &res->res;
+}
+
+static struct vcm_phys *
+vcm_mmu_phys(struct vcm *vcm, resource_size_t size, unsigned flags)
+{
+	return vcm_phys_alloc(size, flags,
+			      container_of(vcm, struct vcm_mmu,
+					   vcm)->driver->orders);
+}
+
+static int __must_check
+__vcm_mmu_activate(struct vcm_res *res, struct vcm_phys *phys)
+{
+	struct vcm_mmu *mmu = container_of(res->vcm, struct vcm_mmu, vcm);
+	if (mmu->driver->activate)
+		return mmu->driver->activate(res, phys);
+
+	return vcm_phys_walk(res->start, phys, mmu->driver->orders,
+			     mmu->driver->activate_page,
+			     mmu->driver->deactivate_page, res->vcm);
+}
+
+static void __vcm_mmu_deactivate(struct vcm_res *res, struct vcm_phys *phys)
+{
+	struct vcm_mmu *mmu = container_of(res->vcm, struct vcm_mmu, vcm);
+	if (mmu->driver->deactivate)
+		return mmu->driver->deactivate(res, phys);
+
+	vcm_phys_walk(res->start, phys, mmu->driver->orders,
+		      mmu->driver->deactivate_page, NULL, res->vcm);
+}
+
+static int vcm_mmu_bind(struct vcm_res *_res, struct vcm_phys *phys)
+{
+	struct vcm_mmu_res *res = container_of(_res, struct vcm_mmu_res, res);
+	struct vcm_mmu *mmu = container_of(_res->vcm, struct vcm_mmu, vcm);
+	unsigned long flags;
+	int ret;
+
+	spin_lock_irqsave(&mmu->lock, flags);
+	if (mmu->activated) {
+		ret = __vcm_mmu_activate(_res, phys);
+		if (ret < 0)
+			goto done;
+	}
+	list_add_tail(&res->bound, &mmu->bound_res);
+	ret = 0;
+done:
+	spin_unlock_irqrestore(&mmu->lock, flags);
+
+	return ret;
+}
+
+static void vcm_mmu_unbind(struct vcm_res *_res)
+{
+	struct vcm_mmu_res *res = container_of(_res, struct vcm_mmu_res, res);
+	struct vcm_mmu *mmu = container_of(_res->vcm, struct vcm_mmu, vcm);
+	unsigned long flags;
+
+	spin_lock_irqsave(&mmu->lock, flags);
+	if (mmu->activated)
+		__vcm_mmu_deactivate(_res, _res->phys);
+	list_del_init(&res->bound);
+	spin_unlock_irqrestore(&mmu->lock, flags);
+}
+
+static void vcm_mmu_unreserve(struct vcm_res *res)
+{
+	struct vcm_mmu *mmu = container_of(res->vcm, struct vcm_mmu, vcm);
+	gen_pool_free(mmu->pool, res->start, res->res_size);
+}
+
+static int vcm_mmu_activate(struct vcm *vcm)
+{
+	struct vcm_mmu *mmu = container_of(vcm, struct vcm_mmu, vcm);
+	struct vcm_mmu_res *r, *rr;
+	unsigned long flags;
+	int ret;
+
+	spin_lock_irqsave(&mmu->lock, flags);
+
+	list_for_each_entry(r, &mmu->bound_res, bound) {
+		ret = __vcm_mmu_activate(&r->res, r->res.phys);
+		if (ret >= 0)
+			continue;
+
+		list_for_each_entry(rr, &mmu->bound_res, bound) {
+			if (r == rr)
+				goto done;
+			__vcm_mmu_deactivate(&rr->res, rr->res.phys);
+		}
+	}
+
+	mmu->activated = 1;
+	ret = 0;
+
+done:
+	spin_unlock_irqrestore(&mmu->lock, flags);
+
+	return ret;
+}
+
+static void vcm_mmu_deactivate(struct vcm *vcm)
+{
+	struct vcm_mmu *mmu = container_of(vcm, struct vcm_mmu, vcm);
+	struct vcm_mmu_res *r;
+	unsigned long flags;
+
+	spin_lock_irqsave(&mmu->lock, flags);
+
+	mmu->activated = 0;
+
+	list_for_each_entry(r, &mmu->bound_res, bound)
+		mmu->driver->deactivate(&r->res, r->res.phys);
+
+	spin_unlock_irqrestore(&mmu->lock, flags);
+}
+
+struct vcm *__must_check vcm_mmu_init(struct vcm_mmu *mmu)
+{
+	static const struct vcm_driver driver = {
+		.cleanup	= vcm_mmu_cleanup,
+		.res		= vcm_mmu_res,
+		.phys		= vcm_mmu_phys,
+		.bind		= vcm_mmu_bind,
+		.unbind		= vcm_mmu_unbind,
+		.unreserve	= vcm_mmu_unreserve,
+		.activate	= vcm_mmu_activate,
+		.deactivate	= vcm_mmu_deactivate,
+	};
+
+	struct vcm *vcm;
+	int ret;
+
+	if (WARN_ON(!mmu || !mmu->driver ||
+		    !(mmu->driver->activate ||
+		      (mmu->driver->activate_page &&
+		       mmu->driver->deactivate_page)) ||
+		    !(mmu->driver->deactivate ||
+		      mmu->driver->deactivate_page)))
+		return ERR_PTR(-EINVAL);
+
+	mmu->vcm.driver = &driver;
+	vcm = vcm_init(&mmu->vcm);
+	if (IS_ERR(vcm))
+		return vcm;
+
+	mmu->pool = gen_pool_create(PAGE_SHIFT, -1);
+	if (!mmu->pool)
+		return ERR_PTR(-ENOMEM);
+
+	ret = gen_pool_add(mmu->pool, mmu->vcm.start, mmu->vcm.size, -1);
+	if (ret) {
+		gen_pool_destroy(mmu->pool);
+		return ERR_PTR(ret);
+	}
+
+	vcm->driver     = &driver;
+	INIT_LIST_HEAD(&mmu->bound_res);
+	spin_lock_init(&mmu->lock);
+
+	return &mmu->vcm;
+}
+EXPORT_SYMBOL_GPL(vcm_mmu_init);
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
