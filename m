Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2F9706B27D8
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 23:31:16 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id p5-v6so2399926pfh.11
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 20:31:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c4-v6sor908635plr.80.2018.08.22.20.31.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 20:31:14 -0700 (PDT)
Date: Thu, 23 Aug 2018 13:31:03 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 2/4] mm/tlb: Remove tlb_remove_table() non-concurrent
 condition
Message-ID: <20180823133103.30d6a16b@roar.ozlabs.ibm.com>
In-Reply-To: <20180822154046.772017055@infradead.org>
References: <20180822153012.173508681@infradead.org>
	<20180822154046.772017055@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: torvalds@linux-foundation.org, luto@kernel.org, x86@kernel.org, bp@alien8.de, will.deacon@arm.com, riel@surriel.com, jannh@google.com, ascannell@google.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Wed, 22 Aug 2018 17:30:14 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> Will noted that only checking mm_users is incorrect; we should also
> check mm_count in order to cover CPUs that have a lazy reference to
> this mm (and could do speculative TLB operations).

Why is that incorrect?

This shortcut has nothing to do with no TLBs -- not sure about x86, but
other CPUs can certainly have remaining TLBs here, speculative
operations or not (even if they don't have an mm_count ref they can
have TLBs here).

So that leaves speculative operations. I don't see where the problem is
with those either -- this shortcut needs to ensure there are no other
*non speculative* operations. mm_users is correct for that.

If there is a speculation security problem here it should be carefully
documented otherwise it's going to be re-introduced...

I actually have a patch to extend this optimisation further that I'm
going to send out again today. It's nice to avoid the double handling
of the pages.

Thanks,
Nick

> 
> If removing this turns out to be a performance issue, we can
> re-instate a more complete check, but in tlb_table_flush() eliding the
> call_rcu_sched().
> 
> Cc: stable@kernel.org
> Cc: Nicholas Piggin <npiggin@gmail.com>
> Cc: David Miller <davem@davemloft.net>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Fixes: 267239116987 ("mm, powerpc: move the RCU page-table freeing into generic code")
> Reported-by: Will Deacon <will.deacon@arm.com>
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> ---
>  mm/memory.c |    9 ---------
>  1 file changed, 9 deletions(-)
> 
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -375,15 +375,6 @@ void tlb_remove_table(struct mmu_gather
>  {
>  	struct mmu_table_batch **batch = &tlb->batch;
>  
> -	/*
> -	 * When there's less then two users of this mm there cannot be a
> -	 * concurrent page-table walk.
> -	 */
> -	if (atomic_read(&tlb->mm->mm_users) < 2) {
> -		__tlb_remove_table(table);
> -		return;
> -	}
> -
>  	if (*batch == NULL) {
>  		*batch = (struct mmu_table_batch *)__get_free_page(GFP_NOWAIT | __GFP_NOWARN);
>  		if (*batch == NULL) {
> 
> 
