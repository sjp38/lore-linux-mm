Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id F3AC86B0274
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 19:29:12 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id m18so554660pgd.13
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 16:29:12 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id y73si2853232pfj.569.2017.10.31.16.29.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 16:29:11 -0700 (PDT)
Subject: [PATCH 13/15] mm, devmap: introduce CONFIG_DEVMAP_MANAGED_PAGES
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 31 Oct 2017 16:22:46 -0700
Message-ID: <150949216597.24061.3943310722702629588.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150949209290.24061.6283157778959640151.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150949209290.24061.6283157778959640151.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, hch@lst.de

Combine the now three use cases of page-idle callbacks for ZONE_DEVICE
memory into a common selectable symbol.

Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/super.c      |    2 ++
 fs/Kconfig               |    1 +
 include/linux/memremap.h |   18 +++++++++++++++---
 include/linux/mm.h       |   46 ++++++++++++++++++++++++----------------------
 kernel/memremap.c        |   25 +++++++++++++++++++++----
 mm/Kconfig               |    5 +++++
 mm/hmm.c                 |   13 ++-----------
 mm/swap.c                |    3 ++-
 8 files changed, 72 insertions(+), 41 deletions(-)

diff --git a/drivers/dax/super.c b/drivers/dax/super.c
index 193e0cd8d90c..4ac359e14777 100644
--- a/drivers/dax/super.c
+++ b/drivers/dax/super.c
@@ -190,6 +190,7 @@ struct dax_device *fs_dax_claim_bdev(struct block_device *bdev, void *owner)
 		return NULL;
 	}
 
+	devmap_managed_pages_enable();
 	pgmap->type = MEMORY_DEVICE_FS_DAX;
 	pgmap->page_free = generic_dax_pagefree;
 	pgmap->data = owner;
@@ -214,6 +215,7 @@ void fs_dax_release(struct dax_device *dax_dev, void *owner)
 	pgmap->type = MEMORY_DEVICE_HOST;
 	pgmap->page_free = NULL;
 	pgmap->data = NULL;
+	devmap_managed_pages_disable();
 	mutex_unlock(&devmap_lock);
 }
 EXPORT_SYMBOL_GPL(fs_dax_release);
diff --git a/fs/Kconfig b/fs/Kconfig
index b40128bf6d1a..cd4ee17ecdd8 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -38,6 +38,7 @@ config FS_DAX
 	bool "Direct Access (DAX) support"
 	depends on MMU
 	depends on !(ARM || MIPS || SPARC)
+	select DEVMAP_MANAGED_PAGES
 	select FS_IOMAP
 	select DAX
 	help
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 39d2de3f744b..a6716f5335e7 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -1,6 +1,5 @@
 #ifndef _LINUX_MEMREMAP_H_
 #define _LINUX_MEMREMAP_H_
-#include <linux/mm.h>
 #include <linux/ioport.h>
 #include <linux/percpu-refcount.h>
 
@@ -138,6 +137,9 @@ struct dev_pagemap {
 	enum memory_type type;
 };
 
+void devmap_managed_pages_enable(void);
+void devmap_managed_pages_disable(void);
+
 #ifdef CONFIG_ZONE_DEVICE
 void *devm_memremap_pages(struct device *dev, struct resource *res,
 		struct percpu_ref *ref, struct vmem_altmap *altmap);
@@ -164,7 +166,7 @@ static inline struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
 }
 #endif
 
-#if defined(CONFIG_DEVICE_PRIVATE) || defined(CONFIG_DEVICE_PUBLIC)
+#ifdef CONFIG_DEVMAP_MANAGED_PAGES
 static inline bool is_device_private_page(const struct page *page)
 {
 	return is_zone_device_page(page) &&
@@ -176,7 +178,17 @@ static inline bool is_device_public_page(const struct page *page)
 	return is_zone_device_page(page) &&
 		page->pgmap->type == MEMORY_DEVICE_PUBLIC;
 }
-#endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
+#else /* CONFIG_DEVMAP_MANAGED_PAGES */
+static inline bool is_device_private_page(const struct page *page)
+{
+	return false;
+}
+
+static inline bool is_device_public_page(const struct page *page)
+{
+	return false;
+}
+#endif /* CONFIG_DEVMAP_MANAGED_PAGES */
 
 /**
  * get_dev_pagemap() - take a new live reference on the dev_pagemap for @pfn
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8c1e3ac77285..2d6cf2583e10 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -800,27 +800,32 @@ static inline bool is_zone_device_page(const struct page *page)
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
-{
-}
-#define IS_HMM_ENABLED 0
-static inline bool is_device_private_page(const struct page *page)
+#ifdef CONFIG_DEVMAP_MANAGED_PAGES
+void __put_devmap_managed_page(struct page *page);
+DECLARE_STATIC_KEY_FALSE(devmap_managed_key);
+static inline bool put_devmap_managed_page(struct page *page)
 {
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
 	return false;
 }
-static inline bool is_device_public_page(const struct page *page)
+#else /* CONFIG_DEVMAP_MANAGED_PAGES */
+static inline bool put_devmap_managed_page(struct page *page)
 {
 	return false;
 }
-#endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
-
+#endif /* CONFIG_DEVMAP_MANAGED_PAGES */
 
 static inline void get_page(struct page *page)
 {
@@ -838,16 +843,13 @@ static inline void put_page(struct page *page)
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
index bf61cfa89c7d..8a4ebfe9db4e 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -503,9 +503,26 @@ struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
 }
 #endif /* CONFIG_ZONE_DEVICE */
 
+#ifdef CONFIG_DEVMAP_MANAGED_PAGES
+DEFINE_STATIC_KEY_FALSE(devmap_managed_key);
+EXPORT_SYMBOL(devmap_managed_key);
+static atomic_t devmap_enable;
 
-#if IS_ENABLED(CONFIG_DEVICE_PRIVATE) ||  IS_ENABLED(CONFIG_DEVICE_PUBLIC)
-void put_zone_device_private_or_public_page(struct page *page)
+void devmap_managed_pages_enable(void)
+{
+	if (atomic_inc_return(&devmap_enable) == 1)
+		static_branch_enable(&devmap_managed_key);
+}
+EXPORT_SYMBOL(devmap_managed_pages_enable);
+
+void devmap_managed_pages_disable(void)
+{
+	if (atomic_dec_and_test(&devmap_enable))
+		static_branch_disable(&devmap_managed_key);
+}
+EXPORT_SYMBOL(devmap_managed_pages_disable);
+
+void __put_devmap_managed_page(struct page *page)
 {
 	int count = page_ref_dec_return(page);
 
@@ -525,5 +542,5 @@ void put_zone_device_private_or_public_page(struct page *page)
 	} else if (!count)
 		__put_page(page);
 }
-EXPORT_SYMBOL(put_zone_device_private_or_public_page);
-#endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
+EXPORT_SYMBOL(__put_devmap_managed_page);
+#endif /* CONFIG_DEVMAP_MANAGED_PAGES */
diff --git a/mm/Kconfig b/mm/Kconfig
index 9c4bdddd80c2..8ee95197dc9f 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -705,6 +705,9 @@ config ARCH_HAS_HMM
 config MIGRATE_VMA_HELPER
 	bool
 
+config DEVMAP_MANAGED_PAGES
+	bool
+
 config HMM
 	bool
 	select MIGRATE_VMA_HELPER
@@ -725,6 +728,7 @@ config DEVICE_PRIVATE
 	bool "Unaddressable device memory (GPU memory, ...)"
 	depends on ARCH_HAS_HMM
 	select HMM
+	select DEVMAP_MANAGED_PAGES
 
 	help
 	  Allows creation of struct pages to represent unaddressable device
@@ -735,6 +739,7 @@ config DEVICE_PUBLIC
 	bool "Addressable device memory (like GPU memory)"
 	depends on ARCH_HAS_HMM
 	select HMM
+	select DEVMAP_MANAGED_PAGES
 
 	help
 	  Allows creation of struct pages to represent addressable device
diff --git a/mm/hmm.c b/mm/hmm.c
index a88a847bccba..53c8f1dd821d 100644
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
 
@@ -998,7 +989,7 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 	resource_size_t addr;
 	int ret;
 
-	static_branch_enable(&device_private_key);
+	devmap_managed_pages_enable();
 
 	devmem = devres_alloc_node(&hmm_devmem_release, sizeof(*devmem),
 				   GFP_KERNEL, dev_to_node(device));
@@ -1092,7 +1083,7 @@ struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
 	if (res->desc != IORES_DESC_DEVICE_PUBLIC_MEMORY)
 		return ERR_PTR(-EINVAL);
 
-	static_branch_enable(&device_private_key);
+	devmap_managed_pages_enable();
 
 	devmem = devres_alloc_node(&hmm_devmem_release, sizeof(*devmem),
 				   GFP_KERNEL, dev_to_node(device));
diff --git a/mm/swap.c b/mm/swap.c
index a77d68f2c1b6..09c71044b565 100644
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
@@ -772,7 +773,7 @@ void release_pages(struct page **pages, int nr, bool cold)
 						       flags);
 				locked_pgdat = NULL;
 			}
-			put_zone_device_private_or_public_page(page);
+			put_devmap_managed_page(page);
 			continue;
 		}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
