Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070612200125.GG3798@us.ibm.com>
References: <20070612023209.GJ3798@us.ibm.com>
	 <Pine.LNX.4.64.0706111953220.25390@schroedinger.engr.sgi.com>
	 <20070612032055.GQ3798@us.ibm.com> <1181660782.5592.50.camel@localhost>
	 <20070612172858.GV3798@us.ibm.com> <1181674081.5592.91.camel@localhost>
	 <Pine.LNX.4.64.0706121150220.30754@schroedinger.engr.sgi.com>
	 <1181677473.5592.149.camel@localhost>
	 <Pine.LNX.4.64.0706121245200.7983@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0706121257290.7983@schroedinger.engr.sgi.com>
	 <20070612200125.GG3798@us.ibm.com>
Content-Type: text/plain
Date: Wed, 13 Jun 2007 11:30:06 -0400
Message-Id: <1181748606.6148.19.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-06-12 at 13:01 -0700, Nishanth Aravamudan wrote:
> On 12.06.2007 [12:58:16 -0700], Christoph Lameter wrote:
> > On Tue, 12 Jun 2007, Christoph Lameter wrote:
> > 
> > > Uhhh... Right there is another special case. The recently 
> > > introduces zonelist swizzle makes the DMA zone come last and if a 
> > > node had only a DMA zone then it may become swizzled to the end of 
> > > the zonelist.
> > 
> > Maybe we can ignore that case for now:
> > 
I wish we wouldn't.  We need the "DMA zone comes last" for both HP and
Fujitsu platforms.  That's why Kame and I worked on that patch
together.  

> > 
> > Fix GFP_THISNODE behavior for memoryless nodes
> > 
> > GFP_THISNODE checks that the zone selected is within the pgdat (node) of the
> > first zone of a nodelist. That only works if the node has memory. A
> > memoryless node will have its first node on another pgdat (node).
> > 
> > GFP_THISNODE currently will return simply memory on the first pgdat.
> > Thus it is returning memory on other nodes. GFP_THISNODE should fail
> > if there is no local memory on a node.
> > 
> > So we add a check to verify that the node specified has memory in
> > alloc_pages_node(). If the node has no memory then return NULL.
> > 
> > The case of alloc_pages(GFP_THISNODE) is not changed. alloc_pages() (with no memory
> > policies in effect)
> > 
> > Signed-off-by: Christoph Lameter <clameter@sgi.com>
> > Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> > 
> > Index: linux-2.6.22-rc4-mm2/include/linux/gfp.h
> > ===================================================================
> > --- linux-2.6.22-rc4-mm2.orig/include/linux/gfp.h	2007-06-12 12:33:37.000000000 -0700
> > +++ linux-2.6.22-rc4-mm2/include/linux/gfp.h	2007-06-12 12:38:37.000000000 -0700
> > @@ -175,6 +175,13 @@ static inline struct page *alloc_pages_n
> >  	if (nid < 0)
> >  		nid = numa_node_id();
> > 
> > +	/*
> > +	 * Check for the special case that GFP_THISNODE is used on a
> > +	 * memoryless node
> > +	 */
> > +	if ((gfp_mask & __GFP_THISNODE) && !node_memory(nid))
> > +		return NULL;
> > +
> 
> Yep, this seems to be the right thing to do, and was in my rolled-up
> patch.

I think that the "node has memory" mask is fine for scanning nodes that
might have memory in the zone of interest--including in the hugetlb
alloc_fresh_huge_page() loop.  However, I think that to support all
platforms in a generic way, alloc_pages_node() and
alloc_page_interleave() [both take a node id arg] should be more strict
when the gfp mask includes 'THISNODE and not assume that a populated
node always has on-node memory in the zone of interest.  E.g., something
like:

	pgdat_t *pgdat;
	struct zonelist *zonelist;

	...

	/* 
	 * after validating nid, ... 
	 * Note that we need to fetch these values anyway for the
	 * [likely?] call to __alloc_pages().  
	 */
	pgdat = NODE_DATA(nid);
	zonelist = pgdat->node_zonelists + gfp_zone(gfp_mask);

	if ((gfp_mask & __GFP_THISNODE) &&
		zonelist->zones[0]->zone_pgdat != pgdat)
		return NULL;
	
	return __alloc_pages(gfp_mask, order, zonelist);


I see you've submitted a new patch set.  I grab it [when Nish reposts]
and test it as is and modified to look something like the above, if
needed.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
