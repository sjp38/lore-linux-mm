Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3A60C6B00A4
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 20:39:07 -0500 (EST)
Message-ID: <4994CF35.60507@goop.org>
Date: Thu, 12 Feb 2009 17:39:01 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: disable preemption in apply_to_pte_range
References: <4994BCF0.30005@goop.org>	<4994C052.9060907@goop.org> <20090212165539.5ce51468.akpm@linux-foundation.org>
In-Reply-To: <20090212165539.5ce51468.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> This weakens the apply_to_page_range() utility by newly requiring that
> the callback function be callable under preempt_disable() if the target
> mm is init_mm.  I guess we can live with that.
>
> It's OK for the two present in-tree callers.  There might of course be
> out-of-tree callers which break, but it is unlikely.
>
> The patch should include a comment explaining why there is a random
> preempt_disable() in this function.
>   

I cuddled them up to their corresponding arch_X_lazy_mmu_mode calls to 
get this across, but I guess some prose would be helpful here.

> Why is apply_to_page_range() exported to modules, btw?  I can find no
> modules which need it.  Unexporting that function would make the
> proposed weakening even less serious.
>   

I have some yet-to-be upstreamed code that can use it from modules.

> The patch assumes that
> arch_enter_lazy_mmu_mode()/arch_leave_lazy_mmu_mode() must have
> preemption disabled for all architectures.  Is this a sensible
> assumption?
>   

In general the model for lazy updates is that you're batching the 
updates in some queue somewhere, which is almost certainly a piece of 
percpu state being maintained by someone.  Its therefore broken and/or 
meaningless to have the code making the updates wandering between cpus 
for the duration of the lazy updates.

> If so, should we do the preempt_disable/enable within those functions? 
> Probably not worth the cost, I guess.

The specific rules are that 
arch_enter_lazy_mmu_mode()/arch_leave_lazy_mmu_mode() require you to be 
holding the appropriate pte locks for the ptes you're updating, so 
preemption is naturally disabled in that case.

This all goes a bit strange with init_mm's non-requirement for taking 
pte locks.  The caller has to arrange for some kind of serialization on 
updating the range in question, and that could be a mutex.  Explicitly 
disabling preemption in enter_lazy_mmu_mode would make sense for this 
case, but it would be redundant for the common case of batched updates 
to usermode ptes.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
