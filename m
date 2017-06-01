Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5EE386B02FA
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 12:45:54 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id m28so15018357uab.9
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 09:45:54 -0700 (PDT)
Received: from mail-vk0-x22d.google.com (mail-vk0-x22d.google.com. [2607:f8b0:400c:c05::22d])
        by mx.google.com with ESMTPS id v24si10367760uaf.36.2017.06.01.09.45.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 09:45:53 -0700 (PDT)
Received: by mail-vk0-x22d.google.com with SMTP id y190so28001498vkc.1
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 09:45:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170601163442.GC17711@leverpostej>
References: <20170601162338.23540-1-aryabinin@virtuozzo.com>
 <20170601162338.23540-3-aryabinin@virtuozzo.com> <20170601163442.GC17711@leverpostej>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 1 Jun 2017 18:45:32 +0200
Message-ID: <CACT4Y+aCKDF95mK2-nuiV0+XineHha3y+6PCW0-EorOaY=TFng@mail.gmail.com>
Subject: Re: [PATCH 3/4] arm64/kasan: don't allocate extra shadow memory
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Alexander Potapenko <glider@google.com>, linux-arm-kernel@lists.infradead.org

On Thu, Jun 1, 2017 at 6:34 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> On Thu, Jun 01, 2017 at 07:23:37PM +0300, Andrey Ryabinin wrote:
>> We used to read several bytes of the shadow memory in advance.
>> Therefore additional shadow memory mapped to prevent crash if
>> speculative load would happen near the end of the mapped shadow memory.
>>
>> Now we don't have such speculative loads, so we no longer need to map
>> additional shadow memory.
>
> I see that patch 1 fixed up the Linux helpers for outline
> instrumentation.
>
> Just to check, is it also true that the inline instrumentation never
> performs unaligned accesses to the shadow memory?

Inline instrumentation generally accesses only a single byte.

> If so, this looks good to me; it also avoids a potential fencepost issue
> when memory exists right at the end of the linear map. Assuming that
> holds:
>
> Acked-by: Mark Rutland <mark.rutland@arm.com>
>
> Thanks,
> Mark.
>
>>
>> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> Cc: Catalin Marinas <catalin.marinas@arm.com>
>> Cc: Will Deacon <will.deacon@arm.com>
>> Cc: linux-arm-kernel@lists.infradead.org
>> ---
>>  arch/arm64/mm/kasan_init.c | 8 +-------
>>  1 file changed, 1 insertion(+), 7 deletions(-)
>>
>> diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
>> index 687a358a3733..81f03959a4ab 100644
>> --- a/arch/arm64/mm/kasan_init.c
>> +++ b/arch/arm64/mm/kasan_init.c
>> @@ -191,14 +191,8 @@ void __init kasan_init(void)
>>               if (start >=3D end)
>>                       break;
>>
>> -             /*
>> -              * end + 1 here is intentional. We check several shadow by=
tes in
>> -              * advance to slightly speed up fastpath. In some rare cas=
es
>> -              * we could cross boundary of mapped shadow, so we just ma=
p
>> -              * some more here.
>> -              */
>>               vmemmap_populate((unsigned long)kasan_mem_to_shadow(start)=
,
>> -                             (unsigned long)kasan_mem_to_shadow(end) + =
1,
>> +                             (unsigned long)kasan_mem_to_shadow(end),
>>                               pfn_to_nid(virt_to_pfn(start)));
>>       }
>>
>> --
>> 2.13.0
>>
>>
>> _______________________________________________
>> linux-arm-kernel mailing list
>> linux-arm-kernel@lists.infradead.org
>> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> IMPORTANT NOTICE: The contents of this email and any attachments are conf=
idential and may also be privileged. If you are not the intended recipient,=
 please notify the sender immediately and do not disclose the contents to a=
ny other person, use it for any purpose, or store or copy the information i=
n any medium. Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
