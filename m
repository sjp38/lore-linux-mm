Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 75F906B0261
	for <linux-mm@kvack.org>; Sat,  5 Nov 2016 09:49:54 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a8so5955250pfg.0
        for <linux-mm@kvack.org>; Sat, 05 Nov 2016 06:49:54 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id pw4si19058238pac.166.2016.11.05.06.49.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Nov 2016 06:49:53 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id y68so10903516pfb.1
        for <linux-mm@kvack.org>; Sat, 05 Nov 2016 06:49:53 -0700 (PDT)
Date: Sat, 5 Nov 2016 14:49:46 +0100
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH/RFC] z3fold: use per-page read/write lock
Message-Id: <20161105144946.3b4be0ee799ae61a82e1d918@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>


Most of z3fold operations are in-page, such as modifying z3fold
page header or moving z3fold objects within a page. Taking
per-pool spinlock to protect per-page objects is therefore
suboptimal, and the idea of having a per-page spinlock (or rwlock)
has been around for some time. However, adding one directly to the
z3fold header makes the latter quite big on some systems so that
it won't fit in a signle chunk.

This patch implements custom per-page read/write locking mechanism
which is lightweight enough to fit into the z3fold header.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/z3fold.c | 148 ++++++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 105 insertions(+), 43 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index fea6791..3e30930 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -23,6 +23,7 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/atomic.h>
+#include <linux/bitops.h>
 #include <linux/list.h>
 #include <linux/mm.h>
 #include <linux/module.h>
@@ -98,6 +99,7 @@ enum buddy {
  * struct z3fold_header - z3fold page metadata occupying the first chunk of each
  *			z3fold page, except for HEADLESS pages
  * @buddy:	links the z3fold page into the relevant list in the pool
+ * @page_lock:		per-page atomic variable used for locking
  * @first_chunks:	the size of the first buddy in chunks, 0 if free
  * @middle_chunks:	the size of the middle buddy in chunks, 0 if free
  * @last_chunks:	the size of the last buddy in chunks, 0 if free
@@ -105,6 +107,7 @@ enum buddy {
  */
 struct z3fold_header {
 	struct list_head buddy;
+	atomic_t page_lock;
 	unsigned short first_chunks;
 	unsigned short middle_chunks;
 	unsigned short last_chunks;
@@ -144,6 +147,7 @@ static struct z3fold_header *init_z3fold_page(struct page *page)
 	clear_bit(PAGE_HEADLESS, &page->private);
 	clear_bit(MIDDLE_CHUNK_MAPPED, &page->private);
 
+	atomic_set(&zhdr->page_lock, 0);
 	zhdr->first_chunks = 0;
 	zhdr->middle_chunks = 0;
 	zhdr->last_chunks = 0;
@@ -159,6 +163,39 @@ static void free_z3fold_page(struct z3fold_header *zhdr)
 	__free_page(virt_to_page(zhdr));
 }
 
+#define Z3FOLD_PAGE_WRITE_FLAG	(1 << 15)
+
+/* Read-lock a z3fold page */
+static void z3fold_page_rlock(struct z3fold_header *zhdr)
+{
+	while (!atomic_add_unless(&zhdr->page_lock, 1, Z3FOLD_PAGE_WRITE_FLAG))
+		cpu_relax();
+	smp_mb();
+}
+
+/* Read-unlock a z3fold page */
+static void z3fold_page_runlock(struct z3fold_header *zhdr)
+{
+	atomic_dec(&zhdr->page_lock);
+	smp_mb();
+}
+
+/* Write-lock a z3fold page */
+static void z3fold_page_wlock(struct z3fold_header *zhdr)
+{
+	while (atomic_cmpxchg(&zhdr->page_lock, 0, Z3FOLD_PAGE_WRITE_FLAG) != 0)
+		cpu_relax();
+	smp_mb();
+}
+
+/* Write-unlock a z3fold page */
+static void z3fold_page_wunlock(struct z3fold_header *zhdr)
+{
+	atomic_sub(Z3FOLD_PAGE_WRITE_FLAG, &zhdr->page_lock);
+	smp_mb();
+}
+
+
 /*
  * Encodes the handle of a particular buddy within a z3fold page
  * Pool lock should be held as this function accesses first_num
@@ -343,50 +380,60 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
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
+			list_del(&zhdr->buddy);
+			spin_unlock(&pool->lock);
+
+			page = virt_to_page(zhdr);
+			z3fold_page_wlock(zhdr);
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
+				z3fold_page_wunlock(zhdr);
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
+	z3fold_page_wlock(zhdr);
 
 found:
 	if (bud == FIRST)
@@ -398,6 +445,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 		zhdr->start_middle = zhdr->first_chunks + 1;
 	}
 
+	spin_lock(&pool->lock);
 	if (zhdr->first_chunks == 0 || zhdr->last_chunks == 0 ||
 			zhdr->middle_chunks == 0) {
 		/* Add to unbuddied list */
@@ -417,6 +465,8 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 
 	*handle = encode_handle(zhdr, bud);
 	spin_unlock(&pool->lock);
+	if (bud != HEADLESS)
+		z3fold_page_wunlock(zhdr);
 
 	return 0;
 }
@@ -437,9 +487,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 	int freechunks;
 	struct page *page;
 	enum buddy bud;
-	bool is_unbuddied = false;
 
-	spin_lock(&pool->lock);
 	zhdr = handle_to_z3fold_header(handle);
 	page = virt_to_page(zhdr);
 
@@ -447,10 +495,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 		/* HEADLESS page stored */
 		bud = HEADLESS;
 	} else {
-		is_unbuddied = zhdr->first_chunks == 0 ||
-				zhdr->middle_chunks == 0 ||
-				zhdr->last_chunks == 0;
-
+		z3fold_page_wlock(zhdr);
 		bud = handle_to_buddy(handle);
 
 		switch (bud) {
@@ -467,37 +512,47 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 		default:
 			pr_err("%s: unknown bud %d\n", __func__, bud);
 			WARN_ON(1);
-			spin_unlock(&pool->lock);
+			z3fold_page_wunlock(zhdr);
 			return;
 		}
 	}
 
 	if (test_bit(UNDER_RECLAIM, &page->private)) {
 		/* z3fold page is under reclaim, reclaim will free */
-		spin_unlock(&pool->lock);
+		if (bud != HEADLESS)
+			z3fold_page_wunlock(zhdr);
 		return;
 	}
 
 	/* Remove from existing buddy list */
-	if (bud != HEADLESS)
+	if (bud != HEADLESS) {
+		spin_lock(&pool->lock);
 		list_del(&zhdr->buddy);
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
+			z3fold_page_wunlock(zhdr);
 		free_z3fold_page(zhdr);
 		atomic64_dec(&pool->pages_nr);
 	} else {
 		z3fold_compact_page(zhdr);
 		/* Add to the unbuddied list */
+		spin_lock(&pool->lock);
 		freechunks = num_free_chunks(zhdr);
 		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
+		spin_unlock(&pool->lock);
+		z3fold_page_wunlock(zhdr);
 	}
 
-	spin_unlock(&pool->lock);
 }
 
 /**
@@ -558,6 +613,8 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 		zhdr = page_address(page);
 		if (!test_bit(PAGE_HEADLESS, &page->private)) {
 			list_del(&zhdr->buddy);
+			spin_unlock(&pool->lock);
+			z3fold_page_rlock(zhdr);
 
 			/*
 			 * We need encode the handles before unlocking, since
@@ -573,13 +630,13 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 				middle_handle = encode_handle(zhdr, MIDDLE);
 			if (zhdr->last_chunks)
 				last_handle = encode_handle(zhdr, LAST);
+			z3fold_page_runlock(zhdr);
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
@@ -597,7 +654,8 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 				goto next;
 		}
 next:
-		spin_lock(&pool->lock);
+		if (!test_bit(PAGE_HEADLESS, &page->private))
+			z3fold_page_wlock(zhdr);
 		clear_bit(UNDER_RECLAIM, &page->private);
 		if ((test_bit(PAGE_HEADLESS, &page->private) && ret == 0) ||
 		    (zhdr->first_chunks == 0 && zhdr->last_chunks == 0 &&
@@ -607,19 +665,22 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 			 * return success.
 			 */
 			clear_bit(PAGE_HEADLESS, &page->private);
+			if (!test_bit(PAGE_HEADLESS, &page->private))
+				z3fold_page_wunlock(zhdr);
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
@@ -630,6 +691,8 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 		list_add(&page->lru, &pool->lru);
 	}
 	spin_unlock(&pool->lock);
+	if (!test_bit(PAGE_HEADLESS, &page->private))
+		z3fold_page_wunlock(zhdr);
 	return -EAGAIN;
 }
 
@@ -650,7 +713,6 @@ static void *z3fold_map(struct z3fold_pool *pool, unsigned long handle)
 	void *addr;
 	enum buddy buddy;
 
-	spin_lock(&pool->lock);
 	zhdr = handle_to_z3fold_header(handle);
 	addr = zhdr;
 	page = virt_to_page(zhdr);
@@ -658,6 +720,7 @@ static void *z3fold_map(struct z3fold_pool *pool, unsigned long handle)
 	if (test_bit(PAGE_HEADLESS, &page->private))
 		goto out;
 
+	z3fold_page_rlock(zhdr);
 	buddy = handle_to_buddy(handle);
 	switch (buddy) {
 	case FIRST:
@@ -676,8 +739,9 @@ static void *z3fold_map(struct z3fold_pool *pool, unsigned long handle)
 		addr = NULL;
 		break;
 	}
+
+	z3fold_page_runlock(zhdr);
 out:
-	spin_unlock(&pool->lock);
 	return addr;
 }
 
@@ -692,19 +756,17 @@ static void z3fold_unmap(struct z3fold_pool *pool, unsigned long handle)
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
 
+	z3fold_page_rlock(zhdr);
 	buddy = handle_to_buddy(handle);
 	if (buddy == MIDDLE)
 		clear_bit(MIDDLE_CHUNK_MAPPED, &page->private);
-	spin_unlock(&pool->lock);
+	z3fold_page_runlock(zhdr);
 }
 
 /**
-- 
2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
