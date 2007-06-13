Date: Wed, 13 Jun 2007 16:12:49 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
In-Reply-To: <20070613230906.GV3798@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706131609370.394@schroedinger.engr.sgi.com>
References: <20070612172858.GV3798@us.ibm.com> <1181674081.5592.91.camel@localhost>
 <Pine.LNX.4.64.0706121150220.30754@schroedinger.engr.sgi.com>
 <1181677473.5592.149.camel@localhost> <Pine.LNX.4.64.0706121245200.7983@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0706121257290.7983@schroedinger.engr.sgi.com>
 <20070612200125.GG3798@us.ibm.com> <1181748606.6148.19.camel@localhost>
 <20070613175802.GP3798@us.ibm.com> <Pine.LNX.4.64.0706131549480.32399@schroedinger.engr.sgi.com>
 <20070613230906.GV3798@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Jun 2007, Nishanth Aravamudan wrote:

> > > That way, if the node has no memory whatsoever, we don't bother checking
> > > the pgdat of the relevant zone?
> > 
> > Checking the pgdat is already done in __alloc_pages. No need to repeat
> > it here.
> 
> Except that check is broken in the same way it is for memoryless nodes,
> right?
> 
> from get_page_from_freelist():
> 
>                 if (unlikely(NUMA_BUILD && (gfp_mask & __GFP_THISNODE) &&
>                         zone->zone_pgdat != zonelist->zones[0]->zone_pgdat))
> 
> Which asks if for this zone, is the first node the same as each node we look at
> for THISNODE requests. But if the first node for the zone is a
> *different* node, we still satisfy the request, but go off-node?
> 
> Just trying to see if that maybe is the problem here?

Right. But we do not have the pgdat pointer available in alloc_pages. Thus 
Lee's check works in alloc_pages_node(). Hmmm... This gets pretty 
difficult to comprehend. Maybe there is another easier way to implement 
GFP_THISNODE?

The breakage of SLUB makes it pretty evident that if GFP_THISNODE returns 
NULL for a memoryless node then lots of

for_each_online_node()

loops in the VM that assume that an online node contain memory are no 
longer working properly. We need to review the VM and convert those loops
to use the node_memory_map.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
