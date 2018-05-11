Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 492DC6B06CB
	for <linux-mm@kvack.org>; Fri, 11 May 2018 15:11:04 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id j12-v6so3428916oiw.10
        for <linux-mm@kvack.org>; Fri, 11 May 2018 12:11:04 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k81-v6si1177289oia.224.2018.05.11.12.11.02
        for <linux-mm@kvack.org>;
        Fri, 11 May 2018 12:11:03 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: [PATCH v2 38/40] PCI: Make "PRG Response PASID Required" handling common
Date: Fri, 11 May 2018 20:06:39 +0100
Message-Id: <20180511190641.23008-39-jean-philippe.brucker@arm.com>
In-Reply-To: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com, bhelgaas@google.com

The PASID ECN to the PCIe spec added a bit in the PRI status register that
allows a Function to declare whether a PRG Response should contain the
PASID prefix or not.

Move the helper that accesses it from amd_iommu into the PCI subsystem,
renaming it to be consistent with the current PCI Express specification
(PRPR - PRG Response PASID Required).

Cc: bhelgaas@google.com
Acked-by: Bjorn Helgaas <bhelgaas@google.com>
Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
---
 drivers/iommu/amd_iommu.c     | 19 +------------------
 drivers/pci/ats.c             | 17 +++++++++++++++++
 include/linux/pci-ats.h       |  8 ++++++++
 include/uapi/linux/pci_regs.h |  1 +
 4 files changed, 27 insertions(+), 18 deletions(-)

diff --git a/drivers/iommu/amd_iommu.c b/drivers/iommu/amd_iommu.c
index 8fb8c737fffe..ac0d97fa514f 100644
--- a/drivers/iommu/amd_iommu.c
+++ b/drivers/iommu/amd_iommu.c
@@ -2043,23 +2043,6 @@ static int pdev_iommuv2_enable(struct pci_dev *pdev)
 	return ret;
 }
 
-/* FIXME: Move this to PCI code */
-#define PCI_PRI_TLP_OFF		(1 << 15)
-
-static bool pci_pri_tlp_required(struct pci_dev *pdev)
-{
-	u16 status;
-	int pos;
-
-	pos = pci_find_ext_capability(pdev, PCI_EXT_CAP_ID_PRI);
-	if (!pos)
-		return false;
-
-	pci_read_config_word(pdev, pos + PCI_PRI_STATUS, &status);
-
-	return (status & PCI_PRI_TLP_OFF) ? true : false;
-}
-
 /*
  * If a device is not yet associated with a domain, this function
  * assigns it visible for the hardware
@@ -2088,7 +2071,7 @@ static int attach_device(struct device *dev,
 
 			dev_data->ats.enabled = true;
 			dev_data->ats.qdep    = pci_ats_queue_depth(pdev);
-			dev_data->pri_tlp     = pci_pri_tlp_required(pdev);
+			dev_data->pri_tlp     = pci_prg_resp_requires_prefix(pdev);
 		}
 	} else if (amd_iommu_iotlb_sup &&
 		   pci_enable_ats(pdev, PAGE_SHIFT) == 0) {
diff --git a/drivers/pci/ats.c b/drivers/pci/ats.c
index 89305b569d3d..dc743e2fae7d 100644
--- a/drivers/pci/ats.c
+++ b/drivers/pci/ats.c
@@ -388,3 +388,20 @@ int pci_max_pasids(struct pci_dev *pdev)
 }
 EXPORT_SYMBOL_GPL(pci_max_pasids);
 #endif /* CONFIG_PCI_PASID */
+
+#if defined(CONFIG_PCI_PASID) && defined(CONFIG_PCI_PRI)
+bool pci_prg_resp_requires_prefix(struct pci_dev *pdev)
+{
+	u16 status;
+	int pos;
+
+	pos = pci_find_ext_capability(pdev, PCI_EXT_CAP_ID_PRI);
+	if (!pos)
+		return false;
+
+	pci_read_config_word(pdev, pos + PCI_PRI_STATUS, &status);
+
+	return !!(status & PCI_PRI_STATUS_PRPR);
+}
+EXPORT_SYMBOL_GPL(pci_prg_resp_requires_prefix);
+#endif /* CONFIG_PCI_PASID && CONFIG_PCI_PRI */
diff --git a/include/linux/pci-ats.h b/include/linux/pci-ats.h
index 7c4b8e27268c..1825ca2c9bf4 100644
--- a/include/linux/pci-ats.h
+++ b/include/linux/pci-ats.h
@@ -68,5 +68,13 @@ static inline int pci_max_pasids(struct pci_dev *pdev)
 
 #endif /* CONFIG_PCI_PASID */
 
+#if defined(CONFIG_PCI_PASID) && defined(CONFIG_PCI_PRI)
+bool pci_prg_resp_requires_prefix(struct pci_dev *pdev);
+#else
+static inline bool pci_prg_resp_requires_prefix(struct pci_dev *pdev)
+{
+	return false;
+}
+#endif /* CONFIG_PCI_PASID && CONFIG_PCI_PRI */
 
 #endif /* LINUX_PCI_ATS_H*/
diff --git a/include/uapi/linux/pci_regs.h b/include/uapi/linux/pci_regs.h
index 103ba797a8f3..f9a11a13131c 100644
--- a/include/uapi/linux/pci_regs.h
+++ b/include/uapi/linux/pci_regs.h
@@ -871,6 +871,7 @@
 #define  PCI_PRI_STATUS_RF	0x001	/* Response Failure */
 #define  PCI_PRI_STATUS_UPRGI	0x002	/* Unexpected PRG index */
 #define  PCI_PRI_STATUS_STOPPED	0x100	/* PRI Stopped */
+#define  PCI_PRI_STATUS_PRPR	0x8000	/* PRG Response requires PASID prefix */
 #define PCI_PRI_MAX_REQ		0x08	/* PRI max reqs supported */
 #define PCI_PRI_ALLOC_REQ	0x0c	/* PRI max reqs allowed */
 #define PCI_EXT_CAP_PRI_SIZEOF	16
-- 
2.17.0
