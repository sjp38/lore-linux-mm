Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 043DC6B0055
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 09:02:18 -0400 (EDT)
Date: Wed, 17 Jun 2009 14:02:16 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/5] Huge Pages Nodes Allowed
Message-ID: <20090617130216.GF28529@csn.ul.ie>
References: <20090616135228.25248.22018.sendpatchset@lts-notebook>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090616135228.25248.22018.sendpatchset@lts-notebook>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, Jun 16, 2009 at 09:52:28AM -0400, Lee Schermerhorn wrote:
> Because of assymmetries in some NUMA platforms, and "interesting"
> topologies emerging in the "scale up x86" world, we have need for
> better control over the placement of "fresh huge pages".  A while
> back Nish Aravamundan floated a series of patches to add per node
> controls for allocating pages to the hugepage pool and removing
> them.  Nish apparently moved on to other tasks before those patches
> were accepted.  I have kept a copy of Nish's patches and have
> intended to rebase and test them and resubmit.
> 
> In an [off-list] exchange with Mel Gorman, who admits to knowledge
> in the huge pages area, I asked his opinion of per node controls
> for huge pages and he suggested another approach:  using the mempolicy
> of the task that changes nr_hugepages to constrain the fresh huge
> page allocations.  I considered this approach but it seemed to me
> to be a misuse of mempolicy for populating the huge pages free
> pool. 

Why would it be a misuse? Fundamentally, the huge page pools are being
filled by the current process when nr_hugepages is being used. Or are
you concerned about the specification of hugepages on the kernel command
line?

> Interleave policy doesn't have same "this node" semantics
> that we want

By "this node" semantics, do you mean allocating from one specific node?
In that case, why would specifying a nodemask of just one node not be
sufficient?

> and bind policy would require constructing a custom
> node mask for node as well as addressing OOM, which we don't want
> during fresh huge page allocation. 

Would the required mask not already be setup when the process set the
policy? OOM is not a major concern, it doesn't trigger for failed
hugepage allocations.

> One could derive a node mask
> of allowed nodes for huge pages from the mempolicy of the task
> that is modifying nr_hugepages and use that for fresh huge pages
> with GFP_THISNODE.  However, if we're not going to use mempolicy
> directly--e.g., via alloc_page_current() or alloc_page_vma() [with
> yet another on-stack pseudo-vma :(]--I thought it cleaner to
> define a "nodes allowed" nodemask for populating the [persistent]
> huge pages free pool.
> 

How about adding alloc_page_mempolicy() that takes the explicit mempolicy
you need?

> This patch series introduces a [per hugepage size] "sysctl",
> hugepages_nodes_allowed, that specifies a nodemask to constrain
> the allocation of persistent, fresh huge pages.   The nodemask
> may be specified by a sysctl, a sysfs huge pages attribute and
> on the kernel boot command line.  
> 
> The series includes a patch to free hugepages from the pool in a
> "round robin" fashion, interleaved across all on-line nodes to
> balance the hugepage pool across nodes.  Nish had a patch to do
> this, too.
> 
> Together, these changes don't provide the fine grain of control
> that per node attributes would. 

I'm failing to understand at the moment why mem policies set by numactl
would not do the job for allocation at least. Freeing is a different problem.

> Specifically, there is no easy
> way to reduce the persistent huge page count for a specific node.
> I think the degree of control provided by these patches is the
> minimal necessary and sufficient for managing the persistent the
> huge page pool.  However, with a bit more reorganization,  we
> could implement per node controls if others would find that
> useful.
> 
> For more info, see the patch descriptions and the updated kernel
> hugepages documentation.
> 


-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
