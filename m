Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 56C7F6B6ABF
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 14:25:33 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id t2so12016598pfj.15
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 11:25:33 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id f63si16103419pfg.136.2018.12.03.11.25.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 11:25:32 -0800 (PST)
Subject: [PATCH RFC 2/3] mm: Add support for exposing if dev_pagemap
 supports refcount pinning
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Mon, 03 Dec 2018 11:25:31 -0800
Message-ID: <154386513120.27193.7977541941078967487.stgit@ahduyck-desk1.amr.corp.intel.com>
In-Reply-To: <154386493754.27193.1300965403157243427.stgit@ahduyck-desk1.amr.corp.intel.com>
References: <154386493754.27193.1300965403157243427.stgit@ahduyck-desk1.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.j.williams@intel.com, pbonzini@redhat.com, yi.z.zhang@linux.intel.com, brho@google.com, kvm@vger.kernel.org, linux-nvdimm@lists.01.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.jiang@intel.com, yu.c.zhang@intel.com, pagupta@redhat.com, david@redhat.com, jack@suse.cz, hch@lst.de, rkrcmar@redhat.com, jglisse@redhat.com

Add a means of exposing if a pagemap supports refcount pinning. I am doing
this to expose if a given pagemap has backing struct pages that will allow
for the reference count of the page to be incremented to lock the page
into place.

The KVM code already has several spots where it was trying to use a
pfn_valid check combined with a PageReserved check to determien if it could
take a reference on the page. I am adding this check so in the case of the
page having the reserved flag checked we can check the pagemap for the page
to determine if we might fall into the special DAX case.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 drivers/nvdimm/pfn_devs.c |    2 ++
 include/linux/memremap.h  |    5 ++++-
 include/linux/mm.h        |   11 +++++++++++
 3 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index 6f22272e8d80..7a4a85bcf7f4 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -640,6 +640,8 @@ static int __nvdimm_setup_pfn(struct nd_pfn *nd_pfn, struct dev_pagemap *pgmap)
 	} else
 		return -ENXIO;
 
+	pgmap->support_refcount_pinning = true;
+
 	return 0;
 }
 
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 55db66b3716f..6e7b85542208 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -109,6 +109,8 @@ typedef void (*dev_page_free_t)(struct page *page, void *data);
  * @page_fault: callback when CPU fault on an unaddressable device page
  * @page_free: free page callback when page refcount reaches 1
  * @altmap: pre-allocated/reserved memory for vmemmap allocations
+ * @altmap_valid: bitflag indicating if altmap is valid
+ * @support_refcount_pinning: bitflag indicating if we support refcount pinning
  * @res: physical address range covered by @ref
  * @ref: reference count that pins the devm_memremap_pages() mapping
  * @kill: callback to transition @ref to the dead state
@@ -120,7 +122,8 @@ struct dev_pagemap {
 	dev_page_fault_t page_fault;
 	dev_page_free_t page_free;
 	struct vmem_altmap altmap;
-	bool altmap_valid;
+	bool altmap_valid:1;
+	bool support_refcount_pinning:1;
 	struct resource res;
 	struct percpu_ref *ref;
 	void (*kill)(struct percpu_ref *ref);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3eb3bf7774f1..5faf66dd4559 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -970,6 +970,12 @@ static inline bool is_pci_p2pdma_page(const struct page *page)
 }
 #endif /* CONFIG_PCI_P2PDMA */
 
+static inline bool is_device_pinnable_page(const struct page *page)
+{
+	return is_zone_device_page(page) &&
+		page->pgmap->support_refcount_pinning;
+}
+
 #else /* CONFIG_DEV_PAGEMAP_OPS */
 static inline void dev_pagemap_get_ops(void)
 {
@@ -998,6 +1004,11 @@ static inline bool is_pci_p2pdma_page(const struct page *page)
 {
 	return false;
 }
+
+static inline bool is_device_pinnable_page(const struct page *page)
+{
+	return false;
+}
 #endif /* CONFIG_DEV_PAGEMAP_OPS */
 
 static inline void get_page(struct page *page)
