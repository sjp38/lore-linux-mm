Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 986CA6B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 06:47:57 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id j68so2494582oih.14
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 03:47:57 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id s4si5050097ots.303.2018.01.29.03.47.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Jan 2018 03:47:56 -0800 (PST)
Subject: Re: [4.15-rc9] fs_reclaim lockdep trace
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <CA+55aFx6w9+C-WM9=xqsmnrMwKzDHeCwVNR5Lbnc9By00b6dzw@mail.gmail.com>
	<d726458d-3d3b-5580-ddfc-2914cbf756ba@I-love.SAKURA.ne.jp>
	<7771dd55-2655-d3a9-80ee-24c9ada7dbbe@I-love.SAKURA.ne.jp>
	<8f1c776d-b791-e0b9-1e5c-62b03dcd1d74@I-love.SAKURA.ne.jp>
	<20180129102746.GQ2269@hirez.programming.kicks-ass.net>
In-Reply-To: <20180129102746.GQ2269@hirez.programming.kicks-ass.net>
Message-Id: <201801292047.EHC05241.OHSQOJOVtFMFLF@I-love.SAKURA.ne.jp>
Date: Mon, 29 Jan 2018 20:47:20 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org
Cc: torvalds@linux-foundation.org, davej@codemonkey.org.uk, npiggin@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, mhocko@kernel.org

Peter Zijlstra wrote:
> On Sun, Jan 28, 2018 at 02:55:28PM +0900, Tetsuo Handa wrote:
> > This warning seems to be caused by commit d92a8cfcb37ecd13
> > ("locking/lockdep: Rework FS_RECLAIM annotation") which moved the
> > location of
> > 
> >   /* this guy won't enter reclaim */
> >   if ((current->flags & PF_MEMALLOC) && !(gfp_mask & __GFP_NOMEMALLOC))
> >           return false;
> > 
> > check added by commit cf40bd16fdad42c0 ("lockdep: annotate reclaim context
> > (__GFP_NOFS)").
> 
> I'm not entirly sure I get what you mean here. How did I move it? It was
> part of lockdep_trace_alloc(), if __GFP_NOMEMALLOC was set, it would not
> mark the lock as held.

d92a8cfcb37ecd13 replaced lockdep_set_current_reclaim_state() with
fs_reclaim_acquire(), and removed current->lockdep_recursion handling.

----------
# git show d92a8cfcb37ecd13 | grep recursion
-# define INIT_LOCKDEP                          .lockdep_recursion = 0, .lockdep_reclaim_gfp = 0,
+# define INIT_LOCKDEP                          .lockdep_recursion = 0,
        unsigned int                    lockdep_recursion;
-       if (unlikely(current->lockdep_recursion))
-       current->lockdep_recursion = 1;
-       current->lockdep_recursion = 0;
-        * context checking code. This tests GFP_FS recursion (a lock taken
----------

> 
> The new code has it in fs_reclaim_acquire/release to the same effect, if
> __GFP_NOMEMALLOC, we'll not acquire/release the lock.

Excuse me, but I can't catch.
We currently acquire/release __fs_reclaim_map if __GFP_NOMEMALLOC.

----------
+static bool __need_fs_reclaim(gfp_t gfp_mask)
+{
(...snipped...)
+       /* this guy won't enter reclaim */
+       if ((current->flags & PF_MEMALLOC) && !(gfp_mask & __GFP_NOMEMALLOC))
+               return false;
(...snipped...)
+}
----------

> 
> 
> > Since __kmalloc_reserve() from __alloc_skb() adds
> > __GFP_NOMEMALLOC | __GFP_NOWARN to gfp_mask, __need_fs_reclaim() is
> > failing to return false despite PF_MEMALLOC context (and resulted in
> > lockdep warning).
> 
> But that's correct right, __GFP_NOMEMALLOC should negate PF_MEMALLOC.
> That's what the name says.

__GFP_NOMEMALLOC negates PF_MEMALLOC regarding what watermark that allocation
request should use.

----------
static inline int __gfp_pfmemalloc_flags(gfp_t gfp_mask)
{
        if (unlikely(gfp_mask & __GFP_NOMEMALLOC))
                return 0;
        if (gfp_mask & __GFP_MEMALLOC)
                return ALLOC_NO_WATERMARKS;
        if (in_serving_softirq() && (current->flags & PF_MEMALLOC))
                return ALLOC_NO_WATERMARKS;
        if (!in_interrupt()) {
                if (current->flags & PF_MEMALLOC)
                        return ALLOC_NO_WATERMARKS;
                else if (oom_reserves_allowed(current))
                        return ALLOC_OOM;
        }

        return 0;
}
----------

But at the same time, PF_MEMALLOC negates __GFP_DIRECT_RECLAIM.

----------
        /* Attempt with potentially adjusted zonelist and alloc_flags */
        page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
        if (page)
                goto got_pg;

        /* Caller is not willing to reclaim, we can't balance anything */
        if (!can_direct_reclaim)
                goto nopage;

        /* Avoid recursion of direct reclaim */
        if (current->flags & PF_MEMALLOC)
                goto nopage;

        /* Try direct reclaim and then allocating */
        page = __alloc_pages_direct_reclaim(gfp_mask, order, alloc_flags, ac,
                                                        &did_some_progress);
        if (page)
                goto got_pg;

        /* Try direct compaction and then allocating */
        page = __alloc_pages_direct_compact(gfp_mask, order, alloc_flags, ac,
                                        compact_priority, &compact_result);
        if (page)
                goto got_pg;

        /* Do not loop if specifically requested */
        if (gfp_mask & __GFP_NORETRY)
                goto nopage;
----------

Then, how can fs_reclaim contribute to deadlock?

> 
> > Since there was no PF_MEMALLOC safeguard as of cf40bd16fdad42c0, checking
> > __GFP_NOMEMALLOC might make sense. But since this safeguard was added by
> > commit 341ce06f69abfafa ("page allocator: calculate the alloc_flags for
> > allocation only once"), checking __GFP_NOMEMALLOC no longer makes sense.
> > Thus, let's remove __GFP_NOMEMALLOC check and allow __need_fs_reclaim() to
> > return false.
> 
> This does not in fact explain what's going on, it just points to
> 'random' patches.
> 
> Are you talking about this:
> 
> +       /* Avoid recursion of direct reclaim */
> +       if (p->flags & PF_MEMALLOC)
> +               goto nopage;
> 
> bit?

Yes.

> 
> > Reported-by: Dave Jones <davej@codemonkey.org.uk>
> > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Cc: Peter Zijlstra <peterz@infradead.org>
> > Cc: Nick Piggin <npiggin@gmail.com>
> > ---
> >  mm/page_alloc.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 76c9688..7804b0e 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3583,7 +3583,7 @@ static bool __need_fs_reclaim(gfp_t gfp_mask)
> >  		return false;
> >  
> >  	/* this guy won't enter reclaim */
> > -	if ((current->flags & PF_MEMALLOC) && !(gfp_mask & __GFP_NOMEMALLOC))
> > +	if (current->flags & PF_MEMALLOC)
> >  		return false;
> 
> I'm _really_ uncomfortable doing that. Esp. without a solid explanation
> of how this raelly can't possibly lead to trouble. Which the above semi
> incoherent rambling is not.
> 
> Your backtrace shows the btrfs shrinker doing an allocation, that's the
> exact kind of thing we need to be extremely careful with.
> 

If btrfs is already holding some lock (and thus __GFP_FS is not safe),
that lock must be printed at

  2 locks held by sshd/24800:
   #0:  (sk_lock-AF_INET6){+.+.}, at: [<000000001a069652>] tcp_sendmsg+0x19/0x40
   #1:  (fs_reclaim){+.+.}, at: [<0000000084f438c2>] fs_reclaim_acquire.part.102+0x5/0x30

doesn't it? But sk_lock-AF_INET6 is not a FS lock, and fs_reclaim does not
actually lock something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
