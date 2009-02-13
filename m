Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C90766B00A0
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 19:56:35 -0500 (EST)
Date: Thu, 12 Feb 2009 16:55:39 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: disable preemption in apply_to_pte_range
Message-Id: <20090212165539.5ce51468.akpm@linux-foundation.org>
In-Reply-To: <4994C052.9060907@goop.org>
References: <4994BCF0.30005@goop.org>
	<4994C052.9060907@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 12 Feb 2009 16:35:30 -0800
Jeremy Fitzhardinge <jeremy@goop.org> wrote:

> Jeremy Fitzhardinge wrote:
> > commit 79d9c90453a7bc9e7613ae889a97ff6b44ab8380
> 
> Scratch that.

Whew.  Version 1 did an obvious GFP_KERNEL allocation inside
preempt_disable().

>  This instead.
>     J
> 
>     mm: disable preemption in apply_to_pte_range
>     
>     Lazy mmu mode needs preemption disabled, so if we're apply to
>     init_mm (which doesn't require any pte locks), then explicitly
>     disable preemption.  (Do it unconditionally after checking we've
>     successfully done the allocation to simplify the error handling.)
>     
>     Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index baa999e..b80cc31 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1718,6 +1718,7 @@ static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
>  
>  	BUG_ON(pmd_huge(*pmd));
>  
> +	preempt_disable();
>  	arch_enter_lazy_mmu_mode();
>  
>  	token = pmd_pgtable(*pmd);
> @@ -1729,6 +1730,7 @@ static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
>  	} while (pte++, addr += PAGE_SIZE, addr != end);
>  
>  	arch_leave_lazy_mmu_mode();
> +	preempt_enable();
>  
>  	if (mm != &init_mm)
>  		pte_unmap_unlock(pte-1, ptl);
> 

This weakens the apply_to_page_range() utility by newly requiring that
the callback function be callable under preempt_disable() if the target
mm is init_mm.  I guess we can live with that.

It's OK for the two present in-tree callers.  There might of course be
out-of-tree callers which break, but it is unlikely.

The patch should include a comment explaining why there is a random
preempt_disable() in this function.


Why is apply_to_page_range() exported to modules, btw?  I can find no
modules which need it.  Unexporting that function would make the
proposed weakening even less serious.


The patch assumes that
arch_enter_lazy_mmu_mode()/arch_leave_lazy_mmu_mode() must have
preemption disabled for all architectures.  Is this a sensible
assumption?

If so, should we do the preempt_disable/enable within those functions? 
Probably not worth the cost, I guess..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
