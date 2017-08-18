Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 52D1B6B025F
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 23:29:04 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id t37so43458437qtg.6
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 20:29:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f189si4219038qkc.389.2017.08.17.20.29.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 20:29:03 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH] mm/hmm: avoid bloating arch that do not make use of HMM
Date: Thu, 17 Aug 2017 23:28:58 -0400
Message-Id: <20170818032858.7447-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

This move all new code including new page migration helper behind
kernel Kconfig option so that there is no codee bloat for arch or
user that do not want to use HMM or any of its associated features.

arm allyesconfig (without all the patchset, then with and this patch):
   text	   data	    bss	    dec	    hex	filename
83721896	46511131	27582964	157815991	96814b7	../without/vmlinux
83722364	46511131	27582964	157816459	968168b	vmlinux

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/memremap.h | 22 +++++++---------------
 include/linux/migrate.h  | 13 +++++++++++++
 include/linux/mm.h       | 26 +++++++++++++++++---------
 mm/Kconfig               |  4 ++++
 mm/Makefile              |  3 ++-
 mm/hmm.c                 |  6 +++---
 mm/migrate.c             |  2 ++
 7 files changed, 48 insertions(+), 28 deletions(-)

diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index f8ee1c73ad2d..79f8ba7c3894 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -138,18 +138,6 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 struct dev_pagemap *find_dev_pagemap(resource_size_t phys);
 
 static inline bool is_zone_device_page(const struct page *page);
-
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
 #else
 static inline void *devm_memremap_pages(struct device *dev,
 		struct resource *res, struct percpu_ref *ref,
@@ -168,17 +156,21 @@ static inline struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
 {
 	return NULL;
 }
+#endif
 
+#if defined(CONFIG_DEVICE_PRIVATE) || defined(CONFIG_DEVICE_PUBLIC)
 static inline bool is_device_private_page(const struct page *page)
 {
-	return false;
+	return is_zone_device_page(page) &&
+		page->pgmap->type == MEMORY_DEVICE_PRIVATE;
 }
 
 static inline bool is_device_public_page(const struct page *page)
 {
-	return false;
+	return is_zone_device_page(page) &&
+		page->pgmap->type == MEMORY_DEVICE_PUBLIC;
 }
-#endif
+#endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
 
 /**
  * get_dev_pagemap() - take a new live reference on the dev_pagemap for @pfn
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index d4e6d12a0b40..643c7ae7d7b4 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -265,6 +265,7 @@ struct migrate_vma_ops {
 				 void *private);
 };
 
+#if defined(CONFIG_MIGRATE_VMA_HELPER)
 int migrate_vma(const struct migrate_vma_ops *ops,
 		struct vm_area_struct *vma,
 		unsigned long start,
@@ -272,6 +273,18 @@ int migrate_vma(const struct migrate_vma_ops *ops,
 		unsigned long *src,
 		unsigned long *dst,
 		void *private);
+#else
+static inline int migrate_vma(const struct migrate_vma_ops *ops,
+			      struct vm_area_struct *vma,
+			      unsigned long start,
+			      unsigned long end,
+			      unsigned long *src,
+			      unsigned long *dst,
+			      void *private)
+{
+	return -EINVAL;
+}
+#endif /* IS_ENABLED(CONFIG_MIGRATE_VMA_HELPER) */
 
 #endif /* CONFIG_MIGRATION */
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index d1d161efefa0..663a2916a3bf 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -796,18 +796,27 @@ static inline bool is_zone_device_page(const struct page *page)
 }
 #endif
 
-#if IS_ENABLED(CONFIG_DEVICE_PRIVATE) ||  IS_ENABLED(CONFIG_DEVICE_PUBLIC)
+#if defined(CONFIG_DEVICE_PRIVATE) || defined(CONFIG_DEVICE_PUBLIC)
 void put_zone_device_private_or_public_page(struct page *page);
-#else
+DECLARE_STATIC_KEY_FALSE(device_private_key);
+#define IS_HMM_ENABLED static_branch_unlikely(&device_private_key)
+static inline bool is_device_private_page(const struct page *page);
+static inline bool is_device_public_page(const struct page *page);
+#else /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
 static inline void put_zone_device_private_or_public_page(struct page *page)
 {
 }
+#define IS_HMM_ENABLED 0
+static inline bool is_device_private_page(const struct page *page)
+{
+	return false;
+}
+static inline bool is_device_public_page(const struct page *page)
+{
+	return false;
+}
 #endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
 
-static inline bool is_device_private_page(const struct page *page);
-static inline bool is_device_public_page(const struct page *page);
-
-DECLARE_STATIC_KEY_FALSE(device_private_key);
 
 static inline void get_page(struct page *page)
 {
@@ -830,9 +839,8 @@ static inline void put_page(struct page *page)
 	 * free and we need to inform the device driver through callback. See
 	 * include/linux/memremap.h and HMM for details.
 	 */
-	if (static_branch_unlikely(&device_private_key) &&
-	    unlikely(is_device_private_page(page) ||
-		     is_device_public_page(page))) {
+	if (IS_HMM_ENABLED && unlikely(is_device_private_page(page) ||
+	    unlikely(is_device_public_page(page)))) {
 		put_zone_device_private_or_public_page(page);
 		return;
 	}
diff --git a/mm/Kconfig b/mm/Kconfig
index 5152959e1912..798f992761fb 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -701,8 +701,12 @@ config ARCH_HAS_HMM
 	depends on MEMORY_HOTREMOVE
 	depends on SPARSEMEM_VMEMMAP
 
+config MIGRATE_VMA_HELPER
+	bool
+
 config HMM
 	bool
+	select MIGRATE_VMA_HELPER
 
 config HMM_MIRROR
 	bool "HMM mirror CPU page table into a device page table"
diff --git a/mm/Makefile b/mm/Makefile
index 1cde2a8bed97..e3ac3aeb533b 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -39,7 +39,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o \
 			   mm_init.o mmu_context.o percpu.o slab_common.o \
 			   compaction.o vmacache.o swap_slots.o \
 			   interval_tree.o list_lru.o workingset.o \
-			   debug.o hmm.o $(mmu-y)
+			   debug.o $(mmu-y)
 
 obj-y += init-mm.o
 
@@ -104,3 +104,4 @@ obj-$(CONFIG_FRAME_VECTOR) += frame_vector.o
 obj-$(CONFIG_DEBUG_PAGE_REF) += debug_page_ref.o
 obj-$(CONFIG_HARDENED_USERCOPY) += usercopy.o
 obj-$(CONFIG_PERCPU_STATS) += percpu-stats.o
+obj-$(CONFIG_HMM) += hmm.o
diff --git a/mm/hmm.c b/mm/hmm.c
index 3faa4d40295e..4a179a16ab10 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -35,17 +35,17 @@
 
 #define PA_SECTION_SIZE (1UL << PA_SECTION_SHIFT)
 
-
+#if defined(CONFIG_DEVICE_PRIVATE) || defined(CONFIG_DEVICE_PUBLIC)
 /*
  * Device private memory see HMM (Documentation/vm/hmm.txt) or hmm.h
  */
 DEFINE_STATIC_KEY_FALSE(device_private_key);
 EXPORT_SYMBOL(device_private_key);
+static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
+#endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
 
 
 #ifdef CONFIG_HMM
-static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
-
 /*
  * struct hmm - HMM per mm struct
  *
diff --git a/mm/migrate.c b/mm/migrate.c
index 850001bc3c12..b94ce857fc52 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2138,6 +2138,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 
 #endif /* CONFIG_NUMA */
 
+#if defined(CONFIG_MIGRATE_VMA_HELPER)
 struct migrate_vma {
 	struct vm_area_struct	*vma;
 	unsigned long		*dst;
@@ -2991,3 +2992,4 @@ int migrate_vma(const struct migrate_vma_ops *ops,
 	return 0;
 }
 EXPORT_SYMBOL(migrate_vma);
+#endif /* defined(MIGRATE_VMA_HELPER) */
-- 
2.13.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
