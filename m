Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A843F6B005C
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 16:08:04 -0500 (EST)
Date: Fri, 16 Jan 2009 15:07:52 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] SLQB slab allocator
In-Reply-To: <20090116031940.GL17810@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0901161500080.27283@quilx.com>
References: <20090114090449.GE2942@wotan.suse.de>
 <84144f020901140253s72995188vb35a79501c38eaa3@mail.gmail.com>
 <20090114114707.GA24673@wotan.suse.de> <84144f020901140544v56b856a4w80756b90f5b59f26@mail.gmail.com>
 <20090114142200.GB25401@wotan.suse.de> <84144f020901140645o68328e01ne0e10ace47555e19@mail.gmail.com>
 <20090114150900.GC25401@wotan.suse.de> <Pine.LNX.4.64.0901141158090.26507@quilx.com>
 <20090115060330.GB17810@wotan.suse.de> <Pine.LNX.4.64.0901151320250.26467@quilx.com>
 <20090116031940.GL17810@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 16 Jan 2009, Nick Piggin wrote:

> > handled by the same 2M TLB covering a 32k page. If the 4k pages are
> > dispersed then you may need 8 2M tlbs (which covers already a quarter of
> > the available 2M TLBs on nehalem f.e.) for which the larger alloc just
> > needs a single one.
>
> Yes I know that. But it's pretty theoretical IMO (and I could equally
> describe a theoretical situation where increased fragmentation in higher
> order slabs will result in worse TLB coverage).

Theoretical only for low sizes of memory. If you have terabytes of memory
then this becomes significant in a pretty fast way.

> > It has lists of free objects that are bound to a particular page. That
> > simplifies numa handling since all the objects in a "queue" (or page) have
> > the same NUMA characteristics.
>
> The same can be said of SLQB and SLAB as well.

Sorry not at all. SLAB and SLQB queue objects from different pages in the
same queue.

> > was assigned to a processor. Memory wastage may only occur because
> > each processor needs to have a separate page from which to allocate. SLAB
> > like designs needs to put a large number of objects in queues which may
> > keep a number of pages in the allocated pages pool although all objects
> > are unused. That does not occur with slub.
>
> That's wrong. SLUB keeps completely free pages on its partial lists, and
> also IIRC can keep free pages pinned in the per-cpu page. I have actually
> seen SLQB use less memory than SLUB in some situations for this reason.

As I sad it pins a single page in the per cpu page and uses that in a way
that you call a queue and I call a freelist.

SLUB keeps a few pages on the partial list right now because it tries to
avoid trips to the page allocator (which is quite slow). These could be
eliminated if the page allocator would work effectively. However that
number is a per node limit.

SLAB and SLUB can have large quantities of objects in their queues that
each can keep a single page out of circulation if its the last
object in that page. This is per queue thing and you have at least two
queues per cpu. SLAB has queues per cpu, per pair of cpu, per node and per
alien node for each node. That can pin quite a number of pages on large
systems. Note that SLAB has one per cpu whereas you have already 2 per
cpu? In SMP configurations this may mean that SLQB has more queues than
SLAB.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
