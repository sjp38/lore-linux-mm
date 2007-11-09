Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA9Gjel5030557
	for <linux-mm@kvack.org>; Fri, 9 Nov 2007 11:45:40 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA9GjdQU108282
	for <linux-mm@kvack.org>; Fri, 9 Nov 2007 11:45:40 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA9Gjd83013621
	for <linux-mm@kvack.org>; Fri, 9 Nov 2007 11:45:39 -0500
Date: Fri, 9 Nov 2007 08:45:37 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH 6/6] Use one zonelist that is filtered by nodemask
Message-ID: <20071109164537.GG7507@us.ibm.com>
References: <20071109143226.23540.12907.sendpatchset@skynet.skynet.ie> <20071109143426.23540.44459.sendpatchset@skynet.skynet.ie> <Pine.LNX.4.64.0711090741120.13932@schroedinger.engr.sgi.com> <20071109161455.GB32088@skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071109161455.GB32088@skynet.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On 09.11.2007 [16:14:55 +0000], Mel Gorman wrote:
> On (09/11/07 07:45), Christoph Lameter didst pronounce:
> > On Fri, 9 Nov 2007, Mel Gorman wrote:
> > 
> > >  struct page * fastcall
> > >  __alloc_pages(gfp_t gfp_mask, unsigned int order,
> > >  		struct zonelist *zonelist)
> > >  {
> > > +	/*
> > > +	 * Use a temporary nodemask for __GFP_THISNODE allocations. If the
> > > +	 * cost of allocating on the stack or the stack usage becomes
> > > +	 * noticable, allocate the nodemasks per node at boot or compile time
> > > +	 */
> > > +	if (unlikely(gfp_mask & __GFP_THISNODE)) {
> > > +		nodemask_t nodemask;
> > 
> > Hmmm.. This places a potentially big structure on the stack. nodemask can 
> > contain up to 1024 bits which means 128 bytes. Maybe keep an array of 
> > gfp_thisnode nodemasks (node_nodemask?) and use node_nodemask[nid]?
> > 
> 
> That is what I was hinting at in the comment as a possible solution.
> 
> > > +
> > > +		return __alloc_pages_internal(gfp_mask, order,
> > > +			zonelist, nodemask_thisnode(numa_node_id(), &nodemask));
> > 
> > Argh.... GFP_THISNODE must use the nid passed to alloc_pages_node
> > and *not* the local numa node id. Only if the node specified to
> > alloc_pages nodes is -1 will this work.
> > 
> 
> alloc_pages_node() calls __alloc_pages_nodemask() though where in this
> function if I'm reading it right is called without a node id. Given no
> other details on the nid, the current one seemed a logical choice.

Yeah, I guess the context here matters (and is a little hard to follow
because thare are a few places that change in different ways here):

For allocating pages from a particular node (GFP_THISNODE with nid),
the nid clearly must be specified. This only happens with
alloc_pages_node(), AFAICT. So, in that interface, the right thing is
done and the appropriate nodemask will be built.

On the other hand, if we call alloc_pages() with GFP_THISNODE set, there
is no nid to base the allocation on, so we "fallback" to numa_node_id()
[ almost like the nid had been specified as -1 ].

So I guess this is logical -- but I wonder, do we have any callers of
alloc_pages(GFP_THISNODE) ? It seems like an odd thing to do, when
alloc_pages_node() exists?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
