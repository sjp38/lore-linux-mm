Date: Mon, 27 Aug 2007 14:32:21 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/1] alloc_pages(): permit get_zeroed_page(GFP_ATOMIC)
 from interrupt context
In-Reply-To: <Pine.LNX.4.64.0708271411200.6566@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0708271431030.7123@schroedinger.engr.sgi.com>
References: <200708232107.l7NL7XDt026979@imap1.linux-foundation.org>
 <Pine.LNX.4.64.0708271308380.5457@schroedinger.engr.sgi.com>
 <20070827133347.424f83a6.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0708271357220.6435@schroedinger.engr.sgi.com>
 <20070827140440.d2109ea5.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0708271411200.6566@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-mm@kvack.org, thomas.jarosch@intra2net.com, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

This issue is a result of commit 656dad312fb41ed95ef08325e9df9bece3aacbbb. 
The intend of moving tests before the check for the highpage was to catch 
some additional errors.

On Mon, 27 Aug 2007, Christoph Lameter wrote:

> On Mon, 27 Aug 2007, Andrew Morton wrote:
> 
> > __GFP_HIGHMEM is not set.
> > 
> > : 	/*
> > : 	 * clear_highpage() will use KM_USER0, so it's a bug to use __GFP_ZERO
> > : 	 * and __GFP_HIGHMEM from hard or soft interrupt context.
> > : 	 */
> > : 	VM_BUG_ON((gfp_flags & __GFP_HIGHMEM) && in_interrupt());
> > 
> > __GFP_HIGHMEM is not set
> > 
> > : 	for (i = 0; i < (1 << order); i++)
> > : 		clear_highpage(page + i);
> > 
> > kmap_atomic() goes boom.
> 
> So the page is not a highmem page. kmap does:
> 
> void *kmap(struct page *page)
> {
>         might_sleep();
>         if (!PageHighMem(page))
>                 return page_address(page);
>         return kmap_high(page);
> }
> 
> -> kmap is fine.
> 
> kmap_atomic() does:
> 
> void *kmap_atomic_prot(struct page *page, enum km_type type, pgprot_t prot)
> {
>         enum fixed_addresses idx;
>         unsigned long vaddr;
> 
>         /* even !CONFIG_PREEMPT needs this, for in_atomic in do_page_fault */
>         pagefault_disable();
> 
>         idx = type + KM_TYPE_NR*smp_processor_id();
>         BUG_ON(!pte_none(*(kmap_pte-idx)));
> 
>         if (!PageHighMem(page))
>                 return page_address(page);
> 
>         vaddr = __fix_to_virt(FIX_KMAP_BEGIN + idx);
>         set_pte(kmap_pte-idx, mk_pte(page, prot));
>         arch_flush_lazy_mmu_mode();
> 
>         return (void*) vaddr;
> }
> 
> Move the check for highmem to the beginning of the function? Why 
> should kmap_atomic fail for a non highmem page?
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
