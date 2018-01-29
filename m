Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9AEA16B0007
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 05:28:01 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id b9so1007321wra.1
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 02:28:01 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id r9si7193655wme.262.2018.01.29.02.28.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Jan 2018 02:28:00 -0800 (PST)
Date: Mon, 29 Jan 2018 11:27:46 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [4.15-rc9] fs_reclaim lockdep trace
Message-ID: <20180129102746.GQ2269@hirez.programming.kicks-ass.net>
References: <20180124013651.GA1718@codemonkey.org.uk>
 <20180127222433.GA24097@codemonkey.org.uk>
 <CA+55aFx6w9+C-WM9=xqsmnrMwKzDHeCwVNR5Lbnc9By00b6dzw@mail.gmail.com>
 <d726458d-3d3b-5580-ddfc-2914cbf756ba@I-love.SAKURA.ne.jp>
 <7771dd55-2655-d3a9-80ee-24c9ada7dbbe@I-love.SAKURA.ne.jp>
 <8f1c776d-b791-e0b9-1e5c-62b03dcd1d74@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8f1c776d-b791-e0b9-1e5c-62b03dcd1d74@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Jones <davej@codemonkey.org.uk>, Nick Piggin <npiggin@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Network Development <netdev@vger.kernel.org>, mhocko@kernel.org

On Sun, Jan 28, 2018 at 02:55:28PM +0900, Tetsuo Handa wrote:
> This warning seems to be caused by commit d92a8cfcb37ecd13
> ("locking/lockdep: Rework FS_RECLAIM annotation") which moved the
> location of
> 
>   /* this guy won't enter reclaim */
>   if ((current->flags & PF_MEMALLOC) && !(gfp_mask & __GFP_NOMEMALLOC))
>           return false;
> 
> check added by commit cf40bd16fdad42c0 ("lockdep: annotate reclaim context
> (__GFP_NOFS)").

I'm not entirly sure I get what you mean here. How did I move it? It was
part of lockdep_trace_alloc(), if __GFP_NOMEMALLOC was set, it would not
mark the lock as held.

The new code has it in fs_reclaim_acquire/release to the same effect, if
__GFP_NOMEMALLOC, we'll not acquire/release the lock.


> Since __kmalloc_reserve() from __alloc_skb() adds
> __GFP_NOMEMALLOC | __GFP_NOWARN to gfp_mask, __need_fs_reclaim() is
> failing to return false despite PF_MEMALLOC context (and resulted in
> lockdep warning).

But that's correct right, __GFP_NOMEMALLOC should negate PF_MEMALLOC.
That's what the name says.

> Since there was no PF_MEMALLOC safeguard as of cf40bd16fdad42c0, checking
> __GFP_NOMEMALLOC might make sense. But since this safeguard was added by
> commit 341ce06f69abfafa ("page allocator: calculate the alloc_flags for
> allocation only once"), checking __GFP_NOMEMALLOC no longer makes sense.
> Thus, let's remove __GFP_NOMEMALLOC check and allow __need_fs_reclaim() to
> return false.

This does not in fact explain what's going on, it just points to
'random' patches.

Are you talking about this:

+       /* Avoid recursion of direct reclaim */
+       if (p->flags & PF_MEMALLOC)
+               goto nopage;

bit?

> Reported-by: Dave Jones <davej@codemonkey.org.uk>
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Nick Piggin <npiggin@gmail.com>
> ---
>  mm/page_alloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 76c9688..7804b0e 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3583,7 +3583,7 @@ static bool __need_fs_reclaim(gfp_t gfp_mask)
>  		return false;
>  
>  	/* this guy won't enter reclaim */
> -	if ((current->flags & PF_MEMALLOC) && !(gfp_mask & __GFP_NOMEMALLOC))
> +	if (current->flags & PF_MEMALLOC)
>  		return false;

I'm _really_ uncomfortable doing that. Esp. without a solid explanation
of how this raelly can't possibly lead to trouble. Which the above semi
incoherent rambling is not.

Your backtrace shows the btrfs shrinker doing an allocation, that's the
exact kind of thing we need to be extremely careful with.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
