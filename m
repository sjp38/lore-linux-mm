Date: Sat, 18 Oct 2008 03:32:58 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: fix anon_vma races
Message-ID: <20081018013258.GA3595@wotan.suse.de>
References: <20081016041033.GB10371@wotan.suse.de> <1224285222.10548.22.camel@lappy.programming.kicks-ass.net> <alpine.LFD.2.00.0810171621180.3438@nehalem.linux-foundation.org> <alpine.LFD.2.00.0810171737350.3438@nehalem.linux-foundation.org> <alpine.LFD.2.00.0810171801220.3438@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0810171801220.3438@nehalem.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 17, 2008 at 06:08:05PM -0700, Linus Torvalds wrote:
> 
> 
> On Fri, 17 Oct 2008, Linus Torvalds wrote:
> > 
> > So maybe a better patch would be as follows? It simplifies the whole thing 
> > by just always locking and unlocking the vma, whether it's newly allocated 
> > or not (and whether it then gets dropped as unnecessary or not).
> 
> Side note: it would be nicer if we had a "spin_lock_init_locked()", so 
> that we could avoid the more expensive "true lock" when doing the initial 
> allocation, but we don't. That said, the case of having to allocate a new 
> anon_vma _should_ be the rare one.

We can't do that, unfortuantely, because anon_vmas are allocated with
SLAB_DESTROY_BY_RCU. Obviously that's the easier way to solve most of
the orderings (then you just need to order store to spinlock with store
to make anon_vma visible). But no, we can't do that.

But there seem like there might be other problems here too... Hmm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
