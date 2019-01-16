Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F05298E0004
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 13:25:45 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id q63so5262773pfi.19
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 10:25:45 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id e6si1674985pgd.428.2019.01.16.10.25.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 10:25:44 -0800 (PST)
Subject: [PATCH 4/4] dax: "Hotplug" persistent memory for use like normal RAM
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 16 Jan 2019 10:19:05 -0800
References: <20190116181859.D1504459@viggo.jf.intel.com>
In-Reply-To: <20190116181859.D1504459@viggo.jf.intel.com>
Message-Id: <20190116181905.12E102B4@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: Dave Hansen <dave.hansen@linux.intel.com>, dan.j.williams@intel.com, dave.jiang@intel.com, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, akpm@linux-foundation.org, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ying.huang@intel.com, fengguang.wu@intel.com, bp@suse.de, bhelgaas@google.com, baiyaowei@cmss.chinamobile.com, tiwai@suse.de


From: Dave Hansen <dave.hansen@linux.intel.com>

Currently, a persistent memory region is "owned" by a device driver,
either the "Direct DAX" or "Filesystem DAX" drivers.  These drivers
allow applications to explicitly use persistent memory, generally
by being modified to use special, new libraries.

However, this limits persistent memory use to applications which
*have* been modified.  To make it more broadly usable, this driver
"hotplugs" memory into the kernel, to be managed ad used just like
normal RAM would be.

To make this work, management software must remove the device from
being controlled by the "Device DAX" infrastructure:

	echo -n dax0.0 > /sys/bus/dax/drivers/device_dax/remove_id
	echo -n dax0.0 > /sys/bus/dax/drivers/device_dax/unbind

and then bind it to this new driver:

	echo -n dax0.0 > /sys/bus/dax/drivers/kmem/new_id
	echo -n dax0.0 > /sys/bus/dax/drivers/kmem/bind

After this, there will be a number of new memory sections visible
in sysfs that can be onlined, or that may get onlined by existing
udev-initiated memory hotplug rules.

Note: this inherits any existing NUMA information for the newly-
added memory from the persistent memory device that came from the
firmware.  On Intel platforms, the firmware has guarantees that
require each socket's persistent memory to be in a separate
memory-only NUMA node.  That means that this patch is not expected
to create NUMA nodes, but will simply hotplug memory into existing
nodes.

There is currently some metadata at the beginning of pmem regions.
The section-size memory hotplug restrictions, plus this small
reserved area can cause the "loss" of a section or two of capacity.
This should be fixable in follow-on patches.  But, as a first step,
losing 256MB of memory (worst case) out of hundreds of gigabytes
is a good tradeoff vs. the required code to fix this up precisely.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Jiang <dave.jiang@intel.com>
Cc: Ross Zwisler <zwisler@kernel.org>
Cc: Vishal Verma <vishal.l.verma@intel.com>
Cc: Tom Lendacky <thomas.lendacky@amd.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: linux-nvdimm@lists.01.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: Huang Ying <ying.huang@intel.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>
Cc: Borislav Petkov <bp@suse.de>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Cc: Takashi Iwai <tiwai@suse.de>
---

 b/drivers/dax/Kconfig  |    5 ++
 b/drivers/dax/Makefile |    1 
 b/drivers/dax/kmem.c   |   93 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 99 insertions(+)

diff -puN drivers/dax/Kconfig~dax-kmem-try-4 drivers/dax/Kconfig
--- a/drivers/dax/Kconfig~dax-kmem-try-4	2019-01-08 09:54:44.051694874 -0800
+++ b/drivers/dax/Kconfig	2019-01-08 09:54:44.056694874 -0800
@@ -32,6 +32,11 @@ config DEV_DAX_PMEM
 
 	  Say M if unsure
 
+config DEV_DAX_KMEM
+	def_bool y
+	depends on DEV_DAX_PMEM   # Needs DEV_DAX_PMEM infrastructure
+	depends on MEMORY_HOTPLUG # for add_memory() and friends
+
 config DEV_DAX_PMEM_COMPAT
 	tristate "PMEM DAX: support the deprecated /sys/class/dax interface"
 	depends on DEV_DAX_PMEM
diff -puN /dev/null drivers/dax/kmem.c
--- /dev/null	2018-12-03 08:41:47.355756491 -0800
+++ b/drivers/dax/kmem.c	2019-01-08 09:54:44.056694874 -0800
@@ -0,0 +1,93 @@
+// SPDX-License-Identifier: GPL-2.0
+/* Copyright(c) 2016-2018 Intel Corporation. All rights reserved. */
+#include <linux/memremap.h>
+#include <linux/pagemap.h>
+#include <linux/memory.h>
+#include <linux/module.h>
+#include <linux/device.h>
+#include <linux/pfn_t.h>
+#include <linux/slab.h>
+#include <linux/dax.h>
+#include <linux/fs.h>
+#include <linux/mm.h>
+#include <linux/mman.h>
+#include "dax-private.h"
+#include "bus.h"
+
+int dev_dax_kmem_probe(struct device *dev)
+{
+	struct dev_dax *dev_dax = to_dev_dax(dev);
+	struct resource *res = &dev_dax->region->res;
+	resource_size_t kmem_start;
+	resource_size_t kmem_size;
+	struct resource *new_res;
+	int numa_node;
+	int rc;
+
+	/* Hotplug starting at the beginning of the next block: */
+	kmem_start = ALIGN(res->start, memory_block_size_bytes());
+
+	kmem_size = resource_size(res);
+	/* Adjust the size down to compensate for moving up kmem_start: */
+        kmem_size -= kmem_start - res->start;
+	/* Align the size down to cover only complete blocks: */
+	kmem_size &= ~(memory_block_size_bytes() - 1);
+
+	new_res = devm_request_mem_region(dev, kmem_start, kmem_size,
+					  dev_name(dev));
+
+	if (!new_res) {
+		printk("could not reserve region %016llx -> %016llx\n",
+				kmem_start, kmem_start+kmem_size);
+		return -EBUSY;
+	}
+
+	/*
+	 * Set flags appropriate for System RAM.  Leave ..._BUSY clear
+	 * so that add_memory() can add a child resource.
+	 */
+	new_res->flags = IORESOURCE_SYSTEM_RAM;
+	new_res->name = dev_name(dev);
+
+	numa_node = dev_dax->target_node;
+	if (numa_node < 0) {
+		pr_warn_once("bad numa_node: %d, forcing to 0\n", numa_node);
+		numa_node = 0;
+	}
+
+	rc = add_memory(numa_node, new_res->start, resource_size(new_res));
+	if (rc)
+		return rc;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(dev_dax_kmem_probe);
+
+static int dev_dax_kmem_remove(struct device *dev)
+{
+	/* Assume that hot-remove will fail for now */
+	return -EBUSY;
+}
+
+static struct dax_device_driver device_dax_kmem_driver = {
+	.drv = {
+		.probe = dev_dax_kmem_probe,
+		.remove = dev_dax_kmem_remove,
+	},
+};
+
+static int __init dax_kmem_init(void)
+{
+	return dax_driver_register(&device_dax_kmem_driver);
+}
+
+static void __exit dax_kmem_exit(void)
+{
+	dax_driver_unregister(&device_dax_kmem_driver);
+}
+
+MODULE_AUTHOR("Intel Corporation");
+MODULE_LICENSE("GPL v2");
+module_init(dax_kmem_init);
+module_exit(dax_kmem_exit);
+MODULE_ALIAS_DAX_DEVICE(0);
diff -puN drivers/dax/Makefile~dax-kmem-try-4 drivers/dax/Makefile
--- a/drivers/dax/Makefile~dax-kmem-try-4	2019-01-08 09:54:44.053694874 -0800
+++ b/drivers/dax/Makefile	2019-01-08 09:54:44.056694874 -0800
@@ -1,6 +1,7 @@
 # SPDX-License-Identifier: GPL-2.0
 obj-$(CONFIG_DAX) += dax.o
 obj-$(CONFIG_DEV_DAX) += device_dax.o
+obj-$(CONFIG_DEV_DAX_KMEM) += kmem.o
 
 dax-y := super.o
 dax-y += bus.o
_
