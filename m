Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 89B2F6B025A
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 23:56:23 -0400 (EDT)
Received: by pdrh1 with SMTP id h1so14454478pdr.0
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 20:56:23 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id fl3si1509284pad.107.2015.08.12.20.56.22
        for <linux-mm@kvack.org>;
        Wed, 12 Aug 2015 20:56:22 -0700 (PDT)
Subject: [RFC PATCH 7/7] libnvdimm, pmem: 'struct page' for pmem
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 12 Aug 2015 23:50:39 -0400
Message-ID: <20150813035039.36913.42618.stgit@otcpl-skl-sds-2.jf.intel.com>
In-Reply-To: <20150813031253.36913.29580.stgit@otcpl-skl-sds-2.jf.intel.com>
References: <20150813031253.36913.29580.stgit@otcpl-skl-sds-2.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: boaz@plexistor.com, riel@redhat.com, linux-nvdimm@lists.01.org, david@fromorbit.com, mingo@kernel.org, linux-mm@kvack.org, mgorman@suse.de, ross.zwisler@linux.intel.com, torvalds@linux-foundation.org, hch@lst.de

Enable the pmem driver to handle PFN device instances.  Attaching a pmem
namespace to a pfn device triggers the driver to allocate and initialize
struct page entries for pmem.  Memory capacity for this allocation can
either come from RAM (if the mapped PMEM capacity is low), or from PMEM
(if the write endurance and relative performance concerns of PMEM are
low).

Given this adds a new call to devm_memunmap() the corresponding wrapper
is added to tools/testing/nvdimm/.

Cc: Boaz Harrosh <boaz@plexistor.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Christoph Hellwig <hch@lst.de>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/nvdimm/Kconfig            |    4 +
 drivers/nvdimm/pfn_devs.c         |    3 -
 drivers/nvdimm/pmem.c             |  213 ++++++++++++++++++++++++++++++++++++-
 tools/testing/nvdimm/Kbuild       |    1 
 tools/testing/nvdimm/test/iomap.c |   13 ++
 5 files changed, 225 insertions(+), 9 deletions(-)

diff --git a/drivers/nvdimm/Kconfig b/drivers/nvdimm/Kconfig
index 7e05f2657d09..87fbd693c68e 100644
--- a/drivers/nvdimm/Kconfig
+++ b/drivers/nvdimm/Kconfig
@@ -77,6 +77,10 @@ config ND_PFN
 config NVDIMM_PFN
 	bool "PFN: Map persistent (device) memory"
 	default LIBNVDIMM
+	depends on MEMORY_HOTPLUG
+	depends on MEMORY_HOTREMOVE
+	depends on X86_64 #arch_add_memory() comprehends device memory
+	depends on ZONE_DEVICE
 	select ND_CLAIM
 	help
 	  Map persistent memory, i.e. advertise it to the memory
diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index 41824b3bf0d2..b1319ed53642 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -227,7 +227,7 @@ struct device *nd_pfn_create(struct nd_region *nd_region)
 	return dev;
 }
 
-static int nd_pfn_validate(struct nd_pfn *nd_pfn)
+int nd_pfn_validate(struct nd_pfn *nd_pfn)
 {
 	struct nd_namespace_common *ndns = nd_pfn->ndns;
 	struct nd_pfn_sb *pfn_sb = nd_pfn->pfn_sb;
@@ -296,6 +296,7 @@ static int nd_pfn_validate(struct nd_pfn *nd_pfn)
 
 	return 0;
 }
+EXPORT_SYMBOL(nd_pfn_validate);
 
 int nd_pfn_probe(struct nd_namespace_common *ndns, void *drvdata)
 {
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 85d4101bb821..51867759b3f3 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -22,19 +22,24 @@
 #include <linux/platform_device.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
+#include <linux/vmalloc.h>
 #include <linux/slab.h>
 #include <linux/pmem.h>
 #include <linux/nd.h>
 #include <linux/mm.h>
 #include <linux/kmap_pfn.h>
+#include "pfn.h"
 #include "nd.h"
 
 struct pmem_device {
 	struct request_queue	*pmem_queue;
 	struct gendisk		*pmem_disk;
+	struct nd_namespace_common *ndns;
 
 	/* One contiguous memory region per device */
 	phys_addr_t		phys_addr;
+	/* when non-zero this device is hosting a 'pfn' instance */
+	phys_addr_t		data_offset;
 	void __pmem		*virt_addr;
 	size_t			size;
 };
@@ -46,7 +51,7 @@ static void pmem_do_bvec(struct pmem_device *pmem, struct page *page,
 			sector_t sector)
 {
 	void *mem = kmap_atomic(page);
-	size_t pmem_off = sector << 9;
+	phys_addr_t pmem_off = sector * 512 + pmem->data_offset;
 	void __pmem *pmem_addr = pmem->virt_addr + pmem_off;
 
 	if (rw == READ) {
@@ -97,10 +102,23 @@ static long pmem_direct_access(struct block_device *bdev, sector_t sector,
 		__pfn_t *pfn)
 {
 	struct pmem_device *pmem = bdev->bd_disk->private_data;
-	size_t offset = sector << 9;
-
-	*pfn = phys_to_pfn_t(pmem->phys_addr + offset, PFN_DEV);
-	return pmem->size - offset;
+	resource_size_t offset = sector * 512 + pmem->data_offset;
+	unsigned long flags = PFN_DEV;
+	resource_size_t size;
+
+	if (pmem->data_offset) {
+		flags |= PFN_MAP;
+		/*
+		 * Limit the direct_access() size to what is covered by
+		 * the memmap
+		 */
+		size = (pmem->size - offset) & ~ND_PFN_MASK;
+	} else
+		size = pmem->size - offset;
+
+	*pfn = phys_to_pfn_t(pmem->phys_addr + offset, flags);
+
+	return size;
 }
 
 static const struct block_device_operations pmem_fops = {
@@ -140,6 +158,9 @@ static struct pmem_device *pmem_alloc(struct device *dev,
 
 static void pmem_detach_disk(struct pmem_device *pmem)
 {
+	if (!pmem->pmem_disk)
+		return;
+
 	del_gendisk(pmem->pmem_disk);
 	put_disk(pmem->pmem_disk);
 	blk_cleanup_queue(pmem->pmem_queue);
@@ -181,7 +202,7 @@ static int pmem_attach_disk(struct device *dev,
 	disk->flags		= GENHD_FL_EXT_DEVT;
 	nvdimm_namespace_disk_name(ndns, disk->disk_name);
 	disk->driverfs_dev = &ndns->dev;
-	set_capacity(disk, pmem->size >> 9);
+	set_capacity(disk, (pmem->size - pmem->data_offset) / 512);
 	pmem->pmem_disk = disk;
 
 	add_disk(disk);
@@ -210,6 +231,170 @@ static int pmem_rw_bytes(struct nd_namespace_common *ndns,
 	return 0;
 }
 
+static int nd_pfn_init(struct nd_pfn *nd_pfn)
+{
+	struct nd_pfn_sb *pfn_sb = kzalloc(sizeof(*pfn_sb), GFP_KERNEL);
+	struct pmem_device *pmem = dev_get_drvdata(&nd_pfn->dev);
+	struct nd_namespace_common *ndns = nd_pfn->ndns;
+	struct nd_region *nd_region;
+	unsigned long npfns;
+	phys_addr_t offset;
+	u64 checksum;
+	int rc;
+
+	if (!pfn_sb)
+		return -ENOMEM;
+
+	nd_pfn->pfn_sb = pfn_sb;
+	rc = nd_pfn_validate(nd_pfn);
+	if (rc == 0 || rc == -EBUSY)
+		return rc;
+
+	/* section alignment for simple hotplug */
+	if (nvdimm_namespace_capacity(ndns) < ND_PFN_ALIGN
+			|| pmem->phys_addr & ND_PFN_MASK)
+		return -ENODEV;
+
+	nd_region = to_nd_region(nd_pfn->dev.parent);
+	if (nd_region->ro) {
+		dev_info(&nd_pfn->dev,
+				"%s is read-only, unable to init metadata\n",
+				dev_name(&nd_region->dev));
+		goto err;
+	}
+
+	memset(pfn_sb, 0, sizeof(*pfn_sb));
+	npfns = (pmem->size - SZ_8K) / SZ_4K;
+	/*
+	 * Note, we use 64 here for the standard size of struct page,
+	 * debugging options may cause it to be larger in which case the
+	 * implementation will limit the pfns advertised through
+	 * ->direct_access() to those that are included in the memmap.
+	 */
+	if (nd_pfn->mode == PFN_MODE_PMEM)
+		offset = SZ_8K + 64 * npfns;
+	else if (nd_pfn->mode == PFN_MODE_RAM)
+		offset = SZ_8K;
+	else
+		goto err;
+
+	offset = ALIGN(offset, PMD_SIZE);
+	npfns = (pmem->size - offset) / SZ_4K;
+	pfn_sb->mode = cpu_to_le32(nd_pfn->mode);
+	pfn_sb->dataoff = cpu_to_le64(offset);
+	pfn_sb->npfns = cpu_to_le64(npfns);
+	memcpy(pfn_sb->signature, PFN_SIG, PFN_SIG_LEN);
+	memcpy(pfn_sb->uuid, nd_pfn->uuid, 16);
+	pfn_sb->version_major = le16_to_cpu(1);
+	checksum = nd_sb_checksum((struct nd_gen_sb *) pfn_sb);
+	pfn_sb->checksum = cpu_to_le64(checksum);
+
+	return 0;
+ err:
+	nd_pfn->pfn_sb = NULL;
+	kfree(pfn_sb);
+	return -ENXIO;
+}
+
+static int nvdimm_namespace_detach_pfn(struct nd_namespace_common *ndns)
+{
+	struct nd_pfn *nd_pfn = to_nd_pfn(ndns->claim);
+	struct pmem_device *pmem;
+
+	/* free pmem disk */
+	pmem = dev_get_drvdata(&nd_pfn->dev);
+	pmem_detach_disk(pmem);
+
+	/* tear down pfn range / wait for per-cpu refcount to drop */
+	unregister_dev_memmap(nd_pfn->dev_map);
+
+	/* release nd_pfn resources */
+	kfree(nd_pfn->pfn_sb);
+	nd_pfn->pfn_sb = NULL;
+
+	return 0;
+}
+
+static noinline int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
+{
+	struct nd_namespace_io *nsio = to_nd_namespace_io(&ndns->dev);
+	struct nd_pfn *nd_pfn = to_nd_pfn(ndns->claim);
+	struct vmem_altmap *altmap;
+	struct nd_region *nd_region;
+	struct nd_pfn_sb *pfn_sb;
+	struct pmem_device *pmem;
+	struct dev_map *dev_map;
+	phys_addr_t offset;
+	int rc;
+	struct vmem_altmap __altmap = {
+		.base_pfn = __phys_to_pfn(nsio->res.start),
+		.reserve = __phys_to_pfn(SZ_8K),
+	};
+
+	if (!nd_pfn->uuid || !nd_pfn->ndns)
+		return -ENODEV;
+
+	nd_region = to_nd_region(nd_pfn->dev.parent);
+	rc = nd_pfn_init(nd_pfn);
+	if (rc)
+		return rc;
+
+	if (PAGE_SIZE != SZ_4K) {
+		dev_err(&nd_pfn->dev, "only supported on systems with 4K PAGE_SIZE\n");
+		return -ENXIO;
+	}
+	if (nsio->res.start & ND_PFN_MASK) {
+		dev_err(&nd_pfn->dev, "%s not memory hotplug section aligned\n",
+				dev_name(&ndns->dev));
+		return -ENXIO;
+	}
+
+	pfn_sb = nd_pfn->pfn_sb;
+	offset = le64_to_cpu(pfn_sb->dataoff);
+	if (nd_pfn->mode == PFN_MODE_PMEM) {
+		nd_pfn->npfns = (resource_size(&nsio->res) - offset)
+			/ PAGE_SIZE;
+		if (le64_to_cpu(nd_pfn->pfn_sb->npfns) > nd_pfn->npfns)
+			dev_info(&nd_pfn->dev,
+					"number of pfns truncated from %lld to %ld\n",
+					le64_to_cpu(nd_pfn->pfn_sb->npfns),
+					nd_pfn->npfns);
+		altmap = & __altmap;
+		altmap->free = __phys_to_pfn(offset - SZ_8K);
+		altmap->alloc = 0;
+	} else if (nd_pfn->mode == PFN_MODE_RAM) {
+		if (offset != SZ_8K)
+			return -EINVAL;
+		nd_pfn->npfns = le64_to_cpu(pfn_sb->npfns);
+		altmap = NULL;
+	} else {
+		rc = -ENXIO;
+		goto err;
+	}
+
+	/* establish pfn range for lookup, and switch to direct map */
+	pmem = dev_get_drvdata(&nd_pfn->dev);
+	memunmap_pmem(&nd_pfn->dev, pmem->virt_addr);
+	dev_map = register_dev_memmap(&nd_pfn->dev, &nsio->res, altmap);
+	if (!dev_map) {
+		rc = -ENOMEM;
+		goto err;
+	}
+	nd_pfn->dev_map = dev_map;
+	pmem->virt_addr = (void __pmem *) __va(pmem->phys_addr);
+
+	/* attach pmem disk in "pfn-mode" */
+	pmem->data_offset = offset;
+	rc = pmem_attach_disk(&nd_pfn->dev, ndns, pmem);
+	if (rc)
+		goto err;
+
+	return rc;
+ err:
+	nvdimm_namespace_detach_pfn(ndns);
+	return rc;
+}
+
 static int nd_pmem_probe(struct device *dev)
 {
 	struct nd_region *nd_region = to_nd_region(dev->parent);
@@ -226,15 +411,25 @@ static int nd_pmem_probe(struct device *dev)
 	if (IS_ERR(pmem))
 		return PTR_ERR(pmem);
 
+	pmem->ndns = ndns;
 	dev_set_drvdata(dev, pmem);
 	ndns->rw_bytes = pmem_rw_bytes;
 
 	if (is_nd_btt(dev))
 		return nvdimm_namespace_attach_btt(ndns);
 
-	if (nd_btt_probe(ndns, pmem) == 0)
+	if (is_nd_pfn(dev))
+		return nvdimm_namespace_attach_pfn(ndns);
+
+	if (nd_btt_probe(ndns, pmem) == 0) {
 		/* we'll come back as btt-pmem */
 		return -ENXIO;
+	}
+
+	if (nd_pfn_probe(ndns, pmem) == 0) {
+		/* we'll come back as pfn-pmem */
+		return -ENXIO;
+	}
 
 	return pmem_attach_disk(dev, ndns, pmem);
 }
@@ -244,7 +439,9 @@ static int nd_pmem_remove(struct device *dev)
 	struct pmem_device *pmem = dev_get_drvdata(dev);
 
 	if (is_nd_btt(dev))
-		nvdimm_namespace_detach_btt(to_nd_btt(dev)->ndns);
+		nvdimm_namespace_detach_btt(pmem->ndns);
+	else if (is_nd_pfn(dev))
+		nvdimm_namespace_detach_pfn(pmem->ndns);
 	else
 		pmem_detach_disk(pmem);
 
diff --git a/tools/testing/nvdimm/Kbuild b/tools/testing/nvdimm/Kbuild
index 22d4d19a49bc..eff633f8b6db 100644
--- a/tools/testing/nvdimm/Kbuild
+++ b/tools/testing/nvdimm/Kbuild
@@ -1,6 +1,7 @@
 ldflags-y += --wrap=ioremap_wc
 ldflags-y += --wrap=devm_ioremap_nocache
 ldflags-y += --wrap=devm_memremap
+ldflags-y += --wrap=devm_memunmap
 ldflags-y += --wrap=ioremap_nocache
 ldflags-y += --wrap=iounmap
 ldflags-y += --wrap=__devm_request_region
diff --git a/tools/testing/nvdimm/test/iomap.c b/tools/testing/nvdimm/test/iomap.c
index ff1e00458864..3609f6713075 100644
--- a/tools/testing/nvdimm/test/iomap.c
+++ b/tools/testing/nvdimm/test/iomap.c
@@ -95,6 +95,19 @@ void *__wrap_devm_memremap(struct device *dev, resource_size_t offset,
 }
 EXPORT_SYMBOL(__wrap_devm_memremap);
 
+void __wrap_devm_memunmap(struct device *dev, void *addr)
+{
+	struct nfit_test_resource *nfit_res;
+
+	rcu_read_lock();
+	nfit_res = get_nfit_res((unsigned long) addr);
+	rcu_read_unlock();
+	if (nfit_res)
+		return;
+	return devm_memunmap(dev, addr);
+}
+EXPORT_SYMBOL(__wrap_devm_memunmap);
+
 void __iomem *__wrap_ioremap_nocache(resource_size_t offset, unsigned long size)
 {
 	return __nfit_test_ioremap(offset, size, ioremap_nocache);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
