Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id A512A6B003C
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 04:44:20 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id jt11so523880pbb.24
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 01:44:19 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 06/15] slab: overloading the RCU head over the LRU for RCU free
Date: Wed, 16 Oct 2013 17:44:03 +0900
Message-Id: <1381913052-23875-7-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

With build-time size checking, we can overload the RCU head over the LRU
of struct page to free pages of a slab in rcu context. This really help to
implement to overload the struct slab over the struct page and this
eventually reduce memory usage and cache footprint of the SLAB.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index d9851ee..8b85d8c 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -130,6 +130,9 @@ struct page {
 
 		struct list_head list;	/* slobs list of pages */
 		struct slab *slab_page; /* slab fields */
+		struct rcu_head rcu_head;	/* Used by SLAB
+						 * when destroying via RCU
+						 */
 	};
 
 	/* Remainder is not double word aligned */
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 74f1058..c2bba24 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -53,7 +53,14 @@
  *  }
  *  rcu_read_unlock();
  *
- * See also the comment on struct slab_rcu in mm/slab.c.
+ * This is useful if we need to approach a kernel structure obliquely,
+ * from its address obtained without the usual locking. We can lock
+ * the structure to stabilize it and check it's still at the given address,
+ * only if we can be sure that the memory has not been meanwhile reused
+ * for some other kind of object (which our subsystem's lock might corrupt).
+ *
+ * rcu_read_lock before reading the address, then rcu_read_unlock after
+ * taking the spinlock within the structure expected at that address.
  */
 #define SLAB_DESTROY_BY_RCU	0x00080000UL	/* Defer freeing slabs to RCU */
 #define SLAB_MEM_SPREAD		0x00100000UL	/* Spread some memory over cpuset */
diff --git a/mm/slab.c b/mm/slab.c
index 7e1aabe..84c4ed6 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -189,25 +189,6 @@ typedef unsigned int kmem_bufctl_t;
 #define	SLAB_LIMIT	(((kmem_bufctl_t)(~0U))-3)
 
 /*
- * struct slab_rcu
- *
- * slab_destroy on a SLAB_DESTROY_BY_RCU cache uses this structure to
- * arrange for kmem_freepages to be called via RCU.  This is useful if
- * we need to approach a kernel structure obliquely, from its address
- * obtained without the usual locking.  We can lock the structure to
- * stabilize it and check it's still at the given address, only if we
- * can be sure that the memory has not been meanwhile reused for some
- * other kind of object (which our subsystem's lock might corrupt).
- *
- * rcu_read_lock before reading the address, then rcu_read_unlock after
- * taking the spinlock within the structure expected at that address.
- */
-struct slab_rcu {
-	struct rcu_head head;
-	struct page *page;
-};
-
-/*
  * struct slab
  *
  * Manages the objs in a slab. Placed either at the beginning of mem allocated
@@ -215,14 +196,11 @@ struct slab_rcu {
  * Slabs are chained into three list: fully used, partial, fully free slabs.
  */
 struct slab {
-	union {
-		struct {
-			struct list_head list;
-			void *s_mem;		/* including colour offset */
-			unsigned int inuse;	/* num of objs active in slab */
-			kmem_bufctl_t free;
-		};
-		struct slab_rcu __slab_cover_slab_rcu;
+	struct {
+		struct list_head list;
+		void *s_mem;		/* including colour offset */
+		unsigned int inuse;	/* num of objs active in slab */
+		kmem_bufctl_t free;
 	};
 };
 
@@ -1509,6 +1487,8 @@ void __init kmem_cache_init(void)
 {
 	int i;
 
+	BUILD_BUG_ON(sizeof(((struct page *)NULL)->lru) <
+					sizeof(struct rcu_head));
 	kmem_cache = &kmem_cache_boot;
 	setup_node_pointer(kmem_cache);
 
@@ -1822,12 +1802,13 @@ static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
 
 static void kmem_rcu_free(struct rcu_head *head)
 {
-	struct slab_rcu *slab_rcu = (struct slab_rcu *)head;
-	struct kmem_cache *cachep = slab_rcu->page->slab_cache;
+	struct kmem_cache *cachep;
+	struct page *page;
 
-	kmem_freepages(cachep, slab_rcu->page);
-	if (OFF_SLAB(cachep))
-		kmem_cache_free(cachep->slabp_cache, slab_rcu);
+	page = container_of(head, struct page, rcu_head);
+	cachep = page->slab_cache;
+
+	kmem_freepages(cachep, page);
 }
 
 #if DEBUG
@@ -2048,16 +2029,27 @@ static void slab_destroy(struct kmem_cache *cachep, struct slab *slabp)
 
 	slab_destroy_debugcheck(cachep, slabp);
 	if (unlikely(cachep->flags & SLAB_DESTROY_BY_RCU)) {
-		struct slab_rcu *slab_rcu;
+		struct rcu_head *head;
+
+		/*
+		 * RCU free overloads the RCU head over the LRU.
+		 * slab_page has been overloeaded over the LRU,
+		 * however it is not used from now on so that
+		 * we can use it safely.
+		 */
+		head = (void *)&page->rcu_head;
+		call_rcu(head, kmem_rcu_free);
 
-		slab_rcu = (struct slab_rcu *)slabp;
-		slab_rcu->page = page;
-		call_rcu(&slab_rcu->head, kmem_rcu_free);
 	} else {
 		kmem_freepages(cachep, page);
-		if (OFF_SLAB(cachep))
-			kmem_cache_free(cachep->slabp_cache, slabp);
 	}
+
+	/*
+	 * From now on, we don't use slab management
+	 * although actual page can be freed in rcu context
+	 */
+	if (OFF_SLAB(cachep))
+		kmem_cache_free(cachep->slabp_cache, slabp);
 }
 
 /**
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
