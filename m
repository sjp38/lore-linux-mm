Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1BDD26B0006
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 14:49:22 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id i137so1408428pfe.0
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 11:49:22 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q7si1574126pga.86.2018.04.18.11.49.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 18 Apr 2018 11:49:20 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v3 03/14] mm: Mark pages in use for page tables
Date: Wed, 18 Apr 2018 11:49:01 -0700
Message-Id: <20180418184912.2851-4-willy@infradead.org>
In-Reply-To: <20180418184912.2851-1-willy@infradead.org>
References: <20180418184912.2851-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

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
 fs/proc/page.c                         | 2 ++
 include/linux/mm.h                     | 2 ++
 include/linux/page-flags.h             | 6 ++++++
 include/uapi/linux/kernel-page-flags.h | 2 +-
 tools/vm/page-types.c                  | 1 +
 5 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/fs/proc/page.c b/fs/proc/page.c
index 1491918a33c3..792c78a49174 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -154,6 +154,8 @@ u64 stable_page_flags(struct page *page)
 
 	if (PageBalloon(page))
 		u |= 1 << KPF_BALLOON;
+	if (PageTable(page))
+		u |= 1 << KPF_PGTABLE;
 
 	if (page_is_idle(page))
 		u |= 1 << KPF_IDLE;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 974e8f8ffe03..5c6069219425 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1819,6 +1819,7 @@ static inline bool pgtable_page_ctor(struct page *page)
 {
 	if (!ptlock_init(page))
 		return false;
+	__SetPageTable(page);
 	inc_zone_page_state(page, NR_PAGETABLE);
 	return true;
 }
@@ -1826,6 +1827,7 @@ static inline bool pgtable_page_ctor(struct page *page)
 static inline void pgtable_page_dtor(struct page *page)
 {
 	pte_lock_deinit(page);
+	__ClearPageTable(page);
 	dec_zone_page_state(page, NR_PAGETABLE);
 }
 
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 8c25b28a35aa..901943e4754b 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -655,6 +655,7 @@ PAGEFLAG_FALSE(DoubleMap)
 #define PG_buddy	0x00000080
 #define PG_balloon	0x00000100
 #define PG_kmemcg	0x00000200
+#define PG_table	0x00000400
 
 #define PageType(page, flag)						\
 	((page->page_type & (PAGE_TYPE_BASE | flag)) == PAGE_TYPE_BASE)
@@ -693,6 +694,11 @@ PAGE_TYPE_OPS(Balloon, balloon)
  */
 PAGE_TYPE_OPS(Kmemcg, kmemcg)
 
+/*
+ * Marks pages in use as page tables.
+ */
+PAGE_TYPE_OPS(Table, table)
+
 extern bool is_free_buddy_page(struct page *page);
 
 __PAGEFLAG(Isolated, isolated, PF_ANY);
diff --git a/include/uapi/linux/kernel-page-flags.h b/include/uapi/linux/kernel-page-flags.h
index fa139841ec18..21b9113c69da 100644
--- a/include/uapi/linux/kernel-page-flags.h
+++ b/include/uapi/linux/kernel-page-flags.h
@@ -35,6 +35,6 @@
 #define KPF_BALLOON		23
 #define KPF_ZERO_PAGE		24
 #define KPF_IDLE		25
-
+#define KPF_PGTABLE		26
 
 #endif /* _UAPILINUX_KERNEL_PAGE_FLAGS_H */
diff --git a/tools/vm/page-types.c b/tools/vm/page-types.c
index a8783f48f77f..cce853dca691 100644
--- a/tools/vm/page-types.c
+++ b/tools/vm/page-types.c
@@ -131,6 +131,7 @@ static const char * const page_flag_names[] = {
 	[KPF_KSM]		= "x:ksm",
 	[KPF_THP]		= "t:thp",
 	[KPF_BALLOON]		= "o:balloon",
+	[KPF_PGTABLE]		= "g:pgtable",
 	[KPF_ZERO_PAGE]		= "z:zero_page",
 	[KPF_IDLE]              = "i:idle_page",
 
-- 
2.17.0
