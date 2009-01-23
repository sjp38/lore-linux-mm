Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2CA9B6B0044
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 13:43:18 -0500 (EST)
Date: Fri, 23 Jan 2009 18:42:37 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] x86,mm: fix pte_free()
In-Reply-To: <1232732068.4850.0.camel@laptop>
Message-ID: <Pine.LNX.4.64.0901231832540.11130@blonde.anvils>
References: <1232728669.4826.143.camel@laptop> <1232732068.4850.0.camel@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, L-K <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Howells <dhowells@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 23 Jan 2009, Peter Zijlstra wrote:
> On Fri, 2009-01-23 at 17:37 +0100, Peter Zijlstra wrote:
> > On -rt we were seeing spurious bad page states like:
> > 
> > Bad page state in process 'firefox'
> > page:c1bc2380 flags:0x40000000 mapping:c1bc2390 mapcount:0 count:0
> > Trying to fix it up, but a reboot is needed
> > Backtrace:
> > Pid: 503, comm: firefox Not tainted 2.6.26.8-rt13 #3
> > [<c043d0f3>] ? printk+0x14/0x19
> > [<c0272d4e>] bad_page+0x4e/0x79
> > [<c0273831>] free_hot_cold_page+0x5b/0x1d3
> > [<c02739f6>] free_hot_page+0xf/0x11
> > [<c0273a18>] __free_pages+0x20/0x2b
> > [<c027d170>] __pte_alloc+0x87/0x91
> > [<c027d25e>] handle_mm_fault+0xe4/0x733
> > [<c043f680>] ? rt_mutex_down_read_trylock+0x57/0x63
> > [<c043f680>] ? rt_mutex_down_read_trylock+0x57/0x63
> > [<c0218875>] do_page_fault+0x36f/0x88a
> > 
> > This is the case where a concurrent fault already installed the PTE
> > and
> > we get to free the newly allocated one.
> > 
> > This is due to pgtable_page_ctor() doing the
> > spin_lock_init(&page->ptl)
> > which is overlaid with the {private, mapping} struct.
> > 
> > union {
> >     struct {
> >         unsigned long private;
> >         struct address_space *mapping;
> >     };
> > #if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
> >     spinlock_t ptl;
> > #endif
> >     struct kmem_cache *slab;
> >     struct page *first_page;
> > };
> > 
> > Normally the spinlock is small enough to not stomp on page->mapping,
> > but
> > PREEMPT_RT=y has huge 'spin'locks.
> > 
> > But lockdep kernels should also be able to trigger this splat, as the
> > lock tracking code grows the spinlock to cover page->mapping.
> > 
> > The obvious fix is calling pgtable_page_dtor() like the regular pte
> > free
> > path __pte_free_tlb() does.
> > 
> > It seems all architectures except x86 and nm10300 already do this, and
> > nm10300 doesn't seem to use pgtable_page_ctor(), which suggests it
> > doesn't do SMP or simply doesnt do MMU at all or something.
> > 
> > Signed-off-by: Peter Zijlstra <a.p.zijlsta@chello.nl>
> > CC: stable@kernel.org

Thanks, Peter: good catch.  That pgtable_page_dtor() had long been there
in pte_free(), then somehow got lost in one of 2.6.26's rearrangements.

Acked-by: Hugh Dickins <hugh@veritas.com>

> 
> Now one that's not obviously borken,..

And I can quite see why you voided the first version:
your mind rightly stalled on that foul "struct page *pte".
Oh well, clean that up some other time.

Hugh

> 
> ---
>  arch/x86/include/asm/pgalloc.h |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/x86/include/asm/pgalloc.h b/arch/x86/include/asm/pgalloc.h
> index cb7c151..dd14c54 100644
> --- a/arch/x86/include/asm/pgalloc.h
> +++ b/arch/x86/include/asm/pgalloc.h
> @@ -42,6 +42,7 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
>  
>  static inline void pte_free(struct mm_struct *mm, struct page *pte)
>  {
> +	pgtable_page_dtor(pte);
>  	__free_page(pte);
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
