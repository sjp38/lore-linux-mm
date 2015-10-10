Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3FACF6B0259
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 21:01:45 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so100965736pac.0
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 18:01:45 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id td8si6489008pac.42.2015.10.09.18.01.42
        for <linux-mm@kvack.org>;
        Fri, 09 Oct 2015 18:01:42 -0700 (PDT)
Subject: [PATCH v2 06/20] libnvdimm, pfn,
 pmem: allocate memmap array in persistent memory
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 09 Oct 2015 20:55:55 -0400
Message-ID: <20151010005555.17221.32221.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
References: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ross.zwisler@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>, hch@lst.de

Use the new vmem_altmap capability to enable the pmem driver to arrange
for a struct page memmap to be established in persistent memory.

Cc: Christoph Hellwig <hch@lst.de>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/nvdimm/pfn_devs.c |    3 +--
 drivers/nvdimm/pmem.c     |   19 +++++++++++++++++--
 2 files changed, 18 insertions(+), 4 deletions(-)

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
index 3c5b8f585441..bb66158c0505 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -322,12 +322,16 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
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
@@ -355,6 +359,17 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
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
@@ -364,7 +379,7 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
 	pmem = dev_get_drvdata(dev);
 	devm_memunmap(dev, (void __force *) pmem->virt_addr);
 	pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, &nsio->res,
-			NULL);
+			altmap);
 	if (IS_ERR(pmem->virt_addr)) {
 		rc = PTR_ERR(pmem->virt_addr);
 		goto err;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
