Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9BE686B0343
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 17:20:43 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id i50so333271188otd.3
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 14:20:43 -0700 (PDT)
Received: from mail-ot0-x244.google.com (mail-ot0-x244.google.com. [2607:f8b0:4003:c0f::244])
        by mx.google.com with ESMTPS id v55si9017055otf.27.2017.03.21.14.20.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 14:20:42 -0700 (PDT)
Received: by mail-ot0-x244.google.com with SMTP id y88so686311ota.1
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 14:20:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+bNrh_a8mBth7ewHS-Fk=wgCky4=Uc89ePeuh5jrLvCQg@mail.gmail.com>
References: <cover.1489519233.git.dvyukov@google.com> <6bb1c71b87b300d04977c34f0cd8586363bc6170.1489519233.git.dvyukov@google.com>
 <20170320171718.GL31213@leverpostej> <956a8e10-e03f-a21c-99d9-8a75c2616e0a@virtuozzo.com>
 <20170321104139.GA22188@leverpostej> <CACT4Y+bNrh_a8mBth7ewHS-Fk=wgCky4=Uc89ePeuh5jrLvCQg@mail.gmail.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 21 Mar 2017 22:20:41 +0100
Message-ID: <CAK8P3a3FqENx+tsg3cbbW4CQtpye7k8MedQqMZidxMCrBR8byg@mail.gmail.com>
Subject: Re: [PATCH 2/3] asm-generic, x86: wrap atomic operations
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Mar 21, 2017 at 7:06 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Tue, Mar 21, 2017 at 11:41 AM, Mark Rutland <mark.rutland@arm.com> wrote:
>> On Tue, Mar 21, 2017 at 12:25:06PM +0300, Andrey Ryabinin wrote:
>
> I don't mind changing READ_ONCE_NOCHECK to READ_ONCE. But I don't have
> strong preference either way.
>
> We could do:
> #define arch_atomic_read_is_already_instrumented 1
> and then skip instrumentation in asm-generic if it's defined. But I
> don't think it's worth it.
>
> There is no functional difference, it's only an optimization (now
> somewhat questionable). As Andrey said, one can get a splash of
> reports anyway, and it's the first one that is important. We use KASAN
> with panic_on_warn=1 so we don't even see the rest.

I'm getting couple of new stack size warnings that are all the result
of the _NOCHECK.

/git/arm-soc/mm/page_alloc.c: In function 'show_free_areas':
/git/arm-soc/mm/page_alloc.c:4685:1: error: the frame size of 3368
bytes is larger than 3072 bytes [-Werror=frame-larger-than=]
 }
/git/arm-soc/lib/atomic64_test.c: In function 'test_atomic':
/git/arm-soc/lib/atomic64_test.c:148:1: error: the frame size of 6528
bytes is larger than 3072 bytes [-Werror=frame-larger-than=]
 }
 ^
/git/arm-soc/lib/atomic64_test.c: In function 'test_atomic64':
/git/arm-soc/lib/atomic64_test.c:243:1: error: the frame size of 7112
bytes is larger than 3072 bytes [-Werror=frame-larger-than=]

This is with my previous set of patches already applied, so
READ_ONCE should not cause problems. Reverting
the READ_ONCE_NOCHECK() in atomic_read() and atomic64_read()
back to READ_ONCE()

I also get a build failure as a result of your patch, but this one is
not addressed by using READ_ONCE():

In file included from /git/arm-soc/arch/x86/include/asm/atomic.h:7:0,
                 from /git/arm-soc/include/linux/atomic.h:4,
                 from /git/arm-soc/arch/x86/include/asm/thread_info.h:53,
                 from /git/arm-soc/include/linux/thread_info.h:25,
                 from /git/arm-soc/arch/x86/include/asm/preempt.h:6,
                 from /git/arm-soc/include/linux/preempt.h:80,
                 from /git/arm-soc/include/linux/spinlock.h:50,
                 from /git/arm-soc/include/linux/mmzone.h:7,
                 from /git/arm-soc/include/linux/gfp.h:5,
                 from /git/arm-soc/include/linux/mm.h:9,
                 from /git/arm-soc/mm/slub.c:12:
/git/arm-soc/mm/slub.c: In function '__slab_free':
/git/arm-soc/arch/x86/include/asm/cmpxchg.h:174:2: error: 'asm'
operand has impossible constraints
  asm volatile(pfx "cmpxchg%c4b %2; sete %0"   \
  ^
/git/arm-soc/arch/x86/include/asm/cmpxchg.h:183:2: note: in expansion
of macro '__cmpxchg_double'
  __cmpxchg_double(LOCK_PREFIX, p1, p2, o1, o2, n1, n2)
  ^~~~~~~~~~~~~~~~
/git/arm-soc/include/asm-generic/atomic-instrumented.h:236:2: note: in
expansion of macro 'arch_cmpxchg_double'
  arch_cmpxchg_double(____p1, (p2), (o1), (o2), (n1), (n2)); \
  ^~~~~~~~~~~~~~~~~~~
/git/arm-soc/mm/slub.c:385:7: note: in expansion of macro 'cmpxchg_double'
   if (cmpxchg_double(&page->freelist, &page->counters,
       ^~~~~~~~~~~~~~
/git/arm-soc/scripts/Makefile.build:308: recipe for target 'mm/slub.o' failed

http://pastebin.com/raw/qXVpi9Ev has the defconfig file I used, and I get the
error with any gcc version I tried (4.9 through 7.0.1).

      Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
