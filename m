Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id F07696B0262
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 16:38:50 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e189so176058341pfa.2
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 13:38:50 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id a19si4721908pal.46.2016.07.14.13.38.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jul 2016 13:38:50 -0700 (PDT)
Received: by mail-pa0-x231.google.com with SMTP id ks6so31888401pab.0
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 13:38:49 -0700 (PDT)
Date: Thu, 14 Jul 2016 13:38:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: System freezes after OOM
In-Reply-To: <20160714152913.GC12289@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1607141326500.68666@chino.kir.corp.google.com>
References: <9be09452-de7f-d8be-fd5d-4a80d1cd1ba3@redhat.com> <alpine.LRH.2.02.1607111027080.14327@file01.intranet.prod.int.rdu2.redhat.com> <20160712064905.GA14586@dhcp22.suse.cz> <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com>
 <2d5e1f84-e886-7b98-cb11-170d7104fd13@I-love.SAKURA.ne.jp> <20160713133955.GK28723@dhcp22.suse.cz> <alpine.LRH.2.02.1607131004340.31769@file01.intranet.prod.int.rdu2.redhat.com> <20160713145638.GM28723@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607131105080.31769@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.10.1607131644590.92037@chino.kir.corp.google.com> <20160714152913.GC12289@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 14 Jul 2016, Michal Hocko wrote:

> > It prevents the whole system from livelocking due to an oom killed process 
> > stalling forever waiting for mempool_alloc() to return.  No other threads 
> > may be oom killed while waiting for it to exit.
> 
> But it is true that the patch has unintended side effect for any mempool
> allocation from the reclaim path (aka PF_MEMALLOC context).

If PF_MEMALLOC context is allocating too much memory reserves, then I'd 
argue that is a problem independent of using mempool_alloc() since 
mempool_alloc() can evolve directly into a call to the page allocator.  
How does such a process guarantee that it cannot deplete memory reserves 
with a simple call to the page allocator?  Since nothing in the page 
allocator is preventing complete depletion of reserves (it simply uses 
ALLOC_NO_WATERMARKS), the caller in a PF_MEMALLOC context must be 
responsible.

> So do you
> think we should rework your additional patch to be explicit about
> TIF_MEMDIE?

Not sure which additional patch you're referring to, the only patch that I 
proposed was commit f9054c70d28b which solved hundreds of machines from 
timing out.

> Something like the following (not even compile tested for
> illustration). Tetsuo has properly pointed out that this doesn't work
> for multithreaded processes reliable but put that aside for now as that
> needs a fix on a different layer. I believe we can fix that quite
> easily after recent/planned changes.
> ---
> diff --git a/mm/mempool.c b/mm/mempool.c
> index 8f65464da5de..ea26d75c8adf 100644
> --- a/mm/mempool.c
> +++ b/mm/mempool.c
> @@ -322,20 +322,20 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
>  
>  	might_sleep_if(gfp_mask & __GFP_DIRECT_RECLAIM);
>  
> +	gfp_mask |= __GFP_NOMEMALLOC;   /* don't allocate emergency reserves */
>  	gfp_mask |= __GFP_NORETRY;	/* don't loop in __alloc_pages */
>  	gfp_mask |= __GFP_NOWARN;	/* failures are OK */
>  
>  	gfp_temp = gfp_mask & ~(__GFP_DIRECT_RECLAIM|__GFP_IO);
>  
>  repeat_alloc:
> -	if (likely(pool->curr_nr)) {
> -		/*
> -		 * Don't allocate from emergency reserves if there are
> -		 * elements available.  This check is racy, but it will
> -		 * be rechecked each loop.
> -		 */
> -		gfp_temp |= __GFP_NOMEMALLOC;
> -	}
> +	/*
> +	 * Make sure that the OOM victim will get access to memory reserves
> +	 * properly if there are no objects in the pool to prevent from
> +	 * livelocks.
> +	 */
> +	if (!likely(pool->curr_nr) && test_thread_flag(TIF_MEMDIE))
> +		gfp_temp &= ~__GFP_NOMEMALLOC;
>  
>  	element = pool->alloc(gfp_temp, pool->pool_data);
>  	if (likely(element != NULL))
> @@ -359,7 +359,7 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
>  	 * We use gfp mask w/o direct reclaim or IO for the first round.  If
>  	 * alloc failed with that and @pool was empty, retry immediately.
>  	 */
> -	if ((gfp_temp & ~__GFP_NOMEMALLOC) != gfp_mask) {
> +	if ((gfp_temp & __GFP_DIRECT_RECLAIM) != (gfp_mask & __GFP_DIRECT_RECLAIM)) {
>  		spin_unlock_irqrestore(&pool->lock, flags);
>  		gfp_temp = gfp_mask;
>  		goto repeat_alloc;

This is bogus and quite obviously leads to oom livelock: if a process is 
holding a mutex and does mempool_alloc(), since __GFP_WAIT is allowed in 
process context for mempool allocation, it can stall here in an oom 
condition if there are no elements available on the mempool freelist.  If 
the oom victim contends the same mutex, the system livelocks and the same 
bug arises because the holder of the mutex loops forever.  This is the 
exact behavior that f9054c70d28b also fixes.

These aren't hypothetical situations, the patch fixed hundreds of machines 
from regularly timing out.  The fundamental reason is that mempool_alloc() 
must not loop forever in process context: that is needed when the 
allocator is either an oom victim itself or the oom victim is blocked by 
an allocator.  mempool_alloc() must guarantee forward progress in such a 
context.

The end result is that when in PF_MEMALLOC context, allocators must be 
responsible and not deplete all memory reserves.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
