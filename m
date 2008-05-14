Date: Wed, 14 May 2008 08:15:32 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
Message-ID: <20080514131531.GA10393@sgi.com>
References: <6b384bb988786aa78ef0.1210170958@duo.random> <20080507234521.GN8276@duo.random> <20080508013459.GS8276@duo.random> <200805132214.27510.nickpiggin@yahoo.com.au> <1210743839.8297.55.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1210743839.8297.55.camel@pasglop>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrea Arcangeli <andrea@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, clameter@sgi.com, holt@sgi.com, npiggin@suse.de, a.p.zijlstra@chello.nl, kvm-devel@lists.sourceforge.net, kanojsarcar@yahoo.com, rdreier@cisco.com, swise@opengridcomputing.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, hugh@veritas.com, rusty@rustcorp.com.au, aliguori@us.ibm.com, chrisw@redhat.com, marcelo@kvack.org, dada1@cosmosbay.com, paulmck@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, May 13, 2008 at 10:43:59PM -0700, Benjamin Herrenschmidt wrote:
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

Unfortunately, we are at least several months away from being able to
provide numbers to justify batching - assuming it is really needed.  We need
large systems running real user workloads. I wish we had that available
right now, but we don't.

It also depends on what you mean by "no batching". If you mean that the
notifier gets called for each pte that is removed from the page table, then
the overhead is clearly very high for some operations. Consider the unmap of
a very large object. A TLB flush per page will be too costly.

However, something based on the mmu_gather seems like it should provide
exactly what is needed to do efficient flushing of the TLB. The GRU does not
require that it be called in a sleepable context. As long as the notifier
callout provides the mmu_gather and vaddr range being flushed, the GRU can
do the efficiently do the rest.

> 
> I had some never-finished patches to use the mmu_gather for pretty much
> everything except single page faults, tho various subtle differences
> between archs and lack of time caused me to let them take the dust and
> not finish them...
> 
> I can try to dig some of that out when I'm back from my current travel,
> though it's probably worth re-doing from scratch now.
> 
> Ben.
> 


-- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
