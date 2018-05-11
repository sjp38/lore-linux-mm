Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 667696B0685
	for <linux-mm@kvack.org>; Fri, 11 May 2018 15:08:01 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id b13-v6so3428128oib.11
        for <linux-mm@kvack.org>; Fri, 11 May 2018 12:08:01 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 64-v6si1264635otq.359.2018.05.11.12.07.59
        for <linux-mm@kvack.org>;
        Fri, 11 May 2018 12:07:59 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: [PATCH v2 05/40] iommu/sva: Track mm changes with an MMU notifier
Date: Fri, 11 May 2018 20:06:06 +0100
Message-Id: <20180511190641.23008-6-jean-philippe.brucker@arm.com>
In-Reply-To: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com

When creating an io_mm structure, register an MMU notifier that informs
us when the virtual address space changes and disappears.

Add a new operation to the IOMMU driver, mm_invalidate, called when a
range of addresses is unmapped to let the IOMMU driver send ATC
invalidations. mm_invalidate cannot sleep.

Adding the notifier complicates io_mm release. In one case device
drivers free the io_mm explicitly by calling unbind (or detaching the
device from its domain). In the other case the process could crash
before unbind, in which case the release notifier has to do all the
work.

Allowing the device driver's mm_exit() handler to sleep adds another
complication, but it will greatly simplify things for users. For example
VFIO can take the IOMMU mutex and remove any trace of io_mm, instead of
introducing complex synchronization to delicatly handle this race. But
relaxing the user side does force unbind() to sleep and wait for all
pending mm_exit() calls to finish.

Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>

---
v1->v2:
* Unbind() waits for mm_exit to finish
* mm_exit can sleep
---
 drivers/iommu/Kconfig     |   1 +
 drivers/iommu/iommu-sva.c | 248 +++++++++++++++++++++++++++++++++++---
 include/linux/iommu.h     |  10 ++
 3 files changed, 244 insertions(+), 15 deletions(-)

diff --git a/drivers/iommu/Kconfig b/drivers/iommu/Kconfig
index cca8e06903c7..38434899e283 100644
--- a/drivers/iommu/Kconfig
+++ b/drivers/iommu/Kconfig
@@ -77,6 +77,7 @@ config IOMMU_DMA
 config IOMMU_SVA
 	bool
 	select IOMMU_API
+	select MMU_NOTIFIER
 
 config FSL_PAMU
 	bool "Freescale IOMMU support"
diff --git a/drivers/iommu/iommu-sva.c b/drivers/iommu/iommu-sva.c
index 0700893c679d..e9afae2537a2 100644
--- a/drivers/iommu/iommu-sva.c
+++ b/drivers/iommu/iommu-sva.c
@@ -7,6 +7,7 @@
 
 #include <linux/idr.h>
 #include <linux/iommu.h>
+#include <linux/mmu_notifier.h>
 #include <linux/sched/mm.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
@@ -106,6 +107,9 @@ struct iommu_bond {
 	struct list_head	mm_head;
 	struct list_head	dev_head;
 	struct list_head	domain_head;
+	refcount_t		refs;
+	struct wait_queue_head	mm_exit_wq;
+	bool			mm_exit_active;
 
 	void			*drvdata;
 };
@@ -124,6 +128,8 @@ static DEFINE_IDR(iommu_pasid_idr);
  */
 static DEFINE_SPINLOCK(iommu_sva_lock);
 
+static struct mmu_notifier_ops iommu_mmu_notifier;
+
 static struct io_mm *
 io_mm_alloc(struct iommu_domain *domain, struct device *dev,
 	    struct mm_struct *mm, unsigned long flags)
@@ -151,6 +157,7 @@ io_mm_alloc(struct iommu_domain *domain, struct device *dev,
 
 	io_mm->flags		= flags;
 	io_mm->mm		= mm;
+	io_mm->notifier.ops	= &iommu_mmu_notifier;
 	io_mm->release		= domain->ops->mm_free;
 	INIT_LIST_HEAD(&io_mm->devices);
 
@@ -167,8 +174,29 @@ io_mm_alloc(struct iommu_domain *domain, struct device *dev,
 		goto err_free_mm;
 	}
 
-	/* TODO: keep track of mm. For the moment, abort. */
-	ret = -ENOSYS;
+	ret = mmu_notifier_register(&io_mm->notifier, mm);
+	if (ret)
+		goto err_free_pasid;
+
+	/*
+	 * Now that the MMU notifier is valid, we can allow users to grab this
+	 * io_mm by setting a valid refcount. Before that it was accessible in
+	 * the IDR but invalid.
+	 *
+	 * The following barrier ensures that users, who obtain the io_mm with
+	 * kref_get_unless_zero, don't read uninitialized fields in the
+	 * structure.
+	 */
+	smp_wmb();
+	kref_init(&io_mm->kref);
+
+	return io_mm;
+
+err_free_pasid:
+	/*
+	 * Even if the io_mm is accessible from the IDR at this point, kref is
+	 * 0 so no user could get a reference to it. Free it manually.
+	 */
 	spin_lock(&iommu_sva_lock);
 	idr_remove(&iommu_pasid_idr, io_mm->pasid);
 	spin_unlock(&iommu_sva_lock);
@@ -180,9 +208,13 @@ io_mm_alloc(struct iommu_domain *domain, struct device *dev,
 	return ERR_PTR(ret);
 }
 
-static void io_mm_free(struct io_mm *io_mm)
+static void io_mm_free(struct rcu_head *rcu)
 {
-	struct mm_struct *mm = io_mm->mm;
+	struct io_mm *io_mm;
+	struct mm_struct *mm;
+
+	io_mm = container_of(rcu, struct io_mm, rcu);
+	mm = io_mm->mm;
 
 	io_mm->release(io_mm);
 	mmdrop(mm);
@@ -197,7 +229,22 @@ static void io_mm_release(struct kref *kref)
 
 	idr_remove(&iommu_pasid_idr, io_mm->pasid);
 
-	io_mm_free(io_mm);
+	/*
+	 * If we're being released from mm exit, the notifier callback ->release
+	 * has already been called. Otherwise we don't need ->release, the io_mm
+	 * isn't attached to anything anymore. Hence no_release.
+	 */
+	mmu_notifier_unregister_no_release(&io_mm->notifier, io_mm->mm);
+
+	/*
+	 * We can't free the structure here, because if mm exits during
+	 * unbind(), then ->release might be attempting to grab the io_mm
+	 * concurrently. And in the other case, if ->release is calling
+	 * io_mm_release, then __mmu_notifier_release expects to still have a
+	 * valid mn when returning. So free the structure when it's safe, after
+	 * the RCU grace period elapsed.
+	 */
+	mmu_notifier_call_srcu(&io_mm->rcu, io_mm_free);
 }
 
 /*
@@ -206,8 +253,14 @@ static void io_mm_release(struct kref *kref)
  */
 static int io_mm_get_locked(struct io_mm *io_mm)
 {
-	if (io_mm)
-		return kref_get_unless_zero(&io_mm->kref);
+	if (io_mm && kref_get_unless_zero(&io_mm->kref)) {
+		/*
+		 * kref_get_unless_zero doesn't provide ordering for reads. This
+		 * barrier pairs with the one in io_mm_alloc.
+		 */
+		smp_rmb();
+		return 1;
+	}
 
 	return 0;
 }
@@ -233,7 +286,8 @@ static int io_mm_attach(struct iommu_domain *domain, struct device *dev,
 	struct iommu_bond *bond, *tmp;
 	struct iommu_sva_param *param = dev->iommu_param->sva_param;
 
-	if (!domain->ops->mm_attach || !domain->ops->mm_detach)
+	if (!domain->ops->mm_attach || !domain->ops->mm_detach ||
+	    !domain->ops->mm_invalidate)
 		return -ENODEV;
 
 	if (pasid > param->max_pasid || pasid < param->min_pasid)
@@ -247,6 +301,8 @@ static int io_mm_attach(struct iommu_domain *domain, struct device *dev,
 	bond->io_mm		= io_mm;
 	bond->dev		= dev;
 	bond->drvdata		= drvdata;
+	refcount_set(&bond->refs, 1);
+	init_waitqueue_head(&bond->mm_exit_wq);
 
 	spin_lock(&iommu_sva_lock);
 	/*
@@ -275,12 +331,37 @@ static int io_mm_attach(struct iommu_domain *domain, struct device *dev,
 	return 0;
 }
 
-static void io_mm_detach_locked(struct iommu_bond *bond)
+static void io_mm_detach_locked(struct iommu_bond *bond, bool wait)
 {
 	struct iommu_bond *tmp;
 	bool detach_domain = true;
 	struct iommu_domain *domain = bond->domain;
 
+	if (wait) {
+		bool do_detach = true;
+		/*
+		 * If we're unbind() then we're deleting the bond no matter
+		 * what. Tell the mm_exit thread that we're cleaning up, and
+		 * wait until it finishes using the bond.
+		 *
+		 * refs is guaranteed to be one or more, otherwise it would
+		 * already have been removed from the list. Check is someone is
+		 * already waiting, in which case we wait but do not free.
+		 */
+		if (refcount_read(&bond->refs) > 1)
+			do_detach = false;
+
+		refcount_inc(&bond->refs);
+		wait_event_lock_irq(bond->mm_exit_wq, !bond->mm_exit_active,
+				    iommu_sva_lock);
+		if (!do_detach)
+			return;
+
+	} else if (!refcount_dec_and_test(&bond->refs)) {
+		/* unbind() is waiting to free the bond */
+		return;
+	}
+
 	list_for_each_entry(tmp, &domain->mm_list, domain_head) {
 		if (tmp->io_mm == bond->io_mm && tmp->dev != bond->dev) {
 			detach_domain = false;
@@ -298,6 +379,129 @@ static void io_mm_detach_locked(struct iommu_bond *bond)
 	kfree(bond);
 }
 
+static int iommu_signal_mm_exit(struct iommu_bond *bond)
+{
+	struct device *dev = bond->dev;
+	struct io_mm *io_mm = bond->io_mm;
+	struct iommu_sva_param *param = dev->iommu_param->sva_param;
+
+	/*
+	 * We can't hold the device's param_lock. If we did and the device
+	 * driver used a global lock around io_mm, we would risk getting the
+	 * following deadlock:
+	 *
+	 *   exit_mm()                 |  Shutdown SVA
+	 *    mutex_lock(param->lock)  |   mutex_lock(glob lock)
+	 *     param->mm_exit()        |    sva_device_shutdown()
+	 *      mutex_lock(glob lock)  |     mutex_lock(param->lock)
+	 *
+	 * Fortunately unbind() waits for us to finish, and sva_device_shutdown
+	 * requires that any bond is removed, so we can safely access mm_exit
+	 * and drvdata without taking any lock.
+	 */
+	if (!param || !param->mm_exit)
+		return 0;
+
+	return param->mm_exit(dev, io_mm->pasid, bond->drvdata);
+}
+
+/* Called when the mm exits. Can race with unbind(). */
+static void iommu_notifier_release(struct mmu_notifier *mn, struct mm_struct *mm)
+{
+	struct iommu_bond *bond, *next;
+	struct io_mm *io_mm = container_of(mn, struct io_mm, notifier);
+
+	/*
+	 * If the mm is exiting then devices are still bound to the io_mm.
+	 * A few things need to be done before it is safe to release:
+	 *
+	 * - As the mmu notifier doesn't hold any reference to the io_mm when
+	 *   calling ->release(), try to take a reference.
+	 * - Tell the device driver to stop using this PASID.
+	 * - Clear the PASID table and invalidate TLBs.
+	 * - Drop all references to this io_mm by freeing the bonds.
+	 */
+	spin_lock(&iommu_sva_lock);
+	if (!io_mm_get_locked(io_mm)) {
+		/* Someone's already taking care of it. */
+		spin_unlock(&iommu_sva_lock);
+		return;
+	}
+
+	list_for_each_entry_safe(bond, next, &io_mm->devices, mm_head) {
+		/*
+		 * Release the lock to let the handler sleep. We need to be
+		 * careful about concurrent modifications to the list and to the
+		 * bond. Tell unbind() not to free the bond until we're done.
+		 */
+		bond->mm_exit_active = true;
+		spin_unlock(&iommu_sva_lock);
+
+		if (iommu_signal_mm_exit(bond))
+			dev_WARN(bond->dev, "possible leak of PASID %u",
+				 io_mm->pasid);
+
+		spin_lock(&iommu_sva_lock);
+		next = list_next_entry(bond, mm_head);
+
+		/* If someone is waiting, let them delete the bond now */
+		bond->mm_exit_active = false;
+		wake_up_all(&bond->mm_exit_wq);
+
+		/* Otherwise, do it ourselves */
+		io_mm_detach_locked(bond, false);
+	}
+	spin_unlock(&iommu_sva_lock);
+
+	/*
+	 * We're now reasonably certain that no more fault is being handled for
+	 * this io_mm, since we just flushed them all out of the fault queue.
+	 * Release the last reference to free the io_mm.
+	 */
+	io_mm_put(io_mm);
+}
+
+static void iommu_notifier_invalidate_range(struct mmu_notifier *mn,
+					    struct mm_struct *mm,
+					    unsigned long start,
+					    unsigned long end)
+{
+	struct iommu_bond *bond;
+	struct io_mm *io_mm = container_of(mn, struct io_mm, notifier);
+
+	spin_lock(&iommu_sva_lock);
+	list_for_each_entry(bond, &io_mm->devices, mm_head) {
+		struct iommu_domain *domain = bond->domain;
+
+		domain->ops->mm_invalidate(domain, bond->dev, io_mm, start,
+					   end - start);
+	}
+	spin_unlock(&iommu_sva_lock);
+}
+
+static int iommu_notifier_clear_flush_young(struct mmu_notifier *mn,
+					    struct mm_struct *mm,
+					    unsigned long start,
+					    unsigned long end)
+{
+	iommu_notifier_invalidate_range(mn, mm, start, end);
+	return 0;
+}
+
+static void iommu_notifier_change_pte(struct mmu_notifier *mn,
+				      struct mm_struct *mm,
+				      unsigned long address, pte_t pte)
+{
+	iommu_notifier_invalidate_range(mn, mm, address, address + PAGE_SIZE);
+}
+
+static struct mmu_notifier_ops iommu_mmu_notifier = {
+	.release		= iommu_notifier_release,
+	.clear_flush_young	= iommu_notifier_clear_flush_young,
+	.change_pte		= iommu_notifier_change_pte,
+	.invalidate_range	= iommu_notifier_invalidate_range,
+};
+
 /**
  * iommu_sva_device_init() - Initialize Shared Virtual Addressing for a device
  * @dev: the device
@@ -320,6 +524,12 @@ static void io_mm_detach_locked(struct iommu_bond *bond)
  * The handler gets an opaque pointer corresponding to the drvdata passed as
  * argument of bind().
  *
+ * The @mm_exit handler is allowed to sleep. Be careful about the locks taken in
+ * @mm_exit, because they might lead to deadlocks if they are also held when
+ * dropping references to the mm. Consider the following call chain:
+ *   mutex_lock(A); mmput(mm) -> exit_mm() -> @mm_exit() -> mutex_lock(A)
+ * Using mmput_async() prevents this scenario.
+ *
  * The device should not be performing any DMA while this function is running,
  * otherwise the behavior is undefined.
  *
@@ -484,15 +694,16 @@ int __iommu_sva_unbind_device(struct device *dev, int pasid)
 	if (!param || WARN_ON(!domain))
 		return -EINVAL;
 
-	spin_lock(&iommu_sva_lock);
+	/* spin_lock_irq matches the one in wait_event_lock_irq */
+	spin_lock_irq(&iommu_sva_lock);
 	list_for_each_entry(bond, &param->mm_list, dev_head) {
 		if (bond->io_mm->pasid == pasid) {
-			io_mm_detach_locked(bond);
+			io_mm_detach_locked(bond, true);
 			ret = 0;
 			break;
 		}
 	}
-	spin_unlock(&iommu_sva_lock);
+	spin_unlock_irq(&iommu_sva_lock);
 
 	return ret;
 }
@@ -503,18 +714,25 @@ EXPORT_SYMBOL_GPL(__iommu_sva_unbind_device);
  * @dev: the device
  *
  * When detaching @device from a domain, IOMMU drivers should use this helper.
+ * This function may sleep while waiting for bonds to be released.
  */
 void __iommu_sva_unbind_dev_all(struct device *dev)
 {
 	struct iommu_sva_param *param;
 	struct iommu_bond *bond, *next;
 
+	/*
+	 * io_mm_detach_locked might wait, so we shouldn't call it with the dev
+	 * param lock held. It's fine to read sva_param outside the lock because
+	 * it can only be freed by iommu_sva_device_shutdown when there are no
+	 * more bonds in the list.
+	 */
 	param = dev->iommu_param->sva_param;
 	if (param) {
-		spin_lock(&iommu_sva_lock);
+		spin_lock_irq(&iommu_sva_lock);
 		list_for_each_entry_safe(bond, next, &param->mm_list, dev_head)
-			io_mm_detach_locked(bond);
-		spin_unlock(&iommu_sva_lock);
+			io_mm_detach_locked(bond, true);
+		spin_unlock_irq(&iommu_sva_lock);
 	}
 }
 EXPORT_SYMBOL_GPL(__iommu_sva_unbind_dev_all);
diff --git a/include/linux/iommu.h b/include/linux/iommu.h
index 439c8fffd836..caa6f79785b9 100644
--- a/include/linux/iommu.h
+++ b/include/linux/iommu.h
@@ -24,6 +24,7 @@
 #include <linux/types.h>
 #include <linux/errno.h>
 #include <linux/err.h>
+#include <linux/mmu_notifier.h>
 #include <linux/of.h>
 #include <uapi/linux/iommu.h>
 
@@ -111,10 +112,15 @@ struct io_mm {
 	unsigned long		flags;
 	struct list_head	devices;
 	struct kref		kref;
+#if defined(CONFIG_MMU_NOTIFIER)
+	struct mmu_notifier	notifier;
+#endif
 	struct mm_struct	*mm;
 
 	/* Release callback for this mm */
 	void (*release)(struct io_mm *io_mm);
+	/* For postponed release */
+	struct rcu_head		rcu;
 };
 
 enum iommu_cap {
@@ -249,6 +255,7 @@ struct iommu_sva_param {
  * @mm_attach: attach io_mm to a device. Install PASID entry if necessary
  * @mm_detach: detach io_mm from a device. Remove PASID entry and
  *             flush associated TLB entries.
+ * @mm_invalidate: Invalidate a range of mappings for an mm
  * @map: map a physically contiguous memory region to an iommu domain
  * @unmap: unmap a physically contiguous memory region from an iommu domain
  * @map_sg: map a scatter-gather list of physically contiguous memory chunks
@@ -298,6 +305,9 @@ struct iommu_ops {
 			 struct io_mm *io_mm, bool attach_domain);
 	void (*mm_detach)(struct iommu_domain *domain, struct device *dev,
 			  struct io_mm *io_mm, bool detach_domain);
+	void (*mm_invalidate)(struct iommu_domain *domain, struct device *dev,
+			      struct io_mm *io_mm, unsigned long vaddr,
+			      size_t size);
 	int (*map)(struct iommu_domain *domain, unsigned long iova,
 		   phys_addr_t paddr, size_t size, int prot);
 	size_t (*unmap)(struct iommu_domain *domain, unsigned long iova,
-- 
2.17.0
