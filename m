Date: Sun, 5 Oct 2008 03:27:00 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH next 2/3] slub defrag: dma_kmalloc_cache add_tail
In-Reply-To: <Pine.LNX.4.64.0810050319001.22004@blonde.site>
Message-ID: <Pine.LNX.4.64.0810050325440.22004@blonde.site>
References: <Pine.LNX.4.64.0810050319001.22004@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Why did that slowdown from mispinned pages manifest only on the G5?

Because something in my x86_32 and x86_64 configs (CONFIG_BLK_DEV_SR
I believe) is giving me a kmalloc_dma-512 cache, and dma_kmalloc_cache()
had not been updated to satisfy the assumption in kmem_cache_defrag(),
that defragmentable caches come first in the list.

So, any DMAable cache was preventing all slub defragmentation: which
looks like it's not been getting the testing exposure it deserves.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/slub.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- 2.6.27-rc7-mmotm/mm/slub.c	2008-09-26 13:18:53.000000000 +0100
+++ linux/mm/slub.c	2008-10-04 20:10:46.000000000 +0100
@@ -2636,7 +2636,7 @@ static noinline struct kmem_cache *dma_k
 		goto unlock_out;
 	}
 
-	list_add(&s->list, &slab_caches);
+	list_add_tail(&s->list, &slab_caches);
 	kmalloc_caches_dma[index] = s;
 
 	schedule_work(&sysfs_add_work);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
