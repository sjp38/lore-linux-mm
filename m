Date: Thu, 19 Jul 2007 10:52:31 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH 5/5] [hugetlb] Try to grow pool for MAP_SHARED mappings
Message-ID: <20070719015231.GA16796@linux-sh.org>
References: <20070713151621.17750.58171.stgit@kernel> <20070713151717.17750.44865.stgit@kernel> <20070713130508.6f5b9bbb.pj@sgi.com> <1184360742.16671.55.camel@localhost.localdomain> <20070713143838.02c3fa95.pj@sgi.com> <29495f1d0707171642t7c1a26d7l1c36a896e1ba3b47@mail.gmail.com> <1184769889.5899.16.camel@localhost> <29495f1d0707180817n7a5709dcr78b641a02cb18057@mail.gmail.com> <1184774524.5899.49.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1184774524.5899.49.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Nish Aravamudan <nish.aravamudan@gmail.com>, Paul Jackson <pj@sgi.com>, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org, mel@skynet.ie, apw@shadowen.org, wli@holomorphy.com, clameter@sgi.com, kenchen@google.com
List-ID: <linux-mm.kvack.org>

On Wed, Jul 18, 2007 at 12:02:03PM -0400, Lee Schermerhorn wrote:
> On Wed, 2007-07-18 at 08:17 -0700, Nish Aravamudan wrote:
> > On 7/18/07, Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> > > I have always considered the huge page pool, as populated by
> > > alloc_fresh_huge_page() in response to changes in nr_hugepages, to be a
> > > system global resource.  I think the system "does the right
> > > thing"--well, almost--with Christoph's memoryless patches and your
> > > hugetlb patches.  Certaintly, the huge pages allocated at boot time,
> > > based on the command line parameter, are system-wide.  cpusets have not
> > > been set up at that time.
> > 
> > I fully agree that hugepages are a global resource.
> > 
> > > It requires privilege to write to the nr_hugepages sysctl, so allowing
> > > it to spread pages across all available nodes [with memory], regardless
> > > of cpusets, makes sense to me.  Altho' I don't expect many folks are
> > > currently changing nr_hugepages from within a constrained cpuset, I
> > > wouldn't want to see us change existing behavior, in this respect.  Your
> > > per node attributes will provide the mechanism to allocate different
> > > numbers of hugepages for, e.g., nodes in cpusets that have applications
> > > that need them.
> > 
> > The issue is that with Adam's patches, the hugepage pool will grow on
> > demand, presuming the process owner's mlock limit is sufficiently
> > high. If said process were running within a constrained cpuset, it
> > seems slightly out-of-whack to allow it grow the pool on other nodes
> > to satisfy the demand.
> 
> Ah, I see.  In that case, it might make sense to grow just for the
> cpuset.  A couple of things come to mind tho':
> 
> 1) we might want a per cpuset control to enable/disable hugetlb pool
> growth on demand, or to limit the max size of the pool--especially if
> the memories are not exclusively owned by the cpuset.  Otherwise,
> non-privileged processes could grow the hugetlb pool in memories shared
> with other cpusets [maybe the root cpuset?], thereby reducing the amount
> of normal, managed pages available to the other cpusets.  Probably want
> such a control in the absense of cpusets as well, if on-demand hugetlb
> pool growth is implemented.  
> 
I don't see that the two are mutually exclusive. Hugetlb pools have to be
node-local anyways due to the varying distances, so perhaps the global
resource thing is the wrong way to approach it. There are already hooks
for spreading slab and page cache pages in cpusets, perhaps it makes
sense to add a hugepage spread variant to balance across the constrained
set?

nr_hugepages is likely something that should still be global, so the
sum of the hugepages in the per-node pools don't exceed this value.

It would be quite nice to have some way to have nodes opt-in to the sort
of behaviour they're willing to tolerate. Some nodes are never going to
tolerate spreading of any sort, hugepages, and so forth. Perhaps it makes
more sense to have some flags in the pgdat where we can more strongly
type the sort of behaviour the node is willing to put up with (or capable
of supporting), at least in this case the nodes that explicitly can't
cope are factored out before we even get to cpuset constraints (plus this
gives us a hook for setting up the interleave nodes in both the system
init and default policies). Thoughts?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
