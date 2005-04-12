Date: Tue, 12 Apr 2005 11:15:24 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [patch 1/4] pcp: zonequeues
Message-ID: <20050412161523.GA7466@sgi.com>
References: <4257D74C.3010703@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4257D74C.3010703@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, Apr 09, 2005 at 11:23:24PM +1000, Nick Piggin wrote:
> Hi Jack,
> Was thinking about some problems in this area, and I hacked up
> a possible implementation to improve things.
> 
> 1/4 switches the per cpu pagesets in struct zone to a single list
> of zone pagesets for each CPU.
> 
> 2/4 changes the per cpu list of pagesets to a list of pointers to
> pagesets, and allocates them dynamically.
> 
> 3/4 changes the code to allow NULL pagesets. In that case, a single
> per-zone pageset is used, which is protected by the zone's spinlock.
> 
> 4/4 changes setup so non local zones don't have associated pagesets.
> 
> It still needs some work - in particular, many NUMA systems probably
> don't want this. I guess benchmarks should be done, and maybe we
> could look at disabling the overhead of 3/4 and functional change of
> 4/4 depending on a CONFIG_ option.
> 
> Also, you say you might want "close" remote nodes to have pagesets,
> but 4/4 only does local nodes. I added a comment with patch 4/4
> marked with XXX which should allow you to do this quite easily.
> 
> Not tested (only compiled) on a NUMA system, but the NULL pagesets
> logic appears to work OK. Boots on a small UMA SMP system. So just
> be careful with it.
> 
> Comments?
> 

Nick

I tested the patch. I found one spot that was missed  with the NUMA 
statistics but everything else looks fine. The patches fix both problems
that I found - bad coloring & excessive pages in pagesets.



Signed-off-by: Jack Steiner <steiner@sgi.com>


Index: linux/drivers/base/node.c
===================================================================
--- linux.orig/drivers/base/node.c	2005-04-07 15:12:14.750749661 -0500
+++ linux/drivers/base/node.c	2005-04-12 10:54:45.324306797 -0500
@@ -87,7 +87,7 @@ static ssize_t node_read_numastat(struct
 	for (i = 0; i < MAX_NR_ZONES; i++) {
 		struct zone *z = &pg->node_zones[i];
 		for (cpu = 0; cpu < NR_CPUS; cpu++) {
-			struct per_cpu_pageset *ps = &z->pageset[cpu];
+			struct per_cpu_zone_stats *ps = &z->stats[cpu];
 			numa_hit += ps->numa_hit;
 			numa_miss += ps->numa_miss;
 			numa_foreign += ps->numa_foreign;

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
