Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 249D56B0392
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 14:06:37 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id b202so50406053vka.7
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 11:06:37 -0700 (PDT)
Received: from mail-vk0-x232.google.com (mail-vk0-x232.google.com. [2607:f8b0:400c:c05::232])
        by mx.google.com with ESMTPS id f199si7389416vke.251.2017.03.21.11.06.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 11:06:36 -0700 (PDT)
Received: by mail-vk0-x232.google.com with SMTP id j64so88364807vkg.3
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 11:06:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170321104139.GA22188@leverpostej>
References: <cover.1489519233.git.dvyukov@google.com> <6bb1c71b87b300d04977c34f0cd8586363bc6170.1489519233.git.dvyukov@google.com>
 <20170320171718.GL31213@leverpostej> <956a8e10-e03f-a21c-99d9-8a75c2616e0a@virtuozzo.com>
 <20170321104139.GA22188@leverpostej>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 21 Mar 2017 19:06:14 +0100
Message-ID: <CACT4Y+bNrh_a8mBth7ewHS-Fk=wgCky4=Uc89ePeuh5jrLvCQg@mail.gmail.com>
Subject: Re: [PATCH 2/3] asm-generic, x86: wrap atomic operations
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Mar 21, 2017 at 11:41 AM, Mark Rutland <mark.rutland@arm.com> wrote:
> On Tue, Mar 21, 2017 at 12:25:06PM +0300, Andrey Ryabinin wrote:
>> On 03/20/2017 08:17 PM, Mark Rutland wrote:
>> > Hi,
>> >
>> > On Tue, Mar 14, 2017 at 08:24:13PM +0100, Dmitry Vyukov wrote:
>> >>  /**
>> >> - * atomic_read - read atomic variable
>> >> + * arch_atomic_read - read atomic variable
>> >>   * @v: pointer of type atomic_t
>> >>   *
>> >>   * Atomically reads the value of @v.
>> >>   */
>> >> -static __always_inline int atomic_read(const atomic_t *v)
>> >> +static __always_inline int arch_atomic_read(const atomic_t *v)
>> >>  {
>> >> -  return READ_ONCE((v)->counter);
>> >> +  /*
>> >> +   * We use READ_ONCE_NOCHECK() because atomic_read() contains KASAN
>> >> +   * instrumentation. Double instrumentation is unnecessary.
>> >> +   */
>> >> +  return READ_ONCE_NOCHECK((v)->counter);
>> >>  }
>> >
>> > Just to check, we do this to avoid duplicate reports, right?
>> >
>> > If so, double instrumentation isn't solely "unnecessary"; it has a
>> > functional difference, and we should explicitly describe that in the
>> > comment.
>> >
>> > ... or are duplicate reports supressed somehow?
>>
>> They are not suppressed yet. But I think we should just switch kasan
>> to single shot mode, i.e. report only the first error. Single bug
>> quite often has multiple invalid memory accesses causing storm in
>> dmesg. Also write OOB might corrupt metadata so the next report will
>> print bogus alloc/free stacktraces.
>> In most cases we need to look only at the first report, so reporting
>> anything after the first is just counterproductive.
>
> FWIW, that sounds sane to me.
>
> Given that, I agree with your comment regarding READ_ONCE{,_NOCHECK}().
>
> If anyone really wants all the reports, we could have a boot-time option
> to do that.


I don't mind changing READ_ONCE_NOCHECK to READ_ONCE. But I don't have
strong preference either way.

We could do:
#define arch_atomic_read_is_already_instrumented 1
and then skip instrumentation in asm-generic if it's defined. But I
don't think it's worth it.

There is no functional difference, it's only an optimization (now
somewhat questionable). As Andrey said, one can get a splash of
reports anyway, and it's the first one that is important. We use KASAN
with panic_on_warn=1 so we don't even see the rest.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
