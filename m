Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8KHMurD018221
	for <linux-mm@kvack.org>; Tue, 20 Sep 2005 13:22:56 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8KHNis9546220
	for <linux-mm@kvack.org>; Tue, 20 Sep 2005 11:23:44 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j8KHNC3a029900
	for <linux-mm@kvack.org>; Tue, 20 Sep 2005 11:23:12 -0600
Subject: [RFC][PATCH 3/4] build_zonelists() unification: don't re-zero zonelist
From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 20 Sep 2005 10:23:11 -0700
References: <20050920172303.8CD9190C@kernel.beaverton.ibm.com>
In-Reply-To: <20050920172303.8CD9190C@kernel.beaverton.ibm.com>
Message-Id: <20050920172311.12E6FE03@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

The pgdats, and thus the zonelists are either statically
allocated in BSS, cleared by the bootmem allocator, or
cleared by arch code such as remapped_pgdat_init(). There
is no need to re-zero them here

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 memhotplug-dave/mm/page_alloc.c |    6 ------
 1 files changed, 6 deletions(-)

diff -puN mm/page_alloc.c~B1.2-build_zonelists_unification mm/page_alloc.c
--- memhotplug/mm/page_alloc.c~B1.2-build_zonelists_unification	2005-09-14 09:32:38.000000000 -0700
+++ memhotplug-dave/mm/page_alloc.c	2005-09-14 09:32:38.000000000 -0700
@@ -1549,12 +1549,6 @@ static void __init build_zonelists(pg_da
 	struct zonelist *zonelist;
 	nodemask_t used_mask;
 
-	/* initialize zonelists */
-	for (i = 0; i < GFP_ZONETYPES; i++) {
-		zonelist = pgdat->node_zonelists + i;
-		zonelist->zones[0] = NULL;
-	}
-
 	/* NUMA-aware ordering of nodes */
 	local_node = pgdat->node_id;
 	load = num_online_nodes();
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
