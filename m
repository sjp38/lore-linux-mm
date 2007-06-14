Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0706131549480.32399@schroedinger.engr.sgi.com>
References: <20070612032055.GQ3798@us.ibm.com>
	 <1181660782.5592.50.camel@localhost> <20070612172858.GV3798@us.ibm.com>
	 <1181674081.5592.91.camel@localhost>
	 <Pine.LNX.4.64.0706121150220.30754@schroedinger.engr.sgi.com>
	 <1181677473.5592.149.camel@localhost>
	 <Pine.LNX.4.64.0706121245200.7983@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0706121257290.7983@schroedinger.engr.sgi.com>
	 <20070612200125.GG3798@us.ibm.com> <1181748606.6148.19.camel@localhost>
	 <20070613175802.GP3798@us.ibm.com>
	 <Pine.LNX.4.64.0706131549480.32399@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 14 Jun 2007 10:23:49 -0400
Message-Id: <1181831029.5410.20.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-06-13 at 15:50 -0700, Christoph Lameter wrote:
> On Wed, 13 Jun 2007, Nishanth Aravamudan wrote:
> 
> > I think your code above makes sense -- I'd still leave in the earlier
> > check, though.
> > 
> > So it probably should be:
> > 
> > 	pgdat = NODE_DATA(nid);
> > 	zonelist = pgdat->node_zonelists + gfp_zone(gfp_mask);
> > 
> > 	if (unlikely((gfp_mask & __GFP_THISNODE) &&
> > 		(!node_memory(nid) ||
> > 		 zonelist->zones[0]->zone_pgdat != pgdat)))
> > 		 return NULL;
> > 
> > That way, if the node has no memory whatsoever, we don't bother checking
> > the pgdat of the relevant zone?
> 
> Checking the pgdat is already done in __alloc_pages. No need to repeat it 
> here.

As discussed in prior mail, that's too late given the check that's being
done.  Down in get_page_from_freelist(), where this check is made, we
don't have the node id nor pgdat from which the allocation is being
attempted.  The node id of the first zone in the list may already be
off-node [even tho' the node_memory_map says the node is populated/has
memory], so we can't rely on that.  

I suppose we could add the pgdat pointer to the zonelist itself or try
to backup to the original pgdat from the zonelist and
gfp_zone(gfp_mask).  Then we could do the check in
get_page_from_freelist() that each zone in the list is on-node.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
