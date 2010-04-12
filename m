Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9596C6B01EF
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 06:37:12 -0400 (EDT)
Date: Mon, 12 Apr 2010 20:37:01 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100412103701.GZ5683@laptop>
References: <4BC1B2CA.8050208@redhat.com>
 <20100411120800.GC10952@elte.hu>
 <20100412060931.GP5683@laptop>
 <4BC2BF67.80903@redhat.com>
 <20100412071525.GR5683@laptop>
 <4BC2CF8C.5090108@redhat.com>
 <20100412082844.GU5683@laptop>
 <4BC2E1D6.9040702@redhat.com>
 <20100412092615.GY5683@laptop>
 <4BC2EFBA.5080404@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BC2EFBA.5080404@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 12, 2010 at 01:02:34PM +0300, Avi Kivity wrote:
> On 04/12/2010 12:26 PM, Nick Piggin wrote:
> >On Mon, Apr 12, 2010 at 12:03:18PM +0300, Avi Kivity wrote:
> >>On 04/12/2010 11:28 AM, Nick Piggin wrote:
> >>>>We use the "try" tactic extensively.  So long as there's a
> >>>>reasonable chance of success, and a reasonable fallback on failure,
> >>>>it's fine.
> >>>>
> >>>>Do you think we won't have reasonable success rates?  Why?
> >>>After the memory is fragmented? It's more or less irriversable. So
> >>>success rates (to fill a specific number of huges pages) will be fine
> >>>up to a point. Then it will be a continual failure.
> >>So we get just a part of the win, not all of it.
> >It can degrade over time. This is the difference. Two idencial workloads
> >may have performance X and Y depending on whether uptime is 1 day or 20
> >days.
> 
> I don't see why it will degrade.  Antifrag will prefer to allocate
> dcache near existing dcache.
> 
> The only scenario I can see where it degrades is that you have a
> dcache load that spills over to all of memory, then falls back
> leaving a pinned page in every huge frame.  It can happen, but I
> don't see it as a likely scenario.  But maybe I'm missing something.

No, it doesn't need to make all hugepages unavailable in order to
start degrading. The moment that fewer huge pages are available than
can be used, due to fragmentation, is when you could start seeing
fragmentation.

If you're using higher order allocations in the kernel, like SLUB
will especially (and SLAB will for some things) then the requirement
for fragmentation basically gets smaller by I think about the same
factor as the page size. So order-2 slabs only need to fill 1/4 of
memory in order to be able to fragment entire memory. But fragmenting
entire memory is not the start of the degredation, it is the end.

 
> >>>Sure, some workloads simply won't trigger fragmentation problems.
> >>>Others will.
> >>Some workloads benefit from readahead.  Some don't.  In fact,
> >>readahead has a higher potential to reduce performance.
> >>
> >>Same as with many other optimizations.
> >Do you see any difference with your examples and this issue?
> 
> Memory layout is more persistent.  Well, disk layout is even more
> persistent.  Still we do extents, and if our disk is fragmented, we
> take the hit.

Sure, and that's not a good thing either.

 
> >>Well, I'll accept what you say since I'm nowhere near as familiar
> >>with the code.  But maybe someone insane will come along and do it.
> >And it'll get nacked :) And it's not only dcache that can cause a
> >problem. This is part of the whole reason it is insane. It is insane
> >to only fix the dcache, because if you accept the dcache is a problem
> >that needs such complexity to fix, then you must accept the same for
> >the inode caches, the buffer head caches, vmas, radix tree nodes, files
> >etc. no?
> 
> inodes come with dcache, yes.  I thought buffer heads are now a much
> smaller load.  vmas usually don't scale up with memory.  If you have
> a lot of radix tree nodes, then you also have a lot of pagecache, so
> the radix tree nodes can be contained.  Open files also don't scale
> with memory.

See above; we don't need to fill all memory, especially with higher
order allocations.

Definitely some workloads that never use much kernel memory will
probably not see fragmentation problems.

 
> >>Yet your effective cache size can be reduced by unhappy aliasing of
> >>physical pages in your working set.  It's unlikely but it can
> >>happen.
> >>
> >>For a statistical mix of workloads, huge pages will also work just
> >>fine.  Perhaps not all of them, but most (those that don't fill
> >>_all_ of memory with dentries).
> >Like I said, you don't need to fill all memory with dentries, you
> >just need to be allocating higher order kernel memory and end up
> >fragmenting your reclaimable pools.
> 
> Allocate those higher order pages from the same huge frame.

We don't keep different pools of different frame sizes around
to allocate different object sizes in. That would get even weirder
than the existing anti-frag stuff with overflow and fallback rules.

 
> >And it's not a statistical mix that is the problem. The problem is
> >that the workloads that do cause fragmentation problems will run well
> >for 1 day or 5 days and then degrade. And it is impossible to know
> >what will degrade and what won't and by how much.
> >
> >I'm not saying this is a showstopper, but it does really suck.
> >
> 
> Can you suggest a real life test workload so we can investigate it?
> 
> >>These are all anonymous/pagecache loads, which we deal with well.
> >Huh? They also involve sockets, files, and involve all of the above
> >data structures I listed and many more.
> 
> A few thousand sockets and open files is chickenfeed for a server.
> They'll kill a few huge frames but won't significantly affect the
> rest of memory.

Lots of small files is very common for a web server for example.


> >>>And yes, Linux works pretty well for a multi-workload platform. You
> >>>might be thinking too much about virtualization where you put things
> >>>in sterile little boxes and take the performance hit.
> >>>
> >>People do it for a reason.
> >The reasoning is not always sound though. And also people do other
> >things. Including increasingly better containers and workload
> >management in the single kernel.
> 
> Containers are wonderful but still a future thing, and even when
> fully implemented they still don't offer the same isolation as
> virtualization.  For example, the owner of workload A might want to
> upgrade the kernel to fix a bug he's hitting, while the owner of
> workload B needs three months to test it.

But better for performance in general.

 
> >>The whole point behind kvm is to reuse the Linux core.  If we have
> >>to reimplement Linux memory management and scheduling, then it's a
> >>failure.
> >And if you need to add complexity to the Linux core for it, it's
> >also a failure.
> 
> Well, we need to add complexity, and we already have.  If the
> acceptance criteria for a feature would be 'no new complexity', then
> the kernel would be a lot smaller than it is now.
> 
> Everything has to be evaluated on the basis of its generality, the
> benefit, the importance of the subsystem that needs it, and impact
> on the code.  Huge pages are already used in server loads so they're
> not specific to kvm.  The benefit, 5-15%, is significant.  You and
> Linus might not be interested in virtualization, but a significant
> and growing fraction of hosts are virtualized, it's up to us if they
> run Linux or something else.  And I trust Andrea and the reviewers
> here to keep the code impact sane.

I'm being realistic. I know sure it is just to be evaluated based
on gains, complexity, alternatives, etc.

When I hear arguments like we must do this because memory to cache
ratio has got 100 times worse and ergo we're on the brink of
catastrophe, that's when things get silly.


> >I'm not saying to reimplement things, but if you had a little bit
> >more support perhaps. Anyway it's just ideas, I'm not saying that
> >transparent hugepages is wrong simply because KVM is a big user and it
> >could be implemented in another way.
> 
> What do you mean by 'more support'?
> 
> >But if it is possible for KVM to use libhugetlb with just a bit of
> >support from the kernel, then it goes some way to reducing the
> >need for transparent hugepages.
> 
> kvm already works with hugetlbfs.  But it's brittle, it means we
> have to choose between performance and overcommit.

Overcommit because it doesn't work with swapping? Or something more?


> >>Not everything, just the major users that can scale with the amount
> >>of memory in the machine.
> >Well you need to audit, to determine if it is going to be a problem or
> >not, and it is more than only dentries. (but even dentries would be a
> >nightmare considering how widely they're used and how much they're
> >passed around the vfs and filesystems).
> 
> pages are passed around everywhere as well.  When something is
> locked or its reference count doesn't match the reachable pointer
> count, you give up.  Only a small number of objects are in active
> use at any one time.

Easier said than done, I suspect.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
