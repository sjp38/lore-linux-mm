Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1013F6B066D
	for <linux-mm@kvack.org>; Fri, 11 May 2018 10:37:37 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id b5-v6so3653152otf.8
        for <linux-mm@kvack.org>; Fri, 11 May 2018 07:37:37 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o49-v6si1257238otc.86.2018.05.11.07.37.35
        for <linux-mm@kvack.org>;
        Fri, 11 May 2018 07:37:36 -0700 (PDT)
Date: Fri, 11 May 2018 15:37:31 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v2] arm: port KCOV to arm
Message-ID: <20180511143731.h4kqm7xc5n7hdr3c@lakrids.cambridge.arm.com>
References: <20180511143248.112484-1-dvyukov@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180511143248.112484-1-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: linux@armlinux.org.uk, liuwenliang@huawei.com, catalin.marinas@arm.com, inux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Koguchi Takuo <takuo.koguchi.sw@hitachi.com>, linux-arm-kernel@lists.infradead.org, syzkaller@googlegroups.com

On Fri, May 11, 2018 at 04:32:48PM +0200, Dmitry Vyukov wrote:
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
>  	select ARCH_HAS_DEVMEM_IS_ALLOWED
>  	select ARCH_HAS_ELF_RANDOMIZE
>  	select ARCH_HAS_FORTIFY_SOURCE
> +	select ARCH_HAS_KCOV
>  	select ARCH_HAS_PTE_SPECIAL if ARM_LPAE
> -	select ARCH_HAS_SET_MEMORY
>  	select ARCH_HAS_PHYS_TO_DMA
> +	select ARCH_HAS_SET_MEMORY
>  	select ARCH_HAS_STRICT_KERNEL_RWX if MMU && !XIP_KERNEL
>  	select ARCH_HAS_STRICT_MODULE_RWX if MMU
>  	select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST

It might be worth mentioning in the commit message that this also cleans
up an existing unordered entry in the arm Kconfig.

Otherwise, this looks good to me, assumign it goes in after my kcov core
fixups. FWIW:

Acked-by: Mark Rutland <mark.rutland@arm.com>

Thanks,
Mark.

> diff --git a/arch/arm/boot/compressed/Makefile b/arch/arm/boot/compressed/Makefile
> index 6a4e7341ecd3..5f5f081e4879 100644
> --- a/arch/arm/boot/compressed/Makefile
> +++ b/arch/arm/boot/compressed/Makefile
> @@ -25,6 +25,9 @@ endif
>  
>  GCOV_PROFILE		:= n
>  
> +# Prevents link failures: __sanitizer_cov_trace_pc() is not linked in.
> +KCOV_INSTRUMENT		:= n
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
>  CFLAGS_switch.o		   += $(CFLAGS_ARMV7VE)
>  obj-$(CONFIG_KVM_ARM_HOST) += s2-setup.o
> +
> +# KVM code is run at a different exception code with a different map, so
> +# compiler instrumentation that inserts callbacks or checks into the code may
> +# cause crashes. Just disable it.
> +GCOV_PROFILE	:= n
> +KASAN_SANITIZE	:= n
> +UBSAN_SANITIZE	:= n
> +KCOV_INSTRUMENT	:= n
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
