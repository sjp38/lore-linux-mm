Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3B1A76B03CD
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 11:05:44 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id i19so67209909ote.14
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 08:05:44 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 66si4224519otv.82.2017.06.19.08.05.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 08:05:43 -0700 (PDT)
Received: from mail-vk0-f48.google.com (mail-vk0-f48.google.com [209.85.213.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4A85123A06
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 15:05:42 +0000 (UTC)
Received: by mail-vk0-f48.google.com with SMTP id y70so53465947vky.3
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 08:05:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5947D2AE.6080609@huawei.com>
References: <b13eee98a0e5322fbdc450f234a01006ec374e2c.1497847645.git.luto@kernel.org>
 <5947D2AE.6080609@huawei.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 19 Jun 2017 08:05:20 -0700
Message-ID: <CALCETrX0jitvM8LZye9BMqHsGEM0vVQvimtmgRpUyL4GATT1PQ@mail.gmail.com>
Subject: Re: [PATCH] x86/mm: Don't reenter flush_tlb_func_common()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Mon, Jun 19, 2017 at 6:33 AM, zhong jiang <zhongjiang@huawei.com> wrote:
> On 2017/6/19 12:48, Andy Lutomirski wrote:
>> It was historically possible to have two concurrent TLB flushes
>> targeting the same CPU: one initiated locally and one initiated
>> remotely.  This can now cause an OOPS in leave_mm() at
>> arch/x86/mm/tlb.c:47:
>>
>>         if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK)
>>                 BUG();
>>
>> with this call trace:
>>  flush_tlb_func_local arch/x86/mm/tlb.c:239 [inline]
>>  flush_tlb_mm_range+0x26d/0x370 arch/x86/mm/tlb.c:317
>>
>> Without reentrancy, this OOPS is impossible: leave_mm() is only
>> called if we're not in TLBSTATE_OK, but then we're unexpectedly
>> in TLBSTATE_OK in leave_mm().
>>
>> This can be caused by flush_tlb_func_remote() happening between
>> the two checks and calling leave_mm(), resulting in two consecutive
>> leave_mm() calls on the same CPU with no intervening switch_mm()
>> calls.
>>
>> We never saw this OOPS before because the old leave_mm()
>> implementation didn't put us back in TLBSTATE_OK, so the assertion
>> didn't fire.
>   HI, Andy
>
>   Today, I see same OOPS in linux 3.4 stable. It prove that it indeed has fired.
>    but It is rarely to appear.  I review the code. I found the a  issue.
>   when current->mm is NULL,  leave_mm will be called. but  it maybe in
>   TLBSTATE_OK,  eg: unuse_mm call after task->mm = NULL , but before enter_lazy_tlb.
>
>    therefore,  it will fire. is it right?

Is there a code path that does this?

Also, the IPI handler on 3.4 looks like this:

        if (f->flush_mm == percpu_read(cpu_tlbstate.active_mm)) {
                if (percpu_read(cpu_tlbstate.state) == TLBSTATE_OK) {
                        if (f->flush_va == TLB_FLUSH_ALL)
                                local_flush_tlb();
                        else
                                __flush_tlb_one(f->flush_va);
                } else
                        leave_mm(cpu);
        }

but leave_mm() checks the same condition (cpu_tlbstate.state, not
current->mm).  How is the BUG triggering?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
