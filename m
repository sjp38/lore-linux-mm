Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 25D206B004A
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 09:04:44 -0400 (EDT)
Date: Mon, 19 Mar 2012 14:04:01 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][PATCH 00/26] sched/numa
Message-ID: <20120319130401.GI24602@redhat.com>
References: <20120316144028.036474157@chello.nl>
 <4F670325.7080700@redhat.com>
 <1332155527.18960.292.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1332155527.18960.292.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Avi Kivity <avi@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 19, 2012 at 12:12:07PM +0100, Peter Zijlstra wrote:
> As to page table scanners, I simply don't see the point. They tend to
> require arch support (I see aa introduces yet another PTE bit -- this
> instantly limits the usefulness of the approach as lots of archs don't
> have spare bits).

Note that for most archs supporting NUMA the pmd/pte is a pure
software representation that the hardware won't ever be able to read,
x86 is almost the exception here.

But the numa pte/pmd bit works identical to PROT_NONE so you're wrong
and it doesn't need a spare bit from the hardware. It's not the same
as PTE_SPECIAL or something the hardware has to be aware about that is
reserved for software use.

This is a bit that is reused from the swap_entry, it is some bit that
become meaningful only when the PRESENT bit is _not_ set, so it only
needs to steal a bit from the swap_entry representation worst
case. It's not a bit required to the hardware, it's a bit I steal from
Linux. On x86 I was careful enough to stole it from an intermediate
place that wasn't used anyway, so I didn't have to alter the
swap_entry representation. I exclude there can be an issue in any
other arch in supporting AutoNUMA in fact it'll be trivial to add and
it shouldn't require almost any arch change except for definiting that
bit (and worst case adjusting the swap_entry representation).

About the cost of the actual pagetable scanner, you're not being
rational about it. You should measure it for once, take khugepaged
make it scan 1G of memory per millisecond and measure the cost.

It is practically zero. The only cost measurable is the cost of the
numa hinting page fault, that concerns me too in virt environment
because of the vmexit cost, but on host even those are quite
insignificant and unmeasurable.

You keep complaining about the unaccountability of the pagetable
scanners in terms of process load, and that's a red herring as far as
I can tell. The irqs and ksoftirqd load in a busy server, is likely
much higher than whatever happens at the pagetable scanner level (sure
thing for khugepaged and by an huge order of magnitude so). I don't
think this is a relevant concern anyway because the pagetable scanners
go over all memory in a equal amount so the cost would be evenly
distributed for all processes over time (the same cannot be said about
the irqs and ksoftrqid that will benefit only a few processes doing
I/O).

That it isn't a real time feature it's obvious, but then on real time
you should use numactl hard binds and never migrate memory in the
first place.

> Also, if you go scan memory, you need some storage -- see how aa grows
> struct page, sure he wants to move that storage some place else, but the

The struct page I didn't clean it up yet (if anyone is interested
patches welcome btw), it'll only be allocated if the system boots on
NUMA hardware and it'll be allocated in the pgdat like in memcg. I
forgot to mention this.

I already cleaned up the mm_struct and task_struct at
least... initially they were also hardcoded inside and not only
allocated if booted on NUMA hardware.

If you boot with memcg compiled in, that's taking an equivalent amount
of memory per-page.

If you can bear the memory loss when memcg is compiled in even when
not enabled, you sure can bear it on NUMA systems that have lots of
memory, so it's perfectly ok to sacrifice a bit of it so that it
performs like not-NUMA but you still have more memory than not-NUMA.

Like for memcg if you'll boot with noautonuma no memory will be
allocated at all and it'll shut itself off without giving a way to
enable it at runtime (for memcg the equivalent would be
cgroup_disable=memory and I'm not sure how many are running that
command to save precious memory allocated at boot for every page on
systems not using memcg at runtime...).

> Also, the only really 'hard' case for the whole auto-numa business is
> single processes that are bigger than a single node -- and those I pose
> are 'rare'.

I don't get what "hard" case means here.

Anyway AutoNUMA handles optimally a ton of processes that are smaller
than one node too. But it handles those that are bigger and spans over
multiple as well without having to modify the application or use soft
binding wrappers.

If you think your home node can do better than AutoNUMA when the
process is smaller than one node, benchmark it and report... I'd be
shocked if the home node can do better than AutoNUMA on any workload
involving processes smaller than one node.

It's actually the numa01 testcase that tests this very case (with
-DTHREAD_ALLOC uses local memory for each thread that fits in the
node, without it forces all thread to share all memory). Feel free to
try.

numa02 tests the case of one process spanning over the whole system
with as thread as physical CPUs (each thread uses local memory or
AutoNUMA should layout the equivalent of MADV_INTERLEAVE there, and
it's not capable of such a thing yet, maybe later).

> Now if you want to be able to scan per-thread, you need per-thread
> page-tables and I really don't want to ever see that. That will blow
> memory overhead and context switch times.

I collect per-thread stats and mm wide stats, but I don't have
per-thread pagetables. That makes it harder to detect the sharing
among different threads as the only disavantage compared to a
per-thread pagetables but like you said it has fewer cons than
per-thread pagetables.

> I guess you can limit the impact by only running the scanners on
> selected processes, but that requires you add interfaces and then either
> rely on admins or userspace to second guess application developers.

No need so far. Besides the processes that aren't running won't run
numa hinting page faults and the scanner cost is not a concern (only
the numa hinting faults are).

You keep worrying about the pagetable scanners, and you don't mention
the numa hinting faults maybe because the numa hinting faults will be
accounted perfectly by the scheduler. But really they're the only
concern here (the pagetable scanner is not and has never been).

> So no, I don't like that at all.
> 
> I'm still reading aa's patch, I haven't actually found anything I like
> or agree with in there, but who knows, there's still some way to go.

If it'll be proven AutoNUMA with automatic collection of all stats,
was a bad idea I can change my mind too no problem. For now I'm
grateful I was given the opportunity to allow my idea to materialize
despite your harsh criticism, until it converged in something that I'm
fully satisfied with in terms of the core algorithms that compute the
data and reacts to it (even if some cleanup is still missing, struct
page etc.. :).

If AutoNUMA is such a bad thing that you can't find anything you like
or agree with, it shall be easy to beat in the numbers especially when
you use syscalls to hint the kernel. So please go ahead and post the
numbers where you beat AutoNUMA.

If I would require the apps to be modified and stop the numa hinting
page faults, then I could probably gain something too. But I believe
we'll be better off with the kernel not requiring the apps the be
modified even if it costs some insignificant CPU.

I believe you're massively underestimating how hard it is for people
to modify the apps or to use wrappers or anything that isn't the
default. I don't care about niche here. For the niche there's the
numactl, cpusets, and all sort of bindings already. No need of more
niche, that is pure kernel API pollution in my view, the niche has all
its hard tools it needs already.

I care only and exclusively about all those people that happen to have
bought one recent two socket node which happens to be a NUMA they want
it or not, and they find sometime their applications runs 50% slower
than they should, and they just want to run faster by upgrading the
kernel without having to touch userland at all.

If AutoNUMA is performing better than your code, I hope will move the
focus not on the small cost of collecting the information to compute,
but in the algorithms we use to compute the collected
information. Because if those are good, the boost is so huge that the
small cost of collecting the stats is lost in the noise.

And if you want to insist complaining about the cost I incur in
collecting the stats, I recommend switching the focus from the
pagetable scanner to the numa hinting page faults (even if the latter
are perfectly accounted by the scheduler).

I tried to extrapolate the smallest possible algorithms that should
handle everything it is being thrown at it while always resulting in a
net gain. I invented 4/5 other algorithms before this one and it took
me weeks of benchmarking to get up with something I was fully
statisfied with. I didn't have to change the brainer part for several
weeks already. And if for anything that isn't clear if you ask me I'll
be willing to explain it. As usual documentation is a bit lacking and
it's one of the items in my list (before any other brainer change).

In implementation terms the scheduler is simplified and it won't work
as well as it should with massive CPU overcommit. But I had to take
shortcuts to keep the complexity down to O(N) where N is the number of
CPUS (not of running processes, as it would have happened if I had it
evaluated the whole thing and handle overcommit well). That will
require some rbtree or other log(n) struct to compute the same
algorithm on all runqueues and not just the rq->curr so that it
handles CPU overcommit optimally. For now it wasn't a big concern. But
if you beat AutoNUMA only with massive CPU overcommit you know why. I
tested overcommit and it still worked almost as fast as the hard
bindings, even if it's only working at the rq->curr level it still
benefits greatly over time, I just don't know how much better it would
run if I extended the math to all the running processes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
