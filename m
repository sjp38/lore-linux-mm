Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8C8186B007B
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 08:02:32 -0400 (EDT)
Received: by mail-pw0-f41.google.com with SMTP id 6so204729pwj.14
        for <linux-mm@kvack.org>; Wed, 29 Sep 2010 05:02:31 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH 3/3] slub: Move NUMA-related functions under CONFIG_NUMA
Date: Wed, 29 Sep 2010 21:02:15 +0900
Message-Id: <1285761735-31499-3-git-send-email-namhyung@gmail.com>
In-Reply-To: <1285761735-31499-1-git-send-email-namhyung@gmail.com>
References: <1285761735-31499-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Make kmalloc_cache_alloc_node_notrace(), kmalloc_large_node()
and __kmalloc_node_track_caller() to be compiled only when
CONFIG_NUMA is selected.

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 mm/slub.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index f0684a9..4abc186 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1756,7 +1756,6 @@ void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t gfpflags, int node)
 	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node);
-#endif
 
 #ifdef CONFIG_TRACING
 void *kmem_cache_alloc_node_notrace(struct kmem_cache *s,
@@ -1767,6 +1766,7 @@ void *kmem_cache_alloc_node_notrace(struct kmem_cache *s,
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node_notrace);
 #endif
+#endif
 
 /*
  * Slow patch handling. This may still be called frequently since objects
@@ -2736,6 +2736,7 @@ void *__kmalloc(size_t size, gfp_t flags)
 }
 EXPORT_SYMBOL(__kmalloc);
 
+#ifdef CONFIG_NUMA
 static void *kmalloc_large_node(size_t size, gfp_t flags, int node)
 {
 	struct page *page;
@@ -2750,7 +2751,6 @@ static void *kmalloc_large_node(size_t size, gfp_t flags, int node)
 	return ptr;
 }
 
-#ifdef CONFIG_NUMA
 void *__kmalloc_node(size_t size, gfp_t flags, int node)
 {
 	struct kmem_cache *s;
@@ -3319,6 +3319,7 @@ void *__kmalloc_track_caller(size_t size, gfp_t gfpflags, unsigned long caller)
 	return ret;
 }
 
+#ifdef CONFIG_NUMA
 void *__kmalloc_node_track_caller(size_t size, gfp_t gfpflags,
 					int node, unsigned long caller)
 {
@@ -3347,6 +3348,7 @@ void *__kmalloc_node_track_caller(size_t size, gfp_t gfpflags,
 
 	return ret;
 }
+#endif
 
 #ifdef CONFIG_SLUB_DEBUG
 static int count_inuse(struct page *page)
-- 
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
