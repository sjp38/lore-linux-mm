Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 51A6E6B0662
	for <linux-mm@kvack.org>; Fri, 18 May 2018 15:45:26 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id bd7-v6so5621666plb.20
        for <linux-mm@kvack.org>; Fri, 18 May 2018 12:45:26 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o1-v6si6468263pgp.273.2018.05.18.12.45.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 18 May 2018 12:45:25 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 17/17] mm: Distinguish VMalloc pages
Date: Fri, 18 May 2018 12:45:19 -0700
Message-Id: <20180518194519.3820-18-willy@infradead.org>
In-Reply-To: <20180518194519.3820-1-willy@infradead.org>
References: <20180518194519.3820-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

For diagnosing various performance and memory-leak problems, it is helpful
to be able to distinguish pages which are in use as VMalloc pages.
Unfortunately, we cannot use the page_type field in struct page, as
this is in use for mapcount by some drivers which map vmalloced pages
to userspace.

Use a special page->mapping value to distinguish VMalloc pages from
other kinds of pages.  Also record a pointer to the vm_struct and the
offset within the area in struct page to help reconstruct exactly what
this page is being used for.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/proc/page.c                         |  2 ++
 include/linux/mm_types.h               |  5 +++++
 include/linux/page-flags.h             | 25 +++++++++++++++++++++++++
 include/uapi/linux/kernel-page-flags.h |  1 +
 mm/vmalloc.c                           |  5 ++++-
 tools/vm/page-types.c                  |  1 +
 6 files changed, 38 insertions(+), 1 deletion(-)

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
index 530a9a2b039b..9a3b677e2c1d 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -146,6 +146,11 @@ struct page {
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
index 901943e4754b..5232433175c1 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -699,6 +699,31 @@ PAGE_TYPE_OPS(Kmemcg, kmemcg)
  */
 PAGE_TYPE_OPS(Table, table)
 
+/*
+ * vmalloc pages may be mapped to userspace, so we need some other way
+ * to distinguish them from other kinds of pages.  Use page->mapping
+ * for this purpose.  Values below 0x1000 cannot be real pointers.
+ */
+#define MAPPING_VMalloc		(void *)0x440
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
index 5fbf27e7f956..98bc690d472d 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1535,7 +1535,7 @@ static void __vunmap(const void *addr, int deallocate_pages)
 		for (i = 0; i < area->nr_pages; i++) {
 			struct page *page = area->pages[i];
 
-			BUG_ON(!page);
+			__ClearPageVMalloc(page);
 			__free_pages(page, 0);
 		}
 
@@ -1704,6 +1704,9 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
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
2.17.0
