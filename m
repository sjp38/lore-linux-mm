Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id AB5966B02F4
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 22:40:24 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id e187so2078527pgc.7
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 19:40:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y1sor2780446pli.2.2017.06.07.19.40.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Jun 2017 19:40:23 -0700 (PDT)
Date: Thu, 8 Jun 2017 11:40:16 +0900
From: Joonsoo Kim <js1304@gmail.com>
Subject: Re: [PATCH v1 00/11] mm/kasan: support per-page shadow memory to
 reduce memory consumption
Message-ID: <20170608024014.GB27998@js1304-desktop>
References: <CACT4Y+anOw8=7u-pZ2ceMw0xVnuaO9YKBJAr-2=KOYt_72b2pw@mail.gmail.com>
 <CACT4Y+YREmHViSMsH84bwtEqbUsqsgzaa76eWzJXqmSgqKbgvg@mail.gmail.com>
 <20170524074539.GA9697@js1304-desktop>
 <CACT4Y+ZwL+iTMvF5NpsovThQrdhunCc282ffjqQcgZg3tAQH4w@mail.gmail.com>
 <20170525004104.GA21336@js1304-desktop>
 <CACT4Y+YV7Rf93NOa1yi0NiELX7wfwkfQmXJ67hEVOrG7VkuJJg@mail.gmail.com>
 <CACT4Y+ZrUi_YGkwmbuGV2_6wC7Q54at1_xyYeT3dQQ=cNm1NsQ@mail.gmail.com>
 <CACT4Y+bT=aaC+XTMwoON-Rc5gOheAj702anXKJMXDJ5FtLDRMw@mail.gmail.com>
 <3a7664a9-e360-ab68-610a-1b697a4b00b5@virtuozzo.com>
 <CACT4Y+at_NESQ8qq4zouArnu5yySQHxC2oW+RuXzqX8hyspZ_g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+at_NESQ8qq4zouArnu5yySQHxC2oW+RuXzqX8hyspZ_g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com

On Thu, Jun 01, 2017 at 08:06:02PM +0200, Dmitry Vyukov wrote:
> On Tue, May 30, 2017 at 4:16 PM, Andrey Ryabinin
> <aryabinin@virtuozzo.com> wrote:
> > On 05/29/2017 06:29 PM, Dmitry Vyukov wrote:
> >> Joonsoo,
> >>
> >> I guess mine (and Andrey's) main concern is the amount of additional
> >> complexity (I am still struggling to understand how it all works) and
> >> more arch-dependent code in exchange for moderate memory win.
> >>
> >> Joonsoo, Andrey,
> >>
> >> I have an alternative proposal. It should be conceptually simpler and
> >> also less arch-dependent. But I don't know if I miss something
> >> important that will render it non working.
> >> Namely, we add a pointer to shadow to the page struct. Then, create a
> >> slab allocator for 512B shadow blocks. Then, attach/detach these
> >> shadow blocks to page structs as necessary. It should lead to even
> >> smaller memory consumption because we won't need a whole shadow page
> >> when only 1 out of 8 corresponding kernel pages are used (we will need
> >> just a single 512B block). I guess with some fragmentation we need
> >> lots of excessive shadow with the current proposed patch.
> >> This does not depend on TLB in any way and does not require hooking
> >> into buddy allocator.
> >> The main downside is that we will need to be careful to not assume
> >> that shadow is continuous. In particular this means that this mode
> >> will work only with outline instrumentation and will need some ifdefs.
> >> Also it will be slower due to the additional indirection when
> >> accessing shadow, but that's meant as "small but slow" mode as far as
> >> I understand.
> >
> > It seems that you are forgetting about stack instrumentation.
> > You'll have to disable it completely, at least with current implementation of it in gcc.
> >
> >> But the main win as I see it is that that's basically complete support
> >> for 32-bit arches. People do ask about arm32 support:
> >> https://groups.google.com/d/msg/kasan-dev/Sk6BsSPMRRc/Gqh4oD_wAAAJ
> >> https://groups.google.com/d/msg/kasan-dev/B22vOFp-QWg/EVJPbrsgAgAJ
> >> and probably mips32 is relevant as well.
> >
> > I don't see how above is relevant for 32-bit arches. Current design
> > is perfectly fine for 32-bit arches. I did some POC arm32 port couple years
> > ago - https://github.com/aryabinin/linux/commits/kasan/arm_v0_1
> > It has some ugly hacks and non-critical bugs. AFAIR it also super-slow because I (mistakenly)
> > made shadow memory uncached. But otherwise it works.
> >
> >> Such mode does not require a huge continuous address space range, has
> >> minimal memory consumption and requires minimal arch-dependent code.
> >> Works only with outline instrumentation, but I think that's a
> >> reasonable compromise.
> >>
> >> What do you think?
> >
> > I don't understand why we trying to invent some hacky/complex schemes when we already have
> > a simple one - scaling shadow to 1/32. It's easy to implement and should be more performant comparing
> > to suggested schemes.
> 
> 
> If 32-bits work with the current approach, then I would also prefer to
> keep things simpler.
> FWIW clang supports settings shadow scale via a command line flag
> (-asan-mapping-scale).

Hello,

To confirm the final consensus, I did a quick comparison of scaling
approach and mine. Note that scaling approach can be co-exist with
mine. And, there is an assumption that we can disable quarantine and
other optional feature of KASAN.

Scaling vs Mine

Memory usage: 1/32 of total memory. vs can be far less than 1/32.
Slab object layout: should be changed. vs none.
Usability: hard. vs simple. (Updating compiler is not required)
Implementation complexity: simple. vs complex.
Porting to other ARCH: simple. vs hard (But, not mandatory)

So, do both you disagree to merge my per-page shadow? If so, I will
not submit v2. Please let me know your decision.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
