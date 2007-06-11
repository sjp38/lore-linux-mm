Subject: Re: [PATCH v2] gfp.h: GFP_THISNODE can go to other nodes if some
	are unpopulated
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0706110926110.15868@schroedinger.engr.sgi.com>
References: <20070607150425.GA15776@us.ibm.com>
	 <Pine.LNX.4.64.0706071103240.24988@schroedinger.engr.sgi.com>
	 <20070607220149.GC15776@us.ibm.com> <466D44C6.6080105@shadowen.org>
	 <Pine.LNX.4.64.0706110911080.15326@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0706110926110.15868@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 11 Jun 2007 14:23:42 -0400
Message-Id: <1181586222.8324.78.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Nishanth Aravamudan <nacc@us.ibm.com>, ak@suse.de, anton@samba.org, mel@csn.ul.ie, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2007-06-11 at 09:42 -0700, Christoph Lameter wrote:
> On Mon, 11 Jun 2007, Christoph Lameter wrote:
> 
> > Well maybe we better fix this? I put an effort into using only cachelines 
> > already used for GFP_THISNODE since this is in a very performance 
> > critical path but at that point I was not thinking that we 
> > would have memoryless nodes.
> 
> Duh. Too bad. The node information is not available in __alloc_pages at 
> all. The only thing we have to go on is a zonelist. And the first element 
> of that zonelist must no longer be the node from which we picked up 
> the zonelist after memoryless nodes come into play.
> 
> We could check this for alloc_pages_node() and alloc_pages_current by 
> putting in some code into the place where we retrive the zonelist based on 
> the current policy.
> 
> And looking at that code I can see some more bad consequences of 
> memoryless nodes:
> 
> 1. Interleave to the memoryless node will be redirected to the nearest
>    node to the memoryless node. This will typically result in the nearest
>    node getting double the allocations if interleave is set.
> 
>    So interleave is basically broken. It will no longer spread out the
>    allocations properly.

Yeah.  That's what was happening with the hugepage allocation that Anton
Blanchard started the patch for.   I reworked the patch, with some input
from you as I recall, to utilize a "populate node map" that specified
which nodes contain memory in the "policy zone".   Nish just reposted
this patch after testing on his platforms with his per node nr_hugepages
sysfs attribute patches.

> 
> 2. MPOL_BIND may allow allocations outside of the nodes specified.
>    It assumes that the first item of the zonelist of each node
>    is that zone.
> 
> 
> So we have a universal assumption in the VM that the first zone of a
> zonelist contains the local node. The current way of generating
> zonelists for memoryless zones is broken (unsurprisingly since the NUMA 
> handling was never designed to handle memoryless nodes).
> 
> I think we can to fix all these troubles by adding a empty zone as
> a first zone in the zonelist if the node has no memory of its own.
> Then we need to make sure that we do the right thing of falling back 
> anytime these empty zones will be encountered.

As I recall, that was Anton's first attempt.  He just left the empty
nodes in the list.  Andi asked him not to do that as it apparently
violated some other [unspecified?] assumptions in the policy code.

Perhaps Andi's objection was because the empty node's zones were not
properly initialized for some usages?

> 
> This will have the effect of
> 
> 1. GFP_THISNODE will fail since there is no memory in the empty zone.
> 
> 2. MPOL_BIND will not allocate on nodes outside of the specified set
>    since there will be an empty zone in the generated zonelist.
> 
> 3. Interleave will still hit an empty zones and fall back to the next.
>    We should add detection of memoryless nodes to mempoliy.c to skip
>    those nodes.

When the hugepages patch was evolving, I suggested that we might want to
export the "populated map" to applications so that they could ask to
bind to or interleave across only populated nodes.  We never pursued
that.  Maybe just eliminate nodes that are unpopulated in the "policy
zone" from the node masks for MPOL_BIND and MPOL_INTERLEAVE in the
system calls?  Saves checking the populated node set in the allocation
paths.  Would need appropriate error return if this resulted in empty
nodemask.

Of course, memory hotplug could result in nodes becoming empty after the
nodemasks are adjusted, so we probably can't avoid checks in the
allocation paths if we want to avoid the bind and interleave issues you
mention above.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
