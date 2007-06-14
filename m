Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0706141012200.30147@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0706121150220.30754@schroedinger.engr.sgi.com>
	 <1181677473.5592.149.camel@localhost>
	 <Pine.LNX.4.64.0706121245200.7983@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0706121257290.7983@schroedinger.engr.sgi.com>
	 <20070612200125.GG3798@us.ibm.com> <1181748606.6148.19.camel@localhost>
	 <20070613175802.GP3798@us.ibm.com> <1181758874.6148.73.camel@localhost>
	 <Pine.LNX.4.64.0706131550520.32399@schroedinger.engr.sgi.com>
	 <1181836247.5410.85.camel@localhost> <20070614160913.GF7469@us.ibm.com>
	 <Pine.LNX.4.64.0706140913530.29612@schroedinger.engr.sgi.com>
	 <1181840872.5410.159.camel@localhost>
	 <Pine.LNX.4.64.0706141012200.30147@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 14 Jun 2007 14:04:28 -0400
Message-Id: <1181844269.5410.199.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-06-14 at 10:16 -0700, Christoph Lameter wrote:
> On Thu, 14 Jun 2007, Lee Schermerhorn wrote:
> 
> > If it (slab allocators etc) wants and/or can use memory from a different
> > node from what it requested, then, it shouldn't be calling with
> > GFP_THISNODE, right?  I mean what's the point?  If GFP_THISNODE never
> 
> The code wanted memory from a certain node because a certain structure is 
> performance sensitive and it did get something else. 

Yes, and if they're fine with that, why did they need to specify
'THISNODE.  They called alloc_pages_node() which effectively "prefers"
the specified node without the 'THISNODE flag.  If they're willing to
fallback to off-node allocations, just drop the THISNODE flag...

> Both slab and slub 
> will fail at some point when trying to touch the structure that was not 
> allocated.

Because they failed to check the return from an allocation?

> 
> > returned off-node memory, then one couldn't use it without checking for
> > and dealing with failure.  And, 'THISNODE allocations CAN fail, when the
> 
> GFP_THISNODE *never* should return off node memory. 

I agree!  But the current [generic] code can and will for some hardware
configurations and zonelist order.

> That it happened is 
> due to people not reviewing the VM as I told them to when we starting 
> allowing memoryless nodes in the core VM.

Certainly, more reviewing is a good thing.  My review shows that an
allocation with 'THISNODE specified WILL return off-node memory if the
specified zonelist has an off-node zone in the first slot and some
on-node memory in lower zones later in the list [node zonelist order].
This configuration does occur.  

I think the disconnect is in whether we want THISNODE allocations to
attempt to look past any higher off-zone nodes and return on-node memory
from a lower [DMA/32] zone.  Sound's like this is what you want, but the
current implementation doesn't do that either, when the zonelists are in
node order.  It returns off-node memory for the first zone in the list,
if any.  If the allocation can't be satisfied from the first zone, it
looks at the next.  If the second or subsequent zones are off-node, it
WILL fail, and never get to the on-node DMA/32 zone.   

Idea:  in get_page_from_freelist() [called from __alloc_pages()]:

1) enhance to add check that first zone in zonelist is also
on-node--something it doesn't do now.

2) instead of bailing out when 'THISNODE is set and we encounter an
off-node zone, keep scanning the zonelist for on-node zones.  Bail out
only if we hit the end of the list and haven't satisfied the request.

This will handle zonelists in node order with no local memory in the
requested zone.  'THISNODE allocations can still fail, once the lower
order local zone is exhausted, but at least it won't return off-node
memory.

I'll still have an issue with huge pages coming from the DMA zone for
some configurations, but I can look at tackling that from another
direction.

> 
> > first zone in the selected zonelist is empty and subsequent zones are
> > off-node.  __alloc_pages() et al WILL fail this case and return NULL, so
> > callers must be prepared to deal with it--even [especially?] early boot
> > code, IMO, anyway.
> 
> Bootstrap is a special case. It is a reasonable expectation to find memory 
> on nodes that have memory (i.e. formerly online nodes were guaranteed to 
> have memory now we guarantee that for "memory nodes").

Whether that expectation is reasonable seems to be configuration
dependent.  I still think you should be able to handle allocation
failures when setting up slub caches at boot time.  A BUG_ON in the boot
path is very unfriendly--system stops dead.  Just treat the node as
memoryless from the slab/slub viewpoint if the allocation fails; or
explicitly allocate slab/slub resources from a nearby node by dropping
the 'THISNODE' [if THISNODE behaved consistently...] and retrying.  Just
don't freeze up the machine.

Later,
Lee



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
