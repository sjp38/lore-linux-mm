Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id EBA206B0038
	for <linux-mm@kvack.org>; Sun, 25 Dec 2016 19:41:38 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id b14so102838462lfg.6
        for <linux-mm@kvack.org>; Sun, 25 Dec 2016 16:41:38 -0800 (PST)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id j132si23815032lfd.282.2016.12.25.16.41.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Dec 2016 16:41:37 -0800 (PST)
Received: by mail-lf0-x244.google.com with SMTP id y21so24292087lfa.0
        for <linux-mm@kvack.org>; Sun, 25 Dec 2016 16:41:37 -0800 (PST)
Date: Mon, 26 Dec 2016 01:40:59 +0100
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH/RESEND 5/5] z3fold: add kref refcounting
Message-Id: <20161226014059.d1aa11c9ed4ac3380bd35870@gmail.com>
In-Reply-To: <20161226013016.968004f3db024ef2111dc458@gmail.com>
References: <20161226013016.968004f3db024ef2111dc458@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>

With both coming and already present locking optimizations,
introducing kref to reference-count z3fold objects is the right
thing to do. Moreover, it makes buddied list no longer necessary,
and allows for a simpler handling of headless pages.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/z3fold.c | 137 ++++++++++++++++++++++++++++++------------------------------
 1 file changed, 68 insertions(+), 69 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 729a2da..4593493 100644
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
@@ -162,9 +161,21 @@ static struct z3fold_header *init_z3fold_page(struct page *page)
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
+	if (!list_empty(&zhdr->buddy))
+		list_del(&zhdr->buddy);
+	if (!list_empty(&page->lru))
+		list_del(&page->lru);
+	free_z3fold_page(page);
 }
 
 /* Lock a z3fold page */
@@ -256,9 +267,9 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
 	if (!pool)
 		return NULL;
 	spin_lock_init(&pool->lock);
+	kref_init(&zhdr->refcount);
 	for_each_unbuddied_list(i, 0)
 		INIT_LIST_HEAD(&pool->unbuddied[i]);
-	INIT_LIST_HEAD(&pool->buddied);
 	INIT_LIST_HEAD(&pool->lru);
 	atomic64_set(&pool->pages_nr, 0);
 	pool->ops = ops;
@@ -383,7 +394,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 			spin_lock(&pool->lock);
 			zhdr = list_first_entry_or_null(&pool->unbuddied[i],
 						struct z3fold_header, buddy);
-			if (!zhdr) {
+			if (!zhdr || !kref_get_unless_zero(&zhdr->refcount)) {
 				spin_unlock(&pool->lock);
 				continue;
 			}
@@ -403,10 +414,12 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 			else if (zhdr->middle_chunks == 0)
 				bud = MIDDLE;
 			else {
+				z3fold_page_unlock(zhdr);
 				spin_lock(&pool->lock);
-				list_add(&zhdr->buddy, &pool->buddied);
+				if (kref_put(&zhdr->refcount,
+					     release_z3fold_page))
+					atomic64_dec(&pool->pages_nr);
 				spin_unlock(&pool->lock);
-				z3fold_page_unlock(zhdr);
 				pr_err("No free chunks in unbuddied\n");
 				WARN_ON(1);
 				continue;
@@ -447,9 +460,6 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 		/* Add to unbuddied list */
 		freechunks = num_free_chunks(zhdr);
 		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
-	} else {
-		/* Add to buddied list */
-		list_add(&zhdr->buddy, &pool->buddied);
 	}
 
 headless:
@@ -515,50 +525,39 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 
 	if (test_bit(UNDER_RECLAIM, &page->private)) {
 		/* z3fold page is under reclaim, reclaim will free */
-		if (bud != HEADLESS)
+		if (bud != HEADLESS) {
 			z3fold_page_unlock(zhdr);
-		return;
-	}
-
-	/* Remove from existing buddy list */
-	if (bud != HEADLESS) {
-		spin_lock(&pool->lock);
-		/*
-		 * this object may have been removed from its list by
-		 * z3fold_alloc(). In that case we just do nothing,
-		 * z3fold_alloc() will allocate an object and add the page
-		 * to the relevant list.
-		 */
-		if (!list_empty(&zhdr->buddy)) {
-			list_del(&zhdr->buddy);
-		} else {
+			spin_lock(&pool->lock);
+			if (kref_put(&zhdr->refcount, release_z3fold_page))
+				atomic64_dec(&pool->pages_nr);
 			spin_unlock(&pool->lock);
-			z3fold_page_unlock(zhdr);
-			return;
 		}
-		spin_unlock(&pool->lock);
+		return;
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
+			if (!list_empty(&zhdr->buddy))
+				list_del(&zhdr->buddy);
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
@@ -617,13 +616,15 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 			return -EINVAL;
 		}
 		page = list_last_entry(&pool->lru, struct page, lru);
-		list_del(&page->lru);
+		list_del_init(&page->lru);
 
 		/* Protect z3fold page against free */
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
@@ -664,30 +665,26 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
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
@@ -696,10 +693,12 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 					 &pool->unbuddied[freechunks]);
 				spin_unlock(&pool->lock);
 			}
-		}
-
-		if (!test_bit(PAGE_HEADLESS, &page->private))
 			z3fold_page_unlock(zhdr);
+			spin_lock(&pool->lock);
+			if (kref_put(&zhdr->refcount, release_z3fold_page))
+				atomic64_dec(&pool->pages_nr);
+			spin_unlock(&pool->lock);
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
