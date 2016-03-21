Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 82D0D6B007E
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 02:30:07 -0400 (EDT)
Received: by mail-pf0-f178.google.com with SMTP id x3so253243721pfb.1
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 23:30:07 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id xv6si16372109pab.1.2016.03.20.23.30.05
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 23:30:06 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 01/18] mm: use put_page to free page instead of putback_lru_page
Date: Mon, 21 Mar 2016 15:30:50 +0900
Message-Id: <1458541867-27380-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1458541867-27380-1-git-send-email-minchan@kernel.org>
References: <1458541867-27380-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Procedure of page migration is as follows:

First of all, it should isolate a page from LRU and try to
migrate the page. If it is successful, it releases the page
for freeing. Otherwise, it should put the page back to LRU
list.

For LRU pages, we have used putback_lru_page for both freeing
and putback to LRU list. It's okay because put_page is aware of
LRU list so if it releases last refcount of the page, it removes
the page from LRU list. However, It makes unnecessary operations
(e.g., lru_cache_add, pagevec and flags operations. It would be
not significant but no worth to do) and harder to support new
non-lru page migration because put_page isn't aware of non-lru
page's data structure.

To solve the problem, we can add new hook in put_page with
PageMovable flags check but it can increase overhead in
hot path and needs new locking scheme to stabilize the flag check
with put_page.

So, this patch cleans it up to divide two semantic(ie, put and putback).
If migration is successful, use put_page instead of putback_lru_page and
use putback_lru_page only on failure. That makes code more readable
and doesn't add overhead in put_page.

Comment from Vlastimil
"Yeah, and compaction (perhaps also other migration users) has to drain
the lru pvec... Getting rid of this stuff is worth even by itself."

Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/migrate.c | 50 +++++++++++++++++++++++++++++++-------------------
 1 file changed, 31 insertions(+), 19 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 6c822a7b27e0..b65c84267ce0 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -913,6 +913,14 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		put_anon_vma(anon_vma);
 	unlock_page(page);
 out:
+	/* If migration is scucessful, move newpage to right list */
+	if (rc == MIGRATEPAGE_SUCCESS) {
+		if (unlikely(__is_movable_balloon_page(newpage)))
+			put_page(newpage);
+		else
+			putback_lru_page(newpage);
+	}
+
 	return rc;
 }
 
@@ -946,6 +954,12 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 
 	if (page_count(page) == 1) {
 		/* page was freed from under us. So we are done. */
+		ClearPageActive(page);
+		ClearPageUnevictable(page);
+		if (put_new_page)
+			put_new_page(newpage, private);
+		else
+			put_page(newpage);
 		goto out;
 	}
 
@@ -958,10 +972,8 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 	}
 
 	rc = __unmap_and_move(page, newpage, force, mode);
-	if (rc == MIGRATEPAGE_SUCCESS) {
-		put_new_page = NULL;
+	if (rc == MIGRATEPAGE_SUCCESS)
 		set_page_owner_migrate_reason(newpage, reason);
-	}
 
 out:
 	if (rc != -EAGAIN) {
@@ -974,28 +986,28 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
-		/* Soft-offlined page shouldn't go through lru cache list */
+	}
+
+	/*
+	 * If migration is successful, drop the reference grabbed during
+	 * isolation. Otherwise, restore the page to LRU list unless we
+	 * want to retry.
+	 */
+	if (rc == MIGRATEPAGE_SUCCESS) {
+		put_page(page);
 		if (reason == MR_MEMORY_FAILURE) {
-			put_page(page);
 			if (!test_set_page_hwpoison(page))
 				num_poisoned_pages_inc();
-		} else
+		}
+	} else {
+		if (rc != -EAGAIN)
 			putback_lru_page(page);
+		if (put_new_page)
+			put_new_page(newpage, private);
+		else
+			put_page(newpage);
 	}
 
-	/*
-	 * If migration was not successful and there's a freeing callback, use
-	 * it.  Otherwise, putback_lru_page() will drop the reference grabbed
-	 * during isolation.
-	 */
-	if (put_new_page)
-		put_new_page(newpage, private);
-	else if (unlikely(__is_movable_balloon_page(newpage))) {
-		/* drop our reference, page already in the balloon */
-		put_page(newpage);
-	} else
-		putback_lru_page(newpage);
-
 	if (result) {
 		if (rc)
 			*result = rc;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
