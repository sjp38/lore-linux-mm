Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 54A136B0005
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 19:42:51 -0400 (EDT)
Received: by mail-wm0-f53.google.com with SMTP id l68so216509834wml.0
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 16:42:51 -0700 (PDT)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id e129si28931997wmd.1.2016.03.23.16.42.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Mar 2016 16:42:50 -0700 (PDT)
Received: by mail-wm0-x232.google.com with SMTP id p65so253147746wmp.1
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 16:42:50 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH 2/2] include/linux: apply __malloc attribute
Date: Thu, 24 Mar 2016 00:42:32 +0100
Message-Id: <1458776553-9033-2-git-send-email-linux@rasmusvillemoes.dk>
In-Reply-To: <1458776553-9033-1-git-send-email-linux@rasmusvillemoes.dk>
References: <1458776553-9033-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andi Kleen <ak@linux.intel.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Attach the malloc attribute to a few allocation functions. This helps
gcc generate better code by telling it that the return value doesn't
alias any existing pointers (which is even more valuable given the
pessimizations implied by -fno-strict-aliasing).

A simple example of what this allows gcc to do can be seen by looking
at the last part of drm_atomic_helper_plane_reset:

	plane->state = kzalloc(sizeof(*plane->state), GFP_KERNEL);

	if (plane->state) {
		plane->state->plane = plane;
		plane->state->rotation = BIT(DRM_ROTATE_0);
	}

which compiles to

    e8 99 bf d6 ff          callq  ffffffff8116d540 <kmem_cache_alloc_trace>
    48 85 c0                test   %rax,%rax
    48 89 83 40 02 00 00    mov    %rax,0x240(%rbx)
    74 11                   je     ffffffff814015c4 <drm_atomic_helper_plane_reset+0x64>
    48 89 18                mov    %rbx,(%rax)
    48 8b 83 40 02 00 00    mov    0x240(%rbx),%rax [*]
    c7 40 40 01 00 00 00    movl   $0x1,0x40(%rax)

With this patch applied, the instruction at [*] is elided, since the
store to plane->state->plane is known to not alter the value of
plane->state.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 include/linux/bootmem.h | 16 ++++++++--------
 include/linux/device.h  | 12 ++++++------
 include/linux/kernel.h  |  4 ++--
 include/linux/mempool.h |  3 ++-
 include/linux/slab.h    | 16 ++++++++--------
 include/linux/string.h  |  2 +-
 6 files changed, 27 insertions(+), 26 deletions(-)

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index 35b22f94d2d2..f9be32691718 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -83,34 +83,34 @@ extern void *__alloc_bootmem(unsigned long size,
 			     unsigned long goal);
 extern void *__alloc_bootmem_nopanic(unsigned long size,
 				     unsigned long align,
-				     unsigned long goal);
+				     unsigned long goal) __malloc;
 extern void *__alloc_bootmem_node(pg_data_t *pgdat,
 				  unsigned long size,
 				  unsigned long align,
-				  unsigned long goal);
+				  unsigned long goal) __malloc;
 void *__alloc_bootmem_node_high(pg_data_t *pgdat,
 				  unsigned long size,
 				  unsigned long align,
-				  unsigned long goal);
+				  unsigned long goal) __malloc;
 extern void *__alloc_bootmem_node_nopanic(pg_data_t *pgdat,
 				  unsigned long size,
 				  unsigned long align,
-				  unsigned long goal);
+				  unsigned long goal) __malloc;
 void *___alloc_bootmem_node_nopanic(pg_data_t *pgdat,
 				  unsigned long size,
 				  unsigned long align,
 				  unsigned long goal,
-				  unsigned long limit);
+				  unsigned long limit) __malloc;
 extern void *__alloc_bootmem_low(unsigned long size,
 				 unsigned long align,
-				 unsigned long goal);
+				 unsigned long goal) __malloc;
 void *__alloc_bootmem_low_nopanic(unsigned long size,
 				 unsigned long align,
-				 unsigned long goal);
+				 unsigned long goal) __malloc;
 extern void *__alloc_bootmem_low_node(pg_data_t *pgdat,
 				      unsigned long size,
 				      unsigned long align,
-				      unsigned long goal);
+				      unsigned long goal) __malloc;
 
 #ifdef CONFIG_NO_BOOTMEM
 /* We are using top down, so it is safe to use 0 here */
diff --git a/include/linux/device.h b/include/linux/device.h
index 002c59728dbe..dd03e76fc375 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -609,14 +609,14 @@ typedef int (*dr_match_t)(struct device *dev, void *res, void *match_data);
 
 #ifdef CONFIG_DEBUG_DEVRES
 extern void *__devres_alloc_node(dr_release_t release, size_t size, gfp_t gfp,
-				 int nid, const char *name);
+				 int nid, const char *name) __malloc;
 #define devres_alloc(release, size, gfp) \
 	__devres_alloc_node(release, size, gfp, NUMA_NO_NODE, #release)
 #define devres_alloc_node(release, size, gfp, nid) \
 	__devres_alloc_node(release, size, gfp, nid, #release)
 #else
 extern void *devres_alloc_node(dr_release_t release, size_t size, gfp_t gfp,
-			       int nid);
+			       int nid) __malloc;
 static inline void *devres_alloc(dr_release_t release, size_t size, gfp_t gfp)
 {
 	return devres_alloc_node(release, size, gfp, NUMA_NO_NODE);
@@ -648,12 +648,12 @@ extern void devres_remove_group(struct device *dev, void *id);
 extern int devres_release_group(struct device *dev, void *id);
 
 /* managed devm_k.alloc/kfree for device drivers */
-extern void *devm_kmalloc(struct device *dev, size_t size, gfp_t gfp);
+extern void *devm_kmalloc(struct device *dev, size_t size, gfp_t gfp) __malloc;
 extern __printf(3, 0)
 char *devm_kvasprintf(struct device *dev, gfp_t gfp, const char *fmt,
-		      va_list ap);
+		      va_list ap) __malloc;
 extern __printf(3, 4)
-char *devm_kasprintf(struct device *dev, gfp_t gfp, const char *fmt, ...);
+char *devm_kasprintf(struct device *dev, gfp_t gfp, const char *fmt, ...) __malloc;
 static inline void *devm_kzalloc(struct device *dev, size_t size, gfp_t gfp)
 {
 	return devm_kmalloc(dev, size, gfp | __GFP_ZERO);
@@ -671,7 +671,7 @@ static inline void *devm_kcalloc(struct device *dev,
 	return devm_kmalloc_array(dev, n, size, flags | __GFP_ZERO);
 }
 extern void devm_kfree(struct device *dev, void *p);
-extern char *devm_kstrdup(struct device *dev, const char *s, gfp_t gfp);
+extern char *devm_kstrdup(struct device *dev, const char *s, gfp_t gfp) __malloc;
 extern void *devm_kmemdup(struct device *dev, const void *src, size_t len,
 			  gfp_t gfp);
 
diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index a13c52ccd8ac..6c2c3bc2e5e2 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -412,9 +412,9 @@ extern __printf(3, 4)
 int scnprintf(char *buf, size_t size, const char *fmt, ...);
 extern __printf(3, 0)
 int vscnprintf(char *buf, size_t size, const char *fmt, va_list args);
-extern __printf(2, 3)
+extern __printf(2, 3) __malloc
 char *kasprintf(gfp_t gfp, const char *fmt, ...);
-extern __printf(2, 0)
+extern __printf(2, 0) __malloc
 char *kvasprintf(gfp_t gfp, const char *fmt, va_list args);
 extern __printf(2, 0)
 const char *kvasprintf_const(gfp_t gfp, const char *fmt, va_list args);
diff --git a/include/linux/mempool.h b/include/linux/mempool.h
index 69b6951e8fd2..e0b79ae74818 100644
--- a/include/linux/mempool.h
+++ b/include/linux/mempool.h
@@ -5,6 +5,7 @@
 #define _LINUX_MEMPOOL_H
 
 #include <linux/wait.h>
+#include <linux/compiler.h>
 
 struct kmem_cache;
 
@@ -31,7 +32,7 @@ extern mempool_t *mempool_create_node(int min_nr, mempool_alloc_t *alloc_fn,
 
 extern int mempool_resize(mempool_t *pool, int new_min_nr);
 extern void mempool_destroy(mempool_t *pool);
-extern void * mempool_alloc(mempool_t *pool, gfp_t gfp_mask);
+extern void * mempool_alloc(mempool_t *pool, gfp_t gfp_mask) __malloc;
 extern void mempool_free(void *element, mempool_t *pool);
 
 /*
diff --git a/include/linux/slab.h b/include/linux/slab.h
index e4b568738ca3..123ecb16b4d6 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -309,8 +309,8 @@ static __always_inline int kmalloc_index(size_t size)
 }
 #endif /* !CONFIG_SLOB */
 
-void *__kmalloc(size_t size, gfp_t flags) __assume_kmalloc_alignment;
-void *kmem_cache_alloc(struct kmem_cache *, gfp_t flags) __assume_slab_alignment;
+void *__kmalloc(size_t size, gfp_t flags) __assume_kmalloc_alignment __malloc;
+void *kmem_cache_alloc(struct kmem_cache *, gfp_t flags) __assume_slab_alignment __malloc;
 void kmem_cache_free(struct kmem_cache *, void *);
 
 /*
@@ -333,8 +333,8 @@ static __always_inline void kfree_bulk(size_t size, void **p)
 }
 
 #ifdef CONFIG_NUMA
-void *__kmalloc_node(size_t size, gfp_t flags, int node) __assume_kmalloc_alignment;
-void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node) __assume_slab_alignment;
+void *__kmalloc_node(size_t size, gfp_t flags, int node) __assume_kmalloc_alignment __malloc;
+void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node) __assume_slab_alignment __malloc;
 #else
 static __always_inline void *__kmalloc_node(size_t size, gfp_t flags, int node)
 {
@@ -348,12 +348,12 @@ static __always_inline void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t f
 #endif
 
 #ifdef CONFIG_TRACING
-extern void *kmem_cache_alloc_trace(struct kmem_cache *, gfp_t, size_t) __assume_slab_alignment;
+extern void *kmem_cache_alloc_trace(struct kmem_cache *, gfp_t, size_t) __assume_slab_alignment __malloc;
 
 #ifdef CONFIG_NUMA
 extern void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
 					   gfp_t gfpflags,
-					   int node, size_t size) __assume_slab_alignment;
+					   int node, size_t size) __assume_slab_alignment __malloc;
 #else
 static __always_inline void *
 kmem_cache_alloc_node_trace(struct kmem_cache *s,
@@ -386,10 +386,10 @@ kmem_cache_alloc_node_trace(struct kmem_cache *s,
 }
 #endif /* CONFIG_TRACING */
 
-extern void *kmalloc_order(size_t size, gfp_t flags, unsigned int order) __assume_page_alignment;
+extern void *kmalloc_order(size_t size, gfp_t flags, unsigned int order) __assume_page_alignment __malloc;
 
 #ifdef CONFIG_TRACING
-extern void *kmalloc_order_trace(size_t size, gfp_t flags, unsigned int order) __assume_page_alignment;
+extern void *kmalloc_order_trace(size_t size, gfp_t flags, unsigned int order) __assume_page_alignment __malloc;
 #else
 static __always_inline void *
 kmalloc_order_trace(size_t size, gfp_t flags, unsigned int order)
diff --git a/include/linux/string.h b/include/linux/string.h
index d3993a79a325..26b6f6a66f83 100644
--- a/include/linux/string.h
+++ b/include/linux/string.h
@@ -119,7 +119,7 @@ char *strreplace(char *s, char old, char new);
 
 extern void kfree_const(const void *x);
 
-extern char *kstrdup(const char *s, gfp_t gfp);
+extern char *kstrdup(const char *s, gfp_t gfp) __malloc;
 extern const char *kstrdup_const(const char *s, gfp_t gfp);
 extern char *kstrndup(const char *s, size_t len, gfp_t gfp);
 extern void *kmemdup(const void *src, size_t len, gfp_t gfp);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
