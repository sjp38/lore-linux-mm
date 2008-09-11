Date: Thu, 11 Sep 2008 22:25:51 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH] Mark the correct zone as full when scanning zonelists
Message-ID: <20080911212550.GA18087@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

The for_each_zone_zonelist() uses a struct zoneref *z cursor when scanning
zonelists to keep track of where in the zonelist it is. The zoneref that
is returned corresponds to the the next zone that is to be scanned, not
the current one as it originally thought of as an opaque list.

When the page allocator is scanning a zonelist, it marks zones that it
temporarily full zones to eliminate near-future scanning attempts. It uses
the zoneref for the marking and consequently the incorrect zone gets marked
full. This leads to a suitable zone being skipped in the mistaken belief
it is full. This patch corrects the problem by changing zoneref to be the
current zone being scanned instead of the next one.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
  include/linux/mmzone.h |   12 ++++++------
  mm/mmzone.c            |    2 +-
  2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 443bc7c..428328a 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -751,8 +751,9 @@ static inline int zonelist_node_idx(struct zoneref *zoneref)
  *
  * This function returns the next zone at or below a given zone index that is
  * within the allowed nodemask using a cursor as the starting point for the
- * search. The zoneref returned is a cursor that is used as the next starting
- * point for future calls to next_zones_zonelist().
+ * search. The zoneref returned is a cursor that represents the current zone
+ * being examined. It should be advanced by one before calling
+ * next_zones_zonelist again.
  */
 struct zoneref *next_zones_zonelist(struct zoneref *z,
 					enum zone_type highest_zoneidx,
@@ -768,9 +769,8 @@ struct zoneref *next_zones_zonelist(struct zoneref *z,
  *
  * This function returns the first zone at or below a given zone index that is
  * within the allowed nodemask. The zoneref returned is a cursor that can be
- * used to iterate the zonelist with next_zones_zonelist. The cursor should
- * not be used by the caller as it does not match the value of the zone
- * returned.
+ * used to iterate the zonelist with next_zones_zonelist by advancing it by
+ * one before calling.
  */
 static inline struct zoneref *first_zones_zonelist(struct zonelist *zonelist,
 					enum zone_type highest_zoneidx,
@@ -795,7 +795,7 @@ static inline struct zoneref *first_zones_zonelist(struct zonelist *zonelist,
 #define for_each_zone_zonelist_nodemask(zone, z, zlist, highidx, nodemask) \
 	for (z = first_zones_zonelist(zlist, highidx, nodemask, &zone);	\
 		zone;							\
-		z = next_zones_zonelist(z, highidx, nodemask, &zone))	\
+		z = next_zones_zonelist(++z, highidx, nodemask, &zone))	\
 
 /**
  * for_each_zone_zonelist - helper macro to iterate over valid zones in a zonelist at or below a given zone index
diff --git a/mm/mmzone.c b/mm/mmzone.c
index 486ed59..16ce8b9 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -69,6 +69,6 @@ struct zoneref *next_zones_zonelist(struct zoneref *z,
 				(z->zone && !zref_in_nodemask(z, nodes)))
 			z++;
 
-	*zone = zonelist_zone(z++);
+	*zone = zonelist_zone(z);
 	return z;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
