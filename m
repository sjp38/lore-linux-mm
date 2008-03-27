Date: Thu, 27 Mar 2008 15:51:45 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH] Uninline zonelist iterator helper functions
Message-ID: <20080327155144.GA7120@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

for_each_zone_zonelist_nodemask() uses large inlined helpers. The number of
callsites using it means that the size of the text section is increased.
This patch uninlines the helpers to reduce the amount of text bloat.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>

---
 fs/buffer.c            |    4 ++-
 include/linux/mmzone.h |   62 +++++++------------------------------------------
 mm/mempolicy.c         |    4 ++-
 mm/mmzone.c            |   31 ++++++++++++++++++++++++
 mm/page_alloc.c        |   10 ++++++-
 5 files changed, 55 insertions(+), 56 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc5-mm1-clean/fs/buffer.c linux-2.6.25-rc5-mm1-1020_uninline/fs/buffer.c
--- linux-2.6.25-rc5-mm1-clean/fs/buffer.c	2008-03-18 09:49:00.000000000 +0000
+++ linux-2.6.25-rc5-mm1-1020_uninline/fs/buffer.c	2008-03-18 09:50:11.000000000 +0000
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
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc5-mm1-clean/include/linux/mmzone.h linux-2.6.25-rc5-mm1-1020_uninline/include/linux/mmzone.h
--- linux-2.6.25-rc5-mm1-clean/include/linux/mmzone.h	2008-03-18 09:49:01.000000000 +0000
+++ linux-2.6.25-rc5-mm1-1020_uninline/include/linux/mmzone.h	2008-03-18 09:50:11.000000000 +0000
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
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc5-mm1-clean/mm/mempolicy.c linux-2.6.25-rc5-mm1-1020_uninline/mm/mempolicy.c
--- linux-2.6.25-rc5-mm1-clean/mm/mempolicy.c	2008-03-18 09:49:02.000000000 +0000
+++ linux-2.6.25-rc5-mm1-1020_uninline/mm/mempolicy.c	2008-03-18 09:50:11.000000000 +0000
@@ -1340,10 +1340,12 @@ unsigned slab_node(struct mempolicy *pol
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
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc5-mm1-clean/mm/mmzone.c linux-2.6.25-rc5-mm1-1020_uninline/mm/mmzone.c
--- linux-2.6.25-rc5-mm1-clean/mm/mmzone.c	2008-03-10 05:22:27.000000000 +0000
+++ linux-2.6.25-rc5-mm1-1020_uninline/mm/mmzone.c	2008-03-18 09:50:11.000000000 +0000
@@ -42,3 +42,33 @@ struct zone *next_zone(struct zone *zone
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
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc5-mm1-clean/mm/page_alloc.c linux-2.6.25-rc5-mm1-1020_uninline/mm/page_alloc.c
--- linux-2.6.25-rc5-mm1-clean/mm/page_alloc.c	2008-03-18 09:49:02.000000000 +0000
+++ linux-2.6.25-rc5-mm1-1020_uninline/mm/page_alloc.c	2008-03-18 09:50:11.000000000 +0000
@@ -1406,9 +1406,9 @@ get_page_from_freelist(gfp_t gfp_mask, n
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
 
-	z = first_zones_zonelist(zonelist, high_zoneidx, nodemask);
+	z = first_zones_zonelist(zonelist, high_zoneidx, nodemask,
+							&preferred_zone);
 	classzone_idx = zonelist_zone_idx(z);
-	preferred_zone = zonelist_zone(z);
 
 zonelist_scan:
 	/*
@@ -1974,6 +1974,12 @@ void show_free_areas(void)
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
