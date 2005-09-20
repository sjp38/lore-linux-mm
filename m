Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8KHLrAH029344
	for <linux-mm@kvack.org>; Tue, 20 Sep 2005 13:21:53 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8KHNBOt500042
	for <linux-mm@kvack.org>; Tue, 20 Sep 2005 11:23:11 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j8KHNA9i029773
	for <linux-mm@kvack.org>; Tue, 20 Sep 2005 11:23:10 -0600
Subject: [RFC][PATCH 1/4] build_zonelists(): create zone_index_to_type() helper
From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 20 Sep 2005 10:23:09 -0700
References: <20050920172303.8CD9190C@kernel.beaverton.ibm.com>
In-Reply-To: <20050920172303.8CD9190C@kernel.beaverton.ibm.com>
Message-Id: <20050920172309.5C36CE4C@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

The two build_zonelists() do identical conversions from a
zone index variable (__GFP_*) to a zone type variable
(ZONE_*).  Create a common helper.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 memhotplug-dave/mm/page_alloc.c |   24 ++++++++++++++----------
 1 files changed, 14 insertions(+), 10 deletions(-)

diff -puN mm/page_alloc.c~B1-build_zonelists_unification mm/page_alloc.c
--- memhotplug/mm/page_alloc.c~B1-build_zonelists_unification	2005-09-14 09:32:37.000000000 -0700
+++ memhotplug-dave/mm/page_alloc.c	2005-09-14 09:32:37.000000000 -0700
@@ -1451,6 +1451,18 @@ static int __init build_zonelists_node(p
 	return j;
 }
 
+static inline zone_index_to_type(int index)
+{
+	int type = ZONE_NORMAL;
+
+	if (index & __GFP_HIGHMEM)
+		type = ZONE_HIGHMEM;
+	if (index & __GFP_DMA)
+		type = ZONE_DMA;
+	return type;
+}
+
+
 #ifdef CONFIG_NUMA
 #define MAX_NODE_LOAD (num_online_nodes())
 static int __initdata node_load[MAX_NUMNODES];
@@ -1547,11 +1559,7 @@ static void __init build_zonelists(pg_da
 			zonelist = pgdat->node_zonelists + i;
 			for (j = 0; zonelist->zones[j] != NULL; j++);
 
-			k = ZONE_NORMAL;
-			if (i & __GFP_HIGHMEM)
-				k = ZONE_HIGHMEM;
-			if (i & __GFP_DMA)
-				k = ZONE_DMA;
+			k = zone_index_to_type(i);
 
 	 		j = build_zonelists_node(NODE_DATA(node), zonelist, j, k);
 			zonelist->zones[j] = NULL;
@@ -1572,11 +1580,7 @@ static void __init build_zonelists(pg_da
 		zonelist = pgdat->node_zonelists + i;
 
 		j = 0;
-		k = ZONE_NORMAL;
-		if (i & __GFP_HIGHMEM)
-			k = ZONE_HIGHMEM;
-		if (i & __GFP_DMA)
-			k = ZONE_DMA;
+		k = zone_index_to_type(i);
 
  		j = build_zonelists_node(pgdat, zonelist, j, k);
  		/*
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
