Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4745F6B02C3
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 23:05:18 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id c189so78295137oia.13
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 20:05:18 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [45.249.212.187])
        by mx.google.com with ESMTPS id q84si2455388oif.1.2017.06.19.20.05.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Jun 2017 20:05:17 -0700 (PDT)
Message-ID: <59488EE2.1080403@huawei.com>
Date: Tue, 20 Jun 2017 10:56:34 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86/mm: Don't reenter flush_tlb_func_common()
References: <b13eee98a0e5322fbdc450f234a01006ec374e2c.1497847645.git.luto@kernel.org> <5947D2AE.6080609@huawei.com> <CALCETrX0jitvM8LZye9BMqHsGEM0vVQvimtmgRpUyL4GATT1PQ@mail.gmail.com>
In-Reply-To: <CALCETrX0jitvM8LZye9BMqHsGEM0vVQvimtmgRpUyL4GATT1PQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus
 Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan
 van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On 2017/6/19 23:05, Andy Lutomirski wrote:
> On Mon, Jun 19, 2017 at 6:33 AM, zhong jiang <zhongjiang@huawei.com> wrote:
>> On 2017/6/19 12:48, Andy Lutomirski wrote:
>>> It was historically possible to have two concurrent TLB flushes
>>> targeting the same CPU: one initiated locally and one initiated
>>> remotely.  This can now cause an OOPS in leave_mm() at
>>> arch/x86/mm/tlb.c:47:
>>>
>>>         if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK)
>>>                 BUG();
>>>
>>> with this call trace:
>>>  flush_tlb_func_local arch/x86/mm/tlb.c:239 [inline]
>>>  flush_tlb_mm_range+0x26d/0x370 arch/x86/mm/tlb.c:317
>>>
>>> Without reentrancy, this OOPS is impossible: leave_mm() is only
>>> called if we're not in TLBSTATE_OK, but then we're unexpectedly
>>> in TLBSTATE_OK in leave_mm().
>>>
>>> This can be caused by flush_tlb_func_remote() happening between
>>> the two checks and calling leave_mm(), resulting in two consecutive
>>> leave_mm() calls on the same CPU with no intervening switch_mm()
>>> calls.
>>>
>>> We never saw this OOPS before because the old leave_mm()
>>> implementation didn't put us back in TLBSTATE_OK, so the assertion
>>> didn't fire.
>>   HI, Andy
>>
>>   Today, I see same OOPS in linux 3.4 stable. It prove that it indeed has fired.
>>    but It is rarely to appear.  I review the code. I found the a  issue.
>>   when current->mm is NULL,  leave_mm will be called. but  it maybe in
>>   TLBSTATE_OK,  eg: unuse_mm call after task->mm = NULL , but before enter_lazy_tlb.
>>
>>    therefore,  it will fire. is it right?
> Is there a code path that does this?
 eg:
 
     cpu1                                                          cpu2                                          

    flush_tlb_page                                              unuse_mm
                                                                    current->mm = NULL
       
         current->mm == NULL                                                                                                   
            leave_mm (cpu_tlbstate.state is TLBSATATE_OK)
                                                                    enter_lazy_tlb
 I am not sure the above race whether  exist or not. Do you point out the problem if it is not existence? please

  Thanks
  zhongjiang
> 	
> Also, the IPI handler on 3.4 looks like this:
>
>         if (f->flush_mm == percpu_read(cpu_tlbstate.active_mm)) {
>                 if (percpu_read(cpu_tlbstate.state) == TLBSTATE_OK) {
>                         if (f->flush_va == TLB_FLUSH_ALL)
>                                 local_flush_tlb();
>                         else
>                                 __flush_tlb_one(f->flush_va);
>                 } else
>                         leave_mm(cpu);
>         }
>
> but leave_mm() checks the same condition (cpu_tlbstate.state, not
> current->mm).  How is the BUG triggering?
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
