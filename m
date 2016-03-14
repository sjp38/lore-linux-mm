Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 941E56B0253
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 14:14:42 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id td3so135002725pab.2
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 11:14:42 -0700 (PDT)
Received: from bby1mta03.pmc-sierra.bc.ca (bby1mta03.pmc-sierra.com. [216.241.235.118])
        by mx.google.com with ESMTPS id 24si12307484pfn.204.2016.03.14.11.14.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 14 Mar 2016 11:14:41 -0700 (PDT)
From: Stephen Bates <stephen.bates@pmcs.com>
Subject: [PATCH RFC 1/1] Add support for ZONE_DEVICE IO memory with struct pages.
Date: Mon, 14 Mar 2016 12:14:37 -0600
Message-Id: <1457979277-26791-1-git-send-email-stephen.bates@pmcs.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-rdma@vger.kernel.org, linux-nvdimm@lists.01.org
Cc: stephen.bates@pmcs.com, logang@deltatee.com, jgunthorpe@obsidianresearch.com, dan.j.williams@intel.com, haggaie@mellanox.com, artemyko@mellanox.com, leonro@mellanox.com, sagig@mellanox.com, javier@cnexlabs.com, hch@infradead.org, ross.zwisler@linux.intel.com

From: Logan Gunthorpe <logang@deltatee.com>

Introduction
------------

This RFC patch adds struct page backing for IO memory and as such
allows IO memory to be used as a DMA target.

Patch Summary
-------------

We build on recent work done that adds memory regions owned by a device
driver (ZONE_DEVICE) [1] and to add struct page support for these new
regions of memory [2]. The patch should apply cleanly to 4.5-rc7.

1. Add a new flag (MEMREMAP_WC) to the enumerated type in include/io.h.

2. Add an extra flags argument into dev_memremap_pages to take in a
MEMREMAP_XX argument. We update the existing calls to this function to
reflect the change.

3. For completeness, we add MEMREMAP_WC support to the memremap;
however we have no actual need for this functionality.

4. We add the static functions, add_zone_device_pages and
remove_zone_device pages. These are similar to arch_add_memory except
they don't create the memory mapping. We don't believe these need to be
made arch specific, but are open to other opinions.

5. dev_memremap_pages and devm_memremap_pages_release are updated to
treat IO memory slightly differently. For IO memory we use a combination
of the appropriate io_remap function and the zone_device pages functions
created above. A flags variable and kaddr pointer are added to struct
page_mem to facilitate this for the release function.

Motivation and Use Cases
------------------------

PCIe IO devices are getting faster. It is not uncommon now to find PCIe
network and storage devices that can generate and consume several GB/s.
Almost always these devices have either a high performance DMA engine, a
number of exposed PCIe BARs or both.

Until this patch, any high-performance transfer of information between
two PICe devices has required the use of a staging buffer in system
memory. With this patch the bandwidth to system memory is not compromised
when high-throughput transfers occurs between PCIe devices. This means
that more system memory bandwidth is available to the CPU cores for data
processing and manipulation. In addition, in systems where the two PCIe
devices reside behind a PCIe switch the datapath avoids the CPU entirely.

Consumers
---------

In order to test this patch and to give an example of a consumer of this
patch we have developed a PCIe driver which can be used to bind to any
PCIe device that exposes IO memory via a PCIe BAR. A basic out of tree
module can be found at [3] which is intended only for testing and example
purposes. Assuming this RFC is received well, the first in-kernel user
would be a patchset which facilitates the Controller Memory Buffer (CMB)
feature for NVMe. This would enable RDMA devices to move data directly
to/from files on NVMe devices without the need for a round trip through
system memory.

The example out of tree module allows for the following accesses:

1. Block based access. For this we borrowed heavily from the pmem device
driver. Note that this mode allows for DAX filesystems to be mounted
on the block device. The driver uses devm_memremap_pages on a block of
PCIe memory such that files on this FS can then be mmapped using direct
access and used as a DMA target.

2. MMAP based access. The driver again uses devm_memremap_pages, then
hands out ZONE_DEVICE backed pages with its fault function. Thus, with
this patch, these mappings would now be usable as DMA targets.

Testing and Performance
-----------------------

We have done a moderate about of testing of this patch on a QEMU
environment and a real hardware environment. On real hardware we have
observed peer-to-peer writes of up to 4GB/s and reads of up to 1.2 GB/s.
In both cases these numbers are limitations of our consumer hardware. In
addtion, we have observed that the CPU DRAM bandwidth is not impacted
when using IOPMEM which is not the case when a traditional patch through
system memory is taken.

For more information on the testing and performance results see the
GitHub site [4].

Known Issues
------------

1. Address Translation. Suggestions have been made that in certain
architectures and topologies the dma_addr_t passed to the DMA master
in a peer-2-peer transfer will not correctly route to the IO memory
intended. However in our testing to date we have not seen this to be
an issue, even in systems with IOMMUs and PCIe switches. It is our
understanding that an IOMMU only maps system memory and would not
interfere with device memory regions. (It certainly has no opportunity
to do so if the transfer gets routed through a switch).

2. Memory Segment Spacing. This patch has the same limitations that
ZONE_DEVICE does in that memory regions must be spaces at least
SECTION_SIZE bytes part. On x86 this is 128MB and there are cases where
BARs can be placed closer together than this. Thus ZONE_DEVICE would not
be usable on neighboring BARs. For our purposes, this is not an issue as
we'd only be looking at enabling a single BAR in a given PCIe device.
More exotic use cases may have problems with this.

3. Coherency Issues. When IOMEM is written from both the CPU and a PCIe
peer there is potential for coherency issues and for writes to occur out
of order. This is something that users of this feature need to be
cognizant of and may necessitate the use of CONFIG_EXPERT. Though really,
this isn't much different than the existing situation with RDMA: if
userspace sets up an MR for remote use, they need to be careful about
using that memory region themselves.

4. Architecture. Currently this patch is applicable only to x86
architectures. The same is true for much of the code pertaining to
PMEM and ZONE_DEVICE. It is hoped that the work will be extended to other
ARCH over time.

References
----------

[1] https://lists.01.org/pipermail/linux-nvdimm/2015-August/001810.html
[2] https://lists.01.org/pipermail/linux-nvdimm/2015-October/002387.html
[3] https://github.com/sbates130272/linux-donard/tree/iopmem-rfc
[4] https://github.com/sbates130272/zone-device

Signed-off-by: Stephen Bates <stephen.bates@pmcs.com>
Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
---
 drivers/nvdimm/pmem.c    |  4 +--
 include/linux/io.h       |  1 +
 include/linux/memremap.h |  5 ++--
 kernel/memremap.c        | 78 ++++++++++++++++++++++++++++++++++++++++++++----
 4 files changed, 79 insertions(+), 9 deletions(-)

diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 8d0b546..095f358 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -184,7 +184,7 @@ static struct pmem_device *pmem_alloc(struct device *dev,
 	pmem->pfn_flags = PFN_DEV;
 	if (pmem_should_map_pages(dev)) {
 		pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, res,
-				&q->q_usage_counter, NULL);
+				&q->q_usage_counter, NULL, ARCH_MEMREMAP_PMEM);
 		pmem->pfn_flags |= PFN_MAP;
 	} else
 		pmem->virt_addr = (void __pmem *) devm_memremap(dev,
@@ -410,7 +410,7 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
 	q = pmem->pmem_queue;
 	devm_memunmap(dev, (void __force *) pmem->virt_addr);
 	pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, &nsio->res,
-			&q->q_usage_counter, altmap);
+			&q->q_usage_counter, altmap, ARCH_MEMREMAP_PMEM);
 	pmem->pfn_flags |= PFN_MAP;
 	if (IS_ERR(pmem->virt_addr)) {
 		rc = PTR_ERR(pmem->virt_addr);
diff --git a/include/linux/io.h b/include/linux/io.h
index 32403b5..e2c8419 100644
--- a/include/linux/io.h
+++ b/include/linux/io.h
@@ -135,6 +135,7 @@ enum {
 	/* See memremap() kernel-doc for usage description... */
 	MEMREMAP_WB = 1 << 0,
 	MEMREMAP_WT = 1 << 1,
+	MEMREMAP_WC = 1 << 2,
 };

 void *memremap(resource_size_t offset, size_t size, unsigned long flags);
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index bcaa634..ad5cf23 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -51,12 +51,13 @@ struct dev_pagemap {

 #ifdef CONFIG_ZONE_DEVICE
 void *devm_memremap_pages(struct device *dev, struct resource *res,
-		struct percpu_ref *ref, struct vmem_altmap *altmap);
+		struct percpu_ref *ref, struct vmem_altmap *altmap,
+		unsigned long flags);
 struct dev_pagemap *find_dev_pagemap(resource_size_t phys);
 #else
 static inline void *devm_memremap_pages(struct device *dev,
 		struct resource *res, struct percpu_ref *ref,
-		struct vmem_altmap *altmap)
+		struct vmem_altmap *altmap, unsigned long flags)
 {
 	/*
 	 * Fail attempts to call devm_memremap_pages() without
diff --git a/kernel/memremap.c b/kernel/memremap.c
index b981a7b..a739286 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -41,7 +41,7 @@ static void *try_ram_remap(resource_size_t offset, size_t size)
  * memremap() - remap an iomem_resource as cacheable memory
  * @offset: iomem resource start address
  * @size: size of remap
- * @flags: either MEMREMAP_WB or MEMREMAP_WT
+ * @flags: either MEMREMAP_WB, MEMREMAP_WT or MEMREMAP_WC
  *
  * memremap() is "ioremap" for cases where it is known that the resource
  * being mapped does not have i/o side effects and the __iomem
@@ -57,6 +57,9 @@ static void *try_ram_remap(resource_size_t offset, size_t size)
  * cache or are written through to memory and never exist in a
  * cache-dirty state with respect to program visibility.  Attempts to
  * map "System RAM" with this mapping type will fail.
+ *
+ * MEMREMAP_WC - like MEMREMAP_WT but enables write combining.
+ *
  */
 void *memremap(resource_size_t offset, size_t size, unsigned long flags)
 {
@@ -101,6 +104,12 @@ void *memremap(resource_size_t offset, size_t size, unsigned long flags)
 		addr = ioremap_wt(offset, size);
 	}

+
+	if (!addr && (flags & MEMREMAP_WC)) {
+		flags &= ~MEMREMAP_WC;
+		addr = ioremap_wc(offset, size);
+	}
+
 	return addr;
 }
 EXPORT_SYMBOL(memremap);
@@ -164,13 +173,41 @@ static RADIX_TREE(pgmap_radix, GFP_KERNEL);
 #define SECTION_MASK ~((1UL << PA_SECTION_SHIFT) - 1)
 #define SECTION_SIZE (1UL << PA_SECTION_SHIFT)

+enum {
+	PAGEMAP_IO_MEM = 1 << 0,
+};
+
 struct page_map {
 	struct resource res;
 	struct percpu_ref *ref;
 	struct dev_pagemap pgmap;
 	struct vmem_altmap altmap;
+	void *kaddr;
+	int flags;
 };

+static int add_zone_device_pages(int nid, u64 start, u64 size)
+{
+	struct pglist_data *pgdat = NODE_DATA(nid);
+	struct zone *zone = pgdat->node_zones + ZONE_DEVICE;
+	unsigned long start_pfn = start >> PAGE_SHIFT;
+	unsigned long nr_pages = size >> PAGE_SHIFT;
+
+	return __add_pages(nid, zone, start_pfn, nr_pages);
+}
+
+static void remove_zone_device_pages(u64 start, u64 size)
+{
+	unsigned long start_pfn = start >> PAGE_SHIFT;
+	unsigned long nr_pages = size >> PAGE_SHIFT;
+	struct zone *zone;
+	int ret;
+
+	zone = page_zone(pfn_to_page(start_pfn));
+	ret = __remove_pages(zone, start_pfn, nr_pages);
+	WARN_ON_ONCE(ret);
+}
+
 void get_zone_device_page(struct page *page)
 {
 	percpu_ref_get(page->pgmap->ref);
@@ -235,8 +272,15 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
 	/* pages are dead and unused, undo the arch mapping */
 	align_start = res->start & ~(SECTION_SIZE - 1);
 	align_size = ALIGN(resource_size(res), SECTION_SIZE);
-	arch_remove_memory(align_start, align_size);
+
+	if (page_map->flags & PAGEMAP_IO_MEM) {
+		remove_zone_device_pages(align_start, align_size);
+		iounmap(page_map->kaddr);
+	} else {
+		arch_remove_memory(align_start, align_size);
+	}
 	pgmap_radix_release(res);
+
 	dev_WARN_ONCE(dev, pgmap->altmap && pgmap->altmap->alloc,
 			"%s: failed to free all reserved pages\n", __func__);
 }
@@ -258,6 +302,8 @@ struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
  * @res: "host memory" address range
  * @ref: a live per-cpu reference count
  * @altmap: optional descriptor for allocating the memmap from @res
+ * @flags: either MEMREMAP_WB, MEMREMAP_WT or MEMREMAP_WC
+ *         see memremap() for a description of the flags
  *
  * Notes:
  * 1/ @ref must be 'live' on entry and 'dead' before devm_memunmap_pages() time
@@ -268,7 +314,8 @@ struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
  *    this is not enforced.
  */
 void *devm_memremap_pages(struct device *dev, struct resource *res,
-		struct percpu_ref *ref, struct vmem_altmap *altmap)
+		struct percpu_ref *ref, struct vmem_altmap *altmap,
+		unsigned long flags)
 {
 	int is_ram = region_intersects(res->start, resource_size(res),
 			"System RAM");
@@ -277,6 +324,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	struct page_map *page_map;
 	unsigned long pfn;
 	int error, nid;
+	void *addr = NULL;

 	if (is_ram == REGION_MIXED) {
 		WARN_ONCE(1, "%s attempted on mixed region %pr\n",
@@ -344,10 +392,28 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	if (nid < 0)
 		nid = numa_mem_id();

-	error = arch_add_memory(nid, align_start, align_size, true);
+	if (flags & MEMREMAP_WB || !flags) {
+		error = arch_add_memory(nid, align_start, align_size, true);
+		addr = __va(res->start);
+	} else {
+		page_map->flags |= PAGEMAP_IO_MEM;
+		error = add_zone_device_pages(nid, align_start, align_size);
+	}
+
 	if (error)
 		goto err_add_memory;

+	if (!addr && (flags & MEMREMAP_WT))
+		addr = ioremap_wt(res->start, resource_size(res));
+
+	if (!addr && (flags & MEMREMAP_WC))
+		addr = ioremap_wc(res->start, resource_size(res));
+
+	if (!addr && page_map->flags & PAGEMAP_IO_MEM) {
+		remove_zone_device_pages(res->start, resource_size(res));
+		goto err_add_memory;
+	}
+
 	for_each_device_pfn(pfn, page_map) {
 		struct page *page = pfn_to_page(pfn);

@@ -355,8 +421,10 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 		list_force_poison(&page->lru);
 		page->pgmap = pgmap;
 	}
+
+	page_map->kaddr = addr;
 	devres_add(dev, page_map);
-	return __va(res->start);
+	return addr;

  err_add_memory:
  err_radix:
--
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
