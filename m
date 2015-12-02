Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id 96ABA6B0254
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 10:47:14 -0500 (EST)
Received: by oies6 with SMTP id s6so27224573oie.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 07:47:14 -0800 (PST)
Received: from m50-135.163.com (m50-135.163.com. [123.125.50.135])
        by mx.google.com with ESMTP id b7si3815759oig.100.2015.12.02.07.47.12
        for <linux-mm@kvack.org>;
        Wed, 02 Dec 2015 07:47:13 -0800 (PST)
From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 3/3] mm/slab: use list_{empty_careful,last_entry} in drain_freelist
Date: Wed,  2 Dec 2015 23:46:13 +0800
Message-Id: <670c0018e0e4f44d6e788423b35e2c32ccf6c1e2.1449070964.git.geliangtang@163.com>
In-Reply-To: <7e551749f5a50cef15a33320d6d33b9d0b0986bd.1449070964.git.geliangtang@163.com>
References: <7e551749f5a50cef15a33320d6d33b9d0b0986bd.1449070964.git.geliangtang@163.com>
In-Reply-To: <22e322cb81d99e70674e9f833c5b6aa4e87714c6.1449070964.git.geliangtang@163.com>
References: <7e551749f5a50cef15a33320d6d33b9d0b0986bd.1449070964.git.geliangtang@163.com> <22e322cb81d99e70674e9f833c5b6aa4e87714c6.1449070964.git.geliangtang@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Geliang Tang <geliangtang@163.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

To simplify the code, use list_empty_careful instead of list_empty.
To make the intention clearer, use list_last_entry instead of list_entry.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 mm/slab.c | 12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 5d5aa3b..1a7d91c 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2362,21 +2362,14 @@ static void drain_cpu_caches(struct kmem_cache *cachep)
 static int drain_freelist(struct kmem_cache *cache,
 			struct kmem_cache_node *n, int tofree)
 {
-	struct list_head *p;
 	int nr_freed;
 	struct page *page;
 
 	nr_freed = 0;
-	while (nr_freed < tofree && !list_empty(&n->slabs_free)) {
+	while (nr_freed < tofree && !list_empty_careful(&n->slabs_free)) {
 
 		spin_lock_irq(&n->list_lock);
-		p = n->slabs_free.prev;
-		if (p == &n->slabs_free) {
-			spin_unlock_irq(&n->list_lock);
-			goto out;
-		}
-
-		page = list_entry(p, struct page, lru);
+		page = list_last_entry(&n->slabs_free, struct page, lru);
 #if DEBUG
 		BUG_ON(page->active);
 #endif
@@ -2390,7 +2383,6 @@ static int drain_freelist(struct kmem_cache *cache,
 		slab_destroy(cache, page);
 		nr_freed++;
 	}
-out:
 	return nr_freed;
 }
 
-- 
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
