Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7BADE6B0078
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 08:00:00 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id lj1so7640233pab.24
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 05:00:00 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id hh5si4219864pbc.151.2014.10.14.04.59.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 14 Oct 2014 04:59:57 -0700 (PDT)
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NDF008Y2NZT2110@mailout4.samsung.com> for linux-mm@kvack.org;
 Tue, 14 Oct 2014 20:59:53 +0900 (KST)
From: Heesub Shin <heesub.shin@samsung.com>
Subject: [RFC PATCH 6/9] mm/zbud: remove list_head for buddied list from
 zbud_header
Date: Tue, 14 Oct 2014 20:59:25 +0900
Message-id: <1413287968-13940-7-git-send-email-heesub.shin@samsung.com>
In-reply-to: <1413287968-13940-1-git-send-email-heesub.shin@samsung.com>
References: <1413287968-13940-1-git-send-email-heesub.shin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjennings@variantweb.net>
Cc: Nitin Gupta <ngupta@vflare.org>, Dan Streetman <ddstreet@ieee.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sunae Seo <sunae.seo@samsung.com>, Heesub Shin <heesub.shin@samsung.com>

zbud allocator links the _unbuddied_ zbud pages into a list in the pool.
When it tries to allocate some spaces, the list is first searched for
the best fit possible. Thus, current implementation has a list_head in
zbud_header structure to construct the list.

This patch simulates a list using the second double word of struct page,
instead of zbud_header. Then, we can eliminate the list_head in
zbud_header. Using _index and _mapcount fields (also including _count on
64-bits machines) in the page struct for list management looks a bit
odd, but no better idea now considering that page->lru is already in
use.

Signed-off-by: Heesub Shin <heesub.shin@samsung.com>
---
 mm/zbud.c | 36 +++++++++++++++++++-----------------
 1 file changed, 19 insertions(+), 17 deletions(-)

diff --git a/mm/zbud.c b/mm/zbud.c
index 383bab0..8a6dd6b 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -99,10 +99,8 @@ struct zbud_pool {
 /*
  * struct zbud_header - zbud page metadata occupying the first chunk of each
  *			zbud page.
- * @buddy:	links the zbud page into the unbuddied lists in the pool
  */
 struct zbud_header {
-	struct list_head buddy;
 	bool under_reclaim;
 };
 
@@ -223,21 +221,24 @@ static size_t get_num_chunks(struct page *page, enum buddy bud)
 	for ((_iter) = (_begin); (_iter) < NCHUNKS; (_iter)++)
 
 /* Initializes the zbud header of a newly allocated zbud page */
-static struct zbud_header *init_zbud_page(struct page *page)
+static void init_zbud_page(struct page *page)
 {
 	struct zbud_header *zhdr = page_address(page);
 	set_num_chunks(page, FIRST, 0);
 	set_num_chunks(page, LAST, 0);
-	INIT_LIST_HEAD(&zhdr->buddy);
+	INIT_LIST_HEAD((struct list_head *) &page->index);
 	INIT_LIST_HEAD(&page->lru);
 	zhdr->under_reclaim = 0;
-	return zhdr;
 }
 
 /* Resets the struct page fields and frees the page */
 static void free_zbud_page(struct zbud_header *zhdr)
 {
-	__free_page(virt_to_page(zhdr));
+	struct page *page = virt_to_page(zhdr);
+
+	init_page_count(page);
+	page_mapcount_reset(page);
+	__free_page(page);
 }
 
 static int is_last_chunk(unsigned long handle)
@@ -341,7 +342,6 @@ int zbud_alloc(struct zbud_pool *pool, size_t size, gfp_t gfp,
 			unsigned long *handle)
 {
 	int chunks, i, freechunks;
-	struct zbud_header *zhdr = NULL;
 	enum buddy bud;
 	struct page *page;
 
@@ -355,10 +355,9 @@ int zbud_alloc(struct zbud_pool *pool, size_t size, gfp_t gfp,
 	/* First, try to find an unbuddied zbud page. */
 	for_each_unbuddied_list(i, chunks) {
 		if (!list_empty(&pool->unbuddied[i])) {
-			zhdr = list_first_entry(&pool->unbuddied[i],
-					struct zbud_header, buddy);
-			page = virt_to_page(zhdr);
-			list_del(&zhdr->buddy);
+			page = list_entry((unsigned long *)
+				pool->unbuddied[i].next, struct page, index);
+			list_del((struct list_head *) &page->index);
 			goto found;
 		}
 	}
@@ -370,7 +369,7 @@ int zbud_alloc(struct zbud_pool *pool, size_t size, gfp_t gfp,
 		return -ENOMEM;
 	spin_lock(&pool->lock);
 	pool->pages_nr++;
-	zhdr = init_zbud_page(page);
+	init_zbud_page(page);
 
 found:
 	if (get_num_chunks(page, FIRST) == 0)
@@ -384,7 +383,8 @@ found:
 		get_num_chunks(page, LAST) == 0) {
 		/* Add to unbuddied list */
 		freechunks = num_free_chunks(page);
-		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
+		list_add((struct list_head *) &page->index,
+				&pool->unbuddied[freechunks]);
 	}
 
 	/* Add/move zbud page to beginning of LRU */
@@ -433,14 +433,15 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
 	freechunks = num_free_chunks(page);
 	if (freechunks == NCHUNKS) {
 		/* Remove from existing unbuddied list */
-		list_del(&zhdr->buddy);
+		list_del((struct list_head *) &page->index);
 		/* zbud page is empty, free */
 		list_del(&page->lru);
 		free_zbud_page(zhdr);
 		pool->pages_nr--;
 	} else {
 		/* Add to unbuddied list */
-		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
+		list_add((struct list_head *) &page->index,
+				&pool->unbuddied[freechunks]);
 	}
 
 	spin_unlock(&pool->lock);
@@ -501,7 +502,7 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
 		page = list_tail_entry(&pool->lru, struct page, lru);
 		zhdr = page_address(page);
 		list_del(&page->lru);
-		list_del(&zhdr->buddy);
+		list_del((struct list_head *) &page->index);
 		/* Protect zbud page against free */
 		zhdr->under_reclaim = true;
 		/*
@@ -543,7 +544,8 @@ next:
 		} else if (get_num_chunks(page, FIRST) == 0 ||
 				get_num_chunks(page, LAST) == 0) {
 			/* add to unbuddied list */
-			list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
+			list_add((struct list_head *) &page->index,
+					&pool->unbuddied[freechunks]);
 		}
 
 		/* add to beginning of LRU */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
