Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 77A896B0007
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 03:03:41 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n19-v6so1100260pff.8
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 00:03:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x17-v6sor1234097pfh.33.2018.06.21.00.03.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Jun 2018 00:03:40 -0700 (PDT)
From: Jia-Ju Bai <baijiaju1990@gmail.com>
Subject: [PATCH] mm: mempool: Remove unused argument in kasan_unpoison_element() and remove_element()
Date: Thu, 21 Jun 2018 15:03:32 +0800
Message-Id: <20180621070332.16633-1-baijiaju1990@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, jthumshirn@suse.de, cl@linux.com, kstewart@linuxfoundation.org, pombredanne@nexb.com, gregkh@linuxfoundation.org, dvyukov@google.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jia-Ju Bai <baijiaju1990@gmail.com>

The argument "gfp_t flags" is not used in kasan_unpoison_element() 
and remove_element(), so remove it.

Signed-off-by: Jia-Ju Bai <baijiaju1990@gmail.com>
---
 mm/mempool.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/mempool.c b/mm/mempool.c
index 5c9dce34719b..3076ab3f7bc4 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -111,7 +111,7 @@ static __always_inline void kasan_poison_element(mempool_t *pool, void *element)
 		kasan_free_pages(element, (unsigned long)pool->pool_data);
 }
 
-static void kasan_unpoison_element(mempool_t *pool, void *element, gfp_t flags)
+static void kasan_unpoison_element(mempool_t *pool, void *element)
 {
 	if (pool->alloc == mempool_alloc_slab || pool->alloc == mempool_kmalloc)
 		kasan_unpoison_slab(element);
@@ -127,12 +127,12 @@ static __always_inline void add_element(mempool_t *pool, void *element)
 	pool->elements[pool->curr_nr++] = element;
 }
 
-static void *remove_element(mempool_t *pool, gfp_t flags)
+static void *remove_element(mempool_t *pool)
 {
 	void *element = pool->elements[--pool->curr_nr];
 
 	BUG_ON(pool->curr_nr < 0);
-	kasan_unpoison_element(pool, element, flags);
+	kasan_unpoison_element(pool, element);
 	check_element(pool, element);
 	return element;
 }
@@ -151,7 +151,7 @@ void mempool_destroy(mempool_t *pool)
 		return;
 
 	while (pool->curr_nr) {
-		void *element = remove_element(pool, GFP_KERNEL);
+		void *element = remove_element(pool);
 		pool->free(element, pool->pool_data);
 	}
 	kfree(pool->elements);
@@ -247,7 +247,7 @@ int mempool_resize(mempool_t *pool, int new_min_nr)
 	spin_lock_irqsave(&pool->lock, flags);
 	if (new_min_nr <= pool->min_nr) {
 		while (new_min_nr < pool->curr_nr) {
-			element = remove_element(pool, GFP_KERNEL);
+			element = remove_element(pool);
 			spin_unlock_irqrestore(&pool->lock, flags);
 			pool->free(element, pool->pool_data);
 			spin_lock_irqsave(&pool->lock, flags);
@@ -333,7 +333,7 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 
 	spin_lock_irqsave(&pool->lock, flags);
 	if (likely(pool->curr_nr)) {
-		element = remove_element(pool, gfp_temp);
+		element = remove_element(pool);
 		spin_unlock_irqrestore(&pool->lock, flags);
 		/* paired with rmb in mempool_free(), read comment there */
 		smp_wmb();
-- 
2.17.0
