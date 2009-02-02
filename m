Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4871D5F0001
	for <linux-mm@kvack.org>; Sun,  1 Feb 2009 22:38:55 -0500 (EST)
Subject: Re: [patch] SLQB slab allocator
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
In-Reply-To: <Pine.LNX.4.64.0901231357250.9011@blonde.anvils>
References: <20090121143008.GV24891@wotan.suse.de>
	 <Pine.LNX.4.64.0901211705570.7020@blonde.anvils>
	 <84144f020901220201g6bdc2d5maf3395fc8b21fe67@mail.gmail.com>
	 <Pine.LNX.4.64.0901221239260.21677@blonde.anvils>
	 <Pine.LNX.4.64.0901231357250.9011@blonde.anvils>
Content-Type: text/plain; charset=UTF-8
Date: Mon, 02 Feb 2009 11:38:43 +0800
Message-Id: <1233545923.2604.60.camel@ymzhang>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, Christoph Lameter <cl@linux-foundation.org>Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi, Hugh,

On Fri, 2009-01-23 at 14:23 +0000, Hugh Dickins wrote:
> On Thu, 22 Jan 2009, Hugh Dickins wrote:
> > On Thu, 22 Jan 2009, Pekka Enberg wrote:
> > > On Wed, Jan 21, 2009 at 8:10 PM, Hugh Dickins <hugh@veritas.com> wrote:
> > > >
> > > > That's been making SLUB behave pretty badly (e.g. elapsed time 30%
> > > > more than SLAB) with swapping loads on most of my machines.  Though
Would you like to share your tmpfs loop swap load with me, so I could reproduce
it on my machines? Do your machines run at i386 mode or x86-64 mode? How much
memory do your machines have?

> > > > oddly one seems immune, and another takes four times as long: guess
> > > > it depends on how close to thrashing, but probably more to investigate
> > > > there.  I think my original SLUB versus SLAB comparisons were done on
> > > > the immune one: as I remember, SLUB and SLAB were equivalent on those
> > > > loads when SLUB came in, but even with boot option slub_max_order=1,
> > > > SLUB is still slower than SLAB on such tests (e.g. 2% slower).
> > > > FWIW - swapping loads are not what anybody should tune for.
> > > 
> > > What kind of machine are you seeing this on? It sounds like it could
> > > be a side-effect from commit 9b2cd506e5f2117f94c28a0040bf5da058105316
> > > ("slub: Calculate min_objects based on number of processors").
i>>?As I know little about your workload, I just guess from 'loop swap load' that
your load eats memory quickly and kernel/swap is started to keep a low free
memory.

Commit i>>?9b2cd506e5f2117f94c28a0040bf5da058105316 is just a method to increase
the page order for slub so there more free objects available in a slab. That
promotes performance for many benchmarks if there are enough __free__ pages.
Because memory is cheaper and comparing with cpu number increasing, memory
is increased more rapidly. So we create commit
9b2cd506e5f2117f94c28a0040bf5da058105316. In addition, if we have no this
commit, we will have another similiar commit to just increase slub_min_objects
and slub_max_order.

However, our assumption about free memory seems inappropriate when memory is
hungry just like your case. Function allocate_slab always tries the higher
order firstly. If it fails to get a new slab, it will tries the minimum order.
As for your case, I think the first try always fails, and it takes too much
time. Perhaps alloc_pages does far away from a checking even with flag
__GFP_NORETRY to consume extra time?


Christoph and Pekka,

Can we add a checking about free memory page number/percentage in function
allocate_slab that we can bypass the first try of alloc_pages when memory
is hungry?


> > 
> > Thanks, yes, that could well account for the residual difference: the
> > machines in question have 2 or 4 cpus, so the old slub_min_objects=4
> > has effectively become slub_min_objects=12 or slub_min_objects=16.
> > 
> > I'm now trying with slub_max_order=1 slub_min_objects=4 on the boot
> > lines (though I'll need to curtail tests on a couple of machines),
> > and will report back later.
> 
> Yes, slub_max_order=1 with slub_min_objects=4 certainly helps this
> swapping load.  I've not tried slub_max_order=0, but I'm running
> with 8kB stacks, so order 1 seems a reasonable choice.
> 
> I can't say where I pulled that "e.g. 2% slower" from: on different
> machines slub was 5% or 10% or 20% slower than slab and slqb even with
> slub_max_order=1 (but not significantly slower on the "immune" machine).
> How much slub_min_objects=4 helps again varies widely, between halving
> or eliminating the difference.
I guess your machines have different memory quantity, but your workload
mostly consumes specified number of pages, so the result percent is
different.

> 
> But I think it's more important that I focus on the worst case machine,
> try to understand what's going on there.
oprofile data and 'slabinfo -AD' output might help.

yanmin


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
