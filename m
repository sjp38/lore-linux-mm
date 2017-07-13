Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 15378440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 12:07:13 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id a142so4500576oii.5
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 09:07:13 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w10si4120380oib.92.2017.07.13.09.07.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 09:07:12 -0700 (PDT)
Received: from mail-ua0-f181.google.com (mail-ua0-f181.google.com [209.85.217.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6705C22C98
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 16:07:11 +0000 (UTC)
Received: by mail-ua0-f181.google.com with SMTP id z22so36659582uah.1
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 09:07:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5F1E23BA-B0DE-4FF0-AB8F-C22936263EAA@gmail.com>
References: <20170711092935.bogdb4oja6v7kilq@suse.de> <E37E0D40-821A-4C82-B924-F1CE6DF97719@gmail.com>
 <20170711132023.wdfpjxwtbqpi3wp2@suse.de> <CALCETrUOYwpJZAAVF8g+_U9fo5cXmGhYrM-ix+X=bbfid+j-Cw@mail.gmail.com>
 <20170711155312.637eyzpqeghcgqzp@suse.de> <CALCETrWjER+vLfDryhOHbJAF5D5YxjN7e9Z0kyhbrmuQ-CuVbA@mail.gmail.com>
 <20170711191823.qthrmdgqcd3rygjk@suse.de> <20170711200923.gyaxfjzz3tpvreuq@suse.de>
 <20170711215240.tdpmwmgwcuerjj3o@suse.de> <9ECCACFE-6006-4C19-8FC0-C387EB5F3BEE@gmail.com>
 <20170712082733.ouf7yx2bnvwwcfms@suse.de> <591A2865-13B8-4B3A-B094-8B83A7F9814B@gmail.com>
 <CALCETrXr16TGe1gxnPajqpq-G8z1hK_fzPzZiJa+h+zZ8RysNw@mail.gmail.com>
 <079D9048-0FFD-4A58-90EF-889259EB6ECE@gmail.com> <CALCETrVrP3OVgs_AjnpfOY2-aeDGRorMQ2i4jeO50kPGb-D6+g@mail.gmail.com>
 <5F1E23BA-B0DE-4FF0-AB8F-C22936263EAA@gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 13 Jul 2017 09:06:49 -0700
Message-ID: <CALCETrXQGr1nJqTGs06-j2ahFdG8gHJX1VdbfPZfHzWJ6oWeZQ@mail.gmail.com>
Subject: Re: Potential race in TLB flush batching?
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, Mel Gorman <mgorman@suse.de>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Thu, Jul 13, 2017 at 9:05 AM, Nadav Amit <nadav.amit@gmail.com> wrote:
> Andy Lutomirski <luto@kernel.org> wrote:
>
>> On Wed, Jul 12, 2017 at 4:42 PM, Nadav Amit <nadav.amit@gmail.com> wrote=
:
>>> Andy Lutomirski <luto@kernel.org> wrote:
>>>
>>>> On Wed, Jul 12, 2017 at 4:27 PM, Nadav Amit <nadav.amit@gmail.com> wro=
te:
>>>>> Actually, I think that based on Andy=E2=80=99s patches there is a rel=
atively
>>>>> reasonable solution. For each mm we will hold both a =E2=80=9Cpending=
_tlb_gen=E2=80=9D
>>>>> (increased under the PT-lock) and an =E2=80=9Cexecuted_tlb_gen=E2=80=
=9D. Once
>>>>> flush_tlb_mm_range finishes flushing it will use cmpxchg to update th=
e
>>>>> executed_tlb_gen to the pending_tlb_gen that was prior the flush (the
>>>>> cmpxchg will ensure the TLB gen only goes forward). Then, whenever
>>>>> pending_tlb_gen is different than executed_tlb_gen - a flush is neede=
d.
>>>>
>>>> Why do we need executed_tlb_gen?  We already have
>>>> cpu_tlbstate.ctxs[...].tlb_gen.  Or is the idea that executed_tlb_gen
>>>> guarantees that all cpus in mm_cpumask are at least up to date to
>>>> executed_tlb_gen?
>>>
>>> Hm... So actually it may be enough, no? Just compare mm->context.tlb_ge=
n
>>> with cpu_tlbstate.ctxs[...].tlb_gen and flush if they are different?
>>
>> Wouldn't that still leave the races where the CPU observing the stale
>> TLB entry isn't the CPU that did munmap/mprotect/whatever?  I think
>> executed_tlb_gen or similar may really be needed for your approach.
>
> Yes, you are right.
>
> This approach requires a counter that is only updated after the flush is
> completed by all cores. This way you ensure there is no CPU that did not
> complete the flush.
>
> Does it make sense?

Yes.  It could be a delta on top of Mel's patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
