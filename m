Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0A5FD440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 12:05:05 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 125so62857334pgi.2
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 09:05:05 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id 1si4630574pgp.88.2017.07.13.09.05.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 09:05:04 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id j186so7441708pge.1
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 09:05:03 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: Potential race in TLB flush batching?
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <CALCETrVrP3OVgs_AjnpfOY2-aeDGRorMQ2i4jeO50kPGb-D6+g@mail.gmail.com>
Date: Thu, 13 Jul 2017 09:05:01 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <5F1E23BA-B0DE-4FF0-AB8F-C22936263EAA@gmail.com>
References: <20170711092935.bogdb4oja6v7kilq@suse.de>
 <E37E0D40-821A-4C82-B924-F1CE6DF97719@gmail.com>
 <20170711132023.wdfpjxwtbqpi3wp2@suse.de>
 <CALCETrUOYwpJZAAVF8g+_U9fo5cXmGhYrM-ix+X=bbfid+j-Cw@mail.gmail.com>
 <20170711155312.637eyzpqeghcgqzp@suse.de>
 <CALCETrWjER+vLfDryhOHbJAF5D5YxjN7e9Z0kyhbrmuQ-CuVbA@mail.gmail.com>
 <20170711191823.qthrmdgqcd3rygjk@suse.de>
 <20170711200923.gyaxfjzz3tpvreuq@suse.de>
 <20170711215240.tdpmwmgwcuerjj3o@suse.de>
 <9ECCACFE-6006-4C19-8FC0-C387EB5F3BEE@gmail.com>
 <20170712082733.ouf7yx2bnvwwcfms@suse.de>
 <591A2865-13B8-4B3A-B094-8B83A7F9814B@gmail.com>
 <CALCETrXr16TGe1gxnPajqpq-G8z1hK_fzPzZiJa+h+zZ8RysNw@mail.gmail.com>
 <079D9048-0FFD-4A58-90EF-889259EB6ECE@gmail.com>
 <CALCETrVrP3OVgs_AjnpfOY2-aeDGRorMQ2i4jeO50kPGb-D6+g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Andy Lutomirski <luto@kernel.org> wrote:

> On Wed, Jul 12, 2017 at 4:42 PM, Nadav Amit <nadav.amit@gmail.com> =
wrote:
>> Andy Lutomirski <luto@kernel.org> wrote:
>>=20
>>> On Wed, Jul 12, 2017 at 4:27 PM, Nadav Amit <nadav.amit@gmail.com> =
wrote:
>>>> Actually, I think that based on Andy=E2=80=99s patches there is a =
relatively
>>>> reasonable solution. For each mm we will hold both a =
=E2=80=9Cpending_tlb_gen=E2=80=9D
>>>> (increased under the PT-lock) and an =E2=80=9Cexecuted_tlb_gen=E2=80=9D=
. Once
>>>> flush_tlb_mm_range finishes flushing it will use cmpxchg to update =
the
>>>> executed_tlb_gen to the pending_tlb_gen that was prior the flush =
(the
>>>> cmpxchg will ensure the TLB gen only goes forward). Then, whenever
>>>> pending_tlb_gen is different than executed_tlb_gen - a flush is =
needed.
>>>=20
>>> Why do we need executed_tlb_gen?  We already have
>>> cpu_tlbstate.ctxs[...].tlb_gen.  Or is the idea that =
executed_tlb_gen
>>> guarantees that all cpus in mm_cpumask are at least up to date to
>>> executed_tlb_gen?
>>=20
>> Hm... So actually it may be enough, no? Just compare =
mm->context.tlb_gen
>> with cpu_tlbstate.ctxs[...].tlb_gen and flush if they are different?
>=20
> Wouldn't that still leave the races where the CPU observing the stale
> TLB entry isn't the CPU that did munmap/mprotect/whatever?  I think
> executed_tlb_gen or similar may really be needed for your approach.

Yes, you are right.

This approach requires a counter that is only updated after the flush is
completed by all cores. This way you ensure there is no CPU that did not
complete the flush.

Does it make sense?=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
