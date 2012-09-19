Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 16C0A6B0044
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 19:46:56 -0400 (EDT)
Date: Wed, 19 Sep 2012 16:46:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, numa: reclaim from all nodes within reclaim
 distance
Message-Id: <20120919164654.43204ba9.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1209180003340.16777@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1209180003340.16777@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 18 Sep 2012 00:03:57 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> RECLAIM_DISTANCE represents the distance between nodes at which it is
> deemed too costly to allocate from; it's preferred to try to reclaim from
> a local zone before falling back to allocating on a remote node with such
> a distance.
> 
> To do this, zone_reclaim_mode is set if the distance between any two
> nodes on the system is greather than this distance.  This, however, ends
> up causing the page allocator to reclaim from every zone regardless of
> its affinity.
> 
> What we really want is to reclaim only from zones that are closer than 
> RECLAIM_DISTANCE.  This patch adds a nodemask to each node that
> represents the set of nodes that are within this distance.  During the
> zone iteration, if the bit for a zone's node is set for the local node,
> then reclaim is attempted; otherwise, the zone is skipped.

zone_reclaim_mode isn't an lval if CONFIG_NUMA=n:

--- a/mm/page_alloc.c~mm-numa-reclaim-from-all-nodes-within-reclaim-distance-fix
+++ a/mm/page_alloc.c
@@ -4561,7 +4561,9 @@ void __paginginit free_area_init_node(in
 	for_each_online_node(i)
 		if (node_distance(nid, i) <= RECLAIM_DISTANCE) {
 			node_set(i, pgdat->reclaim_nodes);
+#ifdef CONFIG_NUMA
 			zone_reclaim_mode = 1;
+#endif
 		}
 	calculate_node_totalpages(pgdat, zones_size, zholes_size);
 

That may not be a very good fix though - can we get all this NUMAy code
out of a non-NUMA-specific code site?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
