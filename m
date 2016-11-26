Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id EEE5E6B0069
	for <linux-mm@kvack.org>; Sat, 26 Nov 2016 14:21:24 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id o141so37856345lff.7
        for <linux-mm@kvack.org>; Sat, 26 Nov 2016 11:21:24 -0800 (PST)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id y138si23625354lfd.147.2016.11.26.11.21.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Nov 2016 11:21:23 -0800 (PST)
Received: by mail-lf0-x243.google.com with SMTP id p100so5923167lfg.2
        for <linux-mm@kvack.org>; Sat, 26 Nov 2016 11:21:23 -0800 (PST)
Date: Sat, 26 Nov 2016 20:21:21 +0100
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH 2/2] z3fold: fix locking issues
Message-Id: <20161126202121.baba91a6e67858648e5d1d2f@gmail.com>
In-Reply-To: <20161126201534.5d5e338f678b478e7a7b8dc3@gmail.com>
References: <20161126201534.5d5e338f678b478e7a7b8dc3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Dan Carpenter <dan.carpenter@oracle.com>

Commit 570931c ("z3fold: use per-page spinlock") introduced locking
issues in reclaim function reported in [1] and [2]. This patch
addresses these issues, also fixing the check for empty lru list
(it was only checked once, while it should be checked every time
we want to get the last lru entry).

[1] https://lkml.org/lkml/2016/11/25/628
[2] http://www.spinics.net/lists/linux-mm/msg117227.html

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/z3fold.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index efbcfcc..729a2da 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -607,12 +607,15 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
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
 
@@ -671,8 +674,7 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 			 * All buddies are now free, free the z3fold page and
 			 * return success.
 			 */
-			clear_bit(PAGE_HEADLESS, &page->private);
-			if (!test_bit(PAGE_HEADLESS, &page->private))
+			if (!test_and_clear_bit(PAGE_HEADLESS, &page->private))
 				z3fold_page_unlock(zhdr);
 			free_z3fold_page(zhdr);
 			atomic64_dec(&pool->pages_nr);
@@ -684,6 +686,7 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 				/* Full, add to buddied list */
 				spin_lock(&pool->lock);
 				list_add(&zhdr->buddy, &pool->buddied);
+				spin_unlock(&pool->lock);
 			} else {
 				z3fold_compact_page(zhdr);
 				/* add to unbuddied list */
@@ -691,15 +694,18 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
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
 	spin_unlock(&pool->lock);
-	if (!test_bit(PAGE_HEADLESS, &page->private))
-		z3fold_page_unlock(zhdr);
 	return -EAGAIN;
 }
 
-- 
2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
