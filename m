Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id EAAB76B0047
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 06:46:37 -0500 (EST)
Subject: Re: [PATCH] mm: disable preemption in apply_to_pte_range
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <4994CF35.60507@goop.org>
References: <4994BCF0.30005@goop.org>	<4994C052.9060907@goop.org>
	 <20090212165539.5ce51468.akpm@linux-foundation.org>
	 <4994CF35.60507@goop.org>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Fri, 13 Feb 2009 12:48:30 +0100
Message-Id: <1234525710.6519.17.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-02-12 at 17:39 -0800, Jeremy Fitzhardinge wrote:

> In general the model for lazy updates is that you're batching the 
> updates in some queue somewhere, which is almost certainly a piece of 
> percpu state being maintained by someone.  Its therefore broken and/or 
> meaningless to have the code making the updates wandering between cpus 
> for the duration of the lazy updates.
> 
> > If so, should we do the preempt_disable/enable within those functions? 
> > Probably not worth the cost, I guess.
> 
> The specific rules are that 
> arch_enter_lazy_mmu_mode()/arch_leave_lazy_mmu_mode() require you to be 
> holding the appropriate pte locks for the ptes you're updating, so 
> preemption is naturally disabled in that case.

Right, except on -rt where the pte lock is a mutex.

> This all goes a bit strange with init_mm's non-requirement for taking 
> pte locks.  The caller has to arrange for some kind of serialization on 
> updating the range in question, and that could be a mutex.  Explicitly 
> disabling preemption in enter_lazy_mmu_mode would make sense for this 
> case, but it would be redundant for the common case of batched updates 
> to usermode ptes.

I really utterly hate how you just plonk preempt_disable() in there
unconditionally and without very clear comments on how and why.

I'd rather we'd fix up the init_mm to also have a pte lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
