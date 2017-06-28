Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7E9166B02C3
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 07:12:53 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id q184so19308360oih.5
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 04:12:53 -0700 (PDT)
Received: from mail-oi0-x231.google.com (mail-oi0-x231.google.com. [2607:f8b0:4003:c06::231])
        by mx.google.com with ESMTPS id u187si1182227oie.76.2017.06.28.04.12.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jun 2017 04:12:52 -0700 (PDT)
Received: by mail-oi0-x231.google.com with SMTP id p187so38651411oif.3
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 04:12:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1706281306120.1970@nanos>
References: <cover.1498140838.git.dvyukov@google.com> <85d51d3551b676ba1fc40e8fbddd2eadd056d8dd.1498140838.git.dvyukov@google.com>
 <20170628100246.7nsvhblgi3xjbc4m@breakpoint.cc> <CACT4Y+Yhy-jucOC37um5xZewEj0sdw8Hjte7oOYxDdxkzOTYoA@mail.gmail.com>
 <alpine.DEB.2.20.1706281306120.1970@nanos>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 28 Jun 2017 13:12:31 +0200
Message-ID: <CACT4Y+YqCP8RC9nRo5oBw2GFdFF+AVJgpcGGENR7hHL9s3GSHg@mail.gmail.com>
Subject: Re: [PATCH] locking/atomics: don't alias ____ptr
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, Jun 28, 2017 at 1:10 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Wed, 28 Jun 2017, Dmitry Vyukov wrote:
>> On Wed, Jun 28, 2017 at 12:02 PM, Sebastian Andrzej Siewior <bigeasy@linutronix.de> wrote:
>> > @@ -359,16 +359,16 @@ static __always_inline bool atomic64_add_negative(s64 i, atomic64_t *v)
>> >
>> >  #define cmpxchg64(ptr, old, new)                       \
>> >  ({                                                     \
>> > -       __typeof__(ptr) ____ptr = (ptr);                \
>> > -       kasan_check_write(____ptr, sizeof(*____ptr));   \
>> > -       arch_cmpxchg64(____ptr, (old), (new));          \
>> > +       __typeof__(ptr) ____ptr64 = (ptr);              \
>> > +       kasan_check_write(____ptr64, sizeof(*____ptr64));\
>> > +       arch_cmpxchg64(____ptr64, (old), (new));        \
>> >  })
>> >
>> >  #define cmpxchg64_local(ptr, old, new)                 \
>> >  ({                                                     \
>> > -       __typeof__(ptr) ____ptr = (ptr);                \
>> > -       kasan_check_write(____ptr, sizeof(*____ptr));   \
>> > -       arch_cmpxchg64_local(____ptr, (old), (new));    \
>> > +       __typeof__(ptr) ____ptr64 = (ptr);              \
>> > +       kasan_check_write(____ptr64, sizeof(*____ptr64));\
>> > +       arch_cmpxchg64_local(____ptr64, (old), (new));  \
>> >  })
>> >
>> >  #define cmpxchg_double(p1, p2, o1, o2, n1, n2)                         \
>>
>>
>> Doh! Thanks for fixing this. I think I've a similar crash in a
>> different place when I developed the patch.
>> The problem is that when we do:
>>
>>        __typeof__(ptr) ____ptr = (ptr);                \
>>        arch_cmpxchg64_local(____ptr, (old), (new));    \
>>
>> We don't necessary pass value of our just declared ____ptr to
>> arch_cmpxchg64_local(). We just pass a symbolic identifier. So if
>> arch_cmpxchg64_local() declares own ____ptr and then tries to use what
>> we passed ("____ptr") it will actually refer to own variable declared
>> rather than to what we wanted to pass in.
>>
>> In my case I ended up with something like:
>>
>> __typeof__(foo) __ptr = __ptr;
>>
>> which compiler decided to turn into 0.
>>
>> Thank you, macros.
>>
>> We can add more underscores, but the problem can happen again. Should
>> we prefix current function/macro name to all local vars?..
>
> Actually we can void that ___ptr dance completely.
>
> Thanks,
>
>         tglx
>
> 8<--------------------
>
> --- a/include/asm-generic/atomic-instrumented.h
> +++ b/include/asm-generic/atomic-instrumented.h
> @@ -359,37 +359,32 @@ static __always_inline bool atomic64_add
>
>  #define cmpxchg(ptr, old, new)                         \
>  ({                                                     \
> -       __typeof__(ptr) ___ptr = (ptr);                 \
> -       kasan_check_write(___ptr, sizeof(*___ptr));     \
> +       kasan_check_write((ptr), sizeof(*(ptr)));       \
>         arch_cmpxchg((ptr), (old), (new));              \
>  })
>
>  #define sync_cmpxchg(ptr, old, new)                    \
>  ({                                                     \
> -       __typeof__(ptr) ___ptr = (ptr);                 \
> -       kasan_check_write(___ptr, sizeof(*___ptr));     \
> -       arch_sync_cmpxchg(___ptr, (old), (new));        \
> +       kasan_check_write((ptr), sizeof(*(ptr)));       \
> +       arch_sync_cmpxchg((ptr), (old), (new));         \
>  })
>
>  #define cmpxchg_local(ptr, old, new)                   \
>  ({                                                     \
> -       __typeof__(ptr) ____ptr = (ptr);                \
> -       kasan_check_write(____ptr, sizeof(*____ptr));   \
> -       arch_cmpxchg_local(____ptr, (old), (new));      \
> +       kasan_check_write((ptr), sizeof(*(ptr)));       \
> +       arch_cmpxchg_local((ptr), (old), (new));        \


/\/\/\/\/\/\/\/\/\/\/\/\

These are macros.
If ptr is foo(), then we will call foo() twice.


>  })
>
>  #define cmpxchg64(ptr, old, new)                       \
>  ({                                                     \
> -       __typeof__(ptr) ____ptr = (ptr);                \
> -       kasan_check_write(____ptr, sizeof(*____ptr));   \
> -       arch_cmpxchg64(____ptr, (old), (new));          \
> +       kasan_check_write((ptr), sizeof(*(ptr)));       \
> +       arch_cmpxchg64((ptr), (old), (new));            \
>  })
>
>  #define cmpxchg64_local(ptr, old, new)                 \
>  ({                                                     \
> -       __typeof__(ptr) ____ptr = (ptr);                \
> -       kasan_check_write(____ptr, sizeof(*____ptr));   \
> -       arch_cmpxchg64_local(____ptr, (old), (new));    \
> +       kasan_check_write((ptr), sizeof(*(ptr)));       \
> +       arch_cmpxchg64_local((ptr), (old), (new));      \
>  })
>
>  /*
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
