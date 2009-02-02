Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 714E05F0001
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 06:50:50 -0500 (EST)
Date: Mon, 2 Feb 2009 11:50:20 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] SLQB slab allocator
In-Reply-To: <1233545923.2604.60.camel@ymzhang>
Message-ID: <Pine.LNX.4.64.0902021013270.7621@blonde.anvils>
References: <20090121143008.GV24891@wotan.suse.de>
 <Pine.LNX.4.64.0901211705570.7020@blonde.anvils>
 <84144f020901220201g6bdc2d5maf3395fc8b21fe67@mail.gmail.com>
 <Pine.LNX.4.64.0901221239260.21677@blonde.anvils>
 <Pine.LNX.4.64.0901231357250.9011@blonde.anvils> <1233545923.2604.60.camel@ymzhang>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-758163607-1233575420=:7621"
Sender: owner-linux-mm@kvack.org
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-758163607-1233575420=:7621
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Mon, 2 Feb 2009, Zhang, Yanmin wrote:
> On Fri, 2009-01-23 at 14:23 +0000, Hugh Dickins wrote:
> > On Thu, 22 Jan 2009, Hugh Dickins wrote:
> > > On Thu, 22 Jan 2009, Pekka Enberg wrote:
> > > > On Wed, Jan 21, 2009 at 8:10 PM, Hugh Dickins <hugh@veritas.com> wr=
ote:
> > > > >
> > > > > That's been making SLUB behave pretty badly (e.g. elapsed time 30=
%
> > > > > more than SLAB) with swapping loads on most of my machines.  Thou=
gh
> Would you like to share your tmpfs loop swap load with me, so I could rep=
roduce
> it on my machines?

A very reasonable request that I feared someone would make!
I'm sure we all have test scripts that we can run happily ourselves,
but as soon as someone else asks, we want to make this and that and
the other adjustment, if only to reduce the amount of setup description
required - this is one such.  I guess I can restrain myself a little if
I'm just sending it to you, separately.

> Do your machines run at i386 mode or x86-64 mode?

Both: one is a ppc64 (G5 Quad), one is i386 only (Atom SSD netbook),
three I can run either way (though my common habit is to run two as
i386 with 32bit userspace and one as x86_64 with 64bit userspace).

> How much memory do your machines have?

I use mem=3D700M when running such tests on all of them (but leave
the netbook with its 1GB mem): otherwise I'd have to ramp up the
test in different ways to get them all swapping enough - it is
tmpfs and swapping that I'm personally most concerned to test.

> > > > > oddly one seems immune, and another takes four times as long: gue=
ss
> > > > > it depends on how close to thrashing, but probably more to invest=
igate
> > > > > there.  I think my original SLUB versus SLAB comparisons were don=
e on
> > > > > the immune one: as I remember, SLUB and SLAB were equivalent on t=
hose
> > > > > loads when SLUB came in, but even with boot option slub_max_order=
=3D1,
> > > > > SLUB is still slower than SLAB on such tests (e.g. 2% slower).
> > > > > FWIW - swapping loads are not what anybody should tune for.
> > > >=20
> > > > What kind of machine are you seeing this on? It sounds like it coul=
d
> > > > be a side-effect from commit 9b2cd506e5f2117f94c28a0040bf5da0581053=
16
> > > > ("slub: Calculate min_objects based on number of processors").
> =EF=BB=BFAs I know little about your workload, I just guess from 'loop sw=
ap load' that
> your load eats memory quickly and kernel/swap is started to keep a low fr=
ee
> memory.
>=20
> Commit =EF=BB=BF9b2cd506e5f2117f94c28a0040bf5da058105316 is just a method=
 to increase
> the page order for slub so there more free objects available in a slab. T=
hat
> promotes performance for many benchmarks if there are enough __free__ pag=
es.
> Because memory is cheaper and comparing with cpu number increasing, memor=
y
> is increased more rapidly. So we create commit
> 9b2cd506e5f2117f94c28a0040bf5da058105316. In addition, if we have no this
> commit, we will have another similiar commit to just increase slub_min_ob=
jects
> and slub_max_order.
>=20
> However, our assumption about free memory seems inappropriate when memory=
 is
> hungry just like your case. Function allocate_slab always tries the highe=
r
> order firstly. If it fails to get a new slab, it will tries the minimum o=
rder.
> As for your case, I think the first try always fails, and it takes too mu=
ch
> time. Perhaps alloc_pages does far away from a checking even with flag
> __GFP_NORETRY to consume extra time?

I believe you're thinking there of how much system time is used.
I haven't been paying much attention to that, and don't have any
complaints about slub from that angle (what's most noticeable there
is that, as expected, slob uses more system time than slab or slqb
or slub).  Although I do record the system time reported for the
test, I very rarely think to add in kswapd0's and loop0's times,
which would be very significant missed contributions.

What I've been worried by is the total elapsed times, that's where
slub shows up badly.  That means, I think, that bad decisions are
being made about what to swap out when, so that altogether there's
too much swapping: which is understandable when slub is aiming for
higher order allocations.  One page of the high order is selected
according to vmscan's usual criteria, but the remaining pages will
be chosen according to their adjacence rather than their age (to
some extent: there is code in there to resist bad decisions too).
If we imagine that vmscan's usual criteria are perfect (ha ha),
then it's unsurprising that going for higher order allocations
leads it to make inferior decisions and swap out too much.

>=20
> Christoph and Pekka,
>=20
> Can we add a checking about free memory page number/percentage in functio=
n
> allocate_slab that we can bypass the first try of alloc_pages when memory
> is hungry?

Having lots of free memory is a temporary accident following process
exit (when lots of anonymous memory has suddenly been freed), before
it has been put to use for page cache.  The kernel tries to run with
a certain amount of free memory in reserve, and the rest of memory
put to (potentially) good use.  I don't think we have the number
you're looking for there, though perhaps some approximation could
be devised (or I'm looking at the problem the wrong way round).

Perhaps feedback from vmscan.c, on how much it's having to write back,
would provide a good clue.  There's plenty of stats maintained there.

> > >=20
> > > Thanks, yes, that could well account for the residual difference: the
> > > machines in question have 2 or 4 cpus, so the old slub_min_objects=3D=
4
> > > has effectively become slub_min_objects=3D12 or slub_min_objects=3D16=
=2E
> > >=20
> > > I'm now trying with slub_max_order=3D1 slub_min_objects=3D4 on the bo=
ot
> > > lines (though I'll need to curtail tests on a couple of machines),
> > > and will report back later.
> >=20
> > Yes, slub_max_order=3D1 with slub_min_objects=3D4 certainly helps this
> > swapping load.  I've not tried slub_max_order=3D0, but I'm running
> > with 8kB stacks, so order 1 seems a reasonable choice.
> >=20
> > I can't say where I pulled that "e.g. 2% slower" from: on different
> > machines slub was 5% or 10% or 20% slower than slab and slqb even with
> > slub_max_order=3D1 (but not significantly slower on the "immune" machin=
e).
> > How much slub_min_objects=3D4 helps again varies widely, between halvin=
g
> > or eliminating the difference.
> I guess your machines have different memory quantity, but your workload
> mostly consumes specified number of pages, so the result percent is
> different.

No, mem=3D700M in each case but the netbook.

> >=20
> > But I think it's more important that I focus on the worst case machine,
> > try to understand what's going on there.
> oprofile data and 'slabinfo -AD' output might help.

oprofile I doubt here, since it's the total elapsed time that worries
me.  I had to look up 'slabinfo -AD', yes, thanks for that pointer, it
may help when I get around to investigating my totally unsubstantiated
suspicion ...

=2E.. on the laptop which suffers worst from slub, I am using an SD
card accessed as USB storage for swap (but no USB storage on the
others).  I'm suspecting there's something down that stack which
is slow to recover from allocation failures: when I tried a much
simplified test using just two "cp -a"s, they can hang on that box.
So my current guess is that slub makes something significantly worse
(some debug options make it significantly worse too), but the actual
bug is elsewhere.

Hugh
--8323584-758163607-1233575420=:7621--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
