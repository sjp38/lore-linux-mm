Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DB5256B0038
	for <linux-mm@kvack.org>; Sat, 15 Oct 2016 07:58:17 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e6so136521562pfk.2
        for <linux-mm@kvack.org>; Sat, 15 Oct 2016 04:58:17 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id l7si18696353paz.154.2016.10.15.04.58.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Oct 2016 04:58:17 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id fn2so6274506pad.1
        for <linux-mm@kvack.org>; Sat, 15 Oct 2016 04:58:17 -0700 (PDT)
Date: Sat, 15 Oct 2016 13:58:06 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH v5 1/3] z3fold: make counters atomic
Message-Id: <20161015135806.725268575b1029381d3591d2@gmail.com>
In-Reply-To: <20161015135632.541010b55bec496e2cae056e@gmail.com>
References: <20161015135632.541010b55bec496e2cae056e@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>

This patch converts pages_nr per-pool counter to atomic64_t.
It also introduces a new counter, unbuddied_nr, which is also
atomic64_t, to track the number of unbuddied (shrinkable) pages,
as a step to prepare for z3fold shrinker implementation.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/z3fold.c | 33 +++++++++++++++++++++++++--------
 1 file changed, 25 insertions(+), 8 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 8f9e89c..5197d7b 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -69,6 +69,7 @@ struct z3fold_ops {
  * @lru:	list tracking the z3fold pages in LRU order by most recently
  *		added buddy.
  * @pages_nr:	number of z3fold pages in the pool.
+ * @unbuddied_nr:	number of unbuddied z3fold pages in the pool.
  * @ops:	pointer to a structure of user defined operations specified at
  *		pool creation time.
  *
@@ -80,7 +81,8 @@ struct z3fold_pool {
 	struct list_head unbuddied[NCHUNKS];
 	struct list_head buddied;
 	struct list_head lru;
-	u64 pages_nr;
+	atomic64_t pages_nr;
+	atomic64_t unbuddied_nr;
 	const struct z3fold_ops *ops;
 	struct zpool *zpool;
 	const struct zpool_ops *zpool_ops;
@@ -234,7 +236,8 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
 		INIT_LIST_HEAD(&pool->unbuddied[i]);
 	INIT_LIST_HEAD(&pool->buddied);
 	INIT_LIST_HEAD(&pool->lru);
-	pool->pages_nr = 0;
+	atomic64_set(&pool->pages_nr, 0);
+	atomic64_set(&pool->unbuddied_nr, 0);
 	pool->ops = ops;
 	return pool;
 }
@@ -334,6 +337,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 					continue;
 				}
 				list_del(&zhdr->buddy);
+				atomic64_dec(&pool->unbuddied_nr);
 				goto found;
 			}
 		}
@@ -346,7 +350,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 	if (!page)
 		return -ENOMEM;
 	spin_lock(&pool->lock);
-	pool->pages_nr++;
+	atomic64_inc(&pool->pages_nr);
 	zhdr = init_z3fold_page(page);
 
 	if (bud == HEADLESS) {
@@ -369,6 +373,7 @@ found:
 		/* Add to unbuddied list */
 		freechunks = num_free_chunks(zhdr);
 		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
+		atomic64_inc(&pool->unbuddied_nr);
 	} else {
 		/* Add to buddied list */
 		list_add(&zhdr->buddy, &pool->buddied);
@@ -412,6 +417,11 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 		/* HEADLESS page stored */
 		bud = HEADLESS;
 	} else {
+		if (zhdr->first_chunks == 0 ||
+		    zhdr->middle_chunks == 0 ||
+		    zhdr->last_chunks == 0)
+			atomic64_dec(&pool->unbuddied_nr);
+
 		bud = handle_to_buddy(handle);
 
 		switch (bud) {
@@ -429,6 +439,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 			pr_err("%s: unknown bud %d\n", __func__, bud);
 			WARN_ON(1);
 			spin_unlock(&pool->lock);
+			atomic64_inc(&pool->unbuddied_nr);
 			return;
 		}
 	}
@@ -451,12 +462,13 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 		list_del(&page->lru);
 		clear_bit(PAGE_HEADLESS, &page->private);
 		free_z3fold_page(zhdr);
-		pool->pages_nr--;
+		atomic64_dec(&pool->pages_nr);
 	} else {
 		z3fold_compact_page(zhdr);
 		/* Add to the unbuddied list */
 		freechunks = num_free_chunks(zhdr);
 		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
+		atomic64_inc(&pool->unbuddied_nr);
 	}
 
 	spin_unlock(&pool->lock);
@@ -520,6 +532,11 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 		zhdr = page_address(page);
 		if (!test_bit(PAGE_HEADLESS, &page->private)) {
 			list_del(&zhdr->buddy);
+			if (zhdr->first_chunks == 0 ||
+			    zhdr->middle_chunks == 0 ||
+			    zhdr->last_chunks == 0)
+				atomic64_dec(&pool->unbuddied_nr);
+
 			/*
 			 * We need encode the handles before unlocking, since
 			 * we can race with free that will set
@@ -569,7 +586,7 @@ next:
 			 */
 			clear_bit(PAGE_HEADLESS, &page->private);
 			free_z3fold_page(zhdr);
-			pool->pages_nr--;
+			atomic64_dec(&pool->pages_nr);
 			spin_unlock(&pool->lock);
 			return 0;
 		}  else if (!test_bit(PAGE_HEADLESS, &page->private)) {
@@ -584,6 +601,7 @@ next:
 				freechunks = num_free_chunks(zhdr);
 				list_add(&zhdr->buddy,
 					 &pool->unbuddied[freechunks]);
+				atomic64_inc(&pool->unbuddied_nr);
 			}
 		}
 
@@ -672,12 +690,11 @@ static void z3fold_unmap(struct z3fold_pool *pool, unsigned long handle)
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
