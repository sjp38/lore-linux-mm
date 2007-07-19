Date: Thu, 19 Jul 2007 12:16:27 +0100
Subject: Re: [PATCH] Remove unnecessary smp_wmb from clear_user_highpage()
Message-ID: <20070719111626.GA5304@skynet.ie>
References: <20070718150514.GA21823@skynet.ie> <Pine.LNX.4.64.0707181645590.26413@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707181645590.26413@blonde.wat.veritas.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (18/07/07 17:45), Hugh Dickins didst pronounce:
> On Wed, 18 Jul 2007, Mel Gorman wrote:
> > 
> > At the nudging of Andrew, I was checking to see if the architecture-specific
> > implementations of alloc_zeroed_user_highpage() can be removed or not.
> 
> Ah, so that was part of the deal for getting MOVABLE in, eh ;-?
> 

heh, no. But I was touching off that area so I get to kick it while I'm
there. It's an interesting one.

> > With the exception of barriers, the differences are negligible and the main
> > memory barrier is in clear_user_highpage(). However, it's unclear why it's
> > needed. Do you mind looking at the following patch and telling me if it's
> > wrong and if so, why?
> > 
> > Thanks a lot.
> 
> I laugh when someone approaches me with a question on barriers ;)

I guess people live in hope :)

> I usually get confused and have to go ask someone else.
> 
> And I should really to leave this query to Nick: he'll be glad of the
> opportunity to post his PageUptodate memorder patches again (looking
> in my mailbox I see versions from February, but I'm pretty sure he put
> out a more compact, less scary one later on). 

Ok, I didn't look at these closely at the the time. I'll take a closer look
when/if the patches make a re-appearance. As of now, it's looking like the
barrier is needed and removing it may result in really obscure bugs with
relation to threads running on different CPUs faulting the same region.

The core of the problem I'm getting from this thread is that with the locking
as-is, the set_pte() can appear to happen before the page was zeroed so many
readers/writers on different CPUs will see a different result if they are
looking PTEs in a lockless fashion.

> He contends that the
> barrier in clear_user_highpage should not be there, but instead
> barriers (usually) needed when setting and testing PageUptodate.
> 
> Andrew and I weren't entirely convinced: I don't think we found
> him wrong, just didn't find time to think about it deeply enough,
> suspicious of a fix in search of a problem, scared by the extent
> of the first patch, put off by the usual host of __..._nolock
> variants and micro-optimizations.  It is worth another look.
> 

It is not easy to prove right or wrong. Building a test-case is not
particularly easy either.

> But setting aside PageUptodate futures...  "git blame" is handy,
> and took me to the patch from Linus appended.  I think there's
> as much need for that smp_wmb() now as there was then.  (But
> am I really _thinking_?  No, just pointing you in directions.)
> 

Good tip. For those watching, finding this commit
via git-blame needs the historical 2.6 git tree at
git://git.kernel.org/pub/scm/linux/kernel/git/tglx/history.git .

> > ===
> > 
> >     This patch removes an unnecessary write barrier from clear_user_highpage().
> >     
> >     clear_user_highpage() is called from alloc_zeroed_user_highpage() on a
> >     number of architectures and from clear_huge_page(). However, these callers
> >     are already protected by the necessary memory barriers due to spinlocks
> 
> Be careful: as Linus indicates, spinlocks on x86 act as good barriers,
> but on some architectures they guarantee no more than is strictly
> necessary.  alpha, powerpc and ia64 spring to my mind as particularly
> difficult ordering-wise, but I bet there are others too.
> 

There was a good reminder of the rules here and it's a bit clearer why
it's possible for the page clear to apparently happen after the set_pte.

> >     in the fault path and the page should not be visible on other CPUs anyway
> 
> The page may not be intentionally visible on another CPU yet.  But imagine
> interesting stale data in the page being cleared, and another thread
> peeking racily at unfaulted areas, hoping to catch sight of that data.
> 

I'm going to attempt to construct a test case to see if it's possible to
reproduce without that barrier in place. I'll contact the PowerPC people
to know if they've done this already.

> >     making the barrier unnecessary. A hint of lack of necessity is that there
> >     does not appear to be a read barrier anywhere for this zeroed page.
> 
> Yes, I think Nick was similarly suspicious of a wmb without an rmb; but
> Linus is _very_ barrier-savvy, so we might want to ask him about it (CC'ed).
> 

Thanks

> >     
> >     The sequence for the first use of alloc_zeroed_user_highpage()
> >     looks like;
> >     
> >     pte_unmap_unlock()
> >     alloc_zeroed_user_highpage()
> >     pte_offset_map_lock()
> >     
> >     The second is
> >     
> >     pte_unmap()	(usually nothing but sometimes a barrier()
> >     alloc_zeroed_user_highpage()
> >     pte_offset_map_lock()
> >     
> >     The two sequences with the use of locking should already have sufficient
> >     barriers.
> 
> To be honest, I've not thought about what you've written there:
> assumed perhaps wrongly that my remarks above invalidate your logic.
> 

Yeah, my logic is invalidated to the extent that removing this barrier
is almost certainly wrong but very difficult to reproduce.

> >     
> >     By removing this write barrier, IA64 could use the default implementation
> >     of alloc_zeroed_user_highpage() instead of a custom version which appears
> >     to do nothing but avoid calling smp_wmb(). Once that is done, there is
> >     little reason to have architecture-specific alloc_zeroed_user_highpage()
> >     helpers as it would be redundant.
> 
> Hmm, I'd expect IA64 to be one of the ones that really needs that smp_wmb()
> anyway.
> 

I'll have to check. They avoid the memory barrier at the moment so we
might as well check that it's being done on purpose.

> > 
> > diff --git a/include/linux/highmem.h b/include/linux/highmem.h
> > index 12c5e4e..ace5a32 100644
> > --- a/include/linux/highmem.h
> > +++ b/include/linux/highmem.h
> > @@ -68,8 +68,6 @@ static inline void clear_user_highpage(struct page *page, unsigned long vaddr)
> >  	void *addr = kmap_atomic(page, KM_USER0);
> >  	clear_user_page(addr, vaddr, page);
> >  	kunmap_atomic(addr, KM_USER0);
> > -	/* Make sure this page is cleared on other CPU's too before using it */
> > -	smp_wmb();
> >  }
> >  
> >  #ifndef __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
> 
> commit 538ce05c0ef4055cf29a92a4abcdf139d180a0f9
> Author: Linus Torvalds <torvalds@ppc970.osdl.org>
> Date:   Wed Oct 13 21:00:06 2004 -0700
> 
>     Fix threaded user page write memory ordering
>     
>     Make sure we order the writes to a newly created page
>     with the page table update that potentially exposes the
>     page to another CPU.
>     
>     This is a no-op on any architecture where getting the
>     page table spinlock will already do the ordering (notably
>     x86), but other architectures can care.
> 
> diff --git a/include/linux/highmem.h b/include/linux/highmem.h
> index 232d8fd..7153aef 100644
> --- a/include/linux/highmem.h
> +++ b/include/linux/highmem.h
> @@ -40,6 +40,8 @@ static inline void clear_user_highpage(struct page *page, unsigned long vaddr)
>  	void *addr = kmap_atomic(page, KM_USER0);
>  	clear_user_page(addr, vaddr, page);
>  	kunmap_atomic(addr, KM_USER0);
> +	/* Make sure this page is cleared on other CPU's too before using it */
> +	smp_wmb();
>  }
>  
>  static inline void clear_highpage(struct page *page)
> @@ -73,6 +75,8 @@ static inline void copy_user_highpage(struct page *to, struct page *from, unsign
>  	copy_user_page(vto, vfrom, vaddr, to);
>  	kunmap_atomic(vfrom, KM_USER0);
>  	kunmap_atomic(vto, KM_USER1);
> +	/* Make sure this page is cleared on other CPU's too before using it */
> +	smp_wmb();
>  }
>  
>  static inline void copy_highpage(struct page *to, struct page *from)

-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
