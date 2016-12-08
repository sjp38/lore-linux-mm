Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 035276B0260
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 10:39:31 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id p16so290129142qta.5
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 07:39:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t20si17529563qki.297.2016.12.08.07.39.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 07:39:30 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM v14 03/16] mm/ZONE_DEVICE/devmem_pages_remove: allow early removal of device memory
Date: Thu,  8 Dec 2016 11:39:31 -0500
Message-Id: <1481215184-18551-4-git-send-email-jglisse@redhat.com>
In-Reply-To: <1481215184-18551-1-git-send-email-jglisse@redhat.com>
References: <1481215184-18551-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

Some device driver manage multiple physical devices memory from a single
fake device driver. In that case the fake device might outlive the real
device and ZONE_DEVICE and its resource allocated for a real device would
waste resources in the meantime.

This patch allow early removal of ZONE_DEVICE and associated resource,
before device driver is tear down.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 include/linux/memremap.h |  7 +++++++
 kernel/memremap.c        | 14 ++++++++++++++
 2 files changed, 21 insertions(+)

diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index f7e0609..32314d2 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -53,6 +53,7 @@ struct dev_pagemap {
 void *devm_memremap_pages(struct device *dev, struct resource *res,
 		struct percpu_ref *ref, struct vmem_altmap *altmap);
 struct dev_pagemap *find_dev_pagemap(resource_size_t phys);
+int devm_memremap_pages_remove(struct device *dev, struct dev_pagemap *pgmap);
 
 static inline bool dev_page_allow_migrate(const struct page *page)
 {
@@ -78,6 +79,12 @@ static inline struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
 	return NULL;
 }
 
+static inline int devm_memremap_pages_remove(struct device *dev,
+					     struct dev_pagemap *pgmap)
+{
+	return -EINVAL;
+}
+
 static inline bool dev_page_allow_migrate(const struct page *page)
 {
 	return false;
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 07665eb..250ef25 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -387,6 +387,20 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
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
