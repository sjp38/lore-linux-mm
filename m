Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 971136B0272
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 21:38:46 -0500 (EST)
Received: by pfnn128 with SMTP id n128so39795893pfn.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 18:38:46 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id d3si16761019pas.116.2015.12.09.18.38.45
        for <linux-mm@kvack.org>;
        Wed, 09 Dec 2015 18:38:45 -0800 (PST)
Subject: [-mm PATCH v2 12/25] libnvdimm, pfn,
 pmem: allocate memmap array in persistent memory
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 09 Dec 2015 18:38:18 -0800
Message-ID: <20151210023818.30368.10196.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
References: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>, linux-nvdimm@lists.01.org

Use the new vmem_altmap capability to enable the pmem driver to arrange
for a struct page memmap to be established in persistent memory.

Cc: Christoph Hellwig <hch@lst.de>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/ia64/include/asm/page.h |    1 +
 drivers/nvdimm/pfn_devs.c    |    3 +--
 drivers/nvdimm/pmem.c        |   19 +++++++++++++++++--
 3 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/include/asm/page.h b/arch/ia64/include/asm/page.h
index ec48bb9f95e1..e8c486ef0d76 100644
--- a/arch/ia64/include/asm/page.h
+++ b/arch/ia64/include/asm/page.h
@@ -105,6 +105,7 @@ extern struct page *vmem_map;
 #ifdef CONFIG_DISCONTIGMEM
 # define page_to_pfn(page)	((unsigned long) (page - vmem_map))
 # define pfn_to_page(pfn)	(vmem_map + (pfn))
+# define __pfn_to_phys(pfn)	PFN_PHYS(pfn)
 #else
 # include <asm-generic/memory_model.h>
 #endif
diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index 71805a1aa0f3..a642cfacee07 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -83,8 +83,7 @@ static ssize_t mode_store(struct device *dev,
 
 		if (strncmp(buf, "pmem\n", n) == 0
 				|| strncmp(buf, "pmem", n) == 0) {
-			/* TODO: allocate from PMEM support */
-			rc = -ENOTTY;
+			nd_pfn->mode = PFN_MODE_PMEM;
 		} else if (strncmp(buf, "ram\n", n) == 0
 				|| strncmp(buf, "ram", n) == 0)
 			nd_pfn->mode = PFN_MODE_RAM;
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 34fa2f003602..1d884318c67b 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -315,12 +315,16 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
 	struct nd_namespace_io *nsio = to_nd_namespace_io(&ndns->dev);
 	struct nd_pfn *nd_pfn = to_nd_pfn(ndns->claim);
 	struct device *dev = &nd_pfn->dev;
-	struct vmem_altmap *altmap;
 	struct nd_region *nd_region;
+	struct vmem_altmap *altmap;
 	struct nd_pfn_sb *pfn_sb;
 	struct pmem_device *pmem;
 	phys_addr_t offset;
 	int rc;
+	struct vmem_altmap __altmap = {
+		.base_pfn = __phys_to_pfn(nsio->res.start),
+		.reserve = __phys_to_pfn(SZ_8K),
+	};
 
 	if (!nd_pfn->uuid || !nd_pfn->ndns)
 		return -ENODEV;
@@ -348,6 +352,17 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
 			return -EINVAL;
 		nd_pfn->npfns = le64_to_cpu(pfn_sb->npfns);
 		altmap = NULL;
+	} else if (nd_pfn->mode == PFN_MODE_PMEM) {
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
 	} else {
 		rc = -ENXIO;
 		goto err;
@@ -357,7 +372,7 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
 	pmem = dev_get_drvdata(dev);
 	devm_memunmap(dev, (void __force *) pmem->virt_addr);
 	pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, &nsio->res,
-			NULL);
+			altmap);
 	pmem->pfn_flags |= PFN_MAP;
 	if (IS_ERR(pmem->virt_addr)) {
 		rc = PTR_ERR(pmem->virt_addr);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
