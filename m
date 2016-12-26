Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5DCE56B0038
	for <linux-mm@kvack.org>; Sun, 25 Dec 2016 19:37:48 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id g12so103262596lfe.5
        for <linux-mm@kvack.org>; Sun, 25 Dec 2016 16:37:48 -0800 (PST)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id r6si23816118lff.179.2016.12.25.16.37.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Dec 2016 16:37:46 -0800 (PST)
Received: by mail-lf0-x243.google.com with SMTP id t196so7596145lff.3
        for <linux-mm@kvack.org>; Sun, 25 Dec 2016 16:37:46 -0800 (PST)
Date: Mon, 26 Dec 2016 01:37:42 +0100
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH/RESEND 3/5] z3fold: use per-page spinlock
Message-Id: <20161226013742.d58f86d2aa3e8f4f12897f42@gmail.com>
In-Reply-To: <20161226013016.968004f3db024ef2111dc458@gmail.com>
References: <20161226013016.968004f3db024ef2111dc458@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>

Most of z3fold operations are in-page, such as modifying z3fold page
header or moving z3fold objects within a page.  Taking per-pool spinlock
to protect per-page objects is therefore suboptimal, and the idea of
having a per-page spinlock (or rwlock) has been around for some time.

This patch implements raw spinlock-based per-page locking mechanism which
is lightweight enough to normally fit ok into the z3fold header.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/z3fold.c | 148 +++++++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 106 insertions(+), 42 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index d2e8aec..28c0a2d 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -98,6 +98,7 @@ enum buddy {
  * struct z3fold_header - z3fold page metadata occupying the first chunk of each
  *			z3fold page, except for HEADLESS pages
  * @buddy:	links the z3fold page into the relevant list in the pool
+ * @page_lock:		per-page lock
  * @first_chunks:	the size of the first buddy in chunks, 0 if free
  * @middle_chunks:	the size of the middle buddy in chunks, 0 if free
  * @last_chunks:	the size of the last buddy in chunks, 0 if free
@@ -105,6 +106,7 @@ enum buddy {
  */
 struct z3fold_header {
 	struct list_head buddy;
+	raw_spinlock_t page_lock;
 	unsigned short first_chunks;
 	unsigned short middle_chunks;
 	unsigned short last_chunks;
@@ -144,6 +146,7 @@ static struct z3fold_header *init_z3fold_page(struct page *page)
 	clear_bit(PAGE_HEADLESS, &page->private);
 	clear_bit(MIDDLE_CHUNK_MAPPED, &page->private);
 
+	raw_spin_lock_init(&zhdr->page_lock);
 	zhdr->first_chunks = 0;
 	zhdr->middle_chunks = 0;
 	zhdr->last_chunks = 0;
@@ -159,6 +162,19 @@ static void free_z3fold_page(struct z3fold_header *zhdr)
 	__free_page(virt_to_page(zhdr));
 }
 
+/* Lock a z3fold page */
+static inline void z3fold_page_lock(struct z3fold_header *zhdr)
+{
+	raw_spin_lock(&zhdr->page_lock);
+}
+
+/* Unlock a z3fold page */
+static inline void z3fold_page_unlock(struct z3fold_header *zhdr)
+{
+	raw_spin_unlock(&zhdr->page_lock);
+}
+
+
 /*
  * Encodes the handle of a particular buddy within a z3fold page
  * Pool lock should be held as this function accesses first_num
@@ -347,50 +363,60 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 		bud = HEADLESS;
 	else {
 		chunks = size_to_chunks(size);
-		spin_lock(&pool->lock);
 
 		/* First, try to find an unbuddied z3fold page. */
 		zhdr = NULL;
 		for_each_unbuddied_list(i, chunks) {
-			if (!list_empty(&pool->unbuddied[i])) {
-				zhdr = list_first_entry(&pool->unbuddied[i],
+			spin_lock(&pool->lock);
+			zhdr = list_first_entry_or_null(&pool->unbuddied[i],
 						struct z3fold_header, buddy);
-				page = virt_to_page(zhdr);
-				if (zhdr->first_chunks == 0) {
-					if (zhdr->middle_chunks != 0 &&
-					    chunks >= zhdr->start_middle)
-						bud = LAST;
-					else
-						bud = FIRST;
-				} else if (zhdr->last_chunks == 0)
+			if (!zhdr) {
+				spin_unlock(&pool->lock);
+				continue;
+			}
+			list_del_init(&zhdr->buddy);
+			spin_unlock(&pool->lock);
+
+			page = virt_to_page(zhdr);
+			z3fold_page_lock(zhdr);
+			if (zhdr->first_chunks == 0) {
+				if (zhdr->middle_chunks != 0 &&
+				    chunks >= zhdr->start_middle)
 					bud = LAST;
-				else if (zhdr->middle_chunks == 0)
-					bud = MIDDLE;
-				else {
-					pr_err("No free chunks in unbuddied\n");
-					WARN_ON(1);
-					continue;
-				}
-				list_del(&zhdr->buddy);
-				goto found;
+				else
+					bud = FIRST;
+			} else if (zhdr->last_chunks == 0)
+				bud = LAST;
+			else if (zhdr->middle_chunks == 0)
+				bud = MIDDLE;
+			else {
+				spin_lock(&pool->lock);
+				list_add(&zhdr->buddy, &pool->buddied);
+				spin_unlock(&pool->lock);
+				z3fold_page_unlock(zhdr);
+				pr_err("No free chunks in unbuddied\n");
+				WARN_ON(1);
+				continue;
 			}
+			goto found;
 		}
 		bud = FIRST;
-		spin_unlock(&pool->lock);
 	}
 
 	/* Couldn't find unbuddied z3fold page, create new one */
 	page = alloc_page(gfp);
 	if (!page)
 		return -ENOMEM;
-	spin_lock(&pool->lock);
+
 	atomic64_inc(&pool->pages_nr);
 	zhdr = init_z3fold_page(page);
 
 	if (bud == HEADLESS) {
 		set_bit(PAGE_HEADLESS, &page->private);
+		spin_lock(&pool->lock);
 		goto headless;
 	}
+	z3fold_page_lock(zhdr);
 
 found:
 	if (bud == FIRST)
@@ -402,6 +428,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 		zhdr->start_middle = zhdr->first_chunks + 1;
 	}
 
+	spin_lock(&pool->lock);
 	if (zhdr->first_chunks == 0 || zhdr->last_chunks == 0 ||
 			zhdr->middle_chunks == 0) {
 		/* Add to unbuddied list */
@@ -421,6 +448,8 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 
 	*handle = encode_handle(zhdr, bud);
 	spin_unlock(&pool->lock);
+	if (bud != HEADLESS)
+		z3fold_page_unlock(zhdr);
 
 	return 0;
 }
@@ -442,7 +471,6 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 	struct page *page;
 	enum buddy bud;
 
-	spin_lock(&pool->lock);
 	zhdr = handle_to_z3fold_header(handle);
 	page = virt_to_page(zhdr);
 
@@ -450,6 +478,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 		/* HEADLESS page stored */
 		bud = HEADLESS;
 	} else {
+		z3fold_page_lock(zhdr);
 		bud = handle_to_buddy(handle);
 
 		switch (bud) {
@@ -466,37 +495,59 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 		default:
 			pr_err("%s: unknown bud %d\n", __func__, bud);
 			WARN_ON(1);
-			spin_unlock(&pool->lock);
+			z3fold_page_unlock(zhdr);
 			return;
 		}
 	}
 
 	if (test_bit(UNDER_RECLAIM, &page->private)) {
 		/* z3fold page is under reclaim, reclaim will free */
-		spin_unlock(&pool->lock);
+		if (bud != HEADLESS)
+			z3fold_page_unlock(zhdr);
 		return;
 	}
 
 	/* Remove from existing buddy list */
-	if (bud != HEADLESS)
-		list_del(&zhdr->buddy);
+	if (bud != HEADLESS) {
+		spin_lock(&pool->lock);
+		/*
+		 * this object may have been removed from its list by
+		 * z3fold_alloc(). In that case we just do nothing,
+		 * z3fold_alloc() will allocate an object and add the page
+		 * to the relevant list.
+		 */
+		if (!list_empty(&zhdr->buddy)) {
+			list_del(&zhdr->buddy);
+		} else {
+			spin_unlock(&pool->lock);
+			z3fold_page_unlock(zhdr);
+			return;
+		}
+		spin_unlock(&pool->lock);
+	}
 
 	if (bud == HEADLESS ||
 	    (zhdr->first_chunks == 0 && zhdr->middle_chunks == 0 &&
 			zhdr->last_chunks == 0)) {
 		/* z3fold page is empty, free */
+		spin_lock(&pool->lock);
 		list_del(&page->lru);
+		spin_unlock(&pool->lock);
 		clear_bit(PAGE_HEADLESS, &page->private);
+		if (bud != HEADLESS)
+			z3fold_page_unlock(zhdr);
 		free_z3fold_page(zhdr);
 		atomic64_dec(&pool->pages_nr);
 	} else {
 		z3fold_compact_page(zhdr);
 		/* Add to the unbuddied list */
+		spin_lock(&pool->lock);
 		freechunks = num_free_chunks(zhdr);
 		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
+		spin_unlock(&pool->lock);
+		z3fold_page_unlock(zhdr);
 	}
 
-	spin_unlock(&pool->lock);
 }
 
 /**
@@ -543,12 +594,15 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 	unsigned long first_handle = 0, middle_handle = 0, last_handle = 0;
 
 	spin_lock(&pool->lock);
-	if (!pool->ops || !pool->ops->evict || list_empty(&pool->lru) ||
-			retries == 0) {
+	if (!pool->ops || !pool->ops->evict || retries == 0) {
 		spin_unlock(&pool->lock);
 		return -EINVAL;
 	}
 	for (i = 0; i < retries; i++) {
+		if (list_empty(&pool->lru)) {
+			spin_unlock(&pool->lock);
+			return -EINVAL;
+		}
 		page = list_last_entry(&pool->lru, struct page, lru);
 		list_del(&page->lru);
 
@@ -557,6 +611,8 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 		zhdr = page_address(page);
 		if (!test_bit(PAGE_HEADLESS, &page->private)) {
 			list_del(&zhdr->buddy);
+			spin_unlock(&pool->lock);
+			z3fold_page_lock(zhdr);
 			/*
 			 * We need encode the handles before unlocking, since
 			 * we can race with free that will set
@@ -571,13 +627,13 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 				middle_handle = encode_handle(zhdr, MIDDLE);
 			if (zhdr->last_chunks)
 				last_handle = encode_handle(zhdr, LAST);
+			z3fold_page_unlock(zhdr);
 		} else {
 			first_handle = encode_handle(zhdr, HEADLESS);
 			last_handle = middle_handle = 0;
+			spin_unlock(&pool->lock);
 		}
 
-		spin_unlock(&pool->lock);
-
 		/* Issue the eviction callback(s) */
 		if (middle_handle) {
 			ret = pool->ops->evict(pool, middle_handle);
@@ -595,7 +651,8 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 				goto next;
 		}
 next:
-		spin_lock(&pool->lock);
+		if (!test_bit(PAGE_HEADLESS, &page->private))
+			z3fold_page_lock(zhdr);
 		clear_bit(UNDER_RECLAIM, &page->private);
 		if ((test_bit(PAGE_HEADLESS, &page->private) && ret == 0) ||
 		    (zhdr->first_chunks == 0 && zhdr->last_chunks == 0 &&
@@ -604,26 +661,34 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 			 * All buddies are now free, free the z3fold page and
 			 * return success.
 			 */
-			clear_bit(PAGE_HEADLESS, &page->private);
+			if (!test_and_clear_bit(PAGE_HEADLESS, &page->private))
+				z3fold_page_unlock(zhdr);
 			free_z3fold_page(zhdr);
 			atomic64_dec(&pool->pages_nr);
-			spin_unlock(&pool->lock);
 			return 0;
 		}  else if (!test_bit(PAGE_HEADLESS, &page->private)) {
 			if (zhdr->first_chunks != 0 &&
 			    zhdr->last_chunks != 0 &&
 			    zhdr->middle_chunks != 0) {
 				/* Full, add to buddied list */
+				spin_lock(&pool->lock);
 				list_add(&zhdr->buddy, &pool->buddied);
+				spin_unlock(&pool->lock);
 			} else {
 				z3fold_compact_page(zhdr);
 				/* add to unbuddied list */
+				spin_lock(&pool->lock);
 				freechunks = num_free_chunks(zhdr);
 				list_add(&zhdr->buddy,
 					 &pool->unbuddied[freechunks]);
+				spin_unlock(&pool->lock);
 			}
 		}
 
+		if (!test_bit(PAGE_HEADLESS, &page->private))
+			z3fold_page_unlock(zhdr);
+
+		spin_lock(&pool->lock);
 		/* add to beginning of LRU */
 		list_add(&page->lru, &pool->lru);
 	}
@@ -648,7 +713,6 @@ static void *z3fold_map(struct z3fold_pool *pool, unsigned long handle)
 	void *addr;
 	enum buddy buddy;
 
-	spin_lock(&pool->lock);
 	zhdr = handle_to_z3fold_header(handle);
 	addr = zhdr;
 	page = virt_to_page(zhdr);
@@ -656,6 +720,7 @@ static void *z3fold_map(struct z3fold_pool *pool, unsigned long handle)
 	if (test_bit(PAGE_HEADLESS, &page->private))
 		goto out;
 
+	z3fold_page_lock(zhdr);
 	buddy = handle_to_buddy(handle);
 	switch (buddy) {
 	case FIRST:
@@ -674,8 +739,9 @@ static void *z3fold_map(struct z3fold_pool *pool, unsigned long handle)
 		addr = NULL;
 		break;
 	}
+
+	z3fold_page_unlock(zhdr);
 out:
-	spin_unlock(&pool->lock);
 	return addr;
 }
 
@@ -690,19 +756,17 @@ static void z3fold_unmap(struct z3fold_pool *pool, unsigned long handle)
 	struct page *page;
 	enum buddy buddy;
 
-	spin_lock(&pool->lock);
 	zhdr = handle_to_z3fold_header(handle);
 	page = virt_to_page(zhdr);
 
-	if (test_bit(PAGE_HEADLESS, &page->private)) {
-		spin_unlock(&pool->lock);
+	if (test_bit(PAGE_HEADLESS, &page->private))
 		return;
-	}
 
+	z3fold_page_lock(zhdr);
 	buddy = handle_to_buddy(handle);
 	if (buddy == MIDDLE)
 		clear_bit(MIDDLE_CHUNK_MAPPED, &page->private);
-	spin_unlock(&pool->lock);
+	z3fold_page_unlock(zhdr);
 }
 
 /**
-- 
2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
