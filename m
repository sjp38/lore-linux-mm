Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4F11F6B026B
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 02:52:46 -0500 (EST)
Received: by mail-pa0-f72.google.com with SMTP id rf5so88154327pab.3
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 23:52:46 -0800 (PST)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id ec5si2893169pad.330.2016.11.09.23.52.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Nov 2016 23:52:45 -0800 (PST)
Received: by mail-pf0-x244.google.com with SMTP id i88so3233913pfk.2
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 23:52:45 -0800 (PST)
Date: Thu, 10 Nov 2016 08:52:37 +0100
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH v4] z3fold: use per-page spinlock
Message-Id: <20161110085237.1b6d9fd655ec734c0b8be5e9@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>


Most of z3fold operations are in-page, such as modifying z3fold
page header or moving z3fold objects within a page. Taking
per-pool spinlock to protect per-page objects is therefore
suboptimal, and the idea of having a per-page spinlock (or rwlock)
has been around for some time.

This patch implements raw spinlock-based per-page locking mechanism
which is lightweight enough to fit nicely into the z3fold header.

Changes from v1 [1]:
- custom locking mechanism changed to spinlocks
- no read/write locks, just per-page spinlock

Changes from v2 [2]:
- if a page is taken off its list by z3fold_alloc(), bail out from
  z3fold_free() early

Changes from v3 [3]:
- spinlock changed to raw spinlock to avoid BUILD_BUG_ON trigger

[1] https://lkml.org/lkml/2016/11/5/59
[2] https://lkml.org/lkml/2016/11/8/400
[3] https://lkml.org/lkml/2016/11/9/146

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/z3fold.c | 137 ++++++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 97 insertions(+), 40 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index d85dac0..cd3713d 100644
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
@@ -343,50 +359,60 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
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
@@ -398,6 +424,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 		zhdr->start_middle = zhdr->first_chunks + 1;
 	}
 
+	spin_lock(&pool->lock);
 	if (zhdr->first_chunks == 0 || zhdr->last_chunks == 0 ||
 			zhdr->middle_chunks == 0) {
 		/* Add to unbuddied list */
@@ -417,6 +444,8 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 
 	*handle = encode_handle(zhdr, bud);
 	spin_unlock(&pool->lock);
+	if (bud != HEADLESS)
+		z3fold_page_unlock(zhdr);
 
 	return 0;
 }
@@ -438,7 +467,6 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 	struct page *page;
 	enum buddy bud;
 
-	spin_lock(&pool->lock);
 	zhdr = handle_to_z3fold_header(handle);
 	page = virt_to_page(zhdr);
 
@@ -446,6 +474,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 		/* HEADLESS page stored */
 		bud = HEADLESS;
 	} else {
+		z3fold_page_lock(zhdr);
 		bud = handle_to_buddy(handle);
 
 		switch (bud) {
@@ -462,37 +491,59 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
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
@@ -553,7 +604,8 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 		zhdr = page_address(page);
 		if (!test_bit(PAGE_HEADLESS, &page->private)) {
 			list_del(&zhdr->buddy);
-
+			spin_unlock(&pool->lock);
+			z3fold_page_lock(zhdr);
 			/*
 			 * We need encode the handles before unlocking, since
 			 * we can race with free that will set
@@ -568,13 +620,13 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
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
@@ -592,7 +644,8 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 				goto next;
 		}
 next:
-		spin_lock(&pool->lock);
+		if (!test_bit(PAGE_HEADLESS, &page->private))
+			z3fold_page_lock(zhdr);
 		clear_bit(UNDER_RECLAIM, &page->private);
 		if ((test_bit(PAGE_HEADLESS, &page->private) && ret == 0) ||
 		    (zhdr->first_chunks == 0 && zhdr->last_chunks == 0 &&
@@ -602,19 +655,22 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 			 * return success.
 			 */
 			clear_bit(PAGE_HEADLESS, &page->private);
+			if (!test_bit(PAGE_HEADLESS, &page->private))
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
 			} else {
 				z3fold_compact_page(zhdr);
 				/* add to unbuddied list */
+				spin_lock(&pool->lock);
 				freechunks = num_free_chunks(zhdr);
 				list_add(&zhdr->buddy,
 					 &pool->unbuddied[freechunks]);
@@ -625,6 +681,8 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 		list_add(&page->lru, &pool->lru);
 	}
 	spin_unlock(&pool->lock);
+	if (!test_bit(PAGE_HEADLESS, &page->private))
+		z3fold_page_unlock(zhdr);
 	return -EAGAIN;
 }
 
@@ -645,7 +703,6 @@ static void *z3fold_map(struct z3fold_pool *pool, unsigned long handle)
 	void *addr;
 	enum buddy buddy;
 
-	spin_lock(&pool->lock);
 	zhdr = handle_to_z3fold_header(handle);
 	addr = zhdr;
 	page = virt_to_page(zhdr);
@@ -653,6 +710,7 @@ static void *z3fold_map(struct z3fold_pool *pool, unsigned long handle)
 	if (test_bit(PAGE_HEADLESS, &page->private))
 		goto out;
 
+	z3fold_page_lock(zhdr);
 	buddy = handle_to_buddy(handle);
 	switch (buddy) {
 	case FIRST:
@@ -671,8 +729,9 @@ static void *z3fold_map(struct z3fold_pool *pool, unsigned long handle)
 		addr = NULL;
 		break;
 	}
+
+	z3fold_page_unlock(zhdr);
 out:
-	spin_unlock(&pool->lock);
 	return addr;
 }
 
@@ -687,19 +746,17 @@ static void z3fold_unmap(struct z3fold_pool *pool, unsigned long handle)
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
