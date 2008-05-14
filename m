Date: Wed, 14 May 2008 08:06:11 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
Message-ID: <20080514060610.GB30448@wotan.suse.de>
References: <6b384bb988786aa78ef0.1210170958@duo.random> <20080507234521.GN8276@duo.random> <20080508013459.GS8276@duo.random> <200805132214.27510.nickpiggin@yahoo.com.au> <1210743839.8297.55.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1210743839.8297.55.camel@pasglop>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrea Arcangeli <andrea@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, clameter@sgi.com, steiner@sgi.com, holt@sgi.com, a.p.zijlstra@chello.nl, kvm-devel@lists.sourceforge.net, kanojsarcar@yahoo.com, rdreier@cisco.com, swise@opengridcomputing.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, hugh@veritas.com, rusty@rustcorp.com.au, aliguori@us.ibm.com, chrisw@redhat.com, marcelo@kvack.org, dada1@cosmosbay.com, paulmck@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, May 13, 2008 at 10:43:59PM -0700, Benjamin Herrenschmidt wrote:
> 
> On Tue, 2008-05-13 at 22:14 +1000, Nick Piggin wrote:
> > ea.
> > 
> > I don't see why you're bending over so far backwards to accommodate
> > this GRU thing that we don't even have numbers for and could actually
> > potentially be batched up in other ways (eg. using mmu_gather or
> > mmu_gather-like idea).
> 
> I agree, we're better off generalizing the mmu_gather batching
> instead...

Well, the first thing would be just to get rid of the whole start/end
idea, which completely departs from the standard Linux system of
clearing ptes, then flushing TLBs, then freeing memory.

The onus would then be on GRU to come up with some numbers to justify
batching, and a patch which works nicely with the rest of the Linux
mm. And yes, mmu-gather is *the* obvious first choice of places to
look if one wanted batching hooks.


> I had some never-finished patches to use the mmu_gather for pretty much
> everything except single page faults, tho various subtle differences
> between archs and lack of time caused me to let them take the dust and
> not finish them...
> 
> I can try to dig some of that out when I'm back from my current travel,
> though it's probably worth re-doing from scratch now.

I always liked the idea as you know. But I don't think that should
be mixed in with the first iteration of the mmu notifiers patch
anyway. GRU actually can work without batching, but there is simply
some (unquantified to me) penalty for not batching it. I think it
is far better to first put in a clean and simple and working functionality
first. The idea that we have to unload some monster be-all-and-end-all
solution onto mainline in a single go seems counter productive to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
