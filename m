Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A1D3F6B0044
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 09:30:57 -0500 (EST)
Subject: Re: [patch] SLQB slab allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <Pine.LNX.4.64.0901231357250.9011@blonde.anvils>
References: <20090121143008.GV24891@wotan.suse.de>
	 <Pine.LNX.4.64.0901211705570.7020@blonde.anvils>
	 <84144f020901220201g6bdc2d5maf3395fc8b21fe67@mail.gmail.com>
	 <Pine.LNX.4.64.0901221239260.21677@blonde.anvils>
	 <Pine.LNX.4.64.0901231357250.9011@blonde.anvils>
Date: Fri, 23 Jan 2009 16:30:11 +0200
Message-Id: <1232721011.6094.70.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Hugh,

On Wed, Jan 21, 2009 at 8:10 PM, Hugh Dickins <hugh@veritas.com> wrote:
> > > > That's been making SLUB behave pretty badly (e.g. elapsed time 30%
> > > > more than SLAB) with swapping loads on most of my machines.  Though
> > > > oddly one seems immune, and another takes four times as long: guess
> > > > it depends on how close to thrashing, but probably more to investigate
> > > > there.  I think my original SLUB versus SLAB comparisons were done on
> > > > the immune one: as I remember, SLUB and SLAB were equivalent on those
> > > > loads when SLUB came in, but even with boot option slub_max_order=1,
> > > > SLUB is still slower than SLAB on such tests (e.g. 2% slower).
> > > > FWIW - swapping loads are not what anybody should tune for.

On Thu, 22 Jan 2009, Pekka Enberg wrote:
> > > What kind of machine are you seeing this on? It sounds like it could
> > > be a side-effect from commit 9b2cd506e5f2117f94c28a0040bf5da058105316
> > > ("slub: Calculate min_objects based on number of processors").

On Thu, 22 Jan 2009, Hugh Dickins wrote:
> > Thanks, yes, that could well account for the residual difference: the
> > machines in question have 2 or 4 cpus, so the old slub_min_objects=4
> > has effectively become slub_min_objects=12 or slub_min_objects=16.
> > 
> > I'm now trying with slub_max_order=1 slub_min_objects=4 on the boot
> > lines (though I'll need to curtail tests on a couple of machines),
> > and will report back later.

On Fri, 2009-01-23 at 14:23 +0000, Hugh Dickins wrote:
> Yes, slub_max_order=1 with slub_min_objects=4 certainly helps this
> swapping load.  I've not tried slub_max_order=0, but I'm running
> with 8kB stacks, so order 1 seems a reasonable choice.

Yanmin/Christoph, maybe we should revisit the min objects logic
calculate_order()?

On Fri, 2009-01-23 at 14:23 +0000, Hugh Dickins wrote:
> I can't say where I pulled that "e.g. 2% slower" from: on different
> machines slub was 5% or 10% or 20% slower than slab and slqb even with
> slub_max_order=1 (but not significantly slower on the "immune" machine).
> How much slub_min_objects=4 helps again varies widely, between halving
> or eliminating the difference.
> 
> But I think it's more important that I focus on the worst case machine,
> try to understand what's going on there.

Yeah. Oprofile and CONFIG_SLUB_STATS are usually quite helpful. You
might want to test the included patch which targets one known SLAB vs.
SLUB regression discovered quite recently.

			Pekka

Subject: [PATCH] SLUB: revert direct page allocator pass through
From: Pekka Enberg <penberg@cs.helsinki.fi>

This patch reverts page allocator pass-through logic from the SLUB allocator.

Commit aadb4bc4a1f9108c1d0fbd121827c936c2ed4217 ("SLUB: direct pass through of
page size or higher kmalloc requests") added page allocator pass-through to the
SLUB allocator for large sized allocations. This, however, results in a
performance regression compared to SLAB in the netperf UDP-U-4k test.

The regression comes from the kfree(skb->head) call in skb_release_data() that
is subject to page allocator pass-through as the size passed to __alloc_skb()
is larger than 4 KB in this test. With this patch, the performance regression
is almost closed:

  <insert numbers here>

Reported-by: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Tested-by: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 2f5c16b..3bd3662 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -124,7 +124,7 @@ struct kmem_cache {
  * We keep the general caches in an array of slab caches that are used for
  * 2^x bytes of allocations.
  */
-extern struct kmem_cache kmalloc_caches[PAGE_SHIFT + 1];
+extern struct kmem_cache kmalloc_caches[KMALLOC_SHIFT_HIGH + 1];
 
 /*
  * Sorry that the following has to be that ugly but some versions of GCC
@@ -135,6 +135,9 @@ static __always_inline int kmalloc_index(size_t size)
 	if (!size)
 		return 0;
 
+	if (size > KMALLOC_MAX_SIZE)
+		return -1;
+
 	if (size <= KMALLOC_MIN_SIZE)
 		return KMALLOC_SHIFT_LOW;
 
@@ -154,10 +157,6 @@ static __always_inline int kmalloc_index(size_t size)
 	if (size <=       1024) return 10;
 	if (size <=   2 * 1024) return 11;
 	if (size <=   4 * 1024) return 12;
-/*
- * The following is only needed to support architectures with a larger page
- * size than 4k.
- */
 	if (size <=   8 * 1024) return 13;
 	if (size <=  16 * 1024) return 14;
 	if (size <=  32 * 1024) return 15;
@@ -167,6 +166,10 @@ static __always_inline int kmalloc_index(size_t size)
 	if (size <= 512 * 1024) return 19;
 	if (size <= 1024 * 1024) return 20;
 	if (size <=  2 * 1024 * 1024) return 21;
+	if (size <=  4 * 1024 * 1024) return 22;
+	if (size <=  8 * 1024 * 1024) return 23;
+	if (size <= 16 * 1024 * 1024) return 24;
+	if (size <= 32 * 1024 * 1024) return 25;
 	return -1;
 
 /*
@@ -191,6 +194,19 @@ static __always_inline struct kmem_cache *kmalloc_slab(size_t size)
 	if (index == 0)
 		return NULL;
 
+	/*
+	 * This function only gets expanded if __builtin_constant_p(size), so
+	 * testing it here shouldn't be needed.  But some versions of gcc need
+	 * help.
+	 */
+	if (__builtin_constant_p(size) && index < 0) {
+		/*
+		 * Generate a link failure. Would be great if we could
+		 * do something to stop the compile here.
+		 */
+		extern void __kmalloc_size_too_large(void);
+		__kmalloc_size_too_large();
+	}
 	return &kmalloc_caches[index];
 }
 
@@ -204,17 +220,9 @@ static __always_inline struct kmem_cache *kmalloc_slab(size_t size)
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
 void *__kmalloc(size_t size, gfp_t flags);
 
-static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
-{
-	return (void *)__get_free_pages(flags | __GFP_COMP, get_order(size));
-}
-
 static __always_inline void *kmalloc(size_t size, gfp_t flags)
 {
 	if (__builtin_constant_p(size)) {
-		if (size > PAGE_SIZE)
-			return kmalloc_large(size, flags);
-
 		if (!(flags & SLUB_DMA)) {
 			struct kmem_cache *s = kmalloc_slab(size);
 
diff --git a/mm/slub.c b/mm/slub.c
index 6392ae5..8fad23f 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2475,7 +2475,7 @@ EXPORT_SYMBOL(kmem_cache_destroy);
  *		Kmalloc subsystem
  *******************************************************************/
 
-struct kmem_cache kmalloc_caches[PAGE_SHIFT + 1] __cacheline_aligned;
+struct kmem_cache kmalloc_caches[KMALLOC_SHIFT_HIGH + 1] __cacheline_aligned;
 EXPORT_SYMBOL(kmalloc_caches);
 
 static int __init setup_slub_min_order(char *str)
@@ -2537,7 +2537,7 @@ panic:
 }
 
 #ifdef CONFIG_ZONE_DMA
-static struct kmem_cache *kmalloc_caches_dma[PAGE_SHIFT + 1];
+static struct kmem_cache *kmalloc_caches_dma[KMALLOC_SHIFT_HIGH + 1];
 
 static void sysfs_add_func(struct work_struct *w)
 {
@@ -2643,8 +2643,12 @@ static struct kmem_cache *get_slab(size_t size, gfp_t flags)
 			return ZERO_SIZE_PTR;
 
 		index = size_index[(size - 1) / 8];
-	} else
+	} else {
+		if (size > KMALLOC_MAX_SIZE)
+			return NULL;
+
 		index = fls(size - 1);
+	}
 
 #ifdef CONFIG_ZONE_DMA
 	if (unlikely((flags & SLUB_DMA)))
@@ -2658,9 +2662,6 @@ void *__kmalloc(size_t size, gfp_t flags)
 {
 	struct kmem_cache *s;
 
-	if (unlikely(size > PAGE_SIZE))
-		return kmalloc_large(size, flags);
-
 	s = get_slab(size, flags);
 
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
@@ -2670,25 +2671,11 @@ void *__kmalloc(size_t size, gfp_t flags)
 }
 EXPORT_SYMBOL(__kmalloc);
 
-static void *kmalloc_large_node(size_t size, gfp_t flags, int node)
-{
-	struct page *page = alloc_pages_node(node, flags | __GFP_COMP,
-						get_order(size));
-
-	if (page)
-		return page_address(page);
-	else
-		return NULL;
-}
-
 #ifdef CONFIG_NUMA
 void *__kmalloc_node(size_t size, gfp_t flags, int node)
 {
 	struct kmem_cache *s;
 
-	if (unlikely(size > PAGE_SIZE))
-		return kmalloc_large_node(size, flags, node);
-
 	s = get_slab(size, flags);
 
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
@@ -2746,11 +2733,8 @@ void kfree(const void *x)
 		return;
 
 	page = virt_to_head_page(x);
-	if (unlikely(!PageSlab(page))) {
-		BUG_ON(!PageCompound(page));
-		put_page(page);
+	if (unlikely(WARN_ON(!PageSlab(page)))) /* XXX */
 		return;
-	}
 	slab_free(page->slab, page, object, _RET_IP_);
 }
 EXPORT_SYMBOL(kfree);
@@ -2985,7 +2969,7 @@ void __init kmem_cache_init(void)
 		caches++;
 	}
 
-	for (i = KMALLOC_SHIFT_LOW; i <= PAGE_SHIFT; i++) {
+	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
 		create_kmalloc_cache(&kmalloc_caches[i],
 			"kmalloc", 1 << i, GFP_KERNEL);
 		caches++;
@@ -3022,7 +3006,7 @@ void __init kmem_cache_init(void)
 	slab_state = UP;
 
 	/* Provide the correct kmalloc names now that the caches are up */
-	for (i = KMALLOC_SHIFT_LOW; i <= PAGE_SHIFT; i++)
+	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++)
 		kmalloc_caches[i]. name =
 			kasprintf(GFP_KERNEL, "kmalloc-%d", 1 << i);
 
@@ -3222,9 +3206,6 @@ void *__kmalloc_track_caller(size_t size, gfp_t gfpflags, unsigned long caller)
 {
 	struct kmem_cache *s;
 
-	if (unlikely(size > PAGE_SIZE))
-		return kmalloc_large(size, gfpflags);
-
 	s = get_slab(size, gfpflags);
 
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
@@ -3238,9 +3219,6 @@ void *__kmalloc_node_track_caller(size_t size, gfp_t gfpflags,
 {
 	struct kmem_cache *s;
 
-	if (unlikely(size > PAGE_SIZE))
-		return kmalloc_large_node(size, gfpflags, node);
-
 	s = get_slab(size, gfpflags);
 
 	if (unlikely(ZERO_OR_NULL_PTR(s)))


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
