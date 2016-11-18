Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3CC3B6B043A
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 12:17:48 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id n68so1888692itn.4
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 09:17:48 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d2si2716435itg.93.2016.11.18.09.17.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 09:17:47 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM v13 05/18] mm/ZONE_DEVICE/devmem_pages_remove: allow early removal of device memory
Date: Fri, 18 Nov 2016 13:18:14 -0500
Message-Id: <1479493107-982-6-git-send-email-jglisse@redhat.com>
In-Reply-To: <1479493107-982-1-git-send-email-jglisse@redhat.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

HMM wants to remove device memory early before device tear down so add an
helper to do that.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 include/linux/memremap.h |  7 +++++++
 kernel/memremap.c        | 14 ++++++++++++++
 2 files changed, 21 insertions(+)

diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 469c88d..b6f03e9 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -60,6 +60,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 			  struct percpu_ref *ref, struct vmem_altmap *altmap,
 			  struct dev_pagemap **ppgmap, int flags);
 struct dev_pagemap *find_dev_pagemap(resource_size_t phys);
+int devm_memremap_pages_remove(struct device *dev, struct dev_pagemap *pgmap);
 
 static inline bool is_addressable_page(const struct page *page)
 {
@@ -88,6 +89,12 @@ static inline struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
 	return NULL;
 }
 
+static inline int devm_memremap_pages_remove(struct device *dev,
+					     struct dev_pagemap *pgmap)
+{
+	return -EINVAL;
+}
+
 static inline bool is_addressable_page(const struct page *page)
 {
 	return true;
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 3d28048..cf83928 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -401,6 +401,20 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 }
 EXPORT_SYMBOL(devm_memremap_pages);
 
+static int devm_page_map_match(struct device *dev, void *data, void *match_data)
+{
+	struct page_map *page_map = data;
+
+	return &page_map->pgmap == match_data;
+}
+
+int devm_memremap_pages_remove(struct device *dev, struct dev_pagemap *pgmap)
+{
+	return devres_release(dev, &devm_memremap_pages_release,
+			      &devm_page_map_match, pgmap);
+}
+EXPORT_SYMBOL(devm_memremap_pages_remove);
+
 unsigned long vmem_altmap_offset(struct vmem_altmap *altmap)
 {
 	/* number of pfns from base where pfn_to_page() is valid */
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
