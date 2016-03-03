Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 12BD06B0268
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 12:45:57 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id p65so631308wmp.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 09:45:57 -0800 (PST)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id wh1si6495783wjb.106.2016.03.03.09.45.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 09:45:56 -0800 (PST)
Received: by mail-wm0-x22b.google.com with SMTP id n186so626521wmn.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 09:45:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160303174015.GG19139@leverpostej>
References: <1457024068-2236-1-git-send-email-mark.rutland@arm.com>
	<CAG_fn=WAfu4oD1Qb1xUnX765RpUznWm1y+FKYqqiM8VO53F+Ag@mail.gmail.com>
	<20160303174015.GG19139@leverpostej>
Date: Thu, 3 Mar 2016 18:45:55 +0100
Message-ID: <CAG_fn=VBOqPSwhKy2OCj7cgM=XaD338L=UfPDcg9X3tCwc6B_g@mail.gmail.com>
Subject: Re: [PATCHv2 0/3] KASAN: clean stale poison upon cold re-entry to kernel
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, mingo@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, catalin.marinas@arm.com, lorenzo.pieralisi@arm.com, peterz@infradead.org, will.deacon@arm.com, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Thu, Mar 3, 2016 at 6:40 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> Hi,
>
> On Thu, Mar 03, 2016 at 06:17:31PM +0100, Alexander Potapenko wrote:
>> Please replace "ASAN" with "KASAN".
>>
>> On Thu, Mar 3, 2016 at 5:54 PM, Mark Rutland <mark.rutland@arm.com> wrot=
e:
>> > Functions which the compiler has instrumented for ASAN place poison on
>> > the stack shadow upon entry and remove this poison prior to returning.
>> >
>> > In some cases (e.g. hotplug and idle), CPUs may exit the kernel a numb=
er
>> > of levels deep in C code. If there are any instrumented functions on
>> > this critical path, these will leave portions of the idle thread stack
>> > shadow poisoned.
>> >
>> > If a CPU returns to the kernel via a different path (e.g. a cold entry=
),
>> > then depending on stack frame layout subsequent calls to instrumented
>> > functions may use regions of the stack with stale poison, resulting in
>> > (spurious) KASAN splats to the console.
>> >
>> > Contemporary GCCs always add stack shadow poisoning when ASAN is
>> > enabled, even when asked to not instrument a function [1], so we can't
>> > simply annotate functions on the critical path to avoid poisoning.
>> >
>> > Instead, this series explicitly removes any stale poison before it can
>> > be hit. In the common hotplug case we clear the entire stack shadow in
>> > common code, before a CPU is brought online.
>> >
>> > On architectures which perform a cold return as part of cpu idle may
>> > retain an architecture-specific amount of stack contents. To retain th=
e
>> > poison for this retained context, the arch code must call the core KAS=
AN
>> > code, passing a "watermark" stack pointer value beyond which shadow wi=
ll
>> > be cleared. Architectures which don't perform a cold return as part of
>> > idle do not need any additional code.
>
> For the above, and the rest of the series, ASAN consistently refers to
> the compiler AddressSanitizer feature, and KASAN consistently refers to
> the Linux-specific infrastructure. A simple s/[^K]ASAN/KASAN/ would
> arguably be wrong (e.g. when referring to GCC behaviour above).
I don't think there's been any convention about the compiler feature
name, we usually talked about ASan as a userspace tool and KASAN as a
kernel-space one, although they share the compiler part.

> If there is a this needs rework, then I'm happy to s/[^K]ASAN/ASan/ to
> follow the usual ASan naming convention and avoid confusion. Otherwise,
> spinning a v3 is simply churn.
I don't insist on changing this, I should've chimed in before.
Feel free to retain the above patch description.
> Thanks,
> Mark.



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
Diese E-Mail ist vertraulich. Wenn Sie nicht der richtige Adressat sind,
leiten Sie diese bitte nicht weiter, informieren Sie den
Absender und l=C3=B6schen Sie die E-Mail und alle Anh=C3=A4nge. Vielen Dank=
.
This e-mail is confidential. If you are not the right addressee please
do not forward it, please inform the sender, and please erase this
e-mail including any attachments. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
