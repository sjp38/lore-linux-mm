Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id D4DD16B0008
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 16:18:41 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 134-v6so12199941pga.1
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 13:18:41 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id b3-v6si28711757plc.103.2018.10.22.13.18.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 13:18:39 -0700 (PDT)
Subject: [PATCH 2/9] dax: kernel memory driver for mm ownership of DAX
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Mon, 22 Oct 2018 13:13:20 -0700
References: <20181022201317.8558C1D8@viggo.jf.intel.com>
In-Reply-To: <20181022201317.8558C1D8@viggo.jf.intel.com>
Message-Id: <20181022201320.45C9785C@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, dan.j.williams@intel.com, dave.jiang@intel.com, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, akpm@linux-foundation.org, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, ying.huang@intel.com, fengguang.wu@intel.com


Add the actual driver to which will own the DAX range.  This
allows very nice party with the other possible "owners" of
a DAX region: device DAX and filesystem DAX.  It also greatly
simplifies the process of handing off control of the memory
between the different owners since it's just a matter of
unbinding and rebinding the device to different drivers.

I tried to do this all internally to the kernel and the
locking and "self-destruction" of the old device context was
a nightmare.  Having userspace drive it is a wonderful
simplification.

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

---

 b/drivers/dax/kmem.c |  152 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 152 insertions(+)

diff -puN /dev/null drivers/dax/kmem.c
--- /dev/null	2018-09-18 12:39:53.059362935 -0700
+++ b/drivers/dax/kmem.c	2018-10-22 13:12:21.502930393 -0700
@@ -0,0 +1,152 @@
+// this just just a copy of drivers/dax/pmem.c with
+// s/dax_pmem/dax_kmem' for now.
+//
+// need real license
+/*
+ * Copyright(c) 2016-2018 Intel Corporation. All rights reserved.
+ */
+#include <linux/percpu-refcount.h>
+#include <linux/memremap.h>
+#include <linux/module.h>
+#include <linux/pfn_t.h>
+#include "../nvdimm/pfn.h"
+#include "../nvdimm/nd.h"
+#include "device-dax.h"
+
+struct dax_kmem {
+	struct device *dev;
+	struct percpu_ref ref;
+	struct dev_pagemap pgmap;
+	struct completion cmp;
+};
+
+static struct dax_kmem *to_dax_kmem(struct percpu_ref *ref)
+{
+	return container_of(ref, struct dax_kmem, ref);
+}
+
+static void dax_kmem_percpu_release(struct percpu_ref *ref)
+{
+	struct dax_kmem *dax_kmem = to_dax_pmem(ref);
+
+	dev_dbg(dax_kmem->dev, "trace\n");
+	complete(&dax_kmem->cmp);
+}
+
+static void dax_kmem_percpu_exit(void *data)
+{
+	struct percpu_ref *ref = data;
+	struct dax_kmem *dax_kmem = to_dax_pmem(ref);
+
+	dev_dbg(dax_kmem->dev, "trace\n");
+	wait_for_completion(&dax_kmem->cmp);
+	percpu_ref_exit(ref);
+}
+
+static void dax_kmem_percpu_kill(void *data)
+{
+	struct percpu_ref *ref = data;
+	struct dax_kmem *dax_kmem = to_dax_pmem(ref);
+
+	dev_dbg(dax_kmem->dev, "trace\n");
+	percpu_ref_kill(ref);
+}
+
+static int dax_kmem_probe(struct device *dev)
+{
+	void *addr;
+	struct resource res;
+	int rc, id, region_id;
+	struct nd_pfn_sb *pfn_sb;
+	struct dev_dax *dev_dax;
+	struct dax_kmem *dax_kmem;
+	struct nd_namespace_io *nsio;
+	struct dax_region *dax_region;
+	struct nd_namespace_common *ndns;
+	struct nd_dax *nd_dax = to_nd_dax(dev);
+	struct nd_pfn *nd_pfn = &nd_dax->nd_pfn;
+
+	ndns = nvdimm_namespace_common_probe(dev);
+	if (IS_ERR(ndns))
+		return PTR_ERR(ndns);
+	nsio = to_nd_namespace_io(&ndns->dev);
+
+	dax_kmem = devm_kzalloc(dev, sizeof(*dax_kmem), GFP_KERNEL);
+	if (!dax_kmem)
+		return -ENOMEM;
+
+	/* parse the 'pfn' info block via ->rw_bytes */
+	rc = devm_nsio_enable(dev, nsio);
+	if (rc)
+		return rc;
+	rc = nvdimm_setup_pfn(nd_pfn, &dax_kmem->pgmap);
+	if (rc)
+		return rc;
+	devm_nsio_disable(dev, nsio);
+
+	pfn_sb = nd_pfn->pfn_sb;
+
+	if (!devm_request_mem_region(dev, nsio->res.start,
+				resource_size(&nsio->res),
+				dev_name(&ndns->dev))) {
+		dev_warn(dev, "could not reserve region %pR\n", &nsio->res);
+		return -EBUSY;
+	}
+
+	dax_kmem->dev = dev;
+	init_completion(&dax_kmem->cmp);
+	rc = percpu_ref_init(&dax_kmem->ref, dax_kmem_percpu_release, 0,
+			GFP_KERNEL);
+	if (rc)
+		return rc;
+
+	rc = devm_add_action_or_reset(dev, dax_kmem_percpu_exit,
+							&dax_kmem->ref);
+	if (rc)
+		return rc;
+
+	dax_kmem->pgmap.ref = &dax_kmem->ref;
+	addr = devm_memremap_pages(dev, &dax_kmem->pgmap);
+	if (IS_ERR(addr))
+		return PTR_ERR(addr);
+
+	rc = devm_add_action_or_reset(dev, dax_kmem_percpu_kill,
+							&dax_kmem->ref);
+	if (rc)
+		return rc;
+
+	/* adjust the dax_region resource to the start of data */
+	memcpy(&res, &dax_kmem->pgmap.res, sizeof(res));
+	res.start += le64_to_cpu(pfn_sb->dataoff);
+
+	rc = sscanf(dev_name(&ndns->dev), "namespace%d.%d", &region_id, &id);
+	if (rc != 2)
+		return -EINVAL;
+
+	dax_region = alloc_dax_region(dev, region_id, &res,
+			le32_to_cpu(pfn_sb->align), addr, PFN_DEV|PFN_MAP);
+	if (!dax_region)
+		return -ENOMEM;
+
+	/* TODO: support for subdividing a dax region... */
+	dev_dax = devm_create_dev_dax(dax_region, id, &res, 1);
+
+	/* child dev_dax instances now own the lifetime of the dax_region */
+	dax_region_put(dax_region);
+
+	return PTR_ERR_OR_ZERO(dev_dax);
+}
+
+static struct nd_device_driver dax_kmem_driver = {
+	.probe = dax_kmem_probe,
+	.drv = {
+		.name = "dax_kmem",
+	},
+	.type = ND_DRIVER_DAX_PMEM,
+};
+
+module_nd_driver(dax_kmem_driver);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Intel Corporation");
+MODULE_ALIAS_ND_DEVICE(ND_DEVICE_DAX_PMEM);
_
