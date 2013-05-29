Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id AA0456B0099
	for <linux-mm@kvack.org>; Wed, 29 May 2013 00:15:37 -0400 (EDT)
Received: by mail-la0-f48.google.com with SMTP id fs12so8045667lab.7
        for <linux-mm@kvack.org>; Tue, 28 May 2013 21:15:35 -0700 (PDT)
Message-ID: <51A580E0.10300@gmail.com>
Date: Wed, 29 May 2013 08:15:28 +0400
From: Max Filippov <jcmvbkbc@gmail.com>
MIME-Version: 1.0
Subject: Re: TLB and PTE coherency during munmap
References: <CAMo8BfL4QfJrfejNKmBDhAVdmE=_Ys6MVUH5Xa3w_mU41hwx0A@mail.gmail.com> <CAHkRjk4ZNwZvf_Cv+HqfMManodCkEpCPdZokPQ68z3nVG8-+wg@mail.gmail.com>
In-Reply-To: <CAHkRjk4ZNwZvf_Cv+HqfMManodCkEpCPdZokPQ68z3nVG8-+wg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm@kvack.org, linux-xtensa@linux-xtensa.org, Chris Zankel <chris@zankel.net>, Marc Gauthier <Marc.Gauthier@tensilica.com>

Hi Catalin,

On Tue, May 28, 2013 at 6:35 PM, Catalin Marinas <catalin.marinas@arm.com> wrote:
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

So, looks like most architectures in the UP configuration should have
this issue (unless they flush TLB in the switch_mm, even when switching
to the same mm):

		tlb_remove_tlb_entry	__tlb_remove_tlb_entry	__tlb_remove_page	__HAVE_ARCH_ENTER_LAZY_MMU_MODE		
		non-default		non-trivial		non-default		defined				
alpha
arc
arm		yes						yes
arm64		yes						yes
avr32
blackfin
c6x
cris
frv
h8300
hexagon
ia64		yes			yes			yes
Kconfig
m32r
m68k
metag
microblaze
mips
mn10300
openrisc
parisc
powerpc					yes						yes
s390		yes						yes (a)
score
sh		yes						yes (a)
sparc											yes
tile
um		yes			yes			yes
unicore32
x86											yes
xtensa

(a) __tlb_remove_page == free_page_and_swap_cache

> I think possible workarounds:
>
> 1. tlb_fast_mode() always returning 0.
> 2. add a tlb_flush_mmu(tlb) before cond_resched() in zap_pmd_range().
> 3. implement __tlb_remove_tlb_entry() on xtensa to always flush the
> tlb (which is probably costly).
> 4. drop the cond_resched() (not sure about preemptible kernels though).
>
> I would vote for 1 but let's see what the mm people say.

-- 
Thanks.
-- Max

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
