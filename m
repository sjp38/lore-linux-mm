Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A9A846B009F
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 05:44:40 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 32/35] Inline next_zones_zonelist() of the zonelist scan in the fastpath
Date: Mon, 16 Mar 2009 09:46:27 +0000
Message-Id: <1237196790-7268-33-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1237196790-7268-1-git-send-email-mel@csn.ul.ie>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

The zonelist walkers call next_zones_zonelist() to find the next zone
that is allowed by the nodemask. It's not inlined because the number of
call-sites bloats text but it is not free to call a function either.
This patch inlines next_zones_zonelist() only for the page allocator
fastpath. All other zonelist walkers use an uninlined version.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/mmzone.h |    6 ++++++
 mm/mmzone.c            |   31 -------------------------------
 mm/page_alloc.c        |   40 +++++++++++++++++++++++++++++++++++++++-
 3 files changed, 45 insertions(+), 32 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 5be2386..9057bc1 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -895,6 +895,12 @@ static inline struct zoneref *first_zones_zonelist(struct zonelist *zonelist,
 		zone;							\
 		z = next_zones_zonelist(++z, highidx, nodemask, &zone))	\
 
+/* Only available to the page allocator fast-path */
+#define fast_foreach_zone_zonelist_nodemask(zone, z, zlist, highidx, nodemask) \
+	for (z = first_zones_zonelist(zlist, highidx, nodemask, &zone);	\
+		zone;							\
+		z = __next_zones_zonelist(++z, highidx, nodemask, &zone)) \
+
 /**
  * for_each_zone_zonelist - helper macro to iterate over valid zones in a zonelist at or below a given zone index
  * @zone - The current zone in the iterator
diff --git a/mm/mmzone.c b/mm/mmzone.c
index 16ce8b9..347951c 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -41,34 +41,3 @@ struct zone *next_zone(struct zone *zone)
 	}
 	return zone;
 }
-
-static inline int zref_in_nodemask(struct zoneref *zref, nodemask_t *nodes)
-{
-#ifdef CONFIG_NUMA
-	return node_isset(zonelist_node_idx(zref), *nodes);
-#else
-	return 1;
-#endif /* CONFIG_NUMA */
-}
-
-/* Returns the next zone at or below highest_zoneidx in a zonelist */
-struct zoneref *next_zones_zonelist(struct zoneref *z,
-					enum zone_type highest_zoneidx,
-					nodemask_t *nodes,
-					struct zone **zone)
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
-	*zone = zonelist_zone(z);
-	return z;
-}
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8568284..33f39cf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1514,6 +1514,44 @@ static void zlc_mark_zone_full(struct zonelist *zonelist, struct zoneref *z)
 }
 #endif	/* CONFIG_NUMA */
 
+static inline int
+zref_in_nodemask(struct zoneref *zref, nodemask_t *nodes)
+{
+#ifdef CONFIG_NUMA
+	return node_isset(zonelist_node_idx(zref), *nodes);
+#else
+	return 1;
+#endif /* CONFIG_NUMA */
+}
+
+/* Returns the next zone at or below highest_zoneidx in a zonelist */
+static inline struct zoneref *
+__next_zones_zonelist(struct zoneref *z, enum zone_type highest_zoneidx,
+					nodemask_t *nodes, struct zone **zone)
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
+	*zone = zonelist_zone(z);
+	return z;
+}
+
+struct zoneref *
+next_zones_zonelist(struct zoneref *z, enum zone_type highest_zoneidx,
+					nodemask_t *nodes, struct zone **zone)
+{
+	return __next_zones_zonelist(z, highest_zoneidx, nodes, zone);
+}
+
 /*
  * get_page_from_freelist goes through the zonelist trying to allocate
  * a page.
@@ -1546,7 +1584,7 @@ zonelist_scan:
 	 * Scan zonelist, looking for a zone with enough free.
 	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
 	 */
-	for_each_zone_zonelist_nodemask(zone, z, zonelist,
+	fast_foreach_zone_zonelist_nodemask(zone, z, zonelist,
 						high_zoneidx, nodemask) {
 
 		/* Ignore the additional zonelist filter checks if possible */
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
