Message-Id: <20070514133212.804544498@chello.nl>
References: <20070514131904.440041502@chello.nl>
Date: Mon, 14 May 2007 15:19:08 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 4/5] mm: slob allocation fairness
Content-Disposition: inline; filename=mm-slob-ranking.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

The slob allocator has some unfairness wrt gfp flags; when the slob space is
grown the gfp flags are used to allocate more memory, however when there is 
slob space available gfp flags are ignored.

Thus it is possible for less critical slob allocations to succeed and gobble
up precious memory when under memory pressure.

This patch solves that by using the newly introduced page allocation rank.

Page allocation rank is a scalar quantity connecting ALLOC_ and gfp flags which
represents how deep we had to reach into our reserves when allocating a page. 
Rank 0 is the deepest we can reach (ALLOC_NO_WATERMARK) and 16 is the most 
shallow allocation possible (ALLOC_WMARK_HIGH).

When the slob space is grown the rank of the page allocation is stored. For
each slob allocation we test the given gfp flags against this rank. Thereby
asking the question: would these flags have allowed the slob to grow.

If not so, we need to test the current situation. This is done by forcing the
growth of the slob space. (Just testing the free page limits will not work due
to direct reclaim) Failing this we need to fail the slob allocation.

Thus if we grew the slob under great duress while PF_MEMALLOC was set and we 
really did access the memalloc reserve the rank would be set to 0. If the next
allocation to that slob would be GFP_NOFS|__GFP_NOMEMALLOC (which ordinarily
maps to rank 4 and always > 0) we'd want to make sure that memory pressure has
decreased enough to allow an allocation with the given gfp flags.

So in this case we try to force grow the slob space and on failure we fail the
slob allocation. Thus preserving the available slob space for more pressing
allocations.

[netperf results]

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Matt Mackall <mpm@selenic.com>
---
 mm/Kconfig |    1 -
 mm/slob.c  |   25 ++++++++++++++++++++++---
 2 files changed, 22 insertions(+), 4 deletions(-)

Index: linux-2.6-git/mm/slob.c
===================================================================
--- linux-2.6-git.orig/mm/slob.c
+++ linux-2.6-git/mm/slob.c
@@ -35,6 +35,7 @@
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/timer.h>
+#include "internal.h"
 
 struct slob_block {
 	int units;
@@ -53,6 +54,7 @@ struct bigblock {
 };
 typedef struct bigblock bigblock_t;
 
+static struct { int rank; } slobrank = { .rank = MAX_ALLOC_RANK };
 static slob_t arena = { .next = &arena, .units = 1 };
 static slob_t *slobfree = &arena;
 static bigblock_t *bigblocks;
@@ -62,12 +64,29 @@ static DEFINE_SPINLOCK(block_lock);
 static void slob_free(void *b, int size);
 static void slob_timer_cbk(void);
 
+static unsigned long slob_get_free_pages(gfp_t flags, int order)
+{
+	struct page *page = alloc_pages(gfp, order);
+	if (!page)
+		return 0;
+	slobrank.rank = page->index;
+	return (unsigned long)page_address(page);
+}
 
 static void *slob_alloc(size_t size, gfp_t gfp, int align)
 {
 	slob_t *prev, *cur, *aligned = 0;
 	int delta = 0, units = SLOB_UNITS(size);
 	unsigned long flags;
+	int rank = slab_alloc_rank(gfp);
+
+	if (slab_insufficient_rank(&slobrank, rank)) {
+		struct page *page = alloc_page(gfp);
+		if (!page)
+			return NULL;
+		slobrank.rank = page->index;
+		__free_page(page);
+	}
 
 	spin_lock_irqsave(&slob_lock, flags);
 	prev = slobfree;
@@ -105,7 +124,7 @@ static void *slob_alloc(size_t size, gfp
 			if (size == PAGE_SIZE) /* trying to shrink arena? */
 				return 0;
 
-			cur = (slob_t *)__get_free_page(gfp);
+			cur = (slob_t *)slob_get_free_pages(gfp, 0);
 			if (!cur)
 				return 0;
 
@@ -166,7 +185,7 @@ void *__kmalloc(size_t size, gfp_t gfp)
 		return 0;
 
 	bb->order = get_order(size);
-	bb->pages = (void *)__get_free_pages(gfp, bb->order);
+	bb->pages = (void *)slob_get_free_pages(gfp, bb->order);
 
 	if (bb->pages) {
 		spin_lock_irqsave(&block_lock, flags);
@@ -309,7 +328,7 @@ void *kmem_cache_alloc(struct kmem_cache
 	if (c->size < PAGE_SIZE)
 		b = slob_alloc(c->size, flags, c->align);
 	else
-		b = (void *)__get_free_pages(flags, get_order(c->size));
+		b = (void *)slob_get_free_pages(flags, get_order(c->size));
 
 	if (c->ctor)
 		c->ctor(b, c, SLAB_CTOR_CONSTRUCTOR);
Index: linux-2.6-git/mm/Kconfig
===================================================================
--- linux-2.6-git.orig/mm/Kconfig
+++ linux-2.6-git/mm/Kconfig
@@ -165,7 +165,6 @@ config ZONE_DMA_FLAG
 
 config SLAB_FAIR
 	def_bool n
-	depends on SLAB || SLUB
 
 config NR_QUICK
 	int

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
