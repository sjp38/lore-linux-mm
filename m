Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id D5A7D6B0038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 09:38:59 -0500 (EST)
Received: by pfnn128 with SMTP id n128so9575647pfn.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 06:38:59 -0800 (PST)
Received: from m50-134.163.com (m50-134.163.com. [123.125.50.134])
        by mx.google.com with ESMTP id vq10si12401967pab.74.2015.12.03.06.38.58
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 06:38:59 -0800 (PST)
From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH] mm/swapfile.c: use list_{next,first}_entry
Date: Thu,  3 Dec 2015 22:38:31 +0800
Message-Id: <dd2963d9bd998add2cf78281038bc0c81b2a73e1.1449153346.git.geliangtang@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jerome Marchand <jmarchan@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>
Cc: Geliang Tang <geliangtang@163.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

To make the intention clearer, use list_{next,first}_entry instead
of list_entry.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 mm/swapfile.c | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 7073fae..7c714c6 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -165,8 +165,6 @@ static void discard_swap_cluster(struct swap_info_struct *si,
 	int found_extent = 0;
 
 	while (nr_pages) {
-		struct list_head *lh;
-
 		if (se->start_page <= start_page &&
 		    start_page < se->start_page + se->nr_pages) {
 			pgoff_t offset = start_page - se->start_page;
@@ -188,8 +186,7 @@ static void discard_swap_cluster(struct swap_info_struct *si,
 				break;
 		}
 
-		lh = se->list.next;
-		se = list_entry(lh, struct swap_extent, list);
+		se = list_next_entry(se, list);
 	}
 }
 
@@ -903,7 +900,7 @@ int swp_swapcount(swp_entry_t entry)
 	VM_BUG_ON(page_private(page) != SWP_CONTINUED);
 
 	do {
-		page = list_entry(page->lru.next, struct page, lru);
+		page = list_next_entry(page, lru);
 		map = kmap_atomic(page);
 		tmp_count = map[offset];
 		kunmap_atomic(map);
@@ -1637,14 +1634,11 @@ static sector_t map_swap_entry(swp_entry_t entry, struct block_device **bdev)
 	se = start_se;
 
 	for ( ; ; ) {
-		struct list_head *lh;
-
 		if (se->start_page <= offset &&
 				offset < (se->start_page + se->nr_pages)) {
 			return se->start_block + (offset - se->start_page);
 		}
-		lh = se->list.next;
-		se = list_entry(lh, struct swap_extent, list);
+		se = list_next_entry(se, list);
 		sis->curr_swap_extent = se;
 		BUG_ON(se == start_se);		/* It *must* be present */
 	}
@@ -1668,7 +1662,7 @@ static void destroy_swap_extents(struct swap_info_struct *sis)
 	while (!list_empty(&sis->first_swap_extent.list)) {
 		struct swap_extent *se;
 
-		se = list_entry(sis->first_swap_extent.list.next,
+		se = list_first_entry(&sis->first_swap_extent.list,
 				struct swap_extent, list);
 		list_del(&se->list);
 		kfree(se);
-- 
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
