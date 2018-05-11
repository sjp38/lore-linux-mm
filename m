Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id F0C496B06CD
	for <linux-mm@kvack.org>; Fri, 11 May 2018 15:11:14 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id v10-v6so4294444oth.16
        for <linux-mm@kvack.org>; Fri, 11 May 2018 12:11:14 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a20-v6si1255842oih.294.2018.05.11.12.11.13
        for <linux-mm@kvack.org>;
        Fri, 11 May 2018 12:11:14 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: [PATCH v2 40/40] iommu/arm-smmu-v3: Add support for PCI PASID
Date: Fri, 11 May 2018 20:06:41 +0100
Message-Id: <20180511190641.23008-41-jean-philippe.brucker@arm.com>
In-Reply-To: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com

Enable PASID for PCI devices that support it. Unlike PRI, we can't enable
PASID lazily in iommu_sva_device_init(), because it has to be enabled
before ATS, and because we have to allocate substream tables early.

Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
---
 drivers/iommu/arm-smmu-v3.c | 54 +++++++++++++++++++++++++++++++++++++
 1 file changed, 54 insertions(+)

diff --git a/drivers/iommu/arm-smmu-v3.c b/drivers/iommu/arm-smmu-v3.c
index 0edbb8d19579..ac6e69f25893 100644
--- a/drivers/iommu/arm-smmu-v3.c
+++ b/drivers/iommu/arm-smmu-v3.c
@@ -2542,6 +2542,52 @@ static bool arm_smmu_sid_in_range(struct arm_smmu_device *smmu, u32 sid)
 	return sid < limit;
 }
 
+static int arm_smmu_enable_pasid(struct arm_smmu_master_data *master)
+{
+	int ret;
+	int features;
+	u8 pasid_bits;
+	int num_pasids;
+	struct pci_dev *pdev;
+
+	if (!dev_is_pci(master->dev))
+		return -ENOSYS;
+
+	pdev = to_pci_dev(master->dev);
+
+	features = pci_pasid_features(pdev);
+	if (features < 0)
+		return -ENOSYS;
+
+	num_pasids = pci_max_pasids(pdev);
+	if (num_pasids <= 0)
+		return -ENOSYS;
+
+	pasid_bits = min_t(u8, ilog2(num_pasids), master->smmu->ssid_bits);
+
+	dev_dbg(&pdev->dev, "device supports %#x PASID bits [%s%s]\n", pasid_bits,
+		(features & PCI_PASID_CAP_EXEC) ? "x" : "",
+		(features & PCI_PASID_CAP_PRIV) ? "p" : "");
+
+	ret = pci_enable_pasid(pdev, features);
+	return ret ? ret : pasid_bits;
+}
+
+static void arm_smmu_disable_pasid(struct arm_smmu_master_data *master)
+{
+	struct pci_dev *pdev;
+
+	if (!dev_is_pci(master->dev))
+		return;
+
+	pdev = to_pci_dev(master->dev);
+
+	if (!pdev->pasid_enabled)
+		return;
+
+	pci_disable_pasid(pdev);
+}
+
 static int arm_smmu_enable_ats(struct arm_smmu_master_data *master)
 {
 	size_t stu;
@@ -2712,6 +2758,11 @@ static int arm_smmu_add_device(struct device *dev)
 		master->ste.can_stall = true;
 	}
 
+	/* PASID must be enabled before ATS */
+	ret = arm_smmu_enable_pasid(master);
+	if (ret > 0)
+		master->ssid_bits = ret;
+
 	arm_smmu_enable_ats(master);
 
 	ret = iommu_device_link(&smmu->iommu, dev);
@@ -2740,6 +2791,7 @@ static int arm_smmu_add_device(struct device *dev)
 
 err_disable_ats:
 	arm_smmu_disable_ats(master);
+	arm_smmu_disable_pasid(master);
 
 err_free_master:
 	kfree(master);
@@ -2769,7 +2821,9 @@ static void arm_smmu_remove_device(struct device *dev)
 	arm_smmu_remove_master(smmu, master);
 	iommu_device_unlink(&smmu->iommu, dev);
 	arm_smmu_disable_pri(master);
+	/* PASID must be disabled after ATS */
 	arm_smmu_disable_ats(master);
+	arm_smmu_disable_pasid(master);
 	kfree(master);
 	iommu_fwspec_free(dev);
 }
-- 
2.17.0
