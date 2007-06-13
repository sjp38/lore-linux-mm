Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070613175802.GP3798@us.ibm.com>
References: <20070612032055.GQ3798@us.ibm.com>
	 <1181660782.5592.50.camel@localhost> <20070612172858.GV3798@us.ibm.com>
	 <1181674081.5592.91.camel@localhost>
	 <Pine.LNX.4.64.0706121150220.30754@schroedinger.engr.sgi.com>
	 <1181677473.5592.149.camel@localhost>
	 <Pine.LNX.4.64.0706121245200.7983@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0706121257290.7983@schroedinger.engr.sgi.com>
	 <20070612200125.GG3798@us.ibm.com> <1181748606.6148.19.camel@localhost>
	 <20070613175802.GP3798@us.ibm.com>
Content-Type: text/plain
Date: Wed, 13 Jun 2007 14:21:14 -0400
Message-Id: <1181758874.6148.73.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-06-13 at 10:58 -0700, Nishanth Aravamudan wrote:
> On 13.06.2007 [11:30:06 -0400], Lee Schermerhorn wrote:
> > On Tue, 2007-06-12 at 13:01 -0700, Nishanth Aravamudan wrote:
> > > On 12.06.2007 [12:58:16 -0700], Christoph Lameter wrote:
> > > > On Tue, 12 Jun 2007, Christoph Lameter wrote:
> > > > 
> > > > > Uhhh... Right there is another special case. The recently 
> > > > > introduces zonelist swizzle makes the DMA zone come last and if a 
> > > > > node had only a DMA zone then it may become swizzled to the end of 
> > > > > the zonelist.
> > > > 
> > > > Maybe we can ignore that case for now:
> > > > 
> > I wish we wouldn't.  We need the "DMA zone comes last" for both HP and
> > Fujitsu platforms.  That's why Kame and I worked on that patch
> > together.  
> 
> Right. I interpreted the "for now" as for this first stack of patches.
> We'll need a fix for your platform on top, but it seems to be a minority
> case? Not saying it shouldn't be fixed, by any means, just trying to get
> a handle on it.

Yep.  I'm testing the stack "as is" now.  If it doesn't spread the huge
pages evenly because of our funky DMA-only node, I'll post a fix up
patch for consideration.

By the way, your sysfs attribute patch doesn't compile.  I'll post
comments/fixes in response to your message that submitted the patch.

> 
<snip>

> > 
> > I think that the "node has memory" mask is fine for scanning nodes
> > that might have memory in the zone of interest--including in the
> > hugetlb alloc_fresh_huge_page() loop.  However, I think that to
> > support all platforms in a generic way, alloc_pages_node() and
> > alloc_page_interleave() [both take a node id arg] should be more
> > strict when the gfp mask includes 'THISNODE and not assume that a
> > populated node always has on-node memory in the zone of interest.
> 
> Hrm, perhaps.
> 
> > E.g., something like:
> > 
> > 	pgdat_t *pgdat;
> > 	struct zonelist *zonelist;
> > 
> > 	...
> > 
> > 	/* 
> > 	 * after validating nid, ... 
> > 	 * Note that we need to fetch these values anyway for the
> > 	 * [likely?] call to __alloc_pages().  
> > 	 */
> > 	pgdat = NODE_DATA(nid);
> > 	zonelist = pgdat->node_zonelists + gfp_zone(gfp_mask);
> > 
> > 	if ((gfp_mask & __GFP_THISNODE) &&
> > 		zonelist->zones[0]->zone_pgdat != pgdat)
> > 		return NULL;
> > 	
> > 	return __alloc_pages(gfp_mask, order, zonelist);
> > 
> > 
> > I see you've submitted a new patch set.  I grab it [when Nish reposts]
> > and test it as is and modified to look something like the above, if
> > needed.
> 
> I think your code above makes sense -- I'd still leave in the earlier
> check, though.
> 
> So it probably should be:
> 
> 	pgdat = NODE_DATA(nid);
> 	zonelist = pgdat->node_zonelists + gfp_zone(gfp_mask);
> 
> 	if (unlikely((gfp_mask & __GFP_THISNODE) &&
> 		(!node_memory(nid) ||
> 		 zonelist->zones[0]->zone_pgdat != pgdat)))
> 		 return NULL;
> 
> That way, if the node has no memory whatsoever, we don't bother checking
> the pgdat of the relevant zone?

Well, since most nodes WILL, I think, have memory, that just adds an
extra check in the most frequent case.  Then, we'll have to go ahead and
check the pgdat.  However, if the first zone in the selected zonelist IS
"on-node" [pgdats match], we know that the node has memory [altho' the
zone may not have available pages].  And since we have to fetch the
pgdat and the zonelist, anyway, as the argument to __alloc_pages(), I
don't think my proposed change adds any additional memory ref's, while
eliminating the ref to the node_memory_map.  I'm assuming here that the
compiler will optimize away any stores to the pgdat/zonelist variables.

So, we can use the node_memory() test at higher levels--like the
alloc_fresh_huge_page() loop, to avoid attempting allocations from nodes
that we know have no memory, but I think the allocate_pages_node() and
allocate_interleave_page() should test the selected zonelist explicitly.

Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
