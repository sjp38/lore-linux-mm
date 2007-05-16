Date: Wed, 16 May 2007 19:48:20 +0100
Subject: Re: [PATCH 2/2] Only check absolute watermarks for ALLOC_HIGH and ALLOC_HARDER allocations
Message-ID: <20070516184819.GF10225@skynet.ie>
References: <20070514173218.6787.56089.sendpatchset@skynet.skynet.ie> <20070514173259.6787.58533.sendpatchset@skynet.skynet.ie> <464AF589.2000000@yahoo.com.au> <20070516132419.GA18542@skynet.ie> <464B089C.9070805@yahoo.com.au> <20070516140038.GA10225@skynet.ie> <464B110E.2040309@yahoo.com.au> <464B4D43.9020002@shadowen.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <464B4D43.9020002@shadowen.org>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, clameter@sgi.com, nicolas.mailhot@laposte.net, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (16/05/07 19:28), Andy Whitcroft didst pronounce:
> Nick Piggin wrote:
> > Mel Gorman wrote:
> >> On (16/05/07 23:35), Nick Piggin didst pronounce:
> >>
> >>> Mel Gorman wrote:
> > 
> >>>> In page_alloc.c
> >>>>
> >>>>       if ((unlikely(rt_task(p)) && !in_interrupt()) || !wait)
> >>>>               alloc_flags |= ALLOC_HARDER;
> >>>>
> >>>> See the !wait part.
> >>>
> >>> And the || part.
> >>>
> >>
> >>
> >> I doubt a rt_task is thrilled to be entering direct reclaim.
> > 
> > Doesn't mean you should break the watermarks. !wait allocations don't
> > always happen from interrupt context either, and it is possible to see
> > code doing
> 
> The problem perhaps here is that we are not able to allocate at all
> despite having large amounts of memory free.  In the original problem
> report we had a failing order-2 allocation when order-7 pages were free,
> and we were over the reserve.
> 
> Indeed in experiments with this algorithm I am finding that it is common
> to fail an order 2 allocation when more than 2* the reserve is
> available.  More on this at the end ...
> 
> > if (!alloc(GFP_KERNEL&~__GFP_WAIT)) {
> >     spin_unlock()
> >     alloc(GFP_KERNEL)
> >     spin_lock()
> > }
> > 
> > 
> >>>> The ALLOC_HIGH applies to __GFP_HIGH allocations which are allowed to
> >>>> dip into emergency pools and go below the reserve.
> >>>
> >>> And some of them can sleep too.
> >>>
> >>
> >>
> >> If you feel very strongly about it, I can back out the ALLOC_HIGH part
> >> for
> >> __GFP_HIGH allocations but it looks like at a glance that users of
> >> __GFP_HIGH
> >> are not too keen on sleeping;
> > 
> > I feel strongly about not breaking these things which are specifically
> > there
> > for a reason and that are being changed seemingly because of the false
> > impression that kswapd doesn't proactively free pages for them.
> 
> The interaction with kswapd is not instantaneous.  When an allocation at
> high order fails to allocate at the low watermarks it will indeed wake
> up kswapd and that will work to release memory at the order specified.
> However, if it is already reclaiming at another order it will not switch
> up until it next completes a pass.  For an allocator who cannot sleep
> this is very likely to be too late.  This is never going to help a
> bursty allocator.
> 
> >>>> ALLOC_HARDER is an urgent allocation class.
> >>>
> >>> And HIGH is even more, and MEMALLOC even more again.
> >>>
> >>
> >>
> >> HIGH => ALLOC_HIGH => obey watermarks at order-0
> >>
> >> Somewhat counter-intuitively, with the current code if the allocation is
> >> a really high priority but can sleep, it can actually allocate without
> >> any
> >> watermarks at all
> > 
> > I didn't understand what you meant?
> > 
> > 
> >>>> What actually happens is that high-order allocations fail even though
> >>>> the watermarks are met because they cannot enter direct reclaim.
> >>>
> >>> Yeah, they fail leaving some spare for more urgent allocations. Like
> >>> how the order-0 allocations work.
> >>
> >>
> >> order-0 watermarks are still in place. After the patch, it is still not
> >> possible for the allocations to break the watermarks there.
> > 
> > The watermarks for higher order pages you could say are implicit but
> > still there. They are scaled down from the order-0 watermarks, so they
> > should behave in the same way. I just can't understand why you're
> > bypassing these if you think the order-0 behaviour is OK.
> 
> The problem is the watermarks for the higher orders are actually much
> stricter than for low orders.  This is a by product of the way in which
> the algorithm calculates the current free at each iteration, taking away
> the pages at smaller order.  The effective free pages at each order is
> scaled by the ratio of the free pages at that order to all the sum of
> all higher orders.  The effective min at each order is halved.
> 
> Due to the nature of the reclaim strategy we will always expect to see
> exponentially more order-0 pages than order-1 etc and so on, making it
> hugely more difficult to allocate a page at these higher orders.
> 
> >>> They should also kick kswapd to start freeing pages _before_ they start
> >>> failing too.
> >>>
> >>
> >>
> >> Should prehaps, but from what I read kswapd is only kicked into action
> >> when the first allocation attempt has already failed.
> > 
> > Well that's wrong unless you are allocating with GFP_THISNODE, in which
> > case that is specifically the behaviour that is asked for.
> 
> kswapd is kicked when we cannot allocate at the normal low water mark,
> we will then attempt a further allocation at min/2 etc.  However we are
> as likely to fail the second as the effective low water mark for higher
> order pages is significantly higher than for order-0.  So kswapd will be
> woken, but it has a huge job on its hands to get us from order-0 low
> order to order-N low water.  As we cannot sleep we are very likely to fail.
> 
> 
> I did some testing with the current algorithm in a test harness.  That
> testing seems to show that the effect of the reserve can be majorly
> higher than the real reserve.  If we look at the OOM from the original
> report we can see there was some 7700 pages free at the time of the
> allocation.  The effective reserve for an ALLOC_HARD allocation is only
> 711 pages, and yet we cannot allocate any pages over order-0.
> 
> total free: 7768
> reserve   : 1423
>    0    1    2    3    4    5    6    7    8    9   10
> 7560    0    8    0    1    1    0    1    0    0    0
> 
> allocation order : 0
> effective free   : 7768
> effective reserve: 711.5
> 
> allocation order : 1
> effective free   : 7767
> effective reserve: 711.5
> 0 207 355
> FAIL
> 
> 
> Looking at the figures above dispassionately it is hard to fault the
> logic of the allocator denying this allocation.  There are indeed very
> few pages at those orders and some (where possible) are reserved for
> PF_MEM tasks, for reclaim itself.  However, the reservation system takes
> no account of higher orders, so we can always end up in a situation
> where there only order-0 pages free; all higher orders have been split.
>  This gives us a constraint on all reclaim processing, it must only
> involve order-0 pages else it could deadlock.  BUT if that is true and
> reclaim only uses order-0 pages then there is in actually no point in
> retaining any PF_MEM reserve at higher order as it would never be used.
> 
> What does this mean:
> 
> 1) any slab which is used from the reclaim path _must_ use order-0
> allocations,
> 2) any slab which is allocated from atomically _should_ use order-0
> allocations.
> 
> My understanding is all slabs within a slub slab cache have to be the
> same order.  So we need to ensure that any slab that might be used from
> the reclaim path must only use order-0 pages.  Also it seems that any
> slab that is allocated from atomically will have to use order-0 pages in
> order to remain reliable.  Christoph, do we have any facility to tag
> caches to use a specific allocation order?

It may be possible with something like this (probably incomplete and definitly
untested) patch. Only the caches that are known offhand to be involved
in the reclaim path are marked up here, there probably are others that
should use the flag.

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc1-mm1-clean/fs/bio.c linux-2.6.22-rc1-mm1-slubatomic/fs/bio.c
--- linux-2.6.22-rc1-mm1-clean/fs/bio.c	2007-05-13 02:45:56.000000000 +0100
+++ linux-2.6.22-rc1-mm1-slubatomic/fs/bio.c	2007-05-16 19:37:22.000000000 +0100
@@ -1187,13 +1187,15 @@ static void __init biovec_init_slabs(voi
 
 		size = bvs->nr_vecs * sizeof(struct bio_vec);
 		bvs->slab = kmem_cache_create(bvs->name, size, 0,
-                                SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
+                                SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_USES_ATOMIC,
+				NULL, NULL);
 	}
 }
 
 static int __init init_bio(void)
 {
-	bio_slab = KMEM_CACHE(bio, SLAB_HWCACHE_ALIGN|SLAB_PANIC);
+	bio_slab = KMEM_CACHE(bio,
+				SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_USES_ATOMIC);
 
 	biovec_init_slabs();
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc1-mm1-clean/include/linux/slab.h linux-2.6.22-rc1-mm1-slubatomic/include/linux/slab.h
--- linux-2.6.22-rc1-mm1-clean/include/linux/slab.h	2007-05-16 10:54:18.000000000 +0100
+++ linux-2.6.22-rc1-mm1-slubatomic/include/linux/slab.h	2007-05-16 19:31:24.000000000 +0100
@@ -23,6 +23,7 @@ typedef struct kmem_cache kmem_cache_t _
 #define SLAB_DEBUG_FREE		0x00000100UL	/* DEBUG: Perform (expensive) checks on free */
 #define SLAB_RED_ZONE		0x00000400UL	/* DEBUG: Red zone objs in a cache */
 #define SLAB_POISON		0x00000800UL	/* DEBUG: Poison objects */
+#define SLAB_USES_ATOMIC	0x00001000UL	/* Slub uses atomic, must be order-0 */
 #define SLAB_HWCACHE_ALIGN	0x00002000UL	/* Align objs on cache lines */
 #define SLAB_CACHE_DMA		0x00004000UL	/* Use GFP_DMA memory */
 #define SLAB_STORE_USER		0x00010000UL	/* DEBUG: Store the last owner for bug hunting */
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc1-mm1-clean/lib/radix-tree.c linux-2.6.22-rc1-mm1-slubatomic/lib/radix-tree.c
--- linux-2.6.22-rc1-mm1-clean/lib/radix-tree.c	2007-05-16 10:54:18.000000000 +0100
+++ linux-2.6.22-rc1-mm1-slubatomic/lib/radix-tree.c	2007-05-16 19:36:18.000000000 +0100
@@ -1023,7 +1023,8 @@ void __init radix_tree_init(void)
 {
 	radix_tree_node_cachep = kmem_cache_create("radix_tree_node",
 			sizeof(struct radix_tree_node), 0,
-			SLAB_PANIC, radix_tree_node_ctor, NULL);
+			SLAB_PANIC|SLAB_USES_ATOMIC,
+			radix_tree_node_ctor, NULL);
 	radix_tree_init_maxindex();
 	hotcpu_notifier(radix_tree_callback, 0);
 }
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc1-mm1-clean/mm/slub.c linux-2.6.22-rc1-mm1-slubatomic/mm/slub.c
--- linux-2.6.22-rc1-mm1-clean/mm/slub.c	2007-05-16 10:54:19.000000000 +0100
+++ linux-2.6.22-rc1-mm1-slubatomic/mm/slub.c	2007-05-16 19:41:51.000000000 +0100
@@ -1978,7 +1978,11 @@ static int calculate_sizes(struct kmem_c
 	size = ALIGN(size, align);
 	s->size = size;
 
-	s->order = calculate_order(size);
+	if (flags & SLAB_USES_ATOMIC) {
+		BUG_ON(size > PAGE_SIZE);
+		s->order = 0;
+	} else
+		s->order = calculate_order(size);
 	if (s->order < 0)
 		return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
