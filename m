Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0DF848E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 19:44:04 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 2-v6so10572786plc.11
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 16:44:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u9-v6sor3090814plz.78.2018.09.10.16.44.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Sep 2018 16:44:02 -0700 (PDT)
Subject: [PATCH 4/4] nvdimm: Trigger the device probe on a cpu local to the
 device
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 10 Sep 2018 16:44:00 -0700
Message-ID: <20180910234400.4068.15541.stgit@localhost.localdomain>
In-Reply-To: <20180910232615.4068.29155.stgit@localhost.localdomain>
References: <20180910232615.4068.29155.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org
Cc: pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com, mingo@kernel.org, dave.hansen@intel.com, jglisse@redhat.com, akpm@linux-foundation.org, logang@deltatee.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch is based off of the pci_call_probe function used to initialize
PCI devices. The general idea here is to move the probe call to a location
that is local to the memory being initialized. By doing this we can shave
significant time off of the total time needed for initialization.

With this patch applied I see a significant reduction in overall init time
as without it the init varied between 23 and 37 seconds to initialize a 3GB
node. With this patch applied the variance is only between 23 and 26
seconds to initialize each node.

I hope to refine this further in the future by combining this logic into
the async_schedule_domain code that is already in use. By doing that it
would likely make this functionality redundant.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/nvdimm/bus.c |   45 ++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 44 insertions(+), 1 deletion(-)

diff --git a/drivers/nvdimm/bus.c b/drivers/nvdimm/bus.c
index 8aae6dcc839f..5b73953176b1 100644
--- a/drivers/nvdimm/bus.c
+++ b/drivers/nvdimm/bus.c
@@ -27,6 +27,7 @@
 #include <linux/io.h>
 #include <linux/mm.h>
 #include <linux/nd.h>
+#include <linux/cpu.h>
 #include "nd-core.h"
 #include "nd.h"
 #include "pfn.h"
@@ -90,6 +91,48 @@ static void nvdimm_bus_probe_end(struct nvdimm_bus *nvdimm_bus)
 	nvdimm_bus_unlock(&nvdimm_bus->dev);
 }
 
+struct nvdimm_drv_dev {
+	struct nd_device_driver *nd_drv;
+	struct device *dev;
+};
+
+static long __nvdimm_call_probe(void *_nddd)
+{
+	struct nvdimm_drv_dev *nddd = _nddd;
+	struct nd_device_driver *nd_drv = nddd->nd_drv;
+
+	return nd_drv->probe(nddd->dev);
+}
+
+static int nvdimm_call_probe(struct nd_device_driver *nd_drv,
+			     struct device *dev)
+{
+	struct nvdimm_drv_dev nddd = { nd_drv, dev };
+	int rc, node, cpu;
+
+	/*
+	 * Execute driver initialization on node where the device is
+	 * attached.  This way the driver will be able to access local
+	 * memory instead of having to initialize memory across nodes.
+	 */
+	node = dev_to_node(dev);
+
+	cpu_hotplug_disable();
+
+	if (node < 0 || node >= MAX_NUMNODES || !node_online(node))
+		cpu = nr_cpu_ids;
+	else
+		cpu = cpumask_any_and(cpumask_of_node(node), cpu_online_mask);
+
+	if (cpu < nr_cpu_ids)
+		rc = work_on_cpu(cpu, __nvdimm_call_probe, &nddd);
+	else
+		rc = __nvdimm_call_probe(&nddd);
+
+	cpu_hotplug_enable();
+	return rc;
+}
+
 static int nvdimm_bus_probe(struct device *dev)
 {
 	struct nd_device_driver *nd_drv = to_nd_device_driver(dev->driver);
@@ -104,7 +147,7 @@ static int nvdimm_bus_probe(struct device *dev)
 			dev->driver->name, dev_name(dev));
 
 	nvdimm_bus_probe_start(nvdimm_bus);
-	rc = nd_drv->probe(dev);
+	rc = nvdimm_call_probe(nd_drv, dev);
 	if (rc == 0)
 		nd_region_probe_success(nvdimm_bus, dev);
 	else
