Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9A6628D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 17:41:36 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id p3LLfYkP001996
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 14:41:35 -0700
Received: from pvg12 (pvg12.prod.google.com [10.241.210.140])
	by kpbe20.cbf.corp.google.com with ESMTP id p3LLfUle014637
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 14:41:33 -0700
Received: by pvg12 with SMTP id 12so102864pvg.33
        for <linux-mm@kvack.org>; Thu, 21 Apr 2011 14:41:30 -0700 (PDT)
Date: Thu, 21 Apr 2011 14:41:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm: always set nodes with regular memory in
 N_NORMAL_MEMORY
In-Reply-To: <alpine.DEB.2.00.1104211411540.20201@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1104211440240.20201@chino.kir.corp.google.com>
References: <1303317178.2587.30.camel@mulgrave.site> <alpine.DEB.2.00.1104201410350.31768@chino.kir.corp.google.com> <20110421220351.9180.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1104211237250.5829@chino.kir.corp.google.com> <alpine.DEB.2.00.1104211500170.5741@router.home>
 <alpine.DEB.2.00.1104211411540.20201@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

N_NORMAL_MEMORY is intended to include all nodes that have present memory 
in regular zones, that is, zones below ZONE_HIGHMEM.  This should be done 
regardless of whether CONFIG_HIGHMEM is set or not.

This fixes ia64 so that the nodes get set appropriately in the nodemask 
for DISCONTIGMEM and mips if it does not enable CONFIG_HIGHMEM even for 
32-bit kernels.

If N_NORMAL_MEMORY is not accurate, slub may encounter errors since it 
relies on this nodemask to setup kmem_cache_node data structures for each 
cache.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4727,7 +4727,6 @@ out:
 /* Any regular memory on that node ? */
 static void check_for_regular_memory(pg_data_t *pgdat)
 {
-#ifdef CONFIG_HIGHMEM
 	enum zone_type zone_type;
 
 	for (zone_type = 0; zone_type <= ZONE_NORMAL; zone_type++) {
@@ -4735,7 +4734,6 @@ static void check_for_regular_memory(pg_data_t *pgdat)
 		if (zone->present_pages)
 			node_set_state(zone_to_nid(zone), N_NORMAL_MEMORY);
 	}
-#endif
 }
 
 /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
