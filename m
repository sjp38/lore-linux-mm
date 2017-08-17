Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id EC1A66B037C
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 20:06:06 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id c2so24889213qkb.10
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 17:06:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r55si1899072qtc.252.2017.08.16.17.06.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 17:06:06 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM-v25 08/19] mm/ZONE_DEVICE: special case put_page() for device private pages v4
Date: Wed, 16 Aug 2017 20:05:37 -0400
Message-Id: <20170817000548.32038-9-jglisse@redhat.com>
In-Reply-To: <20170817000548.32038-1-jglisse@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

A ZONE_DEVICE page that reach a refcount of 1 is free ie no longer
have any user. For device private pages this is important to catch
and thus we need to special case put_page() for this.

Changed since v3:
  - clear page mapping field
Changed since v2:
  - clear page active and waiters
Changed since v1:
  - use static key to disable special code path in put_page() by
    default
  - uninline put_zone_device_private_page()
  - fix build issues with some kernel config related to header
    inter-dependency

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 include/linux/memremap.h | 13 +++++++++++++
 include/linux/mm.h       | 31 ++++++++++++++++++++++---------
 kernel/memremap.c        | 25 ++++++++++++++++++++++++-
 mm/hmm.c                 |  8 ++++++++
 4 files changed, 67 insertions(+), 10 deletions(-)

diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 8e164ec9eed0..8aa6b82679e2 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -126,6 +126,14 @@ struct dev_pagemap {
 void *devm_memremap_pages(struct device *dev, struct resource *res,
 		struct percpu_ref *ref, struct vmem_altmap *altmap);
 struct dev_pagemap *find_dev_pagemap(resource_size_t phys);
+
+static inline bool is_zone_device_page(const struct page *page);
+
+static inline bool is_device_private_page(const struct page *page)
+{
+	return is_zone_device_page(page) &&
+		page->pgmap->type == MEMORY_DEVICE_PRIVATE;
+}
 #else
 static inline void *devm_memremap_pages(struct device *dev,
 		struct resource *res, struct percpu_ref *ref,
@@ -144,6 +152,11 @@ static inline struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
 {
 	return NULL;
 }
+
+static inline bool is_device_private_page(const struct page *page)
+{
+	return false;
+}
 #endif
 
 /**
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a59e149b958a..515d4ae611b2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -23,6 +23,7 @@
 #include <linux/page_ext.h>
 #include <linux/err.h>
 #include <linux/page_ref.h>
+#include <linux/memremap.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -788,25 +789,25 @@ static inline bool is_zone_device_page(const struct page *page)
 {
 	return page_zonenum(page) == ZONE_DEVICE;
 }
-
-static inline bool is_device_private_page(const struct page *page)
-{
-	/* See MEMORY_DEVICE_PRIVATE in include/linux/memory_hotplug.h */
-	return ((page_zonenum(page) == ZONE_DEVICE) &&
-		(page->pgmap->type == MEMORY_DEVICE_PRIVATE));
-}
 #else
 static inline bool is_zone_device_page(const struct page *page)
 {
 	return false;
 }
+#endif
 
-static inline bool is_device_private_page(const struct page *page)
+#ifdef CONFIG_DEVICE_PRIVATE
+void put_zone_device_private_page(struct page *page);
+#else
+static inline void put_zone_device_private_page(struct page *page)
 {
-	return false;
 }
 #endif
 
+static inline bool is_device_private_page(const struct page *page);
+
+DECLARE_STATIC_KEY_FALSE(device_private_key);
+
 static inline void get_page(struct page *page)
 {
 	page = compound_head(page);
@@ -822,6 +823,18 @@ static inline void put_page(struct page *page)
 {
 	page = compound_head(page);
 
+	/*
+	 * For private device pages we need to catch refcount transition from
+	 * 2 to 1, when refcount reach one it means the private device page is
+	 * free and we need to inform the device driver through callback. See
+	 * include/linux/memremap.h and HMM for details.
+	 */
+	if (static_branch_unlikely(&device_private_key) &&
+	    unlikely(is_device_private_page(page))) {
+		put_zone_device_private_page(page);
+		return;
+	}
+
 	if (put_page_testzero(page))
 		__put_page(page);
 }
diff --git a/kernel/memremap.c b/kernel/memremap.c
index d3241f51c1f0..398630c1fba3 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -11,7 +11,6 @@
  * General Public License for more details.
  */
 #include <linux/radix-tree.h>
-#include <linux/memremap.h>
 #include <linux/device.h>
 #include <linux/types.h>
 #include <linux/pfn_t.h>
@@ -476,3 +475,27 @@ struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
 	return pgmap ? pgmap->altmap : NULL;
 }
 #endif /* CONFIG_ZONE_DEVICE */
+
+
+#ifdef CONFIG_DEVICE_PRIVATE
+void put_zone_device_private_page(struct page *page)
+{
+	int count = page_ref_dec_return(page);
+
+	/*
+	 * If refcount is 1 then page is freed and refcount is stable as nobody
+	 * holds a reference on the page.
+	 */
+	if (count == 1) {
+		/* Clear Active bit in case of parallel mark_page_accessed */
+		__ClearPageActive(page);
+		__ClearPageWaiters(page);
+
+		page->mapping = NULL;
+
+		page->pgmap->page_free(page, page->pgmap->data);
+	} else if (!count)
+		__put_page(page);
+}
+EXPORT_SYMBOL(put_zone_device_private_page);
+#endif /* CONFIG_DEVICE_PRIVATE */
diff --git a/mm/hmm.c b/mm/hmm.c
index 91592dae364e..e615f337110a 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -25,9 +25,17 @@
 #include <linux/sched.h>
 #include <linux/swapops.h>
 #include <linux/hugetlb.h>
+#include <linux/jump_label.h>
 #include <linux/mmu_notifier.h>
 
 
+/*
+ * Device private memory see HMM (Documentation/vm/hmm.txt) or hmm.h
+ */
+DEFINE_STATIC_KEY_FALSE(device_private_key);
+EXPORT_SYMBOL(device_private_key);
+
+
 #ifdef CONFIG_HMM
 static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
 
-- 
2.13.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
