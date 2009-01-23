Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 86F916B006A
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 12:34:40 -0500 (EST)
Date: Fri, 23 Jan 2009 18:34:21 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] x86,mm: fix pte_free()
Message-ID: <20090123173421.GA30980@elte.hu>
References: <1232728669.4826.143.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1232728669.4826.143.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, L-K <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Howells <dhowells@redhat.com>
List-ID: <linux-mm.kvack.org>


* Peter Zijlstra <peterz@infradead.org> wrote:

> On -rt we were seeing spurious bad page states like:
> 
> Bad page state in process 'firefox'
> page:c1bc2380 flags:0x40000000 mapping:c1bc2390 mapcount:0 count:0
> Trying to fix it up, but a reboot is needed
> Backtrace:
> Pid: 503, comm: firefox Not tainted 2.6.26.8-rt13 #3
> [<c043d0f3>] ? printk+0x14/0x19
> [<c0272d4e>] bad_page+0x4e/0x79
> [<c0273831>] free_hot_cold_page+0x5b/0x1d3
> [<c02739f6>] free_hot_page+0xf/0x11
> [<c0273a18>] __free_pages+0x20/0x2b
> [<c027d170>] __pte_alloc+0x87/0x91
> [<c027d25e>] handle_mm_fault+0xe4/0x733
> [<c043f680>] ? rt_mutex_down_read_trylock+0x57/0x63
> [<c043f680>] ? rt_mutex_down_read_trylock+0x57/0x63
> [<c0218875>] do_page_fault+0x36f/0x88a
> 
> This is the case where a concurrent fault already installed the PTE and
> we get to free the newly allocated one.
> 
> This is due to pgtable_page_ctor() doing the spin_lock_init(&page->ptl)
> which is overlaid with the {private, mapping} struct.
> 
> union {
>     struct {
>         unsigned long private;
>         struct address_space *mapping;
>     };
> #if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
>     spinlock_t ptl;
> #endif
>     struct kmem_cache *slab;
>     struct page *first_page;
> };
> 
> Normally the spinlock is small enough to not stomp on page->mapping, but
> PREEMPT_RT=y has huge 'spin'locks.
> 
> But lockdep kernels should also be able to trigger this splat, as the
> lock tracking code grows the spinlock to cover page->mapping.
> 
> The obvious fix is calling pgtable_page_dtor() like the regular pte free
> path __pte_free_tlb() does.
> 
> It seems all architectures except x86 and nm10300 already do this, and
> nm10300 doesn't seem to use pgtable_page_ctor(), which suggests it
> doesn't do SMP or simply doesnt do MMU at all or something.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlsta@chello.nl>
> CC: stable@kernel.org
> ---
>  arch/x86/include/asm/pgalloc.h |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/x86/include/asm/pgalloc.h b/arch/x86/include/asm/pgalloc.h
> index cb7c151..b99023c 100644
> --- a/arch/x86/include/asm/pgalloc.h
> +++ b/arch/x86/include/asm/pgalloc.h
> @@ -42,6 +42,7 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
>  
>  static inline void pte_free(struct mm_struct *mm, struct page *pte)
>  {
> +	pgtable_page_dtor();

i suspect on lockdep we dont see this in practice because it initializes 
things to NULL, which hides the issue. On -rt we initialize list heads 
there which brings up the wrong warning in the page free logic.

So i agree with the fix, but the patch does not look right: shouldnt that 
be pgtable_page_dtor(pte), so that we get ->mapping cleared via 
pte_lock_deinit()? (which i guess your intention was here - this probably 
wont even build)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
