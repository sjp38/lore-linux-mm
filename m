Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A4E726B01EF
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 05:26:25 -0400 (EDT)
Date: Mon, 12 Apr 2010 19:26:15 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100412092615.GY5683@laptop>
References: <4BC0DE84.3090305@redhat.com>
 <20100411104608.GA12828@elte.hu>
 <4BC1B2CA.8050208@redhat.com>
 <20100411120800.GC10952@elte.hu>
 <20100412060931.GP5683@laptop>
 <4BC2BF67.80903@redhat.com>
 <20100412071525.GR5683@laptop>
 <4BC2CF8C.5090108@redhat.com>
 <20100412082844.GU5683@laptop>
 <4BC2E1D6.9040702@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BC2E1D6.9040702@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 12, 2010 at 12:03:18PM +0300, Avi Kivity wrote:
> On 04/12/2010 11:28 AM, Nick Piggin wrote:
> >
> >>We use the "try" tactic extensively.  So long as there's a
> >>reasonable chance of success, and a reasonable fallback on failure,
> >>it's fine.
> >>
> >>Do you think we won't have reasonable success rates?  Why?
> >After the memory is fragmented? It's more or less irriversable. So
> >success rates (to fill a specific number of huges pages) will be fine
> >up to a point. Then it will be a continual failure.
> 
> So we get just a part of the win, not all of it.

It can degrade over time. This is the difference. Two idencial workloads
may have performance X and Y depending on whether uptime is 1 day or 20
days.

 
> >Sure, some workloads simply won't trigger fragmentation problems.
> >Others will.
> 
> Some workloads benefit from readahead.  Some don't.  In fact,
> readahead has a higher potential to reduce performance.
> 
> Same as with many other optimizations.

Do you see any difference with your examples and this issue?

 
> >>Why?  If you can isolate all the pointers into the dentry, allocate
> >>the new dentry, make the old one point into the new one, hash it,
> >>move the pointers, drop the old dentry.
> >>
> >>Difficult, yes, but insane?
> >Yes.
> 
> Well, I'll accept what you say since I'm nowhere near as familiar
> with the code.  But maybe someone insane will come along and do it.

And it'll get nacked :) And it's not only dcache that can cause a
problem. This is part of the whole reason it is insane. It is insane
to only fix the dcache, because if you accept the dcache is a problem
that needs such complexity to fix, then you must accept the same for
the inode caches, the buffer head caches, vmas, radix tree nodes, files
etc. no?

 
> >>Caches have statistical performance.  In the long run they average
> >>out.  In the short run they can behave badly.  Same thing with large
> >>pages, except the runs are longer and the wins are smaller.
> >You don't understand. Caches don't suddenly or slowly stop working.
> >For a particular pattern of workload, they statistically pretty much
> >work the same all the time.
> 
> Yet your effective cache size can be reduced by unhappy aliasing of
> physical pages in your working set.  It's unlikely but it can
> happen.
> 
> For a statistical mix of workloads, huge pages will also work just
> fine.  Perhaps not all of them, but most (those that don't fill
> _all_ of memory with dentries).

Like I said, you don't need to fill all memory with dentries, you
just need to be allocating higher order kernel memory and end up
fragmenting your reclaimable pools.

And it's not a statistical mix that is the problem. The problem is
that the workloads that do cause fragmentation problems will run well
for 1 day or 5 days and then degrade. And it is impossible to know
what will degrade and what won't and by how much.

I'm not saying this is a showstopper, but it does really suck.


> >>Database are the easiest case, they allocate memory up front and
> >>don't give it up.  We'll coalesce their memory immediately and
> >>they'll run happily ever after.
> >Again, you're thinking about a benchmark setup. If you've got various
> >admin things, backups, scripts running, probably web servers,
> >application servers etc. Then it's not all that simple.
> 
> These are all anonymous/pagecache loads, which we deal with well.

Huh? They also involve sockets, files, and involve all of the above
data structures I listed and many more.

 
> >And yes, Linux works pretty well for a multi-workload platform. You
> >might be thinking too much about virtualization where you put things
> >in sterile little boxes and take the performance hit.
> >
> 
> People do it for a reason.

The reasoning is not always sound though. And also people do other
things. Including increasingly better containers and workload
management in the single kernel.

 
> >>Virtualization will fragment on overcommit, but the load is all
> >>anonymous memory, so it's easy to defragment.  Very little dcache on
> >>the host.
> >If virtualization is the main worry (which it seems that it is
> >seeing as your TLB misses cost like 6 times more cachelines),
> 
> (just 2x)
> 
> >then complexity should be pushed into the hypervisor, not the
> >core kernel.
> 
> The whole point behind kvm is to reuse the Linux core.  If we have
> to reimplement Linux memory management and scheduling, then it's a
> failure.

And if you need to add complexity to the Linux core for it, it's
also a failure.

I'm not saying to reimplement things, but if you had a little bit
more support perhaps. Anyway it's just ideas, I'm not saying that
transparent hugepages is wrong simply because KVM is a big user and it
could be implemented in another way.

But if it is possible for KVM to use libhugetlb with just a bit of
support from the kernel, then it goes some way to reducing the
need for transparent hugepages.

 
> >>Well, I'm not against it, but that would be a much more intrusive
> >>change than what this thread is about.  Also, you'd need 4K dentries
> >>etc, no?
> >No. You'd just be defragmenting 4K worth of dentries at a time.
> >Dentries (and anything that doesn't care about untranslated KVA)
> >are trivial. Zero change for users of the code.
> 
> I see.
> 
> >This is going off-topic though, I don't want to hijack the thread
> >with talk of nonlinear kernel.
> 
> Too bad, it's interesting.

It sure is, we can start another thread.

 
> >>Mostly we need a way of identifying pointers into a data structure,
> >>like rmap (after all that's what makes transparent hugepages work).
> >And that involves auditing and rewriting anything that allocates
> >and pins kernel memory. It's not only dentries.
> 
> Not everything, just the major users that can scale with the amount
> of memory in the machine.

Well you need to audit, to determine if it is going to be a problem or
not, and it is more than only dentries. (but even dentries would be a
nightmare considering how widely they're used and how much they're
passed around the vfs and filesystems).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
