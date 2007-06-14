Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5EENcF1017741
	for <linux-mm@kvack.org>; Thu, 14 Jun 2007 10:23:38 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5EENbUj216656
	for <linux-mm@kvack.org>; Thu, 14 Jun 2007 08:23:37 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5EENbKj005366
	for <linux-mm@kvack.org>; Thu, 14 Jun 2007 08:23:37 -0600
Date: Thu, 14 Jun 2007 07:23:34 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 2/3] Fix GFP_THISNODE behavior for memoryless nodes
Message-ID: <20070614142334.GB7469@us.ibm.com>
References: <20070612204843.491072749@sgi.com> <20070612205738.548677035@sgi.com> <1181769033.6148.116.camel@localhost> <Pine.LNX.4.64.0706140004070.11676@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706140004070.11676@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

On 14.06.2007 [00:07:28 -0700], Christoph Lameter wrote:
> On Wed, 13 Jun 2007, Lee Schermerhorn wrote:
> 
> > --- Linux.orig/include/linux/gfp.h	2007-06-13 16:36:02.000000000 -0400
> > +++ Linux/include/linux/gfp.h	2007-06-13 16:38:41.000000000 -0400
> > @@ -168,6 +168,9 @@ FASTCALL(__alloc_pages(gfp_t, unsigned i
> >  static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
> >  						unsigned int order)
> >  {
> > +	pg_data_t *pgdat;
> > +	struct zonelist *zonelist;
> > +
> >  	if (unlikely(order >= MAX_ORDER))
> >  		return NULL;
> >  
> > @@ -179,11 +182,13 @@ static inline struct page *alloc_pages_n
> >  	 * Check for the special case that GFP_THISNODE is used on a
> >  	 * memoryless node
> >  	 */
> > -	if ((gfp_mask & __GFP_THISNODE) && !node_memory(nid))
> > +	pgdat = NODE_DATA(nid);
> > +	zonelist = pgdat->node_zonelists + gfp_zone(gfp_mask);
> > +	if ((gfp_mask & __GFP_THISNODE) &&
> > +		pgdat != zonelist->zones[0]->zone_pgdat)
> >  		return NULL;
> >  
> > -	return __alloc_pages(gfp_mask, order,
> > -		NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_mask));
> > +	return __alloc_pages(gfp_mask, order, zonelist);
> >  }
> 
> Good idea but I think this does not address the case where the DMA
> zone of a node was moved to the end of the zonelist. In that case the
> first zone is not on the first pgdat but the node has memory. The
> memory of the node is listed elsewhere in the nodelist. I can probably
> modify __alloc_pages to make GFP_THISNODE to check all zones but we do
> not have the pgdat reference there. Sigh.
> 
> How about generating a special THISNODE zonelist in build_zonelist
> that only contains the zones of a single node. Then just use that one
> if GFP_THISNODE is set. Then we get rid of all the GFP_THISNODE crap
> that I added to __alloc_pages?

Makes sense to me.

Thanks,
NIsh

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
