Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id C66696B0073
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 07:59:58 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id ft15so7400478pdb.17
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 04:59:58 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id hh5si4219864pbc.151.2014.10.14.04.59.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 14 Oct 2014 04:59:55 -0700 (PDT)
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NDF00FUUNZSACD0@mailout4.samsung.com> for linux-mm@kvack.org;
 Tue, 14 Oct 2014 20:59:52 +0900 (KST)
From: Heesub Shin <heesub.shin@samsung.com>
Subject: [RFC PATCH 3/9] mm/zbud: remove lru from zbud_header
Date: Tue, 14 Oct 2014 20:59:22 +0900
Message-id: <1413287968-13940-4-git-send-email-heesub.shin@samsung.com>
In-reply-to: <1413287968-13940-1-git-send-email-heesub.shin@samsung.com>
References: <1413287968-13940-1-git-send-email-heesub.shin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjennings@variantweb.net>
Cc: Nitin Gupta <ngupta@vflare.org>, Dan Streetman <ddstreet@ieee.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sunae Seo <sunae.seo@samsung.com>, Heesub Shin <heesub.shin@samsung.com>

zbud_pool has an lru list for tracking zbud pages and they are strung
together via zhdr->lru. If we reuse page->lru for linking zbud pages
instead of it, the lru field in zbud_header can be dropped.

Signed-off-by: Heesub Shin <heesub.shin@samsung.com>
---
 mm/zbud.c | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/mm/zbud.c b/mm/zbud.c
index 0f5add0..a2390f6 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -100,13 +100,11 @@ struct zbud_pool {
  * struct zbud_header - zbud page metadata occupying the first chunk of each
  *			zbud page.
  * @buddy:	links the zbud page into the unbuddied lists in the pool
- * @lru:	links the zbud page into the lru list in the pool
  * @first_chunks:	the size of the first buddy in chunks, 0 if free
  * @last_chunks:	the size of the last buddy in chunks, 0 if free
  */
 struct zbud_header {
 	struct list_head buddy;
-	struct list_head lru;
 	unsigned int first_chunks;
 	unsigned int last_chunks;
 	bool under_reclaim;
@@ -224,7 +222,7 @@ static struct zbud_header *init_zbud_page(struct page *page)
 	zhdr->first_chunks = 0;
 	zhdr->last_chunks = 0;
 	INIT_LIST_HEAD(&zhdr->buddy);
-	INIT_LIST_HEAD(&zhdr->lru);
+	INIT_LIST_HEAD(&page->lru);
 	zhdr->under_reclaim = 0;
 	return zhdr;
 }
@@ -352,6 +350,7 @@ int zbud_alloc(struct zbud_pool *pool, size_t size, gfp_t gfp,
 		if (!list_empty(&pool->unbuddied[i])) {
 			zhdr = list_first_entry(&pool->unbuddied[i],
 					struct zbud_header, buddy);
+			page = virt_to_page(zhdr);
 			list_del(&zhdr->buddy);
 			goto found;
 		}
@@ -382,9 +381,9 @@ found:
 	}
 
 	/* Add/move zbud page to beginning of LRU */
-	if (!list_empty(&zhdr->lru))
-		list_del(&zhdr->lru);
-	list_add(&zhdr->lru, &pool->lru);
+	if (!list_empty(&page->lru))
+		list_del(&page->lru);
+	list_add(&page->lru, &pool->lru);
 
 	*handle = encode_handle(zhdr, bud);
 	spin_unlock(&pool->lock);
@@ -405,10 +404,12 @@ found:
 void zbud_free(struct zbud_pool *pool, unsigned long handle)
 {
 	struct zbud_header *zhdr;
+	struct page *page;
 	int freechunks;
 
 	spin_lock(&pool->lock);
 	zhdr = handle_to_zbud_header(handle);
+	page = virt_to_page(zhdr);
 
 	/* If first buddy, handle will be page aligned */
 	if ((handle - ZHDR_SIZE_ALIGNED) & ~PAGE_MASK)
@@ -426,7 +427,7 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
 		/* Remove from existing unbuddied list */
 		list_del(&zhdr->buddy);
 		/* zbud page is empty, free */
-		list_del(&zhdr->lru);
+		list_del(&page->lru);
 		free_zbud_page(zhdr);
 		pool->pages_nr--;
 	} else {
@@ -479,6 +480,7 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
 int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
 {
 	int i, ret, freechunks;
+	struct page *page;
 	struct zbud_header *zhdr;
 	unsigned long first_handle, last_handle;
 
@@ -489,8 +491,9 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
 		return -EINVAL;
 	}
 	for (i = 0; i < retries; i++) {
-		zhdr = list_tail_entry(&pool->lru, struct zbud_header, lru);
-		list_del(&zhdr->lru);
+		page = list_tail_entry(&pool->lru, struct page, lru);
+		zhdr = page_address(page);
+		list_del(&page->lru);
 		list_del(&zhdr->buddy);
 		/* Protect zbud page against free */
 		zhdr->under_reclaim = true;
@@ -537,7 +540,7 @@ next:
 		}
 
 		/* add to beginning of LRU */
-		list_add(&zhdr->lru, &pool->lru);
+		list_add(&page->lru, &pool->lru);
 	}
 	spin_unlock(&pool->lock);
 	return -EAGAIN;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
