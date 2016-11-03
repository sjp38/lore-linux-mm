Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1578028025A
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 17:01:13 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id r13so28025252pag.1
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 14:01:13 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id ql7si3570934pac.260.2016.11.03.14.01.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Nov 2016 14:01:11 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id n85so5793649pfi.3
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 14:01:11 -0700 (PDT)
Date: Thu, 3 Nov 2016 22:00:58 +0100
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH] z3fold: make pages_nr atomic
Message-Id: <20161103220058.3017148c790b352c0ec521d4@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>

This patch converts pages_nr per-pool counter to atomic64_t.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/z3fold.c | 26 +++++++++++++++-----------
 1 file changed, 15 insertions(+), 11 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 8f9e89c..4d02280 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -80,7 +80,7 @@ struct z3fold_pool {
 	struct list_head unbuddied[NCHUNKS];
 	struct list_head buddied;
 	struct list_head lru;
-	u64 pages_nr;
+	atomic64_t pages_nr;
 	const struct z3fold_ops *ops;
 	struct zpool *zpool;
 	const struct zpool_ops *zpool_ops;
@@ -234,7 +234,7 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
 		INIT_LIST_HEAD(&pool->unbuddied[i]);
 	INIT_LIST_HEAD(&pool->buddied);
 	INIT_LIST_HEAD(&pool->lru);
-	pool->pages_nr = 0;
+	atomic64_set(&pool->pages_nr, 0);
 	pool->ops = ops;
 	return pool;
 }
@@ -346,7 +346,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 	if (!page)
 		return -ENOMEM;
 	spin_lock(&pool->lock);
-	pool->pages_nr++;
+	atomic64_inc(&pool->pages_nr);
 	zhdr = init_z3fold_page(page);
 
 	if (bud == HEADLESS) {
@@ -439,10 +439,9 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 		return;
 	}
 
-	if (bud != HEADLESS) {
-		/* Remove from existing buddy list */
+	/* Remove from existing buddy list */
+	if (bud != HEADLESS)
 		list_del(&zhdr->buddy);
-	}
 
 	if (bud == HEADLESS ||
 	    (zhdr->first_chunks == 0 && zhdr->middle_chunks == 0 &&
@@ -451,7 +451,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 		list_del(&page->lru);
 		clear_bit(PAGE_HEADLESS, &page->private);
 		free_z3fold_page(zhdr);
-		pool->pages_nr--;
+		atomic64_dec(&pool->pages_nr);
 	} else {
 		z3fold_compact_page(zhdr);
 		/* Add to the unbuddied list */
@@ -569,7 +569,7 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 			 */
 			clear_bit(PAGE_HEADLESS, &page->private);
 			free_z3fold_page(zhdr);
-			pool->pages_nr--;
+			atomic64_dec(&pool->pages_nr);
 			spin_unlock(&pool->lock);
 			return 0;
 		}  else if (!test_bit(PAGE_HEADLESS, &page->private)) {
@@ -672,12 +672,11 @@ static void z3fold_unmap(struct z3fold_pool *pool, unsigned long handle)
  * z3fold_get_pool_size() - gets the z3fold pool size in pages
  * @pool:	pool whose size is being queried
  *
- * Returns: size in pages of the given pool.  The pool lock need not be
- * taken to access pages_nr.
+ * Returns: size in pages of the given pool.
  */
 static u64 z3fold_get_pool_size(struct z3fold_pool *pool)
 {
-	return pool->pages_nr;
+	return atomic64_read(&pool->pages_nr);
 }
 
 /*****************
-- 
2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
