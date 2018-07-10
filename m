Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2D7656B0005
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 12:53:49 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h14-v6so14373802pfi.19
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 09:53:49 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f12-v6si15760657pgq.559.2018.07.10.09.53.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 10 Jul 2018 09:53:47 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v7] mm: Distinguish VMalloc pages
Date: Tue, 10 Jul 2018 09:53:26 -0700
Message-Id: <20180710165326.9378-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

For diagnosing various performance and memory-leak problems, it is helpful
to be able to distinguish pages which are in use as VMalloc pages.
Unfortunately, we cannot use the page_type field in struct page, as
this is in use for mapcount by some drivers which map vmalloced pages
to userspace.

Use a special page->mapping value to distinguish VMalloc pages from
other kinds of pages.  Also record a pointer to the vm_struct and the
offset within the area in struct page to help reconstruct exactly what
this page is being used for.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
v7: Use a value which has the bottom bit set so that page_mapping()
returns NULL.  Comments updated to note this bit of "cleverness".

 fs/proc/page.c                         |  2 ++
 include/linux/mm_types.h               |  5 +++++
 include/linux/page-flags.h             | 26 ++++++++++++++++++++++++++
 include/uapi/linux/kernel-page-flags.h |  1 +
 mm/vmalloc.c                           |  5 ++++-
 tools/vm/page-types.c                  |  1 +
 6 files changed, 39 insertions(+), 1 deletion(-)

diff --git a/fs/proc/page.c b/fs/proc/page.c
index 792c78a49174..fc83dae1af7b 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -156,6 +156,8 @@ u64 stable_page_flags(struct page *page)
 		u |= 1 << KPF_BALLOON;
 	if (PageTable(page))
 		u |= 1 << KPF_PGTABLE;
+	if (PageVMalloc(page))
+		u |= 1 << KPF_VMALLOC;
 
 	if (page_is_idle(page))
 		u |= 1 << KPF_IDLE;
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 21e1b6a9f113..8a4698b368de 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -153,6 +153,11 @@ struct page {
 			spinlock_t ptl;
 #endif
 		};
+		struct {	/* VMalloc pages */
+			struct vm_struct *vm_area;
+			unsigned long vm_offset;
+			unsigned long _vm_id;	/* MAPPING_VMalloc */
+		};
 		struct {	/* ZONE_DEVICE pages */
 			/** @pgmap: Points to the hosting device page map. */
 			struct dev_pagemap *pgmap;
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 901943e4754b..588b8dd28a85 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -699,6 +699,32 @@ PAGE_TYPE_OPS(Kmemcg, kmemcg)
  */
 PAGE_TYPE_OPS(Table, table)
 
+/*
+ * vmalloc pages may be mapped to userspace, so we need some other way
+ * to distinguish them from other kinds of pages.  Use page->mapping for
+ * this purpose.  Values below 0x1000 cannot be real pointers.  Setting
+ * the bottom bit makes page_mapping() return NULL, which is what we want.
+ */
+#define MAPPING_VMalloc		(void *)0x441
+
+#define PAGE_MAPPING_OPS(name)						\
+static __always_inline int Page##name(struct page *page)		\
+{									\
+	return page->mapping == MAPPING_##name;				\
+}									\
+static __always_inline void __SetPage##name(struct page *page)		\
+{									\
+	VM_BUG_ON_PAGE(page->mapping != NULL, page);			\
+	page->mapping = MAPPING_##name;					\
+}									\
+static __always_inline void __ClearPage##name(struct page *page)	\
+{									\
+	VM_BUG_ON_PAGE(page->mapping != MAPPING_##name, page);		\
+	page->mapping = NULL;						\
+}
+
+PAGE_MAPPING_OPS(VMalloc)
+
 extern bool is_free_buddy_page(struct page *page);
 
 __PAGEFLAG(Isolated, isolated, PF_ANY);
diff --git a/include/uapi/linux/kernel-page-flags.h b/include/uapi/linux/kernel-page-flags.h
index 21b9113c69da..6800968b8f47 100644
--- a/include/uapi/linux/kernel-page-flags.h
+++ b/include/uapi/linux/kernel-page-flags.h
@@ -36,5 +36,6 @@
 #define KPF_ZERO_PAGE		24
 #define KPF_IDLE		25
 #define KPF_PGTABLE		26
+#define KPF_VMALLOC		27
 
 #endif /* _UAPILINUX_KERNEL_PAGE_FLAGS_H */
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 1863390fa09c..99331453e114 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1522,7 +1522,7 @@ static void __vunmap(const void *addr, int deallocate_pages)
 		for (i = 0; i < area->nr_pages; i++) {
 			struct page *page = area->pages[i];
 
-			BUG_ON(!page);
+			__ClearPageVMalloc(page);
 			__free_pages(page, 0);
 		}
 
@@ -1691,6 +1691,9 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 			area->nr_pages = i;
 			goto fail;
 		}
+		__SetPageVMalloc(page);
+		page->vm_area = area;
+		page->vm_offset = i;
 		area->pages[i] = page;
 		if (gfpflags_allow_blocking(gfp_mask))
 			cond_resched();
diff --git a/tools/vm/page-types.c b/tools/vm/page-types.c
index cce853dca691..25cc21855be4 100644
--- a/tools/vm/page-types.c
+++ b/tools/vm/page-types.c
@@ -132,6 +132,7 @@ static const char * const page_flag_names[] = {
 	[KPF_THP]		= "t:thp",
 	[KPF_BALLOON]		= "o:balloon",
 	[KPF_PGTABLE]		= "g:pgtable",
+	[KPF_VMALLOC]		= "V:vmalloc",
 	[KPF_ZERO_PAGE]		= "z:zero_page",
 	[KPF_IDLE]              = "i:idle_page",
 
-- 
2.18.0
