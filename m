Received: by ug-out-1314.google.com with SMTP id s2so341092uge
        for <linux-mm@kvack.org>; Wed, 09 May 2007 12:59:29 -0700 (PDT)
Message-ID: <29495f1d0705091259t2532358ana4defb7c4e2a7560@mail.gmail.com>
Date: Wed, 9 May 2007 12:59:29 -0700
From: "Nish Aravamudan" <nish.aravamudan@gmail.com>
Subject: Re: [PATCH] Fix hugetlb pool allocation with empty nodes - V2 -> V3
In-Reply-To: <1178728661.5047.64.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070503022107.GA13592@kryten>
	 <1178310543.5236.43.camel@localhost>
	 <Pine.LNX.4.64.0705041425450.25764@schroedinger.engr.sgi.com>
	 <1178728661.5047.64.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, Anton Blanchard <anton@samba.org>, linux-mm@kvack.org, ak@suse.de, mel@csn.ul.ie, apw@shadowen.org, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

[Adding wli to the Cc]

On 5/9/07, Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> On Fri, 2007-05-04 at 14:27 -0700, Christoph Lameter wrote:
> > On Fri, 4 May 2007, Lee Schermerhorn wrote:
> >
> > > On Wed, 2007-05-02 at 21:21 -0500, Anton Blanchard wrote:
> > > > An interesting bug was pointed out to me where we failed to allocate
> > > > hugepages evenly. In the example below node 7 has no memory (it only has
> > > > CPUs). Node 0 and 1 have plenty of free memory. After doing:
> > >
> > > Here's my attempt to fix the problem [I see it on HP platforms as well],
> > > without removing the population check in build_zonelists_node().  Seems
> > > to work.
> >
> > I think we need something like for_each_online_node for each node with
> > memory otherwise we are going to replicate this all over the place for
> > memoryless nodes. Add a nodemap for populated nodes?
> >
> > I.e.
> >
> > for_each_mem_node?
> >
> > Then you do not have to check the zone flags all the time. May avoid a lot
> > of mess?
>
> OK, here's a rework that exports a node_populated_map and associated
> access functions from page_alloc.c where we already check for populated
> zones.  Maybe this should be "node_hugepages_map" ?
>
> Also, we might consider exporting this to user space for applications
> that want to "interleave across all nodes with hugepages"--not that
> hugetlbfs mappings currently obey "vma policy".  Could still be used
> with the "set task policy before allocating region" method [not that I
> advocate this method ;-)].

For libhugetlbfs purposes, with 1.1 and later, we've recommended folks
use numactl in coordination with the library to specify the policy.
After a kernel fix that submitted a while back (and has been merged
for at least a few releases), hugepages interleave properly when
requested.

> I don't think that a 'for_each_*_node()' macro is appropriate for this
> usage, as allocate_fresh_huge_page() is an "incremental allocator" that
> returns a page from the "next eligible node" on each call.
>
> By the way:  does anything protect the "static int nid" in
> allocate_fresh_huge_page() from racing attempts to set nr_hugepages?
> Can this happen?  Do we care?

Hrm, not sure if we care or not.

We've got a draft of patch that exports nr_hugepages on a per-node
basis in sysfs. Will post it soon, as an additional, more flexible
interface for dealing with hugepages on NUMA.

<snip>

> -       page = alloc_pages_node(nid, htlb_alloc_mask|__GFP_COMP|__GFP_NOWARN,
> -                                       HUGETLB_PAGE_ORDER);

<snip>

> +                       page = alloc_pages_node(nid,
> +                                       GFP_HIGHUSER|__GFP_COMP|GFP_THISNODE,
> +                                       HUGETLB_PAGE_ORDER);

Are we taking out the GFP_NOWARN for a reason? I noticed this in
Anton's patch, but forgot to ask.

<snip>

> Index: Linux/include/linux/nodemask.h

<snip>

> + * node_set_poplated(node)             set bit 'node' in node_populated_map
> + * node_not_poplated(node)             clear bit 'node' in node_populated_map

typos? (poplated v. populated)

<snip>

Looks reasonable otherwise.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
