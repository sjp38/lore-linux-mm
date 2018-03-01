Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 783856B0007
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 16:15:33 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id s6so1971899pgn.3
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 13:15:33 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e9-v6si3646919pln.492.2018.03.01.13.15.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 01 Mar 2018 13:15:31 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v4 3/4] mm: Mark pages allocated through vmalloc
Date: Thu,  1 Mar 2018 13:15:22 -0800
Message-Id: <20180301211523.21104-4-willy@infradead.org>
In-Reply-To: <20180301211523.21104-1-willy@infradead.org>
References: <20180301211523.21104-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>, linux-api@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

Use a bit in page_type to mark pages which have been allocated through
vmalloc.  This can be helpful when debugging crashdumps or analysing
memory fragmentation.  Add a KPF flag to report these pages to userspace
and update page-types.c to interpret that flag.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
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
index d151f590bbc6..8142ab716e90 100644
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
