Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 474046B0008
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 13:55:00 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c5so10024985pfn.17
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 10:55:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a32-v6sor233496pla.4.2018.03.19.10.54.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Mar 2018 10:54:59 -0700 (PDT)
Date: Mon, 19 Mar 2018 10:54:57 -0700
From: Matthias Kaehlcke <mka@chromium.org>
Subject: Re: clang fails on linux-next since commit 8bf705d13039
Message-ID: <20180319175457.GC37438@google.com>
References: <alpine.DEB.2.20.1803171208370.21003@alpaca>
 <CACT4Y+aLqY6wUfRMto_CZxPRSyvPKxK8ucvAmAY-aR_gq8fOAg@mail.gmail.com>
 <20180319172902.GB37438@google.com>
 <CACT4Y+Z9xeWvu5XUy_qNTewihuCC1-2a0hZDuymU6PA_3NJ90Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CACT4Y+Z9xeWvu5XUy_qNTewihuCC1-2a0hZDuymU6PA_3NJ90Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Lukas Bulwahn <lukas.bulwahn@gmail.com>, Nick Desaulniers <ndesaulniers@google.com>, Greg Hackmann <ghackmann@google.com>, Luis Lozano <llozano@google.com>, Michael Davidson <md@google.com>, Sami Tolvanen <samitolvanen@google.com>, Paul Lawrence <paullawrence@google.com>, Ingo Molnar <mingo@kernel.org>, Linux-MM <linux-mm@kvack.org>, kasan-dev <kasan-dev@googlegroups.com>, llvmlinux@lists.linuxfoundation.org, sil2review@lists.osadl.org, Manoj Gupta <manojgupta@chromium.org>, Stephen Hines <srhines@google.com>

El Mon, Mar 19, 2018 at 06:39:32PM +0100 Dmitry Vyukov ha dit:

> On Mon, Mar 19, 2018 at 6:29 PM, Matthias Kaehlcke <mka@chromium.org> wrote:
> > El Mon, Mar 19, 2018 at 09:43:25AM +0300 Dmitry Vyukov ha dit:
> >
> >> On Sat, Mar 17, 2018 at 2:13 PM, Lukas Bulwahn <lukas.bulwahn@gmail.com> wrote:
> >> > Hi Dmitry, hi Ingo,
> >> >
> >> > since commit 8bf705d13039 ("locking/atomic/x86: Switch atomic.h to use atomic-instrumented.h")
> >> > on linux-next (tested and bisected from tag next-20180316), compiling the
> >> > kernel with clang fails with:
> >> >
> >> > In file included from arch/x86/entry/vdso/vdso32/vclock_gettime.c:33:
> >> > In file included from arch/x86/entry/vdso/vdso32/../vclock_gettime.c:15:
> >> > In file included from ./arch/x86/include/asm/vgtod.h:6:
> >> > In file included from ./include/linux/clocksource.h:13:
> >> > In file included from ./include/linux/timex.h:56:
> >> > In file included from ./include/uapi/linux/timex.h:56:
> >> > In file included from ./include/linux/time.h:6:
> >> > In file included from ./include/linux/seqlock.h:36:
> >> > In file included from ./include/linux/spinlock.h:51:
> >> > In file included from ./include/linux/preempt.h:81:
> >> > In file included from ./arch/x86/include/asm/preempt.h:7:
> >> > In file included from ./include/linux/thread_info.h:38:
> >> > In file included from ./arch/x86/include/asm/thread_info.h:53:
> >> > In file included from ./arch/x86/include/asm/cpufeature.h:5:
> >> > In file included from ./arch/x86/include/asm/processor.h:21:
> >> > In file included from ./arch/x86/include/asm/msr.h:67:
> >> > In file included from ./arch/x86/include/asm/atomic.h:279:
> >> > ./include/asm-generic/atomic-instrumented.h:295:10: error: invalid output size for constraint '=a'
> >> >                 return arch_cmpxchg((u64 *)ptr, (u64)old, (u64)new);
> >> >                        ^
> >> > ./arch/x86/include/asm/cmpxchg.h:149:2: note: expanded from macro 'arch_cmpxchg'
> >> >         __cmpxchg(ptr, old, new, sizeof(*(ptr)))
> >> >         ^
> >> > ./arch/x86/include/asm/cmpxchg.h:134:2: note: expanded from macro '__cmpxchg'
> >> >         __raw_cmpxchg((ptr), (old), (new), (size), LOCK_PREFIX)
> >> >         ^
> >> > ./arch/x86/include/asm/cmpxchg.h:95:17: note: expanded from macro '__raw_cmpxchg'
> >> >                              : "=a" (__ret), "+m" (*__ptr)              \
> >> >                                      ^
> >> >
> >> > (... and some more similar and closely related errors)
> >>
> >>
> >> Thanks for reporting, Lukas.
> >>
> >> +more people who are more aware of the current state of clang for kernel.
> >>
> >> Are there are known issues in '=a' constraint handling between gcc and
> >> clang? Is there a recommended way to resolve them?
> >>
> >> Also, Lukas what's your version of clang? Potentially there are some
> >> fixes for kernel in the very latest versions of clang.
> >
> > My impression is that the problem only occurs in code built for
> > 32-bit (like arch/x86/entry/vdso/vdso32/*), where the use of a 64-bit
> > address with a '=a' constraint is indeed invalid. I think the 'root
> > cause' is that clang parses unreachable code before it discards it:
> >
> > static __always_inline unsigned long
> > cmpxchg_local_size(volatile void *ptr, unsigned long old, unsigned long new,
> >                    int size)
> > {
> >         ...
> >         switch (size) {
> >         ...
> >         case 8:
> >                 BUILD_BUG_ON(sizeof(unsigned long) != 8);
> >                 return arch_cmpxchg_local((u64 *)ptr, (u64)old, (u64)new);
> >         }
> >         ...
> > }
> >
> > For 32-bit builds size is 4 and the code in the 'offending' branch is
> > unreachable, however clang still parses it.
> >
> > d135b8b5060e ("arm64: uaccess: suppress spurious clang warning") fixes
> > a similar issue.
> 
> 
> Thanks!
> 
> Do I understand it correctly that this is being fixed in clang?

Personally I am not aware of any development on that side, however I'm
not an LLVM dev.
