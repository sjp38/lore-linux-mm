Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 67C4F6B06A0
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 01:47:49 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id s22so627954pgv.8
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 22:47:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 30sor6958120pgz.10.2018.11.08.22.47.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 22:47:47 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [RFC][PATCH v1 08/11] mm: soft-offline: isolate error pages from buddy freelist
Date: Fri,  9 Nov 2018 15:47:12 +0900
Message-Id: <1541746035-13408-9-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, xishi.qiuxishi@alibaba-inc.com, Laurent Dufour <ldufour@linux.vnet.ibm.com>

Soft-offline shares PG_hwpoison with hard-offline to keep track
of memory error, but recently we found that the approach can be
undesirable for soft-offline because it never expects to stop
applications unlike hard-offline.

So this patch suggests that memory error handler (not only sets
PG_hwpoison, but) isolates error pages from buddy allocator in
its context.

In previous works [1], we allow soft-offline handler to set
PG_hwpoison only after successful page migration and page freeing.
This patch, along with that, makes the isolation always done via
set_hwpoison_free_buddy_page() with zone->lock, so the behavior
should be less racy and more predictable.

Note that only considering for isolation, we don't have to set
PG_hwpoison, but my analysis shows that to make memory hotremove
properly work, we still need some flag to clearly separate memory
error from any other type of pages. So this patch doesn't change this.

[1]:
  commit 6bc9b56433b7 ("mm: fix race on soft-offlining free huge pages")
  commit d4ae9916ea29 ("mm: soft-offline: close the race against page allocation")

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c |  8 +++---
 mm/page_alloc.c     | 71 ++++++++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 70 insertions(+), 9 deletions(-)

diff --git v4.19-mmotm-2018-10-30-16-08/mm/memory-failure.c v4.19-mmotm-2018-10-30-16-08_patched/mm/memory-failure.c
index 869ff8f..ecafd4a 100644
--- v4.19-mmotm-2018-10-30-16-08/mm/memory-failure.c
+++ v4.19-mmotm-2018-10-30-16-08_patched/mm/memory-failure.c
@@ -1762,9 +1762,11 @@ static int __soft_offline_page(struct page *page)
 	if (ret == 1) {
 		put_hwpoison_page(page);
 		pr_info("soft_offline: %#lx: invalidated\n", pfn);
-		SetPageHWPoison(page);
-		num_poisoned_pages_inc();
-		return 0;
+		if (set_hwpoison_free_buddy_page(page)) {
+			num_poisoned_pages_inc();
+			return 0;
+		} else
+			return -EBUSY;
 	}
 
 	/*
diff --git v4.19-mmotm-2018-10-30-16-08/mm/page_alloc.c v4.19-mmotm-2018-10-30-16-08_patched/mm/page_alloc.c
index ae31839..970d6ff 100644
--- v4.19-mmotm-2018-10-30-16-08/mm/page_alloc.c
+++ v4.19-mmotm-2018-10-30-16-08_patched/mm/page_alloc.c
@@ -8183,10 +8183,55 @@ bool is_free_buddy_page(struct page *page)
 }
 
 #ifdef CONFIG_MEMORY_FAILURE
+
+/*
+ * Pick out a free page from buddy allocator. Unlike expand(), this
+ * function can choose the target page by @target which is not limited
+ * to the first page of some free block.
+ *
+ * This function changes zone state, so callers need to hold zone->lock.
+ */
+static inline void pickout_buddy_page(struct zone *zone, struct page *page,
+			struct page *target, int torder, int low, int high,
+			struct free_area *area, int migratetype)
+{
+	unsigned long size = 1 << high;
+	struct page *current_buddy, *next_page;
+
+	while (high > low) {
+		area--;
+		high--;
+		size >>= 1;
+
+		if (target >= &page[size]) { /* target is in higher buddy */
+			next_page = page + size;
+			current_buddy = page;
+		} else { /* target is in lower buddy */
+			next_page = page;
+			current_buddy = page + size;
+		}
+		VM_BUG_ON_PAGE(bad_range(zone, current_buddy), current_buddy);
+
+		if (set_page_guard(zone, &page[size], high, migratetype))
+			continue;
+
+		list_add(&current_buddy->lru, &area->free_list[migratetype]);
+		area->nr_free++;
+		set_page_order(current_buddy, high);
+		page = next_page;
+	}
+}
+
 /*
- * Set PG_hwpoison flag if a given page is confirmed to be a free page.  This
- * test is performed under the zone lock to prevent a race against page
- * allocation.
+ * Isolate hwpoisoned free page which actully does the following
+ *   - confirm that a given page is a free page under zone->lock,
+ *   - set PG_hwpoison flag,
+ *   - remove the page from buddy allocator, subdividing buddy page
+ *     of each order.
+ *
+ * Just setting PG_hwpoison flag is not safe enough for complete isolation
+ * because rapidly-changing memory allocator code is always with the
+ * risk of mishandling the flag and potential race.
  */
 bool set_hwpoison_free_buddy_page(struct page *page)
 {
@@ -8199,10 +8244,24 @@ bool set_hwpoison_free_buddy_page(struct page *page)
 	spin_lock_irqsave(&zone->lock, flags);
 	for (order = 0; order < MAX_ORDER; order++) {
 		struct page *page_head = page - (pfn & ((1 << order) - 1));
+		unsigned int forder = page_order(page_head);
+		struct free_area *area = &(zone->free_area[forder]);
 
-		if (PageBuddy(page_head) && page_order(page_head) >= order) {
-			if (!TestSetPageHWPoison(page))
-				hwpoisoned = true;
+		if (PageBuddy(page_head) && forder >= order) {
+			int migtype = get_pfnblock_migratetype(page_head,
+							page_to_pfn(page_head));
+			/*
+			 * TestSetPageHWPoison() will be used later when
+			 * reworking hard-offline part is finished.
+			 */
+			SetPageHWPoison(page);
+
+			list_del(&page_head->lru);
+			rmv_page_order(page_head);
+			area->nr_free--;
+			pickout_buddy_page(zone, page_head, page, 0, 0, forder,
+					area, migtype);
+			hwpoisoned = true;
 			break;
 		}
 	}
-- 
2.7.0
