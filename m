Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 44D2C6B0213
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 14:24:16 -0400 (EDT)
Received: by mail-pz0-f41.google.com with SMTP id p5so3292851dak.14
        for <linux-mm@kvack.org>; Fri, 22 Jun 2012 11:24:15 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 3/3] slub: release a lock if freeing object with a lock is failed in __slab_free()
Date: Sat, 23 Jun 2012 03:22:39 +0900
Message-Id: <1340389359-2407-3-git-send-email-js1304@gmail.com>
In-Reply-To: <1340389359-2407-1-git-send-email-js1304@gmail.com>
References: <yes>
 <1340389359-2407-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

In some case of __slab_free(), we need a lock for manipulating partial list.
If freeing object with a lock is failed, a lock doesn't needed anymore
for some reasons.

Case 1. prior is NULL, kmem_cache_debug(s) is true

In this case, another free is occured before our free is succeed.
When slab is full(prior is NULL), only possible operation is slab_free().
So in this case, we guess another free is occured.
It may make a slab frozen, so lock is not needed anymore.

Case 2. inuse is NULL

In this case, acquire_slab() is occured before out free is succeed.
We have a last object for slab, so other operation for this slab is
not possible except acquire_slab().
Acquire_slab() makes a slab frozen, so lock is not needed anymore.

Above two reason explain why we don't need a lock
when freeing object with a lock is failed.

So, when cmpxchg_double_slab() is failed, releasing a lock is more suitable.
This may reduce lock contention.

This also make logic somehow simple that 'was_frozen with a lock' case
is never occured. Remove it.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/mm/slub.c b/mm/slub.c
index 531d8ed..3e0b9db 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2438,7 +2438,6 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 	void *prior;
 	void **object = (void *)x;
 	int was_frozen;
-	int inuse;
 	struct page new;
 	unsigned long counters;
 	struct kmem_cache_node *n = NULL;
@@ -2450,13 +2449,17 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 		return;
 
 	do {
+		if (unlikely(n)) {
+			spin_unlock_irqrestore(&n->list_lock, flags);
+			n = NULL;
+		}
 		prior = page->freelist;
 		counters = page->counters;
 		set_freepointer(s, object, prior);
 		new.counters = counters;
 		was_frozen = new.frozen;
 		new.inuse--;
-		if ((!new.inuse || !prior) && !was_frozen && !n) {
+		if ((!new.inuse || !prior) && !was_frozen) {
 
 			if (!kmem_cache_debug(s) && !prior)
 
@@ -2481,7 +2484,6 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 
 			}
 		}
-		inuse = new.inuse;
 
 	} while (!cmpxchg_double_slab(s, page,
 		prior, counters,
@@ -2507,25 +2509,17 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
                 return;
         }
 
+	if (unlikely(!new.inuse && n->nr_partial > s->min_partial))
+		goto slab_empty;
+
 	/*
-	 * was_frozen may have been set after we acquired the list_lock in
-	 * an earlier loop. So we need to check it here again.
+	 * Objects left in the slab. If it was not on the partial list before
+	 * then add it.
 	 */
-	if (was_frozen)
-		stat(s, FREE_FROZEN);
-	else {
-		if (unlikely(!inuse && n->nr_partial > s->min_partial))
-                        goto slab_empty;
-
-		/*
-		 * Objects left in the slab. If it was not on the partial list before
-		 * then add it.
-		 */
-		if (unlikely(!prior)) {
-			remove_full(s, page);
-			add_partial(n, page, DEACTIVATE_TO_TAIL);
-			stat(s, FREE_ADD_PARTIAL);
-		}
+	if (kmem_cache_debug(s) && unlikely(!prior)) {
+		remove_full(s, page);
+		add_partial(n, page, DEACTIVATE_TO_TAIL);
+		stat(s, FREE_ADD_PARTIAL);
 	}
 	spin_unlock_irqrestore(&n->list_lock, flags);
 	return;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
