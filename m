Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id C55136B0062
	for <linux-mm@kvack.org>; Sat, 20 Oct 2012 11:49:30 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so1115607pad.14
        for <linux-mm@kvack.org>; Sat, 20 Oct 2012 08:49:30 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH for-v3.7 1/2] slub: optimize poorly inlined kmalloc* functions
Date: Sun, 21 Oct 2012 00:48:12 +0900
Message-Id: <1350748093-7868-1-git-send-email-js1304@gmail.com>
In-Reply-To: <Yes>
References: <Yes>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Christoph Lameter <cl@linux.com>

kmalloc() and kmalloc_node() is always inlined into generic code.
However, there is a mistake in implemention of the SLUB.

In kmalloc() and kmalloc_node() of the SLUB,
we try to compare kmalloc_caches[index] with NULL.
As it cannot be known at compile time,
this comparison is inserted into generic code invoking kmalloc*.
This may decrease system performance, so we should fix it.

Below is the result of "size vmlinux"
text size is decreased roughly 20KB

Before:
   text	   data	    bss	    dec	    hex	filename
10044177        1443168 5722112 17209457        1069871 vmlinux
After:
   text	   data	    bss	    dec	    hex	filename
10022627        1443136 5722112 17187875        1064423 vmlinux

Cc: Christoph Lameter <cl@linux.com>
Signed-off-by: Joonsoo Kim <js1304@gmail.com>
---
With Christoph's patchset(common kmalloc caches:
'[15/15] Common Kmalloc cache determination') which is not merged into mainline yet,
this issue will be fixed.
As it takes some time, I send this patch for v3.7

This patch is based on v3.7-rc1

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index df448ad..4c75f2b 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -271,9 +271,10 @@ static __always_inline void *kmalloc(size_t size, gfp_t flags)
 			return kmalloc_large(size, flags);
 
 		if (!(flags & SLUB_DMA)) {
-			struct kmem_cache *s = kmalloc_slab(size);
+			int index = kmalloc_index(size);
+			struct kmem_cache *s = kmalloc_caches[index];
 
-			if (!s)
+			if (!index)
 				return ZERO_SIZE_PTR;
 
 			return kmem_cache_alloc_trace(s, flags, size);
@@ -304,9 +305,10 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 {
 	if (__builtin_constant_p(size) &&
 		size <= SLUB_MAX_SIZE && !(flags & SLUB_DMA)) {
-			struct kmem_cache *s = kmalloc_slab(size);
+		int index = kmalloc_index(size);
+		struct kmem_cache *s = kmalloc_caches[index];
 
-		if (!s)
+		if (!index)
 			return ZERO_SIZE_PTR;
 
 		return kmem_cache_alloc_node_trace(s, flags, node, size);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
