Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4BFC26B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 00:20:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e189so370608709pfa.2
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 21:20:31 -0700 (PDT)
Received: from out4433.biz.mail.alibaba.com (out4433.biz.mail.alibaba.com. [47.88.44.33])
        by mx.google.com with ESMTP id y191si1959677pfg.99.2016.07.03.21.20.29
        for <linux-mm@kvack.org>;
        Sun, 03 Jul 2016 21:20:30 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <006001d1d5a8$dd26e1f0$9774a5d0$@alibaba-inc.com>
In-Reply-To: <006001d1d5a8$dd26e1f0$9774a5d0$@alibaba-inc.com>
Subject: Re: [PATCH 3/4] x86: disallow running with 32-bit PTEs to work around erratum
Date: Mon, 04 Jul 2016 12:20:15 +0800
Message-ID: <006401d1d5ab$5e154070$1a3fc150$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Dave Hansen' <dave@sr71.net>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> 
> The Intel(R) Xeon Phi(TM) Processor x200 Family (codename: Knights
> Landing) has an erratum where a processor thread setting the Accessed
> or Dirty bits may not do so atomically against its checks for the
> Present bit.  This may cause a thread (which is about to page fault)
> to set A and/or D, even though the Present bit had already been
> atomically cleared.
> 
> If the PTE is used for storing a swap index or a NUMA migration index,
> the A bit could be misinterpreted as part of the swap type.  The stray
> bits being set cause a software-cleared PTE to be interpreted as a
> swap entry.  In some cases (like when the swap index ends up being
> for a non-existent swapfile), the kernel detects the stray value
> and WARN()s about it, but there is no guarantee that the kernel can
> always detect it.
> 
> When we have 64-bit PTEs (64-bit mode or 32-bit PAE), we were able
> to move the swap PTE format around to avoid these troublesome bits.
> But, 32-bit non-PAE is tight on bits.  So, disallow it from running
> on this hardware.  I can't imagine anyone wanting to run 32-bit
> on this hardware, but this is the safe thing to do.
> 
> ---

<jawoff>

Isn't this work from Mr. Tlb?
>
>  b/arch/x86/boot/boot.h     |    1 +
>  b/arch/x86/boot/cpu.c      |    2 ++
>  b/arch/x86/boot/cpucheck.c |   32 ++++++++++++++++++++++++++++++++
>  b/arch/x86/boot/cpuflags.c |    1 +
>  b/arch/x86/boot/cpuflags.h |    1 +
>  5 files changed, 37 insertions(+)
> 
> diff -puN arch/x86/boot/boot.h~knl-strays-40-disallow-non-PAE-32-bit-on-KNL \
>                 arch/x86/boot/boot.h
> --- a/arch/x86/boot/boot.h~knl-strays-40-disallow-non-PAE-32-bit-on-KNL	2016-07-01 \
>                 10:42:07.302790241 -0700
> +++ b/arch/x86/boot/boot.h	2016-07-01 10:42:07.311790650 -0700
> @@ -295,6 +295,7 @@ static inline int cmdline_find_option_bo
> 
>  /* cpu.c, cpucheck.c */
>  int check_cpu(int *cpu_level_ptr, int *req_level_ptr, u32 **err_flags_ptr);
> +int check_knl_erratum(void);
>  int validate_cpu(void);
> 
>  /* early_serial_console.c */
> diff -puN arch/x86/boot/cpu.c~knl-strays-40-disallow-non-PAE-32-bit-on-KNL \
>                 arch/x86/boot/cpu.c
> --- a/arch/x86/boot/cpu.c~knl-strays-40-disallow-non-PAE-32-bit-on-KNL	2016-07-01 \
>                 10:42:07.303790286 -0700
> +++ b/arch/x86/boot/cpu.c	2016-07-01 10:42:07.312790695 -0700
> @@ -93,6 +93,8 @@ int validate_cpu(void)
>  		show_cap_strs(err_flags);
>  		putchar('\n');
>  		return -1;
> +	} else if (check_knl_erratum()) {
> +		return -1;
>  	} else {
>  		return 0;
>  	}
> diff -puN arch/x86/boot/cpucheck.c~knl-strays-40-disallow-non-PAE-32-bit-on-KNL \
>                 arch/x86/boot/cpucheck.c
> --- a/arch/x86/boot/cpucheck.c~knl-strays-40-disallow-non-PAE-32-bit-on-KNL	2016-07-01 \
>                 10:42:07.305790377 -0700
> +++ b/arch/x86/boot/cpucheck.c	2016-07-01 10:42:07.312790695 -0700
> @@ -24,6 +24,7 @@
>  # include "boot.h"
>  #endif
>  #include <linux/types.h>
> +#include <asm/intel-family.h>
>  #include <asm/processor-flags.h>
>  #include <asm/required-features.h>
>  #include <asm/msr-index.h>
> @@ -175,6 +176,8 @@ int check_cpu(int *cpu_level_ptr, int *r
>  			puts("WARNING: PAE disabled. Use parameter 'forcepae' to enable at your own \
> risk!\n");  }
>  	}
> +	if (!err)
> +		err = check_knl_erratum();
> 
>  	if (err_flags_ptr)
>  		*err_flags_ptr = err ? err_flags : NULL;
> @@ -185,3 +188,32 @@ int check_cpu(int *cpu_level_ptr, int *r
> 
>  	return (cpu.level < req_level || err) ? -1 : 0;
>  }
> +
> +int check_knl_erratum(void)

s/knl/xeon_knl/ ?
> +{
> +	/*
> +	 * First check for the affected model/family:
> +	 */
> +	if (!is_intel() ||
> +	    cpu.family != 6 ||
> +	    cpu.model != INTEL_FAM6_XEON_PHI_KNL)
> +		return 0;
> +
> +	/*
> +	 * This erratum affects the Accessed/Dirty bits, and can
> +	 * cause stray bits to be set in !Present PTEs.  We have
> +	 * enough bits in our 64-bit PTEs (which we have on real
> +	 * 64-bit mode or PAE) to avoid using these troublesome
> +	 * bits.  But, we do not have enough soace in our 32-bit
> +	 * PTEs.  So, refuse to run on 32-bit non-PAE kernels.
> +	 */
> +	if (IS_ENABLED(CONFIG_X86_64) || IS_ENABLED(CONFIG_X86_PAE))
> +		return 0;
> +
> +	puts("This 32-bit kernel can not run on this processor due\n"
> +	     "to a processor erratum.  Use a 64-bit kernel, or PAE.\n\n");

Give processor name to the scared readers please.

> +
> +	return -1;
> +}
> +
> +
> diff -puN arch/x86/boot/cpuflags.c~knl-strays-40-disallow-non-PAE-32-bit-on-KNL \
>                 arch/x86/boot/cpuflags.c
> --- a/arch/x86/boot/cpuflags.c~knl-strays-40-disallow-non-PAE-32-bit-on-KNL	2016-07-01 \
>                 10:42:07.307790468 -0700
> +++ b/arch/x86/boot/cpuflags.c	2016-07-01 10:42:07.312790695 -0700
> @@ -102,6 +102,7 @@ void get_cpuflags(void)
>  			cpuid(0x1, &tfms, &ignored, &cpu.flags[4],
>  			      &cpu.flags[0]);
>  			cpu.level = (tfms >> 8) & 15;
> +			cpu.family = cpu.level;
>  			cpu.model = (tfms >> 4) & 15;
>  			if (cpu.level >= 6)
>  				cpu.model += ((tfms >> 16) & 0xf) << 4;
> diff -puN arch/x86/boot/cpuflags.h~knl-strays-40-disallow-non-PAE-32-bit-on-KNL \
>                 arch/x86/boot/cpuflags.h
> --- a/arch/x86/boot/cpuflags.h~knl-strays-40-disallow-non-PAE-32-bit-on-KNL	2016-07-01 \
>                 10:42:07.308790514 -0700
> +++ b/arch/x86/boot/cpuflags.h	2016-07-01 10:42:07.313790740 -0700
> @@ -6,6 +6,7 @@
> 
>  struct cpu_features {
>  	int level;		/* Family, or 64 for x86-64 */
> +	int family;		/* Family, always */
>  	int model;
>  	u32 flags[NCAPINTS];
>  };
> _
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
