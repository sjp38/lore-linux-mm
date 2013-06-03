Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 4E7E96B0068
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 05:16:48 -0400 (EDT)
Received: by mail-oa0-f43.google.com with SMTP id o6so893365oag.16
        for <linux-mm@kvack.org>; Mon, 03 Jun 2013 02:16:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAMo8BfJt3dnx8NYT66dKfkLyjwPzHAhe0Rs21+Q-pG6OXA2GLA@mail.gmail.com>
References: <CAMo8BfL4QfJrfejNKmBDhAVdmE=_Ys6MVUH5Xa3w_mU41hwx0A@mail.gmail.com>
	<CAHkRjk4ZNwZvf_Cv+HqfMManodCkEpCPdZokPQ68z3nVG8-+wg@mail.gmail.com>
	<51A580E0.10300@gmail.com>
	<20130529101533.GF17767@MacBook-Pro.local>
	<CAMo8BfJt3dnx8NYT66dKfkLyjwPzHAhe0Rs21+Q-pG6OXA2GLA@mail.gmail.com>
Date: Mon, 3 Jun 2013 13:16:47 +0400
Message-ID: <CAMo8BfKQTKCTuMFfhAhAe3OeeT47MZALW9NnH073VC+EGiUUTQ@mail.gmail.com>
Subject: Re: TLB and PTE coherency during munmap
From: Max Filippov <jcmvbkbc@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, Chris Zankel <chris@zankel.net>, Marc Gauthier <Marc.Gauthier@tensilica.com>

On Fri, May 31, 2013 at 5:26 AM, Max Filippov <jcmvbkbc@gmail.com> wrote:
> On Wed, May 29, 2013 at 2:15 PM, Catalin Marinas
> <catalin.marinas@arm.com> wrote:
>> On Wed, May 29, 2013 at 05:15:28AM +0100, Max Filippov wrote:
>>> On Tue, May 28, 2013 at 6:35 PM, Catalin Marinas <catalin.marinas@arm.com> wrote:
>>> > On 26 May 2013 03:42, Max Filippov <jcmvbkbc@gmail.com> wrote:
>>> >> Is it intentional that threads of a process that invoked munmap syscall
>>> >> can see TLB entries pointing to already freed pages, or it is a bug?
>>> >
>>> > If it happens, this would be a bug. It means that a process can access
>>> > a physical page that has been allocated to something else, possibly
>>> > kernel data.
>>> >
>>> >> I'm talking about zap_pmd_range and zap_pte_range:
>>> >>
>>> >>       zap_pmd_range
>>> >>         zap_pte_range
>>> >>           arch_enter_lazy_mmu_mode
>>> >>             ptep_get_and_clear_full
>>> >>             tlb_remove_tlb_entry
>>> >>             __tlb_remove_page
>>> >>           arch_leave_lazy_mmu_mode
>>> >>         cond_resched
>>> >>
>>> >> With the default arch_{enter,leave}_lazy_mmu_mode, tlb_remove_tlb_entry
>>> >> and __tlb_remove_page there is a loop in the zap_pte_range that clears
>>> >> PTEs and frees corresponding pages, but doesn't flush TLB, and
>>> >> surrounding loop in the zap_pmd_range that calls cond_resched. If a thread
>>> >> of the same process gets scheduled then it is able to see TLB entries
>>> >> pointing to already freed physical pages.
>>> >
>>> > It looks to me like cond_resched() here introduces a possible bug but
>>> > it depends on the actual arch code, especially the
>>> > __tlb_remove_tlb_entry() function. On ARM we record the range in
>>> > tlb_remove_tlb_entry() and queue the pages to be removed in
>>> > __tlb_remove_page(). It pretty much acts like tlb_fast_mode() == 0
>>> > even for the UP case (which is also needed for hardware speculative
>>> > TLB loads). The tlb_finish_mmu() takes care of whatever pages are left
>>> > to be freed.
>>> >
>>> > With a dummy __tlb_remove_tlb_entry() and tlb_fast_mode() == 1,
>>> > cond_resched() in zap_pmd_range() would cause problems.
>>>
>>> So, looks like most architectures in the UP configuration should have
>>> this issue (unless they flush TLB in the switch_mm, even when switching
>>> to the same mm):
>>
>> switch_mm() wouldn't be called if switching to the same mm. You could do
>
> Hmm... Strange, but as far as I can tell from the context_switch it would.
>
>> it in switch_to() but it's not efficient (or before returning to user
>> space on the same processor).
>>
>> Do you happen to have a user-space test for this? Something like one
>
> I only had mtest05 from LTP that triggered TLB/PTE inconsistency, but
> not anything that would really try to peek at the freed page. I can make
> such test though.
>
>> thread does an mmap(), writes some poison value, munmap(). The other
>> thread keeps checking the poison value while trapping and ignoring any
>> SIGSEGV. If it's working correctly, the second thread should either get
>> a SIGSEGV or read the poison value.

I've made a number of such tests and had them running for a couple of
days. Checking thread never read anything other than poison value so far.

-- 
Thanks.
-- Max

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
