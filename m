Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id EB32D828DF
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 16:53:39 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fi3so19952128pac.3
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 13:53:39 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id ut6si594367pac.241.2016.03.03.13.53.38
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 13:53:39 -0800 (PST)
Subject: [PATCH v2 2/3] libnvdimm,
 pmem: adjust for section collisions with 'System RAM'
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 03 Mar 2016 13:53:15 -0800
Message-ID: <20160303215315.1014.95661.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <20160303215304.1014.69931.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <20160303215304.1014.69931.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>

On a platform where 'Persistent Memory' and 'System RAM' are mixed
within a given sparsemem section, trim the namespace and notify about the
sub-optimal alignment.

Cc: Toshi Kani <toshi.kani@hpe.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/nvdimm/namespace_devs.c |    7 ++
 drivers/nvdimm/pfn.h            |   10 ++-
 drivers/nvdimm/pfn_devs.c       |    5 ++
 drivers/nvdimm/pmem.c           |  125 ++++++++++++++++++++++++++++-----------
 4 files changed, 111 insertions(+), 36 deletions(-)

diff --git a/drivers/nvdimm/namespace_devs.c b/drivers/nvdimm/namespace_devs.c
index 8ebfcaae3f5a..463756ca2d4b 100644
--- a/drivers/nvdimm/namespace_devs.c
+++ b/drivers/nvdimm/namespace_devs.c
@@ -133,6 +133,7 @@ bool nd_is_uuid_unique(struct device *dev, u8 *uuid)
 bool pmem_should_map_pages(struct device *dev)
 {
 	struct nd_region *nd_region = to_nd_region(dev->parent);
+	struct nd_namespace_io *nsio;
 
 	if (!IS_ENABLED(CONFIG_ZONE_DEVICE))
 		return false;
@@ -143,6 +144,12 @@ bool pmem_should_map_pages(struct device *dev)
 	if (is_nd_pfn(dev) || is_nd_btt(dev))
 		return false;
 
+	nsio = to_nd_namespace_io(dev);
+	if (region_intersects(nsio->res.start, resource_size(&nsio->res),
+				IORESOURCE_SYSTEM_RAM,
+				IORES_DESC_NONE) == REGION_MIXED)
+		return false;
+
 #ifdef ARCH_MEMREMAP_PMEM
 	return ARCH_MEMREMAP_PMEM == MEMREMAP_WB;
 #else
diff --git a/drivers/nvdimm/pfn.h b/drivers/nvdimm/pfn.h
index 6ee707e5b279..8e343a3ca873 100644
--- a/drivers/nvdimm/pfn.h
+++ b/drivers/nvdimm/pfn.h
@@ -27,10 +27,13 @@ struct nd_pfn_sb {
 	__le32 flags;
 	__le16 version_major;
 	__le16 version_minor;
-	__le64 dataoff;
+	__le64 dataoff; /* relative to namespace_base + start_pad */
 	__le64 npfns;
 	__le32 mode;
-	u8 padding[4012];
+	/* minor-version-1 additions for section alignment */
+	__le32 start_pad;
+	__le32 end_trunc;
+	u8 padding[4004];
 	__le64 checksum;
 };
 
@@ -45,4 +48,7 @@ struct nd_pfn_sb {
 #define PFN_SECTION_ALIGN_DOWN(x) (x)
 #define PFN_SECTION_ALIGN_UP(x) (x)
 #endif
+
+#define PHYS_SECTION_ALIGN_DOWN(x) PFN_PHYS(PFN_SECTION_ALIGN_DOWN(PHYS_PFN(x)))
+#define PHYS_SECTION_ALIGN_UP(x) PFN_PHYS(PFN_SECTION_ALIGN_UP(PHYS_PFN(x)))
 #endif /* __NVDIMM_PFN_H */
diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index 0cc9048b86e2..14642617a153 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -299,6 +299,11 @@ int nd_pfn_validate(struct nd_pfn *nd_pfn)
 	if (memcmp(pfn_sb->parent_uuid, parent_uuid, 16) != 0)
 		return -ENODEV;
 
+	if (__le16_to_cpu(pfn_sb->version_minor) < 1) {
+		pfn_sb->start_pad = 0;
+		pfn_sb->end_trunc = 0;
+	}
+
 	switch (le32_to_cpu(pfn_sb->mode)) {
 	case PFN_MODE_RAM:
 		break;
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 68a20b2e3d03..15ec290bd23b 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -43,7 +43,10 @@ struct pmem_device {
 	phys_addr_t		data_offset;
 	unsigned long		pfn_flags;
 	void __pmem		*virt_addr;
+	/* immutable base size of the namespace */
 	size_t			size;
+	/* trim size when namespace capacity has been section aligned */
+	u32			pfn_pad;
 	struct badblocks	bb;
 };
 
@@ -145,7 +148,7 @@ static long pmem_direct_access(struct block_device *bdev, sector_t sector,
 	*kaddr = pmem->virt_addr + offset;
 	*pfn = phys_to_pfn_t(pmem->phys_addr + offset, pmem->pfn_flags);
 
-	return pmem->size - offset;
+	return pmem->size - pmem->pfn_pad - offset;
 }
 
 static const struct block_device_operations pmem_fops = {
@@ -236,7 +239,8 @@ static int pmem_attach_disk(struct device *dev,
 	disk->flags		= GENHD_FL_EXT_DEVT;
 	nvdimm_namespace_disk_name(ndns, disk->disk_name);
 	disk->driverfs_dev = dev;
-	set_capacity(disk, (pmem->size - pmem->data_offset) / 512);
+	set_capacity(disk, (pmem->size - pmem->pfn_pad - pmem->data_offset)
+			/ 512);
 	pmem->pmem_disk = disk;
 	devm_exit_badblocks(dev, &pmem->bb);
 	if (devm_init_badblocks(dev, &pmem->bb))
@@ -279,6 +283,9 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 	struct nd_pfn_sb *pfn_sb = kzalloc(sizeof(*pfn_sb), GFP_KERNEL);
 	struct pmem_device *pmem = dev_get_drvdata(&nd_pfn->dev);
 	struct nd_namespace_common *ndns = nd_pfn->ndns;
+	u32 start_pad = 0, end_trunc = 0;
+	resource_size_t start, size;
+	struct nd_namespace_io *nsio;
 	struct nd_region *nd_region;
 	unsigned long npfns;
 	phys_addr_t offset;
@@ -304,21 +311,56 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 	}
 
 	memset(pfn_sb, 0, sizeof(*pfn_sb));
-	npfns = (pmem->size - SZ_8K) / SZ_4K;
+
+	/*
+	 * Check if pmem collides with 'System RAM' when section aligned and
+	 * trim it accordingly
+	 */
+	nsio = to_nd_namespace_io(&ndns->dev);
+	start = PHYS_SECTION_ALIGN_DOWN(nsio->res.start);
+	size = resource_size(&nsio->res);
+	if (region_intersects(start, size, IORESOURCE_SYSTEM_RAM,
+				IORES_DESC_NONE) == REGION_MIXED) {
+
+		start = nsio->res.start;
+		start_pad = PHYS_SECTION_ALIGN_UP(start) - start;
+	}
+
+	start = nsio->res.start;
+	size = PHYS_SECTION_ALIGN_UP(start + size) - start;
+	if (region_intersects(start, size, IORESOURCE_SYSTEM_RAM,
+				IORES_DESC_NONE) == REGION_MIXED) {
+		size = resource_size(&nsio->res);
+		end_trunc = start + size - PHYS_SECTION_ALIGN_DOWN(start + size);
+	}
+
+	if (start_pad + end_trunc)
+		dev_info(&nd_pfn->dev, "%s section collision, truncate %d bytes\n",
+				dev_name(&ndns->dev), start_pad + end_trunc);
+
 	/*
 	 * Note, we use 64 here for the standard size of struct page,
 	 * debugging options may cause it to be larger in which case the
 	 * implementation will limit the pfns advertised through
 	 * ->direct_access() to those that are included in the memmap.
 	 */
+	start += start_pad;
+	npfns = (pmem->size - start_pad - end_trunc - SZ_8K) / SZ_4K;
 	if (nd_pfn->mode == PFN_MODE_PMEM)
-		offset = ALIGN(SZ_8K + 64 * npfns, nd_pfn->align);
+		offset = ALIGN(start + SZ_8K + 64 * npfns, nd_pfn->align)
+			- start;
 	else if (nd_pfn->mode == PFN_MODE_RAM)
-		offset = ALIGN(SZ_8K, nd_pfn->align);
+		offset = ALIGN(start + SZ_8K, nd_pfn->align) - start;
 	else
 		goto err;
 
-	npfns = (pmem->size - offset) / SZ_4K;
+	if (offset + start_pad + end_trunc >= pmem->size) {
+		dev_err(&nd_pfn->dev, "%s unable to satisfy requested alignment\n",
+				dev_name(&ndns->dev));
+		goto err;
+	}
+
+	npfns = (pmem->size - offset - start_pad - end_trunc) / SZ_4K;
 	pfn_sb->mode = cpu_to_le32(nd_pfn->mode);
 	pfn_sb->dataoff = cpu_to_le64(offset);
 	pfn_sb->npfns = cpu_to_le64(npfns);
@@ -326,6 +368,9 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 	memcpy(pfn_sb->uuid, nd_pfn->uuid, 16);
 	memcpy(pfn_sb->parent_uuid, nd_dev_to_uuid(&ndns->dev), 16);
 	pfn_sb->version_major = cpu_to_le16(1);
+	pfn_sb->version_minor = cpu_to_le16(1);
+	pfn_sb->start_pad = cpu_to_le32(start_pad);
+	pfn_sb->end_trunc = cpu_to_le32(end_trunc);
 	checksum = nd_sb_checksum((struct nd_gen_sb *) pfn_sb);
 	pfn_sb->checksum = cpu_to_le64(checksum);
 
@@ -376,41 +421,36 @@ static unsigned long init_altmap_reserve(resource_size_t base)
 	return reserve;
 }
 
-static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
+static int __nvdimm_namespace_attach_pfn(struct nd_pfn *nd_pfn)
 {
-	struct nd_namespace_io *nsio = to_nd_namespace_io(&ndns->dev);
-	struct nd_pfn *nd_pfn = to_nd_pfn(ndns->claim);
-	struct device *dev = &nd_pfn->dev;
-	struct nd_region *nd_region;
-	struct vmem_altmap *altmap;
-	struct nd_pfn_sb *pfn_sb;
-	struct pmem_device *pmem;
-	struct request_queue *q;
-	phys_addr_t offset;
 	int rc;
+	struct resource res;
+	struct request_queue *q;
+	struct pmem_device *pmem;
+	struct vmem_altmap *altmap;
+	struct device *dev = &nd_pfn->dev;
+	struct nd_pfn_sb *pfn_sb = nd_pfn->pfn_sb;
+	struct nd_namespace_common *ndns = nd_pfn->ndns;
+	u32 start_pad = __le32_to_cpu(pfn_sb->start_pad);
+	u32 end_trunc = __le32_to_cpu(pfn_sb->end_trunc);
+	struct nd_namespace_io *nsio = to_nd_namespace_io(&ndns->dev);
+	resource_size_t base = nsio->res.start + start_pad;
 	struct vmem_altmap __altmap = {
-		.base_pfn = init_altmap_base(nsio->res.start),
-		.reserve = init_altmap_reserve(nsio->res.start),
+		.base_pfn = init_altmap_base(base),
+		.reserve = init_altmap_reserve(base),
 	};
 
-	if (!nd_pfn->uuid || !nd_pfn->ndns)
-		return -ENODEV;
-
-	nd_region = to_nd_region(dev->parent);
-	rc = nd_pfn_init(nd_pfn);
-	if (rc)
-		return rc;
-
-	pfn_sb = nd_pfn->pfn_sb;
-	offset = le64_to_cpu(pfn_sb->dataoff);
+	pmem = dev_get_drvdata(dev);
+	pmem->data_offset = le64_to_cpu(pfn_sb->dataoff);
+	pmem->pfn_pad = start_pad + end_trunc;
 	nd_pfn->mode = le32_to_cpu(nd_pfn->pfn_sb->mode);
 	if (nd_pfn->mode == PFN_MODE_RAM) {
-		if (offset < SZ_8K)
+		if (pmem->data_offset < SZ_8K)
 			return -EINVAL;
 		nd_pfn->npfns = le64_to_cpu(pfn_sb->npfns);
 		altmap = NULL;
 	} else if (nd_pfn->mode == PFN_MODE_PMEM) {
-		nd_pfn->npfns = (resource_size(&nsio->res) - offset)
+		nd_pfn->npfns = (pmem->size - pmem->pfn_pad - pmem->data_offset)
 			/ PAGE_SIZE;
 		if (le64_to_cpu(nd_pfn->pfn_sb->npfns) > nd_pfn->npfns)
 			dev_info(&nd_pfn->dev,
@@ -418,7 +458,7 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
 					le64_to_cpu(nd_pfn->pfn_sb->npfns),
 					nd_pfn->npfns);
 		altmap = & __altmap;
-		altmap->free = __phys_to_pfn(offset - SZ_8K);
+		altmap->free = __phys_to_pfn(pmem->data_offset - SZ_8K);
 		altmap->alloc = 0;
 	} else {
 		rc = -ENXIO;
@@ -426,10 +466,12 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
 	}
 
 	/* establish pfn range for lookup, and switch to direct map */
-	pmem = dev_get_drvdata(dev);
 	q = pmem->pmem_queue;
+	memcpy(&res, &nsio->res, sizeof(res));
+	res.start += start_pad;
+	res.end -= end_trunc;
 	devm_memunmap(dev, (void __force *) pmem->virt_addr);
-	pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, &nsio->res,
+	pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, &res,
 			&q->q_usage_counter, altmap);
 	pmem->pfn_flags |= PFN_MAP;
 	if (IS_ERR(pmem->virt_addr)) {
@@ -438,7 +480,6 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
 	}
 
 	/* attach pmem disk in "pfn-mode" */
-	pmem->data_offset = offset;
 	rc = pmem_attach_disk(dev, ndns, pmem);
 	if (rc)
 		goto err;
@@ -447,6 +488,22 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
  err:
 	nvdimm_namespace_detach_pfn(ndns);
 	return rc;
+
+}
+
+static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
+{
+	struct nd_pfn *nd_pfn = to_nd_pfn(ndns->claim);
+	int rc;
+
+	if (!nd_pfn->uuid || !nd_pfn->ndns)
+		return -ENODEV;
+
+	rc = nd_pfn_init(nd_pfn);
+	if (rc)
+		return rc;
+	/* we need a valid pfn_sb before we can init a vmem_altmap */
+	return __nvdimm_namespace_attach_pfn(nd_pfn);
 }
 
 static int nd_pmem_probe(struct device *dev)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
