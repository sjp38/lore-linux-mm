From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 2/4] pull out zone cpuset and watermark checks for reuse
Date: Tue,  1 Jul 2008 18:58:40 +0100
Message-Id: <1214935122-20828-3-git-send-email-apw@shadowen.org>
In-Reply-To: <1214935122-20828-1-git-send-email-apw@shadowen.org>
References: <1214935122-20828-1-git-send-email-apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

When allocating we need to confirm that the zone we are about to allocate
from is acceptable to the CPUSET we are in, and that it does not violate
the zone watermarks.  Pull these checks out so we can reuse them in a
later patch.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 mm/page_alloc.c |   62 ++++++++++++++++++++++++++++++++++++++----------------
 1 files changed, 43 insertions(+), 19 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 758ecf1..4d9c4e8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1248,6 +1248,44 @@ int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 	return 1;
 }
 
+/*
+ * Return 1 if this zone is an acceptable source given the cpuset
+ * constraints.
+ */
+static inline int zone_cpuset_ok(struct zone *zone,
+					int alloc_flags, gfp_t gfp_mask)
+{
+	if ((alloc_flags & ALLOC_CPUSET) &&
+	    !cpuset_zone_allowed_softwall(zone, gfp_mask))
+		return 0;
+	return 1;
+}
+
+/*
+ * Return 1 if this zone is within the watermarks specified by the
+ * allocation flags.
+ */
+static inline int zone_alloc_ok(struct zone *zone, int order,
+			int classzone_idx, int alloc_flags, gfp_t gfp_mask)
+{
+	if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
+		unsigned long mark;
+		if (alloc_flags & ALLOC_WMARK_MIN)
+			mark = zone->pages_min;
+		else if (alloc_flags & ALLOC_WMARK_LOW)
+			mark = zone->pages_low;
+		else
+			mark = zone->pages_high;
+		if (!zone_watermark_ok(zone, order, mark,
+			    classzone_idx, alloc_flags)) {
+			if (!zone_reclaim_mode ||
+					!zone_reclaim(zone, gfp_mask, order))
+				return 0;
+		}
+	}
+	return 1;
+}
+
 #ifdef CONFIG_NUMA
 /*
  * zlc_setup - Setup for "zonelist cache".  Uses cached zone data to
@@ -1401,25 +1439,11 @@ zonelist_scan:
 		if (NUMA_BUILD && zlc_active &&
 			!zlc_zone_worth_trying(zonelist, z, allowednodes))
 				continue;
-		if ((alloc_flags & ALLOC_CPUSET) &&
-			!cpuset_zone_allowed_softwall(zone, gfp_mask))
-				goto try_next_zone;
-
-		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
-			unsigned long mark;
-			if (alloc_flags & ALLOC_WMARK_MIN)
-				mark = zone->pages_min;
-			else if (alloc_flags & ALLOC_WMARK_LOW)
-				mark = zone->pages_low;
-			else
-				mark = zone->pages_high;
-			if (!zone_watermark_ok(zone, order, mark,
-				    classzone_idx, alloc_flags)) {
-				if (!zone_reclaim_mode ||
-				    !zone_reclaim(zone, gfp_mask, order))
-					goto this_zone_full;
-			}
-		}
+		if (!zone_cpuset_ok(zone, alloc_flags, gfp_mask))
+			goto try_next_zone;
+		if (!zone_alloc_ok(zone, order, classzone_idx,
+							alloc_flags, gfp_mask))
+			goto this_zone_full;
 
 		page = buffered_rmqueue(preferred_zone, zone, order, gfp_mask);
 		if (page)
-- 
1.5.6.1.201.g3e7d3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
