Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 34D356B026D
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 18:42:48 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v78so16172135pgb.4
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 15:42:48 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id v22si2019808pfd.212.2017.10.06.15.42.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Oct 2017 15:42:47 -0700 (PDT)
Subject: [PATCH v7 12/12] tools/testing/nvdimm: enable rdma unit tests
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 06 Oct 2017 15:36:22 -0700
Message-ID: <150732938240.22363.4660628491483540886.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150732931273.22363.8436792888326501071.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150732931273.22363.8436792888326501071.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, linux-rdma@vger.kernel.org

Provide a mock dma_has_iommu() for the ibverbs core. Enable
ib_umem_get() to satisfy its DAX safety checks for a controlled test.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 tools/testing/nvdimm/Kbuild         |   31 +++++++++++++++++++++++++++++++
 tools/testing/nvdimm/config_check.c |    2 ++
 tools/testing/nvdimm/test/iomap.c   |    6 ++++++
 3 files changed, 39 insertions(+)

diff --git a/tools/testing/nvdimm/Kbuild b/tools/testing/nvdimm/Kbuild
index d870520da68b..e4ee7f482ac0 100644
--- a/tools/testing/nvdimm/Kbuild
+++ b/tools/testing/nvdimm/Kbuild
@@ -15,11 +15,13 @@ ldflags-y += --wrap=insert_resource
 ldflags-y += --wrap=remove_resource
 ldflags-y += --wrap=acpi_evaluate_object
 ldflags-y += --wrap=acpi_evaluate_dsm
+ldflags-y += --wrap=dma_has_iommu
 
 DRIVERS := ../../../drivers
 NVDIMM_SRC := $(DRIVERS)/nvdimm
 ACPI_SRC := $(DRIVERS)/acpi/nfit
 DAX_SRC := $(DRIVERS)/dax
+IBCORE := $(DRIVERS)/infiniband/core
 ccflags-y := -I$(src)/$(NVDIMM_SRC)/
 
 obj-$(CONFIG_LIBNVDIMM) += libnvdimm.o
@@ -33,6 +35,7 @@ obj-$(CONFIG_DAX) += dax.o
 endif
 obj-$(CONFIG_DEV_DAX) += device_dax.o
 obj-$(CONFIG_DEV_DAX_PMEM) += dax_pmem.o
+obj-$(CONFIG_INFINIBAND) += ib_core.o
 
 nfit-y := $(ACPI_SRC)/core.o
 nfit-$(CONFIG_X86_MCE) += $(ACPI_SRC)/mce.o
@@ -75,4 +78,32 @@ libnvdimm-$(CONFIG_NVDIMM_PFN) += $(NVDIMM_SRC)/pfn_devs.o
 libnvdimm-$(CONFIG_NVDIMM_DAX) += $(NVDIMM_SRC)/dax_devs.o
 libnvdimm-y += config_check.o
 
+ib_core-y := $(IBCORE)/packer.o
+ib_core-y += $(IBCORE)/ud_header.o
+ib_core-y += $(IBCORE)/verbs.o
+ib_core-y += $(IBCORE)/cq.o
+ib_core-y += $(IBCORE)/rw.o
+ib_core-y += $(IBCORE)/sysfs.o
+ib_core-y += $(IBCORE)/device.o
+ib_core-y += $(IBCORE)/fmr_pool.o
+ib_core-y += $(IBCORE)/cache.o
+ib_core-y += $(IBCORE)/netlink.o
+ib_core-y += $(IBCORE)/roce_gid_mgmt.o
+ib_core-y += $(IBCORE)/mr_pool.o
+ib_core-y += $(IBCORE)/addr.o
+ib_core-y += $(IBCORE)/sa_query.o
+ib_core-y += $(IBCORE)/multicast.o
+ib_core-y += $(IBCORE)/mad.o
+ib_core-y += $(IBCORE)/smi.o
+ib_core-y += $(IBCORE)/agent.o
+ib_core-y += $(IBCORE)/mad_rmpp.o
+ib_core-y += $(IBCORE)/security.o
+ib_core-y += $(IBCORE)/nldev.o
+
+ib_core-$(CONFIG_INFINIBAND_USER_MEM) += $(IBCORE)/umem.o
+ib_core-$(CONFIG_INFINIBAND_ON_DEMAND_PAGING) += $(IBCORE)/umem_odp.o
+ib_core-$(CONFIG_INFINIBAND_ON_DEMAND_PAGING) += $(IBCORE)/umem_rbtree.o
+ib_core-$(CONFIG_CGROUP_RDMA) += $(IBCORE)/cgroup.o
+ib_core-y += config_check.o
+
 obj-m += test/
diff --git a/tools/testing/nvdimm/config_check.c b/tools/testing/nvdimm/config_check.c
index 7dc5a0af9b54..33e7c805bfd6 100644
--- a/tools/testing/nvdimm/config_check.c
+++ b/tools/testing/nvdimm/config_check.c
@@ -14,4 +14,6 @@ void check(void)
 	BUILD_BUG_ON(!IS_MODULE(CONFIG_ACPI_NFIT));
 	BUILD_BUG_ON(!IS_MODULE(CONFIG_DEV_DAX));
 	BUILD_BUG_ON(!IS_MODULE(CONFIG_DEV_DAX_PMEM));
+	BUILD_BUG_ON(!IS_ENABLED(CONFIG_INFINIBAND_USER_MEM));
+	BUILD_BUG_ON(!IS_MODULE(CONFIG_INFINIBAND));
 }
diff --git a/tools/testing/nvdimm/test/iomap.c b/tools/testing/nvdimm/test/iomap.c
index e1f75a1914a1..1c240328ee5b 100644
--- a/tools/testing/nvdimm/test/iomap.c
+++ b/tools/testing/nvdimm/test/iomap.c
@@ -388,4 +388,10 @@ union acpi_object * __wrap_acpi_evaluate_dsm(acpi_handle handle, const guid_t *g
 }
 EXPORT_SYMBOL(__wrap_acpi_evaluate_dsm);
 
+bool __wrap_dma_has_iommu(struct device *dev)
+{
+	return true;
+}
+EXPORT_SYMBOL(__wrap_dma_has_iommu);
+
 MODULE_LICENSE("GPL v2");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
