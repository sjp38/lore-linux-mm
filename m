Date: Mon, 8 Oct 2007 18:56:05 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 6/6] Use one zonelist that is filtered by nodemask
In-Reply-To: <20071009011143.GC14670@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0710081854370.28455@schroedinger.engr.sgi.com>
References: <20070928142326.16783.98817.sendpatchset@skynet.skynet.ie>
 <20070928142526.16783.97067.sendpatchset@skynet.skynet.ie>
 <20071009011143.GC14670@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Mon, 8 Oct 2007, Nishanth Aravamudan wrote:

> >  struct page * fastcall
> >  __alloc_pages(gfp_t gfp_mask, unsigned int order,
> >  		struct zonelist *zonelist)
> >  {
> > +	/*
> > +	 * Use a temporary nodemask for __GFP_THISNODE allocations. If the
> > +	 * cost of allocating on the stack or the stack usage becomes
> > +	 * noticable, allocate the nodemasks per node at boot or compile time
> > +	 */
> > +	if (unlikely(gfp_mask & __GFP_THISNODE)) {
> > +		nodemask_t nodemask;
> > +
> > +		return __alloc_pages_internal(gfp_mask, order,
> > +				zonelist, nodemask_thisnode(&nodemask));
> > +	}
> > +
> >  	return __alloc_pages_internal(gfp_mask, order, zonelist, NULL);
> >  }
> 
> <snip>
> 
> So alloc_pages_node() calls here and for THISNODE allocations, we go ask
> nodemask_thisnode() for a nodemask...

Hmmmm... nodemask_thisnode needs to be passed the zonelist.

> And nodemask_thisnode() always gives us a nodemask with only the node
> the current process is running on set, I think?

Right.

 
> That seems really wrong -- and would explain what Lee was seeing while
> using my patches for the hugetlb pool allocator to use THISNODE
> allocations. All the allocations would end up coming from whatever node
> the process happened to be running on. This obviously messes up hugetlb
> accounting, as I rely on THISNODE requests returning NULL if they go
> off-node.
> 
> I'm not sure how this would be fixed, as __alloc_pages() no longer has
> the nid to set in the mask.
> 
> Am I wrong in my analysis?

No you are right on target. The thisnode function must determine the node 
from the first zone of the zonelist.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
