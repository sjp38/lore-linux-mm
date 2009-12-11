Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 231896B0044
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 03:57:24 -0500 (EST)
Date: Fri, 11 Dec 2009 08:55:15 GMT
From: tip-bot for Li Zefan <lizf@cn.fujitsu.com>
Reply-To: mingo@redhat.com, hpa@zytor.com, linux-kernel@vger.kernel.org,
        lizf@cn.fujitsu.com, penberg@cs.helsinki.fi,
        eduard.munteanu@linux360.ro, fweisbec@gmail.com, rostedt@goodmis.org,
        tglx@linutronix.de, linux-mm@kvack.org, cl@linux-foundation.org,
        mingo@elte.hu
In-Reply-To: <4B21F89A.7000801@cn.fujitsu.com>
References: <4B21F89A.7000801@cn.fujitsu.com>
Subject: [tip:perf/urgent] tracing, slab: Define kmem_cache_alloc_notrace ifdef CONFIG_TRACING
Message-ID: <tip-0f24f1287a86b198c1e4bd4ce45e8565e40ff804@git.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-tip-commits@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, hpa@zytor.com, mingo@redhat.com, penberg@cs.helsinki.fi, lizf@cn.fujitsu.com, eduard.munteanu@linux360.ro, fweisbec@gmail.com, rostedt@goodmis.org, tglx@linutronix.de, linux-mm@kvack.org, mingo@elte.hu, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Commit-ID:  0f24f1287a86b198c1e4bd4ce45e8565e40ff804
Gitweb:     http://git.kernel.org/tip/0f24f1287a86b198c1e4bd4ce45e8565e40ff804
Author:     Li Zefan <lizf@cn.fujitsu.com>
AuthorDate: Fri, 11 Dec 2009 15:45:30 +0800
Committer:  Ingo Molnar <mingo@elte.hu>
CommitDate: Fri, 11 Dec 2009 09:17:02 +0100

tracing, slab: Define kmem_cache_alloc_notrace ifdef CONFIG_TRACING

Define kmem_trace_alloc_{,node}_notrace() if CONFIG_TRACING is
enabled, otherwise perf-kmem will show wrong stats ifndef
CONFIG_KMEM_TRACE, because a kmalloc() memory allocation may
be traced by both trace_kmalloc() and trace_kmem_cache_alloc().

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Frederic Weisbecker <fweisbec@gmail.com>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
Cc: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
LKML-Reference: <4B21F89A.7000801@cn.fujitsu.com>
Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 include/linux/slab_def.h |    4 ++--
 include/linux/slub_def.h |    4 ++--
 mm/slab.c                |    6 +++---
 mm/slub.c                |    4 ++--
 4 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 850d057..ca6b2b3 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -110,7 +110,7 @@ extern struct cache_sizes malloc_sizes[];
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
 void *__kmalloc(size_t size, gfp_t flags);
 
-#ifdef CONFIG_KMEMTRACE
+#ifdef CONFIG_TRACING
 extern void *kmem_cache_alloc_notrace(struct kmem_cache *cachep, gfp_t flags);
 extern size_t slab_buffer_size(struct kmem_cache *cachep);
 #else
@@ -166,7 +166,7 @@ found:
 extern void *__kmalloc_node(size_t size, gfp_t flags, int node);
 extern void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
 
-#ifdef CONFIG_KMEMTRACE
+#ifdef CONFIG_TRACING
 extern void *kmem_cache_alloc_node_notrace(struct kmem_cache *cachep,
 					   gfp_t flags,
 					   int nodeid);
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 5ad70a6..1e14beb 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -217,7 +217,7 @@ static __always_inline struct kmem_cache *kmalloc_slab(size_t size)
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
 void *__kmalloc(size_t size, gfp_t flags);
 
-#ifdef CONFIG_KMEMTRACE
+#ifdef CONFIG_TRACING
 extern void *kmem_cache_alloc_notrace(struct kmem_cache *s, gfp_t gfpflags);
 #else
 static __always_inline void *
@@ -266,7 +266,7 @@ static __always_inline void *kmalloc(size_t size, gfp_t flags)
 void *__kmalloc_node(size_t size, gfp_t flags, int node);
 void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
 
-#ifdef CONFIG_KMEMTRACE
+#ifdef CONFIG_TRACING
 extern void *kmem_cache_alloc_node_notrace(struct kmem_cache *s,
 					   gfp_t gfpflags,
 					   int node);
diff --git a/mm/slab.c b/mm/slab.c
index 7dfa481..9733bb4 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -490,7 +490,7 @@ static void **dbg_userword(struct kmem_cache *cachep, void *objp)
 
 #endif
 
-#ifdef CONFIG_KMEMTRACE
+#ifdef CONFIG_TRACING
 size_t slab_buffer_size(struct kmem_cache *cachep)
 {
 	return cachep->buffer_size;
@@ -3558,7 +3558,7 @@ void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 }
 EXPORT_SYMBOL(kmem_cache_alloc);
 
-#ifdef CONFIG_KMEMTRACE
+#ifdef CONFIG_TRACING
 void *kmem_cache_alloc_notrace(struct kmem_cache *cachep, gfp_t flags)
 {
 	return __cache_alloc(cachep, flags, __builtin_return_address(0));
@@ -3621,7 +3621,7 @@ void *kmem_cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node);
 
-#ifdef CONFIG_KMEMTRACE
+#ifdef CONFIG_TRACING
 void *kmem_cache_alloc_node_notrace(struct kmem_cache *cachep,
 				    gfp_t flags,
 				    int nodeid)
diff --git a/mm/slub.c b/mm/slub.c
index 4996fc7..4a89c3d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1754,7 +1754,7 @@ void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
 }
 EXPORT_SYMBOL(kmem_cache_alloc);
 
-#ifdef CONFIG_KMEMTRACE
+#ifdef CONFIG_TRACING
 void *kmem_cache_alloc_notrace(struct kmem_cache *s, gfp_t gfpflags)
 {
 	return slab_alloc(s, gfpflags, -1, _RET_IP_);
@@ -1775,7 +1775,7 @@ void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t gfpflags, int node)
 EXPORT_SYMBOL(kmem_cache_alloc_node);
 #endif
 
-#ifdef CONFIG_KMEMTRACE
+#ifdef CONFIG_TRACING
 void *kmem_cache_alloc_node_notrace(struct kmem_cache *s,
 				    gfp_t gfpflags,
 				    int node)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
