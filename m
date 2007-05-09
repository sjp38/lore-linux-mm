Received: by ug-out-1314.google.com with SMTP id s2so364898uge
        for <linux-mm@kvack.org>; Wed, 09 May 2007 15:34:13 -0700 (PDT)
Message-ID: <29495f1d0705091534x51a9a0e9me304a880f75ab557@mail.gmail.com>
Date: Wed, 9 May 2007 15:34:10 -0700
From: "Nish Aravamudan" <nish.aravamudan@gmail.com>
Subject: Re: [PATCH] Fix hugetlb pool allocation with empty nodes - V2 -> V3
In-Reply-To: <1178743039.5047.85.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070503022107.GA13592@kryten>
	 <1178310543.5236.43.camel@localhost>
	 <Pine.LNX.4.64.0705041425450.25764@schroedinger.engr.sgi.com>
	 <1178728661.5047.64.camel@localhost>
	 <29495f1d0705091259t2532358ana4defb7c4e2a7560@mail.gmail.com>
	 <1178743039.5047.85.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, Anton Blanchard <anton@samba.org>, linux-mm@kvack.org, ak@suse.de, mel@csn.ul.ie, apw@shadowen.org, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

On 5/9/07, Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> On Wed, 2007-05-09 at 12:59 -0700, Nish Aravamudan wrote:
> > [Adding wli to the Cc]
> >
> > On 5/9/07, Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> > > On Fri, 2007-05-04 at 14:27 -0700, Christoph Lameter wrote:
> > > > On Fri, 4 May 2007, Lee Schermerhorn wrote:
> > > >
> > > > > On Wed, 2007-05-02 at 21:21 -0500, Anton Blanchard wrote:
> > > > > > An interesting bug was pointed out to me where we failed to allocate
> > > > > > hugepages evenly. In the example below node 7 has no memory (it only has
> > > > > > CPUs). Node 0 and 1 have plenty of free memory. After doing:
>
> <snip>
>
> > >
> > > OK, here's a rework that exports a node_populated_map and associated
> > > access functions from page_alloc.c where we already check for populated
> > > zones.  Maybe this should be "node_hugepages_map" ?
> > >
> > > Also, we might consider exporting this to user space for applications
> > > that want to "interleave across all nodes with hugepages"--not that
> > > hugetlbfs mappings currently obey "vma policy".  Could still be used
> > > with the "set task policy before allocating region" method [not that I
> > > advocate this method ;-)].

Hrm, I forgot to reply to that bit before. I think hugetlbfs mappings
will obey at least the interleave policy, per:

struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr)
{
        struct mempolicy *pol = get_vma_policy(current, vma, addr);

        if (pol->policy == MPOL_INTERLEAVE) {
                unsigned nid;

                nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);
                return NODE_DATA(nid)->node_zonelists + gfp_zone(GFP_HIGHUSER);
        }
        return zonelist_policy(GFP_HIGHUSER, pol);
}

> > For libhugetlbfs purposes, with 1.1 and later, we've recommended folks
> > use numactl in coordination with the library to specify the policy.
> > After a kernel fix that submitted a while back (and has been merged
> > for at least a few releases), hugepages interleave properly when
> > requested.
>
> You mean using numactl command to preposition a hugetlb shmem seg
> external to the application?  That's one way to do it.  Some apps like
> to handle this internally themselves.

Hrm, well, libhugetlbfs does not do anything with shmem segs -- I was
referring to use numactl to set the policy for hugepages which then
our malloc implementation takes advantage of. Hugepages show up
interleaved across the nodes. This was what required a simple
mempolicy fix last August (3b98b087fc2daab67518d2baa8aef19a6ad82723)

> > > By the way:  does anything protect the "static int nid" in
> > > allocate_fresh_huge_page() from racing attempts to set nr_hugepages?
> > > Can this happen?  Do we care?
> >
> > Hrm, not sure if we care or not.
>
> Shouldn't happen too often, I think.  And the only result should be some
> additional imbalance that this patch is trying to address.  Still, I
> don't know that it's worth another lock.  And, I don't think we want to
> hold the hugetlb_lock over the page allocation.  However, with a slight
> reordering of the code, with maybe an additional temporary nid variable,
> we could grab the hugetlb lock while updating the static nid each time
> around the loop.  I don't see this as a performance path, but again, is
> it worth it?

I would say it's not, but will defer to wli et al.

> > We've got a draft of patch that exports nr_hugepages on a per-node
> > basis in sysfs. Will post it soon, as an additional, more flexible
> > interface for dealing with hugepages on NUMA.
>
> You mean the ability to specify explicitly the number of hugepages per
> node?

Yep, seems like a handy feature.

> > <snip>
> >
> > > -       page = alloc_pages_node(nid, htlb_alloc_mask|__GFP_COMP|__GFP_NOWARN,
> > > -                                       HUGETLB_PAGE_ORDER);
> >
> > <snip>
> >
> > > +                       page = alloc_pages_node(nid,
> > > +                                       GFP_HIGHUSER|__GFP_COMP|GFP_THISNODE,
> > > +                                       HUGETLB_PAGE_ORDER);
> >
> > Are we taking out the GFP_NOWARN for a reason? I noticed this in
> > Anton's patch, but forgot to ask.
>
> Actually, I hadn't noticed, but a quick look shows that GFP_THISNODE
> contains the __GFP_NOWARN flag, as well as '_NORETRY which I think is
> OK/desirable.

Good call, sorry for the noise. This makes sense (along with Christoph's reply).

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
