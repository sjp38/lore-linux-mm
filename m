Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 957C66B0034
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 08:06:54 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id 14so7161025pdj.12
        for <linux-mm@kvack.org>; Wed, 12 Jun 2013 05:06:53 -0700 (PDT)
Message-ID: <51B86456.3060606@gmail.com>
Date: Wed, 12 Jun 2013 20:06:46 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] mm: Remove zone_type argument of build_zonelists_node
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

The callers of build_zonelists_node always pass MAX_NR_ZONES -1
as the zone_type argument, so we can directly use the value
in build_zonelists_node and remove zone_type argument.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 mm/page_alloc.c |   21 ++++++++-------------
 1 files changed, 8 insertions(+), 13 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 378a15b..4c09dea 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3148,12 +3148,10 @@ static void zoneref_set_zone(struct zone *zone, struct zoneref *zoneref)
  * Add all populated zones of a node to the zonelist.
  */
 static int build_zonelists_node(pg_data_t *pgdat, struct zonelist *zonelist,
-				int nr_zones, enum zone_type zone_type)
+				int nr_zones)
 {
 	struct zone *zone;
-
-	BUG_ON(zone_type >= MAX_NR_ZONES);
-	zone_type++;
+	enum zone_type zone_type = MAX_NR_ZONES;
 
 	do {
 		zone_type--;
@@ -3163,8 +3161,8 @@ static int build_zonelists_node(pg_data_t *pgdat, struct zonelist *zonelist,
 				&zonelist->_zonerefs[nr_zones++]);
 			check_highest_zone(zone_type);
 		}
-
 	} while (zone_type);
+
 	return nr_zones;
 }
 
@@ -3351,8 +3349,7 @@ static void build_zonelists_in_node_order(pg_data_t *pgdat, int node)
 	zonelist = &pgdat->node_zonelists[0];
 	for (j = 0; zonelist->_zonerefs[j].zone != NULL; j++)
 		;
-	j = build_zonelists_node(NODE_DATA(node), zonelist, j,
-							MAX_NR_ZONES - 1);
+	j = build_zonelists_node(NODE_DATA(node), zonelist, j);
 	zonelist->_zonerefs[j].zone = NULL;
 	zonelist->_zonerefs[j].zone_idx = 0;
 }
@@ -3366,7 +3363,7 @@ static void build_thisnode_zonelists(pg_data_t *pgdat)
 	struct zonelist *zonelist;
 
 	zonelist = &pgdat->node_zonelists[1];
-	j = build_zonelists_node(pgdat, zonelist, 0, MAX_NR_ZONES - 1);
+	j = build_zonelists_node(pgdat, zonelist, 0);
 	zonelist->_zonerefs[j].zone = NULL;
 	zonelist->_zonerefs[j].zone_idx = 0;
 }
@@ -3574,7 +3571,7 @@ static void build_zonelists(pg_data_t *pgdat)
 	local_node = pgdat->node_id;
 
 	zonelist = &pgdat->node_zonelists[0];
-	j = build_zonelists_node(pgdat, zonelist, 0, MAX_NR_ZONES - 1);
+	j = build_zonelists_node(pgdat, zonelist, 0);
 
 	/*
 	 * Now we build the zonelist so that it contains the zones
@@ -3587,14 +3584,12 @@ static void build_zonelists(pg_data_t *pgdat)
 	for (node = local_node + 1; node < MAX_NUMNODES; node++) {
 		if (!node_online(node))
 			continue;
-		j = build_zonelists_node(NODE_DATA(node), zonelist, j,
-							MAX_NR_ZONES - 1);
+		j = build_zonelists_node(NODE_DATA(node), zonelist, j);
 	}
 	for (node = 0; node < local_node; node++) {
 		if (!node_online(node))
 			continue;
-		j = build_zonelists_node(NODE_DATA(node), zonelist, j,
-							MAX_NR_ZONES - 1);
+		j = build_zonelists_node(NODE_DATA(node), zonelist, j);
 	}
 
 	zonelist->_zonerefs[j].zone = NULL;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
