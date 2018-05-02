Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 56E0D6B0005
	for <linux-mm@kvack.org>; Wed,  2 May 2018 11:27:36 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id k3so13122655pff.23
        for <linux-mm@kvack.org>; Wed, 02 May 2018 08:27:36 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z6si11710753pfk.194.2018.05.02.08.27.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 02 May 2018 08:27:34 -0700 (PDT)
Date: Wed, 2 May 2018 08:27:33 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: [RFC] Distinguish vmalloc pages
Message-ID: <20180502152733.GB2737@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Igor Stoppa <igor.stoppa@gmail.com>


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

This patch would be a superset of Igor's patch to add an ->area field to
struct page.  It's on top of my recent series to rearrange struct page.
I think it's a nice demonstration of how you don't have to go hunting
around for fields that may or may not be in use; you just add your own
little struct to the union, and you're done.  As well as being *really*
useful for debugging, of course!

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
index 42619e16047f..c51ddd27bfb4 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -141,6 +141,11 @@ struct page {
 			spinlock_t ptl;
 #endif
 		};
+		struct {	/* VMalloc pages */
+			struct vm_struct *vm_area;
+			unsigned long vm_offset;
+			unsigned long _vm_id;	/* MAPPING_VMalloc */
+		};
 
 		/** @rcu_head: You can use this to free a page by RCU. */
 		struct rcu_head rcu_head;
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
