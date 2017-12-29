Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A4C416B0273
	for <linux-mm@kvack.org>; Fri, 29 Dec 2017 02:55:29 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id n6so29909946pfg.19
        for <linux-mm@kvack.org>; Thu, 28 Dec 2017 23:55:29 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id s28si16949295pgn.24.2017.12.28.23.55.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Dec 2017 23:55:27 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 16/17] memremap: change devm_memremap_pages interface to use struct dev_pagemap
Date: Fri, 29 Dec 2017 08:54:05 +0100
Message-Id: <20171229075406.1936-17-hch@lst.de>
In-Reply-To: <20171229075406.1936-1-hch@lst.de>
References: <20171229075406.1936-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Michal Hocko <mhocko@kernel.org>, linux-nvdimm@lists.01.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This new interface is similar to how struct device (and many others)
work. The caller initializes a 'struct dev_pagemap' as required
and calls 'devm_memremap_pages'. This allows the pagemap structure to
be embedded in another structure and thus container_of can be used. In
this way application specific members can be stored in a containing
struct.

This will be used by the P2P infrastructure and HMM could probably
be cleaned up to use it as well (instead of having it's own, similar
'hmm_devmem_pages_create' function).

Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/pmem.c                | 20 ++++++++-------
 drivers/nvdimm/nd.h               |  9 +++----
 drivers/nvdimm/pfn_devs.c         | 27 ++++++++++++---------
 drivers/nvdimm/pmem.c             | 37 +++++++++++++++-------------
 drivers/nvdimm/pmem.h             |  1 +
 include/linux/memremap.h          |  6 ++---
 kernel/memremap.c                 | 51 ++++++++++++++++-----------------------
 tools/testing/nvdimm/test/iomap.c |  7 +++---
 8 files changed, 77 insertions(+), 81 deletions(-)

diff --git a/drivers/dax/pmem.c b/drivers/dax/pmem.c
index 8d8c852ba8f2..31b6ecce4c64 100644
--- a/drivers/dax/pmem.c
+++ b/drivers/dax/pmem.c
@@ -21,6 +21,7 @@
 struct dax_pmem {
 	struct device *dev;
 	struct percpu_ref ref;
+	struct dev_pagemap pgmap;
 	struct completion cmp;
 };
 
@@ -69,20 +70,23 @@ static int dax_pmem_probe(struct device *dev)
 	struct nd_namespace_common *ndns;
 	struct nd_dax *nd_dax = to_nd_dax(dev);
 	struct nd_pfn *nd_pfn = &nd_dax->nd_pfn;
-	struct vmem_altmap __altmap, *altmap = NULL;
 
 	ndns = nvdimm_namespace_common_probe(dev);
 	if (IS_ERR(ndns))
 		return PTR_ERR(ndns);
 	nsio = to_nd_namespace_io(&ndns->dev);
 
+	dax_pmem = devm_kzalloc(dev, sizeof(*dax_pmem), GFP_KERNEL);
+	if (!dax_pmem)
+		return -ENOMEM;
+
 	/* parse the 'pfn' info block via ->rw_bytes */
 	rc = devm_nsio_enable(dev, nsio);
 	if (rc)
 		return rc;
-	altmap = nvdimm_setup_pfn(nd_pfn, &res, &__altmap);
-	if (IS_ERR(altmap))
-		return PTR_ERR(altmap);
+	rc = nvdimm_setup_pfn(nd_pfn, &dax_pmem->pgmap);
+	if (rc)
+		return rc;
 	devm_nsio_disable(dev, nsio);
 
 	pfn_sb = nd_pfn->pfn_sb;
@@ -94,10 +98,6 @@ static int dax_pmem_probe(struct device *dev)
 		return -EBUSY;
 	}
 
-	dax_pmem = devm_kzalloc(dev, sizeof(*dax_pmem), GFP_KERNEL);
-	if (!dax_pmem)
-		return -ENOMEM;
-
 	dax_pmem->dev = dev;
 	init_completion(&dax_pmem->cmp);
 	rc = percpu_ref_init(&dax_pmem->ref, dax_pmem_percpu_release, 0,
@@ -110,7 +110,8 @@ static int dax_pmem_probe(struct device *dev)
 	if (rc)
 		return rc;
 
-	addr = devm_memremap_pages(dev, &res, &dax_pmem->ref, altmap);
+	dax_pmem->pgmap.ref = &dax_pmem->ref;
+	addr = devm_memremap_pages(dev, &dax_pmem->pgmap);
 	if (IS_ERR(addr))
 		return PTR_ERR(addr);
 
@@ -120,6 +121,7 @@ static int dax_pmem_probe(struct device *dev)
 		return rc;
 
 	/* adjust the dax_region resource to the start of data */
+	memcpy(&res, &dax_pmem->pgmap.res, sizeof(res));
 	res.start += le64_to_cpu(pfn_sb->dataoff);
 
 	rc = sscanf(dev_name(&ndns->dev), "namespace%d.%d", &region_id, &id);
diff --git a/drivers/nvdimm/nd.h b/drivers/nvdimm/nd.h
index e958f3724c41..8d6375ee0fda 100644
--- a/drivers/nvdimm/nd.h
+++ b/drivers/nvdimm/nd.h
@@ -368,15 +368,14 @@ unsigned int pmem_sector_size(struct nd_namespace_common *ndns);
 void nvdimm_badblocks_populate(struct nd_region *nd_region,
 		struct badblocks *bb, const struct resource *res);
 #if IS_ENABLED(CONFIG_ND_CLAIM)
-struct vmem_altmap *nvdimm_setup_pfn(struct nd_pfn *nd_pfn,
-		struct resource *res, struct vmem_altmap *altmap);
+int nvdimm_setup_pfn(struct nd_pfn *nd_pfn, struct dev_pagemap *pgmap);
 int devm_nsio_enable(struct device *dev, struct nd_namespace_io *nsio);
 void devm_nsio_disable(struct device *dev, struct nd_namespace_io *nsio);
 #else
-static inline struct vmem_altmap *nvdimm_setup_pfn(struct nd_pfn *nd_pfn,
-		struct resource *res, struct vmem_altmap *altmap)
+static inline int nvdimm_setup_pfn(struct nd_pfn *nd_pfn,
+				   struct dev_pagemap *pgmap)
 {
-	return ERR_PTR(-ENXIO);
+	return -ENXIO;
 }
 static inline int devm_nsio_enable(struct device *dev,
 		struct nd_namespace_io *nsio)
diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index 2adada1a5855..f5c4e8c6e29d 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -542,9 +542,10 @@ static unsigned long init_altmap_reserve(resource_size_t base)
 	return reserve;
 }
 
-static struct vmem_altmap *__nvdimm_setup_pfn(struct nd_pfn *nd_pfn,
-		struct resource *res, struct vmem_altmap *altmap)
+static int __nvdimm_setup_pfn(struct nd_pfn *nd_pfn, struct dev_pagemap *pgmap)
 {
+	struct resource *res = &pgmap->res;
+	struct vmem_altmap *altmap = &pgmap->altmap;
 	struct nd_pfn_sb *pfn_sb = nd_pfn->pfn_sb;
 	u64 offset = le64_to_cpu(pfn_sb->dataoff);
 	u32 start_pad = __le32_to_cpu(pfn_sb->start_pad);
@@ -561,11 +562,13 @@ static struct vmem_altmap *__nvdimm_setup_pfn(struct nd_pfn *nd_pfn,
 	res->start += start_pad;
 	res->end -= end_trunc;
 
+	pgmap->type = MEMORY_DEVICE_HOST;
+
 	if (nd_pfn->mode == PFN_MODE_RAM) {
 		if (offset < SZ_8K)
-			return ERR_PTR(-EINVAL);
+			return -EINVAL;
 		nd_pfn->npfns = le64_to_cpu(pfn_sb->npfns);
-		altmap = NULL;
+		pgmap->altmap_valid = false;
 	} else if (nd_pfn->mode == PFN_MODE_PMEM) {
 		nd_pfn->npfns = PFN_SECTION_ALIGN_UP((resource_size(res)
 					- offset) / PAGE_SIZE);
@@ -577,10 +580,11 @@ static struct vmem_altmap *__nvdimm_setup_pfn(struct nd_pfn *nd_pfn,
 		memcpy(altmap, &__altmap, sizeof(*altmap));
 		altmap->free = PHYS_PFN(offset - SZ_8K);
 		altmap->alloc = 0;
+		pgmap->altmap_valid = true;
 	} else
-		return ERR_PTR(-ENXIO);
+		return -ENXIO;
 
-	return altmap;
+	return 0;
 }
 
 static u64 phys_pmem_align_down(struct nd_pfn *nd_pfn, u64 phys)
@@ -708,19 +712,18 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
  * Determine the effective resource range and vmem_altmap from an nd_pfn
  * instance.
  */
-struct vmem_altmap *nvdimm_setup_pfn(struct nd_pfn *nd_pfn,
-		struct resource *res, struct vmem_altmap *altmap)
+int nvdimm_setup_pfn(struct nd_pfn *nd_pfn, struct dev_pagemap *pgmap)
 {
 	int rc;
 
 	if (!nd_pfn->uuid || !nd_pfn->ndns)
-		return ERR_PTR(-ENODEV);
+		return -ENODEV;
 
 	rc = nd_pfn_init(nd_pfn);
 	if (rc)
-		return ERR_PTR(rc);
+		return rc;
 
-	/* we need a valid pfn_sb before we can init a vmem_altmap */
-	return __nvdimm_setup_pfn(nd_pfn, res, altmap);
+	/* we need a valid pfn_sb before we can init a dev_pagemap */
+	return __nvdimm_setup_pfn(nd_pfn, pgmap);
 }
 EXPORT_SYMBOL_GPL(nvdimm_setup_pfn);
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 7fbc5c5dc8e1..cf074b1ce219 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -298,34 +298,34 @@ static int pmem_attach_disk(struct device *dev,
 {
 	struct nd_namespace_io *nsio = to_nd_namespace_io(&ndns->dev);
 	struct nd_region *nd_region = to_nd_region(dev->parent);
-	struct vmem_altmap __altmap, *altmap = NULL;
 	int nid = dev_to_node(dev), fua, wbc;
 	struct resource *res = &nsio->res;
+	struct resource bb_res;
 	struct nd_pfn *nd_pfn = NULL;
 	struct dax_device *dax_dev;
 	struct nd_pfn_sb *pfn_sb;
 	struct pmem_device *pmem;
-	struct resource pfn_res;
 	struct request_queue *q;
 	struct device *gendev;
 	struct gendisk *disk;
 	void *addr;
+	int rc;
+
+	pmem = devm_kzalloc(dev, sizeof(*pmem), GFP_KERNEL);
+	if (!pmem)
+		return -ENOMEM;
 
 	/* while nsio_rw_bytes is active, parse a pfn info block if present */
 	if (is_nd_pfn(dev)) {
 		nd_pfn = to_nd_pfn(dev);
-		altmap = nvdimm_setup_pfn(nd_pfn, &pfn_res, &__altmap);
-		if (IS_ERR(altmap))
-			return PTR_ERR(altmap);
+		rc = nvdimm_setup_pfn(nd_pfn, &pmem->pgmap);
+		if (rc)
+			return rc;
 	}
 
 	/* we're attaching a block device, disable raw namespace access */
 	devm_nsio_disable(dev, nsio);
 
-	pmem = devm_kzalloc(dev, sizeof(*pmem), GFP_KERNEL);
-	if (!pmem)
-		return -ENOMEM;
-
 	dev_set_drvdata(dev, pmem);
 	pmem->phys_addr = res->start;
 	pmem->size = resource_size(res);
@@ -350,19 +350,22 @@ static int pmem_attach_disk(struct device *dev,
 		return -ENOMEM;
 
 	pmem->pfn_flags = PFN_DEV;
+	pmem->pgmap.ref = &q->q_usage_counter;
 	if (is_nd_pfn(dev)) {
-		addr = devm_memremap_pages(dev, &pfn_res, &q->q_usage_counter,
-				altmap);
+		addr = devm_memremap_pages(dev, &pmem->pgmap);
 		pfn_sb = nd_pfn->pfn_sb;
 		pmem->data_offset = le64_to_cpu(pfn_sb->dataoff);
-		pmem->pfn_pad = resource_size(res) - resource_size(&pfn_res);
+		pmem->pfn_pad = resource_size(res) -
+			resource_size(&pmem->pgmap.res);
 		pmem->pfn_flags |= PFN_MAP;
-		res = &pfn_res; /* for badblocks populate */
-		res->start += pmem->data_offset;
+		memcpy(&bb_res, &pmem->pgmap.res, sizeof(bb_res));
+		bb_res.start += pmem->data_offset;
 	} else if (pmem_should_map_pages(dev)) {
-		addr = devm_memremap_pages(dev, &nsio->res,
-				&q->q_usage_counter, NULL);
+		memcpy(&pmem->pgmap.res, &nsio->res, sizeof(pmem->pgmap.res));
+		pmem->pgmap.altmap_valid = false;
+		addr = devm_memremap_pages(dev, &pmem->pgmap);
 		pmem->pfn_flags |= PFN_MAP;
+		memcpy(&bb_res, &pmem->pgmap.res, sizeof(bb_res));
 	} else
 		addr = devm_memremap(dev, pmem->phys_addr,
 				pmem->size, ARCH_MEMREMAP_PMEM);
@@ -401,7 +404,7 @@ static int pmem_attach_disk(struct device *dev,
 			/ 512);
 	if (devm_init_badblocks(dev, &pmem->bb))
 		return -ENOMEM;
-	nvdimm_badblocks_populate(nd_region, &pmem->bb, res);
+	nvdimm_badblocks_populate(nd_region, &pmem->bb, &bb_res);
 	disk->bb = &pmem->bb;
 
 	dax_dev = alloc_dax(pmem, disk->disk_name, &pmem_dax_ops);
diff --git a/drivers/nvdimm/pmem.h b/drivers/nvdimm/pmem.h
index 6a3cd2a10db6..a64ebc78b5df 100644
--- a/drivers/nvdimm/pmem.h
+++ b/drivers/nvdimm/pmem.h
@@ -22,6 +22,7 @@ struct pmem_device {
 	struct badblocks	bb;
 	struct dax_device	*dax_dev;
 	struct gendisk		*disk;
+	struct dev_pagemap	pgmap;
 };
 
 long __pmem_direct_access(struct pmem_device *pmem, pgoff_t pgoff,
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 1cb5f39d25c1..7b4899c06f49 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -123,8 +123,7 @@ struct dev_pagemap {
 };
 
 #ifdef CONFIG_ZONE_DEVICE
-void *devm_memremap_pages(struct device *dev, struct resource *res,
-		struct percpu_ref *ref, struct vmem_altmap *altmap);
+void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap);
 struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
 		struct dev_pagemap *pgmap);
 
@@ -134,8 +133,7 @@ void vmem_altmap_free(struct vmem_altmap *altmap, unsigned long nr_pfns);
 static inline bool is_zone_device_page(const struct page *page);
 #else
 static inline void *devm_memremap_pages(struct device *dev,
-		struct resource *res, struct percpu_ref *ref,
-		struct vmem_altmap *altmap)
+		struct dev_pagemap *pgmap)
 {
 	/*
 	 * Fail attempts to call devm_memremap_pages() without
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 9207c44cce20..a9a948cd3d7f 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -275,9 +275,10 @@ static unsigned long pfn_end(struct dev_pagemap *pgmap)
 #define for_each_device_pfn(pfn, map) \
 	for (pfn = pfn_first(map); pfn < pfn_end(map); pfn++)
 
-static void devm_memremap_pages_release(struct device *dev, void *data)
+static void devm_memremap_pages_release(void *data)
 {
 	struct dev_pagemap *pgmap = data;
+	struct device *dev = pgmap->dev;
 	struct resource *res = &pgmap->res;
 	resource_size_t align_start, align_size;
 	unsigned long pfn;
@@ -316,29 +317,34 @@ static struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
 /**
  * devm_memremap_pages - remap and provide memmap backing for the given resource
  * @dev: hosting device for @res
- * @res: "host memory" address range
- * @ref: a live per-cpu reference count
- * @altmap: optional descriptor for allocating the memmap from @res
+ * @pgmap: pointer to a struct dev_pgmap
  *
  * Notes:
- * 1/ @ref must be 'live' on entry and 'dead' before devm_memunmap_pages() time
- *    (or devm release event). The expected order of events is that @ref has
+ * 1/ At a minimum the res, ref and type members of @pgmap must be initialized
+ *    by the caller before passing it to this function
+ *
+ * 2/ The altmap field may optionally be initialized, in which case altmap_valid
+ *    must be set to true
+ *
+ * 3/ pgmap.ref must be 'live' on entry and 'dead' before devm_memunmap_pages()
+ *    time (or devm release event). The expected order of events is that ref has
  *    been through percpu_ref_kill() before devm_memremap_pages_release(). The
  *    wait for the completion of all references being dropped and
  *    percpu_ref_exit() must occur after devm_memremap_pages_release().
  *
- * 2/ @res is expected to be a host memory range that could feasibly be
+ * 4/ res is expected to be a host memory range that could feasibly be
  *    treated as a "System RAM" range, i.e. not a device mmio range, but
  *    this is not enforced.
  */
-void *devm_memremap_pages(struct device *dev, struct resource *res,
-		struct percpu_ref *ref, struct vmem_altmap *altmap)
+void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 {
 	resource_size_t align_start, align_size, align_end;
+	struct vmem_altmap *altmap = pgmap->altmap_valid ?
+			&pgmap->altmap : NULL;
 	unsigned long pfn, pgoff, order;
 	pgprot_t pgprot = PAGE_KERNEL;
-	struct dev_pagemap *pgmap;
 	int error, nid, is_ram, i = 0;
+	struct resource *res = &pgmap->res;
 
 	align_start = res->start & ~(SECTION_SIZE - 1);
 	align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
@@ -355,27 +361,10 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	if (is_ram == REGION_INTERSECTS)
 		return __va(res->start);
 
-	if (!ref)
+	if (!pgmap->ref)
 		return ERR_PTR(-EINVAL);
 
-	pgmap = devres_alloc_node(devm_memremap_pages_release,
-			sizeof(*pgmap), GFP_KERNEL, dev_to_node(dev));
-	if (!pgmap)
-		return ERR_PTR(-ENOMEM);
-
-	memcpy(&pgmap->res, res, sizeof(*res));
-
 	pgmap->dev = dev;
-	if (altmap) {
-		memcpy(&pgmap->altmap, altmap, sizeof(*altmap));
-		pgmap->altmap_valid = true;
-		altmap = &pgmap->altmap;
-	}
-	pgmap->ref = ref;
-	pgmap->type = MEMORY_DEVICE_HOST;
-	pgmap->page_fault = NULL;
-	pgmap->page_free = NULL;
-	pgmap->data = NULL;
 
 	mutex_lock(&pgmap_lock);
 	error = 0;
@@ -423,11 +412,13 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 		 */
 		list_del(&page->lru);
 		page->pgmap = pgmap;
-		percpu_ref_get(ref);
+		percpu_ref_get(pgmap->ref);
 		if (!(++i % 1024))
 			cond_resched();
 	}
-	devres_add(dev, pgmap);
+
+	devm_add_action(dev, devm_memremap_pages_release, pgmap);
+
 	return __va(res->start);
 
  err_add_memory:
diff --git a/tools/testing/nvdimm/test/iomap.c b/tools/testing/nvdimm/test/iomap.c
index e1f75a1914a1..ff9d3a5825e1 100644
--- a/tools/testing/nvdimm/test/iomap.c
+++ b/tools/testing/nvdimm/test/iomap.c
@@ -104,15 +104,14 @@ void *__wrap_devm_memremap(struct device *dev, resource_size_t offset,
 }
 EXPORT_SYMBOL(__wrap_devm_memremap);
 
-void *__wrap_devm_memremap_pages(struct device *dev, struct resource *res,
-		struct percpu_ref *ref, struct vmem_altmap *altmap)
+void *__wrap_devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 {
-	resource_size_t offset = res->start;
+	resource_size_t offset = pgmap->res.start;
 	struct nfit_test_resource *nfit_res = get_nfit_res(offset);
 
 	if (nfit_res)
 		return nfit_res->buf + offset - nfit_res->res.start;
-	return devm_memremap_pages(dev, res, ref, altmap);
+	return devm_memremap_pages(dev, pgmap);
 }
 EXPORT_SYMBOL(__wrap_devm_memremap_pages);
 
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
