From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070809210736.14702.36541.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070809210616.14702.73376.sendpatchset@skynet.skynet.ie>
References: <20070809210616.14702.73376.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 4/4] Apply MPOL_BIND policy to two highest zones when highest is ZONE_MOVABLE
Date: Thu,  9 Aug 2007 22:07:36 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee.Schermerhorn@hp.com, ak@suse.de, clameter@sgi.com
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The NUMA layer only supports the MPOL_BIND NUMA policy for the highest
zone. When ZONE_MOVABLE is configured with kernelcore=, the the highest
zone becomes ZONE_MOVABLE. The result is that the bind policy policies is
only applied to allocations like anonymous pages and page cache allocated
from ZONE_MOVABLE when the zone is used.

This patch applies policies to the two highest zones when the highest zone
is ZONE_MOVABLE. As ZONE_MOVABLE consists of pages from the highest "real"
zone, these two zones are equivalent in policy terms.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 include/linux/mempolicy.h |    2 +-
 mm/mempolicy.c            |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc1-mm2-015_zoneid_zonelist/include/linux/mempolicy.h linux-2.6.23-rc1-mm2-020_treat_movable_highest/include/linux/mempolicy.h
--- linux-2.6.23-rc1-mm2-015_zoneid_zonelist/include/linux/mempolicy.h	2007-08-09 15:01:36.000000000 +0100
+++ linux-2.6.23-rc1-mm2-020_treat_movable_highest/include/linux/mempolicy.h	2007-08-09 15:52:23.000000000 +0100
@@ -157,7 +157,7 @@ extern enum zone_type policy_zone;
 
 static inline void check_highest_zone(enum zone_type k)
 {
-	if (k > policy_zone)
+	if (k > policy_zone && k != ZONE_MOVABLE)
 		policy_zone = k;
 }
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc1-mm2-015_zoneid_zonelist/mm/mempolicy.c linux-2.6.23-rc1-mm2-020_treat_movable_highest/mm/mempolicy.c
--- linux-2.6.23-rc1-mm2-015_zoneid_zonelist/mm/mempolicy.c	2007-08-09 18:33:51.000000000 +0100
+++ linux-2.6.23-rc1-mm2-020_treat_movable_highest/mm/mempolicy.c	2007-08-09 18:33:42.000000000 +0100
@@ -151,7 +151,7 @@ static struct zonelist *bind_zonelist(no
 	   lower zones etc. Avoid empty zones because the memory allocator
 	   doesn't like them. If you implement node hot removal you
 	   have to fix that. */
-	k = policy_zone;
+	k = MAX_NR_ZONES - 1;
 	while (1) {
 		for_each_node_mask(nd, *nodes) { 
 			struct zone *z = &NODE_DATA(nd)->node_zones[k];

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
