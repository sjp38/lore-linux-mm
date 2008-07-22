Received: by ti-out-0910.google.com with SMTP id j3so992596tid.8
        for <linux-mm@kvack.org>; Tue, 22 Jul 2008 11:33:34 -0700 (PDT)
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: [RFC PATCH 4/4] kmemtrace: SLOB hooks.
Date: Tue, 22 Jul 2008 21:31:33 +0300
Message-Id: <1216751493-13785-5-git-send-email-eduard.munteanu@linux360.ro>
In-Reply-To: <1216751493-13785-4-git-send-email-eduard.munteanu@linux360.ro>
References: <1216751493-13785-1-git-send-email-eduard.munteanu@linux360.ro>
 <1216751493-13785-2-git-send-email-eduard.munteanu@linux360.ro>
 <1216751493-13785-3-git-send-email-eduard.munteanu@linux360.ro>
 <1216751493-13785-4-git-send-email-eduard.munteanu@linux360.ro>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: penberg@cs.helsinki.fi
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net, mpm@selenic.co
List-ID: <linux-mm.kvack.org>

This adds hooks for the SLOB allocator, to allow tracing with kmemtrace.

Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
---
 include/linux/slob_def.h |    9 +++++----
 mm/slob.c                |   37 +++++++++++++++++++++++++++++++------
 2 files changed, 36 insertions(+), 10 deletions(-)

diff --git a/include/linux/slob_def.h b/include/linux/slob_def.h
index 59a3fa4..0ec00b3 100644
--- a/include/linux/slob_def.h
+++ b/include/linux/slob_def.h
@@ -3,14 +3,15 @@
 
 void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
 
-static inline void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
+static __always_inline void *kmem_cache_alloc(struct kmem_cache *cachep,
+					      gfp_t flags)
 {
 	return kmem_cache_alloc_node(cachep, flags, -1);
 }
 
 void *__kmalloc_node(size_t size, gfp_t flags, int node);
 
-static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
+static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 {
 	return __kmalloc_node(size, flags, node);
 }
@@ -23,12 +24,12 @@ static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
  * kmalloc is the normal method of allocating memory
  * in the kernel.
  */
-static inline void *kmalloc(size_t size, gfp_t flags)
+static __always_inline void *kmalloc(size_t size, gfp_t flags)
 {
 	return __kmalloc_node(size, flags, -1);
 }
 
-static inline void *__kmalloc(size_t size, gfp_t flags)
+static __always_inline void *__kmalloc(size_t size, gfp_t flags)
 {
 	return kmalloc(size, flags);
 }
diff --git a/mm/slob.c b/mm/slob.c
index a3ad667..23375ed 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -65,6 +65,7 @@
 #include <linux/module.h>
 #include <linux/rcupdate.h>
 #include <linux/list.h>
+#include <linux/kmemtrace.h>
 #include <asm/atomic.h>
 
 /*
@@ -463,27 +464,38 @@ void *__kmalloc_node(size_t size, gfp_t gfp, int node)
 {
 	unsigned int *m;
 	int align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
+	void *ret;
 
 	if (size < PAGE_SIZE - align) {
 		if (!size)
 			return ZERO_SIZE_PTR;
 
 		m = slob_alloc(size + align, gfp, align, node);
+
 		if (!m)
 			return NULL;
 		*m = size;
-		return (void *)m + align;
+		ret = (void *)m + align;
+
+		kmemtrace_mark_alloc_node(KMEMTRACE_TYPE_KMALLOC,
+					  _RET_IP_, ret,
+					  size, size + align, gfp, node);
 	} else {
-		void *ret;
+		unsigned int order = get_order(size);
 
-		ret = slob_new_page(gfp | __GFP_COMP, get_order(size), node);
+		ret = slob_new_page(gfp | __GFP_COMP, order, node);
 		if (ret) {
 			struct page *page;
 			page = virt_to_page(ret);
 			page->private = size;
 		}
-		return ret;
+
+		kmemtrace_mark_alloc_node(KMEMTRACE_TYPE_KMALLOC,
+					  _RET_IP_, ret,
+					  size, PAGE_SIZE << order, gfp, node);
 	}
+
+	return ret;
 }
 EXPORT_SYMBOL(__kmalloc_node);
 
@@ -501,6 +513,8 @@ void kfree(const void *block)
 		slob_free(m, *m + align);
 	} else
 		put_page(&sp->page);
+
+	kmemtrace_mark_free(KMEMTRACE_TYPE_KMALLOC, _RET_IP_, block);
 }
 EXPORT_SYMBOL(kfree);
 
@@ -569,10 +583,19 @@ void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
 {
 	void *b;
 
-	if (c->size < PAGE_SIZE)
+	if (c->size < PAGE_SIZE) {
 		b = slob_alloc(c->size, flags, c->align, node);
-	else
+		kmemtrace_mark_alloc_node(KMEMTRACE_TYPE_CACHE,
+					  _RET_IP_, b, c->size,
+					  SLOB_UNITS(c->size) * SLOB_UNIT,
+					  flags, node);
+	} else {
 		b = slob_new_page(flags, get_order(c->size), node);
+		kmemtrace_mark_alloc_node(KMEMTRACE_TYPE_CACHE,
+					  _RET_IP_, b, c->size,
+					  PAGE_SIZE << get_order(c->size),
+					  flags, node);
+	}
 
 	if (c->ctor)
 		c->ctor(c, b);
@@ -608,6 +631,8 @@ void kmem_cache_free(struct kmem_cache *c, void *b)
 	} else {
 		__kmem_cache_free(b, c->size);
 	}
+
+	kmemtrace_mark_free(KMEMTRACE_TYPE_CACHE, _RET_IP_, b);
 }
 EXPORT_SYMBOL(kmem_cache_free);
 
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
