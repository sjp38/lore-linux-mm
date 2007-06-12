Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070612172858.GV3798@us.ibm.com>
References: <20070611234155.GG14458@us.ibm.com>
	 <Pine.LNX.4.64.0706111642450.24042@schroedinger.engr.sgi.com>
	 <20070612000705.GH14458@us.ibm.com>
	 <Pine.LNX.4.64.0706111740280.24389@schroedinger.engr.sgi.com>
	 <20070612020257.GF3798@us.ibm.com>
	 <Pine.LNX.4.64.0706111919450.25134@schroedinger.engr.sgi.com>
	 <20070612023209.GJ3798@us.ibm.com>
	 <Pine.LNX.4.64.0706111953220.25390@schroedinger.engr.sgi.com>
	 <20070612032055.GQ3798@us.ibm.com> <1181660782.5592.50.camel@localhost>
	 <20070612172858.GV3798@us.ibm.com>
Content-Type: text/plain
Date: Tue, 12 Jun 2007 14:48:01 -0400
Message-Id: <1181674081.5592.91.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-06-12 at 10:28 -0700, Nishanth Aravamudan wrote:
> On 12.06.2007 [11:06:22 -0400], Lee Schermerhorn wrote:
<snip>
> > 
> > Nish:  when this all settles down, I still need to make sure it works
> > on our platforms with the funny DMA-only node.  What that comes down
> > to is that when alloc_fresh_huge_page() calls:
> 
> Ok, thanks for these details.
> 
> Would you be ok with stabilizing the generic definition of
> node_populated_map as is (any present pages, regardless of location),
> and then trying to figure out how to get your platform to work with
> that?

Yeah, I think that's my only option now that node_populated_map is being
used for other things than huge page setup.

> 
> > 		page = alloc_pages_node(nid,
> >                                GFP_HIGHUSER|__GFP_COMP|GFP_THISNODE,
> >                                HUGETLB_PAGE_ORDER);
> > 
> > I need to get a page that is on nid.  On our platform, GFP_HIGHUSER is
> > going to specify the zonelist for ZONE_NORMAL.  The first zone on this
> > list needs to be on-node for nid.  With the changes you've made to the
> > definition of populated map, I think this won't be the case.  I need
> > to test your latest patches and fix that, if it's broken.
> 
> Ok. But that means your platform is broken now too, right? As in, it's
> not a regression, per se?

Well, my patch [v4] fixed it on my platform.  So this is a regression
relative to my patch.  But, then, my patch had an issue with an x86_64
system where one node is all/mostly DMA32 and other nodes have memory in
higher zones.  Maybe that's OK [or not] for hugepage allocation, but
almost certainly not for regular page interleaving, ...

> 
> I'm much more concerned in the short term about the whole
> memoryless-node issue, which I think is more straight-forward, and
> generic to fix.

Perhaps, but I think we're still going to get off node allocations with
the revised definition of the populated map and the new zonelist
ordering.  I think we'll need to check for and reject off-node
allocations when '_THISNODE is specified.  We can't assume that the
first zone in a node's zonelist for a given gfp_zone is on-node.

[more in response to other mail...]

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
