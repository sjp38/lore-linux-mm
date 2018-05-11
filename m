Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id EA5406B06BC
	for <linux-mm@kvack.org>; Fri, 11 May 2018 15:10:24 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id q4-v6so4307598ote.6
        for <linux-mm@kvack.org>; Fri, 11 May 2018 12:10:24 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e8-v6si1207391oig.238.2018.05.11.12.10.23
        for <linux-mm@kvack.org>;
        Fri, 11 May 2018 12:10:23 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: [PATCH v2 31/40] iommu/arm-smmu-v3: Improve add_device error handling
Date: Fri, 11 May 2018 20:06:32 +0100
Message-Id: <20180511190641.23008-32-jean-philippe.brucker@arm.com>
In-Reply-To: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com

As add_device becomes more likely to fail when adding new features, let it
clean up behind itself. The iommu_bus_init function does call
remove_device on error, but other sites (e.g. of_iommu) do not.

Don't free level-2 stream tables because we'd have to track if we
allocated each of them or if they are used by other endpoints. It's not
worth the hassle since they are managed resources.

Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>

---
v1->v2: new
---
 drivers/iommu/arm-smmu-v3.c | 36 ++++++++++++++++++++++++++++--------
 1 file changed, 28 insertions(+), 8 deletions(-)

diff --git a/drivers/iommu/arm-smmu-v3.c b/drivers/iommu/arm-smmu-v3.c
index 5d57f41f79b4..d5f3875abfb9 100644
--- a/drivers/iommu/arm-smmu-v3.c
+++ b/drivers/iommu/arm-smmu-v3.c
@@ -2123,26 +2123,43 @@ static int arm_smmu_add_device(struct device *dev)
 	for (i = 0; i < fwspec->num_ids; i++) {
 		u32 sid = fwspec->ids[i];
 
-		if (!arm_smmu_sid_in_range(smmu, sid))
-			return -ERANGE;
+		if (!arm_smmu_sid_in_range(smmu, sid)) {
+			ret = -ERANGE;
+			goto err_free_master;
+		}
 
 		/* Ensure l2 strtab is initialised */
 		if (smmu->features & ARM_SMMU_FEAT_2_LVL_STRTAB) {
 			ret = arm_smmu_init_l2_strtab(smmu, sid);
 			if (ret)
-				return ret;
+				goto err_free_master;
 		}
 	}
 
 	master->ssid_bits = min(smmu->ssid_bits, fwspec->num_pasid_bits);
 
+	ret = iommu_device_link(&smmu->iommu, dev);
+	if (ret)
+		goto err_free_master;
+
 	group = iommu_group_get_for_dev(dev);
-	if (!IS_ERR(group)) {
-		iommu_group_put(group);
-		iommu_device_link(&smmu->iommu, dev);
+	if (IS_ERR(group)) {
+		ret = PTR_ERR(group);
+		goto err_unlink;
 	}
 
-	return PTR_ERR_OR_ZERO(group);
+	iommu_group_put(group);
+
+	return 0;
+
+err_unlink:
+	iommu_device_unlink(&smmu->iommu, dev);
+
+err_free_master:
+	kfree(master);
+	fwspec->iommu_priv = NULL;
+
+	return ret;
 }
 
 static void arm_smmu_remove_device(struct device *dev)
@@ -2155,9 +2172,12 @@ static void arm_smmu_remove_device(struct device *dev)
 		return;
 
 	master = fwspec->iommu_priv;
+	if (!master)
+		return;
+
 	smmu = master->smmu;
 	iopf_queue_remove_device(dev);
-	if (master && master->ste.assigned)
+	if (master->ste.assigned)
 		arm_smmu_detach_dev(dev);
 	iommu_group_remove_device(dev);
 	iommu_device_unlink(&smmu->iommu, dev);
-- 
2.17.0
