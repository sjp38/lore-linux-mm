Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id B89BB6B0087
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 11:48:37 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id ex7so1302205wid.0
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 08:48:37 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
        by mx.google.com with ESMTPS id y5si18589322wie.10.2014.09.09.08.48.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Sep 2014 08:48:36 -0700 (PDT)
Received: by mail-wi0-f179.google.com with SMTP id q5so4733450wiv.0
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 08:48:36 -0700 (PDT)
Message-ID: <540F2152.4070406@plexistor.com>
Date: Tue, 09 Sep 2014 18:48:34 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [PATCH 7/9] pmem: Add support for page structs
References: <1409173922-7484-1-git-send-email-ross.zwisler@linux.intel.com> <540F1EC6.4000504@plexistor.com>
In-Reply-To: <540F1EC6.4000504@plexistor.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@fb.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-nvdimm@lists.01.org, Toshi Kani <toshi.kani@hp.com>, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>

From: Boaz Harrosh <boaz@plexistor.com>

One of the current shortcomings of the NVDIMM/PMEM
support is that this memory does not have a page-struct(s)
associated with its memory and therefor cannot be passed
to a block-device or network or DMAed in any way through
another device in the system.

The use of add_persistent_memory() fixes all this. After this patch
an FS can do:
	bdev_direct_access(,&pfn,);
	page = pfn_to_page(pfn);
And use that page for a lock_page(), set_page_dirty(), and/or
anything else one might do with a page *.
(Note that with brd one can already do this)

[pmem-pages-ref-count]
pmem will serve it's pages with ref==0. Once an FS does
an blkdev_get_XXX(,FMODE_EXCL,), that memory is own by the FS.
The FS needs to manage its allocation, just as it already does
for its disk blocks. The fs should set page->count = 2, before
submission to any Kernel subsystem so when it returns it will
never be released to the Kernel's page-allocators. (page_freeze)

Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
---
 drivers/block/Kconfig | 13 +++++++++++++
 drivers/block/pmem.c  | 19 +++++++++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/drivers/block/Kconfig b/drivers/block/Kconfig
index 5da8cbf..8a5929c 100644
--- a/drivers/block/Kconfig
+++ b/drivers/block/Kconfig
@@ -416,6 +416,19 @@ config BLK_DEV_PMEM
 	  Most normal users won't need this functionality, and can thus say N
 	  here.
 
+config BLK_DEV_PMEM_USE_PAGES
+	bool "Enable use of page struct pages with pmem"
+	depends on BLK_DEV_PMEM
+	depends on PERSISTENT_MEMORY_DEPENDENCY
+	select DRIVER_NEEDS_PERSISTENT_MEMORY
+	default y
+	help
+	  If a user of PMEM device needs "struct page" associated
+	  with its memory, so this memory can be sent to other
+	  block devices, or sent on the network, or be DMA transferred
+	  to other devices in the system, then you must say "Yes" here.
+	  If unsure leave as Yes.
+
 config CDROM_PKTCDVD
 	tristate "Packet writing on CD/DVD media"
 	depends on !UML
diff --git a/drivers/block/pmem.c b/drivers/block/pmem.c
index e07a373..b415b61 100644
--- a/drivers/block/pmem.c
+++ b/drivers/block/pmem.c
@@ -221,6 +221,23 @@ MODULE_PARM_DESC(map,
 static LIST_HEAD(pmem_devices);
 static int pmem_major;
 
+#ifdef CONFIG_BLK_DEV_PMEM_USE_PAGES
+/* pmem->phys_addr and pmem->size need to be set.
+ * Will then set pmem->virt_addr if successful.
+ */
+int pmem_mapmem(struct pmem_device *pmem)
+{
+	return add_persistent_memory(pmem->phys_addr, pmem->size,
+				     &pmem->virt_addr);
+}
+
+static void pmem_unmapmem(struct pmem_device *pmem)
+{
+	remove_persistent_memory(pmem->phys_addr, pmem->size);
+}
+
+#else /* !CONFIG_BLK_DEV_PMEM_USE_PAGES */
+
 /* pmem->phys_addr and pmem->size need to be set.
  * Will then set virt_addr if successful.
  */
@@ -258,6 +275,8 @@ void pmem_unmapmem(struct pmem_device *pmem)
 	release_mem_region(pmem->phys_addr, pmem->size);
 	pmem->virt_addr = NULL;
 }
+#endif /* ! CONFIG_BLK_DEV_PMEM_USE_PAGES */
+
 
 static struct pmem_device *pmem_alloc(phys_addr_t phys_addr, size_t disk_size,
 				      int i)
-- 
1.9.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
