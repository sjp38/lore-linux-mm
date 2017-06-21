Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2B8E16B037C
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 11:23:31 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id 37so102061982otu.13
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 08:23:31 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u62si5328066oif.286.2017.06.21.08.23.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 08:23:30 -0700 (PDT)
Received: from mail-ua0-f170.google.com (mail-ua0-f170.google.com [209.85.217.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CEA202187A
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 15:23:28 +0000 (UTC)
Received: by mail-ua0-f170.google.com with SMTP id g40so115778506uaa.3
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 08:23:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170621103322.pwi6koe7jee7hd63@pd.tnic>
References: <cover.1498022414.git.luto@kernel.org> <e2903f555bd23f8cf62f34b91895c42f7d4e40e3.1498022414.git.luto@kernel.org>
 <20170621103322.pwi6koe7jee7hd63@pd.tnic>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 21 Jun 2017 08:23:07 -0700
Message-ID: <CALCETrVoRjSL2HncTGQ-PJ_1ycUAV3UcDVMEGw=-f7AbqtEN6w@mail.gmail.com>
Subject: Re: [PATCH v3 04/11] x86/mm: Give each mm TLB flush generation a
 unique ID
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, Jun 21, 2017 at 3:33 AM, Borislav Petkov <bp@alien8.de> wrote:
> On Tue, Jun 20, 2017 at 10:22:10PM -0700, Andy Lutomirski wrote:
>> +#define INIT_MM_CONTEXT(mm)                                          \
>> +     .context = {                                                    \
>> +             .ctx_id = 1,                                            \
>
> So ctx_id of 0 is invalid?
>
> Let's state that explicitly. We could even use it to sanity-check mms or
> whatever.

It's stated explicitly in the comment where it's declared in the same file.

>
>> +     }
>> +
>>  void leave_mm(int cpu);
>>
>>  #endif /* _ASM_X86_MMU_H */
>> diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
>> index ecfcb6643c9b..e5295d485899 100644
>> --- a/arch/x86/include/asm/mmu_context.h
>> +++ b/arch/x86/include/asm/mmu_context.h
>> @@ -129,9 +129,14 @@ static inline void enter_lazy_tlb(struct mm_struct *mm, struct task_struct *tsk)
>>               this_cpu_write(cpu_tlbstate.state, TLBSTATE_LAZY);
>>  }
>>
>> +extern atomic64_t last_mm_ctx_id;
>
> I think we prefer externs/variable defines at the beginning of the file,
> not intermixed with functions.

Done

>
>> +static inline u64 bump_mm_tlb_gen(struct mm_struct *mm)
>
> inc_mm_tlb_gen() I guess. git grep says like "inc" more :-)

Done

>> +      * that synchronizes with switch_mm: callers are required to order
>
> Please end function names with parentheses.

Done.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
