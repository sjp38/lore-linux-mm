Message-ID: <4459C708.4030109@bull.net>
Date: Thu, 04 May 2006 11:19:04 +0200
From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
MIME-Version: 1.0
Subject: Re: RFC: RCU protected page table walking
References: <4458CCDC.5060607@bull.net> <200605031846.51657.ak@suse.de>
In-Reply-To: <200605031846.51657.ak@suse.de>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-mm@kvack.org, Zoltan.Menyhart@free.fr
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> s page table walking is not atomic, not even on an x86.
> 
>>Let's consider the following scenario:
>>
>>
>>CPU #1:                      CPU #2:                 CPU #3
>>
>>Starts walking
>>Got the ph. addr. of page Y
>>in internal reg. X
>>                             free_pgtables():
>>                             sets free page Y
> 
> 
> The page is not freed until all CPUs who had the mm mapped are flushed.
> See mmu_gather in asm-generic/tlb.h

Page table walking is in ph. mode, e.g. a PGD access is not sensitive to
a TLB purge.

Here is the (simplified) IA64 implementation:

        free_pgtables(&tlb,...):
            free_pgd_range(tlb,...):
                free_pud_range(*tlb,...):
                    free_pmd_range(tlb,...):
                        free_pte_range(tlb,...):
                            pmd_clear(pmd);
                            pte_free_tlb(tlb, page):
                                __pte_free_tlb(tlb, ptep):
/* --> */                           pte_free(pte);
                        pud_clear(pud);
                        pmd_free_tlb(tlb, pmd):
/* --> */                   pmd_free(pmd);
                    pgd_clear(pgd);
                    pud_free_tlb(tlb, pud):
                        __pud_free_tlb(tlb, pudp):
/* --> */                   pud_free(pud);
                flush_tlb_pgtables((*tlb)->mm,...);

Or if you like, from asm-generic/tlb.h:

	tlb_remove_page(tlb, page):
	    if (tlb_fast_mode(tlb)) {
	        free_page_and_swap_cache(page);
	        return;
	    }
	    tlb->pages[tlb->nr++] = page;
	    if (tlb->nr >= FREE_PTE_NR)
	        tlb_flush_mmu(tlb, 0, 0):

	            free_pages_and_swap_cache(tlb->pages, tlb->nr);

As you can see, we do not care for the the eventual page table walkers.

>>As CPU #1 is still keeping the same ph. address, it fetches an item
>>from a page that is no more its page.
>>
>>Even if this security window is small, it does exist.
> 
> 
> It doesn't at least on architectures that use the generic tlbflush.h

As I showed above, the generic code is unaware of the other CPU's activity.

The problem is:
there is no requirement when we can release a directory page.

What I propose is a way to make sure that the page table walkers will be
able to finish their walks in safety; we release a directory page when
no more walker can reference the page.

Thanks,

Zoltan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
