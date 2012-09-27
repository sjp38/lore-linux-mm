Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 87DF86B0044
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 10:42:12 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 3/4] slub: move slub internal functions to its header
Date: Thu, 27 Sep 2012 18:37:39 +0400
Message-Id: <1348756660-16929-4-git-send-email-glommer@parallels.com>
In-Reply-To: <1348756660-16929-1-git-send-email-glommer@parallels.com>
References: <1348756660-16929-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@cs.helsinki.fi>

The functions oo_order() and oo_objects() are used by the slub to
determine respectively the order of a candidate allocation, and the
number of objects made available from it. I would like a stable visible
location outside slub.c so it can be acessed from slab_common.c.

I considered also just making it a common field between slub and slab,
but decided to move those to slub_def.h due to two main reasons: first,
it still deals with implementation specific details of the caches, so it
is better to just use wrappers. Second, because it is not necessarily
the order determined at cache creation time, but possibly a smaller
order in case of a retry. When we use it in slab_common.c we will be
talking about "base" values, but those functions would still have to
exist inside slub, so doing this we can just reuse them.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: David Rientjes <rientjes@google.com>
---
 include/linux/slub_def.h | 14 ++++++++++++++
 mm/slub.c                | 14 --------------
 2 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index df448ad..f1590c9 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -73,6 +73,20 @@ struct kmem_cache_order_objects {
 	unsigned long x;
 };
 
+#define OO_SHIFT	16
+#define OO_MASK		((1 << OO_SHIFT) - 1)
+#define MAX_OBJS_PER_PAGE	32767 /* since page.objects is u15 */
+
+static inline int oo_order(struct kmem_cache_order_objects x)
+{
+	return x.x >> OO_SHIFT;
+}
+
+static inline int oo_objects(struct kmem_cache_order_objects x)
+{
+	return x.x & OO_MASK;
+}
+
 /*
  * Slab cache management.
  */
diff --git a/mm/slub.c b/mm/slub.c
index 4c2c092..9e72722 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -171,10 +171,6 @@ static inline int kmem_cache_debug(struct kmem_cache *s)
 #define SLUB_MERGE_SAME (SLAB_DEBUG_FREE | SLAB_RECLAIM_ACCOUNT | \
 		SLAB_CACHE_DMA | SLAB_NOTRACK)
 
-#define OO_SHIFT	16
-#define OO_MASK		((1 << OO_SHIFT) - 1)
-#define MAX_OBJS_PER_PAGE	32767 /* since page.objects is u15 */
-
 /* Internal SLUB flags */
 #define __OBJECT_POISON		0x80000000UL /* Poison object */
 #define __CMPXCHG_DOUBLE	0x40000000UL /* Use cmpxchg_double */
@@ -325,16 +321,6 @@ static inline struct kmem_cache_order_objects oo_make(int order,
 	return x;
 }
 
-static inline int oo_order(struct kmem_cache_order_objects x)
-{
-	return x.x >> OO_SHIFT;
-}
-
-static inline int oo_objects(struct kmem_cache_order_objects x)
-{
-	return x.x & OO_MASK;
-}
-
 /*
  * Per slab locking using the pagelock
  */
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
