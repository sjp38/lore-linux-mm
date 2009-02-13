Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 70FFF6B003D
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 09:14:53 -0500 (EST)
Subject: Re: [PATCH] mm: disable preemption in apply_to_pte_range
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <200902140030.59027.nickpiggin@yahoo.com.au>
References: <4994BCF0.30005@goop.org> <4994CF35.60507@goop.org>
	 <1234525710.6519.17.camel@twins>
	 <200902140030.59027.nickpiggin@yahoo.com.au>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Fri, 13 Feb 2009 15:16:51 +0100
Message-Id: <1234534611.6519.109.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Sat, 2009-02-14 at 00:30 +1100, Nick Piggin wrote:
> On Friday 13 February 2009 22:48:30 Peter Zijlstra wrote:
> > On Thu, 2009-02-12 at 17:39 -0800, Jeremy Fitzhardinge wrote:
> > > In general the model for lazy updates is that you're batching the
> > > updates in some queue somewhere, which is almost certainly a piece of
> > > percpu state being maintained by someone.  Its therefore broken and/or
> > > meaningless to have the code making the updates wandering between cpus
> > > for the duration of the lazy updates.
> > >
> > > > If so, should we do the preempt_disable/enable within those functions?
> > > > Probably not worth the cost, I guess.
> > >
> > > The specific rules are that
> > > arch_enter_lazy_mmu_mode()/arch_leave_lazy_mmu_mode() require you to be
> > > holding the appropriate pte locks for the ptes you're updating, so
> > > preemption is naturally disabled in that case.
> >
> > Right, except on -rt where the pte lock is a mutex.
> >
> > > This all goes a bit strange with init_mm's non-requirement for taking
> > > pte locks.  The caller has to arrange for some kind of serialization on
> > > updating the range in question, and that could be a mutex.  Explicitly
> > > disabling preemption in enter_lazy_mmu_mode would make sense for this
> > > case, but it would be redundant for the common case of batched updates
> > > to usermode ptes.
> >
> > I really utterly hate how you just plonk preempt_disable() in there
> > unconditionally and without very clear comments on how and why.
> 
> And even on mainline kernels, builds without the lazy mmu mode stuff
> don't need preemption disabled here either, so it is technically a
> regression in those cases too.

Well, normally we'd be holding the pte lock, which on regular kernels
already disable preemption, as Jeremy noted. So in that respect it
doesn't change things too much.

Its just that slapping preempt_disable()s around like there's not
tomorrow is horridly annoying, its like using the BKL -- there's no data
affinity what so ever, so trying to unravel the dependencies a year
later when you notice its a latency concern is a massive pain in the
backside.

> > I'd rather we'd fix up the init_mm to also have a pte lock.
> 
> Well that wouldn't fix -rt; there would need to be a preempt_disable
> within arch_enter_lazy_mmu_mode(), which I think is the cleanest
> solution.

Hmm, so you're saying we need to be cpu-affine for the lazy mmu stuff?
Otherwise a -rt would just convert the init_mm pte lock to a mutex along
with all other pte locks and there'd be no issue.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
