Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6538682F6A
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 21:39:36 -0500 (EST)
Received: by pfbg73 with SMTP id g73so40694624pfb.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 18:39:36 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id fj9si16806705pad.43.2015.12.09.18.39.35
        for <linux-mm@kvack.org>;
        Wed, 09 Dec 2015 18:39:35 -0800 (PST)
Subject: [-mm PATCH v2 20/25] libnvdimm,
 pmem: move request_queue allocation earlier in probe
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 09 Dec 2015 18:39:00 -0800
Message-ID: <20151210023900.30368.15503.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
References: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-nvdimm@lists.01.org

Before the dynamically allocated struct pages from devm_memremap_pages()
can be put to use outside the driver, we need a mechanism to track
whether they are still in use at teardown.  Towards that goal reorder
the initialization sequence to allow the 'q_usage_counter' from the
request_queue to be used by the devm_memremap_pages() implementation (in
subsequent patches).

Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/nvdimm/pmem.c |   33 ++++++++++++++++++++-------------
 1 file changed, 20 insertions(+), 13 deletions(-)

diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 1d884318c67b..9060a64628ae 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -124,6 +124,7 @@ static struct pmem_device *pmem_alloc(struct device *dev,
 		struct resource *res, int id)
 {
 	struct pmem_device *pmem;
+	struct request_queue *q;
 
 	pmem = devm_kzalloc(dev, sizeof(*pmem), GFP_KERNEL);
 	if (!pmem)
@@ -141,6 +142,10 @@ static struct pmem_device *pmem_alloc(struct device *dev,
 		return ERR_PTR(-EBUSY);
 	}
 
+	q = blk_alloc_queue_node(GFP_KERNEL, dev_to_node(dev));
+	if (!q)
+		return ERR_PTR(-ENOMEM);
+
 	pmem->pfn_flags = PFN_DEV;
 	if (pmem_should_map_pages(dev)) {
 		pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, res,
@@ -151,9 +156,12 @@ static struct pmem_device *pmem_alloc(struct device *dev,
 				pmem->phys_addr, pmem->size,
 				ARCH_MEMREMAP_PMEM);
 
-	if (IS_ERR(pmem->virt_addr))
+	if (IS_ERR(pmem->virt_addr)) {
+		blk_cleanup_queue(q);
 		return (void __force *) pmem->virt_addr;
+	}
 
+	pmem->pmem_queue = q;
 	return pmem;
 }
 
@@ -173,10 +181,6 @@ static int pmem_attach_disk(struct device *dev,
 	int nid = dev_to_node(dev);
 	struct gendisk *disk;
 
-	pmem->pmem_queue = blk_alloc_queue_node(GFP_KERNEL, nid);
-	if (!pmem->pmem_queue)
-		return -ENOMEM;
-
 	blk_queue_make_request(pmem->pmem_queue, pmem_make_request);
 	blk_queue_physical_block_size(pmem->pmem_queue, PAGE_SIZE);
 	blk_queue_max_hw_sectors(pmem->pmem_queue, UINT_MAX);
@@ -411,19 +415,22 @@ static int nd_pmem_probe(struct device *dev)
 	dev_set_drvdata(dev, pmem);
 	ndns->rw_bytes = pmem_rw_bytes;
 
-	if (is_nd_btt(dev))
+	if (is_nd_btt(dev)) {
+		/* btt allocates its own request_queue */
+		blk_cleanup_queue(pmem->pmem_queue);
+		pmem->pmem_queue = NULL;
 		return nvdimm_namespace_attach_btt(ndns);
+	}
 
 	if (is_nd_pfn(dev))
 		return nvdimm_namespace_attach_pfn(ndns);
 
-	if (nd_btt_probe(ndns, pmem) == 0) {
-		/* we'll come back as btt-pmem */
-		return -ENXIO;
-	}
-
-	if (nd_pfn_probe(ndns, pmem) == 0) {
-		/* we'll come back as pfn-pmem */
+	if (nd_btt_probe(ndns, pmem) == 0 || nd_pfn_probe(ndns, pmem) == 0) {
+		/*
+		 * We'll come back as either btt-pmem, or pfn-pmem, so
+		 * drop the queue allocation for now.
+		 */
+		blk_cleanup_queue(pmem->pmem_queue);
 		return -ENXIO;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
