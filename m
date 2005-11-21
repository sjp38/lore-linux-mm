Date: Mon, 21 Nov 2005 13:27:07 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [PATCH] Move policy_zone determination to the page allocator
 initialization?
Message-ID: <Pine.LNX.4.62.0511211325450.10768@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ak@suse.de
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Currently the function to build a zonelist for a BIND policy has the side effect to
set the policy_zone. This seems to be a bit strange. policy_zone seems to 
not be initialized elsewhere and therefore 0. Do we police ZONE_DMA if no 
bind policy has been used yetp?

This patch moves the determination of the zone to apply policies to into the
page allocator. We determine the zone while building the zonelist for nodes.
The default is to policy ZONE_NORMAL. If there are any populated HIGHMEM
segments then switch to ZONE_HIGHMEM.

Not sure if this is right since I am not aware of the history of this issue.
Any particular reason the policy_zone determination is in bind_zonelist?

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.15-rc1-mm2/mm/mempolicy.c
===================================================================
--- linux-2.6.15-rc1-mm2.orig/mm/mempolicy.c	2005-11-21 13:17:59.000000000 -0800
+++ linux-2.6.15-rc1-mm2/mm/mempolicy.c	2005-11-21 13:19:15.000000000 -0800
@@ -102,7 +102,7 @@ static kmem_cache_t *sn_cache;
 
 /* Highest zone. An specific allocation for a zone below that is not
    policied. */
-static int policy_zone;
+int policy_zone;
 
 struct mempolicy default_policy = {
 	.refcnt = ATOMIC_INIT(1), /* never free it */
@@ -140,17 +140,9 @@ static struct zonelist *bind_zonelist(no
 	if (!zl)
 		return NULL;
 	num = 0;
-	for_each_node_mask(nd, *nodes) {
-		int k;
-		for (k = MAX_NR_ZONES-1; k >= 0; k--) {
-			struct zone *z = &NODE_DATA(nd)->node_zones[k];
-			if (!populated_zone(z))
-				continue;
-			zl->zones[num++] = z;
-			if (k > policy_zone)
-				policy_zone = k;
-		}
-	}
+	for_each_node_mask(nd, *nodes)
+		zl->zones[num++] = &NODE_DATA(nd)->node_zones[policy_zone];
+
 	zl->zones[num] = NULL;
 	return zl;
 }
Index: linux-2.6.15-rc1-mm2/mm/page_alloc.c
===================================================================
--- linux-2.6.15-rc1-mm2.orig/mm/page_alloc.c	2005-11-21 13:19:13.000000000 -0800
+++ linux-2.6.15-rc1-mm2/mm/page_alloc.c	2005-11-21 13:19:19.000000000 -0800
@@ -1491,6 +1491,9 @@ void show_free_areas(void)
 	show_swap_cache_info();
 }
 
+/* Used in mempolicy.c */
+extern int policy_zone;
+
 /*
  * Builds allocation fallback zone lists.
  */
@@ -1507,6 +1510,7 @@ static int __init build_zonelists_node(p
 			BUG();
 #endif
 			zonelist->zones[j++] = zone;
+			policy_zone = ZONE_HIGHMEM;
 		}
 	case ZONE_NORMAL:
 		zone = pgdat->node_zones + ZONE_NORMAL;
@@ -1607,6 +1611,7 @@ static void __init build_zonelists(pg_da
 	struct zonelist *zonelist;
 	nodemask_t used_mask;
 
+	policy_zone = ZONE_NORMAL;
 	/* initialize zonelists */
 	for (i = 0; i < GFP_ZONETYPES; i++) {
 		zonelist = pgdat->node_zonelists + i;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
