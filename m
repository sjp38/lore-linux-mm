Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 975AF6B445A
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 18:22:02 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id p3so2415831plk.9
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 15:22:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y73sor2781442pfd.54.2018.11.26.15.22.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 15:22:01 -0800 (PST)
Date: Mon, 26 Nov 2018 15:21:58 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 03/10] mm/huge_memory: fix lockdep complaint on 32-bit
 i_size_read()
In-Reply-To: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1811261520070.2275@eggly.anvils>
References: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org

Huge tmpfs testing, on 32-bit kernel with lockdep enabled, showed that
__split_huge_page() was using i_size_read() while holding the irq-safe
lru_lock and page tree lock, but the 32-bit i_size_read() uses an
irq-unsafe seqlock which should not be nested inside them.

Instead, read the i_size earlier in split_huge_page_to_list(), and pass
the end offset down to __split_huge_page(): all while holding head page
lock, which is enough to prevent truncation of that extent before the
page tree lock has been taken.

Fixes: baa355fd33142 ("thp: file pages support for split_huge_page()")
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: stable@vger.kernel.org # 4.8+
---
 mm/huge_memory.c | 19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index cef2c256e7c4..622cced74fd9 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2439,12 +2439,11 @@ static void __split_huge_page_tail(struct page *head, int tail,
 }
 
 static void __split_huge_page(struct page *page, struct list_head *list,
-		unsigned long flags)
+		pgoff_t end, unsigned long flags)
 {
 	struct page *head = compound_head(page);
 	struct zone *zone = page_zone(head);
 	struct lruvec *lruvec;
-	pgoff_t end = -1;
 	int i;
 
 	lruvec = mem_cgroup_page_lruvec(head, zone->zone_pgdat);
@@ -2452,9 +2451,6 @@ static void __split_huge_page(struct page *page, struct list_head *list,
 	/* complete memcg works before add pages to LRU */
 	mem_cgroup_split_huge_fixup(head);
 
-	if (!PageAnon(page))
-		end = DIV_ROUND_UP(i_size_read(head->mapping->host), PAGE_SIZE);
-
 	for (i = HPAGE_PMD_NR - 1; i >= 1; i--) {
 		__split_huge_page_tail(head, i, lruvec, list);
 		/* Some pages can be beyond i_size: drop them from page cache */
@@ -2626,6 +2622,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	int count, mapcount, extra_pins, ret;
 	bool mlocked;
 	unsigned long flags;
+	pgoff_t end;
 
 	VM_BUG_ON_PAGE(is_huge_zero_page(page), page);
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
@@ -2648,6 +2645,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 			ret = -EBUSY;
 			goto out;
 		}
+		end = -1;
 		mapping = NULL;
 		anon_vma_lock_write(anon_vma);
 	} else {
@@ -2661,6 +2659,15 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 
 		anon_vma = NULL;
 		i_mmap_lock_read(mapping);
+
+		/*
+		 *__split_huge_page() may need to trim off pages beyond EOF:
+		 * but on 32-bit, i_size_read() takes an irq-unsafe seqlock,
+		 * which cannot be nested inside the page tree lock. So note
+		 * end now: i_size itself may be changed at any moment, but
+		 * head page lock is good enough to serialize the trimming.
+		 */
+		end = DIV_ROUND_UP(i_size_read(mapping->host), PAGE_SIZE);
 	}
 
 	/*
@@ -2707,7 +2714,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 		if (mapping)
 			__dec_node_page_state(page, NR_SHMEM_THPS);
 		spin_unlock(&pgdata->split_queue_lock);
-		__split_huge_page(page, list, flags);
+		__split_huge_page(page, list, end, flags);
 		if (PageSwapCache(head)) {
 			swp_entry_t entry = { .val = page_private(head) };
 
-- 
2.20.0.rc0.387.gc7a69e6b6c-goog
