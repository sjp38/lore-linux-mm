Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4907A6B0683
	for <linux-mm@kvack.org>; Fri, 11 May 2018 15:07:55 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j12-v6so3421608oiw.10
        for <linux-mm@kvack.org>; Fri, 11 May 2018 12:07:55 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w91-v6si1353285otb.77.2018.05.11.12.07.54
        for <linux-mm@kvack.org>;
        Fri, 11 May 2018 12:07:54 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: [PATCH v2 04/40] iommu/sva: Add a mm_exit callback for device drivers
Date: Fri, 11 May 2018 20:06:05 +0100
Message-Id: <20180511190641.23008-5-jean-philippe.brucker@arm.com>
In-Reply-To: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com

When an mm exits, devices that were bound to it must stop performing DMA
on its PASID. Let device drivers register a callback to be notified on mm
exit. Add the callback to the sva_param structure attached to struct
device.

Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>

---
v1->v2: use iommu_sva_device_init instead of a separate function
---
 drivers/iommu/iommu-sva.c | 11 ++++++++++-
 include/linux/iommu.h     |  9 +++++++--
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/drivers/iommu/iommu-sva.c b/drivers/iommu/iommu-sva.c
index 6ac679c48f3c..0700893c679d 100644
--- a/drivers/iommu/iommu-sva.c
+++ b/drivers/iommu/iommu-sva.c
@@ -303,6 +303,7 @@ static void io_mm_detach_locked(struct iommu_bond *bond)
  * @dev: the device
  * @features: bitmask of features that need to be initialized
  * @max_pasid: max PASID value supported by the device
+ * @mm_exit: callback to notify the device driver of an mm exiting
  *
  * Users of the bind()/unbind() API must call this function to initialize all
  * features required for SVA.
@@ -313,13 +314,20 @@ static void io_mm_detach_locked(struct iommu_bond *bond)
  * description. Setting @max_pasid to a non-zero value smaller than this limit
  * overrides it.
  *
+ * If the driver intends to share process address spaces, it should pass a valid
+ * @mm_exit handler. Otherwise @mm_exit can be NULL. After @mm_exit returns, the
+ * device must not issue any more transaction with the PASID given as argument.
+ * The handler gets an opaque pointer corresponding to the drvdata passed as
+ * argument of bind().
+ *
  * The device should not be performing any DMA while this function is running,
  * otherwise the behavior is undefined.
  *
  * Return 0 if initialization succeeded, or an error.
  */
 int iommu_sva_device_init(struct device *dev, unsigned long features,
-			  unsigned int max_pasid)
+			  unsigned int max_pasid,
+			  iommu_mm_exit_handler_t mm_exit)
 {
 	int ret;
 	struct iommu_sva_param *param;
@@ -337,6 +345,7 @@ int iommu_sva_device_init(struct device *dev, unsigned long features,
 
 	param->features		= features;
 	param->max_pasid	= max_pasid;
+	param->mm_exit		= mm_exit;
 	INIT_LIST_HEAD(&param->mm_list);
 
 	/*
diff --git a/include/linux/iommu.h b/include/linux/iommu.h
index d5f21719a5a0..439c8fffd836 100644
--- a/include/linux/iommu.h
+++ b/include/linux/iommu.h
@@ -61,6 +61,7 @@ struct iommu_fault_event;
 typedef int (*iommu_fault_handler_t)(struct iommu_domain *,
 			struct device *, unsigned long, int, void *);
 typedef int (*iommu_dev_fault_handler_t)(struct iommu_fault_event *, void *);
+typedef int (*iommu_mm_exit_handler_t)(struct device *dev, int pasid, void *);
 
 struct iommu_domain_geometry {
 	dma_addr_t aperture_start; /* First address that can be mapped    */
@@ -231,6 +232,7 @@ struct iommu_sva_param {
 	unsigned int min_pasid;
 	unsigned int max_pasid;
 	struct list_head mm_list;
+	iommu_mm_exit_handler_t mm_exit;
 };
 
 /**
@@ -980,17 +982,20 @@ static inline int iommu_sva_unbind_device(struct device *dev, int pasid)
 
 #ifdef CONFIG_IOMMU_SVA
 extern int iommu_sva_device_init(struct device *dev, unsigned long features,
-				 unsigned int max_pasid);
+				 unsigned int max_pasid,
+				 iommu_mm_exit_handler_t mm_exit);
 extern int iommu_sva_device_shutdown(struct device *dev);
 extern int __iommu_sva_bind_device(struct device *dev, struct mm_struct *mm,
 				   int *pasid, unsigned long flags,
 				   void *drvdata);
 extern int __iommu_sva_unbind_device(struct device *dev, int pasid);
 extern void __iommu_sva_unbind_dev_all(struct device *dev);
+
 #else /* CONFIG_IOMMU_SVA */
 static inline int iommu_sva_device_init(struct device *dev,
 					unsigned long features,
-					unsigned int max_pasid)
+					unsigned int max_pasid,
+					iommu_mm_exit_handler_t mm_exit)
 {
 	return -ENODEV;
 }
-- 
2.17.0
