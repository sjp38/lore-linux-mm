Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id D55486B040C
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 11:16:01 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id q184so92380907oih.5
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 08:16:01 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c129si5443617oib.292.2017.06.21.08.16.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 08:16:01 -0700 (PDT)
Received: from mail-ua0-f171.google.com (mail-ua0-f171.google.com [209.85.217.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 666C4214EE
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 15:15:59 +0000 (UTC)
Received: by mail-ua0-f171.google.com with SMTP id g40so115512779uaa.3
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 08:16:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170621084902.vy7nvkon4krc7v3q@pd.tnic>
References: <cover.1498022414.git.luto@kernel.org> <b13eee98a0e5322fbdc450f234a01006ec374e2c.1498022414.git.luto@kernel.org>
 <20170621084902.vy7nvkon4krc7v3q@pd.tnic>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 21 Jun 2017 08:15:38 -0700
Message-ID: <CALCETrUr7ZfQ0+KbBoT=r=-+b4BpcxT93R4e=X+1A9uKMQTnqQ@mail.gmail.com>
Subject: Re: [PATCH v3 01/11] x86/mm: Don't reenter flush_tlb_func_common()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, Jun 21, 2017 at 1:49 AM, Borislav Petkov <bp@alien8.de> wrote:
> On Tue, Jun 20, 2017 at 10:22:07PM -0700, Andy Lutomirski wrote:
>> It was historically possible to have two concurrent TLB flushes
>> targetting the same CPU: one initiated locally and one initiated
>> remotely.  This can now cause an OOPS in leave_mm() at
>> arch/x86/mm/tlb.c:47:
>>
>>         if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK)
>>                 BUG();
>>
>> with this call trace:
>>  flush_tlb_func_local arch/x86/mm/tlb.c:239 [inline]
>>  flush_tlb_mm_range+0x26d/0x370 arch/x86/mm/tlb.c:317
>
> These line numbers would most likely mean nothing soon. I think you
> should rather explain why the bug can happen so that future lookers at
> that code can find the spot...
>

That's why I gave function names and the actual code :)

> I'm assuming this is going away in a future patch, as disabling IRQs
> around a TLB flush is kinda expensive. I guess I'll see if I continue
> reading...

No, it's still there.  It's possible that it could be removed with
lots of care, but I'm not convinced it's worth it.
local_irq_disable() and local_irq_enable() are fast, though (3 cycles
each last time I benchmarked them?) -- it's local_irq_save() that
really hurts.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
