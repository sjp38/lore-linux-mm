Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 721026B004F
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 16:46:49 -0400 (EDT)
From: Sage Weil <sage@newdream.net>
Subject: [PATCH] mempool: launder reused items from kzalloc pool
Date: Tue, 28 Jul 2009 13:46:07 -0700
Message-Id: <1248813967-27448-1-git-send-email-sage@newdream.net>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Sage Weil <sage@newdream.net>, Neil Brown <neilb@suse.de>, linux-raid@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

The kzalloc pool created by mempool_create_kzalloc_pool() only zeros items
the first time they are allocated; it doesn't re-zero freed items that are
returned to the pool.  This only comes up when the pool is used in the
first place (when memory is very low).

Fix this by adding a mempool_launder_t method that is called before
returning items to the pool, and set it in mempool_create_kzalloc_pool.
This preserves the use of __GFP_ZERO in the common case where the pool
isn't touched at all.

There are currently two in-tree users of mempool_create_kzalloc_pool:
	drivers/md/multipath.c
	drivers/scsi/ibmvscsi/ibmvfc.c
The first appears to be affected by this bug.  The second manually zeros
each allocation, and can stop doing so after this is fixed.

Alternatively, mempool_create_kzalloc_pool() could be removed entirely and
the callers could zero allocations themselves.

CC: Neil Brown <neilb@suse.de>
CC: <linux-raid@vger.kernel.org>
CC: <linux-kernel@vger.kernel.org>
CC: <linux-mm@kvack.org>
CC: <stable@kernel.org>
Signed-off-by: Sage Weil <sage@newdream.net>
---
 include/linux/mempool.h |   10 ++++++++--
 mm/mempool.c            |    9 +++++++++
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/include/linux/mempool.h b/include/linux/mempool.h
index 9be484d..889c7e1 100644
--- a/include/linux/mempool.h
+++ b/include/linux/mempool.h
@@ -10,6 +10,7 @@ struct kmem_cache;
 
 typedef void * (mempool_alloc_t)(gfp_t gfp_mask, void *pool_data);
 typedef void (mempool_free_t)(void *element, void *pool_data);
+typedef void (mempool_launder_t)(void *element, void *pool_data);
 
 typedef struct mempool_s {
 	spinlock_t lock;
@@ -20,6 +21,7 @@ typedef struct mempool_s {
 	void *pool_data;
 	mempool_alloc_t *alloc;
 	mempool_free_t *free;
+	mempool_launder_t *launder;
 	wait_queue_head_t wait;
 } mempool_t;
 
@@ -52,6 +54,7 @@ mempool_create_slab_pool(int min_nr, struct kmem_cache *kc)
  */
 void *mempool_kmalloc(gfp_t gfp_mask, void *pool_data);
 void *mempool_kzalloc(gfp_t gfp_mask, void *pool_data);
+void mempool_rezero(void *element, void *pool_data);
 void mempool_kfree(void *element, void *pool_data);
 static inline mempool_t *mempool_create_kmalloc_pool(int min_nr, size_t size)
 {
@@ -60,8 +63,11 @@ static inline mempool_t *mempool_create_kmalloc_pool(int min_nr, size_t size)
 }
 static inline mempool_t *mempool_create_kzalloc_pool(int min_nr, size_t size)
 {
-	return mempool_create(min_nr, mempool_kzalloc, mempool_kfree,
-			      (void *) size);
+	mempool_t *pool = mempool_create(min_nr, mempool_kzalloc, mempool_kfree,
+					 (void *) size);
+	if (pool)
+		pool->launder = mempool_rezero;
+	return pool;
 }
 
 /*
diff --git a/mm/mempool.c b/mm/mempool.c
index a46eb1b..6bb3056 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -269,6 +269,8 @@ void mempool_free(void *element, mempool_t *pool)
 	if (pool->curr_nr < pool->min_nr) {
 		spin_lock_irqsave(&pool->lock, flags);
 		if (pool->curr_nr < pool->min_nr) {
+			if (pool->launder)
+				pool->launder(element, pool->pool_data);
 			add_element(pool, element);
 			spin_unlock_irqrestore(&pool->lock, flags);
 			wake_up(&pool->wait);
@@ -315,6 +317,13 @@ void *mempool_kzalloc(gfp_t gfp_mask, void *pool_data)
 }
 EXPORT_SYMBOL(mempool_kzalloc);
 
+void mempool_rezero(void *element, void *pool_data)
+{
+	size_t size = (size_t) pool_data;
+	memset(element, 0, size);
+}
+EXPORT_SYMBOL(mempool_rezero);
+
 void mempool_kfree(void *element, void *pool_data)
 {
 	kfree(element);
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
