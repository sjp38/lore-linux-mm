Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5698B6B0536
	for <linux-mm@kvack.org>; Thu, 17 May 2018 16:16:54 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id g92-v6so3540653plg.6
        for <linux-mm@kvack.org>; Thu, 17 May 2018 13:16:54 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id n127-v6si4532491pga.523.2018.05.17.13.16.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 13:16:52 -0700 (PDT)
Subject: [PATCH v10] mm: introduce MEMORY_DEVICE_FS_DAX and
 CONFIG_DEV_PAGEMAP_OPS
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 17 May 2018 13:06:54 -0700
Message-ID: <152658753673.26786.16458605771414761966.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@suse.com>, kbuild test robot <lkp@intel.com>, Thomas Meyer <thomas@m3y3r.de>, Dave Jiang <dave.jiang@intel.com>, Christoph Hellwig <hch@lst.de>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

In preparation for fixing dax-dma-vs-unmap issues, filesystems need to
be able to rely on the fact that they will get wakeups on dev_pagemap
page-idle events. Introduce MEMORY_DEVICE_FS_DAX and
generic_dax_page_free() as common indicator / infrastructure for dax
filesytems to require. With this change there are no users of the
MEMORY_DEVICE_HOST designation, so remove it.

The HMM sub-system extended dev_pagemap to arrange a callback when a
dev_pagemap managed page is freed. Since a dev_pagemap page is free /
idle when its reference count is 1 it requires an additional branch to
check the page-type at put_page() time. Given put_page() is a hot-path
we do not want to incur that check if HMM is not in use, so a static
branch is used to avoid that overhead when not necessary.

Now, the FS_DAX implementation wants to reuse this mechanism for
receiving dev_pagemap ->page_free() callbacks. Rework the HMM-specific
static-key into a generic mechanism that either HMM or FS_DAX code paths
can enable.

For ARCH=um builds, and any other arch that lacks ZONE_DEVICE support,
care must be taken to compile out the DEV_PAGEMAP_OPS infrastructure.
However, we still need to support FS_DAX in the FS_DAX_LIMITED case
implemented by the s390/dcssblk driver.

Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Michal Hocko <mhocko@suse.com>
Reported-by: kbuild test robot <lkp@intel.com>
Reported-by: Thomas Meyer <thomas@m3y3r.de>
Reported-by: Dave Jiang <dave.jiang@intel.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Cc: Jan Kara <jack@suse.cz>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---

This patch replaces and consolidates patch 2 [1] and 4 [2] from the v9
series [3] for "dax: fix dma vs truncate/hole-punch".

The original implementation which introduced fs_dax_claim() was broken
in the presence of partitions as filesystems on partitions of a pmem
device would collide when attempting to issue fs_dax_claim().

Instead, since this new page wakeup behavior is a property of
dev_pagemap pages and there is a 1:1 relationship between a pmem device
and its dev_pagemap instance, make the pmem driver own the page wakeup
initialization rather than the filesystem.

This simplifies the implementation considerably. The diffstat for the
series is now:

    21 files changed, 546 insertions(+), 277 deletions(-)

...down from:

    24 files changed, 730 insertions(+), 297 deletions(-)

The other patches in the series are not included since they did not
change in any meaningful way. Let me know if anyone wants a full resend,
it will otherwise be available in -next shortly. Given the change in
approach I did not carry Reviewed-by tags from patch 2 and 4 to this
patch.

[1]: [PATCH v9 2/9] mm, dax: enable filesystems to trigger dev_pagemap ->page_free callbacks
https://lists.01.org/pipermail/linux-nvdimm/2018-April/015459.html

[2]: [PATCH v9 4/9] mm, dev_pagemap: introduce CONFIG_DEV_PAGEMAP_OPS
https://lists.01.org/pipermail/linux-nvdimm/2018-April/015461.html

[3]: [PATCH v9 0/9] dax: fix dma vs truncate/hole-punch
https://lists.01.org/pipermail/linux-nvdimm/2018-April/015457.html


 drivers/dax/super.c       |   18 ++++++++---
 drivers/nvdimm/pfn_devs.c |    2 -
 drivers/nvdimm/pmem.c     |   20 +++++++++++++
 fs/Kconfig                |    1 +
 include/linux/memremap.h  |   41 ++++++++++----------------
 include/linux/mm.h        |   71 ++++++++++++++++++++++++++++++++++-----------
 kernel/memremap.c         |   37 +++++++++++++++++++++--
 mm/Kconfig                |    5 +++
 mm/hmm.c                  |   13 +-------
 mm/swap.c                 |    3 +-
 10 files changed, 143 insertions(+), 68 deletions(-)

diff --git a/drivers/dax/super.c b/drivers/dax/super.c
index 2b2332b605e4..4928b7fcfb71 100644
--- a/drivers/dax/super.c
+++ b/drivers/dax/super.c
@@ -134,15 +134,21 @@ int __bdev_dax_supported(struct super_block *sb, int blocksize)
 		 * on being able to do (page_address(pfn_to_page())).
 		 */
 		WARN_ON(IS_ENABLED(CONFIG_ARCH_HAS_PMEM_API));
+		return 0;
 	} else if (pfn_t_devmap(pfn)) {
-		/* pass */;
-	} else {
-		pr_debug("VFS (%s): error: dax support not enabled\n",
-				sb->s_id);
-		return -EOPNOTSUPP;
+		struct dev_pagemap *pgmap;
+
+		pgmap = get_dev_pagemap(pfn_t_to_pfn(pfn), NULL);
+		if (pgmap && pgmap->type == MEMORY_DEVICE_FS_DAX) {
+			put_dev_pagemap(pgmap);
+			return 0;
+		}
+		put_dev_pagemap(pgmap);
 	}
 
-	return 0;
+	pr_debug("VFS (%s): error: dax support not enabled\n",
+			sb->s_id);
+	return -EOPNOTSUPP;
 }
 EXPORT_SYMBOL_GPL(__bdev_dax_supported);
 #endif
diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index 30b08791597d..3f7ad5bc443e 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -561,8 +561,6 @@ static int __nvdimm_setup_pfn(struct nd_pfn *nd_pfn, struct dev_pagemap *pgmap)
 	res->start += start_pad;
 	res->end -= end_trunc;
 
-	pgmap->type = MEMORY_DEVICE_HOST;
-
 	if (nd_pfn->mode == PFN_MODE_RAM) {
 		if (offset < SZ_8K)
 			return -EINVAL;
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 9d714926ecf5..e6d94604e9a4 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -294,6 +294,22 @@ static void pmem_release_disk(void *__pmem)
 	put_disk(pmem->disk);
 }
 
+static void pmem_release_pgmap_ops(void *__pgmap)
+{
+	dev_pagemap_put_ops();
+}
+
+static int setup_pagemap_fsdax(struct device *dev, struct dev_pagemap *pgmap)
+{
+	dev_pagemap_get_ops();
+	if (devm_add_action_or_reset(dev, pmem_release_pgmap_ops, pgmap))
+		return -ENOMEM;
+	pgmap->type = MEMORY_DEVICE_FS_DAX;
+	pgmap->page_free = generic_dax_pagefree;
+
+	return 0;
+}
+
 static int pmem_attach_disk(struct device *dev,
 		struct nd_namespace_common *ndns)
 {
@@ -353,6 +369,8 @@ static int pmem_attach_disk(struct device *dev,
 	pmem->pfn_flags = PFN_DEV;
 	pmem->pgmap.ref = &q->q_usage_counter;
 	if (is_nd_pfn(dev)) {
+		if (setup_pagemap_fsdax(dev, &pmem->pgmap))
+			return -ENOMEM;
 		addr = devm_memremap_pages(dev, &pmem->pgmap);
 		pfn_sb = nd_pfn->pfn_sb;
 		pmem->data_offset = le64_to_cpu(pfn_sb->dataoff);
@@ -364,6 +382,8 @@ static int pmem_attach_disk(struct device *dev,
 	} else if (pmem_should_map_pages(dev)) {
 		memcpy(&pmem->pgmap.res, &nsio->res, sizeof(pmem->pgmap.res));
 		pmem->pgmap.altmap_valid = false;
+		if (setup_pagemap_fsdax(dev, &pmem->pgmap))
+			return -ENOMEM;
 		addr = devm_memremap_pages(dev, &pmem->pgmap);
 		pmem->pfn_flags |= PFN_MAP;
 		memcpy(&bb_res, &pmem->pgmap.res, sizeof(bb_res));
diff --git a/fs/Kconfig b/fs/Kconfig
index bc821a86d965..1e050e012eb9 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -38,6 +38,7 @@ config FS_DAX
 	bool "Direct Access (DAX) support"
 	depends on MMU
 	depends on !(ARM || MIPS || SPARC)
+	select DEV_PAGEMAP_OPS if (ZONE_DEVICE && !FS_DAX_LIMITED)
 	select FS_IOMAP
 	select DAX
 	help
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 7b4899c06f49..29ea63544c4d 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -1,7 +1,6 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 #ifndef _LINUX_MEMREMAP_H_
 #define _LINUX_MEMREMAP_H_
-#include <linux/mm.h>
 #include <linux/ioport.h>
 #include <linux/percpu-refcount.h>
 
@@ -30,13 +29,6 @@ struct vmem_altmap {
  * Specialize ZONE_DEVICE memory into multiple types each having differents
  * usage.
  *
- * MEMORY_DEVICE_HOST:
- * Persistent device memory (pmem): struct page might be allocated in different
- * memory and architecture might want to perform special actions. It is similar
- * to regular memory, in that the CPU can access it transparently. However,
- * it is likely to have different bandwidth and latency than regular memory.
- * See Documentation/nvdimm/nvdimm.txt for more information.
- *
  * MEMORY_DEVICE_PRIVATE:
  * Device memory that is not directly addressable by the CPU: CPU can neither
  * read nor write private memory. In this case, we do still have struct pages
@@ -53,11 +45,19 @@ struct vmem_altmap {
  * driver can hotplug the device memory using ZONE_DEVICE and with that memory
  * type. Any page of a process can be migrated to such memory. However no one
  * should be allow to pin such memory so that it can always be evicted.
+ *
+ * MEMORY_DEVICE_FS_DAX:
+ * Host memory that has similar access semantics as System RAM i.e. DMA
+ * coherent and supports page pinning. In support of coordinating page
+ * pinning vs other operations MEMORY_DEVICE_FS_DAX arranges for a
+ * wakeup event whenever a page is unpinned and becomes idle. This
+ * wakeup is used to coordinate physical address space management (ex:
+ * fs truncate/hole punch) vs pinned pages (ex: device dma).
  */
 enum memory_type {
-	MEMORY_DEVICE_HOST = 0,
-	MEMORY_DEVICE_PRIVATE,
+	MEMORY_DEVICE_PRIVATE = 1,
 	MEMORY_DEVICE_PUBLIC,
+	MEMORY_DEVICE_FS_DAX,
 };
 
 /*
@@ -123,15 +123,18 @@ struct dev_pagemap {
 };
 
 #ifdef CONFIG_ZONE_DEVICE
+void generic_dax_pagefree(struct page *page, void *data);
 void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap);
 struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
 		struct dev_pagemap *pgmap);
 
 unsigned long vmem_altmap_offset(struct vmem_altmap *altmap);
 void vmem_altmap_free(struct vmem_altmap *altmap, unsigned long nr_pfns);
-
-static inline bool is_zone_device_page(const struct page *page);
 #else
+static inline void generic_dax_pagefree(struct page *page, void *data)
+{
+}
+
 static inline void *devm_memremap_pages(struct device *dev,
 		struct dev_pagemap *pgmap)
 {
@@ -161,20 +164,6 @@ static inline void vmem_altmap_free(struct vmem_altmap *altmap,
 }
 #endif /* CONFIG_ZONE_DEVICE */
 
-#if defined(CONFIG_DEVICE_PRIVATE) || defined(CONFIG_DEVICE_PUBLIC)
-static inline bool is_device_private_page(const struct page *page)
-{
-	return is_zone_device_page(page) &&
-		page->pgmap->type == MEMORY_DEVICE_PRIVATE;
-}
-
-static inline bool is_device_public_page(const struct page *page)
-{
-	return is_zone_device_page(page) &&
-		page->pgmap->type == MEMORY_DEVICE_PUBLIC;
-}
-#endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
-
 static inline void put_dev_pagemap(struct dev_pagemap *pgmap)
 {
 	if (pgmap)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1ac1f06a4be6..6e19265ee8f8 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -821,27 +821,65 @@ static inline bool is_zone_device_page(const struct page *page)
 }
 #endif
 
-#if defined(CONFIG_DEVICE_PRIVATE) || defined(CONFIG_DEVICE_PUBLIC)
-void put_zone_device_private_or_public_page(struct page *page);
-DECLARE_STATIC_KEY_FALSE(device_private_key);
-#define IS_HMM_ENABLED static_branch_unlikely(&device_private_key)
-static inline bool is_device_private_page(const struct page *page);
-static inline bool is_device_public_page(const struct page *page);
-#else /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
-static inline void put_zone_device_private_or_public_page(struct page *page)
+#ifdef CONFIG_DEV_PAGEMAP_OPS
+void dev_pagemap_get_ops(void);
+void dev_pagemap_put_ops(void);
+void __put_devmap_managed_page(struct page *page);
+DECLARE_STATIC_KEY_FALSE(devmap_managed_key);
+static inline bool put_devmap_managed_page(struct page *page)
+{
+	if (!static_branch_unlikely(&devmap_managed_key))
+		return false;
+	if (!is_zone_device_page(page))
+		return false;
+	switch (page->pgmap->type) {
+	case MEMORY_DEVICE_PRIVATE:
+	case MEMORY_DEVICE_PUBLIC:
+	case MEMORY_DEVICE_FS_DAX:
+		__put_devmap_managed_page(page);
+		return true;
+	default:
+		break;
+	}
+	return false;
+}
+
+static inline bool is_device_private_page(const struct page *page)
 {
+	return is_zone_device_page(page) &&
+		page->pgmap->type == MEMORY_DEVICE_PRIVATE;
 }
-#define IS_HMM_ENABLED 0
+
+static inline bool is_device_public_page(const struct page *page)
+{
+	return is_zone_device_page(page) &&
+		page->pgmap->type == MEMORY_DEVICE_PUBLIC;
+}
+
+#else /* CONFIG_DEV_PAGEMAP_OPS */
+static inline void dev_pagemap_get_ops(void)
+{
+}
+
+static inline void dev_pagemap_put_ops(void)
+{
+}
+
+static inline bool put_devmap_managed_page(struct page *page)
+{
+	return false;
+}
+
 static inline bool is_device_private_page(const struct page *page)
 {
 	return false;
 }
+
 static inline bool is_device_public_page(const struct page *page)
 {
 	return false;
 }
-#endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
-
+#endif /* CONFIG_DEV_PAGEMAP_OPS */
 
 static inline void get_page(struct page *page)
 {
@@ -859,16 +897,13 @@ static inline void put_page(struct page *page)
 	page = compound_head(page);
 
 	/*
-	 * For private device pages we need to catch refcount transition from
-	 * 2 to 1, when refcount reach one it means the private device page is
-	 * free and we need to inform the device driver through callback. See
+	 * For devmap managed pages we need to catch refcount transition from
+	 * 2 to 1, when refcount reach one it means the page is free and we
+	 * need to inform the device driver through callback. See
 	 * include/linux/memremap.h and HMM for details.
 	 */
-	if (IS_HMM_ENABLED && unlikely(is_device_private_page(page) ||
-	    unlikely(is_device_public_page(page)))) {
-		put_zone_device_private_or_public_page(page);
+	if (put_devmap_managed_page(page))
 		return;
-	}
 
 	if (put_page_testzero(page))
 		__put_page(page);
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 37a9604133f6..3e546c6beb42 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -9,12 +9,19 @@
 #include <linux/memory_hotplug.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/wait_bit.h>
 
 static DEFINE_MUTEX(pgmap_lock);
 static RADIX_TREE(pgmap_radix, GFP_KERNEL);
 #define SECTION_MASK ~((1UL << PA_SECTION_SHIFT) - 1)
 #define SECTION_SIZE (1UL << PA_SECTION_SHIFT)
 
+void generic_dax_pagefree(struct page *page, void *data)
+{
+	wake_up_var(&page->_refcount);
+}
+EXPORT_SYMBOL_GPL(generic_dax_pagefree);
+
 static unsigned long order_at(struct resource *res, unsigned long pgoff)
 {
 	unsigned long phys_pgoff = PHYS_PFN(res->start) + pgoff;
@@ -301,8 +308,30 @@ struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
 	return pgmap;
 }
 
-#if IS_ENABLED(CONFIG_DEVICE_PRIVATE) ||  IS_ENABLED(CONFIG_DEVICE_PUBLIC)
-void put_zone_device_private_or_public_page(struct page *page)
+#ifdef CONFIG_DEV_PAGEMAP_OPS
+DEFINE_STATIC_KEY_FALSE(devmap_managed_key);
+EXPORT_SYMBOL_GPL(devmap_managed_key);
+static atomic_t devmap_enable;
+
+/*
+ * Toggle the static key for ->page_free() callbacks when dev_pagemap
+ * pages go idle.
+ */
+void dev_pagemap_get_ops(void)
+{
+	if (atomic_inc_return(&devmap_enable) == 1)
+		static_branch_enable(&devmap_managed_key);
+}
+EXPORT_SYMBOL_GPL(dev_pagemap_get_ops);
+
+void dev_pagemap_put_ops(void)
+{
+	if (atomic_dec_and_test(&devmap_enable))
+		static_branch_disable(&devmap_managed_key);
+}
+EXPORT_SYMBOL_GPL(dev_pagemap_put_ops);
+
+void __put_devmap_managed_page(struct page *page)
 {
 	int count = page_ref_dec_return(page);
 
@@ -322,5 +351,5 @@ void put_zone_device_private_or_public_page(struct page *page)
 	} else if (!count)
 		__put_page(page);
 }
-EXPORT_SYMBOL(put_zone_device_private_or_public_page);
-#endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
+EXPORT_SYMBOL_GPL(__put_devmap_managed_page);
+#endif /* CONFIG_DEV_PAGEMAP_OPS */
diff --git a/mm/Kconfig b/mm/Kconfig
index d5004d82a1d6..bf9d6366bced 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -692,6 +692,9 @@ config ARCH_HAS_HMM
 config MIGRATE_VMA_HELPER
 	bool
 
+config DEV_PAGEMAP_OPS
+	bool
+
 config HMM
 	bool
 	select MIGRATE_VMA_HELPER
@@ -712,6 +715,7 @@ config DEVICE_PRIVATE
 	bool "Unaddressable device memory (GPU memory, ...)"
 	depends on ARCH_HAS_HMM
 	select HMM
+	select DEV_PAGEMAP_OPS
 
 	help
 	  Allows creation of struct pages to represent unaddressable device
@@ -722,6 +726,7 @@ config DEVICE_PUBLIC
 	bool "Addressable device memory (like GPU memory)"
 	depends on ARCH_HAS_HMM
 	select HMM
+	select DEV_PAGEMAP_OPS
 
 	help
 	  Allows creation of struct pages to represent addressable device
diff --git a/mm/hmm.c b/mm/hmm.c
index 486dc394a5a3..de7b6bf77201 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -35,15 +35,6 @@
 
 #define PA_SECTION_SIZE (1UL << PA_SECTION_SHIFT)
 
-#if defined(CONFIG_DEVICE_PRIVATE) || defined(CONFIG_DEVICE_PUBLIC)
-/*
- * Device private memory see HMM (Documentation/vm/hmm.txt) or hmm.h
- */
-DEFINE_STATIC_KEY_FALSE(device_private_key);
-EXPORT_SYMBOL(device_private_key);
-#endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
-
-
 #if IS_ENABLED(CONFIG_HMM_MIRROR)
 static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
 
@@ -1167,7 +1158,7 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 	resource_size_t addr;
 	int ret;
 
-	static_branch_enable(&device_private_key);
+	dev_pagemap_get_ops();
 
 	devmem = devres_alloc_node(&hmm_devmem_release, sizeof(*devmem),
 				   GFP_KERNEL, dev_to_node(device));
@@ -1261,7 +1252,7 @@ struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
 	if (res->desc != IORES_DESC_DEVICE_PUBLIC_MEMORY)
 		return ERR_PTR(-EINVAL);
 
-	static_branch_enable(&device_private_key);
+	dev_pagemap_get_ops();
 
 	devmem = devres_alloc_node(&hmm_devmem_release, sizeof(*devmem),
 				   GFP_KERNEL, dev_to_node(device));
diff --git a/mm/swap.c b/mm/swap.c
index 3dd518832096..26fc9b5f1b6c 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -29,6 +29,7 @@
 #include <linux/cpu.h>
 #include <linux/notifier.h>
 #include <linux/backing-dev.h>
+#include <linux/memremap.h>
 #include <linux/memcontrol.h>
 #include <linux/gfp.h>
 #include <linux/uio.h>
@@ -743,7 +744,7 @@ void release_pages(struct page **pages, int nr)
 						       flags);
 				locked_pgdat = NULL;
 			}
-			put_zone_device_private_or_public_page(page);
+			put_devmap_managed_page(page);
 			continue;
 		}
 
