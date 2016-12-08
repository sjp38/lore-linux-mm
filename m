Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6FDCE6B0069
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 06:24:39 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id xr1so94905248wjb.7
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 03:24:39 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id r3si12794757wmd.81.2016.12.08.03.24.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 03:24:37 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id m203so2912730wma.3
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 03:24:37 -0800 (PST)
Date: Thu, 8 Dec 2016 12:24:29 +0100
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH/RFC] z3fold: add kref refcounting
Message-Id: <20161208122429.79cdf310867c8b4283b9c7d1@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org


Even with already present locking optimizations (and with the
page compaction to come), using kref for reference counting
z3fold objects seems to be the right thing to do. Moreover,
it makes buddied list no longer necessary, and allows for
simpler handling of headless pages.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/z3fold.c | 108 ++++++++++++++++++++++++++++++++----------------------------
 1 file changed, 57 insertions(+), 51 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 729a2da..8dcf35e 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -52,6 +52,7 @@ enum buddy {
  *			z3fold page, except for HEADLESS pages
  * @buddy:	links the z3fold page into the relevant list in the pool
  * @page_lock:		per-page lock
+ * @refcount:		reference cound for the z3fold page
  * @first_chunks:	the size of the first buddy in chunks, 0 if free
  * @middle_chunks:	the size of the middle buddy in chunks, 0 if free
  * @last_chunks:	the size of the last buddy in chunks, 0 if free
@@ -60,6 +61,7 @@ enum buddy {
 struct z3fold_header {
 	struct list_head buddy;
 	raw_spinlock_t page_lock;
+	struct kref refcount;
 	unsigned short first_chunks;
 	unsigned short middle_chunks;
 	unsigned short last_chunks;
@@ -95,8 +97,6 @@ struct z3fold_header {
  * @unbuddied:	array of lists tracking z3fold pages that contain 2- buddies;
  *		the lists each z3fold page is added to depends on the size of
  *		its free region.
- * @buddied:	list tracking the z3fold pages that contain 3 buddies;
- *		these z3fold pages are full
  * @lru:	list tracking the z3fold pages in LRU order by most recently
  *		added buddy.
  * @pages_nr:	number of z3fold pages in the pool.
@@ -109,7 +109,6 @@ struct z3fold_header {
 struct z3fold_pool {
 	spinlock_t lock;
 	struct list_head unbuddied[NCHUNKS];
-	struct list_head buddied;
 	struct list_head lru;
 	atomic64_t pages_nr;
 	const struct z3fold_ops *ops;
@@ -152,6 +151,7 @@ static struct z3fold_header *init_z3fold_page(struct page *page)
 	clear_bit(MIDDLE_CHUNK_MAPPED, &page->private);
 
 	raw_spin_lock_init(&zhdr->page_lock);
+	kref_init(&zhdr->refcount);
 	zhdr->first_chunks = 0;
 	zhdr->middle_chunks = 0;
 	zhdr->last_chunks = 0;
@@ -162,9 +162,19 @@ static struct z3fold_header *init_z3fold_page(struct page *page)
 }
 
 /* Resets the struct page fields and frees the page */
-static void free_z3fold_page(struct z3fold_header *zhdr)
+static void free_z3fold_page(struct page *page)
 {
-	__free_page(virt_to_page(zhdr));
+	__free_page(page);
+}
+
+static void release_z3fold_page(struct kref *ref)
+{
+	struct z3fold_header *zhdr = container_of(ref, struct z3fold_header,
+						refcount);
+	struct page *page = virt_to_page(zhdr);
+	if (!list_empty(&page->lru))
+		list_del(&page->lru);
+	free_z3fold_page(page);
 }
 
 /* Lock a z3fold page */
@@ -258,7 +268,6 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
 	spin_lock_init(&pool->lock);
 	for_each_unbuddied_list(i, 0)
 		INIT_LIST_HEAD(&pool->unbuddied[i]);
-	INIT_LIST_HEAD(&pool->buddied);
 	INIT_LIST_HEAD(&pool->lru);
 	atomic64_set(&pool->pages_nr, 0);
 	pool->ops = ops;
@@ -388,6 +397,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 				continue;
 			}
 			list_del_init(&zhdr->buddy);
+			kref_get(&zhdr->refcount);
 			spin_unlock(&pool->lock);
 
 			page = virt_to_page(zhdr);
@@ -403,10 +413,8 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 			else if (zhdr->middle_chunks == 0)
 				bud = MIDDLE;
 			else {
-				spin_lock(&pool->lock);
-				list_add(&zhdr->buddy, &pool->buddied);
-				spin_unlock(&pool->lock);
 				z3fold_page_unlock(zhdr);
+				kref_put(&zhdr->refcount, release_z3fold_page);
 				pr_err("No free chunks in unbuddied\n");
 				WARN_ON(1);
 				continue;
@@ -447,9 +455,6 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 		/* Add to unbuddied list */
 		freechunks = num_free_chunks(zhdr);
 		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
-	} else {
-		/* Add to buddied list */
-		list_add(&zhdr->buddy, &pool->buddied);
 	}
 
 headless:
@@ -515,8 +520,10 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 
 	if (test_bit(UNDER_RECLAIM, &page->private)) {
 		/* z3fold page is under reclaim, reclaim will free */
-		if (bud != HEADLESS)
+		if (bud != HEADLESS) {
 			z3fold_page_unlock(zhdr);
+			kref_put(&zhdr->refcount, release_z3fold_page);
+		}
 		return;
 	}
 
@@ -530,35 +537,37 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 		 * to the relevant list.
 		 */
 		if (!list_empty(&zhdr->buddy)) {
-			list_del(&zhdr->buddy);
+			list_del_init(&zhdr->buddy);
 		} else {
 			spin_unlock(&pool->lock);
 			z3fold_page_unlock(zhdr);
+			kref_put(&zhdr->refcount, release_z3fold_page);
 			return;
 		}
 		spin_unlock(&pool->lock);
 	}
 
-	if (bud == HEADLESS ||
-	    (zhdr->first_chunks == 0 && zhdr->middle_chunks == 0 &&
-			zhdr->last_chunks == 0)) {
-		/* z3fold page is empty, free */
+	if (bud == HEADLESS) {
 		spin_lock(&pool->lock);
 		list_del(&page->lru);
 		spin_unlock(&pool->lock);
-		clear_bit(PAGE_HEADLESS, &page->private);
-		if (bud != HEADLESS)
-			z3fold_page_unlock(zhdr);
-		free_z3fold_page(zhdr);
+		free_z3fold_page(page);
 		atomic64_dec(&pool->pages_nr);
 	} else {
-		z3fold_compact_page(zhdr);
-		/* Add to the unbuddied list */
+		if (zhdr->first_chunks != 0 || zhdr->middle_chunks != 0 ||
+		    zhdr->last_chunks != 0) {
+			z3fold_compact_page(zhdr);
+			/* Add to the unbuddied list */
+			spin_lock(&pool->lock);
+			freechunks = num_free_chunks(zhdr);
+			list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
+			spin_unlock(&pool->lock);
+		}
+		z3fold_page_unlock(zhdr);
 		spin_lock(&pool->lock);
-		freechunks = num_free_chunks(zhdr);
-		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
+		if (kref_put(&zhdr->refcount, release_z3fold_page))
+			atomic64_dec(&pool->pages_nr);
 		spin_unlock(&pool->lock);
-		z3fold_page_unlock(zhdr);
 	}
 
 }
@@ -623,7 +632,9 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 		set_bit(UNDER_RECLAIM, &page->private);
 		zhdr = page_address(page);
 		if (!test_bit(PAGE_HEADLESS, &page->private)) {
-			list_del(&zhdr->buddy);
+			if (!list_empty(&zhdr->buddy))
+				list_del_init(&zhdr->buddy);
+			kref_get(&zhdr->refcount);
 			spin_unlock(&pool->lock);
 			z3fold_page_lock(zhdr);
 			/*
@@ -664,30 +675,26 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 				goto next;
 		}
 next:
-		if (!test_bit(PAGE_HEADLESS, &page->private))
-			z3fold_page_lock(zhdr);
 		clear_bit(UNDER_RECLAIM, &page->private);
-		if ((test_bit(PAGE_HEADLESS, &page->private) && ret == 0) ||
-		    (zhdr->first_chunks == 0 && zhdr->last_chunks == 0 &&
-		     zhdr->middle_chunks == 0)) {
-			/*
-			 * All buddies are now free, free the z3fold page and
-			 * return success.
-			 */
-			if (!test_and_clear_bit(PAGE_HEADLESS, &page->private))
+		if (test_bit(PAGE_HEADLESS, &page->private)) {
+			if (ret == 0) {
+				free_z3fold_page(page);
+				return 0;
+			}
+		} else {
+			z3fold_page_lock(zhdr);
+			if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0 &&
+			    zhdr->middle_chunks == 0) {
 				z3fold_page_unlock(zhdr);
-			free_z3fold_page(zhdr);
-			atomic64_dec(&pool->pages_nr);
-			return 0;
-		}  else if (!test_bit(PAGE_HEADLESS, &page->private)) {
-			if (zhdr->first_chunks != 0 &&
-			    zhdr->last_chunks != 0 &&
-			    zhdr->middle_chunks != 0) {
-				/* Full, add to buddied list */
 				spin_lock(&pool->lock);
-				list_add(&zhdr->buddy, &pool->buddied);
+				if (kref_put(&zhdr->refcount,
+					     release_z3fold_page))
+					atomic64_dec(&pool->pages_nr);
 				spin_unlock(&pool->lock);
-			} else {
+				return 0;
+			} else if (zhdr->first_chunks == 0 ||
+				   zhdr->last_chunks == 0 ||
+				   zhdr->middle_chunks == 0) {
 				z3fold_compact_page(zhdr);
 				/* add to unbuddied list */
 				spin_lock(&pool->lock);
@@ -696,10 +703,9 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 					 &pool->unbuddied[freechunks]);
 				spin_unlock(&pool->lock);
 			}
-		}
-
-		if (!test_bit(PAGE_HEADLESS, &page->private))
 			z3fold_page_unlock(zhdr);
+			kref_put(&zhdr->refcount, release_z3fold_page);
+		}
 
 		spin_lock(&pool->lock);
 		/* add to beginning of LRU */
-- 
2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
