Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4E95B6B0276
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 19:22:42 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id w1-v6so99111pgr.7
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 16:22:42 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id i88-v6si20450019pfa.219.2018.06.04.16.22.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jun 2018 16:22:41 -0700 (PDT)
Subject: [PATCH v3 12/12] libnvdimm,
 pmem: Restore page attributes when clearing errors
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 04 Jun 2018 16:12:43 -0700
Message-ID: <152815396335.39010.17157370539429298762.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152815389835.39010.13253559944508110923.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152815389835.39010.13253559944508110923.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: hch@lst.de, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, jack@suse.cz

Use clear_mce_nospec() to restore WB mode for the kernel linear mapping
of a pmem page that was marked 'HWPoison'. A page with 'HWPoison' set
has also been marked UC in PAT (page attribute table) via
set_mce_nospec() to prevent speculative retrievals of poison.

The 'HWPoison' flag is only cleared when overwriting an entire page.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/nvdimm/pmem.c |   26 ++++++++++++++++++++++++++
 drivers/nvdimm/pmem.h |   13 +++++++++++++
 2 files changed, 39 insertions(+)

diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 9d714926ecf5..04ee1fdee219 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -20,6 +20,7 @@
 #include <linux/hdreg.h>
 #include <linux/init.h>
 #include <linux/platform_device.h>
+#include <linux/set_memory.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/badblocks.h>
@@ -51,6 +52,30 @@ static struct nd_region *to_region(struct pmem_device *pmem)
 	return to_nd_region(to_dev(pmem)->parent);
 }
 
+static void hwpoison_clear(struct pmem_device *pmem,
+		phys_addr_t phys, unsigned int len)
+{
+	unsigned long pfn_start, pfn_end, pfn;
+
+	/* only pmem in the linear map supports HWPoison */
+	if (is_vmalloc_addr(pmem->virt_addr))
+		return;
+
+	pfn_start = PHYS_PFN(phys);
+	pfn_end = pfn_start + PHYS_PFN(len);
+	for (pfn = pfn_start; pfn < pfn_end; pfn++) {
+		struct page *page = pfn_to_page(pfn);
+
+		/*
+		 * Note, no need to hold a get_dev_pagemap() reference
+		 * here since we're in the driver I/O path and
+		 * outstanding I/O requests pin the dev_pagemap.
+		 */
+		if (test_and_clear_pmem_poison(page))
+			clear_mce_nospec(pfn);
+	}
+}
+
 static blk_status_t pmem_clear_poison(struct pmem_device *pmem,
 		phys_addr_t offset, unsigned int len)
 {
@@ -65,6 +90,7 @@ static blk_status_t pmem_clear_poison(struct pmem_device *pmem,
 	if (cleared < len)
 		rc = BLK_STS_IOERR;
 	if (cleared > 0 && cleared / 512) {
+		hwpoison_clear(pmem, pmem->phys_addr + offset, cleared);
 		cleared /= 512;
 		dev_dbg(dev, "%#llx clear %ld sector%s\n",
 				(unsigned long long) sector, cleared,
diff --git a/drivers/nvdimm/pmem.h b/drivers/nvdimm/pmem.h
index a64ebc78b5df..59cfe13ea8a8 100644
--- a/drivers/nvdimm/pmem.h
+++ b/drivers/nvdimm/pmem.h
@@ -1,6 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 #ifndef __NVDIMM_PMEM_H__
 #define __NVDIMM_PMEM_H__
+#include <linux/page-flags.h>
 #include <linux/badblocks.h>
 #include <linux/types.h>
 #include <linux/pfn_t.h>
@@ -27,4 +28,16 @@ struct pmem_device {
 
 long __pmem_direct_access(struct pmem_device *pmem, pgoff_t pgoff,
 		long nr_pages, void **kaddr, pfn_t *pfn);
+
+#ifdef CONFIG_MEMORY_FAILURE
+static inline bool test_and_clear_pmem_poison(struct page *page)
+{
+	return TestClearPageHWPoison(page);
+}
+#else
+static inline bool test_and_clear_pmem_poison(struct page *page)
+{
+	return false;
+}
+#endif
 #endif /* __NVDIMM_PMEM_H__ */
