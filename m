Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id EBA796B029C
	for <linux-mm@kvack.org>; Thu,  6 Oct 2011 12:28:14 -0400 (EDT)
Message-ID: <4E8DD5E8.7060806@parallels.com>
Date: Thu, 06 Oct 2011 20:23:04 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH 1/5] slab: Tossing bits around
References: <4E8DD5B9.4060905@parallels.com>
In-Reply-To: <4E8DD5B9.4060905@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
Cc: Glauber Costa <glommer@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>

This is the preparation patch, that just moves the sl[au]b code
around making the further patching simpler.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 mm/slab.c |   28 ++++++++++++++++++----------
 mm/slub.c |   26 +++++++++++++++-----------
 2 files changed, 33 insertions(+), 21 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 6d90a09..81a2063 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -538,7 +538,7 @@ static inline void *index_to_obj(struct kmem_cache *cache, struct slab *slab,
  *   reciprocal_divide(offset, cache->reciprocal_buffer_size)
  */
 static inline unsigned int obj_to_index(const struct kmem_cache *cache,
-					const struct slab *slab, void *obj)
+					const struct slab *slab, const void *obj)
 {
 	u32 offset = (obj - slab->s_mem);
 	return reciprocal_divide(offset, cache->reciprocal_buffer_size);
@@ -2178,6 +2178,15 @@ static int __init_refok setup_cpu_cache(struct kmem_cache *cachep, gfp_t gfp)
 	return 0;
 }
 
+static inline size_t __slab_size(int nr_objs, unsigned long flags)
+{
+	size_t ret;
+
+	ret = sizeof(struct slab) + nr_objs * sizeof(kmem_bufctl_t);
+
+	return ret;
+}
+
 /**
  * kmem_cache_create - Create a cache.
  * @name: A string which is used in /proc/slabinfo to identify this cache.
@@ -2406,8 +2415,8 @@ kmem_cache_create (const char *name, size_t size, size_t align,
 		cachep = NULL;
 		goto oops;
 	}
-	slab_size = ALIGN(cachep->num * sizeof(kmem_bufctl_t)
-			  + sizeof(struct slab), align);
+
+	slab_size = ALIGN(__slab_size(cachep->num, flags), align);
 
 	/*
 	 * If the slab has been placed off-slab, and we have enough space then
@@ -2420,8 +2429,7 @@ kmem_cache_create (const char *name, size_t size, size_t align,
 
 	if (flags & CFLGS_OFF_SLAB) {
 		/* really off slab. No need for manual alignment */
-		slab_size =
-		    cachep->num * sizeof(kmem_bufctl_t) + sizeof(struct slab);
+		slab_size = __slab_size(cachep->num, flags);
 
 #ifdef CONFIG_PAGE_POISONING
 		/* If we're going to use the generic kernel_map_pages()
@@ -2690,6 +2698,11 @@ void kmem_cache_destroy(struct kmem_cache *cachep)
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
 
+static inline kmem_bufctl_t *slab_bufctl(struct slab *slabp)
+{
+	return (kmem_bufctl_t *) (slabp + 1);
+}
+
 /*
  * Get the memory for a slab management obj.
  * For a slab cache when the slab descriptor is off-slab, slab descriptors
@@ -2733,11 +2746,6 @@ static struct slab *alloc_slabmgmt(struct kmem_cache *cachep, void *objp,
 	return slabp;
 }
 
-static inline kmem_bufctl_t *slab_bufctl(struct slab *slabp)
-{
-	return (kmem_bufctl_t *) (slabp + 1);
-}
-
 static void cache_init_objs(struct kmem_cache *cachep,
 			    struct slab *slabp)
 {
diff --git a/mm/slub.c b/mm/slub.c
index 7c54fe8..ab9d6fc 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1414,6 +1414,18 @@ static void setup_object(struct kmem_cache *s, struct page *page,
 		s->ctor(object);
 }
 
+#define need_reserve_slab_rcu						\
+	(sizeof(((struct page *)NULL)->lru) < sizeof(struct rcu_head))
+
+static inline void *slab_reserved_space(struct kmem_cache *s, struct page *page, int size)
+{
+	int order = compound_order(page);
+	int offset = (PAGE_SIZE << order) - s->reserved;
+
+	VM_BUG_ON(s->reserved < size);
+	return page_address(page) + offset;
+}
+
 static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 {
 	struct page *page;
@@ -1481,9 +1493,6 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 	__free_pages(page, order);
 }
 
-#define need_reserve_slab_rcu						\
-	(sizeof(((struct page *)NULL)->lru) < sizeof(struct rcu_head))
-
 static void rcu_free_slab(struct rcu_head *h)
 {
 	struct page *page;
@@ -1501,18 +1510,13 @@ static void free_slab(struct kmem_cache *s, struct page *page)
 	if (unlikely(s->flags & SLAB_DESTROY_BY_RCU)) {
 		struct rcu_head *head;
 
-		if (need_reserve_slab_rcu) {
-			int order = compound_order(page);
-			int offset = (PAGE_SIZE << order) - s->reserved;
-
-			VM_BUG_ON(s->reserved != sizeof(*head));
-			head = page_address(page) + offset;
-		} else {
+		if (need_reserve_slab_rcu)
+			head = slab_reserved_space(s, page, sizeof(struct rcu_head));
+		else
 			/*
 			 * RCU free overloads the RCU head over the LRU
 			 */
 			head = (void *)&page->lru;
-		}
 
 		call_rcu(head, rcu_free_slab);
 	} else
-- 
1.5.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
