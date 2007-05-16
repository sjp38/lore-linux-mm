Received: by ug-out-1314.google.com with SMTP id s2so183106uge
        for <linux-mm@kvack.org>; Wed, 16 May 2007 16:47:05 -0700 (PDT)
Message-ID: <29495f1d0705161647k5524a566y36e36e65d2ec8666@mail.gmail.com>
Date: Wed, 16 May 2007 16:47:05 -0700
From: "Nish Aravamudan" <nish.aravamudan@gmail.com>
Subject: Re: [PATCH] Fix hugetlb pool allocation with empty nodes - V2 -> V3
In-Reply-To: <1179246644.5323.39.camel@localhost>
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
	 <29495f1d0705091534x51a9a0e9me304a880f75ab557@mail.gmail.com>
	 <1179246644.5323.39.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, Anton Blanchard <anton@samba.org>, linux-mm@kvack.org, ak@suse.de, mel@csn.ul.ie, apw@shadowen.org, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

On 5/15/07, Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> On Wed, 2007-05-09 at 15:34 -0700, Nish Aravamudan wrote:
> > On 5/9/07, Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> > > On Wed, 2007-05-09 at 12:59 -0700, Nish Aravamudan wrote:
> > > > [Adding wli to the Cc]
>
> <snip>
>
> > > > >
> > > > > OK, here's a rework that exports a node_populated_map and associated
> > > > > access functions from page_alloc.c where we already check for populated
> > > > > zones.  Maybe this should be "node_hugepages_map" ?
> > > > >
> > > > > Also, we might consider exporting this to user space for applications
> > > > > that want to "interleave across all nodes with hugepages"--not that
> > > > > hugetlbfs mappings currently obey "vma policy".  Could still be used
> > > > > with the "set task policy before allocating region" method [not that I
> > > > > advocate this method ;-)].
> >
> > Hrm, I forgot to reply to that bit before. I think hugetlbfs mappings
> > will obey at least the interleave policy, per:
> >
> > struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr)
> > {
> >         struct mempolicy *pol = get_vma_policy(current, vma, addr);
> >
> >         if (pol->policy == MPOL_INTERLEAVE) {
> >                 unsigned nid;
> >
> >                 nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);
> >                 return NODE_DATA(nid)->node_zonelists + gfp_zone(GFP_HIGHUSER);
> >         }
> >         return zonelist_policy(GFP_HIGHUSER, pol);
> > }
>
>
> I should have been more specific.  I've only used hugetlbfs with shmem
> segments.  I haven't tried libhugetlbfs [does it work on ia64, yet?].
> Huge page shmem segments don't set/get the shared policy on the shared
> object itself.  Rather they use the task private vma_policy.

Ah ok. FWIW, libhugetlbfs does have pseudo-support for IA64. At least,
we build and can run the gerernal functionality tests (those that make
sense on IA64). We avoid tests that specify MAP_FIXED, for instance.
We don't currently have plans to support segment remapping on IA64,
because it's a bit tougher than on other architectures due hugepage
location restrictions. Hugepage malloc should work, though. And since
we only use mlock() in the malloc code, that's where you'd want to use
numactl anyways to specify the right policy.

> Huge tlb shared segments would obey shared policy if the hugetlb_vm_ops
> were hooked up to the shared policy mechanism, but they are not.  So,
> there is no way to set the shared policy on such segments.  I tried a
> simple patch to add the shmem_{get|set}_policy() functions to the
> hugetlb_vm_ops, and this almost works.  However, a cat
> of /proc/<pid>/numa_maps hangs.  Haven't investigated the hang, yet.

<snip>

Interesting -- I'll see if I can take a look at this sometime soon. Do
you have a version (working or not) of your patch that you'd be
willing to share?

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
