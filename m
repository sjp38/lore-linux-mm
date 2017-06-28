Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 484C36B02C3
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 07:22:15 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v60so33215645wrc.7
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 04:22:15 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id k101si1586490wrc.295.2017.06.28.04.22.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 28 Jun 2017 04:22:13 -0700 (PDT)
Date: Wed, 28 Jun 2017 13:21:43 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] locking/atomics: don't alias ____ptr
In-Reply-To: <CACT4Y+YqCP8RC9nRo5oBw2GFdFF+AVJgpcGGENR7hHL9s3GSHg@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1706281315170.1970@nanos>
References: <cover.1498140838.git.dvyukov@google.com> <85d51d3551b676ba1fc40e8fbddd2eadd056d8dd.1498140838.git.dvyukov@google.com> <20170628100246.7nsvhblgi3xjbc4m@breakpoint.cc> <CACT4Y+Yhy-jucOC37um5xZewEj0sdw8Hjte7oOYxDdxkzOTYoA@mail.gmail.com>
 <alpine.DEB.2.20.1706281306120.1970@nanos> <CACT4Y+YqCP8RC9nRo5oBw2GFdFF+AVJgpcGGENR7hHL9s3GSHg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, 28 Jun 2017, Dmitry Vyukov wrote:
> On Wed, Jun 28, 2017 at 1:10 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> >> In my case I ended up with something like:
> >>
> >> __typeof__(foo) __ptr = __ptr;
> >>
> >> which compiler decided to turn into 0.
> >>
> >> Thank you, macros.
> >>
> >> We can add more underscores, but the problem can happen again. Should
> >> we prefix current function/macro name to all local vars?..
> >
> > Actually we can void that ___ptr dance completely.
> >
> > Thanks,
> >
> >         tglx
> >
> > 8<--------------------
> >
> > --- a/include/asm-generic/atomic-instrumented.h
> > +++ b/include/asm-generic/atomic-instrumented.h
> > @@ -359,37 +359,32 @@ static __always_inline bool atomic64_add
> >
> >  #define cmpxchg(ptr, old, new)                         \
> >  ({                                                     \
> > -       __typeof__(ptr) ___ptr = (ptr);                 \
> > -       kasan_check_write(___ptr, sizeof(*___ptr));     \
> > +       kasan_check_write((ptr), sizeof(*(ptr)));       \
> >         arch_cmpxchg((ptr), (old), (new));              \
> >  })
> >
> >  #define sync_cmpxchg(ptr, old, new)                    \
> >  ({                                                     \
> > -       __typeof__(ptr) ___ptr = (ptr);                 \
> > -       kasan_check_write(___ptr, sizeof(*___ptr));     \
> > -       arch_sync_cmpxchg(___ptr, (old), (new));        \
> > +       kasan_check_write((ptr), sizeof(*(ptr)));       \
> > +       arch_sync_cmpxchg((ptr), (old), (new));         \
> >  })
> >
> >  #define cmpxchg_local(ptr, old, new)                   \
> >  ({                                                     \
> > -       __typeof__(ptr) ____ptr = (ptr);                \
> > -       kasan_check_write(____ptr, sizeof(*____ptr));   \
> > -       arch_cmpxchg_local(____ptr, (old), (new));      \
> > +       kasan_check_write((ptr), sizeof(*(ptr)));       \
> > +       arch_cmpxchg_local((ptr), (old), (new));        \
> 
> 
> /\/\/\/\/\/\/\/\/\/\/\/\
> 
> These are macros.
> If ptr is foo(), then we will call foo() twice.

Sigh, is that actually used?

That's all insane. The whole crap gets worse because:

      cmpxchg() can be used on u8, u16, u32 ....

There is a reason why type safety matters.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
