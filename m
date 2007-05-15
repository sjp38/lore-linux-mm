Date: Tue, 15 May 2007 20:52:06 +0100
Subject: Re: [PATCH 8/8] Mark page cache pages as __GFP_PAGECACHE instead of __GFP_MOVABLE
Message-ID: <20070515195206.GA14028@skynet.ie>
References: <20070515150311.16348.56826.sendpatchset@skynet.skynet.ie> <20070515150552.16348.15975.sendpatchset@skynet.skynet.ie> <Pine.LNX.4.64.0705151130250.31972@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705151130250.31972@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (15/05/07 11:31), Christoph Lameter didst pronounce:
> On Tue, 15 May 2007, Mel Gorman wrote:
> 
> > This patch marks page cache allocations as __GFP_PAGECACHE instead of
> > __GFP_MOVABLE. To make code easier to read, a set of three GFP flags are
> > added called GFP_PAGECACHE, GFP_NOFS_PAGECACHE and GFP_HIGHUSER_PAGECACHE.
> 
> What motivated this patch? Are there any special flags that are needed for 
> the pagecache? 
> 

Initially, it was for similar reasons to why GFP_TEMPORARY was defined
instead of using __GFP_RECLAIMABLE. It was clearer when reading the code if
an allocation was marked PAGECACHE even if it was implemented as __GFP_MOVABLE
for grouping purposes.

> Are there any special flags that are needed for
> the pagecache?
> 
 
Not at the moment in this patchset. However, I have another patch that groups
PAGECACHE pages separate to MOVABLE pages based on a __GFP_PAGECACHE flag. If
large pages were used for IO, it would make sense to group them together
from an internal fragmentation perspective. As readahead pages can exist
in private pools outside of the LRU, it also makes sense to keep page
cache pages away from movable pages referenced by page tables. It didn't
seem urgent enough to post now though.

> If we have this flag then we could move the functionality from
> __page_cache_alloc (mm/filemap.c) into the page allocator?
> 

If __GFP_PAGECACHE was being used, I think that __page_cache_alloc() could
be replaced by a call to alloc_pages() once the flag was set. I can look
into it because it sounds like a nice cleanup.

I've included the group-pagecache-pages-together patch below. I haven't tested
it in a while but you'll see how the __GFP_ flag is defined at least. The
part that defines the __GFP_PAGECACHE part can be easily separated out.

========

Subject: Group page cache pages together when grouping pages by mobility

Currently page cache pages are grouped with MOVABLE allocations. This appears
to work well in practice as page cache pages are usually reclaimable via
the LRU. However, this is not strictly correct as page cache pages can only
be cleaned and discarded, not migrated. During readahead, pages may also
exist on a pool for a period of time instead of on the LRU giving them a
differnet lifecycle to ordinary movable pages.

This patch adds a separate MIGRATE type for page cache pages so they are
grouped together. With the possibility of page cache using different page
sizes, it is benefical to have the same contigous blocks in the same blocks
to reduce interference from other allocation sizes.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>

---
 include/linux/gfp.h             |   34 +++++++++++++++++++++++++++-------
 include/linux/mmzone.h          |    5 +++--
 include/linux/pageblock-flags.h |    2 +-
 mm/page_alloc.c                 |    9 +++++----
 mm/vmstat.c                     |    1 +
 5 files changed, 37 insertions(+), 14 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-lameter_v2r7/include/linux/gfp.h linux-2.6.21-mm2-031_pagecache_gfp/include/linux/gfp.h
--- linux-2.6.21-mm2-lameter_v2r7/include/linux/gfp.h	2007-05-15 15:54:23.000000000 +0100
+++ linux-2.6.21-mm2-031_pagecache_gfp/include/linux/gfp.h	2007-05-15 20:36:55.000000000 +0100
@@ -50,8 +50,9 @@ struct vm_area_struct;
 #define __GFP_THISNODE	((__force gfp_t)0x40000u)/* No fallback, no policies */
 #define __GFP_RECLAIMABLE ((__force gfp_t)0x80000u) /* Page is reclaimable */
 #define __GFP_MOVABLE	((__force gfp_t)0x100000u)  /* Page is movable */
+#define __GFP_PAGECACHE ((__force gfp_t)0x200000u)  /* Page cache page */
 
-#define __GFP_BITS_SHIFT 21	/* Room for 21 __GFP_FOO bits */
+#define __GFP_BITS_SHIFT 22	/* Room for 22 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
 
 /* if you forget to add the bitmask here kernel will crash, period */
@@ -59,10 +60,10 @@ struct vm_area_struct;
 			__GFP_COLD|__GFP_NOWARN|__GFP_REPEAT| \
 			__GFP_NOFAIL|__GFP_NORETRY|__GFP_COMP| \
 			__GFP_NOMEMALLOC|__GFP_HARDWALL|__GFP_THISNODE| \
-			__GFP_RECLAIMABLE|__GFP_MOVABLE)
+			__GFP_RECLAIMABLE|__GFP_MOVABLE|__GFP_PAGECACHE)
 
 /* This mask makes up all the page movable related flags */
-#define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE)
+#define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE|__GFP_PAGECACHE)
 
 /* This equals 0, but use constants in case they ever change */
 #define GFP_NOWAIT	(GFP_ATOMIC & ~__GFP_HIGH)
@@ -79,12 +80,12 @@ struct vm_area_struct;
 #define GFP_HIGHUSER_MOVABLE	(__GFP_WAIT | __GFP_IO | __GFP_FS | \
 				 __GFP_HARDWALL | __GFP_HIGHMEM | \
 				 __GFP_MOVABLE)
-#define GFP_NOFS_PAGECACHE	(__GFP_WAIT | __GFP_IO | __GFP_MOVABLE)
+#define GFP_NOFS_PAGECACHE	(__GFP_WAIT | __GFP_IO | __GFP_PAGECACHE)
 #define GFP_USER_PAGECACHE	(__GFP_WAIT | __GFP_IO | __GFP_FS | \
-				 __GFP_HARDWALL | __GFP_MOVABLE)
+				 __GFP_HARDWALL | __GFP_PAGECACHE)
 #define GFP_HIGHUSER_PAGECACHE	(__GFP_WAIT | __GFP_IO | __GFP_FS | \
 				 __GFP_HARDWALL | __GFP_HIGHMEM | \
-				 __GFP_MOVABLE)
+				 __GFP_PAGECACHE)
 
 #ifdef CONFIG_NUMA
 #define GFP_THISNODE	(__GFP_THISNODE | __GFP_NOWARN | __GFP_NORETRY)
@@ -104,11 +105,27 @@ struct vm_area_struct;
 /* Convert GFP flags to their corresponding migrate type */
 static inline int allocflags_to_migratetype(gfp_t gfp_flags)
 {
-	WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
+#ifdef CONFIG_DEBUG_VM
+	/*
+	 * This is an expensive check for the valid usage of migrate flags when
+	 * DEBUG_VM is set. It seemed the quickest way to check for multiple
+	 * bits being set
+	 */
+	int nr_bits;
+	unsigned long mask = gfp_flags & GFP_MOVABLE_MASK;
+
+	for (nr_bits = 0; mask; nr_bits++)
+		mask ^= mask & -mask;
+	
+	BUG_ON(nr_bits > 1);
+#endif
 
 	if (unlikely(page_group_by_mobility_disabled))
 		return MIGRATE_UNMOVABLE;
 
+	if (gfp_flags & __GFP_PAGECACHE)
+		return MIGRATE_PAGECACHE;
+
 	/* Cluster based on mobility */
 	return (((gfp_flags & __GFP_MOVABLE) != 0) << 1) |
 		((gfp_flags & __GFP_RECLAIMABLE) != 0);
@@ -127,6 +144,9 @@ static inline enum zone_type gfp_zone(gf
 	if ((flags & (__GFP_HIGHMEM | __GFP_MOVABLE)) ==
 			(__GFP_HIGHMEM | __GFP_MOVABLE))
 		return ZONE_MOVABLE;
+	if ((flags & (__GFP_HIGHMEM | __GFP_PAGECACHE)) ==
+			(__GFP_HIGHMEM | __GFP_PAGECACHE))
+		return ZONE_MOVABLE;
 #ifdef CONFIG_HIGHMEM
 	if (flags & __GFP_HIGHMEM)
 		return ZONE_HIGHMEM;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-lameter_v2r7/include/linux/mmzone.h linux-2.6.21-mm2-031_pagecache_gfp/include/linux/mmzone.h
--- linux-2.6.21-mm2-lameter_v2r7/include/linux/mmzone.h	2007-05-15 15:54:22.000000000 +0100
+++ linux-2.6.21-mm2-031_pagecache_gfp/include/linux/mmzone.h	2007-05-15 20:36:55.000000000 +0100
@@ -38,8 +38,9 @@ extern int page_group_by_mobility_disabl
 #define MIGRATE_UNMOVABLE     0
 #define MIGRATE_RECLAIMABLE   1
 #define MIGRATE_MOVABLE       2
-#define MIGRATE_RESERVE       3
-#define MIGRATE_TYPES         4
+#define MIGRATE_PAGECACHE     3
+#define MIGRATE_RESERVE       4
+#define MIGRATE_TYPES         5
 
 #define for_each_migratetype_order(order, type) \
 	for (order = 0; order < MAX_ORDER; order++) \
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-lameter_v2r7/include/linux/pageblock-flags.h linux-2.6.21-mm2-031_pagecache_gfp/include/linux/pageblock-flags.h
--- linux-2.6.21-mm2-lameter_v2r7/include/linux/pageblock-flags.h	2007-05-15 15:54:22.000000000 +0100
+++ linux-2.6.21-mm2-031_pagecache_gfp/include/linux/pageblock-flags.h	2007-05-15 20:36:55.000000000 +0100
@@ -31,7 +31,7 @@
 
 /* Bit indices that affect a whole block of pages */
 enum pageblock_bits {
-	PB_range(PB_migrate, 2), /* 2 bits required for migrate types */
+	PB_range(PB_migrate, 3), /* 3 bits required for migrate types */
 	NR_PAGEBLOCK_BITS
 };
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-lameter_v2r7/mm/page_alloc.c linux-2.6.21-mm2-031_pagecache_gfp/mm/page_alloc.c
--- linux-2.6.21-mm2-lameter_v2r7/mm/page_alloc.c	2007-05-15 15:54:23.000000000 +0100
+++ linux-2.6.21-mm2-031_pagecache_gfp/mm/page_alloc.c	2007-05-15 20:36:55.000000000 +0100
@@ -697,10 +697,11 @@ static struct page *__rmqueue_smallest(s
  * the free lists for the desirable migrate type are depleted
  */
 static int fallbacks[MIGRATE_TYPES][MIGRATE_TYPES-1] = {
-	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,   MIGRATE_RESERVE },
-	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,   MIGRATE_RESERVE },
-	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE },
-	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE,     MIGRATE_RESERVE,   MIGRATE_RESERVE }, /* Never used */
+	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_PAGECACHE,   MIGRATE_MOVABLE,   MIGRATE_RESERVE },
+	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_PAGECACHE,   MIGRATE_MOVABLE,   MIGRATE_RESERVE },
+	[MIGRATE_MOVABLE]     = { MIGRATE_PAGECACHE,   MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE },
+	[MIGRATE_PAGECACHE]   = { MIGRATE_MOVABLE,     MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE },
+	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE,     MIGRATE_RESERVE,     MIGRATE_RESERVE,   MIGRATE_RESERVE }, /* Never used */
 };
 
 /*
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-lameter_v2r7/mm/vmstat.c linux-2.6.21-mm2-031_pagecache_gfp/mm/vmstat.c
--- linux-2.6.21-mm2-lameter_v2r7/mm/vmstat.c	2007-05-15 15:54:22.000000000 +0100
+++ linux-2.6.21-mm2-031_pagecache_gfp/mm/vmstat.c	2007-05-15 20:36:55.000000000 +0100
@@ -400,6 +400,7 @@ static char * const migratetype_names[MI
 	"Unmovable",
 	"Reclaimable",
 	"Movable",
+	"Pagecache",
 	"Reserve",
 };
 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
