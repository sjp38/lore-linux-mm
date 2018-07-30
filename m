Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 22D876B000A
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 04:21:26 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id e23-v6so10303558oii.10
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 01:21:26 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f188-v6si7346349oib.268.2018.07.30.01.21.24
        for <linux-mm@kvack.org>;
        Mon, 30 Jul 2018 01:21:24 -0700 (PDT)
Date: Mon, 30 Jul 2018 09:21:16 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [llvmlinux] clang fails on linux-next since commit 8bf705d13039
Message-ID: <20180730082055.r46gplv3cssmzly2@lakrids.cambridge.arm.com>
References: <alpine.DEB.2.20.1803171208370.21003@alpaca>
 <CACT4Y+aLqY6wUfRMto_CZxPRSyvPKxK8ucvAmAY-aR_gq8fOAg@mail.gmail.com>
 <20180319172902.GB37438@google.com>
 <99fbbbe3-df05-446b-9ce0-55787ea038f3@googlegroups.com>
 <CACT4Y+YLj_oNkD7UH-MS3StQG1NBp-gDQ=goKrC9RNET216G-Q@mail.gmail.com>
 <CA+icZUWpg8dAtsBMzhKRt+6fyPdmHqw+Uq28ACr6byYtb42Mtg@mail.gmail.com>
 <CACT4Y+bvN+Fcm6K_UtsL4rqfWtqUimUNpBS4OnviEfbVvPvqHg@mail.gmail.com>
 <CA+icZUVtK+Z_TLSevtheKSBp+WcfP2s+gbZ1meV1e+yKccQJdA@mail.gmail.com>
 <5B0CF7EF02000078001C677A@prv1-mh.provo.novell.com>
 <CA+icZUUDx5CRE661fWXDQ5CEFrSTy64nGPryZRCiHVOHOAWOWA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+icZUUDx5CRE661fWXDQ5CEFrSTy64nGPryZRCiHVOHOAWOWA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sedat Dilek <sedat.dilek@gmail.com>
Cc: Matthias Kaehlcke <mka@chromium.org>, Dmitry Vyukov <dvyukov@google.com>, Greg Hackmann <ghackmann@google.com>, Luis Lozano <llozano@google.com>, Michael Davidson <md@google.com>, Nick Desaulniers <ndesaulniers@google.com>, Paul Lawrence <paullawrence@google.com>, Sami Tolvanen <samitolvanen@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org, llvmlinux@lists.linuxfoundation.org, sil2review@lists.osadl.org, Jan Beulich <JBeulich@suse.com>, Peter Zijlstra <peterz@infradead.org>

On Sun, Jul 29, 2018 at 08:12:00PM +0200, Sedat Dilek wrote:
> [ TO Mark Rutland ]
> 
> Hi,

Hi,

> I was able to build a Linux v4.18-rc6 with tip.git#locking/core [1] on
> top of it here on Debian/buster AMD64.
> 
> The patch of interest is [2]...
> 
> df79ed2c0643 locking/atomics: Simplify cmpxchg() instrumentation
> 
> ...and some more locking/atomics[/x86] may be interesting.
> 
> I had also to apply an asm-goto fix to reduce the number of warnings
> when building with clang-7 (version
> 7.0.0-svn337957-1~exp1+0~20180725200907.1908~1.gbpcccb1b (trunk)).

Just to be clear, clang 7.0.0 has not been released yet, and this is a
trunk build of clang, right?

Do any released versions of clang (e.g. 6.0.1) build a working kernel?

> CONFIG_DRM_AMDGPU=m is BROKEN and a known issue [3].
> 
> I had to hack my fakeroot-sysv binary to workaround a fatal build-stop
> by commenting the part "nested operation not yet supported" when using
> bindeb-pkg make-target.

Does upstream build at all with clang, or are you always having to apply
a number of modifications?

Which config are you using?

> The kernel does ***not boot*** on bare metal.

Ok. Does the prior commit boot?

> More details see [4] and [5] for the clang-side.

It's not clear to me how these relate to the patch in question. AFAICT,
those are build-time errors, but you say that the kernel doesn't boot
(which implies it built).

Are [4,5] relevant to this commit, or to the (unrelated) issue [3]?

My patch removes the switch, so this doesn't look like the same issue.

Thanks,
Mark.

> 
> - Sedat -
> 
> [1] https://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git/log/?h=locking/core
> [2] https://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git/commit/?h=locking/core&id=df79ed2c064363cdc7d2d896923c1885d4e30520
> [3] https://lists.freedesktop.org/archives/amd-gfx/2018-July/024634.html
> [4] https://github.com/ClangBuiltLinux/linux/issues/3
> [5] https://bugs.llvm.org/show_bug.cgi?id=33587

> From 5c3485197eab808768271d72e188ad11b6fcecd4 Mon Sep 17 00:00:00 2001
> From: Sedat Dilek <sedat.dilek@credativ.de>
> Date: Fri, 8 Jun 2018 18:23:26 +0200
> Subject: [PATCH] x86: Warn clang does not support asm-goto
> 
> Signed-off-by: Sedat Dilek <sedat.dilek@credativ.de>
> ---
>  arch/x86/Makefile                 | 2 +-
>  arch/x86/include/asm/cpufeature.h | 9 +--------
>  2 files changed, 2 insertions(+), 9 deletions(-)
> 
> diff --git a/arch/x86/Makefile b/arch/x86/Makefile
> index a08e82856563..6042f6f5a1be 100644
> --- a/arch/x86/Makefile
> +++ b/arch/x86/Makefile
> @@ -181,7 +181,7 @@ ifdef CONFIG_FUNCTION_GRAPH_TRACER
>  endif
>  
>  ifndef CC_HAVE_ASM_GOTO
> -  $(error Compiler lacks asm-goto support.)
> +  $(warning Compiler lacks asm-goto support.)
>  endif
>  
>  #
> diff --git a/arch/x86/include/asm/cpufeature.h b/arch/x86/include/asm/cpufeature.h
> index aced6c9290d6..79177f0efdf1 100644
> --- a/arch/x86/include/asm/cpufeature.h
> +++ b/arch/x86/include/asm/cpufeature.h
> @@ -140,16 +140,9 @@ extern void clear_cpu_cap(struct cpuinfo_x86 *c, unsigned int bit);
>  
>  #define setup_force_cpu_bug(bit) setup_force_cpu_cap(bit)
>  
> +/* Clang does not support asm-goto (see LLVM bug #9295). */
>  #if defined(__clang__) && !defined(CC_HAVE_ASM_GOTO)
>  
> -/*
> - * Workaround for the sake of BPF compilation which utilizes kernel
> - * headers, but clang does not support ASM GOTO and fails the build.
> - */
> -#ifndef __BPF_TRACING__
> -#warning "Compiler lacks ASM_GOTO support. Add -D __BPF_TRACING__ to your compiler arguments"
> -#endif
> -
>  #define static_cpu_has(bit)            boot_cpu_has(bit)
>  
>  #else
> -- 
> 2.18.0
> 
