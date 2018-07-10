Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 51EAF6B026B
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 04:25:37 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h14-v6so13539179pfi.19
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 01:25:37 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id t127-v6si16159487pfb.303.2018.07.10.01.25.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 01:25:36 -0700 (PDT)
From: Zhang Yi <yi.z.zhang@linux.intel.com>
Subject: [PATCH V2 3/4] mm: add a function to differentiate the pages is from DAX device memory
Date: Wed, 11 Jul 2018 01:03:51 +0800
Message-Id: <a0d220839ce0414f13e9394dffcd9abe8689dafe.1531241281.git.yi.z.zhang@linux.intel.com>
In-Reply-To: <cover.1531241281.git.yi.z.zhang@linux.intel.com>
References: <cover.1531241281.git.yi.z.zhang@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan.j.williams@intel.com, jack@suse.cz, hch@lst.de, yu.c.zhang@intel.com
Cc: linux-mm@kvack.org, rkrcmar@redhat.com, yi.z.zhang@intel.com, Zhang Yi <yi.z.zhang@linux.intel.com>

DAX driver hotplug the device memory and move it to memory zone, these
pages will be marked reserved flag, however, some other kernel componet
will misconceive these pages are reserved mmio (ex: we map these dev_dax
or fs_dax pages to kvm for DIMM/NVDIMM backend). Together with the type
MEMORY_DEVICE_FS_DAX, we can use is_dax_page() to differentiate the pages
is DAX device memory or not.

Signed-off-by: Zhang Yi <yi.z.zhang@linux.intel.com>
Signed-off-by: Zhang Yu <yu.c.zhang@linux.intel.com>
---
 include/linux/mm.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6e19265..9f0f690 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -856,6 +856,13 @@ static inline bool is_device_public_page(const struct page *page)
 		page->pgmap->type == MEMORY_DEVICE_PUBLIC;
 }
 
+static inline bool is_dax_page(const struct page *page)
+{
+	return is_zone_device_page(page) &&
+		(page->pgmap->type == MEMORY_DEVICE_FS_DAX ||
+		page->pgmap->type == MEMORY_DEVICE_DEV_DAX);
+}
+
 #else /* CONFIG_DEV_PAGEMAP_OPS */
 static inline void dev_pagemap_get_ops(void)
 {
@@ -879,6 +886,11 @@ static inline bool is_device_public_page(const struct page *page)
 {
 	return false;
 }
+
+static inline bool is_dax_page(const struct page *page)
+{
+	return false;
+}
 #endif /* CONFIG_DEV_PAGEMAP_OPS */
 
 static inline void get_page(struct page *page)
-- 
2.7.4
