Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9592B6B0007
	for <linux-mm@kvack.org>; Fri,  1 Jun 2018 09:14:43 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id u13-v6so2743056lfg.10
        for <linux-mm@kvack.org>; Fri, 01 Jun 2018 06:14:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g75-v6sor807424lfe.68.2018.06.01.06.14.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Jun 2018 06:14:41 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <5B0CF7EF02000078001C677A@prv1-mh.provo.novell.com>
References: <alpine.DEB.2.20.1803171208370.21003@alpaca> <CACT4Y+aLqY6wUfRMto_CZxPRSyvPKxK8ucvAmAY-aR_gq8fOAg@mail.gmail.com>
 <20180319172902.GB37438@google.com> <99fbbbe3-df05-446b-9ce0-55787ea038f3@googlegroups.com>
 <CACT4Y+YLj_oNkD7UH-MS3StQG1NBp-gDQ=goKrC9RNET216G-Q@mail.gmail.com>
 <CA+icZUWpg8dAtsBMzhKRt+6fyPdmHqw+Uq28ACr6byYtb42Mtg@mail.gmail.com>
 <CACT4Y+bvN+Fcm6K_UtsL4rqfWtqUimUNpBS4OnviEfbVvPvqHg@mail.gmail.com>
 <CA+icZUVtK+Z_TLSevtheKSBp+WcfP2s+gbZ1meV1e+yKccQJdA@mail.gmail.com> <5B0CF7EF02000078001C677A@prv1-mh.provo.novell.com>
From: Sedat Dilek <sedat.dilek@gmail.com>
Date: Fri, 1 Jun 2018 15:14:40 +0200
Message-ID: <CA+icZUV0Ke=5B7z_2uE5p=+Qw7DL3aZctRA9S3wE1NqJ_bp_pQ@mail.gmail.com>
Subject: Re: [llvmlinux] clang fails on linux-next since commit 8bf705d13039
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Beulich <JBeulich@suse.com>
Cc: Matthias Kaehlcke <mka@chromium.org>, Dmitry Vyukov <dvyukov@google.com>, Greg Hackmann <ghackmann@google.com>, Luis Lozano <llozano@google.com>, Michael Davidson <md@google.com>, Nick Desaulniers <ndesaulniers@google.com>, Paul Lawrence <paullawrence@google.com>, Sami Tolvanen <samitolvanen@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org, llvmlinux@lists.linuxfoundation.org, sil2review@lists.osadl.org

On Tue, May 29, 2018 at 8:49 AM, Jan Beulich <JBeulich@suse.com> wrote:
>>>> On 28.05.18 at 18:05, <sedat.dilek@gmail.com> wrote:
>> On Mon, Mar 19, 2018 at 6:29 PM, Matthias Kaehlcke <mka@chromium.org> wrote:
>>> El Mon, Mar 19, 2018 at 09:43:25AM +0300 Dmitry Vyukov ha dit:
>>>
>>>> On Sat, Mar 17, 2018 at 2:13 PM, Lukas Bulwahn <lukas.bulwahn@gmail.com> wrote:
>>>> > Hi Dmitry, hi Ingo,
>>>> >
>>>> > since commit 8bf705d13039 ("locking/atomic/x86: Switch atomic.h to use atomic-instrumented.h")
>>>> > on linux-next (tested and bisected from tag next-20180316), compiling the
>>>> > kernel with clang fails with:
>>>> >
>>>> > In file included from arch/x86/entry/vdso/vdso32/vclock_gettime.c:33:
>>>> > In file included from arch/x86/entry/vdso/vdso32/../vclock_gettime.c:15:
>>>> > In file included from ./arch/x86/include/asm/vgtod.h:6:
>>>> > In file included from ./include/linux/clocksource.h:13:
>>>> > In file included from ./include/linux/timex.h:56:
>>>> > In file included from ./include/uapi/linux/timex.h:56:
>>>> > In file included from ./include/linux/time.h:6:
>>>> > In file included from ./include/linux/seqlock.h:36:
>>>> > In file included from ./include/linux/spinlock.h:51:
>>>> > In file included from ./include/linux/preempt.h:81:
>>>> > In file included from ./arch/x86/include/asm/preempt.h:7:
>>>> > In file included from ./include/linux/thread_info.h:38:
>>>> > In file included from ./arch/x86/include/asm/thread_info.h:53:
>>>> > In file included from ./arch/x86/include/asm/cpufeature.h:5:
>>>> > In file included from ./arch/x86/include/asm/processor.h:21:
>>>> > In file included from ./arch/x86/include/asm/msr.h:67:
>>>> > In file included from ./arch/x86/include/asm/atomic.h:279:
>>>> > ./include/asm-generic/atomic-instrumented.h:295:10: error: invalid output size for constraint '=a'
>>>> >                 return arch_cmpxchg((u64 *)ptr, (u64)old, (u64)new);
>>>> >                        ^
>>>> > ./arch/x86/include/asm/cmpxchg.h:149:2: note: expanded from macro 'arch_cmpxchg'
>>>> >         __cmpxchg(ptr, old, new, sizeof(*(ptr)))
>>>> >         ^
>>>> > ./arch/x86/include/asm/cmpxchg.h:134:2: note: expanded from macro '__cmpxchg'
>>>> >         __raw_cmpxchg((ptr), (old), (new), (size), LOCK_PREFIX)
>>>> >         ^
>>>> > ./arch/x86/include/asm/cmpxchg.h:95:17: note: expanded from macro '__raw_cmpxchg'
>>>> >                              : "=a" (__ret), "+m" (*__ptr)              \
>>>> >                                      ^
>>>> >
>>>> > (... and some more similar and closely related errors)
>>>>
>>>>
>>>> Thanks for reporting, Lukas.
>>>>
>>>> +more people who are more aware of the current state of clang for kernel.
>>>>
>>>> Are there are known issues in '=a' constraint handling between gcc and
>>>> clang? Is there a recommended way to resolve them?
>>>>
>>>> Also, Lukas what's your version of clang? Potentially there are some
>>>> fixes for kernel in the very latest versions of clang.
>>>
>>> My impression is that the problem only occurs in code built for
>>> 32-bit (like arch/x86/entry/vdso/vdso32/*), where the use of a 64-bit
>>> address with a '=a' constraint is indeed invalid. I think the 'root
>>> cause' is that clang parses unreachable code before it discards it:
>>>
>>> static __always_inline unsigned long
>>> cmpxchg_local_size(volatile void *ptr, unsigned long old, unsigned long new,
>>>                    int size)
>>> {
>>>         ...
>>>         switch (size) {
>>>         ...
>>>         case 8:
>>>                 BUILD_BUG_ON(sizeof(unsigned long) != 8);
>>>                 return arch_cmpxchg_local((u64 *)ptr, (u64)old, (u64)new);
>>>         }
>>>         ...
>>> }
>>>
>>> For 32-bit builds size is 4 and the code in the 'offending' branch is
>>> unreachable, however clang still parses it.
>>>
>>> d135b8b5060e ("arm64: uaccess: suppress spurious clang warning") fixes
>>> a similar issue.
>>>
>>
>> [ CC Jan Beulich ]
>>
>> Hi Jan,
>>
>> can you look at this issue [1] as you have fixed the percpu issue [2]
>> with [3] on the Linux-kernel side?
>
> I don't see the connection between the two problems. The missing suffixes
> were a latent problem with future improved assembler behavior. The issue
> here is completely different. Short of the clang folks being able to point
> out a suitable compiler level workaround, did anyone consider replacing the
> expressions with the casts to u64 by invocations of arch_cmpxchg64() /
> arch_cmpxchg64_local()? Later code in asm-generic/atomic-instrumented.h
> suggests these symbols are required to be defined anyway.
>
> The only other option I see is to break out the __X86_CASE_Q cases into
> separate macros (evaluating to nothing or BUILD_BUG_ON(1) for 32-bit).
> The definition of __X86_CASE_Q for 32-bit is bogus anyway - the
> comment saying "sizeof will never return -1" is meaningless, because for
> the comparison with the expression in switch() the constant from the case
> label is converted to the type of that expression (i.e. size_t) anyway, i.e.
> the value compared against is (size_t)-1, which is a value the compiler
> can't prove that it won't be returned by sizeof() (despite that being
> extremely unlikely).
>

Hi Jan,

Thanks for looking at this.
Maybe one of the CCed folks with better Linux/x86 skills can answer you.

Regards,
- Sedat -

> Jan
>
>> This problem still occurs with Linux v4.17-rc7 and reverting
>> x86/asm-goto support (clang-7 does not support it).
>>
>> Before this gets fixed on the clang-side, do you see a possibility to
>> fix this on the kernel-side?
>>
>> Clang fails like this as reported above and see [4] as mentioned by
>> Matthias before.
>>
>> ./arch/x86/include/asm/cpufeature.h:150:2: warning: "Compiler lacks
>> ASM_GOTO support. Add -D __BPF_TRACING__ to your compiler arguments"
>> [-W#warnings]
>> #warning "Compiler lacks ASM_GOTO support. Add -D __BPF_TRACING__ to
>> your compiler arguments"
>>  ^
>> In file included from arch/x86/entry/vdso/vdso32/vclock_gettime.c:31:
>> In file included from arch/x86/entry/vdso/vdso32/../vclock_gettime.c:15:
>> In file included from ./arch/x86/include/asm/vgtod.h:6:
>> In file included from ./include/linux/clocksource.h:13:
>> In file included from ./include/linux/timex.h:56:
>> In file included from ./include/uapi/linux/timex.h:56:
>> In file included from ./include/linux/time.h:6:
>> In file included from ./include/linux/seqlock.h:36:
>> In file included from ./include/linux/spinlock.h:51:
>> In file included from ./include/linux/preempt.h:81:
>> In file included from ./arch/x86/include/asm/preempt.h:7:
>> In file included from ./include/linux/thread_info.h:38:
>> In file included from ./arch/x86/include/asm/thread_info.h:53:
>> In file included from ./arch/x86/include/asm/cpufeature.h:5:
>> In file included from ./arch/x86/include/asm/processor.h:21:
>> In file included from ./arch/x86/include/asm/msr.h:67:
>> In file included from ./arch/x86/include/asm/atomic.h:283:
>> ./include/asm-generic/atomic-instrumented.h:365:10: error: invalid
>> output size for constraint '=a'
>>                 return arch_cmpxchg((u64 *)ptr, (u64)old, (u64)new);
>>                        ^
>> ./arch/x86/include/asm/cmpxchg.h:149:2: note: expanded from macro
>> 'arch_cmpxchg'
>>         __cmpxchg(ptr, old, new, sizeof(*(ptr)))
>>         ^
>> ./arch/x86/include/asm/cmpxchg.h:134:2: note: expanded from macro
>> '__cmpxchg'
>>         __raw_cmpxchg((ptr), (old), (new), (size), LOCK_PREFIX)
>>         ^
>> ./arch/x86/include/asm/cmpxchg.h:95:17: note: expanded from macro
>> '__raw_cmpxchg'
>>                              : "=a" (__ret), "+m" (*__ptr)              \
>>                                      ^
>>
>> Thanks in advance.
>>
>> Regards,
>> - Sedat -
>>
>> [1] https://bugs.llvm.org/show_bug.cgi?id=33587
>> [2] https://bugs.llvm.org/show_bug.cgi?id=33587#c18
>> [3] https://git.kernel.org/linus/22636f8c9511245cb3c8412039f1dd95afb3aa59
>> [4]
>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/inclu
>> de/asm-generic/atomic-instrumented.h#n365
>
>
>
