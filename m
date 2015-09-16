Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7CDDE6B0038
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 07:50:52 -0400 (EDT)
Received: by lamp12 with SMTP id p12so125777717lam.0
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 04:50:51 -0700 (PDT)
Received: from mail-la0-x22a.google.com (mail-la0-x22a.google.com. [2a00:1450:4010:c03::22a])
        by mx.google.com with ESMTPS id k4si17940037lam.79.2015.09.16.04.50.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Sep 2015 04:50:51 -0700 (PDT)
Received: by lahg1 with SMTP id g1so97978566lah.1
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 04:50:50 -0700 (PDT)
Date: Wed, 16 Sep 2015 13:50:48 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH 1/2] zbud: allow PAGE_SIZE allocations
Message-Id: <20150916135048.fbd50fac5e91244ab9731b82@gmail.com>
In-Reply-To: <20150916134857.e4a71f601a1f68cfa16cb361@gmail.com>
References: <20150916134857.e4a71f601a1f68cfa16cb361@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ddstreet@ieee.org, akpm@linux-foundation.org, minchan@kernel.org, sergey.senozhatsky@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

For zram to be able to use zbud via the common zpool API,
allocations of size PAGE_SIZE should be allowed by zpool.
zbud uses the beginning of an allocated page for its internal
structure but it is not a problem as long as we keep track of
such special pages using a newly introduced page flag.
To be able to keep track of zbud pages in any case, struct page's
lru pointer will be used for zbud page lists instead of the one
that used to be part of the aforementioned internal structure.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 include/linux/page-flags.h |  3 ++
 mm/zbud.c                  | 71 ++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 62 insertions(+), 12 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 416509e..dd47cf0 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -134,6 +134,9 @@ enum pageflags {
 
 	/* SLOB */
 	PG_slob_free = PG_private,
+
+	/* ZBUD */
+	PG_uncompressed = PG_owner_priv_1,
 };
 
 #ifndef __GENERATING_BOUNDS_H
diff --git a/mm/zbud.c b/mm/zbud.c
index fa48bcdf..ee8b5d6 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -107,13 +107,11 @@ struct zbud_pool {
  * struct zbud_header - zbud page metadata occupying the first chunk of each
  *			zbud page.
  * @buddy:	links the zbud page into the unbuddied/buddied lists in the pool
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
@@ -221,6 +219,7 @@ MODULE_ALIAS("zpool-zbud");
 *****************/
 /* Just to make the code easier to read */
 enum buddy {
+	FULL,
 	FIRST,
 	LAST
 };
@@ -241,7 +240,7 @@ static struct zbud_header *init_zbud_page(struct page *page)
 	zhdr->first_chunks = 0;
 	zhdr->last_chunks = 0;
 	INIT_LIST_HEAD(&zhdr->buddy);
-	INIT_LIST_HEAD(&zhdr->lru);
+	INIT_LIST_HEAD(&page->lru);
 	zhdr->under_reclaim = 0;
 	return zhdr;
 }
@@ -267,11 +266,18 @@ static unsigned long encode_handle(struct zbud_header *zhdr, enum buddy bud)
 	 * over the zbud header in the first chunk.
 	 */
 	handle = (unsigned long)zhdr;
-	if (bud == FIRST)
+	switch (bud) {
+	case FIRST:
 		/* skip over zbud header */
 		handle += ZHDR_SIZE_ALIGNED;
-	else /* bud == LAST */
+		break;
+	case LAST:
 		handle += PAGE_SIZE - (zhdr->last_chunks  << CHUNK_SHIFT);
+		break;
+	case FULL:
+	default:
+		break;
+	}
 	return handle;
 }
 
@@ -360,6 +366,24 @@ int zbud_alloc(struct zbud_pool *pool, size_t size, gfp_t gfp,
 
 	if (!size || (gfp & __GFP_HIGHMEM))
 		return -EINVAL;
+
+	if (size == PAGE_SIZE) {
+		/*
+		 * This is a special case. The page will be allocated
+		 * and used to store uncompressed data
+		 */
+		page = alloc_page(gfp);
+		if (!page)
+			return -ENOMEM;
+		spin_lock(&pool->lock);
+		pool->pages_nr++;
+		INIT_LIST_HEAD(&page->lru);
+		page->flags |= PG_uncompressed;
+		list_add(&page->lru, &pool->lru);
+		spin_unlock(&pool->lock);
+		*handle = encode_handle(page_address(page), FULL);
+		return 0;
+	}
 	if (size > PAGE_SIZE - ZHDR_SIZE_ALIGNED - CHUNK_SIZE)
 		return -ENOSPC;
 	chunks = size_to_chunks(size);
@@ -372,6 +396,7 @@ int zbud_alloc(struct zbud_pool *pool, size_t size, gfp_t gfp,
 			zhdr = list_first_entry(&pool->unbuddied[i],
 					struct zbud_header, buddy);
 			list_del(&zhdr->buddy);
+			page = virt_to_page(zhdr);
 			if (zhdr->first_chunks == 0)
 				bud = FIRST;
 			else
@@ -406,9 +431,9 @@ found:
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
@@ -430,9 +455,21 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
 {
 	struct zbud_header *zhdr;
 	int freechunks;
+	struct page *page;
 
 	spin_lock(&pool->lock);
 	zhdr = handle_to_zbud_header(handle);
+	page = virt_to_page(zhdr);
+
+	/* If it was an uncompressed full page, just free it */
+	if (page->flags & PG_uncompressed) {
+		page->flags &= ~PG_uncompressed;
+		list_del(&page->lru);
+		__free_page(page);
+		pool->pages_nr--;
+		spin_unlock(&pool->lock);
+		return;
+	}
 
 	/* If first buddy, handle will be page aligned */
 	if ((handle - ZHDR_SIZE_ALIGNED) & ~PAGE_MASK)
@@ -451,7 +488,7 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
 
 	if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
 		/* zbud page is empty, free */
-		list_del(&zhdr->lru);
+		list_del(&page->lru);
 		free_zbud_page(zhdr);
 		pool->pages_nr--;
 	} else {
@@ -505,6 +542,7 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
 {
 	int i, ret, freechunks;
 	struct zbud_header *zhdr;
+	struct page *page;
 	unsigned long first_handle = 0, last_handle = 0;
 
 	spin_lock(&pool->lock);
@@ -514,8 +552,17 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
 		return -EINVAL;
 	}
 	for (i = 0; i < retries; i++) {
-		zhdr = list_tail_entry(&pool->lru, struct zbud_header, lru);
-		list_del(&zhdr->lru);
+		page = list_tail_entry(&pool->lru, struct page, lru);
+		zhdr = page_address(page);
+		list_del(&page->lru);
+		/* Uncompressed zbud page? just run eviction and free it */
+		if (page->flags & PG_uncompressed) {
+			page->flags &= ~PG_uncompressed;
+			spin_unlock(&pool->lock);
+			pool->ops->evict(pool, encode_handle(zhdr, FULL));
+			__free_page(page);
+			return 0;
+		}
 		list_del(&zhdr->buddy);
 		/* Protect zbud page against free */
 		zhdr->under_reclaim = true;
@@ -565,7 +612,7 @@ next:
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
