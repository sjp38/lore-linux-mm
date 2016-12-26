Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id C62996B0038
	for <linux-mm@kvack.org>; Sun, 25 Dec 2016 19:33:32 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id x140so30978911lfa.2
        for <linux-mm@kvack.org>; Sun, 25 Dec 2016 16:33:32 -0800 (PST)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id a141si23812204lfa.115.2016.12.25.16.33.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Dec 2016 16:33:31 -0800 (PST)
Received: by mail-lf0-x243.google.com with SMTP id y21so24284574lfa.0
        for <linux-mm@kvack.org>; Sun, 25 Dec 2016 16:33:31 -0800 (PST)
Date: Mon, 26 Dec 2016 01:33:22 +0100
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH/RESEND 1/5] mm/z3fold.c: make pages_nr atomic
Message-Id: <20161226013322.5dddf36ff0de51e44ba6f4a7@gmail.com>
In-Reply-To: <20161226013016.968004f3db024ef2111dc458@gmail.com>
References: <20161226013016.968004f3db024ef2111dc458@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>

Convert pages_nr per-pool counter to atomic64_t so that we won't have
to care about locking for reading/updating it.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/z3fold.c | 20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 207e5dd..2273789 100644
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
@@ -238,7 +238,7 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
 		INIT_LIST_HEAD(&pool->unbuddied[i]);
 	INIT_LIST_HEAD(&pool->buddied);
 	INIT_LIST_HEAD(&pool->lru);
-	pool->pages_nr = 0;
+	atomic64_set(&pool->pages_nr, 0);
 	pool->ops = ops;
 	return pool;
 }
@@ -350,7 +350,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 	if (!page)
 		return -ENOMEM;
 	spin_lock(&pool->lock);
-	pool->pages_nr++;
+	atomic64_inc(&pool->pages_nr);
 	zhdr = init_z3fold_page(page);
 
 	if (bud == HEADLESS) {
@@ -443,10 +443,9 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
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
@@ -455,7 +454,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 		list_del(&page->lru);
 		clear_bit(PAGE_HEADLESS, &page->private);
 		free_z3fold_page(zhdr);
-		pool->pages_nr--;
+		atomic64_dec(&pool->pages_nr);
 	} else {
 		z3fold_compact_page(zhdr);
 		/* Add to the unbuddied list */
@@ -573,7 +572,7 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 			 */
 			clear_bit(PAGE_HEADLESS, &page->private);
 			free_z3fold_page(zhdr);
-			pool->pages_nr--;
+			atomic64_dec(&pool->pages_nr);
 			spin_unlock(&pool->lock);
 			return 0;
 		}  else if (!test_bit(PAGE_HEADLESS, &page->private)) {
@@ -676,12 +675,11 @@ static void z3fold_unmap(struct z3fold_pool *pool, unsigned long handle)
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
