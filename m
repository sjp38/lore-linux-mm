Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8A3EF6B0279
	for <linux-mm@kvack.org>; Wed, 31 May 2017 01:51:01 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y65so7704119pff.13
        for <linux-mm@kvack.org>; Tue, 30 May 2017 22:51:01 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id 88si34484226pld.278.2017.05.30.22.51.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 22:51:00 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id u26so1248430pfd.2
        for <linux-mm@kvack.org>; Tue, 30 May 2017 22:51:00 -0700 (PDT)
Date: Wed, 31 May 2017 14:50:49 +0900
From: Joonsoo Kim <js1304@gmail.com>
Subject: Re: [PATCH v1 00/11] mm/kasan: support per-page shadow memory to
 reduce memory consumption
Message-ID: <20170531055047.GA21606@js1304-desktop>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3a7664a9-e360-ab68-610a-1b697a4b00b5@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com

On Tue, May 30, 2017 at 05:16:56PM +0300, Andrey Ryabinin wrote:
> On 05/29/2017 06:29 PM, Dmitry Vyukov wrote:
> > Joonsoo,
> > 
> > I guess mine (and Andrey's) main concern is the amount of additional
> > complexity (I am still struggling to understand how it all works) and
> > more arch-dependent code in exchange for moderate memory win.
> > 
> > Joonsoo, Andrey,
> > 
> > I have an alternative proposal. It should be conceptually simpler and
> > also less arch-dependent. But I don't know if I miss something
> > important that will render it non working.
> > Namely, we add a pointer to shadow to the page struct. Then, create a
> > slab allocator for 512B shadow blocks. Then, attach/detach these
> > shadow blocks to page structs as necessary. It should lead to even
> > smaller memory consumption because we won't need a whole shadow page
> > when only 1 out of 8 corresponding kernel pages are used (we will need
> > just a single 512B block). I guess with some fragmentation we need
> > lots of excessive shadow with the current proposed patch.
> > This does not depend on TLB in any way and does not require hooking
> > into buddy allocator.
> > The main downside is that we will need to be careful to not assume
> > that shadow is continuous. In particular this means that this mode
> > will work only with outline instrumentation and will need some ifdefs.
> > Also it will be slower due to the additional indirection when
> > accessing shadow, but that's meant as "small but slow" mode as far as
> > I understand.
> 
> It seems that you are forgetting about stack instrumentation.
> You'll have to disable it completely, at least with current implementation of it in gcc.

Correct. Even if we use OUTLINE build, gcc directly inserts codes to the
function prologue/epilogue to mark/unmakr the shadow. And, I'm not
sure we can change it since it would affect performance greately. In
current situation, alternative proposal loses most of benefit mentioned
above.
> 
> > But the main win as I see it is that that's basically complete support
> > for 32-bit arches. People do ask about arm32 support:
> > https://groups.google.com/d/msg/kasan-dev/Sk6BsSPMRRc/Gqh4oD_wAAAJ
> > https://groups.google.com/d/msg/kasan-dev/B22vOFp-QWg/EVJPbrsgAgAJ
> > and probably mips32 is relevant as well.
> 
> I don't see how above is relevant for 32-bit arches. Current design
> is perfectly fine for 32-bit arches. I did some POC arm32 port couple years
> ago - https://github.com/aryabinin/linux/commits/kasan/arm_v0_1
> It has some ugly hacks and non-critical bugs. AFAIR it also super-slow because I (mistakenly) 
> made shadow memory uncached. But otherwise it works.

Could you explain that where is the code to map shadow memory uncached?
I don't find anything related to it.

> > Such mode does not require a huge continuous address space range, has
> > minimal memory consumption and requires minimal arch-dependent code.
> > Works only with outline instrumentation, but I think that's a
> > reasonable compromise.
> > 
> > What do you think?
>  
> I don't understand why we trying to invent some hacky/complex schemes when we already have
> a simple one - scaling shadow to 1/32. It's easy to implement and should be more performant comparing
> to suggested schemes.

My approach can co-exist with changing scaling approach. It has it's
own benefit.

And, as Dmitry mentioned before, scaling shadow to 1/32 also has downsides,
expecially for inline instrumentation. And, it requires compiler
modification and user needs to update their compiler to newer version
which is not so simple in terms of the user's usability

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
