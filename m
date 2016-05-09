Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 72CD96B0005
	for <linux-mm@kvack.org>; Sun,  8 May 2016 22:20:23 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b203so354004886pfb.1
        for <linux-mm@kvack.org>; Sun, 08 May 2016 19:20:23 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id fj9si35529426pab.100.2016.05.08.19.20.21
        for <linux-mm@kvack.org>;
        Sun, 08 May 2016 19:20:21 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v5 01/12] mm: use put_page to free page instead of putback_lru_page
Date: Mon,  9 May 2016 11:20:22 +0900
Message-Id: <1462760433-32357-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1462760433-32357-1-git-send-email-minchan@kernel.org>
References: <1462760433-32357-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>

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

Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/migrate.c | 64 +++++++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 40 insertions(+), 24 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 53ab6398e7a2..f2932498ded2 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -913,6 +913,19 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		put_anon_vma(anon_vma);
 	unlock_page(page);
 out:
+	/*
+	 * If migration is successful, decrease refcount of the newpage
+	 * which will not free the page because new page owner increased
+	 * refcounter. As well, if it is LRU page, add the page to LRU
+	 * list in here.
+	 */
+	if (rc == MIGRATEPAGE_SUCCESS) {
+		if (unlikely(__is_movable_balloon_page(newpage)))
+			put_page(newpage);
+		else
+			putback_lru_page(newpage);
+	}
+
 	return rc;
 }
 
@@ -946,6 +959,12 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 
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
 
@@ -958,10 +977,8 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 	}
 
 	rc = __unmap_and_move(page, newpage, force, mode);
-	if (rc == MIGRATEPAGE_SUCCESS) {
-		put_new_page = NULL;
+	if (rc == MIGRATEPAGE_SUCCESS)
 		set_page_owner_migrate_reason(newpage, reason);
-	}
 
 out:
 	if (rc != -EAGAIN) {
@@ -974,34 +991,33 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
-		/* Soft-offlined page shouldn't go through lru cache list */
-		if (reason == MR_MEMORY_FAILURE && rc == MIGRATEPAGE_SUCCESS) {
+	}
+
+	/*
+	 * If migration is successful, releases reference grabbed during
+	 * isolation. Otherwise, restore the page to right list unless
+	 * we want to retry.
+	 */
+	if (rc == MIGRATEPAGE_SUCCESS) {
+		put_page(page);
+		if (reason == MR_MEMORY_FAILURE) {
 			/*
-			 * With this release, we free successfully migrated
-			 * page and set PG_HWPoison on just freed page
-			 * intentionally. Although it's rather weird, it's how
-			 * HWPoison flag works at the moment.
+			 * Set PG_HWPoison on just freed page
+			 * intentionally. Although it's rather weird,
+			 * it's how HWPoison flag works at the moment.
 			 */
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
