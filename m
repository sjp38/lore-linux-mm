Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 12EBC6B0031
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 12:03:27 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id f8so842385wiw.9
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 09:03:27 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v2si16501052wix.2.2014.02.19.09.03.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 19 Feb 2014 09:03:25 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC PATCH] mm: exclude memory less nodes from zone_reclaim
Date: Wed, 19 Feb 2014 18:03:03 +0100
Message-Id: <1392829383-4125-1-git-send-email-mhocko@suse.cz>
In-Reply-To: <20140219082313.GB14783@dhcp22.suse.cz>
References: <20140219082313.GB14783@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>

We had a report about strange OOM killer strikes on a PPC machine
although there was a lot of swap free and a tons of anonymous memory
which could be swapped out. In the end it turned out that the OOM was
a side effect of zone reclaim which wasn't doesn't unmap and swapp out
and so the system was pushed to the OOM. Although this sounds like a bug
somewhere in the kswapd vs. zone reclaim vs. direct reclaim interaction
numactl on the said hardware suggests that the zone reclaim should
have been set in the first place:
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
node 0 size: 0 MB
node 0 free: 0 MB
node 2 cpus:
node 2 size: 7168 MB
node 2 free: 6019 MB
node distances:
node   0   2
0:  10  40
2:  40  10

So all the CPUs are associated with Node0 which doesn't have any memory
while Node2 contains all the available memory. Node distances cause an
automatic zone_reclaim_mode enabling.

Zone reclaim is intended to keep the allocations local but this doesn't
make any sense on the memory less nodes. So let's exlcude such nodes
for init_zone_allows_reclaim which evaluates zone reclaim behavior and
suitable reclaim_nodes.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
I haven't got to testing this so I am sending this as an RFC for now.
But does this look reasonable?

 mm/page_alloc.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3e953f07edb0..4a44bdc7a8cf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1855,7 +1855,7 @@ static void __paginginit init_zone_allows_reclaim(int nid)
 {
 	int i;
 
-	for_each_online_node(i)
+	for_each_node_state(i, N_HIGH_MEMORY)
 		if (node_distance(nid, i) <= RECLAIM_DISTANCE)
 			node_set(i, NODE_DATA(nid)->reclaim_nodes);
 		else
@@ -4901,7 +4901,8 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 
 	pgdat->node_id = nid;
 	pgdat->node_start_pfn = node_start_pfn;
-	init_zone_allows_reclaim(nid);
+	if (node_state(nid, N_HIGH_MEMORY))
+		init_zone_allows_reclaim(nid);
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 	get_pfn_range_for_nid(nid, &start_pfn, &end_pfn);
 #endif
-- 
1.9.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
