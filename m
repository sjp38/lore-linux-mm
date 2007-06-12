Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0706121150220.30754@schroedinger.engr.sgi.com>
References: <20070611234155.GG14458@us.ibm.com>
	 <Pine.LNX.4.64.0706111642450.24042@schroedinger.engr.sgi.com>
	 <20070612000705.GH14458@us.ibm.com>
	 <Pine.LNX.4.64.0706111740280.24389@schroedinger.engr.sgi.com>
	 <20070612020257.GF3798@us.ibm.com>
	 <Pine.LNX.4.64.0706111919450.25134@schroedinger.engr.sgi.com>
	 <20070612023209.GJ3798@us.ibm.com>
	 <Pine.LNX.4.64.0706111953220.25390@schroedinger.engr.sgi.com>
	 <20070612032055.GQ3798@us.ibm.com> <1181660782.5592.50.camel@localhost>
	 <20070612172858.GV3798@us.ibm.com> <1181674081.5592.91.camel@localhost>
	 <Pine.LNX.4.64.0706121150220.30754@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 12 Jun 2007 15:44:33 -0400
Message-Id: <1181677473.5592.149.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-06-12 at 11:51 -0700, Christoph Lameter wrote:
> On Tue, 12 Jun 2007, Lee Schermerhorn wrote:
> 
> > Well, my patch [v4] fixed it on my platform.  So this is a regression
> > relative to my patch.  But, then, my patch had an issue with an x86_64
> > system where one node is all/mostly DMA32 and other nodes have memory in
> > higher zones.  Maybe that's OK [or not] for hugepage allocation, but
> > almost certainly not for regular page interleaving, ...
> 
> Well this means your patch was arch specific.

Worse than that--the problem is platform specific.  I thought the patch
was generic--that's what I was striving for.  I just hadn't thought
through the implications for x86_64 platforms with just the right amount
of memory to cause a problem.

I tested on a 2 socket, 4GB blade.  All memory, both nodes, was DMA32 or
lower, so policy_zone == ZONE_DMA32 and it worked fine.  I tested on a 4
socket, 32GB server--8GB per node.  Policy_zone was ZONE_NORMAL, but all
nodes had at least 4G of normal memory.  For the nr_hugepages that I
tried, I saw the pages allocated evenly across the nodes.  Guess I
didn't ask for enough pages to consume all of the normal memory on node
0 to see any imbalance thereafter.

> 
> > > I'm much more concerned in the short term about the whole
> > > memoryless-node issue, which I think is more straight-forward, and
> > > generic to fix.
> > 
> > Perhaps, but I think we're still going to get off node allocations with
> > the revised definition of the populated map and the new zonelist
> > ordering.  I think we'll need to check for and reject off-node
> > allocations when '_THISNODE is specified.  We can't assume that the
> > first zone in a node's zonelist for a given gfp_zone is on-node.
> 
> We do not do that anymore. GFP_THISNODE guarantees the allocation on 
> the node with alloc_pages_node. Read on.

I have been reading.  Might work as you say.  Not because you're testing
the populated map in alloc_pages_node().  That can still pass an
off-node zonelist to __alloc_pages().  However, I'm hoping that the test
of the zone_pgdat in get_page_from_freelist() will do the right thing.
I'm referring to:

                
	if (unlikely(NUMA_BUILD && (gfp_mask & __GFP_THISNODE) &&
	    zone->zone_pgdat != zonelist->zones[0]->zone_pgdat))
		break;

But, I'm not convinced that zonelist->zones[0]->zone_pgdat always refers
to the node specified the 'nid' argument of alloc_pages_node().  It was
with my definition of the populated map, but I don't think so, now.

We'll see.

Lee




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
