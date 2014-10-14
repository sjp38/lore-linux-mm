Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 27BF76B007B
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 08:00:01 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id r10so7301651pdi.24
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 05:00:00 -0700 (PDT)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id yp3si12848228pab.136.2014.10.14.04.59.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 14 Oct 2014 04:59:57 -0700 (PDT)
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NDF00EJONZUY7C0@mailout3.samsung.com> for linux-mm@kvack.org;
 Tue, 14 Oct 2014 20:59:54 +0900 (KST)
From: Heesub Shin <heesub.shin@samsung.com>
Subject: [RFC PATCH 7/9] mm/zbud: drop zbud_header
Date: Tue, 14 Oct 2014 20:59:26 +0900
Message-id: <1413287968-13940-8-git-send-email-heesub.shin@samsung.com>
In-reply-to: <1413287968-13940-1-git-send-email-heesub.shin@samsung.com>
References: <1413287968-13940-1-git-send-email-heesub.shin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjennings@variantweb.net>
Cc: Nitin Gupta <ngupta@vflare.org>, Dan Streetman <ddstreet@ieee.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sunae Seo <sunae.seo@samsung.com>, Heesub Shin <heesub.shin@samsung.com>

Now that the only field in zbud_header is .under_reclaim, get it out of
the struct and let PG_reclaim bit in page->flags take over. As a result
of this change, we can finally eliminate the struct zbud_header, and
hence all the internal data structures of zbud live in struct page.

Signed-off-by: Heesub Shin <heesub.shin@samsung.com>
---
 mm/zbud.c | 66 +++++++++++++++++----------------------------------------------
 1 file changed, 18 insertions(+), 48 deletions(-)

diff --git a/mm/zbud.c b/mm/zbud.c
index 8a6dd6b..5a392f3 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -60,17 +60,15 @@
  * NCHUNKS_ORDER determines the internal allocation granularity, effectively
  * adjusting internal fragmentation.  It also determines the number of
  * freelists maintained in each pool. NCHUNKS_ORDER of 6 means that the
- * allocation granularity will be in chunks of size PAGE_SIZE/64. As one chunk
- * in allocated page is occupied by zbud header, NCHUNKS will be calculated to
- * 63 which shows the max number of free chunks in zbud page, also there will be
- * 63 freelists per pool.
+ * allocation granularity will be in chunks of size PAGE_SIZE/64.
+ * NCHUNKS will be calculated to 64 which shows the max number of free
+ * chunks in zbud page, also there will be 64 freelists per pool.
  */
 #define NCHUNKS_ORDER	6
 
 #define CHUNK_SHIFT	(PAGE_SHIFT - NCHUNKS_ORDER)
 #define CHUNK_SIZE	(1 << CHUNK_SHIFT)
-#define ZHDR_SIZE_ALIGNED CHUNK_SIZE
-#define NCHUNKS		((PAGE_SIZE - ZHDR_SIZE_ALIGNED) >> CHUNK_SHIFT)
+#define NCHUNKS		(PAGE_SIZE >> CHUNK_SHIFT)
 
 /**
  * struct zbud_pool - stores metadata for each zbud pool
@@ -96,14 +94,6 @@ struct zbud_pool {
 	struct zbud_ops *ops;
 };
 
-/*
- * struct zbud_header - zbud page metadata occupying the first chunk of each
- *			zbud page.
- */
-struct zbud_header {
-	bool under_reclaim;
-};
-
 /*****************
  * zpool
  ****************/
@@ -220,22 +210,19 @@ static size_t get_num_chunks(struct page *page, enum buddy bud)
 #define for_each_unbuddied_list(_iter, _begin) \
 	for ((_iter) = (_begin); (_iter) < NCHUNKS; (_iter)++)
 
-/* Initializes the zbud header of a newly allocated zbud page */
+/* Initializes a newly allocated zbud page */
 static void init_zbud_page(struct page *page)
 {
-	struct zbud_header *zhdr = page_address(page);
 	set_num_chunks(page, FIRST, 0);
 	set_num_chunks(page, LAST, 0);
 	INIT_LIST_HEAD((struct list_head *) &page->index);
 	INIT_LIST_HEAD(&page->lru);
-	zhdr->under_reclaim = 0;
+	ClearPageReclaim(page);
 }
 
 /* Resets the struct page fields and frees the page */
-static void free_zbud_page(struct zbud_header *zhdr)
+static void free_zbud_page(struct page *page)
 {
-	struct page *page = virt_to_page(zhdr);
-
 	init_page_count(page);
 	page_mapcount_reset(page);
 	__free_page(page);
@@ -261,14 +248,6 @@ static struct page *handle_to_zbud_page(unsigned long handle)
 	return (struct page *) (handle & ~LAST);
 }
 
-/* Returns the zbud page where a given handle is stored */
-static struct zbud_header *handle_to_zbud_header(unsigned long handle)
-{
-	struct page *page = handle_to_zbud_page(handle);
-
-	return page_address(page);
-}
-
 /* Returns the number of free chunks in a zbud page */
 static int num_free_chunks(struct page *page)
 {
@@ -347,7 +326,7 @@ int zbud_alloc(struct zbud_pool *pool, size_t size, gfp_t gfp,
 
 	if (!size || (gfp & __GFP_HIGHMEM))
 		return -EINVAL;
-	if (size > PAGE_SIZE - ZHDR_SIZE_ALIGNED - CHUNK_SIZE)
+	if (size > PAGE_SIZE - CHUNK_SIZE)
 		return -ENOSPC;
 	chunks = size_to_chunks(size);
 	spin_lock(&pool->lock);
@@ -410,21 +389,18 @@ found:
  */
 void zbud_free(struct zbud_pool *pool, unsigned long handle)
 {
-	struct zbud_header *zhdr;
 	struct page *page;
 	int freechunks;
 
 	spin_lock(&pool->lock);
-	zhdr = handle_to_zbud_header(handle);
-	page = virt_to_page(zhdr);
+	page = handle_to_zbud_page(handle);
 
-	/* If first buddy, handle will be page aligned */
-	if ((handle - ZHDR_SIZE_ALIGNED) & ~PAGE_MASK)
-		set_num_chunks(page, LAST, 0);
-	else
+	if (!is_last_chunk(handle))
 		set_num_chunks(page, FIRST, 0);
+	else
+		set_num_chunks(page, LAST, 0);
 
-	if (zhdr->under_reclaim) {
+	if (PageReclaim(page)) {
 		/* zbud page is under reclaim, reclaim will free */
 		spin_unlock(&pool->lock);
 		return;
@@ -436,7 +412,7 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
 		list_del((struct list_head *) &page->index);
 		/* zbud page is empty, free */
 		list_del(&page->lru);
-		free_zbud_page(zhdr);
+		free_zbud_page(page);
 		pool->pages_nr--;
 	} else {
 		/* Add to unbuddied list */
@@ -489,7 +465,6 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
 {
 	int i, ret, freechunks;
 	struct page *page;
-	struct zbud_header *zhdr;
 	unsigned long first_handle, last_handle;
 
 	spin_lock(&pool->lock);
@@ -500,11 +475,10 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
 	}
 	for (i = 0; i < retries; i++) {
 		page = list_tail_entry(&pool->lru, struct page, lru);
-		zhdr = page_address(page);
 		list_del(&page->lru);
 		list_del((struct list_head *) &page->index);
 		/* Protect zbud page against free */
-		zhdr->under_reclaim = true;
+		SetPageReclaim(page);
 		/*
 		 * We need encode the handles before unlocking, since we can
 		 * race with free that will set (first|last)_chunks to 0
@@ -530,14 +504,14 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
 		}
 next:
 		spin_lock(&pool->lock);
-		zhdr->under_reclaim = false;
+		ClearPageReclaim(page);
 		freechunks = num_free_chunks(page);
 		if (freechunks == NCHUNKS) {
 			/*
 			 * Both buddies are now free, free the zbud page and
 			 * return success.
 			 */
-			free_zbud_page(zhdr);
+			free_zbud_page(page);
 			pool->pages_nr--;
 			spin_unlock(&pool->lock);
 			return 0;
@@ -569,14 +543,12 @@ next:
  */
 void *zbud_map(struct zbud_pool *pool, unsigned long handle)
 {
-	size_t offset;
+	size_t offset = 0;
 	struct page *page = handle_to_zbud_page(handle);
 
 	if (is_last_chunk(handle))
 		offset = PAGE_SIZE -
 				(get_num_chunks(page, LAST) << CHUNK_SHIFT);
-	else
-		offset = ZHDR_SIZE_ALIGNED;
 
 	return (unsigned char *) page_address(page) + offset;
 }
@@ -604,8 +576,6 @@ u64 zbud_get_pool_size(struct zbud_pool *pool)
 
 static int __init init_zbud(void)
 {
-	/* Make sure the zbud header will fit in one chunk */
-	BUILD_BUG_ON(sizeof(struct zbud_header) > ZHDR_SIZE_ALIGNED);
 	pr_info("loaded\n");
 
 #ifdef CONFIG_ZPOOL
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
