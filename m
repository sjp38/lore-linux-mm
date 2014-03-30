Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 815666B0031
	for <linux-mm@kvack.org>; Sun, 30 Mar 2014 08:58:58 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id e53so5665416eek.2
        for <linux-mm@kvack.org>; Sun, 30 Mar 2014 05:58:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id u5si17864146een.293.2014.03.30.05.58.55
        for <linux-mm@kvack.org>;
        Sun, 30 Mar 2014 05:58:56 -0700 (PDT)
Message-ID: <53381506.1090104@redhat.com>
Date: Sun, 30 Mar 2014 08:58:46 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch]x86: clearing access bit don't flush tlb
References: <20140326223034.GA31713@kernel.org> <53336907.1050105@redhat.com> <20140327171237.GA9490@kernel.org> <533470F7.4000406@redhat.com> <20140328190233.GA14905@kernel.org>
In-Reply-To: <20140328190233.GA14905@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, mel@csn.ul.ie

On 03/28/2014 03:02 PM, Shaohua Li wrote:
> On Thu, Mar 27, 2014 at 02:41:59PM -0400, Rik van Riel wrote:
>> On 03/27/2014 01:12 PM, Shaohua Li wrote:
>>> On Wed, Mar 26, 2014 at 07:55:51PM -0400, Rik van Riel wrote:
>>>> On 03/26/2014 06:30 PM, Shaohua Li wrote:
>>>>>
>>>>> I posted this patch a year ago or so, but it gets lost. Repost it here to check
>>>>> if we can make progress this time.
>>>>
>>>> I believe we can make progress. However, I also
>>>> believe the code could be enhanced to address a
>>>> concern that Hugh raised last time this was
>>>> proposed...
>>>>
>>>>> And according to intel manual, tlb has less than 1k entries, which covers < 4M
>>>>> memory. In today's system, several giga byte memory is normal. After page
>>>>> reclaim clears pte access bit and before cpu access the page again, it's quite
>>>>> unlikely this page's pte is still in TLB. And context swich will flush tlb too.
>>>>> The chance skiping tlb flush to impact page reclaim should be very rare.
>>>>
>>>> Context switch to a kernel thread does not result in a
>>>> TLB flush, due to the lazy TLB code.
>>>>
>>>> While I agree with you that clearing the TLB right at
>>>> the moment the accessed bit is cleared in a PTE is
>>>> not necessary, I believe it would be good to clear
>>>> the TLB on affected CPUs relatively soon, maybe at the
>>>> next time schedule is called?
>>>>
>>>>> --- linux.orig/arch/x86/mm/pgtable.c	2014-03-27 05:22:08.572100549 +0800
>>>>> +++ linux/arch/x86/mm/pgtable.c	2014-03-27 05:46:12.456131121 +0800
>>>>> @@ -399,13 +399,12 @@ int pmdp_test_and_clear_young(struct vm_
>>>>>  int ptep_clear_flush_young(struct vm_area_struct *vma,
>>>>>  			   unsigned long address, pte_t *ptep)
>>>>>  {
>>>>> -	int young;
>>>>> -
>>>>> -	young = ptep_test_and_clear_young(vma, address, ptep);
>>>>> -	if (young)
>>>>> -		flush_tlb_page(vma, address);
>>>>> -
>>>>> -	return young;
>>>>> +	/*
>>>>> +	 * In X86, clearing access bit without TLB flush doesn't cause data
>>>>> +	 * corruption. Doing this could cause wrong page aging and so hot pages
>>>>> +	 * are reclaimed, but the chance should be very rare.
>>>>> +	 */
>>>>> +	return ptep_test_and_clear_young(vma, address, ptep);
>>>>>  }
>>>>
>>>>
>>>> At this point, we could use vma->vm_mm->cpu_vm_mask_var to
>>>> set (or clear) some bit in the per-cpu data of each CPU that
>>>> has active/valid tlb state for the mm in question.
>>>>
>>>> I could see using cpu_tlbstate.state for this, or maybe
>>>> another variable in cpu_tlbstate, so switch_mm will load
>>>> both items with the same cache line.
>>>>
>>>> At schedule time, the function switch_mm() can examine that
>>>> variable (it already touches that data, anyway), and flush
>>>> the TLB even if prev==next.
>>>>
>>>> I suspect that would be both low overhead enough to get you
>>>> the performance gains you want, and address the concern that
>>>> we do want to flush the TLB at some point.
>>>>
>>>> Does that sound reasonable?
>>>
>>> So looks what you suggested is to force tlb flush for a mm with access bit
>>> cleared in two corner cases:
>>> 1. lazy tlb flush
>>> 2. context switch between threads from one process
>>>
>>> Am I missing anything? I'm wonering if we should care about these corner cases.
>>
>> I believe the corner case is relatively rare, but I also
>> suspect that your patch could fail pretty badly in some
>> of those cases, and the fix is easy...
>>
>>> On the other hand, a thread might run long time without schedule. If the corner
>>> cases are an issue, the long run thread is a severer issue. My point is context
>>> switch does provide a safeguard, but we don't depend on it. The whole theory at
>>> the back of this patch is page which has access bit cleared is unlikely
>>> accessed again when its pte entry is still in tlb cache.
>>
>> On the contrary, a TLB with a good cache policy should
>> retain the most actively used entries, in favor of
>> less actively used ones.
>>
>> That means the pages we care most about keeping, are
>> the ones also most at danger of not having the accessed
>> bit flushed to memory.
>>
>> Does the attached (untested) patch look reasonable?
> 
> It works obviously. Test shows tehre is no extra tradeoff too compared to just
> skip tlb flush. So I have no objection to this if you insist a safeguard like
> this. Should we force no entering lazy tlb too (in context_switch) if
> force_flush is set, because you are talking about it but I didn't see it in the
> patch? Should I push this or will you do it?

Thank you for testing the patch.

I think we should be fine not adding any code to the lazy tlb
entering code, because a kernel thread in lazy tlb mode should
not be accessing user space memory, except for the vhost-net
thread, which will then wake up userspace, and cause the flush.

Since performance numbers were identical, can I use your
performance numbers when submitting my patch? :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
