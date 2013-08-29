Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id B1F856B0033
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 16:11:25 -0400 (EDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/6] slab/block: Add and use kmem_cache_zalloc_node
Date: Thu, 29 Aug 2013 13:11:05 -0700
Message-Id: <35769f9779144ace313671235f6508ba683e752b.1377806578.git.joe@perches.com>
In-Reply-To: <cover.1377806578.git.joe@perches.com>
References: <cover.1377806578.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Jens Axboe <axboe@kernel.dk>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

Create and use kmem_cache_zalloc_node utility to be
acompatible style with all the zalloc equivalents
for kmem_cache_zalloc.

Reduce the uses of __GFP_ZERO.

Signed-off-by: Joe Perches <joe@perches.com>
---
 block/blk-core.c     |  3 +--
 block/blk-ioc.c      |  6 ++----
 block/cfq-iosched.c  | 10 ++++------
 include/linux/slab.h |  5 +++++
 4 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index 3182734..eb7cad2 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -591,8 +591,7 @@ struct request_queue *blk_alloc_queue_node(gfp_t gfp_mask, int node_id)
 	struct request_queue *q;
 	int err;
 
-	q = kmem_cache_alloc_node(blk_requestq_cachep,
-				gfp_mask | __GFP_ZERO, node_id);
+	q = kmem_cache_zalloc_node(blk_requestq_cachep, gfp_mask, node_id);
 	if (!q)
 		return NULL;
 
diff --git a/block/blk-ioc.c b/block/blk-ioc.c
index 46cd7bd..3163751 100644
--- a/block/blk-ioc.c
+++ b/block/blk-ioc.c
@@ -237,8 +237,7 @@ int create_task_io_context(struct task_struct *task, gfp_t gfp_flags, int node)
 	struct io_context *ioc;
 	int ret;
 
-	ioc = kmem_cache_alloc_node(iocontext_cachep, gfp_flags | __GFP_ZERO,
-				    node);
+	ioc = kmem_cache_zalloc_node(iocontext_cachep, gfp_flags, node);
 	if (unlikely(!ioc))
 		return -ENOMEM;
 
@@ -362,8 +361,7 @@ struct io_cq *ioc_create_icq(struct io_context *ioc, struct request_queue *q,
 	struct io_cq *icq;
 
 	/* allocate stuff */
-	icq = kmem_cache_alloc_node(et->icq_cache, gfp_mask | __GFP_ZERO,
-				    q->node);
+	icq = kmem_cache_zalloc_node(et->icq_cache, gfp_mask, q->node);
 	if (!icq)
 		return NULL;
 
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index dabb9d0..42a52d5 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -3584,18 +3584,16 @@ retry:
 		} else if (gfp_mask & __GFP_WAIT) {
 			rcu_read_unlock();
 			spin_unlock_irq(cfqd->queue->queue_lock);
-			new_cfqq = kmem_cache_alloc_node(cfq_pool,
-					gfp_mask | __GFP_ZERO,
-					cfqd->queue->node);
+			new_cfqq = kmem_cache_zalloc_node(cfq_pool, gfp_mask,
+							  cfqd->queue->node);
 			spin_lock_irq(cfqd->queue->queue_lock);
 			if (new_cfqq)
 				goto retry;
 			else
 				return &cfqd->oom_cfqq;
 		} else {
-			cfqq = kmem_cache_alloc_node(cfq_pool,
-					gfp_mask | __GFP_ZERO,
-					cfqd->queue->node);
+			cfqq = kmem_cache_zalloc_node(cfq_pool, gfp_mask,
+						      cfqd->queue->node);
 		}
 
 		if (cfqq) {
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 6c5cc0e..48b7484 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -536,6 +536,11 @@ static inline void *kmem_cache_zalloc(struct kmem_cache *k, gfp_t flags)
 	return kmem_cache_alloc(k, flags | __GFP_ZERO);
 }
 
+static inline void *kmem_cache_zalloc_node(struct kmem_cache *k, gfp_t flags,
+					   int node)
+{
+	return kmem_cache_alloc_node(k, flags | __GFP_ZERO, node);
+}
 /**
  * kzalloc - allocate memory. The memory is set to zero.
  * @size: how many bytes of memory are required.
-- 
1.8.1.2.459.gbcd45b4.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
