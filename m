Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E3E4C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 19:02:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D24892084D
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 19:02:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D24892084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D313C8E000E; Mon, 25 Feb 2019 14:02:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C90798E0004; Mon, 25 Feb 2019 14:02:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B33BE8E000E; Mon, 25 Feb 2019 14:02:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6B34D8E0004
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 14:02:47 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 71so7899256plf.19
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 11:02:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :from:date:references:in-reply-to:message-id;
        bh=qSCp8WFq4n0m4QhR+X834DlshjvZ4prw08Kpqwu8a28=;
        b=RLy25/WJLA1NsQi9clN4OSBHEl6Hvf9tfzUIbm8K1D3oAphcPpHmSRaY/qd5y5cuQU
         Vy4x3cqBsx8zAZGkUxulyfomKHgmq+mmvPuUZ7QE5QCm/Uu0rhADscTRojwH79LYNhpC
         9qVzLTf4zpkRVhv8duvc4Cxpqt5Qna/iOv9HlWDjnl/5zG4lp765NwDwXKjzslF9uW3Y
         HeMhZslbRVgPQ6MHyVSAowTBdJjSmQwtAMuM+EPMq2bCYRZAyJGWNGXnTCwFCxQgN+lo
         F9xQFwzgSEcXIdeKl/r8kzm//S/TigKkkwai+h4cBxQ03tDWZWHLiBnDfy5546CBPTkv
         uC2w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYoOZdaCgFM6hVjHvFVYet5dKh+Eaihm2hxeuY0coT4HhNZFd5g
	2dJZgAv5oIZ6QREktbSyzwJsbt9zVXBjCL0PAQO2SX1MU+KNrr+n2NG8jT6n7W4QllD+XkSYIDr
	+Zt4L2DETPj5heVlzko6wvqdcTD2kX6YuJYg9lfvPsPzaJreEES6dG1Q8G7hRisj+2w==
X-Received: by 2002:a17:902:9893:: with SMTP id s19mr21946835plp.165.1551121367039;
        Mon, 25 Feb 2019 11:02:47 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbTseGy8pdxcQFU5VY3PnX7hU17fxQY0/2/efE3A/m63pdqpjP+ibf8W7YXCSlq7tXfTml9
X-Received: by 2002:a17:902:9893:: with SMTP id s19mr21946711plp.165.1551121365520;
        Mon, 25 Feb 2019 11:02:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551121365; cv=none;
        d=google.com; s=arc-20160816;
        b=VnVCsXObonwDwdvOQ5FlkKdYKSxjJiU0dDUBN4EqBtWZzeoG/qo9N4kvdwMP0KktTJ
         x72aZ/8RyypZyKBmne+9LVd7YId+VD8edMoMQsP+ItV6B0UGQHXonoFxz/xEaypn5Grw
         Vnp46hiNzyrD8cj6f5D+2VVkIgL4cPd1nrMsQL0T/x68fMG2t7g2dJ8+dpCFc1JqNFEO
         b0Pif3bHNCoqIPkx0FKDdhknUfr9UTH8n5ur15mB8K7tkDAPWFNlxVf52kusrL1n0nzW
         /QRABfa5bFJo2Znl/6Qvz+eEHwuUGGtYdrlXJrPm6iEYNOBB9UInh+IlXFXuuV3ATCGm
         Tv0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:in-reply-to:references:date:from:cc:to:subject;
        bh=qSCp8WFq4n0m4QhR+X834DlshjvZ4prw08Kpqwu8a28=;
        b=FeO6VU2qOyW0Jg8SEfcsa8Hl4cb7i2pBZY1txn5EOd9+S+aTJzA0z+PcHWAAlhgxLT
         Fwl7XgpCBweUHkQEWcW4SMnkIm+d1Y0kTJwg2afbnvPKQy7aoenF4Lqmpr/znASvq/AK
         1UP3tygCznJQoFwh/vqm1ieSls8XPeNf489OZNfXIMhWimjPZAG6yDVG0SJdiqgYGprr
         sPEQ9BuUPaBCzXzwAmzNqouXhaRb1c8aA95EqVekySn1sc3ajAUhV39hTLEqIPhE3h18
         IbBZbruIs9MA2gF1cHEKpSZPYma+TnDhK49ZqSqtjEpqK1EELN2Nr/v1MBuhbhB5jmMS
         HkaA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id z190si9928052pgd.238.2019.02.25.11.02.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 11:02:45 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Feb 2019 11:02:44 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,412,1544515200"; 
   d="scan'208";a="120687537"
Received: from viggo.jf.intel.com (HELO localhost.localdomain) ([10.54.77.144])
  by orsmga008.jf.intel.com with ESMTP; 25 Feb 2019 11:02:44 -0800
Subject: [PATCH 5/5] dax: "Hotplug" persistent memory for use like normal RAM
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,dan.j.williams@intel.com,keith.busch@intel.com,dave.jiang@intel.com,zwisler@kernel.org,vishal.l.verma@intel.com,thomas.lendacky@amd.com,akpm@linux-foundation.org,mhocko@suse.com,linux-nvdimm@lists.01.org,linux-mm@kvack.org,ying.huang@intel.com,fengguang.wu@intel.com,bp@suse.de,bhelgaas@google.com,baiyaowei@cmss.chinamobile.com,tiwai@suse.de,jglisse@redhat.com
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Mon, 25 Feb 2019 10:57:40 -0800
References: <20190225185727.BCBD768C@viggo.jf.intel.com>
In-Reply-To: <20190225185727.BCBD768C@viggo.jf.intel.com>
Message-Id: <20190225185740.8660866F@viggo.jf.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


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

	echo dax0.0 > /sys/bus/dax/drivers/device_dax/unbind

and then tell the new driver that it can bind to the device:

	echo dax0.0 > /sys/bus/dax/drivers/kmem/new_id

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
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
Reviewed-by: Keith Busch <keith.busch@intel.com>
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
--- a/drivers/base/memory.c~dax-kmem-try-4	2019-02-25 10:56:51.791908023 -0800
+++ b/drivers/base/memory.c	2019-02-25 10:56:51.800908023 -0800
@@ -88,6 +88,7 @@ unsigned long __weak memory_block_size_b
 {
 	return MIN_MEMORY_BLOCK_SIZE;
 }
+EXPORT_SYMBOL_GPL(memory_block_size_bytes);
 
 static unsigned long get_memory_block_size(void)
 {
diff -puN drivers/dax/Kconfig~dax-kmem-try-4 drivers/dax/Kconfig
--- a/drivers/dax/Kconfig~dax-kmem-try-4	2019-02-25 10:56:51.793908023 -0800
+++ b/drivers/dax/Kconfig	2019-02-25 10:56:51.800908023 -0800
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
--- /dev/null	2019-02-15 15:42:29.903470860 -0800
+++ b/drivers/dax/kmem.c	2019-02-25 10:56:51.800908023 -0800
@@ -0,0 +1,108 @@
+// SPDX-License-Identifier: GPL-2.0
+/* Copyright(c) 2016-2019 Intel Corporation. All rights reserved. */
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
+	kmem_size -= kmem_start - res->start;
+	/* Align the size down to cover only complete blocks: */
+	kmem_size &= ~(memory_block_size_bytes() - 1);
+	kmem_end = kmem_start + kmem_size;
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
+	return 0;
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
--- a/drivers/dax/Makefile~dax-kmem-try-4	2019-02-25 10:56:51.796908023 -0800
+++ b/drivers/dax/Makefile	2019-02-25 10:56:51.800908023 -0800
@@ -1,6 +1,7 @@
 # SPDX-License-Identifier: GPL-2.0
 obj-$(CONFIG_DAX) += dax.o
 obj-$(CONFIG_DEV_DAX) += device_dax.o
+obj-$(CONFIG_DEV_DAX_KMEM) += kmem.o
 
 dax-y := super.o
 dax-y += bus.o
_

