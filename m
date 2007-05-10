Date: Fri, 11 May 2007 00:00:44 +0100
Subject: Re: [Bug 8464] New: autoreconf: page allocation failure. order:2, mode:0x84020
Message-ID: <20070510230044.GB15332@skynet.ie>
References: <200705102128.l4ALSI2A017437@fire-2.osdl.org> <20070510144319.48d2841a.akpm@linux-foundation.org> <Pine.LNX.4.64.0705101447120.12874@schroedinger.engr.sgi.com> <20070510220657.GA14694@skynet.ie> <Pine.LNX.4.64.0705101510500.13404@schroedinger.engr.sgi.com> <20070510221607.GA15084@skynet.ie> <Pine.LNX.4.64.0705101522250.13504@schroedinger.engr.sgi.com> <20070510224441.GA15332@skynet.ie> <Pine.LNX.4.64.0705101547020.14064@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705101547020.14064@schroedinger.engr.sgi.com>
From: mel@skynet.skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, Nicolas.Mailhot@LaPoste.net
Cc: Mel Gorman <mel@skynet.skynet.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "bugme-daemon@kernel-bugs.osdl.org" <bugme-daemon@bugzilla.kernel.org>
List-ID: <linux-mm.kvack.org>

On (10/05/07 15:49), Christoph Lameter didst pronounce:
> On Thu, 10 May 2007, Mel Gorman wrote:
> 
> > > I cannot predict how allocations on a slab will be performed. In order 
> > > to avoid the higher order allocations in we would have to add a flag 
> > > that tells SLUB at slab creation creation time that this cache will be 
> > > used for atomic allocs and thus we can avoid configuring slabs in such a 
> > > way that they use higher order allocs.
> > > 
> > 
> > It is an option. I had the gfp flags passed in to kmem_cache_create() in
> > mind for determining this but SLUB creates slabs differently and different
> > flags could be passed into kmem_cache_alloc() of course.
> 
> So we have a collection of flags to add
> 
> SLAB_USES_ATOMIC

This is a possibility.

> SLAB_TEMPORARY

I have a patch for this sitting in a queue waiting for testing

> SLAB_PERSISTENT
> SLAB_RECLAIMABLE
> SLAB_MOVABLE

I don't think these are required because the necessary information is
available from the GFP flags.

> 
> ?
> 
> > Another alternative is that anti-frag used to also group high-order
> > allocations together and make it hard to fallback to those areas
> > for non-atomic allocations. It is currently backed out by the
> > patch dont-group-high-order-atomic-allocations.patch because
> > it was intended for rare high-order short-lived allocations
> > such as e1000 that are currently dealt with by MIGRATE_RESERVE
> > (bias-the-location-of-pages-freed-for-min_free_kbytes-in-the-same-max_order_nr_pages-blocks.patch)
> >  The high-order atomic groupings may help here because the high-order
> > allocations are long-lived and would claim contiguous areas.
> > 
> > The last alternative I think I mentioned already is to have the minimum
> > order kswapd reclaims as the same order SLUB uses instead of 0 so that
> > min_free_kbytes is kept at higher orders than current.
> 
> Would you get a patch to Nicholas to test either of these solutions?

I do not have a kswapd related patch ready but the first alternative is
readily available.

Nicholas, could you backout the patch
dont-group-high-order-atomic-allocations.patch and test again please?
The following patch has the same effect. Thanks

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-clean/include/linux/mmzone.h linux-2.6.21-mm2-grouphigh/include/linux/mmzone.h
--- linux-2.6.21-mm2-clean/include/linux/mmzone.h	2007-05-09 10:21:28.000000000 +0100
+++ linux-2.6.21-mm2-grouphigh/include/linux/mmzone.h	2007-05-10 23:54:45.000000000 +0100
@@ -38,8 +38,9 @@ extern int page_group_by_mobility_disabl
 #define MIGRATE_UNMOVABLE     0
 #define MIGRATE_RECLAIMABLE   1
 #define MIGRATE_MOVABLE       2
-#define MIGRATE_RESERVE       3
-#define MIGRATE_TYPES         4
+#define MIGRATE_HIGHATOMIC    3
+#define MIGRATE_RESERVE       4
+#define MIGRATE_TYPES         5
 
 #define for_each_migratetype_order(order, type) \
 	for (order = 0; order < MAX_ORDER; order++) \
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-clean/include/linux/pageblock-flags.h linux-2.6.21-mm2-grouphigh/include/linux/pageblock-flags.h
--- linux-2.6.21-mm2-clean/include/linux/pageblock-flags.h	2007-05-09 10:21:28.000000000 +0100
+++ linux-2.6.21-mm2-grouphigh/include/linux/pageblock-flags.h	2007-05-10 23:54:45.000000000 +0100
@@ -31,7 +31,7 @@
 
 /* Bit indices that affect a whole block of pages */
 enum pageblock_bits {
-	PB_range(PB_migrate, 2), /* 2 bits required for migrate types */
+	PB_range(PB_migrate, 3), /* 3 bits required for migrate types */
 	NR_PAGEBLOCK_BITS
 };
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-clean/mm/page_alloc.c linux-2.6.21-mm2-grouphigh/mm/page_alloc.c
--- linux-2.6.21-mm2-clean/mm/page_alloc.c	2007-05-09 10:21:28.000000000 +0100
+++ linux-2.6.21-mm2-grouphigh/mm/page_alloc.c	2007-05-10 23:54:45.000000000 +0100
@@ -167,6 +167,11 @@ static inline int allocflags_to_migratet
 	if (unlikely(page_group_by_mobility_disabled))
 		return MIGRATE_UNMOVABLE;
 
+	/* Cluster high-order atomic allocations together */
+	if (unlikely(order > 0) &&
+			(!(gfp_flags & __GFP_WAIT) || in_interrupt()))
+		return MIGRATE_HIGHATOMIC;
+
 	/* Cluster based on mobility */
 	return (((gfp_flags & __GFP_MOVABLE) != 0) << 1) |
 		((gfp_flags & __GFP_RECLAIMABLE) != 0);
@@ -713,10 +718,11 @@ static struct page *__rmqueue_smallest(s
  * the free lists for the desirable migrate type are depleted
  */
 static int fallbacks[MIGRATE_TYPES][MIGRATE_TYPES-1] = {
-	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,   MIGRATE_RESERVE },
-	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,   MIGRATE_RESERVE },
-	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE },
-	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE,     MIGRATE_RESERVE,   MIGRATE_RESERVE }, /* Never used */
+	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,   MIGRATE_HIGHATOMIC, MIGRATE_RESERVE },
+	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,   MIGRATE_HIGHATOMIC, MIGRATE_RESERVE },
+	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_HIGHATOMIC, MIGRATE_RESERVE },
+	[MIGRATE_HIGHATOMIC]  = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_MOVABLE,    MIGRATE_RESERVE },
+	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE,     MIGRATE_RESERVE,   MIGRATE_RESERVE,    MIGRATE_RESERVE }, /* Never used */
 };
 
 /*
@@ -810,7 +816,9 @@ static struct page *__rmqueue_fallback(s
 	int current_order;
 	struct page *page;
 	int migratetype, i;
+	int nonatomic_fallback_atomic = 0;
 
+retry:
 	/* Find the largest possible block of pages in the other list */
 	for (current_order = MAX_ORDER-1; current_order >= order;
 						--current_order) {
@@ -820,6 +828,14 @@ static struct page *__rmqueue_fallback(s
 			/* MIGRATE_RESERVE handled later if necessary */
 			if (migratetype == MIGRATE_RESERVE)
 				continue;
+			/*
+			 * Make it hard to fallback to blocks used for
+			 * high-order atomic allocations
+			 */
+			if (migratetype == MIGRATE_HIGHATOMIC &&
+				start_migratetype != MIGRATE_UNMOVABLE &&
+				!nonatomic_fallback_atomic)
+				continue;
 
 			area = &(zone->free_area[current_order]);
 			if (list_empty(&area->free_list[migratetype]))
@@ -845,7 +861,8 @@ static struct page *__rmqueue_fallback(s
 								start_migratetype);
 
 				/* Claim the whole block if over half of it is free */
-				if ((pages << current_order) >= (1 << (MAX_ORDER-2)))
+				if ((pages << current_order) >= (1 << (MAX_ORDER-2)) &&
+						migratetype != MIGRATE_HIGHATOMIC)
 					set_pageblock_migratetype(page,
 								start_migratetype);
 
@@ -867,6 +884,12 @@ static struct page *__rmqueue_fallback(s
 		}
 	}
 
+	/* Allow fallback to high-order atomic blocks if memory is that low */
+	if (!nonatomic_fallback_atomic) {
+		nonatomic_fallback_atomic = 1;
+		goto retry;
+	}
+
 	/* Use MIGRATE_RESERVE rather than fail an allocation */
 	return __rmqueue_smallest(zone, order, MIGRATE_RESERVE);
 }
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
