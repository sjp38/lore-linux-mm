From: Andi Kleen <ak@suse.de>
Subject: Re: RFC: RCU protected page table walking
Date: Thu, 4 May 2006 11:31:45 +0200
References: <4458CCDC.5060607@bull.net> <Pine.LNX.4.64.0605031847190.15463@blonde.wat.veritas.com> <4459C8D0.7090609@bull.net>
In-Reply-To: <4459C8D0.7090609@bull.net>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200605041131.46254.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Cc: Hugh Dickins <hugh@veritas.com>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Zoltan.Menyhart@free.fr
List-ID: <linux-mm.kvack.org>

On Thursday 04 May 2006 11:26, Zoltan Menyhart wrote:
> Hugh Dickins wrote:
> > On Wed, 3 May 2006, Andi Kleen wrote:
> > 
> >>The page is not freed until all CPUs who had the mm mapped are flushed.
> >>See mmu_gather in asm-generic/tlb.h
> >>
> >>
> >>>Even if this security window is small, it does exist.
> >>
> >>It doesn't at least on architectures that use the generic tlbflush.h
> > 
> > 
> > Those architectures (including i386 and x86_64) which #define their
> > __pte_free_tlb etc. to tlb_remove_page are safe as is.
> 
> I cannot agree with you. Here is the generic sequence:
> 
>     tlb_remove_page(tlb, page):
>         if (tlb_fast_mode(tlb)) {
>             free_page_and_swap_cache(page);
>             return;
>         }
>         tlb->pages[tlb->nr++] = page;
>         if (tlb->nr >= FREE_PTE_NR)
>             tlb_flush_mmu(tlb, 0, 0):
> 
>                 free_pages_and_swap_cache(tlb->pages, tlb->nr); 
> 
> We set free the PTE, PMD and PUD pages either immediately or when
> tlb->pages[] is full.
> 
> What can make sure that there is no active page table walker on
> another CPU?

We don't free the pages until the other CPUs have been flushed synchronously. 
After the flush the other CPUs don't walk pages anymore. The whole thing is
batched because the synchronous flush can be pretty expensive.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
