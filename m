Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id DD0AE6B0069
	for <linux-mm@kvack.org>; Mon,  2 Jan 2017 09:46:38 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c85so44464862wmi.6
        for <linux-mm@kvack.org>; Mon, 02 Jan 2017 06:46:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b15si43966615wmf.133.2017.01.02.06.46.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 Jan 2017 06:46:37 -0800 (PST)
Date: Mon, 2 Jan 2017 15:46:34 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 1/2] mm: fix remote numa hits statistics
Message-ID: <20170102144634.GB18048@dhcp22.suse.cz>
References: <20161221075711.GF16502@dhcp22.suse.cz>
 <20161221080653.29437-1-mhocko@kernel.org>
 <1d9e466b-dc87-eb41-113f-e7737a4bb7ef@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1d9e466b-dc87-eb41-113f-e7737a4bb7ef@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, Jia He <hejianet@gmail.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Mon 02-01-17 15:16:23, Vlastimil Babka wrote:
> On 12/21/2016 09:06 AM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Jia He has noticed that b9f00e147f27 ("mm, page_alloc: reduce branches
> > in zone_statistics") has an unintentional side effect that remote node
> > allocation requests are accounted as NUMA_MISS rathat than NUMA_HIT and
> > NUMA_OTHER if such a request doesn't use __GFP_OTHER_NODE. There are
> > many of these potentially because the flag is used very rarely while
> > we have many users of __alloc_pages_node.
> > 
> > Fix this by simply ignoring __GFP_OTHER_NODE (it can be removed in a
> > follow up patch) and treat all allocations that were satisfied from the
> > preferred zone's node as NUMA_HITS because this is the same node we
> > requested the allocation from in most cases. If this is not the local
> > node then we just account it as NUMA_OTHER rather than NUMA_LOCAL.
> > 
> > One downsize would be that an allocation request for a node which is
> > outside of the mempolicy nodemask would be reported as a hit which is a
> > bit weird but that was the case before b9f00e147f27 already.
> > 
> > Reported-by: Jia He <hejianet@gmail.com>
> > Fixes: b9f00e147f27 ("mm, page_alloc: reduce branches in zone_statistics")
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> cbmc tells me that this patch is not equal to pre-commit b9f00e147f27
> (in situation where __GFP_OTHER_NODE is not passed, as that's the only
> relevant scenario after your patch), which seems unintended.
> 
> counter example:
> numa_node_id() == 1
> preferred_zone on node 0
> allocated from zone on node 1
> 
> pre-b9f00e147f27:
> allocated zone (node 1) increased NUMA_MISS and NUMA_LOCAL
> preferred zone (node 0) increased NUMA_FOREIGN
> 
> (that looks correct to me)
> 
> your patch:
> allocated zone (node 1) increased NUMA_MISS
> preferred zone (node 0) increased NUMA_FOREIGN
> 
> i.e. it's missing NUMA_LOCAL on node 1, which is IMHO wrong as this was
> an allocation local to the CPU (albeit a MISS wrt the preferred node).

I guess the following should fix that, right?
---
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 647e940e6921..ea60dc06d280 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2587,17 +2587,18 @@ int __isolate_free_page(struct page *page, unsigned int order)
 static inline void zone_statistics(struct zone *preferred_zone, struct zone *z)
 {
 #ifdef CONFIG_NUMA
-	if (z->node == preferred_zone->node) {
-		enum zone_stat_item local_stat = NUMA_LOCAL;
+	enum zone_stat_item local_stat = NUMA_LOCAL;
 
+	if (z->node != numa_node_id())
+		local_stat = NUMA_OTHER;
+
+	if (z->node == preferred_zone->node)
 		__inc_zone_state(z, NUMA_HIT);
-		if (z->node != numa_node_id())
-			local_stat = NUMA_OTHER;
-		__inc_zone_state(z, local_stat);
-	} else {
+	else {
 		__inc_zone_state(z, NUMA_MISS);
 		__inc_zone_state(preferred_zone, NUMA_FOREIGN);
 	}
+	__inc_zone_state(z, local_stat);
 #endif
 }
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
