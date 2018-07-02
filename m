Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id CD7496B0006
	for <linux-mm@kvack.org>; Sun,  1 Jul 2018 20:57:39 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id a1-v6so10561730oti.8
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 17:57:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j143-v6sor3882475oib.260.2018.07.01.17.57.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 01 Jul 2018 17:57:38 -0700 (PDT)
From: john.hubbard@gmail.com
Subject: [PATCH v2 2/6] mm: introduce page->dma_pinned_flags, _count
Date: Sun,  1 Jul 2018 17:56:50 -0700
Message-Id: <20180702005654.20369-3-jhubbard@nvidia.com>
In-Reply-To: <20180702005654.20369-1-jhubbard@nvidia.com>
References: <20180702005654.20369-1-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

From: John Hubbard <jhubbard@nvidia.com>

Add two struct page fields that, combined, are unioned with
struct page->lru. There is no change in the size of
struct page. These new fields are for type safety and clarity.

Also add page flag accessors to test, set and clear the new
page->dma_pinned_flags field.

The page->dma_pinned_count field will be used in upcoming
patches

Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/mm_types.h   | 22 ++++++++++++-----
 include/linux/page-flags.h | 50 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 66 insertions(+), 6 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 99ce070e7dcb..0ecd29dcd642 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -78,12 +78,22 @@ struct page {
 	 */
 	union {
 		struct {	/* Page cache and anonymous pages */
-			/**
-			 * @lru: Pageout list, eg. active_list protected by
-			 * zone_lru_lock.  Sometimes used as a generic list
-			 * by the page owner.
-			 */
-			struct list_head lru;
+			union {
+				/**
+				 * @lru: Pageout list, eg. active_list protected
+				 * by zone_lru_lock.  Sometimes used as a
+				 * generic list by the page owner.
+				 */
+				struct list_head lru;
+				/* Used by get_user_pages*(). Pages may not be
+				 * on an LRU while these dma_pinned_* fields
+				 * are in use.
+				 */
+				struct {
+					unsigned long dma_pinned_flags;
+					atomic_t      dma_pinned_count;
+				};
+			};
 			/* See page-flags.h for PAGE_MAPPING_FLAGS */
 			struct address_space *mapping;
 			pgoff_t index;		/* Our offset within mapping. */
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 901943e4754b..b694a1a3bdf3 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -420,6 +420,56 @@ static __always_inline int __PageMovable(struct page *page)
 				PAGE_MAPPING_MOVABLE;
 }
 
+/*
+ * page->dma_pinned_flags is protected by the zone_gup_lock, plus the
+ * page->dma_pinned_count field as well.
+ *
+ * Because page->dma_pinned_flags is unioned with page->lru, any page that
+ * uses these flags must NOT be on an LRU. That's partly enforced by
+ * ClearPageDmaPinned, which gives the page back to LRU.
+ *
+ * Because PageDmaPinned also corresponds to PageTail (the lowest bit in
+ * the first union of struct page), and this flag is checked without knowing
+ * whether it is a tail page or a PageDmaPinned page, start the flags at
+ * bit 1 (0x2), rather than bit 0.
+ */
+#define PAGE_DMA_PINNED		0x2
+#define PAGE_DMA_PINNED_FLAGS	(PAGE_DMA_PINNED)
+
+/*
+ * Because these flags are read outside of a lock, ensure visibility between
+ * different threads, by using READ|WRITE_ONCE.
+ */
+static __always_inline int PageDmaPinnedFlags(struct page *page)
+{
+	VM_BUG_ON(page != compound_head(page));
+	return (READ_ONCE(page->dma_pinned_flags) & PAGE_DMA_PINNED_FLAGS) != 0;
+}
+
+static __always_inline int PageDmaPinned(struct page *page)
+{
+	VM_BUG_ON(page != compound_head(page));
+	return (READ_ONCE(page->dma_pinned_flags) & PAGE_DMA_PINNED) != 0;
+}
+
+static __always_inline void SetPageDmaPinned(struct page *page)
+{
+	VM_BUG_ON(page != compound_head(page));
+	WRITE_ONCE(page->dma_pinned_flags, PAGE_DMA_PINNED);
+}
+
+static __always_inline void ClearPageDmaPinned(struct page *page)
+{
+	VM_BUG_ON(page != compound_head(page));
+	VM_BUG_ON_PAGE(!PageDmaPinnedFlags(page), page);
+
+	/* This does a WRITE_ONCE to the lru.next, which is also the
+	 * page->dma_pinned_flags field. So in addition to restoring page->lru,
+	 * this provides visibility to other threads.
+	 */
+	INIT_LIST_HEAD(&page->lru);
+}
+
 #ifdef CONFIG_KSM
 /*
  * A KSM page is one of those write-protected "shared pages" or "merged pages"
-- 
2.18.0
