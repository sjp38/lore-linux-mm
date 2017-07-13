Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 98A9F440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 13:15:38 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id b130so4600241oii.9
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 10:15:38 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w186si4569951oiw.25.2017.07.13.10.15.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 10:15:37 -0700 (PDT)
Received: from mail-ua0-f175.google.com (mail-ua0-f175.google.com [209.85.217.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1CE2922CA1
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 17:15:37 +0000 (UTC)
Received: by mail-ua0-f175.google.com with SMTP id z22so37869666uah.1
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 10:15:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170713170712.4iriw5lncoulcgda@suse.de>
References: <20170711155312.637eyzpqeghcgqzp@suse.de> <CALCETrWjER+vLfDryhOHbJAF5D5YxjN7e9Z0kyhbrmuQ-CuVbA@mail.gmail.com>
 <20170711191823.qthrmdgqcd3rygjk@suse.de> <20170711200923.gyaxfjzz3tpvreuq@suse.de>
 <20170711215240.tdpmwmgwcuerjj3o@suse.de> <9ECCACFE-6006-4C19-8FC0-C387EB5F3BEE@gmail.com>
 <20170712082733.ouf7yx2bnvwwcfms@suse.de> <591A2865-13B8-4B3A-B094-8B83A7F9814B@gmail.com>
 <20170713060706.o2cuko5y6irxwnww@suse.de> <CALCETrWF7hxR7rFCUwi5FZWPt_NUy2U5dV+zy6HUm_x+0jdomA@mail.gmail.com>
 <20170713170712.4iriw5lncoulcgda@suse.de>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 13 Jul 2017 10:15:15 -0700
Message-ID: <CALCETrXm8GXXgbXOw8DKL2O9fWfyv2CzExwCLR+6kHLELPsP3Q@mail.gmail.com>
Subject: Re: Potential race in TLB flush batching?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Thu, Jul 13, 2017 at 10:07 AM, Mel Gorman <mgorman@suse.de> wrote:
> On Thu, Jul 13, 2017 at 09:08:21AM -0700, Andrew Lutomirski wrote:
>> On Wed, Jul 12, 2017 at 11:07 PM, Mel Gorman <mgorman@suse.de> wrote:
>> > --- a/arch/x86/mm/tlb.c
>> > +++ b/arch/x86/mm/tlb.c
>> > @@ -455,6 +455,39 @@ void arch_tlbbatch_flush(struct arch_tlbflush_unmap_batch *batch)
>> >         put_cpu();
>> >  }
>> >
>> > +/*
>> > + * Ensure that any arch_tlbbatch_add_mm calls on this mm are up to date when
>>
>> s/are up to date/have flushed the TLBs/ perhaps?
>>
>>
>> Can you update this comment in arch/x86/include/asm/tlbflush.h:
>>
>>          * - Fully flush a single mm.  .mm will be set, .end will be
>>          *   TLB_FLUSH_ALL, and .new_tlb_gen will be the tlb_gen to
>>          *   which the IPI sender is trying to catch us up.
>>
>> by adding something like: This can also happen due to
>> arch_tlbflush_flush_one_mm(), in which case it's quite likely that
>> most or all CPUs are already up to date.
>>
>
> No problem, thanks. Care to ack the patch below? If so, I'll send it
> to Ingo with x86 and linux-mm cc'd after some tests complete (hopefully
> successfully). It's fairly x86 specific and makes sense to go in with the
> rest of the pcid and mm tlb_gen stuff rather than via Andrew's tree even
> through it touches core mm.

Acked-by: Andy Lutomirski <luto@kernel.org> # for the x86 parts

When you send to Ingo, you might want to change
arch_tlbbatch_flush_one_mm to arch_tlbbatch_flush_one_mm(), because
otherwise he'll probably do it for you :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
