Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1A1806B0685
	for <linux-mm@kvack.org>; Fri, 11 May 2018 15:08:06 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id c23-v6so3488207oic.2
        for <linux-mm@kvack.org>; Fri, 11 May 2018 12:08:06 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 188-v6si1199342oia.429.2018.05.11.12.08.05
        for <linux-mm@kvack.org>;
        Fri, 11 May 2018 12:08:05 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: [PATCH v2 06/40] iommu/sva: Search mm by PASID
Date: Fri, 11 May 2018 20:06:07 +0100
Message-Id: <20180511190641.23008-7-jean-philippe.brucker@arm.com>
In-Reply-To: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com

The fault handler will need to find an mm given its PASID. This is the
reason we have an IDR for storing address spaces, so hook it up.

Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
---
 drivers/iommu/iommu-sva.c | 26 ++++++++++++++++++++++++++
 include/linux/iommu.h     |  6 ++++++
 2 files changed, 32 insertions(+)

diff --git a/drivers/iommu/iommu-sva.c b/drivers/iommu/iommu-sva.c
index e9afae2537a2..5abe0f0b445c 100644
--- a/drivers/iommu/iommu-sva.c
+++ b/drivers/iommu/iommu-sva.c
@@ -736,3 +736,29 @@ void __iommu_sva_unbind_dev_all(struct device *dev)
 	}
 }
 EXPORT_SYMBOL_GPL(__iommu_sva_unbind_dev_all);
+
+/**
+ * iommu_sva_find() - Find mm associated to the given PASID
+ * @pasid: Process Address Space ID assigned to the mm
+ *
+ * Returns the mm corresponding to this PASID, or NULL if not found. A reference
+ * to the mm is taken, and must be released with mmput().
+ */
+struct mm_struct *iommu_sva_find(int pasid)
+{
+	struct io_mm *io_mm;
+	struct mm_struct *mm = NULL;
+
+	spin_lock(&iommu_sva_lock);
+	io_mm = idr_find(&iommu_pasid_idr, pasid);
+	if (io_mm && io_mm_get_locked(io_mm)) {
+		if (mmget_not_zero(io_mm->mm))
+			mm = io_mm->mm;
+
+		io_mm_put_locked(io_mm);
+	}
+	spin_unlock(&iommu_sva_lock);
+
+	return mm;
+}
+EXPORT_SYMBOL_GPL(iommu_sva_find);
diff --git a/include/linux/iommu.h b/include/linux/iommu.h
index caa6f79785b9..faf3390ce89d 100644
--- a/include/linux/iommu.h
+++ b/include/linux/iommu.h
@@ -1001,6 +1001,7 @@ extern int __iommu_sva_bind_device(struct device *dev, struct mm_struct *mm,
 extern int __iommu_sva_unbind_device(struct device *dev, int pasid);
 extern void __iommu_sva_unbind_dev_all(struct device *dev);
 
+extern struct mm_struct *iommu_sva_find(int pasid);
 #else /* CONFIG_IOMMU_SVA */
 static inline int iommu_sva_device_init(struct device *dev,
 					unsigned long features,
@@ -1030,6 +1031,11 @@ static inline int __iommu_sva_unbind_device(struct device *dev, int pasid)
 static inline void __iommu_sva_unbind_dev_all(struct device *dev)
 {
 }
+
+static inline struct mm_struct *iommu_sva_find(int pasid)
+{
+	return NULL;
+}
 #endif /* CONFIG_IOMMU_SVA */
 
 #endif /* __LINUX_IOMMU_H */
-- 
2.17.0
