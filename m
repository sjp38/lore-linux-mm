Date: Thu, 29 Nov 2007 12:05:13 -0700
From: Matthew Wilcox <matthew@wil.cx>
Subject: [PATCH] Fix kmem_cache_free performance regression in slab
Message-ID: <20071129190513.GD2584@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The database performance group have found that half the cycles spent
in kmem_cache_free are spent in this one call to BUG_ON.  Moving it
into the CONFIG_SLAB_DEBUG-only function cache_free_debugcheck() is a
performance win of almost 0.5% on their particular benchmark.

The call was added as part of commit ddc2e812d592457747c4367fb73edcaa8e1e49ff
with the comment that "overhead should be minimal".  It may have been
minimal at the time, but it isn't now.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>

diff --git a/mm/slab.c b/mm/slab.c
index cfa6be4..6e16431 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2881,6 +2881,8 @@ static void *cache_free_debugcheck(struct kmem_cache *cachep, void *objp,
 	unsigned int objnr;
 	struct slab *slabp;
 
+	BUG_ON(virt_to_cache(objp) != cachep);
+
 	objp -= obj_offset(cachep);
 	kfree_debugcheck(objp);
 	page = virt_to_head_page(objp);
@@ -3759,8 +3761,6 @@ void kmem_cache_free(struct kmem_cache *cachep, void *objp)
 {
 	unsigned long flags;
 
-	BUG_ON(virt_to_cache(objp) != cachep);
-
 	local_irq_save(flags);
 	debug_check_no_locks_freed(objp, obj_size(cachep));
 	__cache_free(cachep, objp);

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
