Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5526C8E00AC
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 18:22:00 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id l76so5977900pfg.1
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 15:22:00 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id p12si23187888pgl.106.2019.01.24.15.21.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 15:21:58 -0800 (PST)
Subject: [PATCH 5/5] dax: "Hotplug" persistent memory for use like normal RAM
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Thu, 24 Jan 2019 15:14:48 -0800
References: <20190124231441.37A4A305@viggo.jf.intel.com>
In-Reply-To: <20190124231441.37A4A305@viggo.jf.intel.com>
Message-Id: <20190124231448.E102D18E@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, dan.j.williams@intel.com, dave.jiang@intel.com, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, akpm@linux-foundation.org, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, ying.huang@intel.com, fengguang.wu@intel.com, bp@suse.de, bhelgaas@google.com, baiyaowei@cmss.chinamobile.com, tiwai@suse.de, jglisse@redhat.com


From: Dave Hansen <dave.hansen@linux.intel.com>

This is intended for use with NVDIMMs that are physically persistent
(physically like flash) so that they can be used as a cost-effective
RAM replacement.  Intel Optane DC persistent memory is one
implementation of this kind of NVDIMM.

Currently, a persistent memory region is "owned" by a device driver,
either the "Direct DAX" or "Filesystem DAX" drivers.  These drivers
allow applications to explicitly use persistent memory, generally
by being modified to use special, new libraries. (DIMM-based
persistent memory hardware/software is described in great detail
here: Documentation/nvdimm/nvdimm.txt).

However, this limits persistent memory use to applications which
*have* been modified.  To make it more broadly usable, this driver
"hotplugs" memory into the kernel, to be managed and used just like
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

This rebinding procedure is currently a one-way trip.  Once memory
is bound to "kmem", it's there permanently and can not be
unbound and assigned back to device_dax.

The kmem driver will never bind to a dax device unless the device
is *explicitly* bound to the driver.  There are two reasons for
this: One, since it is a one-way trip, it can not be undone if
bound incorrectly.  Two, the kmem driver destroys data on the
device.  Think of if you had good data on a pmem device.  It
would be catastrophic if you compile-in "kmem", but leave out
the "device_dax" driver.  kmem would take over the device and
write volatile data all over your good data.

This inherits any existing NUMA information for the newly-added
memory from the persistent memory device that came from the
firmware.  On Intel platforms, the firmware has guarantees that
require each socket's persistent memory to be in a separate
memory-only NUMA node.  That means that this patch is not expected
to create NUMA nodes, but will simply hotplug memory into existing
nodes.

Because NUMA nodes are created, the existing NUMA APIs and tools
are sufficient to create policies for applications or memory areas
to have affinity for or an aversion to using this memory.

There is currently some metadata at the beginning of pmem regions.
The section-size memory hotplug restrictions, plus this small
reserved area can cause the "loss" of a section or two of capacity.
This should be fixable in follow-on patches.  But, as a first step,
losing 256MB of memory (worst case) out of hundreds of gigabytes
is a good tradeoff vs. the required code to fix this up precisely.
This calculation is also the reason we export
memory_block_size_bytes().

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
Cc: Jerome Glisse <jglisse@redhat.com>
---

 b/drivers/base/memory.c |    1 
 b/drivers/dax/Kconfig   |   16 +++++++
 b/drivers/dax/Makefile  |    1 
 b/drivers/dax/kmem.c    |  108 ++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 126 insertions(+)

diff -puN drivers/base/memory.c~dax-kmem-try-4 drivers/base/memory.c
--- a/drivers/base/memory.c~dax-kmem-try-4	2019-01-24 15:13:15.987199535 -0800
+++ b/drivers/base/memory.c	2019-01-24 15:13:15.994199535 -0800
@@ -88,6 +88,7 @@ unsigned long __weak memory_block_size_b
 {
 	return MIN_MEMORY_BLOCK_SIZE;
 }
+EXPORT_SYMBOL_GPL(memory_block_size_bytes);
 
 static unsigned long get_memory_block_size(void)
 {
diff -puN drivers/dax/Kconfig~dax-kmem-try-4 drivers/dax/Kconfig
--- a/drivers/dax/Kconfig~dax-kmem-try-4	2019-01-24 15:13:15.988199535 -0800
+++ b/drivers/dax/Kconfig	2019-01-24 15:13:15.994199535 -0800
@@ -32,6 +32,22 @@ config DEV_DAX_PMEM
 
 	  Say M if unsure
 
+config DEV_DAX_KMEM
+	tristate "KMEM DAX: volatile-use of persistent memory"
+	default DEV_DAX
+	depends on DEV_DAX
+	depends on MEMORY_HOTPLUG # for add_memory() and friends
+	help
+	  Support access to persistent memory as if it were RAM.  This
+	  allows easier use of persistent memory by unmodified
+	  applications.
+
+	  To use this feature, a DAX device must be unbound from the
+	  device_dax driver (PMEM DAX) and bound to this kmem driver
+	  on each boot.
+
+	  Say N if unsure.
+
 config DEV_DAX_PMEM_COMPAT
 	tristate "PMEM DAX: support the deprecated /sys/class/dax interface"
 	depends on DEV_DAX_PMEM
diff -puN /dev/null drivers/dax/kmem.c
--- /dev/null	2018-12-03 08:41:47.355756491 -0800
+++ b/drivers/dax/kmem.c	2019-01-24 15:13:15.994199535 -0800
@@ -0,0 +1,108 @@
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
+	resource_size_t kmem_end;
+	struct resource *new_res;
+	int numa_node;
+	int rc;
+
+	/*
+	 * Ensure good NUMA information for the persistent memory.
+	 * Without this check, there is a risk that slow memory
+	 * could be mixed in a node with faster memory, causing
+	 * unavoidable performance issues.
+	 */
+	numa_node = dev_dax->target_node;
+	if (numa_node < 0) {
+		dev_warn(dev, "rejecting DAX region %pR with invalid node: %d\n",
+			 res, numa_node);
+		return -EINVAL;
+	}
+
+	/* Hotplug starting at the beginning of the next block: */
+	kmem_start = ALIGN(res->start, memory_block_size_bytes());
+
+	kmem_size = resource_size(res);
+	/* Adjust the size down to compensate for moving up kmem_start: */
+        kmem_size -= kmem_start - res->start;
+	/* Align the size down to cover only complete blocks: */
+	kmem_size &= ~(memory_block_size_bytes() - 1);
+	kmem_end = kmem_start+kmem_size;
+
+	/* Region is permanently reserved.  Hot-remove not yet implemented. */
+	new_res = request_mem_region(kmem_start, kmem_size, dev_name(dev));
+	if (!new_res) {
+		dev_warn(dev, "could not reserve region [%pa-%pa]\n",
+			 &kmem_start, &kmem_end);
+		return -EBUSY;
+	}
+
+	/*
+	 * Set flags appropriate for System RAM.  Leave ..._BUSY clear
+	 * so that add_memory() can add a child resource.  Do not
+	 * inherit flags from the parent since it may set new flags
+	 * unknown to us that will break add_memory() below.
+	 */
+	new_res->flags = IORESOURCE_SYSTEM_RAM;
+	new_res->name = dev_name(dev);
+
+	rc = add_memory(numa_node, new_res->start, resource_size(new_res));
+	if (rc)
+		return rc;
+
+	return 0;
+}
+
+static int dev_dax_kmem_remove(struct device *dev)
+{
+	/*
+	 * Purposely leak the request_mem_region() for the device-dax
+	 * range and return '0' to ->remove() attempts. The removal of
+	 * the device from the driver always succeeds, but the region
+	 * is permanently pinned as reserved by the unreleased
+	 * request_mem_region().
+	 */
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
--- a/drivers/dax/Makefile~dax-kmem-try-4	2019-01-24 15:13:15.990199535 -0800
+++ b/drivers/dax/Makefile	2019-01-24 15:13:15.994199535 -0800
@@ -1,6 +1,7 @@
 # SPDX-License-Identifier: GPL-2.0
 obj-$(CONFIG_DAX) += dax.o
 obj-$(CONFIG_DEV_DAX) += device_dax.o
+obj-$(CONFIG_DEV_DAX_KMEM) += kmem.o
 
 dax-y := super.o
 dax-y += bus.o
_
