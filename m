Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 16A826B0009
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 08:44:50 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id u65so1239894pfd.7
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 05:44:50 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o129si4250428pfo.209.2018.03.07.05.44.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Mar 2018 05:44:48 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 3/4] mm: Mark pages allocated through vmalloc
Date: Wed,  7 Mar 2018 05:44:42 -0800
Message-Id: <20180307134443.32646-4-willy@infradead.org>
In-Reply-To: <20180307134443.32646-1-willy@infradead.org>
References: <20180307134443.32646-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

Use a bit in page_type to mark pages which have been allocated through
vmalloc.  This can be helpful when debugging crashdumps or analysing
memory fragmentation.  Add a KPF flag to report these pages to userspace
and update page-types.c to interpret that flag.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/proc/page.c                         | 2 ++
 include/linux/page-flags.h             | 6 ++++++
 include/uapi/linux/kernel-page-flags.h | 2 +-
 mm/vmalloc.c                           | 2 ++
 tools/vm/page-types.c                  | 1 +
 5 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/fs/proc/page.c b/fs/proc/page.c
index 1491918a33c3..c9757af919a3 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -154,6 +154,8 @@ u64 stable_page_flags(struct page *page)
 
 	if (PageBalloon(page))
 		u |= 1 << KPF_BALLOON;
+	if (PageVmalloc(page))
+		u |= 1 << KPF_VMALLOC;
 
 	if (page_is_idle(page))
 		u |= 1 << KPF_IDLE;
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index be3cd45efeb6..1503d314bb3d 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -643,6 +643,7 @@ PAGEFLAG_FALSE(DoubleMap)
 #define PG_buddy	0x00000080
 #define PG_balloon	0x00000100
 #define PG_kmemcg	0x00000200
+#define PG_vmalloc	0x00000400
 
 #define PageType(page, flag)						\
 	((page->page_type & (PAGE_TYPE_BASE | flag)) == PAGE_TYPE_BASE)
@@ -681,6 +682,11 @@ PAGE_TYPE_OPS(Balloon, balloon)
  */
 PAGE_TYPE_OPS(Kmemcg, kmemcg)
 
+/*
+ * Pages allocated through vmalloc are tagged with this bit.
+ */
+PAGE_TYPE_OPS(Vmalloc, vmalloc)
+
 extern bool is_free_buddy_page(struct page *page);
 
 __PAGEFLAG(Isolated, isolated, PF_ANY);
diff --git a/include/uapi/linux/kernel-page-flags.h b/include/uapi/linux/kernel-page-flags.h
index fa139841ec18..5f1735ff05b3 100644
--- a/include/uapi/linux/kernel-page-flags.h
+++ b/include/uapi/linux/kernel-page-flags.h
@@ -35,6 +35,6 @@
 #define KPF_BALLOON		23
 #define KPF_ZERO_PAGE		24
 #define KPF_IDLE		25
-
+#define KPF_VMALLOC		26
 
 #endif /* _UAPILINUX_KERNEL_PAGE_FLAGS_H */
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index ebff729cc956..3bc0538fc21b 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1536,6 +1536,7 @@ static void __vunmap(const void *addr, int deallocate_pages)
 			struct page *page = area->pages[i];
 
 			BUG_ON(!page);
+			__ClearPageVmalloc(page);
 			__free_pages(page, 0);
 		}
 
@@ -1705,6 +1706,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 			area->nr_pages = i;
 			goto fail;
 		}
+		__SetPageVmalloc(page);
 		area->pages[i] = page;
 		if (gfpflags_allow_blocking(gfp_mask|highmem_mask))
 			cond_resched();
diff --git a/tools/vm/page-types.c b/tools/vm/page-types.c
index a8783f48f77f..116f59eff5e2 100644
--- a/tools/vm/page-types.c
+++ b/tools/vm/page-types.c
@@ -131,6 +131,7 @@ static const char * const page_flag_names[] = {
 	[KPF_KSM]		= "x:ksm",
 	[KPF_THP]		= "t:thp",
 	[KPF_BALLOON]		= "o:balloon",
+	[KPF_VMALLOC]		= "V:vmalloc",
 	[KPF_ZERO_PAGE]		= "z:zero_page",
 	[KPF_IDLE]              = "i:idle_page",
 
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
