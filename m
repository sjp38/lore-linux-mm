Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C51676B02C3
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 09:33:58 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b11so10237921wmh.0
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 06:33:58 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id f38si1908481wra.124.2017.06.28.06.33.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 28 Jun 2017 06:33:57 -0700 (PDT)
Date: Wed, 28 Jun 2017 15:33:25 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] locking/atomics: don't alias ____ptr
In-Reply-To: <CACT4Y+b+a04gyjcsaBGHnm_JhQW4V+TWjfw7POjTRMB4mA6icQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1706281532400.1970@nanos>
References: <cover.1498140838.git.dvyukov@google.com> <85d51d3551b676ba1fc40e8fbddd2eadd056d8dd.1498140838.git.dvyukov@google.com> <20170628100246.7nsvhblgi3xjbc4m@breakpoint.cc> <CACT4Y+Yhy-jucOC37um5xZewEj0sdw8Hjte7oOYxDdxkzOTYoA@mail.gmail.com>
 <alpine.DEB.2.20.1706281306120.1970@nanos> <CACT4Y+YqCP8RC9nRo5oBw2GFdFF+AVJgpcGGENR7hHL9s3GSHg@mail.gmail.com> <alpine.DEB.2.20.1706281423390.1970@nanos> <CACT4Y+b+a04gyjcsaBGHnm_JhQW4V+TWjfw7POjTRMB4mA6icQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, 28 Jun 2017, Dmitry Vyukov wrote:
> On Wed, Jun 28, 2017 at 2:24 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > On Wed, 28 Jun 2017, Dmitry Vyukov wrote:
> >> On Wed, Jun 28, 2017 at 1:10 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> >> >  #define cmpxchg_local(ptr, old, new)                   \
> >> >  ({                                                     \
> >> > -       __typeof__(ptr) ____ptr = (ptr);                \
> >> > -       kasan_check_write(____ptr, sizeof(*____ptr));   \
> >> > -       arch_cmpxchg_local(____ptr, (old), (new));      \
> >> > +       kasan_check_write((ptr), sizeof(*(ptr)));       \
> >> > +       arch_cmpxchg_local((ptr), (old), (new));        \
> >>
> >>
> >> /\/\/\/\/\/\/\/\/\/\/\/\
> >>
> >> These are macros.
> >> If ptr is foo(), then we will call foo() twice.
> >
> > If that's true, the foo() will be evaluated a gazillion more times down the
> > way to the end of this macro maze.
> 
> No. If we do:
> 
> __typeof__(ptr) ____ptr = (ptr);
> 
> and then only use ____ptr, then ptr is evaluated only once regardless
> of what the rest of macros do.

What I meant is, that we have today nested macros which do a lot of that
same nonsense even w/o that patch.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
