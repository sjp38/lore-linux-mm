Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2A2CC6B000A
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 08:44:50 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id 101-v6so1142099ple.19
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 05:44:50 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x23si11412731pge.2.2018.03.07.05.44.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Mar 2018 05:44:48 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 4/4] mm: Mark pages in use for page tables
Date: Wed,  7 Mar 2018 05:44:43 -0800
Message-Id: <20180307134443.32646-5-willy@infradead.org>
In-Reply-To: <20180307134443.32646-1-willy@infradead.org>
References: <20180307134443.32646-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

Define a new PageTable bit in the page_type and use it to mark pages in
use as page tables.  This can be helpful when debugging crashdumps or
analysing memory fragmentation.  Add a KPF flag to report these pages
to userspace and update page-types.c to interpret that flag.

Note that only pages currently accounted as NR_PAGETABLES are tracked
as PageTable; this does not include pgd/p4d/pud/pmd pages.  Those will
be the subject of a later patch.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/tile/mm/pgtable.c                 | 3 +++
 fs/proc/page.c                         | 2 ++
 include/linux/mm.h                     | 2 ++
 include/linux/page-flags.h             | 6 ++++++
 include/uapi/linux/kernel-page-flags.h | 1 +
 tools/vm/page-types.c                  | 1 +
 6 files changed, 15 insertions(+)

diff --git a/arch/tile/mm/pgtable.c b/arch/tile/mm/pgtable.c
index ec5576fd3a86..6dff12db335d 100644
--- a/arch/tile/mm/pgtable.c
+++ b/arch/tile/mm/pgtable.c
@@ -206,6 +206,7 @@ struct page *pgtable_alloc_one(struct mm_struct *mm, unsigned long address,
 	 */
 	for (i = 1; i < order; ++i) {
 		init_page_count(p+i);
+		__SetPageTable(p+i);
 		inc_zone_page_state(p+i, NR_PAGETABLE);
 	}
 
@@ -226,6 +227,7 @@ void pgtable_free(struct mm_struct *mm, struct page *p, int order)
 
 	for (i = 1; i < order; ++i) {
 		__free_page(p+i);
+		__ClearPageTable(p+i);
 		dec_zone_page_state(p+i, NR_PAGETABLE);
 	}
 }
@@ -240,6 +242,7 @@ void __pgtable_free_tlb(struct mmu_gather *tlb, struct page *pte,
 
 	for (i = 1; i < order; ++i) {
 		tlb_remove_page(tlb, pte + i);
+		__ClearPageTable(pte + i);
 		dec_zone_page_state(pte + i, NR_PAGETABLE);
 	}
 }
diff --git a/fs/proc/page.c b/fs/proc/page.c
index c9757af919a3..80275e7a963b 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -156,6 +156,8 @@ u64 stable_page_flags(struct page *page)
 		u |= 1 << KPF_BALLOON;
 	if (PageVmalloc(page))
 		u |= 1 << KPF_VMALLOC;
+	if (PageTable(page))
+		u |= 1 << KPF_PGTABLE;
 
 	if (page_is_idle(page))
 		u |= 1 << KPF_IDLE;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ad06d42adb1a..7a15042d6828 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1829,6 +1829,7 @@ static inline bool pgtable_page_ctor(struct page *page)
 {
 	if (!ptlock_init(page))
 		return false;
+	__SetPageTable(page);
 	inc_zone_page_state(page, NR_PAGETABLE);
 	return true;
 }
@@ -1836,6 +1837,7 @@ static inline bool pgtable_page_ctor(struct page *page)
 static inline void pgtable_page_dtor(struct page *page)
 {
 	pte_lock_deinit(page);
+	__ClearPageTable(page);
 	dec_zone_page_state(page, NR_PAGETABLE);
 }
 
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 1503d314bb3d..aa5c8c1c6d38 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -644,6 +644,7 @@ PAGEFLAG_FALSE(DoubleMap)
 #define PG_balloon	0x00000100
 #define PG_kmemcg	0x00000200
 #define PG_vmalloc	0x00000400
+#define PG_table	0x00000800
 
 #define PageType(page, flag)						\
 	((page->page_type & (PAGE_TYPE_BASE | flag)) == PAGE_TYPE_BASE)
@@ -687,6 +688,11 @@ PAGE_TYPE_OPS(Kmemcg, kmemcg)
  */
 PAGE_TYPE_OPS(Vmalloc, vmalloc)
 
+/*
+ * Marks pages in use as page tables.
+ */
+PAGE_TYPE_OPS(Table, table)
+
 extern bool is_free_buddy_page(struct page *page);
 
 __PAGEFLAG(Isolated, isolated, PF_ANY);
diff --git a/include/uapi/linux/kernel-page-flags.h b/include/uapi/linux/kernel-page-flags.h
index 5f1735ff05b3..3c51d8bf8b7b 100644
--- a/include/uapi/linux/kernel-page-flags.h
+++ b/include/uapi/linux/kernel-page-flags.h
@@ -36,5 +36,6 @@
 #define KPF_ZERO_PAGE		24
 #define KPF_IDLE		25
 #define KPF_VMALLOC		26
+#define KPF_PGTABLE		27
 
 #endif /* _UAPILINUX_KERNEL_PAGE_FLAGS_H */
diff --git a/tools/vm/page-types.c b/tools/vm/page-types.c
index 116f59eff5e2..bbb992694f05 100644
--- a/tools/vm/page-types.c
+++ b/tools/vm/page-types.c
@@ -132,6 +132,7 @@ static const char * const page_flag_names[] = {
 	[KPF_THP]		= "t:thp",
 	[KPF_BALLOON]		= "o:balloon",
 	[KPF_VMALLOC]		= "V:vmalloc",
+	[KPF_PGTABLE]		= "g:pgtable",
 	[KPF_ZERO_PAGE]		= "z:zero_page",
 	[KPF_IDLE]              = "i:idle_page",
 
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
