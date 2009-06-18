Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 380186B004F
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 05:32:06 -0400 (EDT)
Date: Thu, 18 Jun 2009 10:33:02 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/5] Huge Pages Nodes Allowed
Message-ID: <20090618093301.GD14903@csn.ul.ie>
References: <20090616135228.25248.22018.sendpatchset@lts-notebook> <20090617130216.GF28529@csn.ul.ie> <1245258954.6235.58.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1245258954.6235.58.camel@lts-notebook>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, Jun 17, 2009 at 01:15:54PM -0400, Lee Schermerhorn wrote:
> On Wed, 2009-06-17 at 14:02 +0100, Mel Gorman wrote:
> > On Tue, Jun 16, 2009 at 09:52:28AM -0400, Lee Schermerhorn wrote:
> > > Because of assymmetries in some NUMA platforms, and "interesting"
> > > topologies emerging in the "scale up x86" world, we have need for
> > > better control over the placement of "fresh huge pages".  A while
> > > back Nish Aravamundan floated a series of patches to add per node
> > > controls for allocating pages to the hugepage pool and removing
> > > them.  Nish apparently moved on to other tasks before those patches
> > > were accepted.  I have kept a copy of Nish's patches and have
> > > intended to rebase and test them and resubmit.
> > > 
> > > In an [off-list] exchange with Mel Gorman, who admits to knowledge
> > > in the huge pages area, I asked his opinion of per node controls
> > > for huge pages and he suggested another approach:  using the mempolicy
> > > of the task that changes nr_hugepages to constrain the fresh huge
> > > page allocations.  I considered this approach but it seemed to me
> > > to be a misuse of mempolicy for populating the huge pages free
> > > pool. 
> > 
> > Why would it be a misuse? Fundamentally, the huge page pools are being
> > filled by the current process when nr_hugepages is being used. Or are
> > you concerned about the specification of hugepages on the kernel command
> > line?
> 
> Well, "misuse" might be too strong [and I already softened it from
> "abuse" :)]--more like "not a good fit, IMO".   I agree that it could be
> made to work, but it just didn't "feel" right.  I suppose that we could
> use alloc_pages_current() with the necessary gfp flags to specify the
> "thisnode"/"exact_node" semantics [no fallback], making sure we didn't
> OOM kill the task if a node couldn't satisfy the huge page
> allocation, ...  I think it would require major restructuring of
> set_max_huge_pages(), ...  Maybe that would be the right thing to do and
> maybe we'll end up there, but I was looking for a simpler approach.  
> 

Ultimately I think it's the right way of doing things. hugepages in the
past had a large number of "special" considerations in comparison to the
core VM. We've removed a fair few of the special cases in the last year
and I'd rather avoid introducing more of them.

If I was as an administrator, I would prefer being able to do allocate
hugepages only on two nodes with

# numactl --interleave 0,2 hugeadm --pool-pages-min=2M:128

instead of

# echo some_magic > /proc/sys/vm/hugepage_nodes_allowed
# hugeadm --pool-pages-min=2M:128

hugeadm would have to be taught about the new sysctl of course if it's created
but it still feels more awkward than it should be and numactl should already
be familar.

> And, yes, the kernel command line was a consideration.  Because of that,
> I considered specifying a boot time "nodes_allowed" mask and
> constructing a "nodes_allowed" mask at run time from the current task's
> policy.  But, it seemed more straightforward to my twisted way of
> thinking to make the nodes_allowed mask a bona fide hstate attribute.
> 

I see scope for allowing the nodemask to be specified at boot-time all right,
heck it might even be required! However, I am somewhat attached to the idea
of static hugepage allocation obeying memory policies.

> > 
> > > Interleave policy doesn't have same "this node" semantics
> > > that we want
> > 
> > By "this node" semantics, do you mean allocating from one specific node?
> 
> Yes.
> 
> > In that case, why would specifying a nodemask of just one node not be
> > sufficient?
> 
> Maybe along with GFP_THISNODE. 

But a nodemask of just one node might as well be GFP_THISNODE, right?

> In general, we want to interleave the
> persistent huge pages over multiple nodes, but we don't want the
> allocations to succeed by falling back to another node.  Then we end up
> with unbalanced allocations.  This is how fresh huge page allocation
> worked before it was changed to use "THISNODE".
> 
> 
> > 
> > > and bind policy would require constructing a custom
> > > node mask for node as well as addressing OOM, which we don't want
> > > during fresh huge page allocation. 
> > 
> > Would the required mask not already be setup when the process set the
> > policy? OOM is not a major concern, it doesn't trigger for failed
> > hugepage allocations.
> 
> Perhaps not with the current implementation.  However, a certain,
> currently shipping, enterprise distro added a "quick and dirty"  [well,
> "dirty", anyway :)] implementation of "thisnode" behavior to elimiate
> the unwanted fallback behavior and resulting huge pages imbalance by
> constructing an ad hoc "MPOL_BIND" policy for allocating huge pages.  We
> found that this DOES result in oom kill of the task increasing
> nr_hugepages if it encountered a node w/ no available huge pages.
> 

Fun.

> If one used "echo" [usually a shell builtin] to increase nr_hugepages,
> it killed off your shell.  sysctl was somewhat better--only killed
> sysctl.  The good news was that oom kill just sets a thread info flag,
> so the nr_hugepages handler continued to allocate pages around the nodes
> and further oom kills were effective no-ops.  When the allocations was
> done, the victim task would die.  End users might not consider this
> acceptable behavior.
> 

No. My current expectation is that we've handled the vast majority of
cases where processes could get unexpectedly killed just because they
were looking funny at hugepages.

> I wasn't sure we'd avoid this situation if we dropped back to using task
> mempolicy via, e.g., alloc_pages_current().  So, I thought I'd run this
> proposal [nodes_allowed] by you.
> 

I'm not wholesale against it. Minimally, I see scope for specifying the
nodemask at boot-time but I'm less sold on the sysctl at the moment because
I'm not convinced that applying memory policies when sizing the hugepage pool
cannot be made work to solve your problem.

> > 
> > > One could derive a node mask
> > > of allowed nodes for huge pages from the mempolicy of the task
> > > that is modifying nr_hugepages and use that for fresh huge pages
> > > with GFP_THISNODE.  However, if we're not going to use mempolicy
> > > directly--e.g., via alloc_page_current() or alloc_page_vma() [with
> > > yet another on-stack pseudo-vma :(]--I thought it cleaner to
> > > define a "nodes allowed" nodemask for populating the [persistent]
> > > huge pages free pool.
> > > 
> > 
> > How about adding alloc_page_mempolicy() that takes the explicit mempolicy
> > you need?
> 
> Interesting you should mention this.  Somewhat off topic:  I have a
> "cleanup" and reorg of shared policy and vma policy that separates
> policy lookup from allocation, and adds an "alloc_page_pol()" function.
> This is part of my series to generalize shared policy and extend it to
> shared, mmap()ed regular files.  That aspect of the series [shared
> policy on shared mmaped files] got a lot of push back without any
> consideration of the technical details of the patches themselves.

Those arguements feel vaguely familiar. I think I read the thread although
the specifics of the objections escape me. Think there was something about
non-determinism if two processes shared a mapping with different policies
and no idea which should take precedence.

> Besides having need/requests for this capability, the resulting cleanup,
> removal of all on-stack pseudo-vmas, ..., the series actually seems to
> perform [slightly] better on the testing I've done.
> 
> I keep this series up to date and hope to repost again sometime with
> benchmark results. 
> 

Sounds like a good idea. If the cleanup yielded an alloc_page_pol()
function, it might make the patch for hugetlbfs more straight-forward.

> 
> > 
> > > This patch series introduces a [per hugepage size] "sysctl",
> > > hugepages_nodes_allowed, that specifies a nodemask to constrain
> > > the allocation of persistent, fresh huge pages.   The nodemask
> > > may be specified by a sysctl, a sysfs huge pages attribute and
> > > on the kernel boot command line.  
> > > 
> > > The series includes a patch to free hugepages from the pool in a
> > > "round robin" fashion, interleaved across all on-line nodes to
> > > balance the hugepage pool across nodes.  Nish had a patch to do
> > > this, too.
> > > 
> > > Together, these changes don't provide the fine grain of control
> > > that per node attributes would. 
> > 
> > I'm failing to understand at the moment why mem policies set by numactl
> > would not do the job for allocation at least. Freeing is a different problem.
> 
> They could be made to work.  I actually started coding up a patch to
> extract a "nodes allowed" mask from the policy for use with
> alloc_fresh_huge_page[_node]() so that I could maintain the overall
> structure and use alloc_page_exact_node() with nodes in the allowed
> mask.  And, as you say, with some investigation, we may find that we can
> use alloc_pages_current() with appropriate flags to achieve the exact
> node semantics on each node in the policy.
> 

I'd like to see it investigated more please.

> > 
> > > Specifically, there is no easy
> > > way to reduce the persistent huge page count for a specific node.
> > > I think the degree of control provided by these patches is the
> > > minimal necessary and sufficient for managing the persistent the
> > > huge page pool.  However, with a bit more reorganization,  we
> > > could implement per node controls if others would find that
> > > useful.
> > > 
> > > For more info, see the patch descriptions and the updated kernel
> > > hugepages documentation.
> > > 
> > 
> 
> More in response to your comments on the individual patches.
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
