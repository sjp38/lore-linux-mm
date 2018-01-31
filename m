Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id D0AA96B000D
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 18:04:32 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id e10so4180336uam.1
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 15:04:32 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id y18si7205967uay.93.2018.01.31.15.04.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 15:04:31 -0800 (PST)
From: daniel.m.jordan@oracle.com
Subject: [RFC PATCH v1 05/13] mm: add batching logic to add/delete/move API's
Date: Wed, 31 Jan 2018 18:04:05 -0500
Message-Id: <20180131230413.27653-6-daniel.m.jordan@oracle.com>
In-Reply-To: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
References: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, Dave.Dice@oracle.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, ldufour@linux.vnet.ibm.com, mgorman@suse.de, mhocko@kernel.org, pasha.tatashin@oracle.com, steven.sistare@oracle.com, yossi.lev@oracle.com

Change the add/delete/move LRU API's in mm_inline.h to account for LRU
batching.  Now when a page is added to the front of the LRU, it's
assigned a batch number that's used to decide which spinlock in the
lru_batch_lock array to take when removing that page from the LRU.  Each
newly-added page is also unconditionally made a sentinel page.

As more pages are added to the front of an LRU, the same batch number is
used for each until a threshold is reached, at which point a batch is
ready and the sentinel bits are unset in all but the first and last pages
of the batch.  This allows those inner pages to be removed with a batch
lock rather than the heavier lru_lock.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 include/linux/mm_inline.h | 119 ++++++++++++++++++++++++++++++++++++++++++++--
 include/linux/mmzone.h    |   3 ++
 mm/swap.c                 |   2 +-
 mm/vmscan.c               |   4 +-
 4 files changed, 122 insertions(+), 6 deletions(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index d7fc46ebc33b..ec8b966a1c76 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -3,6 +3,7 @@
 #define LINUX_MM_INLINE_H
 
 #include <linux/huge_mm.h>
+#include <linux/random.h>
 #include <linux/swap.h>
 
 /**
@@ -44,27 +45,139 @@ static __always_inline void update_lru_size(struct lruvec *lruvec,
 #endif
 }
 
+static __always_inline void __add_page_to_lru_list(struct page *page,
+				struct lruvec *lruvec, enum lru_list lru)
+{
+	int tag;
+	struct page *cur, *next, *second_page;
+	struct lru_list_head *head = &lruvec->lists[lru];
+
+	list_add(&page->lru, lru_head(head));
+	/* Set sentinel unconditionally until batch is full. */
+	page->lru_sentinel = true;
+
+	second_page = container_of(page->lru.next, struct page, lru);
+	VM_BUG_ON_PAGE(!second_page->lru_sentinel, second_page);
+
+	page->lru_batch = head->first_batch_tag;
+	++head->first_batch_npages;
+
+	if (head->first_batch_npages < LRU_BATCH_MAX)
+		return;
+
+	tag = head->first_batch_tag;
+	if (likely(second_page->lru_batch == tag)) {
+		/* Unset sentinel bit in all non-sentinel nodes. */
+		cur = second_page;
+		list_for_each_entry_from(cur, lru_head(head), lru) {
+			next = list_next_entry(cur, lru);
+			if (next->lru_batch != tag)
+				break;
+			cur->lru_sentinel = false;
+		}
+	}
+
+	tag = prandom_u32_max(NUM_LRU_BATCH_LOCKS);
+	if (unlikely(tag == head->first_batch_tag))
+		tag = (tag + 1) % NUM_LRU_BATCH_LOCKS;
+	head->first_batch_tag = tag;
+	head->first_batch_npages = 0;
+}
+
 static __always_inline void add_page_to_lru_list(struct page *page,
 				struct lruvec *lruvec, enum lru_list lru)
 {
 	update_lru_size(lruvec, lru, page_zonenum(page), hpage_nr_pages(page));
-	list_add(&page->lru, lru_head(&lruvec->lists[lru]));
+	__add_page_to_lru_list(page, lruvec, lru);
+}
+
+static __always_inline void __add_page_to_lru_list_tail(struct page *page,
+				struct lruvec *lruvec, enum lru_list lru)
+{
+	int tag;
+	struct page *cur, *prev, *second_page;
+	struct lru_list_head *head = &lruvec->lists[lru];
+
+	list_add_tail(&page->lru, lru_head(head));
+	/* Set sentinel unconditionally until batch is full. */
+	page->lru_sentinel = true;
+
+	second_page = container_of(page->lru.prev, struct page, lru);
+	VM_BUG_ON_PAGE(!second_page->lru_sentinel, second_page);
+
+	page->lru_batch = head->last_batch_tag;
+	++head->last_batch_npages;
+
+	if (head->last_batch_npages < LRU_BATCH_MAX)
+		return;
+
+	tag = head->last_batch_tag;
+	if (likely(second_page->lru_batch == tag)) {
+		/* Unset sentinel bit in all non-sentinel nodes. */
+		cur = second_page;
+		list_for_each_entry_from_reverse(cur, lru_head(head), lru) {
+			prev = list_prev_entry(cur, lru);
+			if (prev->lru_batch != tag)
+				break;
+			cur->lru_sentinel = false;
+		}
+	}
+
+	tag = prandom_u32_max(NUM_LRU_BATCH_LOCKS);
+	if (unlikely(tag == head->last_batch_tag))
+		tag = (tag + 1) % NUM_LRU_BATCH_LOCKS;
+	head->last_batch_tag = tag;
+	head->last_batch_npages = 0;
 }
 
 static __always_inline void add_page_to_lru_list_tail(struct page *page,
 				struct lruvec *lruvec, enum lru_list lru)
 {
+
 	update_lru_size(lruvec, lru, page_zonenum(page), hpage_nr_pages(page));
-	list_add_tail(&page->lru, lru_head(&lruvec->lists[lru]));
+	__add_page_to_lru_list_tail(page, lruvec, lru);
 }
 
-static __always_inline void del_page_from_lru_list(struct page *page,
+static __always_inline void __del_page_from_lru_list(struct page *page,
 				struct lruvec *lruvec, enum lru_list lru)
 {
+	struct page *left, *right;
+
+	left  = container_of(page->lru.prev, struct page, lru);
+	right = container_of(page->lru.next, struct page, lru);
+
+	if (page->lru_sentinel) {
+		VM_BUG_ON(!left->lru_sentinel && !right->lru_sentinel);
+		left->lru_sentinel = true;
+		right->lru_sentinel = true;
+	}
+
 	list_del(&page->lru);
+}
+
+static __always_inline void del_page_from_lru_list(struct page *page,
+				struct lruvec *lruvec, enum lru_list lru)
+{
+	__del_page_from_lru_list(page, lruvec, lru);
 	update_lru_size(lruvec, lru, page_zonenum(page), -hpage_nr_pages(page));
 }
 
+static __always_inline void move_page_to_lru_list(struct page *page,
+						  struct lruvec *lruvec,
+						  enum lru_list lru)
+{
+	__del_page_from_lru_list(page, lruvec, lru);
+	__add_page_to_lru_list(page, lruvec, lru);
+}
+
+static __always_inline void move_page_to_lru_list_tail(struct page *page,
+						       struct lruvec *lruvec,
+						       enum lru_list lru)
+{
+	__del_page_from_lru_list(page, lruvec, lru);
+	__add_page_to_lru_list_tail(page, lruvec, lru);
+}
+
 /**
  * page_lru_base_type - which LRU list type should a page be on?
  * @page: the page to test
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index feca75b8f492..492f86cdb346 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -19,6 +19,7 @@
 #include <linux/page-flags-layout.h>
 #include <linux/atomic.h>
 #include <linux/mm_types.h>
+#include <linux/pagevec.h>
 #include <asm/page.h>
 
 /* Free memory management - zoned buddy allocator.  */
@@ -260,6 +261,8 @@ struct lruvec {
 #define LRU_ALL_ANON (BIT(LRU_INACTIVE_ANON) | BIT(LRU_ACTIVE_ANON))
 #define LRU_ALL	     ((1 << NR_LRU_LISTS) - 1)
 
+#define LRU_BATCH_MAX PAGEVEC_SIZE
+
 #define NUM_LRU_BATCH_LOCKS 32
 struct lru_batch_lock {
 	spinlock_t lock;
diff --git a/mm/swap.c b/mm/swap.c
index 286636bb6a4f..67eb89fc9435 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -561,7 +561,7 @@ static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
 		 * The page's writeback ends up during pagevec
 		 * We moves tha page into tail of inactive.
 		 */
-		list_move_tail(&page->lru, lru_head(&lruvec->lists[lru]));
+		move_page_to_lru_list_tail(page, lruvec, lru);
 		__count_vm_event(PGROTATED);
 	}
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index aa629c4720dd..b4c32a65a40f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1553,7 +1553,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 		case -EBUSY:
 			/* else it is being freed elsewhere */
-			list_move(&page->lru, src);
+			move_page_to_lru_list(page, lruvec, lru);
 			continue;
 
 		default:
@@ -1943,7 +1943,7 @@ static unsigned move_active_pages_to_lru(struct lruvec *lruvec,
 
 		nr_pages = hpage_nr_pages(page);
 		update_lru_size(lruvec, lru, page_zonenum(page), nr_pages);
-		list_move(&page->lru, lru_head(&lruvec->lists[lru]));
+		move_page_to_lru_list(page, lruvec, lru);
 
 		if (put_page_testzero(page)) {
 			__ClearPageLRU(page);
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
