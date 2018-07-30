Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id C91156B000D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 05:40:51 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id w21-v6so2563807lji.6
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 02:40:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i13-v6sor869100lfk.180.2018.07.30.02.40.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Jul 2018 02:40:50 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <20180730091934.omn2vj6eyh6kaecs@lakrids.cambridge.arm.com>
References: <CA+icZUVQZtvLg6XGwnS-4Zgv+tkCGWw5Ue8_585H_xNOofX76Q@mail.gmail.com>
 <20180730091934.omn2vj6eyh6kaecs@lakrids.cambridge.arm.com>
From: Sedat Dilek <sedat.dilek@gmail.com>
Date: Mon, 30 Jul 2018 11:40:49 +0200
Message-ID: <CA+icZUUicAr5hBB9oGtuLhygP4pf39YV9hhrg7GpJQUibZu=ig@mail.gmail.com>
Subject: Re: [llvmlinux] clang fails on linux-next since commit 8bf705d13039
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Matthias Kaehlcke <mka@chromium.org>, Dmitry Vyukov <dvyukov@google.com>, Greg Hackmann <ghackmann@google.com>, Luis Lozano <llozano@google.com>, Michael Davidson <md@google.com>, Nick Desaulniers <ndesaulniers@google.com>, Paul Lawrence <paullawrence@google.com>, Sami Tolvanen <samitolvanen@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org, llvmlinux@lists.linuxfoundation.org, sil2review@lists.osadl.org, Jan Beulich <JBeulich@suse.com>, Peter Zijlstra <peterz@infradead.org>, Kees Cook <keescook@chromium.org>, Colin King <colin.king@canonical.com>

On Mon, Jul 30, 2018 at 11:19 AM, Mark Rutland <mark.rutland@arm.com> wrote:
> On Mon, Jul 30, 2018 at 11:09:54AM +0200, Sedat Dilek wrote:
>> On Mon, Jul 30, 2018 at 10:21 AM, Mark Rutland <mark.rutland@arm.com> wrote:
>> > On Sun, Jul 29, 2018 at 08:12:00PM +0200, Sedat Dilek wrote:
>> >> I was able to build a Linux v4.18-rc6 with tip.git#locking/core [1] on
>> >> top of it here on Debian/buster AMD64.
>> >>
>> >> The patch of interest is [2]...
>> >>
>> >> df79ed2c0643 locking/atomics: Simplify cmpxchg() instrumentation
>> >>
>> >> ...and some more locking/atomics[/x86] may be interesting.
>> >>
>> >> I had also to apply an asm-goto fix to reduce the number of warnings
>> >> when building with clang-7 (version
>> >> 7.0.0-svn337957-1~exp1+0~20180725200907.1908~1.gbpcccb1b (trunk)).
>
>> >> The kernel does ***not boot*** on bare metal.
>> >
>> > Ok. Does the prior commit boot?
>>
>> I cannot say as I was not able to compile with clang since the commit
>> 8bf705d13039 mentioned here in the subject.
>
>> Kees pointed me to issue #7 "__builtin_constant_p() does not work in
>> deep inline functions" which is the cause for not booting.
>> The issue is known as #7.
>>
>> My qemu-log.txt is attached for details if you want to look at.
>>
>> [1] https://github.com/ClangBuiltLinux/linux/issues/7
>>
>> >> More details see [4] and [5] for the clang-side.
>> >
>> > It's not clear to me how these relate to the patch in question. AFAICT,
>> > those are build-time errors, but you say that the kernel doesn't boot
>> > (which implies it built).
>> >
>> > Are [4,5] relevant to this commit, or to the (unrelated) issue [3]?
>> >
>> > My patch removes the switch, so this doesn't look like the same issue.
>>
>> ClangBuiltLinux issue #3 "clang validates extended assembly
>> constraints of dead code" is the problem on the clang-side.
>> Matthias and Jan commented on the thread [1] if you want to read.
>> You fixed the issue on the kernel-side, so that I could build a Linux
>> v4.18-rc6 with clang-7 (trunk).
>> This is a huge progress - really.
>>
>> [1] https://groups.google.com/forum/#!topic/kasan-dev/oMgCP37n1vw
>>
>> Is this a bit clearer, now?
>
> Yes; I had misunderstood your mail as reporting a regression resulting
> from my patch, rather than an improvement.
>
> IIUC, commit df79ed2c0643 ("locking/atomics: Simplify cmpxchg()
> instrumentation") happens to make the kernel compile with clang, when it
> would not previously (since commit 8bf705d13039).
>
> Given that you seem to understand the remaining issue, I take it that
> there is nothing that I need to do here.
>
> Thanks,
> Mark.
>

What are your plans to have...

4d2b25f630c7 locking/atomics: Instrument cmpxchg_double*()
f9881cc43b11 locking/atomics: Instrument xchg()
df79ed2c0643 locking/atomics: Simplify cmpxchg() instrumentation
00d5551cc4ee locking/atomics/x86: Reduce arch_cmpxchg64*() instrumentation

...for example in Linux 4.18 or 4.17.y?

Thanks,
- Sedat -
