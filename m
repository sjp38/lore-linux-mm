Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0FB776B0276
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 10:56:44 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a7so75030123pfj.3
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 07:56:44 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id z19si5263708pfi.576.2017.10.10.07.56.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 07:56:42 -0700 (PDT)
Subject: [PATCH v8 14/14] tools/testing/nvdimm: enable rdma unit tests
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 10 Oct 2017 07:50:17 -0700
Message-ID: <150764701713.16882.9840394340145664403.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150764693502.16882.15848797003793552156.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150764693502.16882.15848797003793552156.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-rdma@vger.kernel.org, linux-api@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org

Provide a mock dma_get_iommu_domain() for the ibverbs core. Enable
ib_umem_get() to satisfy its DAX safety checks for a controlled test.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 tools/testing/nvdimm/Kbuild         |   31 +++++++++++++++++++++++++++++++
 tools/testing/nvdimm/config_check.c |    2 ++
 tools/testing/nvdimm/test/iomap.c   |   14 ++++++++++++++
 3 files changed, 47 insertions(+)

diff --git a/tools/testing/nvdimm/Kbuild b/tools/testing/nvdimm/Kbuild
index d870520da68b..f4a007090950 100644
--- a/tools/testing/nvdimm/Kbuild
+++ b/tools/testing/nvdimm/Kbuild
@@ -15,11 +15,13 @@ ldflags-y += --wrap=insert_resource
 ldflags-y += --wrap=remove_resource
 ldflags-y += --wrap=acpi_evaluate_object
 ldflags-y += --wrap=acpi_evaluate_dsm
+ldflags-y += --wrap=dma_get_iommu_domain
 
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
index e1f75a1914a1..1e439b2b01e7 100644
--- a/tools/testing/nvdimm/test/iomap.c
+++ b/tools/testing/nvdimm/test/iomap.c
@@ -17,6 +17,7 @@
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/pfn_t.h>
+#include <linux/iommu.h>
 #include <linux/acpi.h>
 #include <linux/io.h>
 #include <linux/mm.h>
@@ -388,4 +389,17 @@ union acpi_object * __wrap_acpi_evaluate_dsm(acpi_handle handle, const guid_t *g
 }
 EXPORT_SYMBOL(__wrap_acpi_evaluate_dsm);
 
+/*
+ * This assumes that any iommu api routine we would call with this
+ * domain checks for NULL ops and either returns an error or does
+ * nothing.
+ */
+struct iommu_domain *__wrap_dma_get_iommu_domain(struct device *dev)
+{
+	static struct iommu_domain domain;
+
+	return &domain;
+}
+EXPORT_SYMBOL(__wrap_dma_get_iommu_domain);
+
 MODULE_LICENSE("GPL v2");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
