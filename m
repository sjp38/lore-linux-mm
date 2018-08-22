Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 769B16B21F3
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 22:18:01 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id a26-v6so297916pgw.7
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 19:18:01 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id f9-v6si434492pgl.554.2018.08.21.19.17.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 19:17:58 -0700 (PDT)
From: Zhang Yi <yi.z.zhang@linux.intel.com>
Subject: [PATCH V4 3/4] mm: add a function to differentiate the pages is from DAX device memory
Date: Wed, 22 Aug 2018 18:56:48 +0800
Message-Id: <044309496afbb4121447dff6a453bd6b96d6068d.1534934405.git.yi.z.zhang@linux.intel.com>
In-Reply-To: <cover.1534934405.git.yi.z.zhang@linux.intel.com>
References: <cover.1534934405.git.yi.z.zhang@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan.j.williams@intel.com, dave.jiang@intel.com, yu.c.zhang@intel.com, pagupta@redhat.com, david@redhat.com, jack@suse.cz, hch@lst.de
Cc: linux-mm@kvack.org, rkrcmar@redhat.com, jglisse@redhat.com, yi.z.zhang@intel.com, Zhang Yi <yi.z.zhang@linux.intel.com>

DAX driver hotplug the device memory and move it to memory zone, these
pages will be marked reserved flag, however, some other kernel componet
will misconceive these pages are reserved mmio (ex: we map these dev_dax
or fs_dax pages to kvm for DIMM/NVDIMM backend). Together with the type
MEMORY_DEVICE_FS_DAX, we can use is_dax_page() to differentiate the pages
is DAX device memory or not.

Signed-off-by: Zhang Yi <yi.z.zhang@linux.intel.com>
Signed-off-by: Zhang Yu <yu.c.zhang@linux.intel.com>
Acked-by: Jan Kara <jack@suse.cz>
---
 include/linux/mm.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 68a5121..de5cbc3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -889,6 +889,13 @@ static inline bool is_device_public_page(const struct page *page)
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
@@ -912,6 +919,11 @@ static inline bool is_device_public_page(const struct page *page)
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
