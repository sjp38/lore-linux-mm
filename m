Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 14AA76B0258
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 00:47:23 -0400 (EDT)
Received: by pacbt3 with SMTP id bt3so10907646pac.3
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 21:47:22 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id co2si7659122pbb.197.2015.09.22.21.47.22
        for <linux-mm@kvack.org>;
        Tue, 22 Sep 2015 21:47:22 -0700 (PDT)
Subject: [PATCH 05/15] pmem: kill memremap_pmem()
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 23 Sep 2015 00:41:39 -0400
Message-ID: <20150923044139.36490.38720.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org

Now that the pmem-api is defined as "a set of apis that enables access
to WB mapped pmem",  the mapping type is implied.  Remove the wrapper
and push the functionality down into the pmem driver in preparation for
adding support for direct-mapped pmem.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/nvdimm/pmem.c |    9 +++++----
 include/linux/pmem.h  |   26 +-------------------------
 2 files changed, 6 insertions(+), 29 deletions(-)

diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 0ba6a978f227..0680affae04a 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -157,8 +157,9 @@ static struct pmem_device *pmem_alloc(struct device *dev,
 			return addr;
 		pmem->virt_addr = (void __pmem *) addr;
 	} else {
-		pmem->virt_addr = memremap_pmem(dev, pmem->phys_addr,
-				pmem->size);
+		pmem->virt_addr = (void __pmem *) devm_memremap(dev,
+				pmem->phys_addr, pmem->size,
+				ARCH_MEMREMAP_PMEM);
 		if (!pmem->virt_addr)
 			return ERR_PTR(-ENXIO);
 	}
@@ -363,8 +364,8 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
 
 	/* establish pfn range for lookup, and switch to direct map */
 	pmem = dev_get_drvdata(dev);
-	memunmap_pmem(dev, pmem->virt_addr);
-	pmem->virt_addr = (void __pmem *)devm_memremap_pages(dev, &nsio->res);
+	devm_memunmap(dev, (void __force *) pmem->virt_addr);
+	pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, &nsio->res);
 	if (IS_ERR(pmem->virt_addr)) {
 		rc = PTR_ERR(pmem->virt_addr);
 		goto err;
diff --git a/include/linux/pmem.h b/include/linux/pmem.h
index 85f810b33917..acfea8ce4a07 100644
--- a/include/linux/pmem.h
+++ b/include/linux/pmem.h
@@ -65,11 +65,6 @@ static inline void memcpy_from_pmem(void *dst, void __pmem const *src, size_t si
 	memcpy(dst, (void __force const *) src, size);
 }
 
-static inline void memunmap_pmem(struct device *dev, void __pmem *addr)
-{
-	devm_memunmap(dev, (void __force *) addr);
-}
-
 static inline bool arch_has_pmem_api(void)
 {
 	return IS_ENABLED(CONFIG_ARCH_HAS_PMEM_API);
@@ -93,7 +88,7 @@ static inline bool arch_has_wmb_pmem(void)
  * These defaults seek to offer decent performance and minimize the
  * window between i/o completion and writes being durable on media.
  * However, it is undefined / architecture specific whether
- * default_memremap_pmem + default_memcpy_to_pmem is sufficient for
+ * ARCH_MEMREMAP_PMEM + default_memcpy_to_pmem is sufficient for
  * making data durable relative to i/o completion.
  */
 static inline void default_memcpy_to_pmem(void __pmem *dst, const void *src,
@@ -117,25 +112,6 @@ static inline void default_clear_pmem(void __pmem *addr, size_t size)
 }
 
 /**
- * memremap_pmem - map physical persistent memory for pmem api
- * @offset: physical address of persistent memory
- * @size: size of the mapping
- *
- * Establish a mapping of the architecture specific memory type expected
- * by memcpy_to_pmem() and wmb_pmem().  For example, it may be
- * the case that an uncacheable or writethrough mapping is sufficient,
- * or a writeback mapping provided memcpy_to_pmem() and
- * wmb_pmem() arrange for the data to be written through the
- * cache to persistent media.
- */
-static inline void __pmem *memremap_pmem(struct device *dev,
-		resource_size_t offset, unsigned long size)
-{
-	return (void __pmem *) devm_memremap(dev, offset, size,
-			ARCH_MEMREMAP_PMEM);
-}
-
-/**
  * memcpy_to_pmem - copy data to persistent memory
  * @dst: destination buffer for the copy
  * @src: source buffer for the copy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
