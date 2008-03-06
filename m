Date: Thu, 6 Mar 2008 18:41:27 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/6] Use two zonelist that are filtered by GFP mask
Message-ID: <20080306184127.GB20085@csn.ul.ie>
References: <20080227214708.6858.53458.sendpatchset@localhost> <20080227214734.6858.9968.sendpatchset@localhost> <20080228133247.6a7b626f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080228133247.6a7b626f.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, ak@suse.de, clameter@sgi.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, rientjes@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On (28/02/08 13:32), Andrew Morton didst pronounce:
> On Wed, 27 Feb 2008 16:47:34 -0500
> Lee Schermerhorn <lee.schermerhorn@hp.com> wrote:
> 
> > +/* Returns the first zone at or below highest_zoneidx in a zonelist */
> > +static inline struct zone **first_zones_zonelist(struct zonelist *zonelist,
> > +					enum zone_type highest_zoneidx)
> > +{
> > +	struct zone **z;
> > +
> > +	/* Find the first suitable zone to use for the allocation */
> > +	z = zonelist->zones;
> > +	while (*z && zone_idx(*z) > highest_zoneidx)
> > +		z++;
> > +
> > +	return z;
> > +}
> > +
> > +/* Returns the next zone at or below highest_zoneidx in a zonelist */
> > +static inline struct zone **next_zones_zonelist(struct zone **z,
> > +					enum zone_type highest_zoneidx)
> > +{
> > +	/* Find the next suitable zone to use for the allocation */
> > +	while (*z && zone_idx(*z) > highest_zoneidx)
> > +		z++;
> > +
> > +	return z;
> > +}
> > +
> > +/**
> > + * for_each_zone_zonelist - helper macro to iterate over valid zones in a zonelist at or below a given zone index
> > + * @zone - The current zone in the iterator
> > + * @z - The current pointer within zonelist->zones being iterated
> > + * @zlist - The zonelist being iterated
> > + * @highidx - The zone index of the highest zone to return
> > + *
> > + * This iterator iterates though all zones at or below a given zone index.
> > + */
> > +#define for_each_zone_zonelist(zone, z, zlist, highidx) \
> > +	for (z = first_zones_zonelist(zlist, highidx), zone = *z++;	\
> > +		zone;							\
> > +		z = next_zones_zonelist(z, highidx), zone = *z++)
> > +
> 
> omygawd will that thing generate a lot of code!
> 
> It has four call sites in mm/oom_kill.c and the overall patchset increases
> mm/oom_kill.o's text section (x86_64 allmodconfig) from 3268 bytes to 3845.
> 
> vmscan.o and page_alloc.o also grew a lot.  otoh total vmlinux bloat from
> the patchset is only around 700 bytes, so I expect that with a little less
> insanity we could actually get an aggregate improvement here.
> 
> Some of the inlining in mmzone.h is just comical.  Some of it is obvious
> (first_zones_zonelist) and some of it is less obvious (pfn_present).
> 
> I applied these for testing but I really don't think we should be merging
> such easily-fixed regressions into mainline.  Could someone please take a
> look at de-porking core MM?
> 

Here is the first attempt at uninlining the the zonelist walking. It doesn't
use a callback iterator as that appeared at first glance as it would cause
more bloat. With the version of patches posted, the increase in text size
of vmlinux was 946 (x86_64 allmodconfig) and with this patch it's 613 so
it's a bit of an improvement.

Performance is still good. It's not a definitive gain or loss in comparison to
the two-zonelist as different machines show different results. In comparison
to the vanilla, it's still generally a win so for the reduction in text size,
it's likely worth it overall.

In comparison to two-zonelist the performance differences looks like

Kernbench Elapsed    time      -0.66      to 2.03
Kernbench Total  CPU           -0.73      to 0.94
Hackbench pipes-1              -8.23      to 29.65
Hackbench pipes-4              -8.10      to 10.98
Hackbench pipes-8              -17.55     to 8.66
Hackbench pipes-16             -12.15     to 3.16
Hackbench sockets-1            -6.90      to 11.78
Hackbench sockets-4            -1.75      to 3.89
Hackbench sockets-8            -7.53      to 5.78
Hackbench sockets-16           -3.78      to 5.89
TBench    clients-1            -1.98      to 12.01
TBench    clients-2            -3.83      to 11.02
TBench    clients-4            -4.49      to 6.32
TBench    clients-8            -5.65      to 5.76
DBench    clients-1-ext2       -5.13      to 0.98
DBench    clients-2-ext2       -2.42      to 8.07
DBench    clients-4-ext2       -4.64      to 1.92
DBench    clients-8-ext2       -5.57      to 9.90

DBench is the one I am most frowning at as another file-based microbench
showed huge variances but it's not clear why it would be particularly
sensitive.

Suggestions on how to improve the patch or alternatives?

==CUT HERE==
Subject: Uninline zonelist iterator helper functions

The order zones are accessed in is determined by a zonelist and the
iterator for it is for_each_zone_zonelist_nodemask(). That uses a number
of large inline functions that bloats the vmlinux file unnecessarily.
This patch uninlines one helper function and reduces the size of
another. Some iterator logic is then pushed to the uninlined function to
reduce text duplication

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 fs/buffer.c            |    4 ++-
 include/linux/mmzone.h |   62 +++++++------------------------------------------
 mm/mempolicy.c         |    4 ++-
 mm/mmzone.c            |   31 ++++++++++++++++++++++++
 mm/page_alloc.c        |   10 ++++++-
 5 files changed, 55 insertions(+), 56 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc2-mm1-1010_update_documentation/fs/buffer.c linux-2.6.25-rc2-mm1-1020_uninline/fs/buffer.c
--- linux-2.6.25-rc2-mm1-1010_update_documentation/fs/buffer.c	2008-03-03 14:39:40.000000000 +0000
+++ linux-2.6.25-rc2-mm1-1020_uninline/fs/buffer.c	2008-03-06 11:26:07.000000000 +0000
@@ -369,6 +369,7 @@ void invalidate_bdev(struct block_device
 static void free_more_memory(void)
 {
 	struct zoneref *zrefs;
+	struct zone *dummy;
 	int nid;
 
 	wakeup_pdflush(1024);
@@ -376,7 +377,8 @@ static void free_more_memory(void)
 
 	for_each_online_node(nid) {
 		zrefs = first_zones_zonelist(node_zonelist(nid, GFP_NOFS),
-						gfp_zone(GFP_NOFS), NULL);
+						gfp_zone(GFP_NOFS), NULL,
+						&dummy);
 		if (zrefs->zone)
 			try_to_free_pages(node_zonelist(nid, GFP_NOFS), 0,
 						GFP_NOFS);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc2-mm1-1010_update_documentation/include/linux/mmzone.h linux-2.6.25-rc2-mm1-1020_uninline/include/linux/mmzone.h
--- linux-2.6.25-rc2-mm1-1010_update_documentation/include/linux/mmzone.h	2008-03-03 14:39:40.000000000 +0000
+++ linux-2.6.25-rc2-mm1-1020_uninline/include/linux/mmzone.h	2008-03-06 11:14:59.000000000 +0000
@@ -750,59 +750,19 @@ static inline int zonelist_node_idx(stru
 #endif /* CONFIG_NUMA */
 }
 
-static inline void zoneref_set_zone(struct zone *zone, struct zoneref *zoneref)
-{
-	zoneref->zone = zone;
-	zoneref->zone_idx = zone_idx(zone);
-}
-
-static inline int zref_in_nodemask(struct zoneref *zref, nodemask_t *nodes)
-{
-#ifdef CONFIG_NUMA
-	return node_isset(zonelist_node_idx(zref), *nodes);
-#else
-	return 1;
-#endif /* CONFIG_NUMA */
-}
+struct zoneref *next_zones_zonelist(struct zoneref *z,
+					enum zone_type highest_zoneidx,
+					nodemask_t *nodes,
+					struct zone **zone);
 
 /* Returns the first zone at or below highest_zoneidx in a zonelist */
 static inline struct zoneref *first_zones_zonelist(struct zonelist *zonelist,
 					enum zone_type highest_zoneidx,
-					nodemask_t *nodes)
+					nodemask_t *nodes,
+					struct zone **zone)
 {
-	struct zoneref *z;
-
-	/* Find the first suitable zone to use for the allocation */
-	z = zonelist->_zonerefs;
-	if (likely(nodes == NULL))
-		while (zonelist_zone_idx(z) > highest_zoneidx)
-			z++;
-	else
-		while (zonelist_zone_idx(z) > highest_zoneidx ||
-				(z->zone && !zref_in_nodemask(z, nodes)))
-			z++;
-
-	return z;
-}
-
-/* Returns the next zone at or below highest_zoneidx in a zonelist */
-static inline struct zoneref *next_zones_zonelist(struct zoneref *z,
-					enum zone_type highest_zoneidx,
-					nodemask_t *nodes)
-{
-	/*
-	 * Find the next suitable zone to use for the allocation.
-	 * Only filter based on nodemask if it's set
-	 */
-	if (likely(nodes == NULL))
-		while (zonelist_zone_idx(z) > highest_zoneidx)
-			z++;
-	else
-		while (zonelist_zone_idx(z) > highest_zoneidx ||
-				(z->zone && !zref_in_nodemask(z, nodes)))
-			z++;
-
-	return z;
+	return next_zones_zonelist(zonelist->_zonerefs, highest_zoneidx, nodes,
+								zone);
 }
 
 /**
@@ -817,11 +777,9 @@ static inline struct zoneref *next_zones
  * within a given nodemask
  */
 #define for_each_zone_zonelist_nodemask(zone, z, zlist, highidx, nodemask) \
-	for (z = first_zones_zonelist(zlist, highidx, nodemask),	\
-					zone = zonelist_zone(z++);	\
+	for (z = first_zones_zonelist(zlist, highidx, nodemask, &zone);	\
 		zone;							\
-		z = next_zones_zonelist(z, highidx, nodemask),		\
-					zone = zonelist_zone(z++))
+		z = next_zones_zonelist(z, highidx, nodemask, &zone))	\
 
 /**
  * for_each_zone_zonelist - helper macro to iterate over valid zones in a zonelist at or below a given zone index
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc2-mm1-1010_update_documentation/mm/mempolicy.c linux-2.6.25-rc2-mm1-1020_uninline/mm/mempolicy.c
--- linux-2.6.25-rc2-mm1-1010_update_documentation/mm/mempolicy.c	2008-03-03 14:39:40.000000000 +0000
+++ linux-2.6.25-rc2-mm1-1020_uninline/mm/mempolicy.c	2008-03-06 12:17:30.000000000 +0000
@@ -1214,10 +1214,12 @@ unsigned slab_node(struct mempolicy *pol
 		 */
 		struct zonelist *zonelist;
 		struct zoneref *z;
+		struct zone *dummy;
 		enum zone_type highest_zoneidx = gfp_zone(GFP_KERNEL);
 		zonelist = &NODE_DATA(numa_node_id())->node_zonelists[0];
 		z = first_zones_zonelist(zonelist, highest_zoneidx,
-							&policy->v.nodes);
+							&policy->v.nodes,
+							&dummy);
 		return zonelist_node_idx(z);
 	}
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc2-mm1-1010_update_documentation/mm/mmzone.c linux-2.6.25-rc2-mm1-1020_uninline/mm/mmzone.c
--- linux-2.6.25-rc2-mm1-1010_update_documentation/mm/mmzone.c	2008-02-15 20:57:20.000000000 +0000
+++ linux-2.6.25-rc2-mm1-1020_uninline/mm/mmzone.c	2008-03-06 11:14:57.000000000 +0000
@@ -42,3 +42,34 @@ struct zone *next_zone(struct zone *zone
 	return zone;
 }
 
+static inline int zref_in_nodemask(struct zoneref *zref, nodemask_t *nodes)
+{
+#ifdef CONFIG_NUMA
+	return node_isset(zonelist_node_idx(zref), *nodes);
+#else
+	return 1;
+#endif /* CONFIG_NUMA */
+}
+
+
+/* Returns the next zone at or below highest_zoneidx in a zonelist */
+struct zoneref *next_zones_zonelist(struct zoneref *z,
+					enum zone_type highest_zoneidx,
+					nodemask_t *nodes,
+					struct zone **zone)
+{
+	/*
+	 * Find the next suitable zone to use for the allocation.
+	 * Only filter based on nodemask if it's set
+	 */
+	if (likely(nodes == NULL))
+		while (zonelist_zone_idx(z) > highest_zoneidx)
+			z++;
+	else
+		while (zonelist_zone_idx(z) > highest_zoneidx ||
+				(z->zone && !zref_in_nodemask(z, nodes)))
+			z++;
+
+	*zone = zonelist_zone(z++);
+	return z;
+}
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc2-mm1-1010_update_documentation/mm/page_alloc.c linux-2.6.25-rc2-mm1-1020_uninline/mm/page_alloc.c
--- linux-2.6.25-rc2-mm1-1010_update_documentation/mm/page_alloc.c	2008-03-03 14:39:40.000000000 +0000
+++ linux-2.6.25-rc2-mm1-1020_uninline/mm/page_alloc.c	2008-03-06 11:11:00.000000000 +0000
@@ -1398,9 +1398,9 @@ get_page_from_freelist(gfp_t gfp_mask, n
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
 
-	z = first_zones_zonelist(zonelist, high_zoneidx, nodemask);
+	z = first_zones_zonelist(zonelist, high_zoneidx, nodemask,
+							&preferred_zone);
 	classzone_idx = zonelist_zone_idx(z);
-	preferred_zone = zonelist_zone(z);
 
 zonelist_scan:
 	/*
@@ -1966,6 +1966,12 @@ void show_free_areas(void)
 	show_swap_cache_info();
 }
 
+static void zoneref_set_zone(struct zone *zone, struct zoneref *zoneref)
+{
+	zoneref->zone = zone;
+	zoneref->zone_idx = zone_idx(zone);
+}
+
 /*
  * Builds allocation fallback zone lists.
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
