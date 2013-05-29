Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 69C796B0096
	for <linux-mm@kvack.org>; Tue, 28 May 2013 23:23:53 -0400 (EDT)
Received: by mail-oa0-f43.google.com with SMTP id o6so10954035oag.2
        for <linux-mm@kvack.org>; Tue, 28 May 2013 20:23:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130528143459.GN724@phenom.dumpdata.com>
References: <CAMo8BfL4QfJrfejNKmBDhAVdmE=_Ys6MVUH5Xa3w_mU41hwx0A@mail.gmail.com>
	<CAMo8BfJie1Y49QeSJ+JTQb9WsYJkMMkb1BkKz2Gzy3T7V6ogHA@mail.gmail.com>
	<20130528143459.GN724@phenom.dumpdata.com>
Date: Wed, 29 May 2013 07:23:52 +0400
Message-ID: <CAMo8BfLNt07PM87eV-xT+VnLVvmxrryWw4QBX6G4p-gy1Wb70w@mail.gmail.com>
Subject: Re: TLB and PTE coherency during munmap
From: Max Filippov <jcmvbkbc@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-xtensa@linux-xtensa.org, Chris Zankel <chris@zankel.net>, Marc Gauthier <Marc.Gauthier@tensilica.com>

On Tue, May 28, 2013 at 6:34 PM, Konrad Rzeszutek Wilk
<konrad.wilk@oracle.com> wrote:
> On Sun, May 26, 2013 at 06:50:46AM +0400, Max Filippov wrote:
>> Hello arch and mm people.
>>
>> Is it intentional that threads of a process that invoked munmap syscall
>> can see TLB entries pointing to already freed pages, or it is a bug?
>>
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
> The idea behind the lazy MMU subsystem is that it does not need to flush
> the TLB all the time and allow one to do PTE manipulations in a "batch mode".
> Meaning there are stray entries - and one has to be diligient about not using them.

Yes, I got it, IOW TLB entries must either be flushed before userspace can
see them, or the underlying pages must not be freed.

> Here is the relvant comment from the Linux header:
>
> /*
>  * A facility to provide lazy MMU batching.  This allows PTE updates and
>  * page invalidations to be delayed until a call to leave lazy MMU mode
>  * is issued.  Some architectures may benefit from doing this, and it is
>  * beneficial for both shadow and direct mode hypervisors, which may batch
>  * the PTE updates which happen during this window.  Note that using this
>  * interface requires that read hazards be removed from the code.  A read
>  * hazard could result in the direct mode hypervisor case, since the actual
>  * write to the page tables may not yet have taken place, so reads though
>  * a raw PTE pointer after it has been modified are not guaranteed to be
>  * up to date.  This mode can only be entered and left under the protection of
>  * the page table locks for all page tables which may be modified.  In the UP
>  * case, this is required so that preemption is disabled, and in the SMP case,
>  * it must synchronize the delayed page table writes properly on other CPUs.
>  */
>
> This means that eventually when arch_leave_lazy_mmu_mode or
> arch_flush_lazy_mmu_mode is called, the PTE updates _should_ be flushed
> (aka, TLB flush if needed on the altered PTE entries).

Should (: But I only see powerpc, sparc and x86 defining
__HAVE_ARCH_ENTER_LAZY_MMU_MODE, so this does not apply to all
remaining arches.

-- 
Thanks.
-- Max

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
