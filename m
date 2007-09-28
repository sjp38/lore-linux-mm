Date: Fri, 28 Sep 2007 19:28:26 +0100
Subject: Re: [PATCH 5/6] Filter based on a nodemask as well as a gfp_mask
Message-ID: <20070928182825.GA9779@skynet.ie>
References: <20070928142326.16783.98817.sendpatchset@skynet.skynet.ie> <20070928142506.16783.99266.sendpatchset@skynet.skynet.ie> <1190993823.5513.10.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1190993823.5513.10.camel@localhost>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On (28/09/07 11:37), Lee Schermerhorn didst pronounce:
> Still need to fix 'nodes_intersect' -> 'nodes_intersects'.  See below.
> 
> On Fri, 2007-09-28 at 15:25 +0100, Mel Gorman wrote:
> > The MPOL_BIND policy creates a zonelist that is used for allocations belonging
> > to that thread that can use the policy_zone. As the per-node zonelist is
> > already being filtered based on a zone id, this patch adds a version of
> > __alloc_pages() that takes a nodemask for further filtering. This eliminates
> > the need for MPOL_BIND to create a custom zonelist. A positive benefit of
> > this is that allocations using MPOL_BIND now use the local-node-ordered
> > zonelist instead of a custom node-id-ordered zonelist.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > Acked-by: Christoph Lameter <clameter@sgi.com>
> > ---
> > 
> >  fs/buffer.c               |    2 
> >  include/linux/cpuset.h    |    4 -
> >  include/linux/gfp.h       |    4 +
> >  include/linux/mempolicy.h |    3 
> >  include/linux/mmzone.h    |   58 +++++++++++++---
> >  kernel/cpuset.c           |   18 +----
> >  mm/mempolicy.c            |  144 +++++++++++------------------------------
> >  mm/page_alloc.c           |   40 +++++++----
> >  8 files changed, 131 insertions(+), 142 deletions(-)
> > 
> > diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-020_zoneid_zonelist/fs/buffer.c linux-2.6.23-rc8-mm2-030_filter_nodemask/fs/buffer.c
> > --- linux-2.6.23-rc8-mm2-020_zoneid_zonelist/fs/buffer.c	2007-09-28 15:49:39.000000000 +0100
> > +++ linux-2.6.23-rc8-mm2-030_filter_nodemask/fs/buffer.c	2007-09-28 15:49:57.000000000 +0100
> > @@ -376,7 +376,7 @@ static void free_more_memory(void)
> >  
> >  	for_each_online_node(nid) {
> >  		zrefs = first_zones_zonelist(node_zonelist(nid, GFP_NOFS),
> > -						gfp_zone(GFP_NOFS));
> > +						NULL, gfp_zone(GFP_NOFS));
> >  		if (zrefs->zone)
> >  			try_to_free_pages(node_zonelist(nid, GFP_NOFS), 0,
> >  						GFP_NOFS);
> > diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-020_zoneid_zonelist/include/linux/cpuset.h linux-2.6.23-rc8-mm2-030_filter_nodemask/include/linux/cpuset.h
> > --- linux-2.6.23-rc8-mm2-020_zoneid_zonelist/include/linux/cpuset.h	2007-09-27 14:41:05.000000000 +0100
> > +++ linux-2.6.23-rc8-mm2-030_filter_nodemask/include/linux/cpuset.h	2007-09-28 15:49:57.000000000 +0100
> > @@ -28,7 +28,7 @@ void cpuset_init_current_mems_allowed(vo
> >  void cpuset_update_task_memory_state(void);
> >  #define cpuset_nodes_subset_current_mems_allowed(nodes) \
> >  		nodes_subset((nodes), current->mems_allowed)
> > -int cpuset_zonelist_valid_mems_allowed(struct zonelist *zl);
> > +int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask);
> >  
> >  extern int __cpuset_zone_allowed_softwall(struct zone *z, gfp_t gfp_mask);
> >  extern int __cpuset_zone_allowed_hardwall(struct zone *z, gfp_t gfp_mask);
> > @@ -103,7 +103,7 @@ static inline void cpuset_init_current_m
> >  static inline void cpuset_update_task_memory_state(void) {}
> >  #define cpuset_nodes_subset_current_mems_allowed(nodes) (1)
> >  
> > -static inline int cpuset_zonelist_valid_mems_allowed(struct zonelist *zl)
> > +static inline int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask)
> >  {
> >  	return 1;
> >  }
> > diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-020_zoneid_zonelist/include/linux/gfp.h linux-2.6.23-rc8-mm2-030_filter_nodemask/include/linux/gfp.h
> > --- linux-2.6.23-rc8-mm2-020_zoneid_zonelist/include/linux/gfp.h	2007-09-28 15:49:16.000000000 +0100
> > +++ linux-2.6.23-rc8-mm2-030_filter_nodemask/include/linux/gfp.h	2007-09-28 15:49:57.000000000 +0100
> > @@ -184,6 +184,10 @@ static inline void arch_alloc_page(struc
> >  extern struct page *
> >  FASTCALL(__alloc_pages(gfp_t, unsigned int, struct zonelist *));
> >  
> > +extern struct page *
> > +FASTCALL(__alloc_pages_nodemask(gfp_t, unsigned int,
> > +				struct zonelist *, nodemask_t *nodemask));
> > +
> >  static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
> >  						unsigned int order)
> >  {
> > diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-020_zoneid_zonelist/include/linux/mempolicy.h linux-2.6.23-rc8-mm2-030_filter_nodemask/include/linux/mempolicy.h
> > --- linux-2.6.23-rc8-mm2-020_zoneid_zonelist/include/linux/mempolicy.h	2007-09-28 15:48:55.000000000 +0100
> > +++ linux-2.6.23-rc8-mm2-030_filter_nodemask/include/linux/mempolicy.h	2007-09-28 15:49:57.000000000 +0100
> > @@ -64,9 +64,8 @@ struct mempolicy {
> >  	atomic_t refcnt;
> >  	short policy; 	/* See MPOL_* above */
> >  	union {
> > -		struct zonelist  *zonelist;	/* bind */
> >  		short 		 preferred_node; /* preferred */
> > -		nodemask_t	 nodes;		/* interleave */
> > +		nodemask_t	 nodes;		/* interleave/bind */
> >  		/* undefined for default */
> >  	} v;
> >  	nodemask_t cpuset_mems_allowed;	/* mempolicy relative to these nodes */
> > diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-020_zoneid_zonelist/include/linux/mmzone.h linux-2.6.23-rc8-mm2-030_filter_nodemask/include/linux/mmzone.h
> > --- linux-2.6.23-rc8-mm2-020_zoneid_zonelist/include/linux/mmzone.h	2007-09-28 15:49:39.000000000 +0100
> > +++ linux-2.6.23-rc8-mm2-030_filter_nodemask/include/linux/mmzone.h	2007-09-28 15:49:57.000000000 +0100
> > @@ -758,47 +758,85 @@ static inline void encode_zoneref(struct
> >  	zoneref->zone_idx = zone_idx(zone);
> >  }
> >  
> > +static inline int zref_in_nodemask(struct zoneref *zref, nodemask_t *nodes)
> > +{
> > +#ifdef CONFIG_NUMA
> > +	return node_isset(zonelist_node_idx(zref), *nodes);
> > +#else
> > +	return 1;
> > +#endif /* CONFIG_NUMA */
> > +}
> > +
> >  /* Returns the first zone at or below highest_zoneidx in a zonelist */
> >  static inline struct zoneref *first_zones_zonelist(struct zonelist *zonelist,
> > +					nodemask_t *nodes,
> >  					enum zone_type highest_zoneidx)
> >  {
> >  	struct zoneref *z;
> >  
> >  	/* Find the first suitable zone to use for the allocation */
> >  	z = zonelist->_zonerefs;
> > -	while (zonelist_zone_idx(z) > highest_zoneidx)
> > -		z++;
> > +	if (likely(nodes == NULL))
> > +		while (zonelist_zone_idx(z) > highest_zoneidx)
> > +			z++;
> > +	else
> > +		while (zonelist_zone_idx(z) > highest_zoneidx ||
> > +				(z->zone && !zref_in_nodemask(z, nodes)))
> > +			z++;
> >  
> >  	return z;
> >  }
> >  
> >  /* Returns the next zone at or below highest_zoneidx in a zonelist */
> >  static inline struct zoneref *next_zones_zonelist(struct zoneref *z,
> > +					nodemask_t *nodes,
> >  					enum zone_type highest_zoneidx)
> >  {
> > -	/* Find the next suitable zone to use for the allocation */
> > -	while (zonelist_zone_idx(z) > highest_zoneidx)
> > -		z++;
> > +	/*
> > +	 * Find the next suitable zone to use for the allocation.
> > +	 * Only filter based on nodemask if it's set
> > +	 */
> > +	if (likely(nodes == NULL))
> > +		while (zonelist_zone_idx(z) > highest_zoneidx)
> > +			z++;
> > +	else
> > +		while (zonelist_zone_idx(z) > highest_zoneidx ||
> > +				(z->zone && !zref_in_nodemask(z, nodes)))
> > +			z++;
> >  
> >  	return z;
> >  }
> >  
> >  /**
> > - * for_each_zone_zonelist - helper macro to iterate over valid zones in a zonelist at or below a given zone index
> > + * for_each_zone_zonelist_nodemask - helper macro to iterate over valid zones in a zonelist at or below a given zone index and within a nodemask
> >   * @zone - The current zone in the iterator
> >   * @z - The current pointer within zonelist->zones being iterated
> >   * @zlist - The zonelist being iterated
> >   * @highidx - The zone index of the highest zone to return
> > + * @nodemask - Nodemask allowed by the allocator
> >   *
> > - * This iterator iterates though all zones at or below a given zone index.
> > + * This iterator iterates though all zones at or below a given zone index and
> > + * within a given nodemask
> >   */
> > -#define for_each_zone_zonelist(zone, z, zlist, highidx) \
> > -	for (z = first_zones_zonelist(zlist, highidx),			\
> > +#define for_each_zone_zonelist_nodemask(zone, z, zlist, highidx, nodemask) \
> > +	for (z = first_zones_zonelist(zlist, nodemask, highidx),	\
> >  					zone = zonelist_zone(z++);	\
> >  		zone;							\
> > -		z = next_zones_zonelist(z, highidx),			\
> > +		z = next_zones_zonelist(z, nodemask, highidx),		\
> >  					zone = zonelist_zone(z++))
> >  
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
> > +	for_each_zone_zonelist_nodemask(zone, z, zlist, highidx, NULL)
> > +
> >  #ifdef CONFIG_SPARSEMEM
> >  #include <asm/sparsemem.h>
> >  #endif
> > diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-020_zoneid_zonelist/kernel/cpuset.c linux-2.6.23-rc8-mm2-030_filter_nodemask/kernel/cpuset.c
> > --- linux-2.6.23-rc8-mm2-020_zoneid_zonelist/kernel/cpuset.c	2007-09-28 15:49:39.000000000 +0100
> > +++ linux-2.6.23-rc8-mm2-030_filter_nodemask/kernel/cpuset.c	2007-09-28 15:49:57.000000000 +0100
> > @@ -1516,22 +1516,14 @@ nodemask_t cpuset_mems_allowed(struct ta
> >  }
> >  
> >  /**
> > - * cpuset_zonelist_valid_mems_allowed - check zonelist vs. curremt mems_allowed
> > - * @zl: the zonelist to be checked
> > + * cpuset_nodemask_valid_mems_allowed - check nodemask vs. curremt mems_allowed
> > + * @nodemask: the nodemask to be checked
> >   *
> > - * Are any of the nodes on zonelist zl allowed in current->mems_allowed?
> > + * Are any of the nodes in the nodemask allowed in current->mems_allowed?
> >   */
> > -int cpuset_zonelist_valid_mems_allowed(struct zonelist *zl)
> > +int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask)
> >  {
> > -	int i;
> > -
> > -	for (i = 0; zl->_zonerefs[i].zone; i++) {
> > -		int nid = zonelist_node_idx(zl->_zonerefs[i]);
> > -
> > -		if (node_isset(nid, current->mems_allowed))
> > -			return 1;
> > -	}
> > -	return 0;
> > +	return nodes_intersect(nodemask, current->mems_allowed);
>                  ^^^^^^^^^^^^^^^ -- should be nodes_intersects, I think.

Crap, you're right, I missed the warning about implicit declarations. I
apologise. This is the corrected version

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-020_zoneid_zonelist/fs/buffer.c linux-2.6.23-rc8-mm2-030_filter_nodemask/fs/buffer.c
--- linux-2.6.23-rc8-mm2-020_zoneid_zonelist/fs/buffer.c	2007-09-28 19:23:05.000000000 +0100
+++ linux-2.6.23-rc8-mm2-030_filter_nodemask/fs/buffer.c	2007-09-28 19:23:14.000000000 +0100
@@ -376,7 +376,7 @@ static void free_more_memory(void)
 
 	for_each_online_node(nid) {
 		zrefs = first_zones_zonelist(node_zonelist(nid, GFP_NOFS),
-						gfp_zone(GFP_NOFS));
+						NULL, gfp_zone(GFP_NOFS));
 		if (zrefs->zone)
 			try_to_free_pages(node_zonelist(nid, GFP_NOFS), 0,
 						GFP_NOFS);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-020_zoneid_zonelist/include/linux/cpuset.h linux-2.6.23-rc8-mm2-030_filter_nodemask/include/linux/cpuset.h
--- linux-2.6.23-rc8-mm2-020_zoneid_zonelist/include/linux/cpuset.h	2007-09-28 19:22:22.000000000 +0100
+++ linux-2.6.23-rc8-mm2-030_filter_nodemask/include/linux/cpuset.h	2007-09-28 19:23:14.000000000 +0100
@@ -28,7 +28,7 @@ void cpuset_init_current_mems_allowed(vo
 void cpuset_update_task_memory_state(void);
 #define cpuset_nodes_subset_current_mems_allowed(nodes) \
 		nodes_subset((nodes), current->mems_allowed)
-int cpuset_zonelist_valid_mems_allowed(struct zonelist *zl);
+int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask);
 
 extern int __cpuset_zone_allowed_softwall(struct zone *z, gfp_t gfp_mask);
 extern int __cpuset_zone_allowed_hardwall(struct zone *z, gfp_t gfp_mask);
@@ -103,7 +103,7 @@ static inline void cpuset_init_current_m
 static inline void cpuset_update_task_memory_state(void) {}
 #define cpuset_nodes_subset_current_mems_allowed(nodes) (1)
 
-static inline int cpuset_zonelist_valid_mems_allowed(struct zonelist *zl)
+static inline int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask)
 {
 	return 1;
 }
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-020_zoneid_zonelist/include/linux/gfp.h linux-2.6.23-rc8-mm2-030_filter_nodemask/include/linux/gfp.h
--- linux-2.6.23-rc8-mm2-020_zoneid_zonelist/include/linux/gfp.h	2007-09-28 19:22:56.000000000 +0100
+++ linux-2.6.23-rc8-mm2-030_filter_nodemask/include/linux/gfp.h	2007-09-28 19:23:14.000000000 +0100
@@ -184,6 +184,10 @@ static inline void arch_alloc_page(struc
 extern struct page *
 FASTCALL(__alloc_pages(gfp_t, unsigned int, struct zonelist *));
 
+extern struct page *
+FASTCALL(__alloc_pages_nodemask(gfp_t, unsigned int,
+				struct zonelist *, nodemask_t *nodemask));
+
 static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 						unsigned int order)
 {
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-020_zoneid_zonelist/include/linux/mempolicy.h linux-2.6.23-rc8-mm2-030_filter_nodemask/include/linux/mempolicy.h
--- linux-2.6.23-rc8-mm2-020_zoneid_zonelist/include/linux/mempolicy.h	2007-09-28 19:22:46.000000000 +0100
+++ linux-2.6.23-rc8-mm2-030_filter_nodemask/include/linux/mempolicy.h	2007-09-28 19:23:14.000000000 +0100
@@ -64,9 +64,8 @@ struct mempolicy {
 	atomic_t refcnt;
 	short policy; 	/* See MPOL_* above */
 	union {
-		struct zonelist  *zonelist;	/* bind */
 		short 		 preferred_node; /* preferred */
-		nodemask_t	 nodes;		/* interleave */
+		nodemask_t	 nodes;		/* interleave/bind */
 		/* undefined for default */
 	} v;
 	nodemask_t cpuset_mems_allowed;	/* mempolicy relative to these nodes */
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-020_zoneid_zonelist/include/linux/mmzone.h linux-2.6.23-rc8-mm2-030_filter_nodemask/include/linux/mmzone.h
--- linux-2.6.23-rc8-mm2-020_zoneid_zonelist/include/linux/mmzone.h	2007-09-28 19:23:05.000000000 +0100
+++ linux-2.6.23-rc8-mm2-030_filter_nodemask/include/linux/mmzone.h	2007-09-28 19:23:14.000000000 +0100
@@ -758,47 +758,85 @@ static inline void encode_zoneref(struct
 	zoneref->zone_idx = zone_idx(zone);
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
 /* Returns the first zone at or below highest_zoneidx in a zonelist */
 static inline struct zoneref *first_zones_zonelist(struct zonelist *zonelist,
+					nodemask_t *nodes,
 					enum zone_type highest_zoneidx)
 {
 	struct zoneref *z;
 
 	/* Find the first suitable zone to use for the allocation */
 	z = zonelist->_zonerefs;
-	while (zonelist_zone_idx(z) > highest_zoneidx)
-		z++;
+	if (likely(nodes == NULL))
+		while (zonelist_zone_idx(z) > highest_zoneidx)
+			z++;
+	else
+		while (zonelist_zone_idx(z) > highest_zoneidx ||
+				(z->zone && !zref_in_nodemask(z, nodes)))
+			z++;
 
 	return z;
 }
 
 /* Returns the next zone at or below highest_zoneidx in a zonelist */
 static inline struct zoneref *next_zones_zonelist(struct zoneref *z,
+					nodemask_t *nodes,
 					enum zone_type highest_zoneidx)
 {
-	/* Find the next suitable zone to use for the allocation */
-	while (zonelist_zone_idx(z) > highest_zoneidx)
-		z++;
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
 
 	return z;
 }
 
 /**
- * for_each_zone_zonelist - helper macro to iterate over valid zones in a zonelist at or below a given zone index
+ * for_each_zone_zonelist_nodemask - helper macro to iterate over valid zones in a zonelist at or below a given zone index and within a nodemask
  * @zone - The current zone in the iterator
  * @z - The current pointer within zonelist->zones being iterated
  * @zlist - The zonelist being iterated
  * @highidx - The zone index of the highest zone to return
+ * @nodemask - Nodemask allowed by the allocator
  *
- * This iterator iterates though all zones at or below a given zone index.
+ * This iterator iterates though all zones at or below a given zone index and
+ * within a given nodemask
  */
-#define for_each_zone_zonelist(zone, z, zlist, highidx) \
-	for (z = first_zones_zonelist(zlist, highidx),			\
+#define for_each_zone_zonelist_nodemask(zone, z, zlist, highidx, nodemask) \
+	for (z = first_zones_zonelist(zlist, nodemask, highidx),	\
 					zone = zonelist_zone(z++);	\
 		zone;							\
-		z = next_zones_zonelist(z, highidx),			\
+		z = next_zones_zonelist(z, nodemask, highidx),		\
 					zone = zonelist_zone(z++))
 
+/**
+ * for_each_zone_zonelist - helper macro to iterate over valid zones in a zonelist at or below a given zone index
+ * @zone - The current zone in the iterator
+ * @z - The current pointer within zonelist->zones being iterated
+ * @zlist - The zonelist being iterated
+ * @highidx - The zone index of the highest zone to return
+ *
+ * This iterator iterates though all zones at or below a given zone index.
+ */
+#define for_each_zone_zonelist(zone, z, zlist, highidx) \
+	for_each_zone_zonelist_nodemask(zone, z, zlist, highidx, NULL)
+
 #ifdef CONFIG_SPARSEMEM
 #include <asm/sparsemem.h>
 #endif
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-020_zoneid_zonelist/kernel/cpuset.c linux-2.6.23-rc8-mm2-030_filter_nodemask/kernel/cpuset.c
--- linux-2.6.23-rc8-mm2-020_zoneid_zonelist/kernel/cpuset.c	2007-09-28 19:23:05.000000000 +0100
+++ linux-2.6.23-rc8-mm2-030_filter_nodemask/kernel/cpuset.c	2007-09-28 19:27:01.000000000 +0100
@@ -1516,22 +1516,14 @@ nodemask_t cpuset_mems_allowed(struct ta
 }
 
 /**
- * cpuset_zonelist_valid_mems_allowed - check zonelist vs. curremt mems_allowed
- * @zl: the zonelist to be checked
+ * cpuset_nodemask_valid_mems_allowed - check nodemask vs. curremt mems_allowed
+ * @nodemask: the nodemask to be checked
  *
- * Are any of the nodes on zonelist zl allowed in current->mems_allowed?
+ * Are any of the nodes in the nodemask allowed in current->mems_allowed?
  */
-int cpuset_zonelist_valid_mems_allowed(struct zonelist *zl)
+int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask)
 {
-	int i;
-
-	for (i = 0; zl->_zonerefs[i].zone; i++) {
-		int nid = zonelist_node_idx(zl->_zonerefs[i]);
-
-		if (node_isset(nid, current->mems_allowed))
-			return 1;
-	}
-	return 0;
+	return nodes_intersects(*nodemask, current->mems_allowed);
 }
 
 /*
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-020_zoneid_zonelist/mm/mempolicy.c linux-2.6.23-rc8-mm2-030_filter_nodemask/mm/mempolicy.c
--- linux-2.6.23-rc8-mm2-020_zoneid_zonelist/mm/mempolicy.c	2007-09-28 19:23:05.000000000 +0100
+++ linux-2.6.23-rc8-mm2-030_filter_nodemask/mm/mempolicy.c	2007-09-28 19:23:14.000000000 +0100
@@ -134,41 +134,21 @@ static int mpol_check_policy(int mode, n
  	return nodes_subset(*nodes, node_states[N_HIGH_MEMORY]) ? 0 : -EINVAL;
 }
 
-/* Generate a custom zonelist for the BIND policy. */
-static struct zonelist *bind_zonelist(nodemask_t *nodes)
+/* Check that the nodemask contains at least one populated zone */
+static int is_valid_nodemask(nodemask_t *nodemask)
 {
-	struct zonelist *zl;
-	int num, max, nd;
-	enum zone_type k;
+	int nd, k;
 
-	max = 1 + MAX_NR_ZONES * nodes_weight(*nodes);
-	max++;			/* space for zlcache_ptr (see mmzone.h) */
-	zl = kmalloc(sizeof(struct zone *) * max, GFP_KERNEL);
-	if (!zl)
-		return ERR_PTR(-ENOMEM);
-	zl->zlcache_ptr = NULL;
-	num = 0;
-	/* First put in the highest zones from all nodes, then all the next 
-	   lower zones etc. Avoid empty zones because the memory allocator
-	   doesn't like them. If you implement node hot removal you
-	   have to fix that. */
-	k = MAX_NR_ZONES - 1;
-	while (1) {
-		for_each_node_mask(nd, *nodes) { 
-			struct zone *z = &NODE_DATA(nd)->node_zones[k];
-			if (z->present_pages > 0) 
-				encode_zoneref(z, &zl->_zonerefs[num++]);
-		}
-		if (k == 0)
-			break;
-		k--;
-	}
-	if (num == 0) {
-		kfree(zl);
-		return ERR_PTR(-EINVAL);
+	/* Check that there is something useful in this mask */
+	k = policy_zone;
+
+	for_each_node_mask(nd, *nodemask) {
+		struct zone *z = &NODE_DATA(nd)->node_zones[k];
+		if (z->present_pages > 0)
+			return 1;
 	}
-	zl->_zonerefs[num].zone = NULL;
-	return zl;
+
+	return 0;
 }
 
 /* Create a new policy */
@@ -201,12 +181,11 @@ static struct mempolicy *mpol_new(int mo
 			policy->v.preferred_node = -1;
 		break;
 	case MPOL_BIND:
-		policy->v.zonelist = bind_zonelist(nodes);
-		if (IS_ERR(policy->v.zonelist)) {
-			void *error_code = policy->v.zonelist;
+		if (!is_valid_nodemask(nodes)) {
 			kmem_cache_free(policy_cache, policy);
-			return error_code;
+			return ERR_PTR(-EINVAL);
 		}
+		policy->v.nodes = *nodes;
 		break;
 	}
 	policy->policy = mode;
@@ -484,19 +463,12 @@ static long do_set_mempolicy(int mode, n
 /* Fill a zone bitmap for a policy */
 static void get_zonemask(struct mempolicy *p, nodemask_t *nodes)
 {
-	int i;
-
 	nodes_clear(*nodes);
 	switch (p->policy) {
-	case MPOL_BIND:
-		for (i = 0; p->v.zonelist->_zonerefs[i].zone; i++) {
-			struct zoneref *zref;
-			zref = &p->v.zonelist->_zonerefs[i];
-			node_set(zonelist_node_idx(zref), *nodes);
-		}
-		break;
 	case MPOL_DEFAULT:
 		break;
+	case MPOL_BIND:
+		/* Fall through */
 	case MPOL_INTERLEAVE:
 		*nodes = p->v.nodes;
 		break;
@@ -1131,6 +1103,18 @@ static struct mempolicy * get_vma_policy
 	return pol;
 }
 
+/* Return a nodemask representing a mempolicy */
+static inline nodemask_t *nodemask_policy(gfp_t gfp, struct mempolicy *policy)
+{
+	/* Lower zones don't get a nodemask applied for MPOL_BIND */
+	if (unlikely(policy->policy == MPOL_BIND &&
+			gfp_zone(gfp) >= policy_zone &&
+			cpuset_nodemask_valid_mems_allowed(&policy->v.nodes)))
+		return &policy->v.nodes;
+
+	return NULL;
+}
+
 /* Return a zonelist representing a mempolicy */
 static struct zonelist *zonelist_policy(gfp_t gfp, struct mempolicy *policy)
 {
@@ -1143,11 +1127,6 @@ static struct zonelist *zonelist_policy(
 			nd = numa_node_id();
 		break;
 	case MPOL_BIND:
-		/* Lower zones don't get a policy applied */
-		/* Careful: current->mems_allowed might have moved */
-		if (gfp_zone(gfp) >= policy_zone)
-			if (cpuset_zonelist_valid_mems_allowed(policy->v.zonelist))
-				return policy->v.zonelist;
 		/*FALL THROUGH*/
 	case MPOL_INTERLEAVE: /* should not happen */
 	case MPOL_DEFAULT:
@@ -1191,7 +1170,13 @@ unsigned slab_node(struct mempolicy *pol
 		 * Follow bind policy behavior and start allocation at the
 		 * first node.
 		 */
-		return zonelist_node_idx(policy->v.zonelist->_zonerefs);
+		struct zonelist *zonelist;
+		struct zoneref *z;
+		enum zone_type highest_zoneidx = gfp_zone(GFP_KERNEL);
+		zonelist = &NODE_DATA(numa_node_id())->node_zonelists[0];
+		z = first_zones_zonelist(zonelist, &policy->v.nodes,
+							highest_zoneidx);
+		return zonelist_node_idx(z);
 	}
 
 	case MPOL_PREFERRED:
@@ -1349,7 +1334,7 @@ alloc_page_vma(gfp_t gfp, struct vm_area
 	/*
 	 * fast path:  default or task policy
 	 */
-	return __alloc_pages(gfp, 0, zl);
+	return __alloc_pages_nodemask(gfp, 0, zl, nodemask_policy(gfp, pol));
 }
 
 /**
@@ -1406,14 +1391,6 @@ struct mempolicy *__mpol_copy(struct mem
 	}
 	*new = *old;
 	atomic_set(&new->refcnt, 1);
-	if (new->policy == MPOL_BIND) {
-		int sz = ksize(old->v.zonelist);
-		new->v.zonelist = kmemdup(old->v.zonelist, sz, GFP_KERNEL);
-		if (!new->v.zonelist) {
-			kmem_cache_free(policy_cache, new);
-			return ERR_PTR(-ENOMEM);
-		}
-	}
 	return new;
 }
 
@@ -1427,21 +1404,12 @@ int __mpol_equal(struct mempolicy *a, st
 	switch (a->policy) {
 	case MPOL_DEFAULT:
 		return 1;
+	case MPOL_BIND:
+		/* Fall through */
 	case MPOL_INTERLEAVE:
 		return nodes_equal(a->v.nodes, b->v.nodes);
 	case MPOL_PREFERRED:
 		return a->v.preferred_node == b->v.preferred_node;
-	case MPOL_BIND: {
-		int i;
-		for (i = 0; a->v.zonelist->_zonerefs[i].zone; i++) {
-			struct zone *za, *zb;
-			za = zonelist_zone(&a->v.zonelist->_zonerefs[i]);
-			zb = zonelist_zone(&b->v.zonelist->_zonerefs[i]);
-			if (za != zb)
-				return 0;
-		}
-		return b->v.zonelist->_zonerefs[i].zone == NULL;
-	}
 	default:
 		BUG();
 		return 0;
@@ -1453,8 +1421,6 @@ void __mpol_free(struct mempolicy *p)
 {
 	if (!atomic_dec_and_test(&p->refcnt))
 		return;
-	if (p->policy == MPOL_BIND)
-		kfree(p->v.zonelist);
 	p->policy = MPOL_DEFAULT;
 	kmem_cache_free(policy_cache, p);
 }
@@ -1745,6 +1711,8 @@ static void mpol_rebind_policy(struct me
 	switch (pol->policy) {
 	case MPOL_DEFAULT:
 		break;
+	case MPOL_BIND:
+		/* Fall through */
 	case MPOL_INTERLEAVE:
 		nodes_remap(tmp, pol->v.nodes, *mpolmask, *newmask);
 		pol->v.nodes = tmp;
@@ -1757,32 +1725,6 @@ static void mpol_rebind_policy(struct me
 						*mpolmask, *newmask);
 		*mpolmask = *newmask;
 		break;
-	case MPOL_BIND: {
-		nodemask_t nodes;
-		struct zoneref *z;
-		struct zonelist *zonelist;
-
-		nodes_clear(nodes);
-		for (z = pol->v.zonelist->_zonerefs; z->zone; z++)
-			node_set(zonelist_node_idx(z), nodes);
-		nodes_remap(tmp, nodes, *mpolmask, *newmask);
-		nodes = tmp;
-
-		zonelist = bind_zonelist(&nodes);
-
-		/* If no mem, then zonelist is NULL and we keep old zonelist.
-		 * If that old zonelist has no remaining mems_allowed nodes,
-		 * then zonelist_policy() will "FALL THROUGH" to MPOL_DEFAULT.
-		 */
-
-		if (!IS_ERR(zonelist)) {
-			/* Good - got mem - substitute new zonelist */
-			kfree(pol->v.zonelist);
-			pol->v.zonelist = zonelist;
-		}
-		*mpolmask = *newmask;
-		break;
-	}
 	default:
 		BUG();
 		break;
@@ -1845,9 +1787,7 @@ static inline int mpol_to_str(char *buff
 		break;
 
 	case MPOL_BIND:
-		get_zonemask(pol, &nodes);
-		break;
-
+		/* Fall through */
 	case MPOL_INTERLEAVE:
 		nodes = pol->v.nodes;
 		break;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-020_zoneid_zonelist/mm/page_alloc.c linux-2.6.23-rc8-mm2-030_filter_nodemask/mm/page_alloc.c
--- linux-2.6.23-rc8-mm2-020_zoneid_zonelist/mm/page_alloc.c	2007-09-28 19:23:05.000000000 +0100
+++ linux-2.6.23-rc8-mm2-030_filter_nodemask/mm/page_alloc.c	2007-09-28 19:23:14.000000000 +0100
@@ -1420,7 +1420,7 @@ static void zlc_mark_zone_full(struct zo
  * a page.
  */
 static struct page *
-get_page_from_freelist(gfp_t gfp_mask, unsigned int order,
+get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 		struct zonelist *zonelist, int high_zoneidx, int alloc_flags)
 {
 	struct zoneref *z;
@@ -1431,7 +1431,7 @@ get_page_from_freelist(gfp_t gfp_mask, u
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
 
-	z = first_zones_zonelist(zonelist, high_zoneidx);
+	z = first_zones_zonelist(zonelist, nodemask, high_zoneidx);
 	classzone_idx = zonelist_zone_idx(z);
 
 zonelist_scan:
@@ -1439,7 +1439,8 @@ zonelist_scan:
 	 * Scan zonelist, looking for a zone with enough free.
 	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
 	 */
-	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
+	for_each_zone_zonelist_nodemask(zone, z, zonelist,
+						high_zoneidx, nodemask) {
 		if (NUMA_BUILD && zlc_active &&
 			!zlc_zone_worth_trying(zonelist, z, allowednodes))
 				continue;
@@ -1545,9 +1546,9 @@ static void set_page_owner(struct page *
 /*
  * This is the 'heart' of the zoned buddy allocator.
  */
-struct page * fastcall
-__alloc_pages(gfp_t gfp_mask, unsigned int order,
-		struct zonelist *zonelist)
+static struct page *
+__alloc_pages_internal(gfp_t gfp_mask, unsigned int order,
+			struct zonelist *zonelist, nodemask_t *nodemask)
 {
 	const gfp_t wait = gfp_mask & __GFP_WAIT;
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
@@ -1576,7 +1577,7 @@ restart:
 		return NULL;
 	}
 
-	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, order,
+	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
 			zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET);
 	if (page)
 		goto got_pg;
@@ -1621,7 +1622,7 @@ restart:
 	 * Ignore cpuset if GFP_ATOMIC (!wait) rather than fail alloc.
 	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
 	 */
-	page = get_page_from_freelist(gfp_mask, order, zonelist,
+	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
 						high_zoneidx, alloc_flags);
 	if (page)
 		goto got_pg;
@@ -1634,7 +1635,7 @@ rebalance:
 		if (!(gfp_mask & __GFP_NOMEMALLOC)) {
 nofail_alloc:
 			/* go through the zonelist yet again, ignoring mins */
-			page = get_page_from_freelist(gfp_mask, order,
+			page = get_page_from_freelist(gfp_mask, nodemask, order,
 				zonelist, high_zoneidx, ALLOC_NO_WATERMARKS);
 			if (page)
 				goto got_pg;
@@ -1669,7 +1670,7 @@ nofail_alloc:
 		drain_all_local_pages();
 
 	if (likely(did_some_progress)) {
-		page = get_page_from_freelist(gfp_mask, order,
+		page = get_page_from_freelist(gfp_mask, nodemask, order,
 					zonelist, high_zoneidx, alloc_flags);
 		if (page)
 			goto got_pg;
@@ -1685,8 +1686,9 @@ nofail_alloc:
 		 * a parallel oom killing, we must fail if we're still
 		 * under heavy pressure.
 		 */
-		page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, order,
-			zonelist, high_zoneidx, ALLOC_WMARK_HIGH|ALLOC_CPUSET);
+		page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask,
+			order, zonelist, high_zoneidx,
+			ALLOC_WMARK_HIGH|ALLOC_CPUSET);
 		if (page) {
 			clear_zonelist_oom(zonelist, gfp_mask);
 			goto got_pg;
@@ -1739,6 +1741,20 @@ got_pg:
 	return page;
 }
 
+struct page * fastcall
+__alloc_pages(gfp_t gfp_mask, unsigned int order,
+		struct zonelist *zonelist)
+{
+	return __alloc_pages_internal(gfp_mask, order, zonelist, NULL);
+}
+
+struct page * fastcall
+__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
+		struct zonelist *zonelist, nodemask_t *nodemask)
+{
+	return __alloc_pages_internal(gfp_mask, order, zonelist, nodemask);
+}
+
 EXPORT_SYMBOL(__alloc_pages);
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
