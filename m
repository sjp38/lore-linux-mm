Received: by mu-out-0910.google.com with SMTP id g7so260158muf
        for <linux-mm@kvack.org>; Wed, 18 Jul 2007 08:17:45 -0700 (PDT)
Message-ID: <29495f1d0707180817n7a5709dcr78b641a02cb18057@mail.gmail.com>
Date: Wed, 18 Jul 2007 08:17:44 -0700
From: "Nish Aravamudan" <nish.aravamudan@gmail.com>
Subject: Re: [PATCH 5/5] [hugetlb] Try to grow pool for MAP_SHARED mappings
In-Reply-To: <1184769889.5899.16.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070713151621.17750.58171.stgit@kernel>
	 <20070713151717.17750.44865.stgit@kernel>
	 <20070713130508.6f5b9bbb.pj@sgi.com>
	 <1184360742.16671.55.camel@localhost.localdomain>
	 <20070713143838.02c3fa95.pj@sgi.com>
	 <29495f1d0707171642t7c1a26d7l1c36a896e1ba3b47@mail.gmail.com>
	 <1184769889.5899.16.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Paul Jackson <pj@sgi.com>, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org, mel@skynet.ie, apw@shadowen.org, wli@holomorphy.com, clameter@sgi.com, kenchen@google.com, Paul Mundt <lethal@linux-sh.org>
List-ID: <linux-mm.kvack.org>

On 7/18/07, Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> On Tue, 2007-07-17 at 16:42 -0700, Nish Aravamudan wrote:
> > On 7/13/07, Paul Jackson <pj@sgi.com> wrote:
> > > Adam wrote:
> > > > To be honest, I just don't think a global hugetlb pool and cpusets are
> > > > compatible, period.
> > >
> > > It's not an easy fit, that's for sure ;).
> >
> > In the context of my patches to make the hugetlb pool's interleave
> > work with memoryless nodes, I may have pseudo-solution for growing the
> > pool while respecting cpusets.
> >
> > Essentially, given that GFP_THISNODE allocations stay on the node
> > requested (which is the case after Christoph's set of memoryless node
> > patches go in), we invoke:
> >
> >   pol = mpol_new(MPOL_INTERLEAVE, &node_states[N_MEMORY])
> >
> > in the two callers of alloc_fresh_huge_page(pol) in hugetlb.c.
> > alloc_fresh_huge_page() in turn invokes interleave_nodes(pol) so that
> > we request hugepages in an interleaved fashion over all nodes with
> > memory.
> >
> > Now, what I'm wondering is why interleave_nodes() is not cpuset aware?
> > Or is it expected that the caller do the right thing with the policy
> > beforehand? If so, I think I could just make those two callers do
> >
> >   pol = mpol_new(MPOL_INTERLEAVE, cpuset_mems_allowed(current))
> >
> > ?
> >
> > Or am I way off here?
>
>
> Nish:
>
> I have always considered the huge page pool, as populated by
> alloc_fresh_huge_page() in response to changes in nr_hugepages, to be a
> system global resource.  I think the system "does the right
> thing"--well, almost--with Christoph's memoryless patches and your
> hugetlb patches.  Certaintly, the huge pages allocated at boot time,
> based on the command line parameter, are system-wide.  cpusets have not
> been set up at that time.

I fully agree that hugepages are a global resource.

> It requires privilege to write to the nr_hugepages sysctl, so allowing
> it to spread pages across all available nodes [with memory], regardless
> of cpusets, makes sense to me.  Altho' I don't expect many folks are
> currently changing nr_hugepages from within a constrained cpuset, I
> wouldn't want to see us change existing behavior, in this respect.  Your
> per node attributes will provide the mechanism to allocate different
> numbers of hugepages for, e.g., nodes in cpusets that have applications
> that need them.

The issue is that with Adam's patches, the hugepage pool will grow on
demand, presuming the process owner's mlock limit is sufficiently
high. If said process were running within a constrained cpuset, it
seems slightly out-of-whack to allow it grow the pool on other nodes
to satisfy the demand.

> Re: the "well, almost":  nr_hugepages is still "broken" for me on some
> of my platforms where the interleaved, dma-only pseudo-node contains
> sufficient memory to satisfy a hugepage request.  I'll end up with a few
> hugepages consuming most of the dma memory.  Consuming the dma isn't the
> issue--there should be enough remaining for any dma needs.  I just want
> more control over what gets placed on the interleaved pseudo-node by
> default.  I think that Paul Mundt [added to cc list] has similar
> concerns about default policies on the sh platforms.  I have some ideas,
> but I'm waiting for the memoryless nodes and your patches to stabilize
> in the mm tree.

And well, we're already 'broken' as far as I can tell with cpusets and
the hugepage pool. I'm just trying to decide if it's fixable as is, or
if we need extra cleverness. A simple hack would be to just modify the
interleave call with a callback that uses the appropriate mask if
CPUSETS is on or off (I don't want to always use cpuset_mems_allowed()
unconditionally, becuase it returns node_possible_map if !CPUSETS.

Thanks for the feedback. If folks are ok with the way things are, then
so be it. I was just hoping Paul might have some thoughts on how best
to avoid violating cpuset constraints with Adam's patches in the
context of my patches.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
