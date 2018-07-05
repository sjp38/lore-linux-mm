Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CDD0C6B0279
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 03:00:01 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b5-v6so4304234pfi.5
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 00:00:01 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id cc1-v6si5461303plb.458.2018.07.05.00.00.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jul 2018 00:00:00 -0700 (PDT)
Subject: [PATCH 11/13] libnvdimm,
 pmem: Initialize the memmap in the background
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 04 Jul 2018 23:50:01 -0700
Message-ID: <153077340108.40830.8427794791878610916.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153077334130.40830.2714147692560185329.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153077334130.40830.2714147692560185329.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Vishal Verma <vishal.l.verma@intel.com>, Dave Jiang <dave.jiang@intel.com>, hch@lst.de, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Arrange for the pmem driver to call memmap_sync() when it is asked to
produce a valid pfn. The infrastructure is housed in the 'nd_pfn'
device which implies that the async init support only exists for
platform defined persistent memory, not the legacy / debug memmap=ss!nn
facility.

Another reason to restrict the capability to the 'nd_pfn' device case is
that nd_pfn devices have sysfs infrastructure to communicate the
memmap initialization state to userspace.

The sysfs publication of memmap init state is saved for a later patch.

Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Vishal Verma <vishal.l.verma@intel.com>
Cc: Dave Jiang <dave.jiang@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/nvdimm/nd.h             |    2 ++
 drivers/nvdimm/pmem.c           |   16 ++++++++++++----
 drivers/nvdimm/pmem.h           |    1 +
 tools/testing/nvdimm/pmem-dax.c |    7 ++++++-
 4 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/drivers/nvdimm/nd.h b/drivers/nvdimm/nd.h
index 32e0364b48b9..ee4f76fb0cb5 100644
--- a/drivers/nvdimm/nd.h
+++ b/drivers/nvdimm/nd.h
@@ -12,6 +12,7 @@
  */
 #ifndef __ND_H__
 #define __ND_H__
+#include <linux/memmap_async.h>
 #include <linux/libnvdimm.h>
 #include <linux/badblocks.h>
 #include <linux/blkdev.h>
@@ -208,6 +209,7 @@ struct nd_pfn {
 	unsigned long npfns;
 	enum nd_pfn_mode mode;
 	struct nd_pfn_sb *pfn_sb;
+	struct memmap_async_state async;
 	struct nd_namespace_common *ndns;
 };
 
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index c430536320a5..a1158181adc2 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -22,6 +22,7 @@
 #include <linux/platform_device.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
+#include <linux/memmap_async.h>
 #include <linux/badblocks.h>
 #include <linux/memremap.h>
 #include <linux/vmalloc.h>
@@ -228,8 +229,13 @@ __weak long __pmem_direct_access(struct pmem_device *pmem, pgoff_t pgoff,
 					PFN_PHYS(nr_pages))))
 		return -EIO;
 	*kaddr = pmem->virt_addr + offset;
-	if (pfn)
+	if (pfn) {
+		struct dev_pagemap *pgmap = &pmem->pgmap;
+		struct memmap_async_state *async = pgmap->async;
+
 		*pfn = phys_to_pfn_t(pmem->phys_addr + offset, pmem->pfn_flags);
+		memmap_sync(*pfn, nr_pages, async);
+	}
 
 	/*
 	 * If badblocks are present, limit known good range to the
@@ -310,13 +316,15 @@ static void fsdax_pagefree(struct page *page, void *data)
 	wake_up_var(&page->_refcount);
 }
 
-static int setup_pagemap_fsdax(struct device *dev, struct dev_pagemap *pgmap)
+static int setup_pagemap_fsdax(struct device *dev, struct dev_pagemap *pgmap,
+		struct memmap_async_state *async)
 {
 	dev_pagemap_get_ops();
 	if (devm_add_action_or_reset(dev, pmem_release_pgmap_ops, pgmap))
 		return -ENOMEM;
 	pgmap->type = MEMORY_DEVICE_FS_DAX;
 	pgmap->page_free = fsdax_pagefree;
+	pgmap->async = async;
 
 	return 0;
 }
@@ -379,7 +387,7 @@ static int pmem_attach_disk(struct device *dev,
 	pmem->pfn_flags = PFN_DEV;
 	pmem->pgmap.ref = &q->q_usage_counter;
 	if (is_nd_pfn(dev)) {
-		if (setup_pagemap_fsdax(dev, &pmem->pgmap))
+		if (setup_pagemap_fsdax(dev, &pmem->pgmap, &nd_pfn->async))
 			return -ENOMEM;
 		addr = devm_memremap_pages(dev, &pmem->pgmap,
 				pmem_freeze_queue);
@@ -393,7 +401,7 @@ static int pmem_attach_disk(struct device *dev,
 	} else if (pmem_should_map_pages(dev)) {
 		memcpy(&pmem->pgmap.res, &nsio->res, sizeof(pmem->pgmap.res));
 		pmem->pgmap.altmap_valid = false;
-		if (setup_pagemap_fsdax(dev, &pmem->pgmap))
+		if (setup_pagemap_fsdax(dev, &pmem->pgmap, NULL))
 			return -ENOMEM;
 		addr = devm_memremap_pages(dev, &pmem->pgmap,
 				pmem_freeze_queue);
diff --git a/drivers/nvdimm/pmem.h b/drivers/nvdimm/pmem.h
index a64ebc78b5df..93d226ea1006 100644
--- a/drivers/nvdimm/pmem.h
+++ b/drivers/nvdimm/pmem.h
@@ -1,6 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 #ifndef __NVDIMM_PMEM_H__
 #define __NVDIMM_PMEM_H__
+#include <linux/memmap_async.h>
 #include <linux/badblocks.h>
 #include <linux/types.h>
 #include <linux/pfn_t.h>
diff --git a/tools/testing/nvdimm/pmem-dax.c b/tools/testing/nvdimm/pmem-dax.c
index d4cb5281b30e..63151b75615c 100644
--- a/tools/testing/nvdimm/pmem-dax.c
+++ b/tools/testing/nvdimm/pmem-dax.c
@@ -42,8 +42,13 @@ long __pmem_direct_access(struct pmem_device *pmem, pgoff_t pgoff,
 	}
 
 	*kaddr = pmem->virt_addr + offset;
-	if (pfn)
+	if (pfn) {
+		struct dev_pagemap *pgmap = &pmem->pgmap;
+		struct memmap_async_state *async = pgmap->async;
+
 		*pfn = phys_to_pfn_t(pmem->phys_addr + offset, pmem->pfn_flags);
+		memmap_sync(*pfn, nr_pages, async);
+	}
 
 	/*
 	 * If badblocks are present, limit known good range to the
