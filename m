Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C302E6B0395
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:04:08 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id n141so42264330qke.1
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 08:04:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r5si4079142qkf.281.2017.03.16.08.03.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 08:03:53 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 03/16] mm/ZONE_DEVICE/free-page: callback when page is freed v3
Date: Thu, 16 Mar 2017 12:05:22 -0400
Message-Id: <1489680335-6594-4-git-send-email-jglisse@redhat.com>
In-Reply-To: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

When a ZONE_DEVICE page refcount reach 1 it means it is free and nobody
is holding a reference on it (only device to which the memory belong do).
Add a callback and call it when that happen so device driver can implement
their own free page management.

Changes since v2:
  - Move page refcount in put_zone_device_page()

Changes since v1:
  - Do not update devm_memremap_pages() to take extra argument

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 include/linux/memremap.h |  6 ++++++
 kernel/memremap.c        | 11 ++++++++++-
 2 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 29d2cca..3e04f58 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -35,19 +35,25 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
 }
 #endif
 
+typedef void (*dev_page_free_t)(struct page *page, void *data);
+
 /**
  * struct dev_pagemap - metadata for ZONE_DEVICE mappings
+ * @page_free: free page callback when page refcount reach 1
  * @altmap: pre-allocated/reserved memory for vmemmap allocations
  * @res: physical address range covered by @ref
  * @ref: reference count that pins the devm_memremap_pages() mapping
  * @dev: host device of the mapping for debug
+ * @data: privata data pointer for page_free
  * @flags: memory flags see MEMORY_* in memory_hotplug.h
  */
 struct dev_pagemap {
+	dev_page_free_t page_free;
 	struct vmem_altmap *altmap;
 	const struct resource *res;
 	struct percpu_ref *ref;
 	struct device *dev;
+	void *data;
 	int flags;
 };
 
diff --git a/kernel/memremap.c b/kernel/memremap.c
index c821946..19df1f5 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -190,7 +190,14 @@ EXPORT_SYMBOL(get_zone_device_page);
 
 void put_zone_device_page(struct page *page)
 {
-	page_ref_dec(page);
+	int count = page_ref_dec_return(page);
+
+	/*
+	 * If refcount is 1 then page is freed and refcount is stable as nobody
+	 * holds a reference on the page.
+	 */
+	if (page->pgmap->page_free && count == 1)
+		page->pgmap->page_free(page, page->pgmap->data);
 
 	put_dev_pagemap(page->pgmap);
 }
@@ -331,6 +338,8 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	pgmap->ref = ref;
 	pgmap->res = &page_map->res;
 	pgmap->flags = MEMORY_DEVICE;
+	pgmap->page_free = NULL;
+	pgmap->data = NULL;
 
 	mutex_lock(&pgmap_lock);
 	error = 0;
-- 
2.4.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
