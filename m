Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3548A6B0044
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 09:23:32 -0500 (EST)
Date: Fri, 23 Jan 2009 14:23:14 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] SLQB slab allocator
In-Reply-To: <Pine.LNX.4.64.0901221239260.21677@blonde.anvils>
Message-ID: <Pine.LNX.4.64.0901231357250.9011@blonde.anvils>
References: <20090121143008.GV24891@wotan.suse.de>
 <Pine.LNX.4.64.0901211705570.7020@blonde.anvils>
 <84144f020901220201g6bdc2d5maf3395fc8b21fe67@mail.gmail.com>
 <Pine.LNX.4.64.0901221239260.21677@blonde.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jan 2009, Hugh Dickins wrote:
> On Thu, 22 Jan 2009, Pekka Enberg wrote:
> > On Wed, Jan 21, 2009 at 8:10 PM, Hugh Dickins <hugh@veritas.com> wrote:
> > >
> > > That's been making SLUB behave pretty badly (e.g. elapsed time 30%
> > > more than SLAB) with swapping loads on most of my machines.  Though
> > > oddly one seems immune, and another takes four times as long: guess
> > > it depends on how close to thrashing, but probably more to investigate
> > > there.  I think my original SLUB versus SLAB comparisons were done on
> > > the immune one: as I remember, SLUB and SLAB were equivalent on those
> > > loads when SLUB came in, but even with boot option slub_max_order=1,
> > > SLUB is still slower than SLAB on such tests (e.g. 2% slower).
> > > FWIW - swapping loads are not what anybody should tune for.
> > 
> > What kind of machine are you seeing this on? It sounds like it could
> > be a side-effect from commit 9b2cd506e5f2117f94c28a0040bf5da058105316
> > ("slub: Calculate min_objects based on number of processors").
> 
> Thanks, yes, that could well account for the residual difference: the
> machines in question have 2 or 4 cpus, so the old slub_min_objects=4
> has effectively become slub_min_objects=12 or slub_min_objects=16.
> 
> I'm now trying with slub_max_order=1 slub_min_objects=4 on the boot
> lines (though I'll need to curtail tests on a couple of machines),
> and will report back later.

Yes, slub_max_order=1 with slub_min_objects=4 certainly helps this
swapping load.  I've not tried slub_max_order=0, but I'm running
with 8kB stacks, so order 1 seems a reasonable choice.

I can't say where I pulled that "e.g. 2% slower" from: on different
machines slub was 5% or 10% or 20% slower than slab and slqb even with
slub_max_order=1 (but not significantly slower on the "immune" machine).
How much slub_min_objects=4 helps again varies widely, between halving
or eliminating the difference.

But I think it's more important that I focus on the worst case machine,
try to understand what's going on there.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
