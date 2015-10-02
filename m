Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1F1D082F99
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 06:14:12 -0400 (EDT)
Received: by laer8 with SMTP id r8so89714628lae.2
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 03:14:11 -0700 (PDT)
Received: from mail-la0-x22b.google.com (mail-la0-x22b.google.com. [2a00:1450:4010:c03::22b])
        by mx.google.com with ESMTPS id tb2si5722154lbb.176.2015.10.02.03.14.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Oct 2015 03:14:10 -0700 (PDT)
Received: by laclj5 with SMTP id lj5so89833409lac.3
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 03:14:10 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH 2/2] slab.h: sprinkle __assume_aligned attributes
Date: Fri,  2 Oct 2015 12:12:55 +0200
Message-Id: <1443780775-10304-2-git-send-email-linux@rasmusvillemoes.dk>
In-Reply-To: <1443780775-10304-1-git-send-email-linux@rasmusvillemoes.dk>
References: <1443780775-10304-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The various allocators return aligned memory. Telling the compiler
that allows it to generate better code in many cases, for example when
the return value is immediately passed to memset().

Some code does become larger, but at least we win twice as much as we lose:

$ scripts/bloat-o-meter /tmp/vmlinux vmlinux
add/remove: 0/0 grow/shrink: 13/52 up/down: 995/-2140 (-1145)

An example of the different (and smaller) code can be seen in mm_alloc(). Before:

:       48 8d 78 08             lea    0x8(%rax),%rdi
:       48 89 c1                mov    %rax,%rcx
:       48 89 c2                mov    %rax,%rdx
:       48 c7 00 00 00 00 00    movq   $0x0,(%rax)
:       48 c7 80 48 03 00 00    movq   $0x0,0x348(%rax)
:       00 00 00 00
:       31 c0                   xor    %eax,%eax
:       48 83 e7 f8             and    $0xfffffffffffffff8,%rdi
:       48 29 f9                sub    %rdi,%rcx
:       81 c1 50 03 00 00       add    $0x350,%ecx
:       c1 e9 03                shr    $0x3,%ecx
:       f3 48 ab                rep stos %rax,%es:(%rdi)

After:

:       48 89 c2                mov    %rax,%rdx
:       b9 6a 00 00 00          mov    $0x6a,%ecx
:       31 c0                   xor    %eax,%eax
:       48 89 d7                mov    %rdx,%rdi
:       f3 48 ab                rep stos %rax,%es:(%rdi)

So gcc's strategy is to do two possibly (but not really, of course)
unaligned stores to the first and last word, then do an aligned rep
stos covering the middle part with a little overlap. Maybe arches
which do not allow unaligned stores gain even more.

I don't know if gcc can actually make use of alignments greater than 8
for anything, so one could probably drop the __assume_xyz_alignment
macros and just use __assume_aligned(8).

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---

The increases in code size are mostly caused by gcc deciding to
opencode strlen() using the check-four-bytes-at-a-time trick when it
knows the buffer is sufficiently aligned (one function grew by 200
bytes). Now it turns out that many of these strlen() calls showing up
were in fact redundant, and they're gone from -next. Applying the two
patches to next-20151001 bloat-o-meter instead says

add/remove: 0/0 grow/shrink: 6/52 up/down: 244/-2140 (-1896)


 include/linux/slab.h | 43 ++++++++++++++++++++++++++-----------------
 1 file changed, 26 insertions(+), 17 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 7e37d448ed91..b89a67d297f1 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -158,6 +158,24 @@ size_t ksize(const void *);
 #endif
 
 /*
+ * Setting ARCH_SLAB_MINALIGN in arch headers allows a different alignment.
+ * Intended for arches that get misalignment faults even for 64 bit integer
+ * aligned buffers.
+ */
+#ifndef ARCH_SLAB_MINALIGN
+#define ARCH_SLAB_MINALIGN __alignof__(unsigned long long)
+#endif
+
+/*
+ * kmalloc and friends return ARCH_KMALLOC_MINALIGN aligned
+ * pointers. kmem_cache_alloc and friends return ARCH_SLAB_MINALIGN
+ * aligned pointers.
+ */
+#define __assume_kmalloc_alignment __assume_aligned(ARCH_KMALLOC_MINALIGN)
+#define __assume_slab_alignment __assume_aligned(ARCH_SLAB_MINALIGN)
+#define __assume_page_alignment __assume_aligned(PAGE_SIZE)
+
+/*
  * Kmalloc array related definitions
  */
 
@@ -286,8 +304,8 @@ static __always_inline int kmalloc_index(size_t size)
 }
 #endif /* !CONFIG_SLOB */
 
-void *__kmalloc(size_t size, gfp_t flags);
-void *kmem_cache_alloc(struct kmem_cache *, gfp_t flags);
+void *__kmalloc(size_t size, gfp_t flags) __assume_kmalloc_alignment;
+void *kmem_cache_alloc(struct kmem_cache *, gfp_t flags) __assume_slab_alignment;
 void kmem_cache_free(struct kmem_cache *, void *);
 
 /*
@@ -301,8 +319,8 @@ void kmem_cache_free_bulk(struct kmem_cache *, size_t, void **);
 bool kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void **);
 
 #ifdef CONFIG_NUMA
-void *__kmalloc_node(size_t size, gfp_t flags, int node);
-void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
+void *__kmalloc_node(size_t size, gfp_t flags, int node) __assume_kmalloc_alignment;
+void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node) __assume_slab_alignment;
 #else
 static __always_inline void *__kmalloc_node(size_t size, gfp_t flags, int node)
 {
@@ -316,12 +334,12 @@ static __always_inline void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t f
 #endif
 
 #ifdef CONFIG_TRACING
-extern void *kmem_cache_alloc_trace(struct kmem_cache *, gfp_t, size_t);
+extern void *kmem_cache_alloc_trace(struct kmem_cache *, gfp_t, size_t) __assume_slab_alignment;
 
 #ifdef CONFIG_NUMA
 extern void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
 					   gfp_t gfpflags,
-					   int node, size_t size);
+					   int node, size_t size) __assume_slab_alignment;
 #else
 static __always_inline void *
 kmem_cache_alloc_node_trace(struct kmem_cache *s,
@@ -354,10 +372,10 @@ kmem_cache_alloc_node_trace(struct kmem_cache *s,
 }
 #endif /* CONFIG_TRACING */
 
-extern void *kmalloc_order(size_t size, gfp_t flags, unsigned int order);
+extern void *kmalloc_order(size_t size, gfp_t flags, unsigned int order) __assume_page_alignment;
 
 #ifdef CONFIG_TRACING
-extern void *kmalloc_order_trace(size_t size, gfp_t flags, unsigned int order);
+extern void *kmalloc_order_trace(size_t size, gfp_t flags, unsigned int order) __assume_page_alignment;
 #else
 static __always_inline void *
 kmalloc_order_trace(size_t size, gfp_t flags, unsigned int order)
@@ -482,15 +500,6 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 	return __kmalloc_node(size, flags, node);
 }
 
-/*
- * Setting ARCH_SLAB_MINALIGN in arch headers allows a different alignment.
- * Intended for arches that get misalignment faults even for 64 bit integer
- * aligned buffers.
- */
-#ifndef ARCH_SLAB_MINALIGN
-#define ARCH_SLAB_MINALIGN __alignof__(unsigned long long)
-#endif
-
 struct memcg_cache_array {
 	struct rcu_head rcu;
 	struct kmem_cache *entries[0];
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
