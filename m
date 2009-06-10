Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9CA236B005C
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 13:57:04 -0400 (EDT)
Date: Wed, 10 Jun 2009 20:58:40 +0300 (EEST)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: [PATCH 3/3] vmalloc: use kzalloc() instead of alloc_bootmem()
Message-ID: <Pine.LNX.4.64.0906102058060.28361@melkki.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: cl@linux-foundation.com, mingo@elte.hu, hannes@cmpxchg.org, torvalds@linux-foundation.org, mpm@selenic.com, npiggin@suse.de, yinghai@kernel.org
List-ID: <linux-mm.kvack.org>

From: Pekka Enberg <penberg@cs.helsinki.fi>

We can call vmalloc_init() after kmem_cache_init() and use kzalloc() instead of
the bootmem allocator when initializing vmalloc data structures.

Acked-by: Nick Piggin <npiggin@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Yinghai Lu <yinghai@kernel.org>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 init/main.c  |    2 +-
 mm/vmalloc.c |    3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/init/main.c b/init/main.c
index 8be5193..0c6f366 100644
--- a/init/main.c
+++ b/init/main.c
@@ -587,13 +587,13 @@ asmlinkage void __init start_kernel(void)
 	 * kmem_cache_init()
 	 */
 	pidhash_init();
-	vmalloc_init();
 	vfs_caches_init_early();
 	/*
 	 * Set up kernel memory allocators
 	 */
 	mem_init();
 	kmem_cache_init();
+	vmalloc_init();
 	/*
 	 * Set up the scheduler prior starting any interrupts (such as the
 	 * timer interrupt). Full topology setup happens at smp_init()
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 083716e..3235138 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -23,7 +23,6 @@
 #include <linux/rbtree.h>
 #include <linux/radix-tree.h>
 #include <linux/rcupdate.h>
-#include <linux/bootmem.h>
 #include <linux/pfn.h>
 
 #include <asm/atomic.h>
@@ -1032,7 +1031,7 @@ void __init vmalloc_init(void)
 
 	/* Import existing vmlist entries. */
 	for (tmp = vmlist; tmp; tmp = tmp->next) {
-		va = alloc_bootmem(sizeof(struct vmap_area));
+		va = kzalloc(sizeof(struct vmap_area), GFP_NOWAIT);
 		va->flags = tmp->flags | VM_VM_AREA;
 		va->va_start = (unsigned long)tmp->addr;
 		va->va_end = va->va_start + tmp->size;
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
