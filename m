Subject: Re: [PATCH] Fix hugetlb pool allocation with empty nodes - V2 -> V3
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <29495f1d0705091534x51a9a0e9me304a880f75ab557@mail.gmail.com>
References: <20070503022107.GA13592@kryten>
	 <1178310543.5236.43.camel@localhost>
	 <Pine.LNX.4.64.0705041425450.25764@schroedinger.engr.sgi.com>
	 <1178728661.5047.64.camel@localhost>
	 <29495f1d0705091259t2532358ana4defb7c4e2a7560@mail.gmail.com>
	 <1178743039.5047.85.camel@localhost>
	 <29495f1d0705091534x51a9a0e9me304a880f75ab557@mail.gmail.com>
Content-Type: text/plain
Date: Tue, 15 May 2007 12:30:44 -0400
Message-Id: <1179246644.5323.39.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nish Aravamudan <nish.aravamudan@gmail.com>
Cc: Christoph Lameter <clameter@sgi.com>, Anton Blanchard <anton@samba.org>, linux-mm@kvack.org, ak@suse.de, mel@csn.ul.ie, apw@shadowen.org, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-05-09 at 15:34 -0700, Nish Aravamudan wrote: 
> On 5/9/07, Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> > On Wed, 2007-05-09 at 12:59 -0700, Nish Aravamudan wrote:
> > > [Adding wli to the Cc]

<snip>

> > > >
> > > > OK, here's a rework that exports a node_populated_map and associated
> > > > access functions from page_alloc.c where we already check for populated
> > > > zones.  Maybe this should be "node_hugepages_map" ?
> > > >
> > > > Also, we might consider exporting this to user space for applications
> > > > that want to "interleave across all nodes with hugepages"--not that
> > > > hugetlbfs mappings currently obey "vma policy".  Could still be used
> > > > with the "set task policy before allocating region" method [not that I
> > > > advocate this method ;-)].
> 
> Hrm, I forgot to reply to that bit before. I think hugetlbfs mappings
> will obey at least the interleave policy, per:
> 
> struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr)
> {
>         struct mempolicy *pol = get_vma_policy(current, vma, addr);
> 
>         if (pol->policy == MPOL_INTERLEAVE) {
>                 unsigned nid;
> 
>                 nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);
>                 return NODE_DATA(nid)->node_zonelists + gfp_zone(GFP_HIGHUSER);
>         }
>         return zonelist_policy(GFP_HIGHUSER, pol);
> }


I should have been more specific.  I've only used hugetlbfs with shmem
segments.  I haven't tried libhugetlbfs [does it work on ia64, yet?].
Huge page shmem segments don't set/get the shared policy on the shared
object itself.  Rather they use the task private vma_policy.

Huge tlb shared segments would obey shared policy if the hugetlb_vm_ops
were hooked up to the shared policy mechanism, but they are not.  So,
there is no way to set the shared policy on such segments.  I tried a
simple patch to add the shmem_{get|set}_policy() functions to the
hugetlb_vm_ops, and this almost works.  However, a cat
of /proc/<pid>/numa_maps hangs.  Haven't investigated the hang, yet.

Anyway, here's the scenario to illustrate the "failure"--e.g., on
2.6.22-rc1:

from one task, create a huge page shmem segment:  shmget with
SHM_HUGETLB

map it [shmat] 

Now, either fork a child process or attach the shmem segment from
another task.

>From one task, mbind the segment with, say, interleave policy, but don't
touch it to fault in pages yet.  [If you use a separate task, rather
than a child of the first task, you can do the mbind before the attach.
However, a child will inherit the address space of the parent, so any
mbind before a fork will be inherited by the child.  A workaround, at
least.]

Touch the addresses from the child/other task to fault in the pages.
Unlike normal, non-huge, shmem segments, the huge pages faulted in by a
task which did not set/inherit the policy will not obey the policy.

Here's an "memtoy" script that will do this.  Requires at least
memtoy-0.11a/b [see http://free.linux.hp.com/~lts/Tools].  Assumes at
least 4G worth of huge pages distributed across 4 nodes.  Adjust script
according to your config.

shmem foo 4g huge
map foo
child x
mbind foo interleave 0,1,2,3
# touch foo from the child 'x'
/x touch foo
# what does parent see?
where foo
# what does child see?
/x where foo

run this script using:  'memtoy -v <path-to-script>'

> 
> > > For libhugetlbfs purposes, with 1.1 and later, we've recommended folks
> > > use numactl in coordination with the library to specify the policy.
> > > After a kernel fix that submitted a while back (and has been merged
> > > for at least a few releases), hugepages interleave properly when
> > > requested.
> >
> > You mean using numactl command to preposition a hugetlb shmem seg
> > external to the application?  That's one way to do it.  Some apps like
> > to handle this internally themselves.
> 
> Hrm, well, libhugetlbfs does not do anything with shmem segs -- I was
> referring to use numactl to set the policy for hugepages which then
> our malloc implementation takes advantage of. Hugepages show up
> interleaved across the nodes. This was what required a simple
> mempolicy fix last August (3b98b087fc2daab67518d2baa8aef19a6ad82723)
> 

Yep.  Saw that one go by.  Interleaving DOES work for hugetlb shmem
segments if, e.g., in the script above, you touch the segment from the
parent where the mbind was done, or if you do the mbind before forking
the child.

Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
