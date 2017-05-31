Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E4E2A6B02F3
	for <linux-mm@kvack.org>; Wed, 31 May 2017 12:30:01 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id m5so18583440pfc.1
        for <linux-mm@kvack.org>; Wed, 31 May 2017 09:30:01 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40130.outbound.protection.outlook.com. [40.107.4.130])
        by mx.google.com with ESMTPS id 30si50087557plc.155.2017.05.31.09.30.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 31 May 2017 09:30:00 -0700 (PDT)
Subject: Re: [PATCH v1 00/11] mm/kasan: support per-page shadow memory to
 reduce memory consumption
References: <20170516062318.GC16015@js1304-desktop>
 <CACT4Y+anOw8=7u-pZ2ceMw0xVnuaO9YKBJAr-2=KOYt_72b2pw@mail.gmail.com>
 <CACT4Y+YREmHViSMsH84bwtEqbUsqsgzaa76eWzJXqmSgqKbgvg@mail.gmail.com>
 <20170524074539.GA9697@js1304-desktop>
 <CACT4Y+ZwL+iTMvF5NpsovThQrdhunCc282ffjqQcgZg3tAQH4w@mail.gmail.com>
 <20170525004104.GA21336@js1304-desktop>
 <CACT4Y+YV7Rf93NOa1yi0NiELX7wfwkfQmXJ67hEVOrG7VkuJJg@mail.gmail.com>
 <CACT4Y+ZrUi_YGkwmbuGV2_6wC7Q54at1_xyYeT3dQQ=cNm1NsQ@mail.gmail.com>
 <CACT4Y+bT=aaC+XTMwoON-Rc5gOheAj702anXKJMXDJ5FtLDRMw@mail.gmail.com>
 <3a7664a9-e360-ab68-610a-1b697a4b00b5@virtuozzo.com>
 <20170531055047.GA21606@js1304-desktop>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <80f2f6f7-0a37-53dc-843e-1adbed4377fa@virtuozzo.com>
Date: Wed, 31 May 2017 19:31:53 +0300
MIME-Version: 1.0
In-Reply-To: <20170531055047.GA21606@js1304-desktop>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com

On 05/31/2017 08:50 AM, Joonsoo Kim wrote:
>>> But the main win as I see it is that that's basically complete support
>>> for 32-bit arches. People do ask about arm32 support:
>>> https://groups.google.com/d/msg/kasan-dev/Sk6BsSPMRRc/Gqh4oD_wAAAJ
>>> https://groups.google.com/d/msg/kasan-dev/B22vOFp-QWg/EVJPbrsgAgAJ
>>> and probably mips32 is relevant as well.
>>
>> I don't see how above is relevant for 32-bit arches. Current design
>> is perfectly fine for 32-bit arches. I did some POC arm32 port couple years
>> ago - https://github.com/aryabinin/linux/commits/kasan/arm_v0_1
>> It has some ugly hacks and non-critical bugs. AFAIR it also super-slow because I (mistakenly) 
>> made shadow memory uncached. But otherwise it works.
> 
> Could you explain that where is the code to map shadow memory uncached?
> I don't find anything related to it.
> 

I didn't set set any cache policy (L_PTE_MT_*) on shadow mapping (see set_pte_at() calls )
which means it's L_PTE_MT_UNCACHED 

>>> Such mode does not require a huge continuous address space range, has
>>> minimal memory consumption and requires minimal arch-dependent code.
>>> Works only with outline instrumentation, but I think that's a
>>> reasonable compromise.
>>>
>>> What do you think?
>>  
>> I don't understand why we trying to invent some hacky/complex schemes when we already have
>> a simple one - scaling shadow to 1/32. It's easy to implement and should be more performant comparing
>> to suggested schemes.
> 
> My approach can co-exist with changing scaling approach. It has it's
> own benefit.
> 
> And, as Dmitry mentioned before, scaling shadow to 1/32 also has downsides,
> expecially for inline instrumentation. And, it requires compiler
> modification and user needs to update their compiler to newer version
> which is not so simple in terms of the user's usability
> 
> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
