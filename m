Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id CBE756B0010
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 02:00:38 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id r72-v6so6575455pfj.3
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 23:00:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u6-v6sor128946plz.53.2018.10.11.23.00.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Oct 2018 23:00:37 -0700 (PDT)
From: john.hubbard@gmail.com
Subject: [PATCH 6/6] mm: track gup pages with page->dma_pinned_* fields
Date: Thu, 11 Oct 2018 23:00:14 -0700
Message-Id: <20181012060014.10242-7-jhubbard@nvidia.com>
In-Reply-To: <20181012060014.10242-1-jhubbard@nvidia.com>
References: <20181012060014.10242-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

From: John Hubbard <jhubbard@nvidia.com>

This patch sets and restores the new page->dma_pinned_flags and
page->dma_pinned_count fields, but does not actually use them for
anything yet.

In order to use these fields at all, the page must be removed from
any LRU list that it's on. The patch also adds some precautions that
prevent the page from getting moved back onto an LRU, once it is
in this state.

This is in preparation to fix some problems that came up when using
devices (NICs, GPUs, for example) that set up direct access to a chunk
of system (CPU) memory, so that they can DMA to/from that memory.

CC: Matthew Wilcox <willy@infradead.org>
CC: Jan Kara <jack@suse.cz>
CC: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/mm.h | 15 ++-----------
 mm/gup.c           | 56 ++++++++++++++++++++++++++++++++++++++++++++--
 mm/memcontrol.c    |  7 ++++++
 mm/swap.c          | 51 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 114 insertions(+), 15 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 76d18aada9f8..44878d21e27b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -944,21 +944,10 @@ static inline void put_page(struct page *page)
 }
 
 /*
- * put_user_page() - release a page that had previously been acquired via
- * a call to one of the get_user_pages*() functions.
- *
  * Pages that were pinned via get_user_pages*() must be released via
- * either put_user_page(), or one of the put_user_pages*() routines
- * below. This is so that eventually, pages that are pinned via
- * get_user_pages*() can be separately tracked and uniquely handled. In
- * particular, interactions with RDMA and filesystems need special
- * handling.
+ * one of these put_user_pages*() routines:
  */
-static inline void put_user_page(struct page *page)
-{
-	put_page(page);
-}
-
+void put_user_page(struct page *page);
 void put_user_pages_dirty(struct page **pages, unsigned long npages);
 void put_user_pages_dirty_lock(struct page **pages, unsigned long npages);
 void put_user_pages(struct page **pages, unsigned long npages);
diff --git a/mm/gup.c b/mm/gup.c
index 05ee7c18e59a..fddbc30cde89 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -20,6 +20,51 @@
 
 #include "internal.h"
 
+static int pin_page_for_dma(struct page *page)
+{
+	int ret = 0;
+	struct zone *zone;
+
+	page = compound_head(page);
+	zone = page_zone(page);
+
+	spin_lock(zone_gup_lock(zone));
+
+	if (PageDmaPinned(page)) {
+		/* Page was not on an LRU list, because it was DMA-pinned. */
+		VM_BUG_ON_PAGE(PageLRU(page), page);
+
+		atomic_inc(&page->dma_pinned_count);
+		goto unlock_out;
+	}
+
+	/*
+	 * Note that page->dma_pinned_flags is unioned with page->lru.
+	 * Therefore, the rules are: checking if any of the
+	 * PAGE_DMA_PINNED_FLAGS bits are set may be done while page->lru
+	 * is in use. However, setting those flags requires that
+	 * the page is both locked, and also, removed from the LRU.
+	 */
+	ret = isolate_lru_page(page);
+
+	if (ret == 0) {
+		/* Avoid problems later, when freeing the page: */
+		ClearPageActive(page);
+		ClearPageUnevictable(page);
+
+		/* counteract isolate_lru_page's effects: */
+		put_page(page);
+
+		atomic_set(&page->dma_pinned_count, 1);
+		SetPageDmaPinned(page);
+	}
+
+unlock_out:
+	spin_unlock(zone_gup_lock(zone));
+
+	return ret;
+}
+
 static struct page *no_page_table(struct vm_area_struct *vma,
 		unsigned int flags)
 {
@@ -659,7 +704,7 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned int gup_flags, struct page **pages,
 		struct vm_area_struct **vmas, int *nonblocking)
 {
-	long i = 0;
+	long i = 0, j;
 	int err = 0;
 	unsigned int page_mask;
 	struct vm_area_struct *vma = NULL;
@@ -764,6 +809,10 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 	} while (nr_pages);
 
 out:
+	if (pages)
+		for (j = 0; j < i; j++)
+			pin_page_for_dma(pages[j]);
+
 	return i ? i : err;
 }
 
@@ -1841,7 +1890,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			struct page **pages)
 {
 	unsigned long addr, len, end;
-	int nr = 0, ret = 0;
+	int nr = 0, ret = 0, i;
 
 	start &= PAGE_MASK;
 	addr = start;
@@ -1862,6 +1911,9 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 		ret = nr;
 	}
 
+	for (i = 0; i < nr; i++)
+		pin_page_for_dma(pages[i]);
+
 	if (nr < nr_pages) {
 		/* Try to get the remaining pages with get_user_pages */
 		start += nr << PAGE_SHIFT;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e79cb59552d9..af9719756081 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2335,6 +2335,11 @@ static void lock_page_lru(struct page *page, int *isolated)
 	if (PageLRU(page)) {
 		struct lruvec *lruvec;
 
+		/* LRU and PageDmaPinned are mutually exclusive: they use the
+		 * same fields in struct page, but for different purposes.
+		 */
+		VM_BUG_ON_PAGE(PageDmaPinned(page), page);
+
 		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
 		ClearPageLRU(page);
 		del_page_from_lru_list(page, lruvec, page_lru(page));
@@ -2352,6 +2357,8 @@ static void unlock_page_lru(struct page *page, int isolated)
 
 		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
 		VM_BUG_ON_PAGE(PageLRU(page), page);
+		VM_BUG_ON_PAGE(PageDmaPinned(page), page);
+
 		SetPageLRU(page);
 		add_page_to_lru_list(page, lruvec, page_lru(page));
 	}
diff --git a/mm/swap.c b/mm/swap.c
index efab3a6b6f91..6b2b1a958a67 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -134,6 +134,46 @@ void put_pages_list(struct list_head *pages)
 }
 EXPORT_SYMBOL(put_pages_list);
 
+/*
+ * put_user_page() - release a page that had previously been acquired via
+ * a call to one of the get_user_pages*() functions.
+ *
+ * Pages that were pinned via get_user_pages*() must be released via
+ * either put_user_page(), or one of the put_user_pages*() routines
+ * below. This is so that eventually, pages that are pinned via
+ * get_user_pages*() can be separately tracked and uniquely handled. In
+ * particular, interactions with RDMA and filesystems need special
+ * handling.
+ */
+void put_user_page(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+
+	page = compound_head(page);
+
+	VM_BUG_ON_PAGE(PageLRU(page), page);
+	VM_BUG_ON_PAGE(!PageDmaPinned(page), page);
+
+	if (atomic_dec_and_test(&page->dma_pinned_count)) {
+		spin_lock(zone_gup_lock(zone));
+
+		/* Re-check while holding the lock, because
+		 * pin_page_for_dma() or get_page() may have snuck in right
+		 * after the atomic_dec_and_test, and raised the count
+		 * above zero again. If so, just leave the flag set. And
+		 * because the atomic_dec_and_test above already got the
+		 * accounting correct, no other action is required.
+		 */
+		if (atomic_read(&page->dma_pinned_count) == 0)
+			ClearPageDmaPinned(page);
+
+		spin_unlock(zone_gup_lock(zone));
+	}
+
+	put_page(page);
+}
+EXPORT_SYMBOL(put_user_page);
+
 /*
  * put_user_pages_dirty() - for each page in the @pages array, make
  * that page (or its head page, if a compound page) dirty, if it was
@@ -907,6 +947,11 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 	VM_BUG_ON_PAGE(PageCompound(page_tail), page);
 	VM_BUG_ON_PAGE(PageLRU(page_tail), page);
+
+	/* LRU and PageDmaPinned are mutually exclusive: they use the
+	 * same fields in struct page, but for different purposes.
+	 */
+	VM_BUG_ON_PAGE(PageDmaPinned(page_tail), page);
 	VM_BUG_ON(NR_CPUS != 1 &&
 		  !spin_is_locked(&lruvec_pgdat(lruvec)->lru_lock));
 
@@ -946,6 +991,12 @@ static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
 
 	VM_BUG_ON_PAGE(PageLRU(page), page);
 
+	/* LRU and PageDmaPinned are mutually exclusive: they use the
+	 * same fields in struct page, but for different purposes.
+	 */
+	if (PageDmaPinned(page))
+		return;
+
 	SetPageLRU(page);
 	/*
 	 * Page becomes evictable in two ways:
-- 
2.19.1
