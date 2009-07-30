Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7F2DA6B004D
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 10:18:59 -0400 (EDT)
Date: Thu, 30 Jul 2009 16:10:22 +0200 (CEST)
From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 3/5] mm: Add kmalloc NULL tests
Message-ID: <Pine.LNX.4.64.0907301608350.8734@ask.diku.dk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
List-ID: <linux-mm.kvack.org>

From: Julia Lawall <julia@diku.dk>

Check that the result of kmalloc is not NULL before passing it to other
functions.

The semantic match that finds this problem is as follows:
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@@
expression *x;
identifier f;
constant char *C;
@@

x = \(kmalloc\|kcalloc\|kzalloc\)(...);
... when != x == NULL
    when != x != NULL
    when != (x || ...)
(
kfree(x)
|
f(...,C,...,x,...)
|
*f(...,x,...)
|
*x->f
)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 mm/slab.c       |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 7b5d4de..972e427 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1502,6 +1502,7 @@ void __init kmem_cache_init(void)
 
 		ptr = kmalloc(sizeof(struct arraycache_init), GFP_NOWAIT);
 
+		BUG_ON(!ptr);
 		BUG_ON(cpu_cache_get(&cache_cache) != &initarray_cache.cache);
 		memcpy(ptr, cpu_cache_get(&cache_cache),
 		       sizeof(struct arraycache_init));
@@ -1514,6 +1515,7 @@ void __init kmem_cache_init(void)
 
 		ptr = kmalloc(sizeof(struct arraycache_init), GFP_NOWAIT);
 
+		BUG_ON(!ptr);
 		BUG_ON(cpu_cache_get(malloc_sizes[INDEX_AC].cs_cachep)
 		       != &initarray_generic.cache);
 		memcpy(ptr, cpu_cache_get(malloc_sizes[INDEX_AC].cs_cachep),

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
