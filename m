Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 024CA6B0258
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 23:56:13 -0400 (EDT)
Received: by pawu10 with SMTP id u10so28484992paw.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 20:56:12 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id by6si1516895pdb.89.2015.08.12.20.56.11
        for <linux-mm@kvack.org>;
        Wed, 12 Aug 2015 20:56:11 -0700 (PDT)
Subject: [RFC PATCH 5/7] libnvdimm,
 e820: make CONFIG_X86_PMEM_LEGACY a tristate option
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 12 Aug 2015 23:50:29 -0400
Message-ID: <20150813035028.36913.25267.stgit@otcpl-skl-sds-2.jf.intel.com>
In-Reply-To: <20150813031253.36913.29580.stgit@otcpl-skl-sds-2.jf.intel.com>
References: <20150813031253.36913.29580.stgit@otcpl-skl-sds-2.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: boaz@plexistor.com, riel@redhat.com, linux-nvdimm@lists.01.org, david@fromorbit.com, mingo@kernel.org, linux-mm@kvack.org, mgorman@suse.de, ross.zwisler@linux.intel.com, torvalds@linux-foundation.org, hch@lst.de

Purely for ease of testing, with this in place we can run the unit test
alongside any tests that depend on the memmap=ss!nn kernel parameter.
The unit test mocking implementation requires that libnvdimm be a module
and not built-in.

A nice side effect is the implementation is a bit more generic as it no
longer depends on <asm/e820.h>.

Cc: Christoph Hellwig <hch@lst.de>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/Kconfig                 |    6 ++-
 arch/x86/include/uapi/asm/e820.h |    2 -
 arch/x86/kernel/Makefile         |    2 -
 arch/x86/kernel/pmem.c           |   79 ++++-------------------------------
 drivers/nvdimm/Makefile          |    3 +
 drivers/nvdimm/e820.c            |   86 ++++++++++++++++++++++++++++++++++++++
 tools/testing/nvdimm/Kbuild      |    4 ++
 7 files changed, 108 insertions(+), 74 deletions(-)
 create mode 100644 drivers/nvdimm/e820.c

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 64829b17980b..5d6994f62c4d 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1439,10 +1439,14 @@ config ILLEGAL_POINTER_VALUE
 
 source "mm/Kconfig"
 
+config X86_PMEM_LEGACY_DEVICE
+	bool
+
 config X86_PMEM_LEGACY
-	bool "Support non-standard NVDIMMs and ADR protected memory"
+	tristate "Support non-standard NVDIMMs and ADR protected memory"
 	depends on PHYS_ADDR_T_64BIT
 	depends on BLK_DEV
+	select X86_PMEM_LEGACY_DEVICE
 	select LIBNVDIMM
 	help
 	  Treat memory marked using the non-standard e820 type of 12 as used
diff --git a/arch/x86/include/uapi/asm/e820.h b/arch/x86/include/uapi/asm/e820.h
index 0f457e6eab18..9dafe59cf6e2 100644
--- a/arch/x86/include/uapi/asm/e820.h
+++ b/arch/x86/include/uapi/asm/e820.h
@@ -37,7 +37,7 @@
 /*
  * This is a non-standardized way to represent ADR or NVDIMM regions that
  * persist over a reboot.  The kernel will ignore their special capabilities
- * unless the CONFIG_X86_PMEM_LEGACY=y option is set.
+ * unless the CONFIG_X86_PMEM_LEGACY option is set.
  *
  * ( Note that older platforms also used 6 for the same type of memory,
  *   but newer versions switched to 12 as 6 was assigned differently.  Some
diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index 0f15af41bd80..ac2bb7e28ba2 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -92,7 +92,7 @@ obj-$(CONFIG_KVM_GUEST)		+= kvm.o kvmclock.o
 obj-$(CONFIG_PARAVIRT)		+= paravirt.o paravirt_patch_$(BITS).o
 obj-$(CONFIG_PARAVIRT_SPINLOCKS)+= paravirt-spinlocks.o
 obj-$(CONFIG_PARAVIRT_CLOCK)	+= pvclock.o
-obj-$(CONFIG_X86_PMEM_LEGACY)	+= pmem.o
+obj-$(CONFIG_X86_PMEM_LEGACY_DEVICE) += pmem.o
 
 obj-$(CONFIG_PCSPKR_PLATFORM)	+= pcspeaker.o
 
diff --git a/arch/x86/kernel/pmem.c b/arch/x86/kernel/pmem.c
index 64f90f53bb85..4f00b63d7ff3 100644
--- a/arch/x86/kernel/pmem.c
+++ b/arch/x86/kernel/pmem.c
@@ -3,80 +3,17 @@
  * Copyright (c) 2015, Intel Corporation.
  */
 #include <linux/platform_device.h>
-#include <linux/libnvdimm.h>
 #include <linux/module.h>
-#include <asm/e820.h>
-
-static void e820_pmem_release(struct device *dev)
-{
-	struct nvdimm_bus *nvdimm_bus = dev->platform_data;
-
-	if (nvdimm_bus)
-		nvdimm_bus_unregister(nvdimm_bus);
-}
-
-static struct platform_device e820_pmem = {
-	.name = "e820_pmem",
-	.id = -1,
-	.dev = {
-		.release = e820_pmem_release,
-	},
-};
-
-static const struct attribute_group *e820_pmem_attribute_groups[] = {
-	&nvdimm_bus_attribute_group,
-	NULL,
-};
-
-static const struct attribute_group *e820_pmem_region_attribute_groups[] = {
-	&nd_region_attribute_group,
-	&nd_device_attribute_group,
-	NULL,
-};
 
 static __init int register_e820_pmem(void)
 {
-	static struct nvdimm_bus_descriptor nd_desc;
-	struct device *dev = &e820_pmem.dev;
-	struct nvdimm_bus *nvdimm_bus;
-	int rc, i;
-
-	rc = platform_device_register(&e820_pmem);
-	if (rc)
-		return rc;
-
-	nd_desc.attr_groups = e820_pmem_attribute_groups;
-	nd_desc.provider_name = "e820";
-	nvdimm_bus = nvdimm_bus_register(dev, &nd_desc);
-	if (!nvdimm_bus)
-		goto err;
-	dev->platform_data = nvdimm_bus;
-
-	for (i = 0; i < e820.nr_map; i++) {
-		struct e820entry *ei = &e820.map[i];
-		struct resource res = {
-			.flags	= IORESOURCE_MEM,
-			.start	= ei->addr,
-			.end	= ei->addr + ei->size - 1,
-		};
-		struct nd_region_desc ndr_desc;
-
-		if (ei->type != E820_PRAM)
-			continue;
-
-		memset(&ndr_desc, 0, sizeof(ndr_desc));
-		ndr_desc.res = &res;
-		ndr_desc.attr_groups = e820_pmem_region_attribute_groups;
-		ndr_desc.numa_node = NUMA_NO_NODE;
-		if (!nvdimm_pmem_region_create(nvdimm_bus, &ndr_desc))
-			goto err;
-	}
-
-	return 0;
-
- err:
-	dev_err(dev, "failed to register legacy persistent memory ranges\n");
-	platform_device_unregister(&e820_pmem);
-	return -ENXIO;
+	struct platform_device *pdev;
+
+	/*
+	 * See drivers/nvdimm/e820.c for the implementation, this is
+	 * simply here to trigger the module to load on demand.
+	 */
+	pdev = platform_device_alloc("e820_pmem", -1);
+	return platform_device_add(pdev);
 }
 device_initcall(register_e820_pmem);
diff --git a/drivers/nvdimm/Makefile b/drivers/nvdimm/Makefile
index 594bb97c867a..9bf15db52dee 100644
--- a/drivers/nvdimm/Makefile
+++ b/drivers/nvdimm/Makefile
@@ -2,6 +2,7 @@ obj-$(CONFIG_LIBNVDIMM) += libnvdimm.o
 obj-$(CONFIG_BLK_DEV_PMEM) += nd_pmem.o
 obj-$(CONFIG_ND_BTT) += nd_btt.o
 obj-$(CONFIG_ND_BLK) += nd_blk.o
+obj-$(CONFIG_X86_PMEM_LEGACY) += nd_e820.o
 
 nd_pmem-y := pmem.o
 
@@ -9,6 +10,8 @@ nd_btt-y := btt.o
 
 nd_blk-y := blk.o
 
+nd_e820-y := e820.o
+
 libnvdimm-y := core.o
 libnvdimm-y += bus.o
 libnvdimm-y += dimm_devs.o
diff --git a/drivers/nvdimm/e820.c b/drivers/nvdimm/e820.c
new file mode 100644
index 000000000000..1b5743ad92db
--- /dev/null
+++ b/drivers/nvdimm/e820.c
@@ -0,0 +1,86 @@
+/*
+ * Copyright (c) 2015, Christoph Hellwig.
+ * Copyright (c) 2015, Intel Corporation.
+ */
+#include <linux/platform_device.h>
+#include <linux/libnvdimm.h>
+#include <linux/module.h>
+
+static const struct attribute_group *e820_pmem_attribute_groups[] = {
+	&nvdimm_bus_attribute_group,
+	NULL,
+};
+
+static const struct attribute_group *e820_pmem_region_attribute_groups[] = {
+	&nd_region_attribute_group,
+	&nd_device_attribute_group,
+	NULL,
+};
+
+static int e820_pmem_remove(struct platform_device *pdev)
+{
+	struct nvdimm_bus *nvdimm_bus = platform_get_drvdata(pdev);
+
+	nvdimm_bus_unregister(nvdimm_bus);
+	return 0;
+}
+
+static int e820_pmem_probe(struct platform_device *pdev)
+{
+	static struct nvdimm_bus_descriptor nd_desc;
+	struct device *dev = &pdev->dev;
+	struct nvdimm_bus *nvdimm_bus;
+	struct resource *p;
+
+	nd_desc.attr_groups = e820_pmem_attribute_groups;
+	nd_desc.provider_name = "e820";
+	nvdimm_bus = nvdimm_bus_register(dev, &nd_desc);
+	if (!nvdimm_bus)
+		goto err;
+	platform_set_drvdata(pdev, nvdimm_bus);
+
+	for (p = iomem_resource.child; p ; p = p->sibling) {
+		struct nd_region_desc ndr_desc;
+
+		if (strncmp(p->name, "Persistent Memory (legacy)", 26) != 0)
+			continue;
+
+		memset(&ndr_desc, 0, sizeof(ndr_desc));
+		ndr_desc.res = p;
+		ndr_desc.attr_groups = e820_pmem_region_attribute_groups;
+		ndr_desc.numa_node = NUMA_NO_NODE;
+		if (!nvdimm_pmem_region_create(nvdimm_bus, &ndr_desc))
+			goto err;
+	}
+
+	return 0;
+
+ err:
+	nvdimm_bus_unregister(nvdimm_bus);
+	dev_err(dev, "failed to register legacy persistent memory ranges\n");
+	return -ENXIO;
+}
+
+static struct platform_driver e820_pmem_driver = {
+	.probe = e820_pmem_probe,
+	.remove = e820_pmem_remove,
+	.driver = {
+		.name = "e820_pmem",
+	},
+};
+
+static __init int e820_pmem_init(void)
+{
+	return platform_driver_register(&e820_pmem_driver);
+}
+
+static __exit void e820_pmem_exit(void)
+{
+	platform_driver_unregister(&e820_pmem_driver);
+}
+
+MODULE_ALIAS("platform:e820_pmem*");
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Intel Corporation");
+module_init(e820_pmem_init);
+module_exit(e820_pmem_exit);
diff --git a/tools/testing/nvdimm/Kbuild b/tools/testing/nvdimm/Kbuild
index 04c5fc09576d..e667579d38a0 100644
--- a/tools/testing/nvdimm/Kbuild
+++ b/tools/testing/nvdimm/Kbuild
@@ -15,6 +15,7 @@ obj-$(CONFIG_LIBNVDIMM) += libnvdimm.o
 obj-$(CONFIG_BLK_DEV_PMEM) += nd_pmem.o
 obj-$(CONFIG_ND_BTT) += nd_btt.o
 obj-$(CONFIG_ND_BLK) += nd_blk.o
+obj-$(CONFIG_X86_PMEM_LEGACY) += nd_e820.o
 obj-$(CONFIG_ACPI_NFIT) += nfit.o
 
 nfit-y := $(ACPI_SRC)/nfit.o
@@ -29,6 +30,9 @@ nd_btt-y += config_check.o
 nd_blk-y := $(NVDIMM_SRC)/blk.o
 nd_blk-y += config_check.o
 
+nd_e820-y := $(NVDIMM_SRC)/e820.o
+nd_e820-y += config_check.o
+
 libnvdimm-y := $(NVDIMM_SRC)/core.o
 libnvdimm-y += $(NVDIMM_SRC)/bus.o
 libnvdimm-y += $(NVDIMM_SRC)/dimm_devs.o

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
