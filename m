Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 66A8F6B025E
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 16:50:51 -0500 (EST)
Received: by mail-yw0-f199.google.com with SMTP id u68so281188315ywg.4
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 13:50:51 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s26si1698701ywa.45.2017.01.27.13.50.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jan 2017 13:50:50 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM v17 02/14] mm/ZONE_DEVICE/free-page: callback when page is freed v2
Date: Fri, 27 Jan 2017 17:52:09 -0500
Message-Id: <1485557541-7806-3-git-send-email-jglisse@redhat.com>
In-Reply-To: <1485557541-7806-1-git-send-email-jglisse@redhat.com>
References: <1485557541-7806-1-git-send-email-jglisse@redhat.com>
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

Changed since v1:
  - Do not update devm_memremap_pages() to take extra argument

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 include/linux/memremap.h | 8 +++++++-
 kernel/memremap.c        | 8 ++++++++
 2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index f7e0609..06fa74b 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -35,23 +35,29 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
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
  */
 struct dev_pagemap {
+	dev_page_free_t page_free;
 	struct vmem_altmap *altmap;
 	const struct resource *res;
 	struct percpu_ref *ref;
 	struct device *dev;
+	void *data;
 };
 
 #ifdef CONFIG_ZONE_DEVICE
 void *devm_memremap_pages(struct device *dev, struct resource *res,
-		struct percpu_ref *ref, struct vmem_altmap *altmap);
+			  struct percpu_ref *ref, struct vmem_altmap *altmap);
 struct dev_pagemap *find_dev_pagemap(resource_size_t phys);
 
 static inline bool dev_page_allow_migrate(const struct page *page)
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 07665eb..2f37c92 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -190,6 +190,12 @@ EXPORT_SYMBOL(get_zone_device_page);
 
 void put_zone_device_page(struct page *page)
 {
+	/*
+	 * If refcount is 1 then page is freed and refcount is stable as nobody
+	 * holds a reference on the page.
+	 */
+	if (page->pgmap->page_free && page_count(page) == 1)
+		page->pgmap->page_free(page, page->pgmap->data);
 	put_dev_pagemap(page->pgmap);
 }
 EXPORT_SYMBOL(put_zone_device_page);
@@ -322,6 +328,8 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	}
 	pgmap->ref = ref;
 	pgmap->res = &page_map->res;
+	pgmap->page_free = NULL;
+	pgmap->data = NULL;
 
 	mutex_lock(&pgmap_lock);
 	error = 0;
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
