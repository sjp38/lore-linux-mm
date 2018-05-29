Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 846436B0003
	for <linux-mm@kvack.org>; Tue, 29 May 2018 02:49:25 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 89-v6so8802550plb.18
        for <linux-mm@kvack.org>; Mon, 28 May 2018 23:49:25 -0700 (PDT)
Received: from prv1-mh.provo.novell.com (prv1-mh.provo.novell.com. [137.65.248.33])
        by mx.google.com with ESMTPS id y13-v6si24078377pge.290.2018.05.28.23.49.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 May 2018 23:49:24 -0700 (PDT)
Message-Id: <5B0CF7EF02000078001C677A@prv1-mh.provo.novell.com>
Date: Tue, 29 May 2018 00:49:19 -0600
From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [llvmlinux] clang fails on linux-next since commit
 8bf705d13039
References: <alpine.DEB.2.20.1803171208370.21003@alpaca>
 <CACT4Y+aLqY6wUfRMto_CZxPRSyvPKxK8ucvAmAY-aR_gq8fOAg@mail.gmail.com>
 <20180319172902.GB37438@google.com>
 <99fbbbe3-df05-446b-9ce0-55787ea038f3@googlegroups.com>
 <CACT4Y+YLj_oNkD7UH-MS3StQG1NBp-gDQ=goKrC9RNET216G-Q@mail.gmail.com>
 <CA+icZUWpg8dAtsBMzhKRt+6fyPdmHqw+Uq28ACr6byYtb42Mtg@mail.gmail.com>
 <CACT4Y+bvN+Fcm6K_UtsL4rqfWtqUimUNpBS4OnviEfbVvPvqHg@mail.gmail.com>
 <CA+icZUVtK+Z_TLSevtheKSBp+WcfP2s+gbZ1meV1e+yKccQJdA@mail.gmail.com>
In-Reply-To: <CA+icZUVtK+Z_TLSevtheKSBp+WcfP2s+gbZ1meV1e+yKccQJdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sedat.dilek@gmail.com
Cc: Matthias Kaehlcke <mka@chromium.org>, Dmitry Vyukov <dvyukov@google.com>, Greg Hackmann <ghackmann@google.com>, Luis Lozano <llozano@google.com>, Michael Davidson <md@google.com>, Nick Desaulniers <ndesaulniers@google.com>, Paul Lawrence <paullawrence@google.com>, Sami Tolvanen <samitolvanen@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org, llvmlinux@lists.linuxfoundation.org, sil2review@lists.osadl.org

>>> On 28.05.18 at 18:05, <sedat.dilek@gmail.com> wrote:
> On Mon, Mar 19, 2018 at 6:29 PM, Matthias Kaehlcke <mka@chromium.org> =
wrote:
>> El Mon, Mar 19, 2018 at 09:43:25AM +0300 Dmitry Vyukov ha dit:
>>
>>> On Sat, Mar 17, 2018 at 2:13 PM, Lukas Bulwahn <lukas.bulwahn@gmail.com=
> wrote:
>>> > Hi Dmitry, hi Ingo,
>>> >
>>> > since commit 8bf705d13039 ("locking/atomic/x86: Switch atomic.h to =
use atomic-instrumented.h")
>>> > on linux-next (tested and bisected from tag next-20180316), =
compiling the
>>> > kernel with clang fails with:
>>> >
>>> > In file included from arch/x86/entry/vdso/vdso32/vclock_gettime.c:33:=

>>> > In file included from arch/x86/entry/vdso/vdso32/../vclock_gettime.c:=
15:
>>> > In file included from ./arch/x86/include/asm/vgtod.h:6:
>>> > In file included from ./include/linux/clocksource.h:13:
>>> > In file included from ./include/linux/timex.h:56:
>>> > In file included from ./include/uapi/linux/timex.h:56:
>>> > In file included from ./include/linux/time.h:6:
>>> > In file included from ./include/linux/seqlock.h:36:
>>> > In file included from ./include/linux/spinlock.h:51:
>>> > In file included from ./include/linux/preempt.h:81:
>>> > In file included from ./arch/x86/include/asm/preempt.h:7:
>>> > In file included from ./include/linux/thread_info.h:38:
>>> > In file included from ./arch/x86/include/asm/thread_info.h:53:
>>> > In file included from ./arch/x86/include/asm/cpufeature.h:5:
>>> > In file included from ./arch/x86/include/asm/processor.h:21:
>>> > In file included from ./arch/x86/include/asm/msr.h:67:
>>> > In file included from ./arch/x86/include/asm/atomic.h:279:
>>> > ./include/asm-generic/atomic-instrumented.h:295:10: error: invalid =
output size for constraint '=3Da'
>>> >                 return arch_cmpxchg((u64 *)ptr, (u64)old, (u64)new);
>>> >                        ^
>>> > ./arch/x86/include/asm/cmpxchg.h:149:2: note: expanded from macro =
'arch_cmpxchg'
>>> >         __cmpxchg(ptr, old, new, sizeof(*(ptr)))
>>> >         ^
>>> > ./arch/x86/include/asm/cmpxchg.h:134:2: note: expanded from macro =
'__cmpxchg'
>>> >         __raw_cmpxchg((ptr), (old), (new), (size), LOCK_PREFIX)
>>> >         ^
>>> > ./arch/x86/include/asm/cmpxchg.h:95:17: note: expanded from macro =
'__raw_cmpxchg'
>>> >                              : "=3Da" (__ret), "+m" (*__ptr)         =
     \
>>> >                                      ^
>>> >
>>> > (... and some more similar and closely related errors)
>>>
>>>
>>> Thanks for reporting, Lukas.
>>>
>>> +more people who are more aware of the current state of clang for =
kernel.
>>>
>>> Are there are known issues in '=3Da' constraint handling between gcc =
and
>>> clang? Is there a recommended way to resolve them?
>>>
>>> Also, Lukas what's your version of clang? Potentially there are some
>>> fixes for kernel in the very latest versions of clang.
>>
>> My impression is that the problem only occurs in code built for
>> 32-bit (like arch/x86/entry/vdso/vdso32/*), where the use of a 64-bit
>> address with a '=3Da' constraint is indeed invalid. I think the 'root
>> cause' is that clang parses unreachable code before it discards it:
>>
>> static __always_inline unsigned long
>> cmpxchg_local_size(volatile void *ptr, unsigned long old, unsigned long =
new,
>>                    int size)
>> {
>>         ...
>>         switch (size) {
>>         ...
>>         case 8:
>>                 BUILD_BUG_ON(sizeof(unsigned long) !=3D 8);
>>                 return arch_cmpxchg_local((u64 *)ptr, (u64)old, =
(u64)new);
>>         }
>>         ...
>> }
>>
>> For 32-bit builds size is 4 and the code in the 'offending' branch is
>> unreachable, however clang still parses it.
>>
>> d135b8b5060e ("arm64: uaccess: suppress spurious clang warning") fixes
>> a similar issue.
>>
>=20
> [ CC Jan Beulich ]
>=20
> Hi Jan,
>=20
> can you look at this issue [1] as you have fixed the percpu issue [2]
> with [3] on the Linux-kernel side?

I don't see the connection between the two problems. The missing suffixes
were a latent problem with future improved assembler behavior. The issue
here is completely different. Short of the clang folks being able to point
out a suitable compiler level workaround, did anyone consider replacing =
the
expressions with the casts to u64 by invocations of arch_cmpxchg64() /
arch_cmpxchg64_local()? Later code in asm-generic/atomic-instrumented.h
suggests these symbols are required to be defined anyway.

The only other option I see is to break out the __X86_CASE_Q cases into
separate macros (evaluating to nothing or BUILD_BUG_ON(1) for 32-bit).
The definition of __X86_CASE_Q for 32-bit is bogus anyway - the
comment saying "sizeof will never return -1" is meaningless, because for
the comparison with the expression in switch() the constant from the case
label is converted to the type of that expression (i.e. size_t) anyway, =
i.e.
the value compared against is (size_t)-1, which is a value the compiler
can't prove that it won't be returned by sizeof() (despite that being
extremely unlikely).

Jan

> This problem still occurs with Linux v4.17-rc7 and reverting
> x86/asm-goto support (clang-7 does not support it).
>=20
> Before this gets fixed on the clang-side, do you see a possibility to
> fix this on the kernel-side?
>=20
> Clang fails like this as reported above and see [4] as mentioned by
> Matthias before.
>=20
> ./arch/x86/include/asm/cpufeature.h:150:2: warning: "Compiler lacks
> ASM_GOTO support. Add -D __BPF_TRACING__ to your compiler arguments"
> [-W#warnings]
> #warning "Compiler lacks ASM_GOTO support. Add -D __BPF_TRACING__ to
> your compiler arguments"
>  ^
> In file included from arch/x86/entry/vdso/vdso32/vclock_gettime.c:31:
> In file included from arch/x86/entry/vdso/vdso32/../vclock_gettime.c:15:
> In file included from ./arch/x86/include/asm/vgtod.h:6:
> In file included from ./include/linux/clocksource.h:13:
> In file included from ./include/linux/timex.h:56:
> In file included from ./include/uapi/linux/timex.h:56:
> In file included from ./include/linux/time.h:6:
> In file included from ./include/linux/seqlock.h:36:
> In file included from ./include/linux/spinlock.h:51:
> In file included from ./include/linux/preempt.h:81:
> In file included from ./arch/x86/include/asm/preempt.h:7:
> In file included from ./include/linux/thread_info.h:38:
> In file included from ./arch/x86/include/asm/thread_info.h:53:
> In file included from ./arch/x86/include/asm/cpufeature.h:5:
> In file included from ./arch/x86/include/asm/processor.h:21:
> In file included from ./arch/x86/include/asm/msr.h:67:
> In file included from ./arch/x86/include/asm/atomic.h:283:
> ./include/asm-generic/atomic-instrumented.h:365:10: error: invalid
> output size for constraint '=3Da'
>                 return arch_cmpxchg((u64 *)ptr, (u64)old, (u64)new);
>                        ^
> ./arch/x86/include/asm/cmpxchg.h:149:2: note: expanded from macro=20
> 'arch_cmpxchg'
>         __cmpxchg(ptr, old, new, sizeof(*(ptr)))
>         ^
> ./arch/x86/include/asm/cmpxchg.h:134:2: note: expanded from macro=20
> '__cmpxchg'
>         __raw_cmpxchg((ptr), (old), (new), (size), LOCK_PREFIX)
>         ^
> ./arch/x86/include/asm/cmpxchg.h:95:17: note: expanded from macro
> '__raw_cmpxchg'
>                              : "=3Da" (__ret), "+m" (*__ptr)             =
 \
>                                      ^
>=20
> Thanks in advance.
>=20
> Regards,
> - Sedat -
>=20
> [1] https://bugs.llvm.org/show_bug.cgi?id=3D33587=20
> [2] https://bugs.llvm.org/show_bug.cgi?id=3D33587#c18=20
> [3] https://git.kernel.org/linus/22636f8c9511245cb3c8412039f1dd95afb3aa59=
=20
> [4]=20
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/i=
nclu=20
> de/asm-generic/atomic-instrumented.h#n365
