Date: Fri, 27 Jul 2007 11:55:35 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Document Linux Memory Policy - V2
In-Reply-To: <1185559260.5069.40.camel@localhost>
Message-ID: <Pine.LNX.4.64.0707271148170.16415@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
 <20070725111646.GA9098@skynet.ie>  <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com>
  <20070726132336.GA18825@skynet.ie>  <Pine.LNX.4.64.0707261104360.2374@schroedinger.engr.sgi.com>
  <20070726225920.GA10225@skynet.ie>  <Pine.LNX.4.64.0707261819530.18210@schroedinger.engr.sgi.com>
  <20070727082046.GA6301@skynet.ie> <20070727154519.GA21614@skynet.ie>
 <Pine.LNX.4.64.0707271026040.15990@schroedinger.engr.sgi.com>
 <1185559260.5069.40.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, ak@suse.de, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, pj@sgi.com, Michael Kerrisk <mtk-manpages@gmx.net>, Randy Dunlap <randy.dunlap@oracle.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, 27 Jul 2007, Lee Schermerhorn wrote:

> +    Shared Policy:  This policy applies to "memory objects" mapped shared into
> +    one or more tasks' distinct address spaces.  Shared policies are applied
> +    directly to the shared object.  Thus, all tasks that attach to the object
> +    share the policy, and all pages allocated for the shared object, by any
> +    task, will obey the shared policy.

This applies to shmem only not to shared memory. Shared memory can also 
come about by mmapping a file etc. Its better to describe shmem 
as an exceptional situation later and warn of the surprises coming with 
the use of memory policies on shmem in a separate section.

> +	MPOL_BIND:  This mode specifies that memory must come from the
> +	set of nodes specified by the policy.  The kernel builds a custom
> +	zonelist pointed to by the zonelist member of struct mempolicy,
> +	containing just the nodes specified by the Bind policy.  If the kernel
> +	is unable to allocate a page from the first node in the custom zonelist,
> +	it moves on to the next, and so forth.  If it is unable to allocate a
> +	page from any of the nodes in this list, the allocation will fail.

The implementation details may not be useful to explain here and may 
change soon. Maybe just describe the effect?

> +	    The memory policy APIs do not specify an order in which the nodes
> +	    will be searched.  However, unlike the per node zonelists mentioned
> +	    above, the custom zonelist for the Bind policy do not consider the
> +	    distance between the nodes.  Rather, the lists are built in order
> +	    of numeric node id.

Yea another reson to get the nodemask as a parameter for alloc_pages().

> +2) when tasks in two cpusets share access to a memory region, such as shared
> +   memory segments created by shmget() of mmap() with the MAP_ANONYMOUS and
> +   MAP_SHARED flags, only nodes whose memories are allowed in both cpusets
> +   may be used in the policies.  Again, obtaining this information requires
> +   "stepping outside" the memory policy APIs to use the cpuset information.
> +   Furthermore, if the cpusets' "allowed memory" sets are disjoint, "local"
> +   allocation is the only valid policy.

In general this works fine with a shared mapping via mmap (which is much 
more common). The problem exists if one uses shmem with the strange shared 
semantics.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
