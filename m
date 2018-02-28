Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 27CBC6B0009
	for <linux-mm@kvack.org>; Wed, 28 Feb 2018 17:32:12 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id h61-v6so2165833pld.3
        for <linux-mm@kvack.org>; Wed, 28 Feb 2018 14:32:12 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j71si1555183pgd.404.2018.02.28.14.32.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 28 Feb 2018 14:32:09 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v3 4/4] mm: Mark pages in use for page tables
Date: Wed, 28 Feb 2018 14:31:57 -0800
Message-Id: <20180228223157.9281-5-willy@infradead.org>
In-Reply-To: <20180228223157.9281-1-willy@infradead.org>
References: <20180228223157.9281-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

Define a new PageTable bit in the page_type and use it to mark pages in
use as page tables.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/mm.h         | 2 ++
 include/linux/page-flags.h | 6 ++++++
 2 files changed, 8 insertions(+)

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
index 8142ab716e90..ac6bab90849c 100644
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
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
