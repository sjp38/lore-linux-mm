Date: Mon, 25 Sep 2000 18:41:24 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: the new VMt
Message-ID: <20000925184124.C27677@athlon.random>
References: <20000925180448.A25083@gruyere.muc.suse.de> <Pine.LNX.4.21.0009251817420.9122-100000@elte.hu> <20000925181817.A25553@gruyere.muc.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000925181817.A25553@gruyere.muc.suse.de>; from ak@suse.de on Mon, Sep 25, 2000 at 06:18:17PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 06:18:17PM +0200, Andi Kleen wrote:
> On Mon, Sep 25, 2000 at 06:19:07PM +0200, Ingo Molnar wrote:
> > > Another thing I would worry about are ports with multiple user page
> > > sizes in 2.5. Another ugly case is the x86-64 port which has 4K pages
> > > but may likely need a 16K kernel stack due to the 64bit stack bloat.
> > 
> > yep, but these cases are not affected, i think in the order != 0 case we
> > should return NULL if a certain number of iterations did not yield any
> > free page.
> 
> Ok, that would just break fork()

Not sure if I have the whole context (I've not yet received Ingo's email
that you're replying to).

Currently we do a memory balancing pass indipendently by the order of the
allocation. Thus we don't do any iteraction and the memory balancing
is completly order blind (unfortunately it's also zone blind, while
at least in 2.2.x the memory balancing known which zone it had
to allocate memory from).

If Ingo suggested more iteractions of memory balancing for those cases
that should only make things better with respect to fragmentation.

But I'd much prefer to pass not only the classzone from allocator
to memory balancing, but _also_ the order of the allocation,
and then shrink_mmap will know it doesn't worth to free anything 
that isn't contigous on the order of the allocation that we need.

classzone haven't reached this point yet.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
