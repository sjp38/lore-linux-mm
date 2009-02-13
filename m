Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 43E556B003D
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 08:31:30 -0500 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] mm: disable preemption in apply_to_pte_range
Date: Sat, 14 Feb 2009 00:30:58 +1100
References: <4994BCF0.30005@goop.org> <4994CF35.60507@goop.org> <1234525710.6519.17.camel@twins>
In-Reply-To: <1234525710.6519.17.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902140030.59027.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Friday 13 February 2009 22:48:30 Peter Zijlstra wrote:
> On Thu, 2009-02-12 at 17:39 -0800, Jeremy Fitzhardinge wrote:
> > In general the model for lazy updates is that you're batching the
> > updates in some queue somewhere, which is almost certainly a piece of
> > percpu state being maintained by someone.  Its therefore broken and/or
> > meaningless to have the code making the updates wandering between cpus
> > for the duration of the lazy updates.
> >
> > > If so, should we do the preempt_disable/enable within those functions?
> > > Probably not worth the cost, I guess.
> >
> > The specific rules are that
> > arch_enter_lazy_mmu_mode()/arch_leave_lazy_mmu_mode() require you to be
> > holding the appropriate pte locks for the ptes you're updating, so
> > preemption is naturally disabled in that case.
>
> Right, except on -rt where the pte lock is a mutex.
>
> > This all goes a bit strange with init_mm's non-requirement for taking
> > pte locks.  The caller has to arrange for some kind of serialization on
> > updating the range in question, and that could be a mutex.  Explicitly
> > disabling preemption in enter_lazy_mmu_mode would make sense for this
> > case, but it would be redundant for the common case of batched updates
> > to usermode ptes.
>
> I really utterly hate how you just plonk preempt_disable() in there
> unconditionally and without very clear comments on how and why.

And even on mainline kernels, builds without the lazy mmu mode stuff
don't need preemption disabled here either, so it is technically a
regression in those cases too.

> I'd rather we'd fix up the init_mm to also have a pte lock.

Well that wouldn't fix -rt; there would need to be a preempt_disable
within arch_enter_lazy_mmu_mode(), which I think is the cleanest
solution.

And, hmm... this makes me wonder what is being applied to what? Are
the callers of apply_to_pte_range on init_mm doing the correct
locking? I'd not be surprised if not. Jeremy did you notice any
particular backtraces?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
