Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: Why *not* rmap, anyway?
Date: Sun, 5 May 2002 21:04:16 +0200
References: <Pine.LNX.4.33.0204241138290.1968-100000@erol>
In-Reply-To: <Pine.LNX.4.33.0204241138290.1968-100000@erol>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E174RIu-00049X-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christian Smith <csmith@micromuse.com>, Rik van Riel <riel@conectiva.com.br>
Cc: Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 24 April 2002 12:50, Christian Smith wrote:
> On Tue, 23 Apr 2002, Rik van Riel wrote:
> >On Tue, 23 Apr 2002, Christian Smith wrote:
> >
> >> The question becomes, how much work would it be to rip out the Linux MM
> >> piece-meal, and replace it with an implementation of UVM?
> >
> >I doubt we want the Mach pmap layer.
> 
> Why not?

Because we use the page tables as part of our essential vm bookkeeping, thus
eliminating the whole UVM/mach 'memory objects' layer.  There was only ever
one trick the memory objects layer could do that we could not with our simple
page table based approach, that being page table sharing.  And now we've found
a way to do that as well, so there is no longer a single advantage to the
memory object strategy, while there is a lot of hard-to-read-and-maintain code
associated with it, and bookkeeping overhead.  (Note I'm not talking about the
rmap aspect here - that's overhead that buys us something tangible - we
think.)

> It'd surely make porting to new architecures easier

It doesn't really.  Ask Linus if you need to know in gory detail why, or
better, search the lkml archives.  This comes up regularly, and imho, Linus
is clearly correct here, both on theoretical grounds and in practice.

In fact, we do have our own abstraction, which is simply a per-architecture
implementation of the basic page table editing operations.  On architectures
that support it (ia32, uml, others) the hardware interprets the page tables
directly.  Otherwise, the contents of the generic page tables are forwarded
incrementally to the real hardware page tables.

Sticking strictly to the ia32 page table model *is* going to break
eventually, however it hasn't yet and we have plenty of time to generalize
the page table model when needed.  Note: 'generalize', not 'lather on a new
layer'.

> (not that
> I've tried it either way, mind) is there is a clearly defined MMU
> interface. Pmap can hide the differences between forward mapping page
> table, TLB or inverted page table lookups,

Not only hide, but interfere with.  For example, in my page table sharing
patch I treat page directories as first-class objects, with ref counts and
individual locks.  How do we extend the pmap api to accomodate that?

> can do SMP TLB shootdown 
> transparently.

But we already do that per-architecture, with a generic api.

> If not the Mach pmap layer, then surely another pmap-like 
> layer would be beneficial.

How about the one we already have?

> It can handle sparse address space management without the hackery of 
> n-level page tables, where a couple of years ago, 3 levels was enough for 
> anyone, but now we're not so sure.

This is true, however we don't need to add a new layer to deal with that,
just generalize the existing one.  You want to be very careful about where
you draw that boundaries, to avoid becoming hampered by the lowest common
denoninator effect.

> The n-level page table doesn't fit in with a high level, platform 
> independant MM, and doesn't easily work for all classes of low level MMU. 
> It doesn't really scale up or down.

I don't agree with 'doesn't scale down'.  I partially agree with 'doesn't
scale up'.  *However*, whatever bookkeeping structure we ultimately end up
with, it has to permit efficient processing in VM order - otherwise how are
you going to implement zap_page_range for example?  So it's going to stay
as some kind of tree, though it doesn't have to remain as rigidly defined
as it now is.

> Read the papers on UVM at:
>  http://www.ccrc.wustl.edu/pub/chuck/tech/uvm

Been there, done that :-)

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
