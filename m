Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7CF4D6B000C
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 02:00:35 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 14-v6so10555568pfk.22
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 23:00:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l12-v6sor141052pgm.60.2018.10.11.23.00.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Oct 2018 23:00:34 -0700 (PDT)
From: john.hubbard@gmail.com
Subject: [PATCH 4/6] mm: introduce page->dma_pinned_flags, _count
Date: Thu, 11 Oct 2018 23:00:12 -0700
Message-Id: <20181012060014.10242-5-jhubbard@nvidia.com>
In-Reply-To: <20181012060014.10242-1-jhubbard@nvidia.com>
References: <20181012060014.10242-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

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
 include/linux/mm_types.h   | 22 +++++++++++++-----
 include/linux/page-flags.h | 47 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 63 insertions(+), 6 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 5ed8f6292a53..017ab82e36ca 100644
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
index 74bee8cecf4c..81ed52c3caae 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -425,6 +425,53 @@ static __always_inline int __PageMovable(struct page *page)
 				PAGE_MAPPING_MOVABLE;
 }
 
+/*
+ * Because page->dma_pinned_flags is unioned with page->lru, any page that
+ * uses these flags must NOT be on an LRU. That's partly enforced by
+ * ClearPageDmaPinned, which gives the page back to LRU.
+ *
+ * PageDmaPinned also corresponds to PageTail (the 0th bit in the first union
+ * of struct page), and this flag is checked without knowing whether it is a
+ * tail page or a PageDmaPinned page. Therefore, start the flags at bit 1 (0x2),
+ * rather than bit 0.
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
2.19.1
