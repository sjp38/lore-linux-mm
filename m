Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 27F7F6B035D
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 23:25:22 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id t28-v6so12632616pfk.21
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 20:25:22 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id q76-v6si27715819pfa.91.2018.10.30.20.25.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Oct 2018 20:25:20 -0700 (PDT)
Subject: [PATCH 8/8] device-dax: Add /sys/class/dax backwards compatibility
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 30 Oct 2018 20:13:31 -0700
Message-ID: <154095561122.3271337.123035797363130070.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <154095556915.3271337.12581429676272726902.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <154095556915.3271337.12581429676272726902.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com

On the expectation that some environments may not upgrade libdaxctl
(userspace component that depends on the /sys/class/dax hierarchy),
provide a default / legacy dax_pmem_compat driver. The dax_pmem_compat
driver implements the original /sys/class/dax sysfs layout rather than
/sys/bus/dax. When userspace is upgraded it can blacklist this module
and switch to the dax_pmem driver going forward.

CONFIG_DEV_DAX_PMEM_COMPAT and supporting code will be deleted according
to the dax_pmem entry in Documentation/ABI/obsolete/.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 Documentation/ABI/obsolete/sysfs-class-dax |   22 +++++++
 drivers/dax/Kconfig                        |   12 +++-
 drivers/dax/Makefile                       |    4 +
 drivers/dax/bus.c                          |   29 +++++++--
 drivers/dax/bus.h                          |   26 +++++++-
 drivers/dax/device.c                       |    9 ++-
 drivers/dax/pmem.c                         |   90 ----------------------------
 drivers/dax/pmem/Makefile                  |    7 ++
 drivers/dax/pmem/compat.c                  |   73 +++++++++++++++++++++++
 drivers/dax/pmem/core.c                    |   69 +++++++++++++++++++++
 drivers/dax/pmem/pmem.c                    |   40 ++++++++++++
 tools/testing/nvdimm/Kbuild                |    6 ++
 12 files changed, 283 insertions(+), 104 deletions(-)
 create mode 100644 Documentation/ABI/obsolete/sysfs-class-dax
 delete mode 100644 drivers/dax/pmem.c
 create mode 100644 drivers/dax/pmem/Makefile
 create mode 100644 drivers/dax/pmem/compat.c
 create mode 100644 drivers/dax/pmem/core.c
 create mode 100644 drivers/dax/pmem/pmem.c

diff --git a/Documentation/ABI/obsolete/sysfs-class-dax b/Documentation/ABI/obsolete/sysfs-class-dax
new file mode 100644
index 000000000000..2cb9fc5e8bd1
--- /dev/null
+++ b/Documentation/ABI/obsolete/sysfs-class-dax
@@ -0,0 +1,22 @@
+What:           /sys/class/dax/
+Date:           May, 2016
+KernelVersion:  v4.7
+Contact:        linux-nvdimm@lists.01.org
+Description:	Device DAX is the device-centric analogue of Filesystem
+		DAX (CONFIG_FS_DAX).  It allows memory ranges to be
+		allocated and mapped without need of an intervening file
+		system.  Device DAX is strict, precise and predictable.
+		Specifically this interface:
+
+		1/ Guarantees fault granularity with respect to a given
+		page size (pte, pmd, or pud) set at configuration time.
+
+		2/ Enforces deterministic behavior by being strict about
+		what fault scenarios are supported.
+
+		The /sys/class/dax/ interface enumerates all the
+		device-dax instances in the system. The ABI is
+		deprecated and will be removed after 2020. It is
+		replaced with the DAX bus interface /sys/bus/dax/ where
+		device-dax instances can be found under
+		/sys/bus/dax/devices/
diff --git a/drivers/dax/Kconfig b/drivers/dax/Kconfig
index e0700bf4893a..6fc96f03920e 100644
--- a/drivers/dax/Kconfig
+++ b/drivers/dax/Kconfig
@@ -23,12 +23,22 @@ config DEV_DAX
 config DEV_DAX_PMEM
 	tristate "PMEM DAX: direct access to persistent memory"
 	depends on LIBNVDIMM && NVDIMM_DAX && DEV_DAX
+	depends on m # until we can kill DEV_DAX_PMEM_COMPAT
 	default DEV_DAX
 	help
 	  Support raw access to persistent memory.  Note that this
 	  driver consumes memory ranges allocated and exported by the
 	  libnvdimm sub-system.
 
-	  Say Y if unsure
+	  Say M if unsure
+
+config DEV_DAX_PMEM_COMPAT
+	tristate "PMEM DAX: support the deprecated /sys/class/dax interface"
+	depends on DEV_DAX_PMEM
+	default DEV_DAX_PMEM
+	help
+	  Older versions of the libdaxctl library expect to find all
+	  device-dax instances under /sys/class/dax. If libdaxctl in
+	  your distribution is older than v58 say M, otherwise say N.
 
 endif
diff --git a/drivers/dax/Makefile b/drivers/dax/Makefile
index 658e6b9b1d74..233bbffccbe6 100644
--- a/drivers/dax/Makefile
+++ b/drivers/dax/Makefile
@@ -1,9 +1,9 @@
 # SPDX-License-Identifier: GPL-2.0
 obj-$(CONFIG_DAX) += dax.o
 obj-$(CONFIG_DEV_DAX) += device_dax.o
-obj-$(CONFIG_DEV_DAX_PMEM) += dax_pmem.o
 
 dax-y := super.o
 dax-y += bus.o
-dax_pmem-y := pmem.o
 device_dax-y := device.o
+
+obj-y += pmem/
diff --git a/drivers/dax/bus.c b/drivers/dax/bus.c
index 178d76504f79..ebf9a4726f6c 100644
--- a/drivers/dax/bus.c
+++ b/drivers/dax/bus.c
@@ -9,6 +9,8 @@
 #include "dax-private.h"
 #include "bus.h"
 
+static struct class *dax_class;
+
 static DEFINE_MUTEX(dax_bus_lock);
 
 #define DAX_NAME_LEN 30
@@ -310,8 +312,8 @@ static void unregister_dev_dax(void *dev)
 	put_device(dev);
 }
 
-struct dev_dax *devm_create_dev_dax(struct dax_region *dax_region, int id,
-		struct dev_pagemap *pgmap)
+struct dev_dax *__devm_create_dev_dax(struct dax_region *dax_region, int id,
+		struct dev_pagemap *pgmap, enum dev_dax_subsys subsys)
 {
 	struct device *parent = dax_region->dev;
 	struct dax_device *dax_dev;
@@ -350,7 +352,10 @@ struct dev_dax *devm_create_dev_dax(struct dax_region *dax_region, int id,
 
 	inode = dax_inode(dax_dev);
 	dev->devt = inode->i_rdev;
-	dev->bus = &dax_bus_type;
+	if (subsys == DEV_DAX_BUS)
+		dev->bus = &dax_bus_type;
+	else
+		dev->class = dax_class;
 	dev->parent = parent;
 	dev->groups = dax_attribute_groups;
 	dev->release = dev_dax_release;
@@ -374,7 +379,7 @@ struct dev_dax *devm_create_dev_dax(struct dax_region *dax_region, int id,
 
 	return ERR_PTR(rc);
 }
-EXPORT_SYMBOL_GPL(devm_create_dev_dax);
+EXPORT_SYMBOL_GPL(__devm_create_dev_dax);
 
 static int match_always_count;
 
@@ -407,6 +412,7 @@ EXPORT_SYMBOL_GPL(__dax_driver_register);
 
 void dax_driver_unregister(struct dax_device_driver *dax_drv)
 {
+	struct device_driver *drv = &dax_drv->drv;
 	struct dax_id *dax_id, *_id;
 
 	mutex_lock(&dax_bus_lock);
@@ -416,15 +422,28 @@ void dax_driver_unregister(struct dax_device_driver *dax_drv)
 		kfree(dax_id);
 	}
 	mutex_unlock(&dax_bus_lock);
+	driver_unregister(drv);
 }
 EXPORT_SYMBOL_GPL(dax_driver_unregister);
 
 int __init dax_bus_init(void)
 {
-	return bus_register(&dax_bus_type);
+	int rc;
+
+	if (IS_ENABLED(CONFIG_DEV_DAX_PMEM_COMPAT)) {
+		dax_class = class_create(THIS_MODULE, "dax");
+		if (IS_ERR(dax_class))
+			return PTR_ERR(dax_class);
+	}
+
+	rc = bus_register(&dax_bus_type);
+	if (rc)
+		class_destroy(dax_class);
+	return rc;
 }
 
 void __exit dax_bus_exit(void)
 {
 	bus_unregister(&dax_bus_type);
+	class_destroy(dax_class);
 }
diff --git a/drivers/dax/bus.h b/drivers/dax/bus.h
index 395ab812367c..ce977552ffb5 100644
--- a/drivers/dax/bus.h
+++ b/drivers/dax/bus.h
@@ -2,7 +2,8 @@
 /* Copyright(c) 2016 - 2018 Intel Corporation. All rights reserved. */
 #ifndef __DAX_BUS_H__
 #define __DAX_BUS_H__
-struct device;
+#include <linux/device.h>
+
 struct dev_dax;
 struct resource;
 struct dax_device;
@@ -10,8 +11,23 @@ struct dax_region;
 void dax_region_put(struct dax_region *dax_region);
 struct dax_region *alloc_dax_region(struct device *parent, int region_id,
 		struct resource *res, unsigned int align, unsigned long flags);
-struct dev_dax *devm_create_dev_dax(struct dax_region *dax_region, int id,
-		struct dev_pagemap *pgmap);
+
+enum dev_dax_subsys {
+	DEV_DAX_BUS,
+	DEV_DAX_CLASS,
+};
+
+struct dev_dax *__devm_create_dev_dax(struct dax_region *dax_region, int id,
+		struct dev_pagemap *pgmap, enum dev_dax_subsys subsys);
+
+static inline struct dev_dax *devm_create_dev_dax(struct dax_region *dax_region,
+		int id, struct dev_pagemap *pgmap)
+{
+	return __devm_create_dev_dax(dax_region, id, pgmap, DEV_DAX_BUS);
+}
+
+/* to be deleted when DEV_DAX_CLASS is removed */
+struct dev_dax *__dax_pmem_probe(struct device *dev, enum dev_dax_subsys subsys);
 
 struct dax_device_driver {
 	struct device_driver drv;
@@ -26,6 +42,10 @@ int __dax_driver_register(struct dax_device_driver *dax_drv,
 void dax_driver_unregister(struct dax_device_driver *dax_drv);
 void kill_dev_dax(struct dev_dax *dev_dax);
 
+#if IS_ENABLED(CONFIG_DEV_DAX_PMEM_COMPAT)
+int dev_dax_probe(struct device *dev);
+#endif
+
 /*
  * While run_dax() is potentially a generic operation that could be
  * defined in include/linux/dax.h we don't want to grow any users
diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index 052aed3ab600..71694cd984a3 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -445,7 +445,7 @@ static void dev_dax_kill(void *dev_dax)
 	kill_dev_dax(dev_dax);
 }
 
-static int dev_dax_probe(struct device *dev)
+int dev_dax_probe(struct device *dev)
 {
 	struct dev_dax *dev_dax = to_dev_dax(dev);
 	struct dax_device *dax_dev = dev_dax->dax_dev;
@@ -488,7 +488,11 @@ static int dev_dax_probe(struct device *dev)
 	inode = dax_inode(dax_dev);
 	cdev = inode->i_cdev;
 	cdev_init(cdev, &dax_fops);
-	cdev->owner = dev->driver->owner;
+	if (dev->class) {
+		/* for the CONFIG_DEV_DAX_PMEM_COMPAT case */
+		cdev->owner = dev->parent->driver->owner;
+	} else
+		cdev->owner = dev->driver->owner;
 	cdev_set_parent(cdev, &dev->kobj);
 	rc = cdev_add(cdev, dev->devt, 1);
 	if (rc)
@@ -501,6 +505,7 @@ static int dev_dax_probe(struct device *dev)
 	run_dax(dax_dev);
 	return devm_add_action_or_reset(dev, dev_dax_kill, dev_dax);
 }
+EXPORT_SYMBOL_GPL(dev_dax_probe);
 
 static int dev_dax_remove(struct device *dev)
 {
diff --git a/drivers/dax/pmem.c b/drivers/dax/pmem.c
deleted file mode 100644
index d3cefa7868ac..000000000000
--- a/drivers/dax/pmem.c
+++ /dev/null
@@ -1,90 +0,0 @@
-/*
- * Copyright(c) 2016 Intel Corporation. All rights reserved.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of version 2 of the GNU General Public License as
- * published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License for more details.
- */
-#include <linux/percpu-refcount.h>
-#include <linux/memremap.h>
-#include <linux/module.h>
-#include <linux/pfn_t.h>
-#include "../nvdimm/pfn.h"
-#include "../nvdimm/nd.h"
-#include "bus.h"
-
-static int dax_pmem_probe(struct device *dev)
-{
-	struct resource res;
-	int rc, id, region_id;
-	resource_size_t offset;
-	struct nd_pfn_sb *pfn_sb;
-	struct dev_dax *dev_dax;
-	struct nd_namespace_io *nsio;
-	struct dax_region *dax_region;
-	struct dev_pagemap pgmap = { 0 };
-	struct nd_namespace_common *ndns;
-	struct nd_dax *nd_dax = to_nd_dax(dev);
-	struct nd_pfn *nd_pfn = &nd_dax->nd_pfn;
-
-	ndns = nvdimm_namespace_common_probe(dev);
-	if (IS_ERR(ndns))
-		return PTR_ERR(ndns);
-	nsio = to_nd_namespace_io(&ndns->dev);
-
-	/* parse the 'pfn' info block via ->rw_bytes */
-	rc = devm_nsio_enable(dev, nsio);
-	if (rc)
-		return rc;
-	rc = nvdimm_setup_pfn(nd_pfn, &pgmap);
-	if (rc)
-		return rc;
-	devm_nsio_disable(dev, nsio);
-
-	/* reserve the metadata area, device-dax will reserve the data */
-        pfn_sb = nd_pfn->pfn_sb;
-	offset = le64_to_cpu(pfn_sb->dataoff);
-	if (!devm_request_mem_region(dev, nsio->res.start, offset,
-				dev_name(&ndns->dev))) {
-                dev_warn(dev, "could not reserve metadata\n");
-                return -EBUSY;
-        }
-
-	rc = sscanf(dev_name(&ndns->dev), "namespace%d.%d", &region_id, &id);
-	if (rc != 2)
-		return -EINVAL;
-
-	/* adjust the dax_region resource to the start of data */
-	memcpy(&res, &pgmap.res, sizeof(res));
-	res.start += offset;
-	dax_region = alloc_dax_region(dev, region_id, &res,
-			le32_to_cpu(pfn_sb->align), PFN_DEV|PFN_MAP);
-	if (!dax_region)
-		return -ENOMEM;
-
-	dev_dax = devm_create_dev_dax(dax_region, id, &pgmap);
-
-	/* child dev_dax instances now own the lifetime of the dax_region */
-	dax_region_put(dax_region);
-
-	return PTR_ERR_OR_ZERO(dev_dax);
-}
-
-static struct nd_device_driver dax_pmem_driver = {
-	.probe = dax_pmem_probe,
-	.drv = {
-		.name = "dax_pmem",
-	},
-	.type = ND_DRIVER_DAX_PMEM,
-};
-
-module_nd_driver(dax_pmem_driver);
-
-MODULE_LICENSE("GPL v2");
-MODULE_AUTHOR("Intel Corporation");
-MODULE_ALIAS_ND_DEVICE(ND_DEVICE_DAX_PMEM);
diff --git a/drivers/dax/pmem/Makefile b/drivers/dax/pmem/Makefile
new file mode 100644
index 000000000000..e2e79bd3fdcf
--- /dev/null
+++ b/drivers/dax/pmem/Makefile
@@ -0,0 +1,7 @@
+obj-$(CONFIG_DEV_DAX_PMEM) += dax_pmem.o
+obj-$(CONFIG_DEV_DAX_PMEM) += dax_pmem_core.o
+obj-$(CONFIG_DEV_DAX_PMEM_COMPAT) += dax_pmem_compat.o
+
+dax_pmem-y := pmem.o
+dax_pmem_core-y := core.o
+dax_pmem_compat-y := compat.o
diff --git a/drivers/dax/pmem/compat.c b/drivers/dax/pmem/compat.c
new file mode 100644
index 000000000000..d7b15e6f30c5
--- /dev/null
+++ b/drivers/dax/pmem/compat.c
@@ -0,0 +1,73 @@
+// SPDX-License-Identifier: GPL-2.0
+/* Copyright(c) 2016 - 2018 Intel Corporation. All rights reserved. */
+#include <linux/percpu-refcount.h>
+#include <linux/memremap.h>
+#include <linux/module.h>
+#include <linux/pfn_t.h>
+#include <linux/nd.h>
+#include "../bus.h"
+
+/* we need the private definitions to implement compat suport */
+#include "../dax-private.h"
+
+static int dax_pmem_compat_probe(struct device *dev)
+{
+	struct dev_dax *dev_dax = __dax_pmem_probe(dev, DEV_DAX_CLASS);
+	int rc;
+
+	if (IS_ERR(dev_dax))
+		return PTR_ERR(dev_dax);
+
+        if (!devres_open_group(&dev_dax->dev, dev_dax, GFP_KERNEL))
+		return -ENOMEM;
+
+	device_lock(&dev_dax->dev);
+	rc = dev_dax_probe(&dev_dax->dev);
+	device_unlock(&dev_dax->dev);
+
+	devres_close_group(&dev_dax->dev, dev_dax);
+	if (rc)
+		devres_release_group(&dev_dax->dev, dev_dax);
+
+	return rc;
+}
+
+static int dax_pmem_compat_release(struct device *dev, void *data)
+{
+	device_lock(dev);
+	devres_release_group(dev, to_dev_dax(dev));
+	device_unlock(dev);
+
+	return 0;
+}
+
+static int dax_pmem_compat_remove(struct device *dev)
+{
+	device_for_each_child(dev, NULL, dax_pmem_compat_release);
+	return 0;
+}
+
+static struct nd_device_driver dax_pmem_compat_driver = {
+	.probe = dax_pmem_compat_probe,
+	.remove = dax_pmem_compat_remove,
+	.drv = {
+		.name = "dax_pmem_compat",
+	},
+	.type = ND_DRIVER_DAX_PMEM,
+};
+
+static int __init dax_pmem_compat_init(void)
+{
+	return nd_driver_register(&dax_pmem_compat_driver);
+}
+module_init(dax_pmem_compat_init);
+
+static void __exit dax_pmem_compat_exit(void)
+{
+	driver_unregister(&dax_pmem_compat_driver.drv);
+}
+module_exit(dax_pmem_compat_exit);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Intel Corporation");
+MODULE_ALIAS_ND_DEVICE(ND_DEVICE_DAX_PMEM);
diff --git a/drivers/dax/pmem/core.c b/drivers/dax/pmem/core.c
new file mode 100644
index 000000000000..bdcff1b14e95
--- /dev/null
+++ b/drivers/dax/pmem/core.c
@@ -0,0 +1,69 @@
+// SPDX-License-Identifier: GPL-2.0
+/* Copyright(c) 2016 - 2018 Intel Corporation. All rights reserved. */
+#include <linux/memremap.h>
+#include <linux/module.h>
+#include <linux/pfn_t.h>
+#include "../../nvdimm/pfn.h"
+#include "../../nvdimm/nd.h"
+#include "../bus.h"
+
+struct dev_dax *__dax_pmem_probe(struct device *dev, enum dev_dax_subsys subsys)
+{
+	struct resource res;
+	int rc, id, region_id;
+	resource_size_t offset;
+	struct nd_pfn_sb *pfn_sb;
+	struct dev_dax *dev_dax;
+	struct nd_namespace_io *nsio;
+	struct dax_region *dax_region;
+	struct dev_pagemap pgmap = { 0 };
+	struct nd_namespace_common *ndns;
+	struct nd_dax *nd_dax = to_nd_dax(dev);
+	struct nd_pfn *nd_pfn = &nd_dax->nd_pfn;
+
+	ndns = nvdimm_namespace_common_probe(dev);
+	if (IS_ERR(ndns))
+		return ERR_CAST(ndns);
+	nsio = to_nd_namespace_io(&ndns->dev);
+
+	/* parse the 'pfn' info block via ->rw_bytes */
+	rc = devm_nsio_enable(dev, nsio);
+	if (rc)
+		return ERR_PTR(rc);
+	rc = nvdimm_setup_pfn(nd_pfn, &pgmap);
+	if (rc)
+		return ERR_PTR(rc);
+	devm_nsio_disable(dev, nsio);
+
+	/* reserve the metadata area, device-dax will reserve the data */
+        pfn_sb = nd_pfn->pfn_sb;
+	offset = le64_to_cpu(pfn_sb->dataoff);
+	if (!devm_request_mem_region(dev, nsio->res.start, offset,
+				dev_name(&ndns->dev))) {
+                dev_warn(dev, "could not reserve metadata\n");
+		return ERR_PTR(-EBUSY);
+        }
+
+	rc = sscanf(dev_name(&ndns->dev), "namespace%d.%d", &region_id, &id);
+	if (rc != 2)
+		return ERR_PTR(-EINVAL);
+
+	/* adjust the dax_region resource to the start of data */
+	memcpy(&res, &pgmap.res, sizeof(res));
+	res.start += offset;
+	dax_region = alloc_dax_region(dev, region_id, &res,
+			le32_to_cpu(pfn_sb->align), PFN_DEV|PFN_MAP);
+	if (!dax_region)
+		return ERR_PTR(-ENOMEM);
+
+	dev_dax = __devm_create_dev_dax(dax_region, id, &pgmap, subsys);
+
+	/* child dev_dax instances now own the lifetime of the dax_region */
+	dax_region_put(dax_region);
+
+	return dev_dax;
+}
+EXPORT_SYMBOL_GPL(__dax_pmem_probe);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Intel Corporation");
diff --git a/drivers/dax/pmem/pmem.c b/drivers/dax/pmem/pmem.c
new file mode 100644
index 000000000000..0ae4238a0ef8
--- /dev/null
+++ b/drivers/dax/pmem/pmem.c
@@ -0,0 +1,40 @@
+// SPDX-License-Identifier: GPL-2.0
+/* Copyright(c) 2016 - 2018 Intel Corporation. All rights reserved. */
+#include <linux/percpu-refcount.h>
+#include <linux/memremap.h>
+#include <linux/module.h>
+#include <linux/pfn_t.h>
+#include <linux/nd.h>
+#include "../bus.h"
+
+static int dax_pmem_probe(struct device *dev)
+{
+	return PTR_ERR_OR_ZERO(__dax_pmem_probe(dev, DEV_DAX_BUS));
+}
+
+static struct nd_device_driver dax_pmem_driver = {
+	.probe = dax_pmem_probe,
+	.drv = {
+		.name = "dax_pmem",
+	},
+	.type = ND_DRIVER_DAX_PMEM,
+};
+
+static int __init dax_pmem_init(void)
+{
+	return nd_driver_register(&dax_pmem_driver);
+}
+module_init(dax_pmem_init);
+
+static void __exit dax_pmem_exit(void)
+{
+	driver_unregister(&dax_pmem_driver.drv);
+}
+module_exit(dax_pmem_exit);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Intel Corporation");
+#if !IS_ENABLED(CONFIG_DEV_DAX_PMEM_COMPAT)
+/* For compat builds, don't load this module by default */
+MODULE_ALIAS_ND_DEVICE(ND_DEVICE_DAX_PMEM);
+#endif
diff --git a/tools/testing/nvdimm/Kbuild b/tools/testing/nvdimm/Kbuild
index bfc4d8e98452..1e37719bc37e 100644
--- a/tools/testing/nvdimm/Kbuild
+++ b/tools/testing/nvdimm/Kbuild
@@ -34,6 +34,8 @@ obj-$(CONFIG_DAX) += dax.o
 endif
 obj-$(CONFIG_DEV_DAX) += device_dax.o
 obj-$(CONFIG_DEV_DAX_PMEM) += dax_pmem.o
+obj-$(CONFIG_DEV_DAX_PMEM) += dax_pmem_core.o
+obj-$(CONFIG_DEV_DAX_PMEM_COMPAT) += dax_pmem_compat.o
 
 nfit-y := $(ACPI_SRC)/core.o
 nfit-$(CONFIG_X86_MCE) += $(ACPI_SRC)/mce.o
@@ -63,7 +65,9 @@ device_dax-y += dax-dev.o
 device_dax-y += device_dax_test.o
 device_dax-y += config_check.o
 
-dax_pmem-y := $(DAX_SRC)/pmem.o
+dax_pmem-y := $(DAX_SRC)/pmem/pmem.o
+dax_pmem_core-y := $(DAX_SRC)/pmem/core.o
+dax_pmem_compat-y := $(DAX_SRC)/pmem/compat.o
 dax_pmem-y += config_check.o
 
 libnvdimm-y := $(NVDIMM_SRC)/core.o
