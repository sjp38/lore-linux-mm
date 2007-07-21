Date: Sun, 22 Jul 2007 01:57:55 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH 5/5] [hugetlb] Try to grow pool for MAP_SHARED mappings
Message-ID: <20070721165755.GB4043@linux-sh.org>
References: <20070713151717.17750.44865.stgit@kernel> <20070713130508.6f5b9bbb.pj@sgi.com> <1184360742.16671.55.camel@localhost.localdomain> <20070713143838.02c3fa95.pj@sgi.com> <29495f1d0707171642t7c1a26d7l1c36a896e1ba3b47@mail.gmail.com> <1184769889.5899.16.camel@localhost> <29495f1d0707180817n7a5709dcr78b641a02cb18057@mail.gmail.com> <1184774524.5899.49.camel@localhost> <20070719015231.GA16796@linux-sh.org> <29495f1d0707201335u5fbc9565o2a53a18e45d8b28@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <29495f1d0707201335u5fbc9565o2a53a18e45d8b28@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nish Aravamudan <nish.aravamudan@gmail.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Paul Jackson <pj@sgi.com>, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org, mel@skynet.ie, apw@shadowen.org, wli@holomorphy.com, clameter@sgi.com, kenchen@google.com
List-ID: <linux-mm.kvack.org>

On Fri, Jul 20, 2007 at 01:35:52PM -0700, Nish Aravamudan wrote:
> On 7/18/07, Paul Mundt <lethal@linux-sh.org> wrote:
> >On Wed, Jul 18, 2007 at 12:02:03PM -0400, Lee Schermerhorn wrote:
> >> On Wed, 2007-07-18 at 08:17 -0700, Nish Aravamudan wrote:
> >> > On 7/18/07, Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> >> > > I have always considered the huge page pool, as populated by
> >> > > alloc_fresh_huge_page() in response to changes in nr_hugepages, to 
> >be a
> >> > > system global resource.  I think the system "does the right
> >> > > thing"--well, almost--with Christoph's memoryless patches and your
> >> > > hugetlb patches.  Certaintly, the huge pages allocated at boot time,
> >> > > based on the command line parameter, are system-wide.  cpusets have 
> >not
> >> > > been set up at that time.
> >> >
> >> > I fully agree that hugepages are a global resource.
> >> >
> >> > > It requires privilege to write to the nr_hugepages sysctl, so 
> >allowing
> >> > > it to spread pages across all available nodes [with memory], 
> >regardless
> >> > > of cpusets, makes sense to me.  Altho' I don't expect many folks are
> >> > > currently changing nr_hugepages from within a constrained cpuset, I
> >> > > wouldn't want to see us change existing behavior, in this respect.  
> >Your
> >> > > per node attributes will provide the mechanism to allocate different
> >> > > numbers of hugepages for, e.g., nodes in cpusets that have 
> >applications
> >> > > that need them.
> >> >
> >> > The issue is that with Adam's patches, the hugepage pool will grow on
> >> > demand, presuming the process owner's mlock limit is sufficiently
> >> > high. If said process were running within a constrained cpuset, it
> >> > seems slightly out-of-whack to allow it grow the pool on other nodes
> >> > to satisfy the demand.
> >>
> >> Ah, I see.  In that case, it might make sense to grow just for the
> >> cpuset.  A couple of things come to mind tho':
> >>
> >> 1) we might want a per cpuset control to enable/disable hugetlb pool
> >> growth on demand, or to limit the max size of the pool--especially if
> >> the memories are not exclusively owned by the cpuset.  Otherwise,
> >> non-privileged processes could grow the hugetlb pool in memories shared
> >> with other cpusets [maybe the root cpuset?], thereby reducing the amount
> >> of normal, managed pages available to the other cpusets.  Probably want
> >> such a control in the absense of cpusets as well, if on-demand hugetlb
> >> pool growth is implemented.
> >>
> >I don't see that the two are mutually exclusive. Hugetlb pools have to be
> >node-local anyways due to the varying distances, so perhaps the global
> >resource thing is the wrong way to approach it. There are already hooks
> >for spreading slab and page cache pages in cpusets, perhaps it makes
> >sense to add a hugepage spread variant to balance across the constrained
> >set?
> 
> I'm not sure I understand why you say "hugetlb pools"? There is no
> plural in the kernel, there is only the global pool. Now, on NUMA
> machines, yes, the pool is spread across nodes, but, well, that's just
> because of where the memory is. We already spread out the allocation
> of hugepages across all NUMA nodes (or will, once my patches go in).
> And I think with my earlier suggestion (of just changing the
> interleave mask used for those allocations to be cpuset-aware), that
> we'd spread across the cpuset too, if there is one. Is that what you
> mean by "spread variant"?
> 
Yes, that's what I was referring to. The main thing is that there may
simply be nodes where we don't want to spread the huge pages (mostly due
to size constraints). For instance, nodes that don't make it in to
the interleave map are a reasonable candidate for also never spreading
hugepage pages to.

> >It would be quite nice to have some way to have nodes opt-in to the sort
> >of behaviour they're willing to tolerate. Some nodes are never going to
> >tolerate spreading of any sort, hugepages, and so forth. Perhaps it makes
> >more sense to have some flags in the pgdat where we can more strongly
> >type the sort of behaviour the node is willing to put up with (or capable
> >of supporting), at least in this case the nodes that explicitly can't
> >cope are factored out before we even get to cpuset constraints (plus this
> >gives us a hook for setting up the interleave nodes in both the system
> >init and default policies). Thoughts?
> 
> I guess I don't understand which nodes you're talking about now? How
> do you spread across any particular single node (how I read "Some
> nodes are never going to tolerate spreading of any sort")? Or do you
> mean that some cpusets aren't going to want to spread (interleave?).
> 
> Oh, are you trying to say that some nodes should be dropped from
> interleave masks (explicitly excluded from all possible interleave
> masks)? What kind of nodes would these be? We're doing something
> similar to deal with memoryless nodes, perhaps it could be
> generalized?
> 
Correct. You can see some the changes in mm/mempolicy,c:numa_policy_init() 
for keeping nodes out of the system init policy. While we want to be able
to let the kernel manage the node and let applications do node-local
allocation, this nodes will never want slab pages or anything like that
due to the size constraints.

Christoph had posted some earlier slub patches for excluding certain
nodes from slub entirely, this may also be something you want to pick up
and work on for memoryless nodes. I've been opting for SLOB + NUMA on my
platforms, but if something like this is tidied up generically then slub
is certainly something to support as an alternative.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
