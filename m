Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 6812F6B0080
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 18:50:57 -0400 (EDT)
Received: by mail-yx0-f169.google.com with SMTP id l1so244376yen.14
        for <linux-mm@kvack.org>; Wed, 05 Sep 2012 15:50:57 -0700 (PDT)
From: Ezequiel Garcia <elezegarcia@gmail.com>
Subject: [PATCH 2/5] mm, slob: Add support for kmalloc_track_caller()
Date: Wed,  5 Sep 2012 19:48:40 -0300
Message-Id: <1346885323-15689-2-git-send-email-elezegarcia@gmail.com>
In-Reply-To: <1346885323-15689-1-git-send-email-elezegarcia@gmail.com>
References: <1346885323-15689-1-git-send-email-elezegarcia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Ezequiel Garcia <elezegarcia@gmail.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

Currently slob falls back to regular kmalloc for this case.
With this patch kmalloc_track_caller() is correctly implemented,
thus tracing the specified caller.

This is important to trace accurately allocations performed by
krealloc, kstrdup, kmemdup, etc.

Cc: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>
Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>
---
 include/linux/slab.h |    6 ++++--
 mm/slob.c            |   27 ++++++++++++++++++++++++---
 2 files changed, 28 insertions(+), 5 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 0dd2dfa..83d1a14 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -321,7 +321,8 @@ static inline void *kmem_cache_alloc_node(struct kmem_cache *cachep,
  * request comes from.
  */
 #if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_SLUB) || \
-	(defined(CONFIG_SLAB) && defined(CONFIG_TRACING))
+	(defined(CONFIG_SLAB) && defined(CONFIG_TRACING)) || \
+	(defined(CONFIG_SLOB) && defined(CONFIG_TRACING))
 extern void *__kmalloc_track_caller(size_t, gfp_t, unsigned long);
 #define kmalloc_track_caller(size, flags) \
 	__kmalloc_track_caller(size, flags, _RET_IP_)
@@ -340,7 +341,8 @@ extern void *__kmalloc_track_caller(size_t, gfp_t, unsigned long);
  * allocation request comes from.
  */
 #if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_SLUB) || \
-	(defined(CONFIG_SLAB) && defined(CONFIG_TRACING))
+	(defined(CONFIG_SLAB) && defined(CONFIG_TRACING)) || \
+	(defined(CONFIG_SLOB) && defined(CONFIG_TRACING))
 extern void *__kmalloc_node_track_caller(size_t, gfp_t, int, unsigned long);
 #define kmalloc_node_track_caller(size, flags, node) \
 	__kmalloc_node_track_caller(size, flags, node, \
diff --git a/mm/slob.c b/mm/slob.c
index ae46edc..083959a 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -424,7 +424,8 @@ out:
  * End of slob allocator proper. Begin kmem_cache_alloc and kmalloc frontend.
  */
 
-void *__kmalloc_node(size_t size, gfp_t gfp, int node)
+static __always_inline void *
+__do_kmalloc_node(size_t size, gfp_t gfp, int node, unsigned long caller)
 {
 	unsigned int *m;
 	int align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
@@ -445,7 +446,7 @@ void *__kmalloc_node(size_t size, gfp_t gfp, int node)
 		*m = size;
 		ret = (void *)m + align;
 
-		trace_kmalloc_node(_RET_IP_, ret,
+		trace_kmalloc_node(caller, ret,
 				   size, size + align, gfp, node);
 	} else {
 		unsigned int order = get_order(size);
@@ -454,15 +455,35 @@ void *__kmalloc_node(size_t size, gfp_t gfp, int node)
 			gfp |= __GFP_COMP;
 		ret = slob_new_pages(gfp, order, node);
 
-		trace_kmalloc_node(_RET_IP_, ret,
+		trace_kmalloc_node(caller, ret,
 				   size, PAGE_SIZE << order, gfp, node);
 	}
 
 	kmemleak_alloc(ret, size, 1, gfp);
 	return ret;
 }
+
+void *__kmalloc_node(size_t size, gfp_t gfp, int node)
+{
+	return __do_kmalloc_node(size, gfp, node, _RET_IP_);
+}
 EXPORT_SYMBOL(__kmalloc_node);
 
+#ifdef CONFIG_TRACING
+void *__kmalloc_track_caller(size_t size, gfp_t gfp, unsigned long caller)
+{
+	return __do_kmalloc_node(size, gfp, -1, caller);
+}
+
+#ifdef CONFIG_NUMA
+void *__kmalloc_node_track_caller(size_t size, gfp_t gfpflags,
+					int node, unsigned long caller)
+{
+	return __do_kmalloc_node(size, gfp, node, caller);
+}
+#endif
+#endif
+
 void kfree(const void *block)
 {
 	struct page *sp;
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
