Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DA4F16B00D4
	for <linux-mm@kvack.org>; Mon,  5 Jan 2009 21:23:55 -0500 (EST)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n062Nuo9004610
	for <linux-mm@kvack.org>; Mon, 5 Jan 2009 21:23:56 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n062NpRT170018
	for <linux-mm@kvack.org>; Mon, 5 Jan 2009 21:23:53 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n063O2pi016585
	for <linux-mm@kvack.org>; Mon, 5 Jan 2009 22:24:02 -0500
Date: Mon, 5 Jan 2009 18:23:52 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [patch] mm: fix lockless pagecache reordering bug (was Re:
	BUG: soft lockup - is this XFS problem?)
Message-ID: <20090106022352.GY6959@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20090105064838.GA5209@wotan.suse.de> <49623384.2070801@aon.at> <20090105164135.GC32675@wotan.suse.de> <alpine.LFD.2.00.0901050859430.3057@localhost.localdomain> <20090105180008.GE32675@wotan.suse.de> <alpine.LFD.2.00.0901051027011.3057@localhost.localdomain> <20090105201258.GN6959@linux.vnet.ibm.com> <alpine.LFD.2.00.0901051224110.3057@localhost.localdomain> <20090105215727.GQ6959@linux.vnet.ibm.com> <20090106020550.GA819@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090106020550.GA819@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Klotz <peter.klotz@aon.at>, stable@kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Christoph Hellwig <hch@infradead.org>, Roman Kononov <kernel@kononov.ftml.net>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 06, 2009 at 03:05:50AM +0100, Nick Piggin wrote:
> On Mon, Jan 05, 2009 at 01:57:27PM -0800, Paul E. McKenney wrote:
> > On Mon, Jan 05, 2009 at 12:39:14PM -0800, Linus Torvalds wrote:
> > > 
> > > 
> > > On Mon, 5 Jan 2009, Paul E. McKenney wrote:
> > > > 
> > > > My guess is that Nick believes that the value in *pslot cannot change
> > > > in such as way as to cause radix_tree_is_indirect_ptr()'s return value
> > > > to change within a given RCU grace period, and that Linus disagrees.
> > > 
> > > Oh, it's entirely possible that there are some lifetime rules or others 
> > > that make it impossible for things to go from "not indirect" -> 
> > > "indirect". So if that was Nick's point, then I'm not "disagreeing" per 
> > > se.
> > > 
> > > What I'm disagreeing about is that Nick apparently thinks that this is all 
> > > subtle code, and as a result we should add barriers in some very 
> > > non-obvious places.
> > > 
> > > While _I_ think that the problem isn't properly solved by barriers, but by 
> > > just making the code less subtle. If the barrier only exists because of 
> > > the reload issue, then the obvious solution - to me - is to just use what 
> > > is already the proper accessor function that forces a nice reload. That 
> > > way the compiler is forced to create code that does what the source 
> > > clearly means it to do, regardless of any barriers at all.
> > > 
> > > Barriers in general should be the _last_ thing added. And if they are 
> > > added, they should be added as deeply in the call-chain as possible, so 
> > > that we don't need to add them in multiple call-sites. Again, using the 
> > > rcu_dereference() approach seems to solve that issue too - rather than add 
> > > three barriers in three different places, we just add the proper 
> > > dereference in _one_ place.
> > 
> > I don't have any argument with this line of reasoning, and am myself a bit
> > puzzled as to why rcu_dereference() isn't the right tool for Nick's job.
> > Then again, I don't claim to fully understand what he is trying to do.
> 
> OK, granted I do need the ACCESS_ONCE. It is loading a pointer who's target
> can be changed concurrently with the rcu algorithm. The rcu_derefernce
> thing kind of set me thinking down the wrong track, because the object of the
> pointer it loads is not RCU protected and doesn't need the memory barrier
> (on alpha).
> 
> But... RCU radix tree is not only used for the pagecache, so it's probably not
> worth complicating things to seperate out those two cases. rcu_dereference
> might be the best fit.

Works for me!

> > > > Whatever the answer, I would argue for -at- -least- a comment explaining
> > > > why it is safe.  I am not seeing the objection to rcu_dereference(), but
> > > > I must confess that it has been awhile since I have looked closely at
> > > > the radix_tree code.  :-/
> > > 
> > > And I'm actually suprised that gcc can generate the problematic code in 
> > > the first place. I'd expect that a "atomic_add_unless()" would always be 
> > > at LEAST a compiler barrier, even if it isn't necessarily a CPU memory 
> > > barrier.
> > > 
> > > But because we inline it, and because we allow gcc to see that it doesn't 
> > > do anything if it gets just the right value from memory, I guess gcc ends 
> > > up able to change the "for()" loop so that the first iteration can exit 
> > > specially, and then for that case (and no other case) it can cache 
> > > variables over the whole atomic_add_unless().
> > > 
> > > Again, that's very fragile. The fact that Documentation/atomic_ops.txt 
> > > says that the failure case doesn't contain any barriers is really _meant_ 
> > > to be about the architecture-specific CPU barriers, not so much about 
> > > something as simple as a compiler re-ordering. 
> > > 
> > > So while I think that we should use rcu_dereference() (regardless of any 
> > > other issues), I _also_ think that part of the problem really is the 
> > > excessive subtlety in the whole code, and the (obviously very surprising) 
> > > fact that gcc could end up caching an unrelated memory load across that 
> > > whole atomic op.
> > > 
> > > Maybe we should make atomics always imply a compiler barrier, even when 
> > > they do not imply a memory barrier. The one exception would be the 
> > > (special) case of "atomic_read()/atomic_set()", which don't really do any 
> > > kind of complex operation at all, and where we really do want the compiler 
> > > to be able to coalesce multiple atomic_reads() to a single one.
> > > 
> > > In contrast, there's no sense in allowing the compiler to coalesce a 
> > > "atomic_add_unless()" with anything else. Making it a compiler barrier 
> > > (possibly by uninlining it, or just adding a barrier to it) would also 
> > > have avoided the whole subtle case - which is always a good thing.
> > 
> > That makes a lot of sense to me!
> 
> It would have avoided one problem (the same one my patch did). But it
> doesn't solve the problem of the missing ACCESS_ONCE allowing the
> pointer to be reloaded from the slot pointer.

Agreed.

> Sticking an rcu_dereference in radix_tree_deref_slot seems to fix the
> assembly for me too, I grafted the changelog onto that. Linus probably
> you are using -Os?
> 
> --
> Subject: mm lockless pagecache barrier fix
> 
> An XFS workload showed up a bug in the lockless pagecache patch. Basically it
> would go into an "infinite" loop, although it would sometimes be able to break
> out of the loop! The reason is a missing compiler barrier in the "increment
> reference count unless it was zero" case of the lockless pagecache protocol in
> the gang lookup functions.
> 
> This would cause the compiler to use a cached value of struct page pointer to
> retry the operation with, rather than reload it. So the page might have been
> removed from pagecache and freed (refcount==0) but the lookup would not correctly
> notice the page is no longer in pagecache, and keep attempting to increment the
> refcount and failing, until the page gets reallocated for something else. This
> isn't a data corruption because the condition will be detected if the page has
> been reallocated. However it can result in a lockup. 
> 
> Linus points out that ACCESS_ONCE is also required in that pointer load, even
> if it's absence is not causing a bug on our particular build. The most general
> way to solve this is just to put an rcu_dereference in radix_tree_deref_slot.
> 
> Assembly of find_get_pages,
> before:
> .L220:
>         movq    (%rbx), %rax    #* ivtmp.1162, tmp82
>         movq    (%rax), %rdi    #, prephitmp.1149
> .L218:
>         testb   $1, %dil        #, prephitmp.1149
>         jne     .L217   #,
>         testq   %rdi, %rdi      # prephitmp.1149
>         je      .L203   #,
>         cmpq    $-1, %rdi       #, prephitmp.1149
>         je      .L217   #,
>         movl    8(%rdi), %esi   # <variable>._count.counter, c
>         testl   %esi, %esi      # c
>         je      .L218   #,
> 
> after:
> .L212:
>         movq    (%rbx), %rax    #* ivtmp.1109, tmp81
>         movq    (%rax), %rdi    #, ret
>         testb   $1, %dil        #, ret
>         jne     .L211   #,
>         testq   %rdi, %rdi      # ret
>         je      .L197   #,
>         cmpq    $-1, %rdi       #, ret
>         je      .L211   #,
>         movl    8(%rdi), %esi   # <variable>._count.counter, c
>         testl   %esi, %esi      # c
>         je      .L212   #,
> 
> (notice the obvious infinite loop in the first example, if page->count remains 0)

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> Signed-off-by: Nick Piggin <npiggin@suse.de>
> ---
>  include/linux/radix-tree.h |    2 +-
>  mm/filemap.c               |   23 ++++++++++++++++++++---
>  2 files changed, 21 insertions(+), 4 deletions(-)
> 
> Index: linux-2.6/include/linux/radix-tree.h
> ===================================================================
> --- linux-2.6.orig/include/linux/radix-tree.h
> +++ linux-2.6/include/linux/radix-tree.h
> @@ -136,7 +136,7 @@ do {									\
>   */
>  static inline void *radix_tree_deref_slot(void **pslot)
>  {
> -	void *ret = *pslot;
> +	void *ret = rcu_dereference(*pslot);
>  	if (unlikely(radix_tree_is_indirect_ptr(ret)))
>  		ret = RADIX_TREE_RETRY;
>  	return ret;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
