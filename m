Subject: Re: [PATCH] add __GFP_ZERO to GFP_LEVEL_MASK
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1185256869.8197.27.camel@twins>
References: <1185185020.8197.11.camel@twins>
	 <20070723112143.GB19437@skynet.ie> <1185190711.8197.15.camel@twins>
	 <Pine.LNX.4.64.0707231615310.427@schroedinger.engr.sgi.com>
	 <1185256869.8197.27.camel@twins>
Content-Type: text/plain
Date: Tue, 24 Jul 2007 08:48:52 +0200
Message-Id: <1185259732.8197.30.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@skynet.ie>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Daniel Phillips <phillips@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-07-24 at 08:01 +0200, Peter Zijlstra wrote:

> Then we can either fixup the slab allocators to mask out __GFP_ZERO, or
> do something like the below.
> 
> Personally I like the consistency of adding __GFP_ZERO here (removes
> this odd exception) and just masking it in the sl[aou]b thingies.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/gfp.h |    2 +-
 mm/slab.c           |    4 +++-
 mm/slob.c           |    2 ++
 mm/slub.c           |    4 +++-
 4 files changed, 9 insertions(+), 3 deletions(-)

Index: linux-2.6-2/include/linux/gfp.h
===================================================================
--- linux-2.6-2.orig/include/linux/gfp.h
+++ linux-2.6-2/include/linux/gfp.h
@@ -56,7 +56,7 @@ struct vm_area_struct;
 /* if you forget to add the bitmask here kernel will crash, period */
 #define GFP_LEVEL_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS| \
 			__GFP_COLD|__GFP_NOWARN|__GFP_REPEAT| \
-			__GFP_NOFAIL|__GFP_NORETRY|__GFP_COMP| \
+			__GFP_NOFAIL|__GFP_NORETRY|__GFP_COMP|__GFP_ZERO| \
 			__GFP_NOMEMALLOC|__GFP_HARDWALL|__GFP_THISNODE| \
 			__GFP_MOVABLE)
 
Index: linux-2.6-2/mm/slab.c
===================================================================
--- linux-2.6-2.orig/mm/slab.c
+++ linux-2.6-2/mm/slab.c
@@ -2739,11 +2739,13 @@ static int cache_grow(struct kmem_cache 
 	gfp_t local_flags;
 	struct kmem_list3 *l3;
 
+	flags &= ~__GFP_ZERO; /* slab has its own object zeroing */
+
 	/*
 	 * Be lazy and only check for valid flags here,  keeping it out of the
 	 * critical path in kmem_cache_alloc().
 	 */
-	BUG_ON(flags & ~(GFP_DMA | __GFP_ZERO | GFP_LEVEL_MASK));
+	BUG_ON(flags & ~(GFP_DMA | GFP_LEVEL_MASK));
 
 	local_flags = (flags & GFP_LEVEL_MASK);
 	/* Take the l3 list lock to change the colour_next on this node */
Index: linux-2.6-2/mm/slob.c
===================================================================
--- linux-2.6-2.orig/mm/slob.c
+++ linux-2.6-2/mm/slob.c
@@ -223,6 +223,8 @@ static void *slob_new_page(gfp_t gfp, in
 {
 	void *page;
 
+	gfp &= ~__GFP_ZERO; /* slob has its own object zeroing */
+
 #ifdef CONFIG_NUMA
 	if (node != -1)
 		page = alloc_pages_node(node, gfp, order);
Index: linux-2.6-2/mm/slub.c
===================================================================
--- linux-2.6-2.orig/mm/slub.c
+++ linux-2.6-2/mm/slub.c
@@ -1078,7 +1078,9 @@ static struct page *new_slab(struct kmem
 	void *last;
 	void *p;
 
-	BUG_ON(flags & ~(GFP_DMA | __GFP_ZERO | GFP_LEVEL_MASK));
+	flags &= ~__GFP_ZERO; /* slab has its own object zeroing */
+
+	BUG_ON(flags & ~(GFP_DMA | GFP_LEVEL_MASK));
 
 	if (flags & __GFP_WAIT)
 		local_irq_enable();



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
