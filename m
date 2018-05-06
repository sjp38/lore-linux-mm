Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 132E36B000C
	for <linux-mm@kvack.org>; Sun,  6 May 2018 06:48:05 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id g26-v6so8009014lfb.20
        for <linux-mm@kvack.org>; Sun, 06 May 2018 03:48:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m13-v6sor3675949ljj.33.2018.05.06.03.48.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 06 May 2018 03:48:03 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <CACT4Y+YLj_oNkD7UH-MS3StQG1NBp-gDQ=goKrC9RNET216G-Q@mail.gmail.com>
References: <alpine.DEB.2.20.1803171208370.21003@alpaca> <CACT4Y+aLqY6wUfRMto_CZxPRSyvPKxK8ucvAmAY-aR_gq8fOAg@mail.gmail.com>
 <20180319172902.GB37438@google.com> <99fbbbe3-df05-446b-9ce0-55787ea038f3@googlegroups.com>
 <CACT4Y+YLj_oNkD7UH-MS3StQG1NBp-gDQ=goKrC9RNET216G-Q@mail.gmail.com>
From: Sedat Dilek <sedat.dilek@gmail.com>
Date: Sun, 6 May 2018 12:48:02 +0200
Message-ID: <CA+icZUWpg8dAtsBMzhKRt+6fyPdmHqw+Uq28ACr6byYtb42Mtg@mail.gmail.com>
Subject: Re: clang fails on linux-next since commit 8bf705d13039
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: kasan-dev <kasan-dev@googlegroups.com>, Matthias Kaehlcke <mka@chromium.org>, Linux-MM <linux-mm@kvack.org>, llvmlinux@lists.linuxfoundation.org

On Sun, May 6, 2018 at 12:44 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Sun, May 6, 2018 at 12:41 PM,  <sedat.dilek@gmail.com> wrote:
>>
>>
>> Am Montag, 19. M=C3=A4rz 2018 18:29:04 UTC+1 schrieb Matthias Kaehlcke:
>>>
>>> El Mon, Mar 19, 2018 at 09:43:25AM +0300 Dmitry Vyukov ha dit:
>>>
>>> > On Sat, Mar 17, 2018 at 2:13 PM, Lukas Bulwahn <lukas....@gmail.com>
>>> > wrote:
>>> > > Hi Dmitry, hi Ingo,
>>> > >
>>> > > since commit 8bf705d13039 ("locking/atomic/x86: Switch atomic.h to =
use
>>> > > atomic-instrumented.h")
>>> > > on linux-next (tested and bisected from tag next-20180316), compili=
ng
>>> > > the
>>> > > kernel with clang fails with:
>>> > >
>>> > > In file included from arch/x86/entry/vdso/vdso32/vclock_gettime.c:3=
3:
>>> > > In file included from
>>> > > arch/x86/entry/vdso/vdso32/../vclock_gettime.c:15:
>>> > > In file included from ./arch/x86/include/asm/vgtod.h:6:
>>> > > In file included from ./include/linux/clocksource.h:13:
>>> > > In file included from ./include/linux/timex.h:56:
>>> > > In file included from ./include/uapi/linux/timex.h:56:
>>> > > In file included from ./include/linux/time.h:6:
>>> > > In file included from ./include/linux/seqlock.h:36:
>>> > > In file included from ./include/linux/spinlock.h:51:
>>> > > In file included from ./include/linux/preempt.h:81:
>>> > > In file included from ./arch/x86/include/asm/preempt.h:7:
>>> > > In file included from ./include/linux/thread_info.h:38:
>>> > > In file included from ./arch/x86/include/asm/thread_info.h:53:
>>> > > In file included from ./arch/x86/include/asm/cpufeature.h:5:
>>> > > In file included from ./arch/x86/include/asm/processor.h:21:
>>> > > In file included from ./arch/x86/include/asm/msr.h:67:
>>> > > In file included from ./arch/x86/include/asm/atomic.h:279:
>>> > > ./include/asm-generic/atomic-instrumented.h:295:10: error: invalid
>>> > > output size for constraint '=3Da'
>>> > >                 return arch_cmpxchg((u64 *)ptr, (u64)old, (u64)new)=
;
>>> > >                        ^
>>> > > ./arch/x86/include/asm/cmpxchg.h:149:2: note: expanded from macro
>>> > > 'arch_cmpxchg'
>>> > >         __cmpxchg(ptr, old, new, sizeof(*(ptr)))
>>> > >         ^
>>> > > ./arch/x86/include/asm/cmpxchg.h:134:2: note: expanded from macro
>>> > > '__cmpxchg'
>>> > >         __raw_cmpxchg((ptr), (old), (new), (size), LOCK_PREFIX)
>>> > >         ^
>>> > > ./arch/x86/include/asm/cmpxchg.h:95:17: note: expanded from macro
>>> > > '__raw_cmpxchg'
>>> > >                              : "=3Da" (__ret), "+m" (*__ptr)
>>> > > \
>>> > >                                      ^
>>> > >
>>> > > (... and some more similar and closely related errors)
>>> >
>>> >
>>> > Thanks for reporting, Lukas.
>>> >
>>> > +more people who are more aware of the current state of clang for
>>> > kernel.
>>> >
>>> > Are there are known issues in '=3Da' constraint handling between gcc =
and
>>> > clang? Is there a recommended way to resolve them?
>>> >
>>> > Also, Lukas what's your version of clang? Potentially there are some
>>> > fixes for kernel in the very latest versions of clang.
>>>
>>> My impression is that the problem only occurs in code built for
>>> 32-bit (like arch/x86/entry/vdso/vdso32/*), where the use of a 64-bit
>>> address with a '=3Da' constraint is indeed invalid. I think the 'root
>>> cause' is that clang parses unreachable code before it discards it:
>>>
>>> static __always_inline unsigned long
>>> cmpxchg_local_size(volatile void *ptr, unsigned long old, unsigned long
>>> new,
>>>                    int size)
>>> {
>>>         ...
>>>         switch (size) {
>>>         ...
>>>         case 8:
>>>                 BUILD_BUG_ON(sizeof(unsigned long) !=3D 8);
>>>                 return arch_cmpxchg_local((u64 *)ptr, (u64)old, (u64)ne=
w);
>>>         }
>>>            ...
>>> }
>>>
>>> For 32-bit builds size is 4 and the code in the 'offending' branch is
>>> unreachable, however clang still parses it.
>>>
>>> d135b8b5060e ("arm64: uaccess: suppress spurious clang warning") fixes
>>> a similar issue.
>>
>>
>> When forcing to build with '-O0' instead of default '-O2' I can see this=
...
>>
>>  ./include/asm-generic/atomic-instrumented.h:364:3: error: array size is
>> negative
>>                 BUILD_BUG_ON(sizeof(unsigned long) !=3D 8);
>>                 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>> ./include/linux/build_bug.h:66:52: note: expanded from macro 'BUILD_BUG_=
ON'
>> #define BUILD_BUG_ON(condition) ((void)sizeof(char[1 - 2*!!(condition)])=
)
>>                                                    ^~~~~~~~~~~~~~~~~~~
>
>
> With clang or gcc?

clang version 7 (svn330207) and binutils/ld 2.30.

- Sedat -
