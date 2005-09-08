Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j88GFDK9402898
	for <linux-mm@kvack.org>; Thu, 8 Sep 2005 12:15:17 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j88GDtQX084988
	for <linux-mm@kvack.org>; Thu, 8 Sep 2005 10:13:55 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j88GDtNu017644
	for <linux-mm@kvack.org>; Thu, 8 Sep 2005 10:13:55 -0600
Subject: [RFC][PATCH] unify build_zonelists()
From: Dave Hansen <haveblue@us.ibm.com>
Date: Thu, 08 Sep 2005 09:13:52 -0700
Message-Id: <20050908161352.3A8CC221@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, colpatch@us.ibm.com, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

page_alloc.c currently has two implementations of build_zonelists()
based on a CONFIG_NUMA #ifdef.  Does anybody see a reason to keep
the !NUMA one?  The NUMA version uses one more global __init
variable than the flat one.  But, all of its extra loops should
optimize down to nothing when NUMA is off.

Using all of the skill of a blind butcher, I hacked the non-NUMA
version out and booted it.  Seems to work just fine.  Any reason
we shouldn't do this?

P.S. The guys doing all of the work on the NUMA and CPU bitmaps
deserve a pat on the back.  All of those abstractions pay off
in cases like this.

---

 memhotplug-dave/mm/page_alloc.c |   46 ----------------------------------------
 1 files changed, 46 deletions(-)

diff -puN mm/page_alloc.c~build_zonelists_fix mm/page_alloc.c
--- memhotplug/mm/page_alloc.c~build_zonelists_fix	2005-09-08 09:04:48.000000000 -0700
+++ memhotplug-dave/mm/page_alloc.c	2005-09-08 09:05:27.000000000 -0700
@@ -1451,7 +1451,6 @@ static int __init build_zonelists_node(p
 	return j;
 }
 
-#ifdef CONFIG_NUMA
 #define MAX_NODE_LOAD (num_online_nodes())
 static int __initdata node_load[MAX_NUMNODES];
 /**
@@ -1559,51 +1558,6 @@ static void __init build_zonelists(pg_da
 	}
 }
 
-#else	/* CONFIG_NUMA */
-
-static void __init build_zonelists(pg_data_t *pgdat)
-{
-	int i, j, k, node, local_node;
-
-	local_node = pgdat->node_id;
-	for (i = 0; i < GFP_ZONETYPES; i++) {
-		struct zonelist *zonelist;
-
-		zonelist = pgdat->node_zonelists + i;
-
-		j = 0;
-		k = ZONE_NORMAL;
-		if (i & __GFP_HIGHMEM)
-			k = ZONE_HIGHMEM;
-		if (i & __GFP_DMA)
-			k = ZONE_DMA;
-
- 		j = build_zonelists_node(pgdat, zonelist, j, k);
- 		/*
- 		 * Now we build the zonelist so that it contains the zones
- 		 * of all the other nodes.
- 		 * We don't want to pressure a particular node, so when
- 		 * building the zones for node N, we make sure that the
- 		 * zones coming right after the local ones are those from
- 		 * node N+1 (modulo N)
- 		 */
-		for (node = local_node + 1; node < MAX_NUMNODES; node++) {
-			if (!node_online(node))
-				continue;
-			j = build_zonelists_node(NODE_DATA(node), zonelist, j, k);
-		}
-		for (node = 0; node < local_node; node++) {
-			if (!node_online(node))
-				continue;
-			j = build_zonelists_node(NODE_DATA(node), zonelist, j, k);
-		}
-
-		zonelist->zones[j] = NULL;
-	}
-}
-
-#endif	/* CONFIG_NUMA */
-
 void __init build_all_zonelists(void)
 {
 	int i;
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
