Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2CFFA6B0780
	for <linux-mm@kvack.org>; Sat, 10 Nov 2018 03:51:03 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id y73-v6so2477344oie.13
        for <linux-mm@kvack.org>; Sat, 10 Nov 2018 00:51:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z21sor5761747otz.118.2018.11.10.00.51.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 10 Nov 2018 00:51:02 -0800 (PST)
From: john.hubbard@gmail.com
Subject: [PATCH v2 4/6] mm: introduce page->dma_pinned_flags, _count
Date: Sat, 10 Nov 2018 00:50:39 -0800
Message-Id: <20181110085041.10071-5-jhubbard@nvidia.com>
In-Reply-To: <20181110085041.10071-1-jhubbard@nvidia.com>
References: <20181110085041.10071-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Balbir Singh <bsingharora@gmail.com>

From: John Hubbard <jhubbard@nvidia.com>

Add two struct page fields that, combined, are unioned with
struct page->lru. There is no change in the size of
struct page. These new fields are for type safety and clarity.

Also add page flag accessors to test, set and clear the new
page->dma_pinned_flags field.

The page->dma_pinned_count field will be used in upcoming
patches.

Cc: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Christopher Lameter <cl@linux.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Balbir Singh <bsingharora@gmail.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/mm_types.h   | 22 ++++++++++----
 include/linux/page-flags.h | 61 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 77 insertions(+), 6 deletions(-)

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
index 50ce1bddaf56..3190b6b6a82f 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -437,6 +437,67 @@ static __always_inline int __PageMovable(struct page *page)
 				PAGE_MAPPING_MOVABLE;
 }
 
+/*
+ * Because page->dma_pinned_flags is unioned with page->lru, any page that
+ * uses these flags must NOT be on an LRU. That's partly enforced by
+ * ClearPageDmaPinned, which gives the page back to LRU.
+ *
+ * PageDmaPinned is checked without knowing whether it is a tail page or a
+ * PageDmaPinned page. For that reason, PageDmaPinned avoids PageTail (the 0th
+ * bit in the first union of struct page), and instead uses bit 1 (0x2),
+ * rather than bit 0.
+ *
+ * PageDmaPinned can only be used if no other systems are using the same bit
+ * across the first struct page union. In this regard, it is similar to
+ * PageTail, and in fact, because of PageTail's constraint that bit 0 be left
+ * alone, bit 1 is also left alone so far: other union elements (ignoring tail
+ * pages) put pointers there, and pointer alignment leaves the lower two bits
+ * available.
+ *
+ * So, constraints include:
+ *
+ *     -- Only use PageDmaPinned on non-tail pages.
+ *     -- Remove the page from any LRU list first.
+ */
+#define PAGE_DMA_PINNED		0x2UL
+#define PAGE_DMA_PINNED_WAS_LRU	0x4UL
+
+static __always_inline int PageDmaPinned(struct page *page)
+{
+	VM_BUG_ON(page != compound_head(page));
+	return test_bit(PAGE_DMA_PINNED, &page->dma_pinned_flags);
+}
+
+static __always_inline void SetPageDmaPinned(struct page *page)
+{
+	VM_BUG_ON(page != compound_head(page));
+	set_bit(PAGE_DMA_PINNED, &page->dma_pinned_flags);
+}
+
+static __always_inline void ClearPageDmaPinned(struct page *page)
+{
+	VM_BUG_ON(page != compound_head(page));
+	clear_bit(PAGE_DMA_PINNED, &page->dma_pinned_flags);
+}
+
+static __always_inline int PageDmaPinnedWasLru(struct page *page)
+{
+	VM_BUG_ON(page != compound_head(page));
+	return test_bit(PAGE_DMA_PINNED_WAS_LRU, &page->dma_pinned_flags);
+}
+
+static __always_inline void SetPageDmaPinnedWasLru(struct page *page)
+{
+	VM_BUG_ON(page != compound_head(page));
+	set_bit(PAGE_DMA_PINNED_WAS_LRU, &page->dma_pinned_flags);
+}
+
+static __always_inline void ClearPageDmaPinnedWasLru(struct page *page)
+{
+	VM_BUG_ON(page != compound_head(page));
+	clear_bit(PAGE_DMA_PINNED_WAS_LRU, &page->dma_pinned_flags);
+}
+
 #ifdef CONFIG_KSM
 /*
  * A KSM page is one of those write-protected "shared pages" or "merged pages"
-- 
2.19.1
