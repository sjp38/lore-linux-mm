Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 56B5F6B0736
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 18:24:48 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id a24-v6so2625590pfn.12
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 15:24:48 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a8-v6si9167572plz.94.2018.11.09.15.24.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 15:24:46 -0800 (PST)
Subject: [PATCH] acpi/nfit,
 device-dax: Identify differentiated memory with a unique numa-node
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 09 Nov 2018 15:12:57 -0800
Message-ID: <154180517736.2047781.13819458479548681732.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Fan Du <fan.du@intel.com>, Michael Ellerman <mpe@ellerman.id.au>, Oliver O'Halloran <oohall@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Persistent memory, as described by the ACPI NFIT (NVDIMM Firmware
Interface Table), is the first known instance of a memory range
described by a unique "target" proximity domain. Where "initiator" and
"target" proximity domains is an approach that the ACPI HMAT
(Heterogeneous Memory Attributes Table) uses to described the unique
performance properties of a memory range relative to a given initiator
(e.g. CPU or DMA device).

Currently the numa-node for a /dev/pmemX block-device or /dev/daxX.Y
char-device follows the traditional notion of 'numa-node' where the
attribute conveys the closest online numa-node. That numa-node attribute
is useful for cpu-binding and memory-binding processes *near* the
device. However, when the memory range backing a 'pmem', or 'dax' device
is onlined (memory hot-add) the memory-only-numa-node representing that
address needs to be differentiated from the set of online nodes. In
other words, the numa-node association of the device depends on whether
you can bind processes *near* the cpu-numa-node in the offline
device-case, or bind process *on* the memory-range directly after the
backing address range is onlined.

Allow for the case that platform firmware describes persistent memory
with a unique proximity domain, i.e. when it is distinct from the
proximity of DRAM and CPUs that are on the same socket. Plumb the Linux
numa-node translation of that proximity through the libnvdimm region
device to namespaces that are in device-dax mode. With this in place the
proposed kmem driver [1] can optionally discover a unique numa-node
number for the address range as it transitions the memory from an
offline state managed by a device-driver to an online memory range
managed by the core-mm.

[1]: https://lkml.org/lkml/2018/10/23/9

Reported-by: Fan Du <fan.du@intel.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: "Oliver O'Halloran" <oohall@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/powerpc/platforms/pseries/papr_scm.c |    1 +
 drivers/acpi/nfit/core.c                  |    8 ++++++--
 drivers/acpi/numa.c                       |    1 +
 drivers/dax/bus.c                         |    4 +++-
 drivers/dax/bus.h                         |    3 ++-
 drivers/dax/dax-private.h                 |    4 ++++
 drivers/dax/pmem/core.c                   |    4 +++-
 drivers/nvdimm/e820.c                     |    1 +
 drivers/nvdimm/nd.h                       |    2 +-
 drivers/nvdimm/of_pmem.c                  |    1 +
 drivers/nvdimm/region_devs.c              |    1 +
 include/linux/libnvdimm.h                 |    1 +
 12 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/arch/powerpc/platforms/pseries/papr_scm.c b/arch/powerpc/platforms/pseries/papr_scm.c
index ee9372b65ca5..6a0a35b872d1 100644
--- a/arch/powerpc/platforms/pseries/papr_scm.c
+++ b/arch/powerpc/platforms/pseries/papr_scm.c
@@ -233,6 +233,7 @@ static int papr_scm_nvdimm_init(struct papr_scm_priv *p)
 	memset(&ndr_desc, 0, sizeof(ndr_desc));
 	ndr_desc.attr_groups = region_attr_groups;
 	ndr_desc.numa_node = dev_to_node(&p->pdev->dev);
+	ndr_desc.target_node = ndr_desc.numa_node;
 	ndr_desc.res = &p->res;
 	ndr_desc.of_node = p->dn;
 	ndr_desc.provider_data = p;
diff --git a/drivers/acpi/nfit/core.c b/drivers/acpi/nfit/core.c
index f8c638f3c946..2225e3de33ac 100644
--- a/drivers/acpi/nfit/core.c
+++ b/drivers/acpi/nfit/core.c
@@ -2825,11 +2825,15 @@ static int acpi_nfit_register_region(struct acpi_nfit_desc *acpi_desc,
 	ndr_desc->res = &res;
 	ndr_desc->provider_data = nfit_spa;
 	ndr_desc->attr_groups = acpi_nfit_region_attribute_groups;
-	if (spa->flags & ACPI_NFIT_PROXIMITY_VALID)
+	if (spa->flags & ACPI_NFIT_PROXIMITY_VALID) {
 		ndr_desc->numa_node = acpi_map_pxm_to_online_node(
 						spa->proximity_domain);
-	else
+		ndr_desc->target_node = acpi_map_pxm_to_node(
+				spa->proximity_domain);
+	} else {
 		ndr_desc->numa_node = NUMA_NO_NODE;
+		ndr_desc->target_node = NUMA_NO_NODE;
+	}
 
 	/*
 	 * Persistence domain bits are hierarchical, if
diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index 274699463b4f..b9d86babb13a 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -84,6 +84,7 @@ int acpi_map_pxm_to_node(int pxm)
 
 	return node;
 }
+EXPORT_SYMBOL(acpi_map_pxm_to_node);
 
 /**
  * acpi_map_pxm_to_online_node - Map proximity ID to online node
diff --git a/drivers/dax/bus.c b/drivers/dax/bus.c
index 568168500217..c620ad52d7e5 100644
--- a/drivers/dax/bus.c
+++ b/drivers/dax/bus.c
@@ -214,7 +214,7 @@ static void dax_region_unregister(void *region)
 }
 
 struct dax_region *alloc_dax_region(struct device *parent, int region_id,
-		struct resource *res, unsigned int align,
+		struct resource *res, int target_node, unsigned int align,
 		unsigned long pfn_flags)
 {
 	struct dax_region *dax_region;
@@ -244,6 +244,7 @@ struct dax_region *alloc_dax_region(struct device *parent, int region_id,
 	dax_region->id = region_id;
 	dax_region->align = align;
 	dax_region->dev = parent;
+	dax_region->target_node = target_node;
 	if (sysfs_create_groups(&parent->kobj, dax_region_attribute_groups)) {
 		kfree(dax_region);
 		return NULL;
@@ -348,6 +349,7 @@ struct dev_dax *__devm_create_dev_dax(struct dax_region *dax_region, int id,
 
 	dev_dax->dax_dev = dax_dev;
 	dev_dax->region = dax_region;
+	dev_dax->target_node = dax_region->target_node;
 	kref_get(&dax_region->kref);
 
 	inode = dax_inode(dax_dev);
diff --git a/drivers/dax/bus.h b/drivers/dax/bus.h
index ce977552ffb5..8619e3299943 100644
--- a/drivers/dax/bus.h
+++ b/drivers/dax/bus.h
@@ -10,7 +10,8 @@ struct dax_device;
 struct dax_region;
 void dax_region_put(struct dax_region *dax_region);
 struct dax_region *alloc_dax_region(struct device *parent, int region_id,
-		struct resource *res, unsigned int align, unsigned long flags);
+		struct resource *res, int target_node, unsigned int align,
+		unsigned long flags);
 
 enum dev_dax_subsys {
 	DEV_DAX_BUS,
diff --git a/drivers/dax/dax-private.h b/drivers/dax/dax-private.h
index a82ce48f5884..a45612148ca0 100644
--- a/drivers/dax/dax-private.h
+++ b/drivers/dax/dax-private.h
@@ -26,6 +26,7 @@ void dax_bus_exit(void);
 /**
  * struct dax_region - mapping infrastructure for dax devices
  * @id: kernel-wide unique region for a memory range
+ * @target_node: effective numa node if this memory range is onlined
  * @kref: to pin while other agents have a need to do lookups
  * @dev: parent device backing this region
  * @align: allocation and mapping alignment for child dax devices
@@ -34,6 +35,7 @@ void dax_bus_exit(void);
  */
 struct dax_region {
 	int id;
+	int target_node;
 	struct kref kref;
 	struct device *dev;
 	unsigned int align;
@@ -46,6 +48,7 @@ struct dax_region {
  * data while the device is activated in the driver.
  * @region - parent region
  * @dax_dev - core dax functionality
+ * @target_node: effective numa node if dev_dax memory range is onlined
  * @dev - device core
  * @pgmap - pgmap for memmap setup / lifetime (driver owned)
  * @ref: pgmap reference count (driver owned)
@@ -54,6 +57,7 @@ struct dax_region {
 struct dev_dax {
 	struct dax_region *region;
 	struct dax_device *dax_dev;
+	int target_node;
 	struct device dev;
 	struct dev_pagemap pgmap;
 	struct percpu_ref ref;
diff --git a/drivers/dax/pmem/core.c b/drivers/dax/pmem/core.c
index bdcff1b14e95..f71019ce0647 100644
--- a/drivers/dax/pmem/core.c
+++ b/drivers/dax/pmem/core.c
@@ -20,6 +20,7 @@ struct dev_dax *__dax_pmem_probe(struct device *dev, enum dev_dax_subsys subsys)
 	struct nd_namespace_common *ndns;
 	struct nd_dax *nd_dax = to_nd_dax(dev);
 	struct nd_pfn *nd_pfn = &nd_dax->nd_pfn;
+	struct nd_region *nd_region = to_nd_region(dev->parent);
 
 	ndns = nvdimm_namespace_common_probe(dev);
 	if (IS_ERR(ndns))
@@ -52,7 +53,8 @@ struct dev_dax *__dax_pmem_probe(struct device *dev, enum dev_dax_subsys subsys)
 	memcpy(&res, &pgmap.res, sizeof(res));
 	res.start += offset;
 	dax_region = alloc_dax_region(dev, region_id, &res,
-			le32_to_cpu(pfn_sb->align), PFN_DEV|PFN_MAP);
+			nd_region->target_node, le32_to_cpu(pfn_sb->align),
+			PFN_DEV|PFN_MAP);
 	if (!dax_region)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/drivers/nvdimm/e820.c b/drivers/nvdimm/e820.c
index 521eaf53a52a..36be9b619187 100644
--- a/drivers/nvdimm/e820.c
+++ b/drivers/nvdimm/e820.c
@@ -47,6 +47,7 @@ static int e820_register_one(struct resource *res, void *data)
 	ndr_desc.res = res;
 	ndr_desc.attr_groups = e820_pmem_region_attribute_groups;
 	ndr_desc.numa_node = e820_range_to_nid(res->start);
+	ndr_desc.target_node = ndr_desc.numa_node;
 	set_bit(ND_REGION_PAGEMAP, &ndr_desc.flags);
 	if (!nvdimm_pmem_region_create(nvdimm_bus, &ndr_desc))
 		return -ENXIO;
diff --git a/drivers/nvdimm/nd.h b/drivers/nvdimm/nd.h
index e79cc8e5c114..623216545cc8 100644
--- a/drivers/nvdimm/nd.h
+++ b/drivers/nvdimm/nd.h
@@ -153,7 +153,7 @@ struct nd_region {
 	u16 ndr_mappings;
 	u64 ndr_size;
 	u64 ndr_start;
-	int id, num_lanes, ro, numa_node;
+	int id, num_lanes, ro, numa_node, target_node;
 	void *provider_data;
 	struct kernfs_node *bb_state;
 	struct badblocks bb;
diff --git a/drivers/nvdimm/of_pmem.c b/drivers/nvdimm/of_pmem.c
index 0a701837dfc0..ecaaa27438e2 100644
--- a/drivers/nvdimm/of_pmem.c
+++ b/drivers/nvdimm/of_pmem.c
@@ -68,6 +68,7 @@ static int of_pmem_region_probe(struct platform_device *pdev)
 		memset(&ndr_desc, 0, sizeof(ndr_desc));
 		ndr_desc.attr_groups = region_attr_groups;
 		ndr_desc.numa_node = dev_to_node(&pdev->dev);
+		ndr_desc.target_node = ndr_desc.numa_node;
 		ndr_desc.res = &pdev->resource[i];
 		ndr_desc.of_node = np;
 		set_bit(ND_REGION_PAGEMAP, &ndr_desc.flags);
diff --git a/drivers/nvdimm/region_devs.c b/drivers/nvdimm/region_devs.c
index 174a418cb171..86cd425b786d 100644
--- a/drivers/nvdimm/region_devs.c
+++ b/drivers/nvdimm/region_devs.c
@@ -1060,6 +1060,7 @@ static struct nd_region *nd_region_create(struct nvdimm_bus *nvdimm_bus,
 	nd_region->flags = ndr_desc->flags;
 	nd_region->ro = ro;
 	nd_region->numa_node = ndr_desc->numa_node;
+	nd_region->target_node = ndr_desc->target_node;
 	ida_init(&nd_region->ns_ida);
 	ida_init(&nd_region->btt_ida);
 	ida_init(&nd_region->pfn_ida);
diff --git a/include/linux/libnvdimm.h b/include/linux/libnvdimm.h
index 097072c5a852..941102c0c81f 100644
--- a/include/linux/libnvdimm.h
+++ b/include/linux/libnvdimm.h
@@ -124,6 +124,7 @@ struct nd_region_desc {
 	void *provider_data;
 	int num_lanes;
 	int numa_node;
+	int target_node;
 	unsigned long flags;
 	struct device_node *of_node;
 };
