Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 66F946B0279
	for <linux-mm@kvack.org>; Tue, 30 May 2017 10:15:07 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id q27so97620116pfi.8
        for <linux-mm@kvack.org>; Tue, 30 May 2017 07:15:07 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0118.outbound.protection.outlook.com. [104.47.2.118])
        by mx.google.com with ESMTPS id a9si13225313pgf.76.2017.05.30.07.15.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 May 2017 07:15:06 -0700 (PDT)
Subject: Re: [PATCH v1 00/11] mm/kasan: support per-page shadow memory to
 reduce memory consumption
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
 <CACT4Y+ZVrs9XDk5QXkQyej+xFwKrgnGn-RPBC+pL5znUp2aSCg@mail.gmail.com>
 <20170516062318.GC16015@js1304-desktop>
 <CACT4Y+anOw8=7u-pZ2ceMw0xVnuaO9YKBJAr-2=KOYt_72b2pw@mail.gmail.com>
 <CACT4Y+YREmHViSMsH84bwtEqbUsqsgzaa76eWzJXqmSgqKbgvg@mail.gmail.com>
 <20170524074539.GA9697@js1304-desktop>
 <CACT4Y+ZwL+iTMvF5NpsovThQrdhunCc282ffjqQcgZg3tAQH4w@mail.gmail.com>
 <20170525004104.GA21336@js1304-desktop>
 <CACT4Y+YV7Rf93NOa1yi0NiELX7wfwkfQmXJ67hEVOrG7VkuJJg@mail.gmail.com>
 <CACT4Y+ZrUi_YGkwmbuGV2_6wC7Q54at1_xyYeT3dQQ=cNm1NsQ@mail.gmail.com>
 <CACT4Y+bT=aaC+XTMwoON-Rc5gOheAj702anXKJMXDJ5FtLDRMw@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <3a7664a9-e360-ab68-610a-1b697a4b00b5@virtuozzo.com>
Date: Tue, 30 May 2017 17:16:56 +0300
MIME-Version: 1.0
In-Reply-To: <CACT4Y+bT=aaC+XTMwoON-Rc5gOheAj702anXKJMXDJ5FtLDRMw@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com

On 05/29/2017 06:29 PM, Dmitry Vyukov wrote:
> Joonsoo,
> 
> I guess mine (and Andrey's) main concern is the amount of additional
> complexity (I am still struggling to understand how it all works) and
> more arch-dependent code in exchange for moderate memory win.
> 
> Joonsoo, Andrey,
> 
> I have an alternative proposal. It should be conceptually simpler and
> also less arch-dependent. But I don't know if I miss something
> important that will render it non working.
> Namely, we add a pointer to shadow to the page struct. Then, create a
> slab allocator for 512B shadow blocks. Then, attach/detach these
> shadow blocks to page structs as necessary. It should lead to even
> smaller memory consumption because we won't need a whole shadow page
> when only 1 out of 8 corresponding kernel pages are used (we will need
> just a single 512B block). I guess with some fragmentation we need
> lots of excessive shadow with the current proposed patch.
> This does not depend on TLB in any way and does not require hooking
> into buddy allocator.
> The main downside is that we will need to be careful to not assume
> that shadow is continuous. In particular this means that this mode
> will work only with outline instrumentation and will need some ifdefs.
> Also it will be slower due to the additional indirection when
> accessing shadow, but that's meant as "small but slow" mode as far as
> I understand.

It seems that you are forgetting about stack instrumentation.
You'll have to disable it completely, at least with current implementation of it in gcc.

> But the main win as I see it is that that's basically complete support
> for 32-bit arches. People do ask about arm32 support:
> https://groups.google.com/d/msg/kasan-dev/Sk6BsSPMRRc/Gqh4oD_wAAAJ
> https://groups.google.com/d/msg/kasan-dev/B22vOFp-QWg/EVJPbrsgAgAJ
> and probably mips32 is relevant as well.

I don't see how above is relevant for 32-bit arches. Current design
is perfectly fine for 32-bit arches. I did some POC arm32 port couple years
ago - https://github.com/aryabinin/linux/commits/kasan/arm_v0_1
It has some ugly hacks and non-critical bugs. AFAIR it also super-slow because I (mistakenly) 
made shadow memory uncached. But otherwise it works.

> Such mode does not require a huge continuous address space range, has
> minimal memory consumption and requires minimal arch-dependent code.
> Works only with outline instrumentation, but I think that's a
> reasonable compromise.
> 
> What do you think?
 
I don't understand why we trying to invent some hacky/complex schemes when we already have
a simple one - scaling shadow to 1/32. It's easy to implement and should be more performant comparing
to suggested schemes.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
