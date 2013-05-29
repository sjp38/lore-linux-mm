Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 84C6B6B00AF
	for <linux-mm@kvack.org>; Wed, 29 May 2013 08:00:51 -0400 (EDT)
Message-ID: <51A5EDE2.2040603@synopsys.com>
Date: Wed, 29 May 2013 17:30:34 +0530
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
MIME-Version: 1.0
Subject: Re: TLB and PTE coherency during munmap
References: <CAMo8BfL4QfJrfejNKmBDhAVdmE=_Ys6MVUH5Xa3w_mU41hwx0A@mail.gmail.com> <CAHkRjk4ZNwZvf_Cv+HqfMManodCkEpCPdZokPQ68z3nVG8-+wg@mail.gmail.com>
In-Reply-To: <CAHkRjk4ZNwZvf_Cv+HqfMManodCkEpCPdZokPQ68z3nVG8-+wg@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Max Filippov <jcmvbkbc@gmail.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm@kvack.org, linux-xtensa@linux-xtensa.org, Chris Zankel <chris@zankel.net>, Marc
 Gauthier <Marc.Gauthier@tensilica.com>

[Resending with fixed linux-mm address]

On 05/28/2013 08:05 PM, Catalin Marinas wrote:
> Max,
> 
> On 26 May 2013 03:42, Max Filippov <jcmvbkbc@gmail.com> wrote:
>> Hello arch and mm people.
>>
>> Is it intentional that threads of a process that invoked munmap syscall
>> can see TLB entries pointing to already freed pages, or it is a bug?
> 
> If it happens, this would be a bug. It means that a process can access
> a physical page that has been allocated to something else, possibly
> kernel data.
> 
>> I'm talking about zap_pmd_range and zap_pte_range:
>>
>>       zap_pmd_range
>>         zap_pte_range
>>           arch_enter_lazy_mmu_mode
>>             ptep_get_and_clear_full
>>             tlb_remove_tlb_entry
>>             __tlb_remove_page
>>           arch_leave_lazy_mmu_mode
>>         cond_resched
>>
>> With the default arch_{enter,leave}_lazy_mmu_mode, tlb_remove_tlb_entry
>> and __tlb_remove_page there is a loop in the zap_pte_range that clears
>> PTEs and frees corresponding pages, but doesn't flush TLB, and
>> surrounding loop in the zap_pmd_range that calls cond_resched. If a thread
>> of the same process gets scheduled then it is able to see TLB entries
>> pointing to already freed physical pages.
> 
> It looks to me like cond_resched() here introduces a possible bug but
> it depends on the actual arch code, especially the
> __tlb_remove_tlb_entry() function. On ARM we record the range in
> tlb_remove_tlb_entry() and queue the pages to be removed in
> __tlb_remove_page(). It pretty much acts like tlb_fast_mode() == 0
> even for the UP case (which is also needed for hardware speculative
> TLB loads). The tlb_finish_mmu() takes care of whatever pages are left
> to be freed.
> 
> With a dummy __tlb_remove_tlb_entry() and tlb_fast_mode() == 1,
> cond_resched() in zap_pmd_range() would cause problems.
> 
> I think possible workarounds:
> 
> 1. tlb_fast_mode() always returning 0.

This might add needless page free batching logic so not very lucrative.

> 2. add a tlb_flush_mmu(tlb) before cond_resched() in zap_pmd_range().

For !fullmm flushes it might be no-op on some arches (atleast on ARC) as we use
tlb_end_vma() to do TLB range flush. And flushing the entire TLB would be
excessive though.

Actually zap_pte_range() already has logic to flush the TLB range (if batching
runs out of space). Can we re-use that infrastructure to make sure zap_pte_range()
does it's share of TLB flushing before returning and going into cond_resched().

However with that, we need to prevent tlb_end_vma()/tlb_finish_mmu() from
duplicating the range flush - which can be done by clearing tlb->need_flush.

Now simplistically this will cause even the fullmm flushes (simple ASID increment
on ARC/ARM..) to become TLB walks to flush the individual entries so we can do
this for only for !fullmm, assuming that cond_resched() can potentially cause an
exit'ing task's thread to be scheduled in and reuse the entries.

Let me go off cook a patch to see if this might work.

-Vineet





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
