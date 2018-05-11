Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id EEEA26B0688
	for <linux-mm@kvack.org>; Fri, 11 May 2018 15:08:22 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u10-v6so3426035oie.8
        for <linux-mm@kvack.org>; Fri, 11 May 2018 12:08:22 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z68-v6si1388380otb.328.2018.05.11.12.08.21
        for <linux-mm@kvack.org>;
        Fri, 11 May 2018 12:08:21 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: [PATCH v2 09/40] iommu/sva: Register page fault handler
Date: Fri, 11 May 2018 20:06:10 +0100
Message-Id: <20180511190641.23008-10-jean-philippe.brucker@arm.com>
In-Reply-To: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com

Let users call iommu_sva_device_init() with the IOMMU_SVA_FEAT_IOPF flag,
that enables the I/O Page Fault queue. The IOMMU driver checks is the
device supports a form of page fault, in which case they add the device to
a fault queue. If the device doesn't support page faults, the IOMMU driver
aborts iommu_sva_device_init().

The fault queue must be flushed before any io_mm is freed, to make sure
that its PASID isn't used in any fault queue, and can be reallocated.
Add iopf_queue_flush() calls in a few strategic locations.

Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>

---
v1->v2: new
---
 drivers/iommu/iommu-sva.c | 36 ++++++++++++++++++++++++++++++++----
 drivers/iommu/iommu.c     |  6 +++---
 include/linux/iommu.h     |  2 ++
 3 files changed, 37 insertions(+), 7 deletions(-)

diff --git a/drivers/iommu/iommu-sva.c b/drivers/iommu/iommu-sva.c
index 5abe0f0b445c..e98b994c15f1 100644
--- a/drivers/iommu/iommu-sva.c
+++ b/drivers/iommu/iommu-sva.c
@@ -441,6 +441,8 @@ static void iommu_notifier_release(struct mmu_notifier *mn, struct mm_struct *mm
 			dev_WARN(bond->dev, "possible leak of PASID %u",
 				 io_mm->pasid);
 
+		iopf_queue_flush_dev(bond->dev);
+
 		spin_lock(&iommu_sva_lock);
 		next = list_next_entry(bond, mm_head);
 
@@ -518,6 +520,9 @@ static struct mmu_notifier_ops iommu_mmu_notifier = {
  * description. Setting @max_pasid to a non-zero value smaller than this limit
  * overrides it.
  *
+ * If the device should support recoverable I/O Page Faults (e.g. PCI PRI), the
+ * IOMMU_SVA_FEAT_IOPF feature must be requested.
+ *
  * If the driver intends to share process address spaces, it should pass a valid
  * @mm_exit handler. Otherwise @mm_exit can be NULL. After @mm_exit returns, the
  * device must not issue any more transaction with the PASID given as argument.
@@ -546,12 +551,21 @@ int iommu_sva_device_init(struct device *dev, unsigned long features,
 	if (!domain || !domain->ops->sva_device_init)
 		return -ENODEV;
 
-	if (features)
+	if (features & ~IOMMU_SVA_FEAT_IOPF)
 		return -EINVAL;
 
+	if (features & IOMMU_SVA_FEAT_IOPF) {
+		ret = iommu_register_device_fault_handler(dev, iommu_queue_iopf,
+							  dev);
+		if (ret)
+			return ret;
+	}
+
 	param = kzalloc(sizeof(*param), GFP_KERNEL);
-	if (!param)
-		return -ENOMEM;
+	if (!param) {
+		ret = -ENOMEM;
+		goto err_remove_handler;
+	}
 
 	param->features		= features;
 	param->max_pasid	= max_pasid;
@@ -584,6 +598,9 @@ int iommu_sva_device_init(struct device *dev, unsigned long features,
 err_free_param:
 	kfree(param);
 
+err_remove_handler:
+	iommu_unregister_device_fault_handler(dev);
+
 	return ret;
 }
 EXPORT_SYMBOL_GPL(iommu_sva_device_init);
@@ -593,7 +610,8 @@ EXPORT_SYMBOL_GPL(iommu_sva_device_init);
  * @dev: the device
  *
  * Disable SVA. Device driver should ensure that the device isn't performing any
- * DMA while this function is running.
+ * DMA while this function is running. In addition all faults should have been
+ * flushed to the IOMMU.
  */
 int iommu_sva_device_shutdown(struct device *dev)
 {
@@ -617,6 +635,8 @@ int iommu_sva_device_shutdown(struct device *dev)
 
 	kfree(param);
 
+	iommu_unregister_device_fault_handler(dev);
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(iommu_sva_device_shutdown);
@@ -694,6 +714,12 @@ int __iommu_sva_unbind_device(struct device *dev, int pasid)
 	if (!param || WARN_ON(!domain))
 		return -EINVAL;
 
+	/*
+	 * Caller stopped the device from issuing PASIDs, now make sure they are
+	 * out of the fault queue.
+	 */
+	iopf_queue_flush_dev(dev);
+
 	/* spin_lock_irq matches the one in wait_event_lock_irq */
 	spin_lock_irq(&iommu_sva_lock);
 	list_for_each_entry(bond, &param->mm_list, dev_head) {
@@ -721,6 +747,8 @@ void __iommu_sva_unbind_dev_all(struct device *dev)
 	struct iommu_sva_param *param;
 	struct iommu_bond *bond, *next;
 
+	iopf_queue_flush_dev(dev);
+
 	/*
 	 * io_mm_detach_locked might wait, so we shouldn't call it with the dev
 	 * param lock held. It's fine to read sva_param outside the lock because
diff --git a/drivers/iommu/iommu.c b/drivers/iommu/iommu.c
index 333801e1519c..13f705df0725 100644
--- a/drivers/iommu/iommu.c
+++ b/drivers/iommu/iommu.c
@@ -2278,9 +2278,9 @@ EXPORT_SYMBOL_GPL(iommu_fwspec_add_ids);
  * iommu_sva_device_init() must be called first, to initialize the required SVA
  * features. @flags is a subset of these features.
  *
- * The caller must pin down using get_user_pages*() all mappings shared with the
- * device. mlock() isn't sufficient, as it doesn't prevent minor page faults
- * (e.g. copy-on-write).
+ * If IOMMU_SVA_FEAT_IOPF isn't requested, the caller must pin down using
+ * get_user_pages*() all mappings shared with the device. mlock() isn't
+ * sufficient, as it doesn't prevent minor page faults (e.g. copy-on-write).
  *
  * On success, 0 is returned and @pasid contains a valid ID. Otherwise, an error
  * is returned.
diff --git a/include/linux/iommu.h b/include/linux/iommu.h
index fad3a60e1c14..933100678f64 100644
--- a/include/linux/iommu.h
+++ b/include/linux/iommu.h
@@ -64,6 +64,8 @@ typedef int (*iommu_fault_handler_t)(struct iommu_domain *,
 typedef int (*iommu_dev_fault_handler_t)(struct iommu_fault_event *, void *);
 typedef int (*iommu_mm_exit_handler_t)(struct device *dev, int pasid, void *);
 
+#define IOMMU_SVA_FEAT_IOPF		(1 << 0)
+
 struct iommu_domain_geometry {
 	dma_addr_t aperture_start; /* First address that can be mapped    */
 	dma_addr_t aperture_end;   /* Last address that can be mapped     */
-- 
2.17.0
