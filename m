Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 05CD46B0259
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 00:47:34 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so29313121pac.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 21:47:33 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id z5si7634261par.231.2015.09.22.21.47.33
        for <linux-mm@kvack.org>;
        Tue, 22 Sep 2015 21:47:33 -0700 (PDT)
Subject: [PATCH 07/15] devm_memremap: convert to return ERR_PTR
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 23 Sep 2015 00:41:50 -0400
Message-ID: <20150923044150.36490.15073.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

Make devm_memremap consistent with the error return scheme of
devm_memremap_pages to remove special casing in the pmem driver.

Cc: Christoph Hellwig <hch@lst.de>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/nvdimm/pmem.c |   16 ++++++----------
 kernel/memremap.c     |    2 +-
 2 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 0680affae04a..9805d311b1d1 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -150,19 +150,15 @@ static struct pmem_device *pmem_alloc(struct device *dev,
 		return ERR_PTR(-EBUSY);
 	}
 
-	if (pmem_should_map_pages(dev)) {
-		void *addr = devm_memremap_pages(dev, res);
-
-		if (IS_ERR(addr))
-			return addr;
-		pmem->virt_addr = (void __pmem *) addr;
-	} else {
+	if (pmem_should_map_pages(dev))
+		pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, res);
+	else
 		pmem->virt_addr = (void __pmem *) devm_memremap(dev,
 				pmem->phys_addr, pmem->size,
 				ARCH_MEMREMAP_PMEM);
-		if (!pmem->virt_addr)
-			return ERR_PTR(-ENXIO);
-	}
+
+	if (IS_ERR(pmem->virt_addr))
+		return (void __force *) pmem->virt_addr;
 
 	return pmem;
 }
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 0756273437e0..0d818ce04129 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -116,7 +116,7 @@ void *devm_memremap(struct device *dev, resource_size_t offset,
 
 	ptr = devres_alloc(devm_memremap_release, sizeof(*ptr), GFP_KERNEL);
 	if (!ptr)
-		return NULL;
+		return ERR_PTR(-ENOMEM);
 
 	addr = memremap(offset, size, flags);
 	if (addr) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
