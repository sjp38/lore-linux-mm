Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6F99A6B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 08:55:57 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id r6so6977970pfk.9
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 05:55:57 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v8si634370pgs.639.2018.01.29.05.55.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Jan 2018 05:55:55 -0800 (PST)
Date: Mon, 29 Jan 2018 14:55:47 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [4.15-rc9] fs_reclaim lockdep trace
Message-ID: <20180129135547.GR2269@hirez.programming.kicks-ass.net>
References: <CA+55aFx6w9+C-WM9=xqsmnrMwKzDHeCwVNR5Lbnc9By00b6dzw@mail.gmail.com>
 <d726458d-3d3b-5580-ddfc-2914cbf756ba@I-love.SAKURA.ne.jp>
 <7771dd55-2655-d3a9-80ee-24c9ada7dbbe@I-love.SAKURA.ne.jp>
 <8f1c776d-b791-e0b9-1e5c-62b03dcd1d74@I-love.SAKURA.ne.jp>
 <20180129102746.GQ2269@hirez.programming.kicks-ass.net>
 <201801292047.EHC05241.OHSQOJOVtFMFLF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201801292047.EHC05241.OHSQOJOVtFMFLF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: torvalds@linux-foundation.org, davej@codemonkey.org.uk, npiggin@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, mhocko@kernel.org

On Mon, Jan 29, 2018 at 08:47:20PM +0900, Tetsuo Handa wrote:
> Peter Zijlstra wrote:
> > On Sun, Jan 28, 2018 at 02:55:28PM +0900, Tetsuo Handa wrote:
> > > This warning seems to be caused by commit d92a8cfcb37ecd13
> > > ("locking/lockdep: Rework FS_RECLAIM annotation") which moved the
> > > location of
> > > 
> > >   /* this guy won't enter reclaim */
> > >   if ((current->flags & PF_MEMALLOC) && !(gfp_mask & __GFP_NOMEMALLOC))
> > >           return false;
> > > 
> > > check added by commit cf40bd16fdad42c0 ("lockdep: annotate reclaim context
> > > (__GFP_NOFS)").
> > 
> > I'm not entirly sure I get what you mean here. How did I move it? It was
> > part of lockdep_trace_alloc(), if __GFP_NOMEMALLOC was set, it would not
> > mark the lock as held.
> 
> d92a8cfcb37ecd13 replaced lockdep_set_current_reclaim_state() with
> fs_reclaim_acquire(), and removed current->lockdep_recursion handling.
> 
> ----------
> # git show d92a8cfcb37ecd13 | grep recursion
> -# define INIT_LOCKDEP                          .lockdep_recursion = 0, .lockdep_reclaim_gfp = 0,
> +# define INIT_LOCKDEP                          .lockdep_recursion = 0,
>         unsigned int                    lockdep_recursion;
> -       if (unlikely(current->lockdep_recursion))
> -       current->lockdep_recursion = 1;
> -       current->lockdep_recursion = 0;
> -        * context checking code. This tests GFP_FS recursion (a lock taken
> ----------

That should not matter at all. The only case that would matter for is if
lockdep itself would ever call into lockdep again. Not something that
happens here.

> > The new code has it in fs_reclaim_acquire/release to the same effect, if
> > __GFP_NOMEMALLOC, we'll not acquire/release the lock.
> 
> Excuse me, but I can't catch.
> We currently acquire/release __fs_reclaim_map if __GFP_NOMEMALLOC.

Right, got the case inverted, same difference though. Before we'd do
mark_held_lock(), now we do acquire/release under the same conditions.

> > > Since __kmalloc_reserve() from __alloc_skb() adds
> > > __GFP_NOMEMALLOC | __GFP_NOWARN to gfp_mask, __need_fs_reclaim() is
> > > failing to return false despite PF_MEMALLOC context (and resulted in
> > > lockdep warning).
> > 
> > But that's correct right, __GFP_NOMEMALLOC should negate PF_MEMALLOC.
> > That's what the name says.
> 
> __GFP_NOMEMALLOC negates PF_MEMALLOC regarding what watermark that allocation
> request should use.

Right.

> But at the same time, PF_MEMALLOC negates __GFP_DIRECT_RECLAIM.

Ah indeed.

> Then, how can fs_reclaim contribute to deadlock?

Not sure it can. But if we're going to allow this, it needs to come with
a clear description on why. Not a few clues to a puzzle.

Now, even if its not strictly a deadlock, there is something to be said
for flagging GFP_FS allocs that lead to nested GFP_FS allocs, do we ever
want to allow that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
