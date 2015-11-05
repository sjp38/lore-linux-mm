Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id EFC5682F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 06:50:43 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so85969635pab.0
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 03:50:43 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w5si9657697pbt.148.2015.11.05.03.50.42
        for <linux-mm@kvack.org>;
        Thu, 05 Nov 2015 03:50:42 -0800 (PST)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH] mm: slab: Only move management objects off-slab for sizes larger than KMALLOC_MIN_SIZE
Date: Thu,  5 Nov 2015 11:50:35 +0000
Message-Id: <1446724235-31400-1-git-send-email-catalin.marinas@arm.com>
In-Reply-To: <20151105043155.GA20374@js1304-P5Q-DELUXE>
References: <20151105043155.GA20374@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Catalin Marinas <catalin.marinas@arm.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

Commit 8fc9cf420b36 ("slab: make more slab management structure off the
slab") enables off-slab management objects for sizes starting with
PAGE_SIZE >> 5. This means 128 bytes for a 4KB page configuration.
However, on systems with a KMALLOC_MIN_SIZE of 128 (arm64 in 4.4), such
optimisation does not make sense since the slab management allocation
would take 128 bytes anyway (even though freelist_size is 32) with the
additional overhead of another allocation.

This patch introduces an OFF_SLAB_MIN_SIZE macro which takes
KMALLOC_MIN_SIZE into account. It also solves a slab bug on arm64 where
the first kmalloc_cache to be initialised after slab_early_init = 0,
"kmalloc-128", fails to allocate off-slab management objects from the
same "kmalloc-128" cache.

Fixes: 8fc9cf420b36 ("slab: make more slab management structure off the slab")
Cc: <stable@vger.kernel.org> # 3.15+
Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---
 mm/slab.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 4fcc5dd8d5a6..419b649b395e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -282,6 +282,7 @@ static void kmem_cache_node_init(struct kmem_cache_node *parent)
 
 #define CFLGS_OFF_SLAB		(0x80000000UL)
 #define	OFF_SLAB(x)	((x)->flags & CFLGS_OFF_SLAB)
+#define OFF_SLAB_MIN_SIZE	(max_t(size_t, PAGE_SIZE >> 5, KMALLOC_MIN_SIZE + 1))
 
 #define BATCHREFILL_LIMIT	16
 /*
@@ -2212,7 +2213,7 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	 * it too early on. Always use on-slab management when
 	 * SLAB_NOLEAKTRACE to avoid recursive calls into kmemleak)
 	 */
-	if ((size >= (PAGE_SIZE >> 5)) && !slab_early_init &&
+	if (size >= OFF_SLAB_MIN_SIZE && !slab_early_init &&
 	    !(flags & SLAB_NOLEAKTRACE))
 		/*
 		 * Size is large, assume best to place the slab management obj
@@ -2276,7 +2277,7 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 		/*
 		 * This is a possibility for one of the kmalloc_{dma,}_caches.
 		 * But since we go off slab only for object size greater than
-		 * PAGE_SIZE/8, and kmalloc_{dma,}_caches get created
+		 * OFF_SLAB_MIN_SIZE, and kmalloc_{dma,}_caches get created
 		 * in ascending order,this should not happen at all.
 		 * But leave a BUG_ON for some lucky dude.
 		 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
