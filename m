Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0184A6B0664
	for <linux-mm@kvack.org>; Fri, 11 May 2018 10:36:36 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id z16-v6so1921883pgv.16
        for <linux-mm@kvack.org>; Fri, 11 May 2018 07:36:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c21-v6sor848638pgn.162.2018.05.11.07.36.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 May 2018 07:36:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180511143248.112484-1-dvyukov@google.com>
References: <20180511143248.112484-1-dvyukov@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 11 May 2018 16:36:13 +0200
Message-ID: <CACT4Y+YVpA95QWSkK32urFZu+-jPp-C9ExKQx1+uEvYOrH8png@mail.gmail.com>
Subject: Re: [PATCH v2] arm: port KCOV to arm
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>, Mark Rutland <mark.rutland@arm.com>, Abbott Liu <liuwenliang@huawei.com>, Catalin Marinas <catalin.marinas@arm.com>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Koguchi Takuo <takuo.koguchi.sw@hitachi.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, syzkaller <syzkaller@googlegroups.com>

On Fri, May 11, 2018 at 4:32 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> KCOV is code coverage collection facility used, in particular, by syzkaller
> system call fuzzer. There is some interest in using syzkaller on arm devices.
> So port KCOV to arm.
>
> On implementation level this merely declares that KCOV is supported and
> disables instrumentation of 3 special cases. Reasons for disabling are
> commented in code.
>
> Tested with qemu-system-arm/vexpress-a15.
>
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Russell King <linux@armlinux.org.uk>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Abbott Liu <liuwenliang@huawei.com>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Koguchi Takuo <takuo.koguchi.sw@hitachi.com>
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-mm@kvack.org
> Cc: syzkaller@googlegroups.com
>
> ---
>
> Changes since v1:
>  - remove disable of instrumentation for arch/arm/mm/fault.c
>  - disable instrumentation of arch/arm/kvm/hyp/*
>  - resort ARCH_HAS_KCOV alphabetically


Andrew, this is for MM tree because this depends on the following
patches in MM tree:

    kcov: prefault the kcov_area
    kcov: ensure irq code sees a valid area
    sched/core / kcov: avoid kcov_area during task switch



> ---
>  arch/arm/Kconfig                  | 3 ++-
>  arch/arm/boot/compressed/Makefile | 3 +++
>  arch/arm/kvm/hyp/Makefile         | 8 ++++++++
>  arch/arm/vdso/Makefile            | 3 +++
>  4 files changed, 16 insertions(+), 1 deletion(-)
>
> diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
> index 3493f840e89c..34591796c36f 100644
> --- a/arch/arm/Kconfig
> +++ b/arch/arm/Kconfig
> @@ -8,9 +8,10 @@ config ARM
>         select ARCH_HAS_DEVMEM_IS_ALLOWED
>         select ARCH_HAS_ELF_RANDOMIZE
>         select ARCH_HAS_FORTIFY_SOURCE
> +       select ARCH_HAS_KCOV
>         select ARCH_HAS_PTE_SPECIAL if ARM_LPAE
> -       select ARCH_HAS_SET_MEMORY
>         select ARCH_HAS_PHYS_TO_DMA
> +       select ARCH_HAS_SET_MEMORY
>         select ARCH_HAS_STRICT_KERNEL_RWX if MMU && !XIP_KERNEL
>         select ARCH_HAS_STRICT_MODULE_RWX if MMU
>         select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
> diff --git a/arch/arm/boot/compressed/Makefile b/arch/arm/boot/compressed/Makefile
> index 6a4e7341ecd3..5f5f081e4879 100644
> --- a/arch/arm/boot/compressed/Makefile
> +++ b/arch/arm/boot/compressed/Makefile
> @@ -25,6 +25,9 @@ endif
>
>  GCOV_PROFILE           := n
>
> +# Prevents link failures: __sanitizer_cov_trace_pc() is not linked in.
> +KCOV_INSTRUMENT                := n
> +
>  #
>  # Architecture dependencies
>  #
> diff --git a/arch/arm/kvm/hyp/Makefile b/arch/arm/kvm/hyp/Makefile
> index 7fc0638f263a..d2b5ec9c4b92 100644
> --- a/arch/arm/kvm/hyp/Makefile
> +++ b/arch/arm/kvm/hyp/Makefile
> @@ -23,3 +23,11 @@ obj-$(CONFIG_KVM_ARM_HOST) += hyp-entry.o
>  obj-$(CONFIG_KVM_ARM_HOST) += switch.o
>  CFLAGS_switch.o                   += $(CFLAGS_ARMV7VE)
>  obj-$(CONFIG_KVM_ARM_HOST) += s2-setup.o
> +
> +# KVM code is run at a different exception code with a different map, so
> +# compiler instrumentation that inserts callbacks or checks into the code may
> +# cause crashes. Just disable it.
> +GCOV_PROFILE   := n
> +KASAN_SANITIZE := n
> +UBSAN_SANITIZE := n
> +KCOV_INSTRUMENT        := n
> diff --git a/arch/arm/vdso/Makefile b/arch/arm/vdso/Makefile
> index bb4118213fee..f4efff9d3afb 100644
> --- a/arch/arm/vdso/Makefile
> +++ b/arch/arm/vdso/Makefile
> @@ -30,6 +30,9 @@ CFLAGS_vgettimeofday.o = -O2
>  # Disable gcov profiling for VDSO code
>  GCOV_PROFILE := n
>
> +# Prevents link failures: __sanitizer_cov_trace_pc() is not linked in.
> +KCOV_INSTRUMENT := n
> +
>  # Force dependency
>  $(obj)/vdso.o : $(obj)/vdso.so
>
> --
> 2.17.0.441.gb46fe60e1d-goog
>
